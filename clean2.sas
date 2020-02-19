data train;
infile "/folders/myfolders/Kaggle/train.csv" dlm="," firstobs=2;
input Id   MSSubClass   MSZoning   $   LotFrontage   LotArea   Street   $   Alley   $   LotShape   $   LandContour   $   Utilities   $   LotConfig   $   LandSlope   $   Neighborhood   $   Condition1   $   Condition2   $   BldgType   $   HouseStyle   $   OverallQual   OverallCond   YearBuilt   YearRemodAdd   RoofStyle   $   RoofMatl   $   Exterior1st   $   Exterior2nd   $   MasVnrType   $   MasVnrArea   ExterQual   $   ExterCond   $   Foundation   $   BsmtQual   $   BsmtCond   $   BsmtExposure   $   BsmtFinType1   $   BsmtFinSF1   BsmtFinType2   $   BsmtFinSF2   BsmtUnfSF   TotalBsmtSF   Heating   $   HeatingQC   $   CentralAir   $   Electrical   $   X1stFlrSF   X2ndFlrSF   LowQualFinSF   GrLivArea   BsmtFullBath   BsmtHalfBath   FullBath   HalfBath   BedroomAbvGr   KitchenAbvGr   KitchenQual   $   TotRmsAbvGrd   Functional   $   Fireplaces   FireplaceQu   $   GarageType   $   GarageYrBlt   GarageFinish   $   GarageCars   GarageArea   GarageQual   $   GarageCond   $   PavedDrive   $   WoodDeckSF   OpenPorchSF   EnclosedPorch   X3SsnPorch   ScreenPorch   PoolArea   PoolQC   $   Fence   $   MiscFeature   $   MiscVal   MoSold   YrSold   SaleType   $   SaleCondition   $   SalePrice ;

data test;
infile "/folders/myfolders/Kaggle/test.csv" dlm="," firstobs=2;
input Id   MSSubClass   MSZoning   $   LotFrontage   LotArea   Street   $   Alley   $   LotShape   $   LandContour   $   Utilities   $   LotConfig   $   LandSlope   $   Neighborhood   $   Condition1   $   Condition2   $   BldgType   $   HouseStyle   $   OverallQual   OverallCond   YearBuilt   YearRemodAdd   RoofStyle   $   RoofMatl   $   Exterior1st   $   Exterior2nd   $   MasVnrType   $   MasVnrArea   ExterQual   $   ExterCond   $   Foundation   $   BsmtQual   $   BsmtCond   $   BsmtExposure   $   BsmtFinType1   $   BsmtFinSF1   BsmtFinType2   $   BsmtFinSF2   BsmtUnfSF   TotalBsmtSF   Heating   $   HeatingQC   $   CentralAir   $   Electrical   $   X1stFlrSF   X2ndFlrSF   LowQualFinSF   GrLivArea   BsmtFullBath   BsmtHalfBath   FullBath   HalfBath   BedroomAbvGr   KitchenAbvGr   KitchenQual   $   TotRmsAbvGrd   Functional   $   Fireplaces   FireplaceQu   $   GarageType   $   GarageYrBlt   GarageFinish   $   GarageCars   GarageArea   GarageQual   $   GarageCond   $   PavedDrive   $   WoodDeckSF   OpenPorchSF   EnclosedPorch   X3SsnPorch   ScreenPorch   PoolArea   PoolQC   $   Fence   $   MiscFeature   $   MiscVal   MoSold   YrSold   SaleType   $   SaleCondition   $;
/*From the intro to Kaggle video in the Assignment Word Doc*/
/*Prepare the train and test sets for prediction*/
data test;
set test;
SalePrice=.;
;
data train2;
set train test;
run;

proc univariate data = train2;
var  LotFrontage  MasVnrArea  BsmtFinSF1   BsmtFinSF2   BsmtUnfSF  
 TotalBsmtSF  BsmtFullBath BsmtHalfBath GarageYrBlt  GarageCars 
GarageArea   SalePrice ;

