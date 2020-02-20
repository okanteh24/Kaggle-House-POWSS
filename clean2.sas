data train;
infile "/folders/myfolders/Kaggle/train.csv" dlm="," firstobs=2;
input Id MSSubClass MSZoning $ LotFrontage LotArea Street $ Alley $ LotShape $ LandContour $ Utilities $ LotConfig $ LandSlope $ Neighborhood $ Condition1 $ Condition2 $ BldgType $ HouseStyle $ OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle $ RoofMatl $ Exterior1st $ Exterior2nd $ MasVnrType $ MasVnrArea ExterQual $ ExterCond $ Foundation $ BsmtQual $ BsmtCond $ BsmtExposure $ BsmtFinType1 $ BsmtFinSF1 BsmtFinType2 $ BsmtFinSF2 BsmtUnfSF TotalBsmtSF Heating $ HeatingQC $ CentralAir $ Electrical $ X1stFlrSF X2ndFlrSF LowQualFinSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr KitchenAbvGr KitchenQual $ TotRmsAbvGrd Functional $ Fireplaces FireplaceQu $ GarageType $ GarageYrBlt GarageFinish $ GarageCars GarageArea GarageQual $ GarageCond $ PavedDrive $ WoodDeckSF OpenPorchSF EnclosedPorch X3SsnPorch ScreenPorch PoolArea PoolQC $ Fence $ MiscFeature $ MiscVal MoSold YrSold SaleType $ SaleCondition $ SalePrice ;



data test;
infile "/folders/myfolders/Kaggle/test.csv" dlm="," firstobs=2;
input Id MSSubClass MSZoning $ LotFrontage LotArea Street $ Alley $ LotShape $ LandContour $ Utilities $ LotConfig $ LandSlope $ Neighborhood $ Condition1 $ Condition2 $ BldgType $ HouseStyle $ OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle $ RoofMatl $ Exterior1st $ Exterior2nd $ MasVnrType $ MasVnrArea ExterQual $ ExterCond $ Foundation $ BsmtQual $ BsmtCond $ BsmtExposure $ BsmtFinType1 $ BsmtFinSF1 BsmtFinType2 $ BsmtFinSF2 BsmtUnfSF TotalBsmtSF Heating $ HeatingQC $ CentralAir $ Electrical $ X1stFlrSF X2ndFlrSF LowQualFinSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr KitchenAbvGr KitchenQual $ TotRmsAbvGrd Functional $ Fireplaces FireplaceQu $ GarageType $ GarageYrBlt GarageFinish $ GarageCars GarageArea GarageQual $ GarageCond $ PavedDrive $ WoodDeckSF OpenPorchSF EnclosedPorch X3SsnPorch ScreenPorch PoolArea PoolQC $ Fence $ MiscFeature $ MiscVal MoSold YrSold SaleType $ SaleCondition $ ;
/*Prepare the train and test sets for prediction*/



data test;
set test;
SalePrice=.;
;
data trainTest;
set train test;
run;
*Find the columns with NAs or .;




proc format;
 value $missfmt 'NA'='Missing' other='Not Missing';
 value  missfmt  . ='Missing' other='Not Missing';
run;
proc freq data=trainTest; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;


/* If BsmtCond is NA that means there is no basement.  So put 0 square feet
for TotalBsmtSquareFeet.  If MasVnrType is NA that means no Veneer so put 0 for MasVnrArea.
Etc...  */
 data trainTest;
set trainTest;
if MasVnrType ="NA" AND MasVnrArea =. THEN MasVnrArea=0;   
if BsmtCond="NA" AND  BsmtFinSF1=. THEN BsmtFinSF1=0;
if BsmtCond="NA" AND  BsmtFinSF2=. THEN BsmtFinSF2=0;
if BsmtCond="NA" AND  BsmtUnfSF=. THEN BsmtUnfSF=0;
if BsmtCond="NA" AND  TotalBsmtSF=. THEN TotalBsmtSF=0;
if BsmtCond="NA" AND  BsmtFullBath=. THEN BsmtFullBath=0;
if BsmtCond="NA" AND  BsmtHalfBath=. THEN BsmtHalfBath=0;
if PoolQC="NA" AND  PoolArea=. THEN PoolArea=0;
if GarageCond="NA" AND  GarageArea=. THEN GarageArea=0;
if GarageCond="NA" AND  GarageCars=. THEN GarageCars=0;
if FireplaceQu="NA" AND  Fireplaces=. THEN Fireplaces=0;
/*LotFrontage is simply missing values so impute the MEDIAN*/
proc stdize data=trainTest out=trainTest missing=MEDIAN reponly;
   
   var LotFrontage GarageYrBlt;     /* you can list multiple variables to impute */



/*Find value of highest frequency for categorical variables with missing values*/
/*only for variables whose "NA" does not mean "None"*/
PROC FREQ data=trainTest;
TABLES  MSZoning         Exterior1st  Exterior2nd 
      Electrical   KitchenQual  Functional   FireplaceQu 
        
         MiscFeature SaleType;

data trainTest;
set trainTest;
IF MSZoning = "NA" THEN MSZoning = "RL";
IF Utilities = "NA" THEN Utilities = "AllPub";
IF Exterior1st = "NA" THEN Exterior1st = "VinylSd";
IF Exterior2nd = "NA" THEN Exterior2nd = "VinylSd";
IF MasVnrType = "NA" THEN MasVnrType = "None";
IF Electrical = "NA" THEN Electrical = "SBrkr";
IF KitchenQual = "NA" THEN KitchenQual = "TA";
IF Functional = "NA" THEN Functional = "Typ";
IF SaleType = "NA" THEN SaleType = "WD";

/*The only values with missing variables should be Alley MasVnrType BsmtQual BsmtExposure BsmtFintype
 GarageTypeQualFinishCond PoolQC FireplaceQu Fence*/
proc freq data=trainTest; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;

data trainTest;
set trainTest;
lSalePrice=log(SalePrice);
/*Insert Peter's GLMselect code*/
proc glmselect data=trainTest seed=1;
	class MSZoning Street Alley LotShape LandContour Utilities LotConfig LandSlope 
		Neighborhood Condition1 Condition2 BldgType HouseStyle RoofStyle RoofMatl 
		Exterior1st Exterior2nd MasVnrType ExterQual ExterCond Foundation BsmtQual 
		BsmtCond BsmtExposure BsmtFinType1 BsmtFinType2 Heating HeatingQC CentralAir 
		Electrical KitchenQual Functional FireplaceQu GarageType GarageFinish 
		GarageQual GarageCond PavedDrive Fence MiscFeature SaleType SaleCondition PoolQC;
	model SalePrice=MSSubClass--SaleCondition / selection=forward (choose=CV 
		stop=CV) cvmethod=split(10) CVdetails;
	output out=forward_results p=Predict;
run;



