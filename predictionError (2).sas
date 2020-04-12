/* Calculates the Average Sum of Squared Error for your model using multiple simulations
with Do Loops

2. Go to  the line with "%macro testmodel();" right under that replace the glm statement
with your model.  
3.  In the proc glm statement, set data=CVcomplete. Do not delete the output statement under glm.
3. Run entire document.
4. Make sure your dataset has train and test vertically merged with test's SalePrices as . period
	For example:
	data test;
	set test;
	SalePrice=.;
	
	data trainTest;
	set trainTest;

5. Run: %montecarloTest(datasetName);  Replace your dataset name make sure step 4.
6. open table: aggregateError2.  Avg is your Average SSE.
*/

/*testmodel creates a table with House Id and Predicted Sale Price*/
%macro testmodel();
proc glm data=cvcomplete plots=all;
where id ne 496;
class centralair neighborhood mszoning salecondition kitchenqual ;
model lSalePrice=llotarea overallqual overallcond yearbuilt  BsmtFinSF1
   lgrlivarea totalbsmtsf  bedroomabvgr Fireplaces GarageCars  
   _2ndflrsf    _1stflrsf    
   centralair neighborhood mszoning  salecondition   kitchenqual 
    
   /solution;
	output out=results p=Predict;
	run;
	*transform log numbers into normal numbers;
	
	data results;
	set results;
	Predict=exp(Predict);
	SalePrice=Predict;
	*if sale price is below 0 change it;
	data results2;
	set results;
	if Predict>0 then SalePrice = Predict;
	if Predict < 0 then SalePrice=10000;
	keep id SalePrice;
%mend;
/*traintest2 randomly selects 438 rows of training set to be test set
and combines them with 1020 randomly selected rows to be train set.  
Returns CV complete with the random test set missing sale prices.
it saves the test set's actual house price for model evaluation later
in chart called testresponse.  */
%macro trainTest2(data,nperm,splitObs,random); 

	
	
	data trainOnly;
	set &data;
	where SalePrice NE .;
	
	/*find function that scrambles dataframe*/
	/* ------CREATE TEMPORARY DATA SET WITH RANDOM NUMBERS------ */
	 data permutation; 
	 set trainOnly;
	 array _random_ _ran_1-_ran_&nperm; 
	 do over _random_;
	 _random_=ranuni(&random); 
	 end; 
	/* ------PERMUTE AND CLUSTER THE DATA----------------------- */
	%do n=1 %to &nperm; 
	 proc sort data=permutation
	 out=_perm_; by _ran_&n; 
	 run;
	%end;
	/*only take out the first 1020 rows*/
	
	
	data CVcomplete;
	set _perm_;
	
	data testresponse;
	set _perm_;
	if _n_ >(&splitobs) then output testresponse;
	
	data CVcomplete;
	set CVcomplete;
	if _n_>(&splitobs) then lSalePrice=.;
	
	data testResponse;
	set testResponse;
	keep id SalePrice;

%mend;


/*Input is a factor variable which will be added to a glm model to generate predictions.

 output:table with predicted Sale Price for test data set

 */



%macro CVerror2(actual,predicted,colNum);
	proc sql;
	create table testPredict as
	    select test.id, test.SalePrice, predict.SalePrice as prediction
	    from &actual as test left join &predicted as predict on
	    test.id=predict.id;
	data testPredict;
	set testPredict;
	SquaredError=(SalePrice-prediction)**2;
	
	proc univariate data=testPredict;
	var SquaredError;
	ods output Moments=error;
	
	data error;
	set error;
	if Label2="Sum Observations" then output error;
	keep nValue2 colNum;
	data error;
	set error;
	colNum=&colNum;

%mend;

%macro montecarloTest(data);
	data masterError2;
	%do seed=1 %to 10001 %by 1000; 
		/*seed will be the random number seed that is used to scramble up the dataset*/
		/*At each iteration of the seed loop, there will be a new permutation of the dataset*/
		%trainTest2(&data,4,1020,&seed);
		
		/*initialize the chart that stores SSE for each variable for each permutation*/
		/*create a chart with 1 row that gives the SumSquareError for column 1*/
		%testModel();
		%cverror2(testresponse,results2,1);
		data error2;
		set error;

		
		data masterError2;
		set masterError2 error2;
	%end;
%mend;
%macro avgSSE();
	proc sql;
	create table aggregateError2 as
	select colnum,sqrt(avg(nvalue2)) as avg,sqrt(std(nvalue2)) as std,sqrt(avg(nvalue2))+sqrt(std(nvalue2)) as upper,
	sqrt(avg(nvalue2))-sqrt(std(nvalue2)) as lower 
	  from masterError2 
	  where colnum NE . 
	group by colNum
	order by avg 
	;
	
%mend;

%montecarloTest(traintests);
%avgSSE();