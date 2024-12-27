* Encoding: UTF-8.
** Encoding: UTF-8.

**This code should be run in SPSS after converting original dataset .csv file (Ollé-Castellà et al., 2023: 10.34810/DATA690) into .sav file.

**Variables recoding.
RECODE P128 (0 thru 1=1) (2 thru 3=2) (ELSE=Copy) INTO KnowsOA.
VARIABLE LABELS KnowsOA 'Knows about Open Science proposals'.
EXECUTE.

AUTORECODE VARIABLES=P2 
  /INTO P2R
  /DESCENDING
  /PRINT.
RECODE P2R (2=0) (1=1) (3=1) (4=1) (5=9).
EXECUTE.
VALUE LABELS P2R
0 "Has not deposited articles"
1 "Has deposited articles"
9 "Did not publish".
VARIABLE LABELS P2R 'Deposited articles in 2019-2020?'.

RECODE P73 (6=0) (ELSE=Copy) INTO P73R.
VARIABLE LABELS P73R 'Deposited research data openly? (R)'.
VALUE LABELS P73R
0 "Has not deposited data"
1 "Has deposited data".
EXECUTE.

** Create the variable CenterType.
COMPUTE CenterType = 0.
* Condition for CenterType = 1 (Public).
IF ((P136 = 1 OR P138 = 1) AND P137 = 0 AND P139 = 0) CenterType = 1.
* Condition for CenterType = 2 (Private).
IF ((P137 = 1 OR P139 = 1) AND P136 = 0 AND P138 = 0) CenterType = 2.
* Condition for CenterType = 3 (Both).
IF ((P136 = 1 AND P137 = 1) OR (P137 = 1 AND P138 = 1) OR (P138 = 1 AND P139 = 1)) CenterType = 3.
* Condition for CenterType = 4 (Other: text in P140 different from "-").
IF (P140 ~= "-" AND CHAR.LENGTH(LTRIM(RTRIM(P140))) > 0) CenterType = 4.

* Add the variable label.
VARIABLE LABELS CenterType "Type of center (Public or Private)".
* Add value labels.
VALUE LABELS CenterType
    1 "Public"
    2 "Private"
    3 "Both"
    4 "Other".
* Review results.
FREQUENCIES VARIABLES = CenterType.

**Install SPSS TUTORIALS, then.
SPSS TUTORIALS DUMMIFY VARIABLES=Discipline
/OPTIONS NEWLABELS=LABLAB REFCAT=NONE ACTION=BOTH.
SPSS TUTORIALS DUMMIFY VARIABLES=Gender AgeGroup
/OPTIONS NEWLABELS=LABLAB REFCAT=NONE ACTION=RUN.
SPSS TUTORIALS DUMMIFY VARIABLES=CenterType
/OPTIONS NEWLABELS=LABLAB REFCAT=NONE ACTION=BOTH.

** Customized tables with Bonferroni adjustment.
CTABLES
  /VLABELS VARIABLES=P2R P3 P4 P5 P6 P7 P8 P9 P73R P74 P75 P76 P77 P78 P79 KnowsOA Gender AgeGroup 
    Discipline CenterType 
    DISPLAY=BOTH
  /TABLE P2R [C][COLPCT.COUNT PCT40.1] + P3 [C][COLPCT.COUNT PCT40.1] + P4 [C][COLPCT.COUNT 
    PCT40.1] + P5 [C][COLPCT.COUNT PCT40.1] + P6 [C][COLPCT.COUNT PCT40.1] + P7 [C][COLPCT.COUNT 
    PCT40.1] + P8 [C][COLPCT.COUNT PCT40.1] + P9 [C][COLPCT.COUNT PCT40.1] + P73R [COLPCT.COUNT 
    PCT40.1] + P74 [C][COLPCT.COUNT PCT40.1] + P75 [C][COLPCT.COUNT PCT40.1] + P76 [C][COLPCT.COUNT 
    PCT40.1] + P77 [C][COLPCT.COUNT PCT40.1] + P78 [C][COLPCT.COUNT PCT40.1] + P79 [C][COLPCT.COUNT 
    PCT40.1] BY KnowsOA [C] + Gender [C] + AgeGroup [C] + Discipline [C] + CenterType [C]
  /CATEGORIES VARIABLES=P2R P3 P4 P5 P6 P7 P8 P9 P73R P74 P75 P76 P77 P78 P79 KnowsOA ORDER=A 
    KEY=VALUE EMPTY=INCLUDE
  /CATEGORIES VARIABLES=Gender [2, 4] EMPTY=INCLUDE
  /CATEGORIES VARIABLES=AgeGroup [2, 3, 4, 5] EMPTY=INCLUDE
  /CATEGORIES VARIABLES=Discipline [2, 3, 4, 5, 6, 7, 8] EMPTY=INCLUDE
  /CATEGORIES VARIABLES=CenterType [1.00, 2.00, 4.00] EMPTY=INCLUDE
  /CRITERIA CILEVEL=95
  /SIGTEST TYPE=CHISQUARE ALPHA=0.05 INCLUDEMRSETS=YES CATEGORIES=ALLVISIBLE
  /COMPARETEST TYPE=PROP ALPHA=0.05 ADJUST=BONFERRONI ORIGIN=COLUMN INCLUDEMRSETS=YES 
    CATEGORIES=ALLVISIBLE MERGE=NO SHOWSIG=YES.

