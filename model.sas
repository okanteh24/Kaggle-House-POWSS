/*
This file creates a multiple regression model to predict house sale price in Ames, Iowa 
given 89 variables about the house: square footage, neighborhood etc.
*/

*Read in the training dataseet which includes house features AND the actual house sale prices;
data train;
infile "train.csv" dlm="," firstobs=2;
input Id MSSubClass MSZoning $ LotFrontage LotArea Street $ Alley $ LotShape $ LandContour $ Utilities $ LotConfig $ LandSlope $ Neighborhood $ Condition1 $ Condition2 $ BldgType $ HouseStyle $ OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle $ RoofMatl $ Exterior1st $ Exterior2nd $ MasVnrType $ MasVnrArea ExterQual $ ExterCond $ Foundation $ BsmtQual $ BsmtCond $ BsmtExposure $ BsmtFinType1 $ BsmtFinSF1 BsmtFinType2 $ BsmtFinSF2 BsmtUnfSF TotalBsmtSF Heating $ HeatingQC $ CentralAir $ Electrical $ _1stflrsf _2ndflrsf LowQualFinSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr KitchenAbvGr KitchenQual $ TotRmsAbvGrd Functional $ Fireplaces FireplaceQu $ GarageType $ GarageYrBlt GarageFinish $ GarageCars GarageArea GarageQual $ GarageCond $ PavedDrive $ WoodDeckSF OpenPorchSF EnclosedPorch _3SsnPorch ScreenPorch PoolArea PoolQC $ Fence $ MiscFeature $ MiscVal MoSold YrSold SaleType $ SaleCondition $ SalePrice ;
*Read in the test dataset which includes house features without actual sale prices;
data test;
infile "test.csv" dlm="," firstobs=2;
input Id MSSubClass MSZoning $ LotFrontage LotArea Street $ Alley $ LotShape $ LandContour $ Utilities $ LotConfig $ LandSlope $ Neighborhood $ Condition1 $ Condition2 $ BldgType $ HouseStyle $ OverallQual OverallCond YearBuilt YearRemodAdd RoofStyle $ RoofMatl $ Exterior1st $ Exterior2nd $ MasVnrType $ MasVnrArea ExterQual $ ExterCond $ Foundation $ BsmtQual $ BsmtCond $ BsmtExposure $ BsmtFinType1 $ BsmtFinSF1 BsmtFinType2 $ BsmtFinSF2 BsmtUnfSF TotalBsmtSF Heating $ HeatingQC $ CentralAir $ Electrical $ _1stflrsf _2ndflrsf LowQualFinSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr KitchenAbvGr KitchenQual $ TotRmsAbvGrd Functional $ Fireplaces FireplaceQu $ GarageType $ GarageYrBlt GarageFinish $ GarageCars GarageArea GarageQual $ GarageCond $ PavedDrive $ WoodDeckSF OpenPorchSF EnclosedPorch _3SsnPorch ScreenPorch PoolArea PoolQC $ Fence $ MiscFeature $ MiscVal MoSold YrSold SaleType $ SaleCondition $ ;
/*Add the sale prices column to test set but put in missing values*/
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
*find columns with missing values;
proc freq data=trainTest; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;

* If BsmtCond is NA that means there is no basement.  So put 0 square feet
for TotalBsmtSquareFeet.  If MasVnrType is NA that means no Veneer so put 0 for MasVnrArea.
Etc... ;
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
TABLES  MSZoning  Exterior1st  Exterior2nd  Electrical   KitchenQual  Functional   FireplaceQu MiscFeature SaleType;

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

*The only values with missing variables should be Alley MasVnrType BsmtQual BsmtExposure BsmtFintype GarageTypeQualFinishCond PoolQC FireplaceQu Fence;
proc freq data=trainTest; 
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;

data trainTest;
set trainTest;
lSalePrice=log(SalePrice);

*Remove influential points for GrLivArea slope with House Sale Price;
data trainTest;
set trainTest;
if _n_ = 1299 then delete;