PROC FREQ data=train2;
TABLES  MSZoning     Alley        Utilities    Exterior1st  Exterior2nd 
  MasVnrType   BsmtQual     BsmtCond     BsmtExposure BsmtFinType1
 BsmtFinType2 Electrical   KitchenQual  Functional   FireplaceQu 
 GarageType   GarageFinish GarageQual   GarageCond   PoolQC     
 Fence        MiscFeature SaleType;

/*For variables whose NAs are not "None" replace NA with mode, value Highest Frequency*/
data train2Clean;
set train2;
IF MSZoning = "NA" THEN MSZoning = "RL";
IF Utilities = "NA" THEN Utilities = "AllPub";
IF Exterior1st = "NA" THEN Exterior1st = "VinylSd";
IF Exterior2nd = "NA" THEN Exterior2nd = "VinylSd";
IF MasVnrType = "NA" THEN MasVnrType = "None";
IF Electrical = "NA" THEN Electrical = "SBrkr";
IF KitchenQual = "NA" THEN KitchenQual = "TA";
IF Functional = "NA" THEN Functional = "Typ";
IF SaleType = "NA" THEN SaleType = "WD";
/*LotFrontage  MasVnrArea  BsmtFinSF1   BsmtFinSF2   BsmtUnfSF  
 TotalBsmtSF  BsmtFullBath BsmtHalfBath GarageYrBlt  GarageCars 
GarageArea    */
/*
data train2CleanNum;
set train2Clean;
IF LotFrontage = "." THEN LotFrontage = "68";
IF MasVnrArea = "." THEN MasVnrArea = "0";
IF BsmtFinSF1 = "." THEN BsmtFinSF1 = "368.5";
IF BsmtFinSF2 = "." THEN BsmtFinSF2 = "0";
IF BsmtUnfSF = "." THEN BsmtUnfSF = "467";
IF TotalBsmtSF = "." THEN TotalBsmtSF = "989.5";
IF BsmtFullBath = "." THEN BsmtFullBath = "0";
IF BsmtHalfBath = "." THEN BsmtHalfBath = "0";
IF GarageYrBlt = "." THEN GarageYrBlt = "1979";
IF GarageCars = "." THEN GarageCars = "2";
IF GarageArea = "." THEN GarageArea = "RL";
*/
PROC FREQ data=train2Clean;
TABLES MasVnrType BsmtQual GarageType;

data train2CleanNum;
set train2Clean;
IF LotFrontage = . THEN LotFrontage = 68;
/*All  missing MasVnrArea had MasVnrType of None */
IF MasVnrArea = . THEN MasVnrArea = 0;
/*All missing GarageYrBlt  had GarageType of NA  except for 2 observations   */
IF GarageYrBlt = . THEN GarageYrBlt = 1979;
IF Id = 2121 THEN DO; 
BsmtFinSF1 = 368.5;
BsmtFinSF2 = 0;
BsmtUnfSF = 467;
TotalBsmtSF = 989.5;
BsmtFullBath = 0;
BsmtHalfBath = 0;
End;
IF Id = 2577 THEN DO;
 GarageYrBlt = 1979;
 GarageCars = 2;
 GarageArea = 480;
 END;
 IF Id = 2189 THEN DO;
 BsmtFullBath = 0;
 BsmtHalfBath = 0;
 END;


/*OR SYNTAX? Conditional Print? */

/*Recode ordinal variables Does Automatic Var Selection dummy code?*/

proc freq data=train2CleanNum;
tables ExterQual ExterCond BsmtQual BsmtCond BsmtExposure BsmtFinType1 BsmtFinType2
HeatingQC CentralAir Electrical KitchenQual Functional FireplaceQu GarageFinish GarageQual GarageCond
PoolQC Fence;

data trainRecode;
set train2CleanNum;


proc sql;
	create table trainRecode2 as
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
                
     from trainRecode
     ;
quit;

proc univariate data=trainRecode2;
var BsmtQualR;
histogram BsmtQualR;
