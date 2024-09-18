Sets
       i   loads         / 1*6  /
       t   period        / 1*12 /
;

** Node demand in m^3/h
Table Pd(i,t) "Power demand (kW)"
       1      2       3     4      5      6      7      8      9      10     11     12    
   1  6.5    3.3    4.2    4.8    18.6   21.5   15.2   12.5   28.6   49.7   13.5   14.6  
   2  3.5    2.8    1.5    2.8    22.9   25.6   14.9   12.6   25.2   39.8   12.1   11.9 
   3  2.5    3.5    3.7    3.8    20.5   22.8   12.8   10.7   32.8   50.6   9.5    11.6  
   4  2.5    3.4    3.6    8.8    19.7   23.9   9.7    4.6    30.8   59.8   6.7    8.5  
   5  9.5    7.1    6.9    4.8    20.6   21.5   5.1    5.9    25.9   58.4   8.3    7.9
   6  8.7    3.5    2.5    11     30.9   36.3   34.3   28.9   39.5   98.5   27.9   31.1
;
Table DeltaP(i,t) "Demand Flexibility (%)"
       1     2     3     4     5     6     7     8     9     10    11    12    
   1  0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   
   2  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  
   3  0.06  0.06  0.06  0.06  0.06  0.06  0.06  0.06  0.06  0.06  0.06  0.06  
   4  0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1   0.1
   5  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05  0.05
   6  0.2   0.2   0.2   0.2   0.2   0.2   0.2   0.2   0.2   0.2   0.2   0.2   
;


Table PVL2(i,t) "PV Generation (kW)"
       1     2     3     4     5     6     7     8     9     10    11    12    
   1   0     4     25    30    70    10    15    6     0     0     6     0  
;

Table PVL1(i,t) "PV Generation (kW)"
       1     2     3     4     5     6     7     8     9     10    11    12    
   1   0     0     3     10    5     30    15    0     6     0     0     0  
;

Table PVL6(i,t) "PV Generation (kW)"
       1     2     3     4     5     6     7     8     9     10    11    12    
   1   0     2     2     10    25    20    0     0     3     0     0     0   
;


Scalar
         Pmax_rede "kW"            / 300  /
         E_Stor    "kWh"           /  60  /
         E_Ini_L4  "kWh"           /  30   /
         E_Ini_L6  "kWh"           /  0   /
         P_ch_max  "kW"            /  30  /
         P_dch_max "kW"            /  30  /
         eff       "%"             / 0.98 /
;

** cost in ? KWH per hour
Parameter
 cost(t)
/ 1 0.2, 2 0.24, 3 0.22, 4 0.17, 5 0.26, 6 0.2, 7 0.19, 8 0.2,
  9 0.22, 10 0.15, 11 0.16, 12 0.14 /
 
Pmax(i) maximum capacity for each load at each house
     / 1   50
       2   50
       3   50
       4   60
       5   60
       6   100/;



* STEP 1
* Variables declaration (Variables; Positive variables; Binary variables)

Variables
z total costs during the day
Pf(i,t) total power taking in consideration the DeltaP 
Flex(i,t) DeltaP*PD
Costs(i,t) costs of each house in each hour
;

Positive Variable
Prede(i,t) power consumed from the Energy Grid
Pcommunity(i,t) power that can be bought from the community
** PV variables
PVL1_used(t) power supplied from house L1 PV to itself
PVL2_used(t) power supplied from house L2 PV to itself
PVL6_used(t) power supplied from house L6 PV to itself
PVL1_community(t) power supplied from house L1 PV to community
PVL2_community(t) power supplied from house L2 PV to community
PVL6_community(t) power supplied from house L6 PV to community
PVL1_rede(t) power supplied from house L1 PV to energy grid
PVL2_rede(t) power supplied from house L2 PV to energy grid
PVL6_rede(t) power supplied from house L6 PV to energy grid

** Energy variables
EnergyL4(t) energy currently stored on the battery from house L4
PL4_rede_charge(t) power charging the L4 Energy storage from the Energy Grid
PL4_community_charge(t) power charging the L4 Energy storage from the Community
PL4_sto_discharge(t) power discharging the L4 Energy storage to the house L4
PL4_rede_discharge(t) power discharging the L4 Energy storage to the Energy Grid
PL4_community_discharge(t) power discharging the L4 Energy storage to the Community

EnergyL6(t) energy currently stored on the battery from house L6
PL6_sto_charge(t) power charging the L6 house from its own PV
PL6_rede_charge(t) power charging the L6 Energy storage from the Energy Grid
PL6_community_charge(t) power charging the L6 Energy storage from the Community
PL6_sto_discharge(t) power discharging the L6 Energy storage to the house L4
PL6_rede_discharge(t) power discharging the L6 Energy storage to the Energy Grid
PL6_community_discharge(t) power discharging the L6 Energy storage to the Community

** Community variables
PcommunityL1(t) power that L1 can buy from the community
PcommunityL2(t) power that L1 can buy from the community
PcommunityL3(t) power that L1 can buy from the community
PcommunityL4(t) power that L1 can buy from the community
PcommunityL5(t) power that L1 can buy from the community
PcommunityL6(t) power that L1 can buy from the community
;