data trainTest;
set trainTest;
if _n_ = 524 then delete;
proc glm data=traintest;
where Neighborhood in ("NAmes","Edwards","BrkSide");
class Neighborhood;
model lsaleprice=grlivarea neighborhood;
*Log transform _1stflrsf;
data trainTest;
	set trainTest;
	if _1stflrsf = 0 then l_1stflrsf=log(_1stflrsf+0.1);
	else l_1stflrsf=log(_1stflrsf);
 
*log transform certain variables;
data traintest;
set traintest;
lgrlivarea=log(grlivarea);
llotarea=log(lotarea);
llotfrontage=log(lotfrontage);
if TotalBsmtsf=0 then lTotalBsmtSF=log(TotalBsmtSF+100);
else lTotalBsmtSF=log(totalbsmtsf);
if bsmtfinsf1=0 then lbsmtfinsf1=log(bsmtfinsf1+100);
else lbsmtfinsf1=log(bsmtfinsf1);
if openporchsf=0 then lopenporchsf=log(openporchsf+10);
else lopenporchsf=log(openporchsf);
totalArea=screenporch + grlivarea;
ltotalArea=log(totalArea);
totalrooms=TotRmsAbvGrd + bsmtfullbath + bsmthalfbath;
totalporch=openporchsf + enclosedporch +screenporch+_3SsnPorch;
baths=bsmtfullbath+(bsmthalfbath/2)+fullbath+(halfbath/2);

/*Recode ordinal variables as numbers*/
proc sql;
	create table traintestr as
   select *, case ExterQual
                when "Ex" then 5
                when "Gd" then 4
                when "TA" then 3
                when "Fa" then 2
                else 1
                end as ExterQualR,
                case ExterCond
                when "Ex" then 5
                when "Gd" then 4
                when "TA" then 3
                when "Fa" then 2
                else 1
                end as ExterCondR,
                case BsmtQual
                when "Ex" then 5
                when "Gd" then 4
                when "TA" then 3
                when "Fa" then 2
                when "Po" then 1
                else 0
                end as BsmtQualR,
                case BsmtCond
                when "Ex" then 5
                when "Gd" then 4
                when "TA" then 3
                when "Fa" then 2
                when "Po" then 1
                else 0
                end as BsmtCondR,
                case BsmtExposure
                when "Gd" then 4
                when "Av" then 3
                when "Mn" then 2
                when "No" then 1
                else 0
                end as BsmtExposureR,
                case BsmtFinType1
                when "GLQ" then 6
                when "ALQ" then 5
                when "BLQ" then 4
                when "Rec" then 3
                when "LwQ" then 2
                when "Unf" then 1
                else 0
                end as BsmtFinType1R,
                case BsmtFinType2
                when "GLQ" then 6
                when "ALQ" then 5
                when "BLQ" then 4
                when "Rec" then 3
                when "LwQ" then 2
                when "Unf" then 1
                else 0
                end as BsmtFinType2R,
                case HeatingQC
                when "Ex" then 5
                when "Gd" then 4
                when "TA" then 3
                when "Fa" then 2
                else 1
                end as HeatingQCR,
         
                 case KitchenQual
                when "Ex" then 5
                when "Gd" then 4
                when "TA" then 3
                when "Fa" then 2
                else 1
                end as KitchenQualR,
                  case FireplaceQu
                when "Ex" then 5
                when "Gd" then 4
                when "TA" then 3
                when "Fa" then 2
                when "Po" then 1
                else 0
                end as FireplaceQuR,
                case Functional
                when "Typ" then 8
                when "Min1" then 7
                when "Min2" then 6
                when "Mod" then 5
                when "Maj1" then 4
                when "Maj2" then 3
                when "Sev" then 2
                else 1
                end as FunctionalR,
                 case GarageFinish
                when "Fin" then 3
                when "RFn" then 2
                when "Unf" then 1
                else 0
                end as GarageFinishR,
                 case GarageQual
                when "Ex" then 5
                when "Gd" then 4
                when "TA" then 3
                when "Fa" then 2
                when "Po" then 1
                else 0
                end as GarageQualR,
                  case GarageCond
                when "Ex" then 5
                when "Gd" then 4
                when "TA" then 3
                when "Fa" then 2
                when "Po" then 1
                else 0
                end as GarageCondR,
                   case PoolQC
                when "Ex" then 4
                when "Gd" then 3
                when "TA" then 2
                when "Fa" then 1
                else 0
                end as PoolQCR,
                   case Fence
                when "GdPrv" then 4
                when "MnPrv" then 3
                when "GdWo" then 2
                when "MnWw" then 1
                else 0
                end as FenceR
                
     from traintest
     ;
