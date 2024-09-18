Sets
       i   loads         / 1*5 /
       t   period        / 1*24 / ;

** Node demand in m^3/h
Table Pd(i,t) "Power demand (kW)"
       1      2       3     4      5      6      7      8      9      10     11     12    13    14    15    16    17     18     19     20     21     22     23     24
   1  144.0  145.8  147.6  140.4  133.2  117.0  100.8  91.8   82.8   75.6   69.6   63.6  57.6  55.8  54.0  61.2  68.4   80.4   92.4   104.4  115.2  126.0  136.8  147.6
   2  219.6  223.2  226.8  217.8  208.8  180.0  151.2  136.8  122.4  111.6  104.4  97.2  90.0  84.6  79.2  90.0  100.8  118.8  136.8  154.8  174.6  194.4  214.2  234.0
   3  219.6  223.2  226.8  217.8  208.8  180.0  151.2  136.8  122.4  111.6  104.4  97.2  90.0  84.6  79.2  90.0  100.8  118.8  136.8  154.8  174.6  194.4  214.2  234.0
   4  194.4  198.0  201.6  190.8  180.0  158.4  136.8  122.4  108.0  100.8  93.6   86.4  79.2  75.6  72.0  81.0  90.0   106.8  123.6  140.4  154.8  169.2  183.6  198.0
   5  64.8   64.8   64.8   61.2   57.6   50.4   43.2   37.8   32.4   28.8   27.6   26.4  25.2  25.2  25.2  27.0  28.8   32.4   36.0   39.6   47.7   55.8   63.9   72.0

Table DeltaP(i,t) "Demand Flexibility (%)"
       1     2     3     4     5     6     7     8     9     10    11    12    13    14    15    16    17    18    19    20    21    22    23    24
   1  0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.05  0.1   0.1   0.1   0.1   0.1
   2  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05
   3  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25  0     0     0     0     0     0     0     0
   4  0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0     0.25  0.25  0.25  0.25  0.25  0.25  0.25  0.25
   5  0.2   0.2   0.2   0.2   0.2   0.2   0.2   0.1   0.1   0.2   0.2   0.2   0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.1   0.1   0.1   0.1
;


Scalar
         Pmax    "kW"            / 850 /
;

** cost in ? KWH per hour
Parameter
 cost(t)
/ 1 0.016, 2 0.016, 3 0.018, 4 0.018, 5 0.021, 6 0.021, 7 0.022, 8 0.022,
  9 0.023, 10 0.023, 11 0.024, 12 0.024, 13 0.025, 14 0.025, 15 0.029, 16 0.029,
 17 0.031, 18 0.031, 19 0.035, 20 0.035, 21 0.0325, 22 0.0325, 23 0.03, 24 0.03/;


* STEP 1
* Variables declaration (Variables; Positive variables; Binary variables)
Variables
**** Error calculations
error(i,t) difference between Pf and Pd

**** General
z total costs during the day
Pf(i,t) total power taking in consideration the DeltaP 
Flex(i,t) DeltaP*PD
Conso(t) stores the value of the total power of the 5 loads at each hour
Diff calculates the difference betwwen the initial power and inicial
**** 3)
CostAux cost for service participation
;

Negative Variables
**** 3)
Pshading(i,t) power to counter infisability when the Pmax can't be as low as the constraint ;

**** 2)
Binary Variable
X(i,t) Binary variable to pull down;


**** Change variables foward to change between problems

* STEP 2
* Equations description
Equations
**** General
costs define objective function
ConsoAux(t) Consumption max Pf of hours
Flexeq(i,t) defines the real power demand taking account the demand flexibility
Flexeq4 defines that the total power consumption must be the same when the demand flexibility is used
Flexeq2(i,t) defines the demand flexibility lower bound
Flexeq3(i,t) defines the demand flexibility higher bound
**** 1) and 2)
*ConsoMax(t) Consumption max
**** 2)
*Flexeq5(i,t) defines the usage of the binary variables on the respective loads
**** 3)
Cost2 cost for service participation
ConsoMax2(t) defines the max consumption taking in account the new limit for Pmax
ConsoMax3(t) defines the max consumption taking in account the new limit for Pmax

**** Error calculations
*erroreq(i,t) difference between Pf and Pd
;

* STEP 3
* "Model" definition


****** CONSTRAINTS
**** General
*costs..         z =e= sum((i,t), Pf(i,t)*cost(t)) ;
Flexeq(i,t)..   Pf(i,t)=e=Pd(i,t)+Flex(i,t);
Flexeq4..       sum((i,t), Pf(i,t)) =e= sum((i,t), Pd(i,t));

**** 1)
*ConsoMax(t)..   sum(i,  Pf(i,t))=l=Pmax;
Flexeq2(i,t)..  Flex(i,t)=l=Pd(i,t)*DeltaP(i,t);
Flexeq3(i,t)..  Flex(i,t)=g=-Pd(i,t)*DeltaP(i,t);

**** 2)
*ConsoMax(t)..   sum(i,  Pf(i,t))=l=Pmax;
*Flexeq2(i,t)$(ord(i)<=2)..  Flex(i,t)=l=Pd(i,t)*DeltaP(i,t);
*Flexeq5(i,t)$(ord(i)<=2)..  Flex(i,t)=g=-Pd(i,t)*DeltaP(i,t);
*Flexeq3(i,t)$(ord(i)>2)..  Flex(i,t)=e=-Pd(i,t)*DeltaP(i,t)*X(i,t);

**** 3) uses 1) or 2) except their ConsoMax(t)
costs..         z =e= sum((i,t), Pf(i,t)*cost(t)) - sum((i,t), Pshading(i,t)*cost(t)*5);
Cost2..   CostAux =e= -sum((i,t), Pshading(i,t)*cost(t)*5);
ConsoMax2(t)$(ord(t)>18)..   sum(i,  Pshading(i,t)) + sum(i,  Pf(i,t))=l=700;
ConsoMax3(t)$(ord(t)<=18)..  sum(i,  Pf(i,t))=l=850; 


****** PLOT VARIABLES
ConsoAux(t)..   Conso(t) =e= sum(i,  Pf(i,t));
** Error calculations
*erroreq(i,t)..  error(i,t) =e= Flex(i,t)/Pd(i,t);

* STEP 4
* "Solve" definition
Model assingment_IX /all/ ;

**** 1) and 3)
*solve assingment_IX using lp minimizing z ;

**** 2) and 3)
solve assingment_IX using mip minimizing z ;

**** Error calculation
*solve assingment_IX using MINLP minimizing z ;

* STEP 5
* "Display" results
display z.l, Pf.l, Flex.l, Pshading.l, CostAux.l;


* STEP 6
* "Move" results to a excel file

*=== First unload to GDX file (occurs during execution phase)
*execute_unload "results.gdx" Flex.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
*execute 'gdxxrw.exe results.gdx o=results_Flex.xlsx var=Flex.l'