Binary Variable
XL4(t) only lets either charge or the discharge to be activated on house 4
XL6(t) only lets either charge or the discharge to be activated on house 6
D(i,t) only lets Flex by either zero or max
;


* STEP 2
* Equations declaration

Equations
** Pf calculations
PMaxAux(i,t) maximum capacity for each load in each house at each time
Flexeq(i,t) defines the real power demand taking account the demand flexibility
Flexeq2(i,t) defines the demand flexibility lower bound for continuos variables
Flexeq3(i,t) defines the demand flexibility higher bound for continuos variables
Flexeq4(i,t) defines the demand flexibility higher bound for discontinuos variables
MaxConsumption defines that the total power consumption must be the same when the demand flexibility is used
PfL1(i,t) defines the loads for house 1
PfL2(i,t) defines the loads for house 2
PfL3(i,t) defines the loads for house 3
PfL4(i,t) defines the loads for house 4
PfL5(i,t) defines the loads for house 5
PfL6(i,t) defines the loads for house 6

** PV calculations
PVL1Eq(t) calculates the PV from house L1 distribution
PVL2Eq(t) calculates the PV from house L2 distribution
PVL6Eq(t) calculates the PV from house L6 distribution 

** Energy Storage calculations
PchargeL4(t) set the maximum power L6 is charged in each hour
PdischargeL4(t) set the maximum power L6 is discharged in each hour
EnergyL4Eq(t) equations for energy storage distribution in house L4
EnergyL4Eq2(t) equations for energy storage distribution in house L4
EnergyL4Eq3(t) equations for energy storage distribution in house L4
PchargeL6(t) set the maximum power L6 is charged in each hour
PdischargeL6(t) set the maximum power L6 is discharged in each hour
EnergyL6Eq(t) equations for energy storage distribution in house L6
EnergyL6Eq2(t) equations for energy storage distribution in house L6
EnergyL6Eq3(t) equations for energy storage distribution in house L6

** Energy Grid calculations
Prede_Max_Supply(t) Max power provided by the Energy Grid in each hour

** Community calculations
*Final_Community_Power(t) the final value for the community power should be zero
PcommunityL1Eq(i,t)  defines the community power distribution for house 1
PcommunityL2Eq(i,t)  defines the community power distribution for house 2
PcommunityL3Eq(i,t)  defines the community power distribution for house 3
PcommunityL4Eq(i,t)  defines the community power distribution for house 4
PcommunityL5Eq(i,t)  defines the community power distribution for house 5
PcommunityL6Eq(i,t)  defines the community power distribution for house 6
$ontext
** Costs calculation
CostL1(i,t) costs of house L1 in each hour
CostL2(i,t) costs of house L1 in each hour
CostL3(i,t) costs of house L1 in each hour
CostL4(i,t) costs of house L1 in each hour
CostL5(i,t) costs of house L1 in each hour
CostL6(i,t) costs of house L1 in each hour
$offtext
** Objective Function
obj define objective function
;



* STEP 3
* "Model" definition

**** Pf calculations
Flexeq(i,t)..                                      Pf(i,t)=e=Pd(i,t)+Flex(i,t);
Flexeq2(i,t)$((2 <=ord(i)) and (ord(i)<=4))..      Flex(i,t)=l=Pd(i,t)*DeltaP(i,t);
Flexeq3(i,t)$((2 <=ord(i)) and (ord(i)<=4))..      Flex(i,t)=g=-Pd(i,t)*DeltaP(i,t);
Flexeq4(i,t)$(ord(i)=1 or ord(i)=5 or ord(i)=6)..  Flex(i,t) =e= -Pd(i,t)*DeltaP(i,t)*D(i,t);
MaxConsumption..                                   sum((i,t), Pf(i,t)) =e= sum((i,t), Pd(i,t));

PfL1('1',t)..  Pf('1',t) =e= Prede('1',t) + PcommunityL1(t) + PVL1_used(t);
PfL2('2',t)..  Pf('2',t) =e= Prede('2',t) + PcommunityL2(t) + PVL2_used(t);
PfL3('3',t)..  Pf('3',t) =e= Prede('3',t) + PcommunityL3(t);
PfL4('4',t)..  Pf('4',t) =e= Prede('4',t) + PcommunityL4(t) + PL4_sto_discharge(t);
PfL5('5',t)..  Pf('5',t) =e= Prede('5',t) + PcommunityL5(t);
PfL6('5',t)..  Pf('6',t) =e= Prede('6',t) + PcommunityL6(t) + PL6_sto_discharge(t) + PVL6_used(t);

PMaxAux(i,t)..    Pf(i,t) =l= Pmax(i);

**** PV calculations
PVL1Eq(t)..  sum(i, PVL1(i,t)) =e= PVL1_used(t) + PVL1_community(t) + PVL1_rede(t);
PVL2Eq(t)..  sum(i, PVL2(i,t)) =e= PVL2_used(t) + PVL2_community(t) + PVL2_rede(t);
PVL6Eq(t)..  sum(i, PVL6(i,t)) =e= PVL6_used(t) + PVL6_community(t) + PVL6_rede(t) + PL6_sto_charge(t);