quit;

data traintestsd;
set traintest;
/*Reduce collinearity between year variables*/
proc stdize data=traintest out=traintestsd method=std;
var  yearbuilt yearremodadd ;
data traintest;
set traintest;
if bsmtunfsf=0 then lbsmtunfsf= log(bsmtunfsf+10);
else lbsmtunfsf=log(bsmtunfsf);
if bsmtfinsf2=0 then lbsmtfinsf2= log(bsmtfinsf2+5);
else lbsmtfinsf2=log(bsmtfinsf2);
if _3SsnPorch=0 then l_3SsnPorch= log(_3SsnPorch+15);
else l_3SsnPorch=log(_3SsnPorch);
if miscval=0 then lmiscval= log(miscval+50);
else lmiscval=log(miscval);
if miscval=0 then lmssubclass= log(mssubclass+50);
else lmssubclass=log(mssubclass);
if wooddecksf=0 then lwooddecksf= log(wooddecksf+3);
else lwooddecksf=log(wooddecksf);
l_1stflrsf=log(_1stflrsf);
if _2ndflrsf=0 then l_2ndflrsf=log(_2ndflrsf+100);
else l_2ndflrsf=log(_2ndflrsf);

if enclosedporch=0 then lenclosedporch=log(enclosedporch+10);
else lenclosedporch=log(enclosedporch);
if poolarea=0 then lpoolarea=log(poolarea+100);
else lpoolarea=log(poolarea);
if lowqualfinsf=0 then llowqualfinsf=log(lowqualfinsf+40);
else llowqualfinsf=log(lowqualfinsf);

proc stdize data=traintestr out=traintests method=std;
var _1stflrsf _2ndflrsf;
*Create multiple regression model with best variables;
proc glm data=traintests plots=all;
class centralair neighborhood mszoning salecondition kitchenqual bsmtexposure  bsmtqual 
garagequal;
model lSalePrice=llotarea overallqual overallcond yearbuilt  BsmtFinSF1
   lgrlivarea totalbsmtsf  bedroomabvgr Fireplaces GarageCars  totalporch
   _2ndflrsf    _1stflrsf  
   centralair neighborhood mszoning  salecondition   kitchenqual bsmtqual
   bsmtexposure garagequal
   /solution;
output out=results p=Predict;
run;
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
where id>1460;
proc glmselect data=trainTest seed=1;
	class MSZoning Street Alley LotShape LandContour Utilities LotConfig LandSlope 
		Neighborhood Condition1 Condition2 BldgType HouseStyle RoofStyle RoofMatl 
		Exterior1st Exterior2nd MasVnrType ExterQual ExterCond Foundation BsmtQual 
		BsmtCond BsmtExposure BsmtFinType1 BsmtFinType2 Heating HeatingQC CentralAir 
		Electrical KitchenQual Functional FireplaceQu GarageType GarageFinish 
		GarageQual GarageCond PavedDrive Fence MiscFeature SaleType SaleCondition PoolQC;
	model lSalePrice=MSSubClass--SaleCondition / selection=stepwise;

proc sgscatter data=traintest;
matrix lsaleprice  wooddecksf overallcond LlotArea bsmtfullbath BedroomAbvGr;
/*wooddecksf too many 0s and cannot log transform, bsmtfullbath no visual correlation
Both are removed*/