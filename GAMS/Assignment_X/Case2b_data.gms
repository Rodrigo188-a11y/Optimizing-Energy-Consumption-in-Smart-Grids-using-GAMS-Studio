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
   5  0.2   0.2   0.2   0.2   0.2   0.2   0.2   0.1   0.1   0.2   0.3   0.3   0.3   0.3   0.3   0.3   0.3   0.3   0.3   0.3   0.3   0.3   0.3   0.3
;


Table PV(i,t) "PV Generation (kW)"
       1     2     3     4     5     6     7     8     9     10    11    12    13    14    15    16    17    18    19    20    21    22    23    24
   1   0     0     0     0     0     20    80    300   800   1250  1600  1800  2000  1800  1700  1400  950   500   150   30    0     0     0     0
;


Scalar
         Pmax      "kW"            / 850  /
         E_Stor    "kWh"           / 2000 /
         E_Ini     "kWh"           / 1000 /
         P_ch_max  "kW"            / 1500 /
         P_dch_max "kW"            / 1500 /
         eff       "%"             / 0.98 /
;

** cost in ? KWH per hour
Parameter
 cost(t)
/ 1 0.1, 2 0.1, 3 0.1, 4 0.1, 5 0.1, 6 0.1, 7 0.1, 8 0.2,
  9 0.2, 10 0.2, 11 0.2, 12 0.2, 13 0.2, 14 0.2, 15 0.2, 16 0.2,
 17 0.2, 18 0.2, 19 0.2, 20 0.2, 21 0.2, 22 0.2, 23 0.1, 24 0.1/;
 


* STEP 1
* Variables declaration (Variables; Positive variables; Binary variables)
Variables
**** General
z total costs during the day
Pf(i,t) total power taking in consideration the DeltaP 
Flex(i,t) DeltaP*PD
Pfdisplay(t)
z2 total costs during the day
;

Positive Variable
**** General
PVused(i,t) actual power consumed from the PV panels
PVsold(i,t) cost selling from the PV panels
Prede(t) actual power consumed from the network to make the difference between the PV and the Pf
**** 2)
PVused2(t) actual power consumed from the PV panels
PVsold2(t) cost selling from the PV panels
Pcharge(t) power charging the battery from the PV system
Prede_charge(t) power charging the battery from the Energy Grid
Pdischarge(t) power being decharged from the battery to the house
Pdischarge_sold(t) power being decharged from the battery selled back to Energy Grid
Energy(t) energy currently stored on the battery
;

Binary Variable
**** 2)
X(t) only lets either charge or the discharge to be activated;



* STEP 2
* Equations declaration

**** Uncomment either 1) or 2), or 1) and 3) or 2) and 3)
Equations
**** General
costs define objective function
ConsoMax(t) Consumption max
Flexeq(i,t) defines the real power demand taking account the demand flexibility
Flexeq2(i,t) defines the demand flexibility lower bound
Flexeq3(i,t) defines the demand flexibility higher bound
MaxConsumption defines that the total power consumption must be the same when the demand flexibility is used
PfdisplayEq(t)
Pf2Eq(t) Difference between the power demand consumed by the loads and the power supplied by the PV
* only uncomment on d)
costsAux calculates the cost for d)
**** 1)
*PVauxEq(i,t) actual power consumed from the PV panels
PVcostEq(i,t) cost selling from the PV panels
**** 2)
*PVauxEq2(t) actual power consumed from the PV panels
*PVcostEq2(t) cost selling from the PV panels
*PchargeEq(t) power charging the battery
*PdischargeEq(t) power being decharged from the battery
*EnergyEq(t) max energy stored on the battery
*EnergyEq2(t) initial energy stored on the battery
*EnergyEq3(t) energy currently stored on the battery
**** 3)
*ConsoMax2(t) Consumption max
;



* STEP 3
* "Model" definition