**** Energy Storage calculations
** L4
PchargeL4(t)..               PL4_rede_charge(t) + PL4_community_charge(t) =l= P_ch_max*XL4(t);
PdischargeL4(t)..            PL4_sto_discharge(t) + PL4_rede_discharge(t) + PL4_community_discharge(t) =l= (1 - XL4(t))*P_dch_max;
EnergyL4Eq(t)..              EnergyL4(t) =l= E_Stor;
EnergyL4Eq2(t)$(ord(t)=1)..  EnergyL4(t) =e= E_Ini_L4 + (PL4_rede_charge(t) + PL4_community_charge(t))*eff - (PL4_sto_discharge(t) + PL4_rede_discharge(t) + PL4_community_discharge(t))/eff;
EnergyL4Eq3(t)$(ord(t)>1)..  EnergyL4(t) =e= EnergyL4(t-1) + (PL4_rede_charge(t) + PL4_community_charge(t))*eff - (PL4_sto_discharge(t) + PL4_rede_discharge(t) + PL4_community_discharge(t))/eff;
** L6
PchargeL6(t)..               PL6_rede_charge(t) + PL6_community_charge(t) + PL6_sto_charge(t) =l= P_ch_max*XL6(t);
PdischargeL6(t)..            PL6_sto_discharge(t) + PL6_rede_discharge(t) + PL6_community_discharge(t) =l= (1 - XL6(t))*P_dch_max;
EnergyL6Eq(t)..              EnergyL6(t) =l= E_Stor;
EnergyL6Eq2(t)$(ord(t)=1)..  EnergyL6(t) =e= E_Ini_L6 + (PL6_rede_charge(t) + PL6_community_charge(t) + PL6_sto_charge(t))*eff - (PL6_sto_discharge(t) + PL6_rede_discharge(t) + PL6_community_discharge(t))/eff;
EnergyL6Eq3(t)$(ord(t)>1)..  EnergyL6(t) =e= EnergyL6(t-1) + (PL6_rede_charge(t) + PL6_community_charge(t) + PL6_sto_charge(t))*eff - (PL6_sto_discharge(t) + PL6_rede_discharge(t) + PL6_community_discharge(t))/eff;

**** Energy Grid calculations
Prede_Max_Supply(t)..  sum(i, Prede(i,t)) =l= Pmax_rede;

**** Community calculations
*Final_Community_Power(t)$(ord(t)=12)..  sum(i, Pcommunity(i,t)) =e= 0;
PcommunityL1Eq(i,t)..  Pcommunity('1',t) =e= PVL1_community(t) - PcommunityL1(t);
PcommunityL2Eq(i,t)..  Pcommunity('2',t) =e= PVL2_community(t) - PcommunityL2(t);
PcommunityL3Eq(i,t)..  Pcommunity('3',t) =e= - PcommunityL3(t);
PcommunityL4Eq(i,t)..  Pcommunity('4',t) =e= PL4_community_discharge(t) - PcommunityL4(t) - PL4_community_charge(t);
PcommunityL5Eq(i,t)..  Pcommunity('5',t) =e= - PcommunityL5(t);
PcommunityL6Eq(i,t)..  Pcommunity('6',t) =e= PVL6_community(t) + PL6_community_discharge(t) - PcommunityL6(t) - PL6_community_charge(t);
$ontext
**** Costs calculation
CostL1(i,t)..  Costs('1',t) =e= (Prede('1',t) + PcommunityL1(t))*cost(t) - (PVL1_community(t) + PVL1_rede(t))*cost(t);
CostL2(i,t)..  Costs('2',t) =e= (Prede('2',t) + PcommunityL2(t))*cost(t) - (PVL2_community(t) + PVL2_rede(t))*cost(t);
CostL3(i,t)..  Costs('3',t) =e= (Prede('3',t) + PcommunityL3(t))*cost(t);
CostL4(i,t)..  Costs('4',t) =e= (Prede('4',t) + PcommunityL4(t)+ PL4_rede_charge(t) + PL4_community_charge(t))*cost(t) - (PVL2_community(t) + PVL2_rede(t) + PL4_rede_discharge(t) + PL4_community_discharge(t))*cost(t);
CostL5(i,t)..  Costs('5',t) =e= (Prede('5',t) + PcommunityL5(t))*cost(t);
CostL6(i,t)..  Costs('6',t) =e= (Prede('6',t) + PcommunityL6(t)+ PL6_rede_charge(t) + PL6_community_charge(t))*cost(t) - (PVL6_community(t) + PVL2_rede(t) + PL4_rede_discharge(t) + PL4_community_discharge(t))*cost(t);
$offtext
**** Objective Function
obj..  z =e= sum((i,t), Pcommunity(i,t));



* STEP 5
* "Solve" definition
Model final_project /all/ ;

solve final_project using minlp maximing z  ;



* STEP 6
* "Display" results

display z.l,Pf.l, Prede.l, Pcommunity.l, Costs.l;