* Creation of indexes.
COMPUTE ArticleDepositIndex=P3+P4+P5+P6+P7+P8.
EXECUTE.
COMPUTE DataDepositIndex=P74+P75+P76+P77+P78+P79.
EXECUTE.

COMPUTE HasDepositedArticles = 0.
IF (P3 = 1 OR P4 = 1 OR P5 = 1 OR P6 = 1 OR P7 = 1 OR P8 = 1) HasDepositedArticles = 1.
EXECUTE.

COMPUTE HasDepositedData = 0.
IF (P74 = 1 OR P75 = 1 OR P76 = 1 OR P77 = 1 OR P78 = 1 OR P79 = 1) HasDepositedData = 1.
EXECUTE.

** Linear regressions with indexes.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT ArticleDepositIndex
  /METHOD=ENTER KnowsOA Gender_3 Discipline_1 Discipline_2 Discipline_4 Discipline_5 Discipline_6 
    Discipline_7 Discipline_8 CenterType_1 AgeGroup_2 AgeGroup_3 AgeGroup_4.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT DataDepositIndex
  /METHOD=ENTER KnowsOA Gender_3 Discipline_1 Discipline_2 Discipline_4 Discipline_5 Discipline_6 
    Discipline_7 Discipline_8 CenterType_1 AgeGroup_2 AgeGroup_3 AgeGroup_4.

** Logistic regressions with HasDepositedArticles and HasDepositedData.
LOGISTIC REGRESSION VARIABLES HasDepositedArticles
  /METHOD=ENTER KnowsOA Gender_3 Discipline_1 Discipline_2 Discipline_4 Discipline_5 Discipline_6 
    Discipline_7 Discipline_8 CenterType_1 
  /PRINT=GOODFIT CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

LOGISTIC REGRESSION VARIABLES HasDepositedData
  /METHOD=ENTER KnowsOA Gender_3 Discipline_1 Discipline_2 Discipline_4 Discipline_5 Discipline_6 
    Discipline_7 Discipline_8 CenterType_1 
  /PRINT=GOODFIT CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

* Logistic regressions including age groups.
LOGISTIC REGRESSION VARIABLES HasDepositedArticles
  /METHOD=ENTER KnowsOA Gender_3 Discipline_1 Discipline_2 Discipline_4 Discipline_5 Discipline_6 
    Discipline_7 Discipline_8 CenterType_1 AgeGroup_2 AgeGroup_3 AgeGroup_4
  /PRINT=GOODFIT CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

LOGISTIC REGRESSION VARIABLES HasDepositedData
  /METHOD=ENTER KnowsOA Gender_3 Discipline_1 Discipline_2 Discipline_4 Discipline_5 Discipline_6 
    Discipline_7 Discipline_8 CenterType_1 AgeGroup_2 AgeGroup_3 AgeGroup_4
  /PRINT=GOODFIT CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