**** General
Flexeq(i,t)..     Pf(i,t)=e=Pd(i,t)+Flex(i,t);
Flexeq2(i,t)..    Flex(i,t)=l=Pd(i,t)*DeltaP(i,t);
Flexeq3(i,t)..    Flex(i,t)=g=-Pd(i,t)*DeltaP(i,t);
MaxConsumption..  sum((i,t), Pf(i,t)) =e= sum((i,t), Pd(i,t));
PfdisplayEq(t)..  Pfdisplay(t) =e= sum(i, Pf(i,t));


**** 1
ConsoMax(t)..     Prede(t)=l=Pmax;
Pf2Eq(t)..        Prede(t) =e= sum(i, Pf(i,t)) - sum(i, PVused(i,t));
*PVauxEq(i,t)..    PVused(i,t) =l= PV(i,t);
PVcostEq(i,t)..   PVsold(i,t) =e= PV(i,t) - PVused(i,t);
** a)
*costs..          z =e= sum(t, Prede(t)*cost(t)) - sum((i,t), PVsold(i,t)*cost(t));
** b)
*costs..          z =e= sum(t, Prede(t)*cost(t));
** c)
*costs..          z =e= sum(t, Prede(t)*cost(t)) - sum((i,t), PVsold(i,t)*cost(t)*1.20);
** d)
costs..          z =e= sum(t, Prede(t)) - sum((i,t), PVused(i,t));
costsAux..       z2 =e= -z;           

**** 2.1 - without Pdischarge selling to Energy Grid from Storage
*ConsoMax(t)..              Prede(t)=l=Pmax;
*PchargeEq(t)..             Pcharge(t) =l= P_ch_max*X(t);
*PdischargeEq(t)..          Pdischarge(t) =l= P_dch_max*(1-X(t));
*EnergyEq(t)..              Energy(t) =l= E_Stor;
*EnergyEq2(t)$(ord(t)=1)..  Energy(t) =e= E_Ini + Pcharge(t)*eff - Pdischarge(t)/eff;
*EnergyEq3(t)$(ord(t)>1)..  Energy(t) =e= Energy(t-1) + Pcharge(t)*eff - Pdischarge(t)/eff;
*PVauxEq2(t)..              PVused2(t) =l= sum(i, PV(i,t))-Pcharge(t);
*PVcostEq2(t)..             PVsold2(t) =e= sum(i, PV(i,t)) - PVused2(t) - Pcharge(t);
*Pf2Eq(t)..                 Prede(t) =e= sum(i, Pf(i,t)) - PVused2(t) - Pdischarge(t);
** a)
*costs..                    z =e= sum(t, Prede(t)*cost(t)) - sum(t, PVsold2(t)*cost(t));
** b)
*costs..         z =e= sum(t, Prede(t)*cost(t));
** c)
*costs..         z =e= sum(t, Prede(t)*cost(t)) - sum(t, PVsold2(t)*cost(t)*1.20);
** d)
*costs..         z =e= sum(t, Prede(t)) - sum(t, PVused2(t)) - sum(t, Pdischarge(t));
*costsAux..       z2 =e= -z

**** 2.2 - with Pdischarge selling to Energy Grid from Storage
*ConsoMax(t)..              (Prede(t)+Prede_charge(t))=l=Pmax;
*PchargeEq(t)..             (Pcharge(t)+Prede_charge(t)) =l= P_ch_max*X(t);
*PdischargeEq(t)..          (Pdischarge(t)+Pdischarge_sold(t)) =l= P_dch_max*(1-X(t));
*EnergyEq(t)..              Energy(t) =l= E_Stor;
*EnergyEq2(t)$(ord(t)=1)..  Energy(t) =e= E_Ini + (Pcharge(t) + Prede_charge(t))*eff - (Pdischarge(t) + Pdischarge_sold(t))/eff;
*EnergyEq3(t)$(ord(t)>1)..  Energy(t) =e= Energy(t-1) + (Pcharge(t) + Prede_charge(t))*eff - (Pdischarge(t) + Pdischarge_sold(t))/eff;
*PVauxEq2(t)..              PVused2(t) =l= sum(i, PV(i,t))-Pcharge(t);
*PVcostEq2(t)..             PVsold2(t) =e= sum(i, PV(i,t)) - PVused2(t) - Pcharge(t);
*Pf2Eq(t)..                 Prede(t) =e= sum(i, Pf(i,t)) - PVused2(t) - Pdischarge(t);
** a)
*costs..  z =e= sum(t, Prede(t)*cost(t)) + sum(t, Prede_charge(t)*cost(t)) - sum(t, PVsold2(t)*cost(t)) - sum(t, Pdischarge_sold(t)*cost(t));
** b)
*costs..         z =e= sum(t, Prede(t)*cost(t))+ sum(t, Prede_charge(t)*cost(t));
** c)
*costs..         z =e= sum(t, Prede(t)*cost(t)) + sum(t, Prede_charge(t)*cost(t)) - sum(t, PVsold2(t)*cost(t)*1.2) - sum(t, Pdischarge_sold(t)*cost(t)*1.2);
** d)
*costs..          z =e= sum(t, Prede(t)) - sum(t, PVused2(t))- sum(t, Pdischarge(t));
*costsAux..       z2 =e= -z;

**** 3 - comment "ConsoMax(t)" and "costs" from previous exercises and uncomment the rest
*ConsoMax(t)$(ord(t)>18)..    (Prede(t)+Prede_charge(t))=l=700;
*ConsoMax2(t)$(ord(t)<=18)..  (Prede(t)+Prede_charge(t))=l=850;



* STEP 5
* "Solve" definition
Model transport /all/ ;

**** 1)
solve transport using lp minimizing z ;

**** 2)
*solve transport using MINLP minimizing z ;



* STEP 6
* "Display" results

**** 1)
display z.l,Pf.l,Pfdisplay.l, Prede.l, PVused.l, PVsold.l;

**** 2)
*display z.l,Pf.l,Pfdisplay.l, Prede.l, PVused2.l, Pcharge.l, Pdischarge.l, PVsold2.l, Prede_charge.l, Pdischarge_sold.l, Energy.l, X.l;


* STEP 6
* "Move" results to a excel file

$onText
*=== First unload to GDX file (occurs during execution phase)
execute_unload "results.gdx" z.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results.gdx o=cost.xlsx var=z.l'

execute_unload "results1.gdx" Pf.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results1.gdx o=Pf.xlsx var=Pf.l'

execute_unload "results2.gdx" Pfdisplay.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results2.gdx o=Pf_each_hour.xlsx var=Pfdisplay.l'

execute_unload "results3.gdx" Prede.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results3.gdx o=Prede.xlsx var=Prede.l'

execute_unload "results4.gdx" PVused2.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results4.gdx o=PVused.xlsx var=PVused2.l'

execute_unload "results5.gdx" PVsold2.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results5.gdx o=PVsold.xlsx var=PVsold2.l'

execute_unload "results6.gdx" Pcharge.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results6.gdx o=Pcharge.xlsx var=Pcharge.l'

execute_unload "results7.gdx" Pdischarge.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results7.gdx o=Pdischarge.xlsx var=Pdischarge.l'

execute_unload "results8.gdx" Energy.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results8.gdx o=Energy.xlsx var=Energy.l'

execute_unload "results9.gdx" Prede_charge.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results9.gdx o=Prede_charge.xlsx var=Prede_charge.l'

execute_unload "results10.gdx" Pdischarge_sold.l

*=== Now write to variable levels to Excel file from GDX 
*=== Since we do not specify a sheet, data is placed in first sheet
execute 'gdxxrw.exe results10.gdx o=Pdischarge_sold.xlsx var=Pdischarge_sold.l'
$offText