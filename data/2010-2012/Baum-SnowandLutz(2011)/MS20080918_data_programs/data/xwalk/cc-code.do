/**
cc-code.do

This program assigns msa and cmsa codes to central
cities based on the 2000 census definitions.
It creates the variables msa and cmsa given placefips
codes.

**/

/*** Recode relevant central cities in place-codes.dta
to match placefips codes in reported census CC data ***/
replace placefips =35000 if placefips==35160 & statefips==12
replace placefips =35000 if placefips==35006 & statefips==12
replace placefips =58715 if placefips==58725 & statefips==12
replace placefips =3440 if placefips==3432 & statefips==13
replace placefips =4204 if placefips==4196 & statefips==13
replace placefips =19007 if placefips==19030 & statefips==13
replace placefips =36003 if placefips==36010 & statefips==18
replace placefips =46027 if placefips==46000 & statefips==21
replace placefips =3600 if placefips==3695 & statefips==25
replace placefips =82525 if placefips==82595 & statefips==25
replace placefips =18130 if statefips==34 & placefips==18070


gen msacmsa = -9

** All but New England

replace msacmsa=1000 if statefips==1 & placefips==7000
replace msacmsa=1010 if statefips==38 & placefips==7200
replace msacmsa=1020 if statefips==18 & placefips==5860
replace msacmsa=1040 if statefips==17 & placefips==53234
replace msacmsa=1040 if statefips==17 & placefips==6613
replace msacmsa=1080 if statefips==16 & placefips==56260
replace msacmsa=1080 if statefips==16 & placefips==8830
replace msacmsa=120 if statefips==13 & placefips==1052
replace msacmsa=1240 if statefips==48 & placefips==10768
replace msacmsa=1240 if statefips==48 & placefips==32372
replace msacmsa=1240 if statefips==48 & placefips==65036
replace msacmsa=1260 if statefips==48 & placefips==10912
replace msacmsa=1260 if statefips==48 & placefips==15976
replace msacmsa=1280 if statefips==36 & placefips==11000
replace msacmsa=1280 if statefips==36 & placefips==51055
replace msacmsa=1320 if statefips==39 & placefips==12000
replace msacmsa=1320 if statefips==39 & placefips==48244
replace msacmsa=1350 if statefips==56 & placefips==13150
replace msacmsa=1360 if statefips==19 & placefips==12000
replace msacmsa=1400 if statefips==17 & placefips==12385
replace msacmsa=1400 if statefips==17 & placefips==77005
replace msacmsa=1440 if statefips==45 & placefips==13330
replace msacmsa=1440 if statefips==45 & placefips==50875
replace msacmsa=1480 if statefips==54 & placefips==14600
replace msacmsa=1520 if statefips==37 & placefips==12000
replace msacmsa=1520 if statefips==37 & placefips==14100
replace msacmsa=1520 if statefips==37 & placefips==25580
replace msacmsa=1520 if statefips==37 & placefips==35200
replace msacmsa=1520 if statefips==45 & placefips==61405
replace msacmsa=1540 if statefips==51 & placefips==14968
replace msacmsa=1560 if statefips==47 & placefips==14000
replace msacmsa=1580 if statefips==56 & placefips==13900
replace msacmsa=160 if statefips==36 & placefips==1000
replace msacmsa=160 if statefips==36 & placefips==65255
replace msacmsa=160 if statefips==36 & placefips==65508
replace msacmsa=160 if statefips==36 & placefips==75484
replace msacmsa=1602 if statefips==17 & placefips==14000
replace msacmsa=1602 if statefips==17 & placefips==19161
replace msacmsa=1602 if statefips==17 & placefips==23074
replace msacmsa=1602 if statefips==17 & placefips==24582
replace msacmsa=1602 if statefips==17 & placefips==3012
replace msacmsa=1602 if statefips==17 & placefips==38570
replace msacmsa=1602 if statefips==17 & placefips==38934
replace msacmsa=1602 if statefips==17 & placefips==53559
replace msacmsa=1602 if statefips==18 & placefips==19486
replace msacmsa=1602 if statefips==18 & placefips==27000
replace msacmsa=1602 if statefips==55 & placefips==39225
replace msacmsa=1620 if statefips==6 & placefips==13014
replace msacmsa=1620 if statefips==6 & placefips==55520
replace msacmsa=1642 if statefips==39 & placefips==15000
replace msacmsa=1642 if statefips==39 & placefips==33012
replace msacmsa=1642 if statefips==39 & placefips==49840
replace msacmsa=1660 if statefips==21 & placefips==37918
replace msacmsa=1660 if statefips==47 & placefips==15160
replace msacmsa=1692 if statefips==39 & placefips==1000
replace msacmsa=1692 if statefips==39 & placefips==16000
replace msacmsa=1692 if statefips==39 & placefips==25256
replace msacmsa=1692 if statefips==39 & placefips==39872
replace msacmsa=1692 if statefips==39 & placefips==44856
replace msacmsa=1720 if statefips==8 & placefips==16000
replace msacmsa=1740 if statefips==29 & placefips==15670
replace msacmsa=1760 if statefips==45 & placefips==16000
replace msacmsa=1800 if statefips==13 & placefips==19007
replace msacmsa=1840 if statefips==39 & placefips==18000
replace msacmsa=1840 if statefips==39 & placefips==41720
replace msacmsa=1840 if statefips==39 & placefips==54040
replace msacmsa=1880 if statefips==48 & placefips==17000
replace msacmsa=1890 if statefips==41 & placefips==15800
replace msacmsa=1900 if statefips==24 & placefips==21325
replace msacmsa=1922 if statefips==48 & placefips==19000
replace msacmsa=1922 if statefips==48 & placefips==19972
replace msacmsa=1922 if statefips==48 & placefips==27000
replace msacmsa=1922 if statefips==48 & placefips==37000
replace msacmsa=1922 if statefips==48 & placefips==4000
replace msacmsa=1950 if statefips==51 & placefips==21344
replace msacmsa=1960 if statefips==17 & placefips==49867
replace msacmsa=1960 if statefips==17 & placefips==65078
replace msacmsa=1960 if statefips==19 & placefips==19000
replace msacmsa=200 if statefips==35 & placefips==2000
replace msacmsa=2000 if statefips==39 & placefips==21000
replace msacmsa=2000 if statefips==39 & placefips==25914
replace msacmsa=2000 if statefips==39 & placefips==74118
replace msacmsa=2020 if statefips==12 & placefips==16525
replace msacmsa=2030 if statefips==1 & placefips==20104
replace msacmsa=2040 if statefips==17 & placefips==18823
replace msacmsa=2082 if statefips==8 & placefips==20000
replace msacmsa=2082 if statefips==8 & placefips==32155
replace msacmsa=2082 if statefips==8 & placefips==45970
replace msacmsa=2082 if statefips==8 & placefips==7850
replace msacmsa=2120 if statefips==19 & placefips==21000
replace msacmsa=2162 if statefips==26 & placefips==21000
replace msacmsa=2162 if statefips==26 & placefips==22000
replace msacmsa=2162 if statefips==26 & placefips==29000
replace msacmsa=2162 if statefips==26 & placefips==3000
replace msacmsa=2162 if statefips==26 & placefips==65440
replace msacmsa=2162 if statefips==26 & placefips==65820
replace msacmsa=2180 if statefips==1 & placefips==21184
replace msacmsa=2190 if statefips==10 & placefips==21200
replace msacmsa=220 if statefips==22 & placefips==975
replace msacmsa=2200 if statefips==19 & placefips==22395
replace msacmsa=2240 if statefips==27 & placefips==17000
replace msacmsa=2240 if statefips==55 & placefips==78650
replace msacmsa=2290 if statefips==55 & placefips==22300
replace msacmsa=2320 if statefips==48 & placefips==24000
replace msacmsa=2330 if statefips==18 & placefips==20728
replace msacmsa=2330 if statefips==18 & placefips==28386
replace msacmsa=2335 if statefips==36 & placefips==24229
replace msacmsa=2340 if statefips==40 & placefips==23950
replace msacmsa=2360 if statefips==42 & placefips==24000
replace msacmsa=240 if statefips==42 & placefips==2000
replace msacmsa=240 if statefips==42 & placefips==6088
replace msacmsa=2400 if statefips==41 & placefips==23850
replace msacmsa=2400 if statefips==41 & placefips==69600
replace msacmsa=2440 if statefips==18 & placefips==22000
replace msacmsa=2440 if statefips==21 & placefips==35866
replace msacmsa=2520 if statefips==27 & placefips==43864
replace msacmsa=2520 if statefips==38 & placefips==25700
replace msacmsa=2560 if statefips==37 & placefips==22920
replace msacmsa=2580 if statefips==5 & placefips==23290
replace msacmsa=2580 if statefips==5 & placefips==60410
replace msacmsa=2580 if statefips==5 & placefips==66080
replace msacmsa=2620 if statefips==4 & placefips==23620
replace msacmsa=2650 if statefips==1 & placefips==26896
replace msacmsa=2655 if statefips==45 & placefips==25810
replace msacmsa=2670 if statefips==8 & placefips==27425
replace msacmsa=2670 if statefips==8 & placefips==46465
replace msacmsa=2700 if statefips==12 & placefips==10275
replace msacmsa=2700 if statefips==12 & placefips==24125
replace msacmsa=2710 if statefips==12 & placefips==24300
replace msacmsa=2710 if statefips==12 & placefips==58715
replace msacmsa=2720 if statefips==5 & placefips==24550
replace msacmsa=2750 if statefips==12 & placefips==24475
replace msacmsa=2760 if statefips==18 & placefips==25000
replace msacmsa=280 if statefips==42 & placefips==2184
replace msacmsa=2840 if statefips==6 & placefips==27000
replace msacmsa=2840 if statefips==6 & placefips==45022
replace msacmsa=2880 if statefips==1 & placefips==28696
replace msacmsa=2900 if statefips==12 & placefips==25175
replace msacmsa=2975 if statefips==36 & placefips==29333
replace msacmsa=2980 if statefips==37 & placefips==26880
replace msacmsa=2985 if statefips==38 & placefips==32060
replace msacmsa=2995 if statefips==8 & placefips==31660
replace msacmsa=3000 if statefips==26 & placefips==34000
replace msacmsa=3000 if statefips==26 & placefips==38640
replace msacmsa=3000 if statefips==26 & placefips==56320
replace msacmsa=3040 if statefips==30 & placefips==32800
replace msacmsa=3080 if statefips==55 & placefips==31000
replace msacmsa=3120 if statefips==37 & placefips==28000
replace msacmsa=3120 if statefips==37 & placefips==31400
replace msacmsa=3120 if statefips==37 & placefips==75000
replace msacmsa=3120 if statefips==37 & placefips==9060
replace msacmsa=3150 if statefips==37 & placefips==28080
replace msacmsa=3160 if statefips==45 & placefips==1360
replace msacmsa=3160 if statefips==45 & placefips==30850
replace msacmsa=3160 if statefips==45 & placefips==68290
replace msacmsa=320 if statefips==48 & placefips==3000
replace msacmsa=3240 if statefips==42 & placefips==11272
replace msacmsa=3240 if statefips==42 & placefips==32800
replace msacmsa=3240 if statefips==42 & placefips==42168
replace msacmsa=3285 if statefips==28 & placefips==31020
replace msacmsa=3290 if statefips==37 & placefips==31060
replace msacmsa=3290 if statefips==37 & placefips==37760
replace msacmsa=3290 if statefips==37 & placefips==44400
replace msacmsa=3320 if statefips==15 & placefips==17000
replace msacmsa=3350 if statefips==22 & placefips==36255
replace msacmsa=3362 if statefips==48 & placefips==16432
replace msacmsa=3362 if statefips==48 & placefips==28068
replace msacmsa=3362 if statefips==48 & placefips==35000
replace msacmsa=3362 if statefips==48 & placefips==6128
replace msacmsa=3362 if statefips==48 & placefips==72392
replace msacmsa=3400 if statefips==21 & placefips==2368
replace msacmsa=3400 if statefips==54 & placefips==39460
replace msacmsa=3440 if statefips==1 & placefips==37000
replace msacmsa=3480 if statefips==18 & placefips==1468
replace msacmsa=3480 if statefips==18 & placefips==36003
replace msacmsa=3500 if statefips==19 & placefips==38595
replace msacmsa=3520 if statefips==26 & placefips==41420
replace msacmsa=3560 if statefips==28 & placefips==36000
replace msacmsa=3580 if statefips==47 & placefips==37640
replace msacmsa=3600 if statefips==12 & placefips==35000
replace msacmsa=3605 if statefips==37 & placefips==34200
replace msacmsa=3610 if statefips==36 & placefips==38264
replace msacmsa=3620 if statefips==55 & placefips==37825
replace msacmsa=3620 if statefips==55 & placefips==6500
replace msacmsa=3660 if statefips==47 & placefips==38320
replace msacmsa=3660 if statefips==47 & placefips==39560
replace msacmsa=3660 if statefips==47 & placefips==8540
replace msacmsa=3660 if statefips==51 & placefips==9816
replace msacmsa=3680 if statefips==42 & placefips==38288
replace msacmsa=3700 if statefips==5 & placefips==35710
replace msacmsa=3710 if statefips==29 & placefips==37592
replace msacmsa=3720 if statefips==26 & placefips==42160
replace msacmsa=3720 if statefips==26 & placefips==5920
replace msacmsa=3760 if statefips==20 & placefips==36000
replace msacmsa=3760 if statefips==20 & placefips==39000
replace msacmsa=3760 if statefips==20 & placefips==52575
replace msacmsa=3760 if statefips==29 & placefips==38000
replace msacmsa=380 if statefips==2 & placefips==3000
replace msacmsa=3810 if statefips==48 & placefips==39148
replace msacmsa=3810 if statefips==48 & placefips==72176
replace msacmsa=3840 if statefips==47 & placefips==40000
replace msacmsa=3840 if statefips==47 & placefips==55120
replace msacmsa=3850 if statefips==18 & placefips==40392
replace msacmsa=3870 if statefips==55 & placefips==40775
replace msacmsa=3880 if statefips==22 & placefips==40735
replace msacmsa=3920 if statefips==18 & placefips==40788
replace msacmsa=3960 if statefips==22 & placefips==41155
replace msacmsa=3980 if statefips==12 & placefips==38250
replace msacmsa=3980 if statefips==12 & placefips==78275
replace msacmsa=40 if statefips==48 & placefips==1000
replace msacmsa=4000 if statefips==42 & placefips==41216
replace msacmsa=4040 if statefips==26 & placefips==24120
replace msacmsa=4040 if statefips==26 & placefips==46000
replace msacmsa=4080 if statefips==48 & placefips==41464
replace msacmsa=4100 if statefips==35 & placefips==39380
replace msacmsa=4120 if statefips==32 & placefips==40000
replace msacmsa=4150 if statefips==20 & placefips==38900
replace msacmsa=4200 if statefips==40 & placefips==41850
replace msacmsa=4280 if statefips==21 & placefips==46027
replace msacmsa=4320 if statefips==39 & placefips==43554
replace msacmsa=4360 if statefips==31 & placefips==28000
replace msacmsa=4400 if statefips==5 & placefips==15190
replace msacmsa=4400 if statefips==5 & placefips==34750
replace msacmsa=4400 if statefips==5 & placefips==41000
replace msacmsa=4400 if statefips==5 & placefips==50450
replace msacmsa=4420 if statefips==48 & placefips==43888
replace msacmsa=4420 if statefips==48 & placefips==46776
replace msacmsa=4472 if statefips==6 & placefips==2000
replace msacmsa=4472 if statefips==6 & placefips==33182
replace msacmsa=4472 if statefips==6 & placefips==36770
replace msacmsa=4472 if statefips==6 & placefips==40130
replace msacmsa=4472 if statefips==6 & placefips==43000
replace msacmsa=4472 if statefips==6 & placefips==44000
replace msacmsa=4472 if statefips==6 & placefips==55184
replace msacmsa=4472 if statefips==6 & placefips==55254
replace msacmsa=4472 if statefips==6 & placefips==56000
replace msacmsa=4472 if statefips==6 & placefips==62000
replace msacmsa=4472 if statefips==6 & placefips==65000
replace msacmsa=4472 if statefips==6 & placefips==65042
replace msacmsa=4472 if statefips==6 & placefips==69000
replace msacmsa=4472 if statefips==6 & placefips==78120
replace msacmsa=450 if statefips==1 & placefips==1852
replace msacmsa=4520 if statefips==18 & placefips==52326
replace msacmsa=4520 if statefips==21 & placefips==48000
replace msacmsa=460 if statefips==55 & placefips==2375
replace msacmsa=460 if statefips==55 & placefips==55750
replace msacmsa=460 if statefips==55 & placefips==60500
replace msacmsa=4600 if statefips==48 & placefips==45000
replace msacmsa=4640 if statefips==51 & placefips==47672
replace msacmsa=4680 if statefips==13 & placefips==49000
replace msacmsa=4720 if statefips==55 & placefips==48000
replace msacmsa=480 if statefips==37 & placefips==2140
replace msacmsa=4800 if statefips==39 & placefips==47138
replace msacmsa=4840 if statefips==72 & placefips==52431
replace msacmsa=4880 if statefips==48 & placefips==22660
replace msacmsa=4880 if statefips==48 & placefips==45384
replace msacmsa=4880 if statefips==48 & placefips==48768
replace msacmsa=4890 if statefips==41 & placefips==3050
replace msacmsa=4890 if statefips==41 & placefips==47000
replace msacmsa=4900 if statefips==12 & placefips==43975
replace msacmsa=4900 if statefips==12 & placefips==54000
replace msacmsa=4900 if statefips==12 & placefips==71900
replace msacmsa=4920 if statefips==47 & placefips==48000
replace msacmsa=4920 if statefips==5 & placefips==74540
replace msacmsa=4940 if statefips==6 & placefips==46898
replace msacmsa=4992 if statefips==12 & placefips==24000
replace msacmsa=4992 if statefips==12 & placefips==45000
replace msacmsa=4992 if statefips==12 & placefips==45025
replace msacmsa=500 if statefips==13 & placefips==3440
replace msacmsa=5082 if statefips==55 & placefips==53000
replace msacmsa=5082 if statefips==55 & placefips==66000
replace msacmsa=5082 if statefips==55 & placefips==84250
replace msacmsa=5120 if statefips==27 & placefips==43000
replace msacmsa=5120 if statefips==27 & placefips==58000
replace msacmsa=5140 if statefips==30 & placefips==50200
replace msacmsa=5160 if statefips==1 & placefips==50000
replace msacmsa=5170 if statefips==6 & placefips==48354
replace msacmsa=5170 if statefips==6 & placefips==80812
replace msacmsa=520 if statefips==13 & placefips==4000
replace msacmsa=5200 if statefips==22 & placefips==51410
replace msacmsa=5240 if statefips==1 & placefips==51000
replace msacmsa=5280 if statefips==18 & placefips==51876
replace msacmsa=5330 if statefips==45 & placefips==49075
replace msacmsa=5345 if statefips==12 & placefips==47625
replace msacmsa=5360 if statefips==47 & placefips==51560
replace msacmsa=5360 if statefips==47 & placefips==52006
replace msacmsa=5560 if statefips==22 & placefips==55000
replace msacmsa=5560 if statefips==22 & placefips==70805
replace msacmsa=5602 if statefips==34 & placefips==18130
replace msacmsa=5602 if statefips==34 & placefips==3580
replace msacmsa=5602 if statefips==34 & placefips==36000
replace msacmsa=5602 if statefips==34 & placefips==51000
replace msacmsa=5602 if statefips==34 & placefips==74000
replace msacmsa=5602 if statefips==36 & placefips==50034
replace msacmsa=5602 if statefips==36 & placefips==51000
replace msacmsa=5602 if statefips==36 & placefips==59641
replace msacmsa=5602 if statefips==36 & placefips==81677
replace msacmsa=5720 if statefips==51 & placefips==35000
replace msacmsa=5720 if statefips==51 & placefips==56000
replace msacmsa=5720 if statefips==51 & placefips==57000
replace msacmsa=5720 if statefips==51 & placefips==64000
replace msacmsa=5720 if statefips==51 & placefips==76432
replace msacmsa=5720 if statefips==51 & placefips==82000
replace msacmsa=5790 if statefips==12 & placefips==50750
replace msacmsa=580 if statefips==1 & placefips==3076
replace msacmsa=580 if statefips==1 & placefips==57048
replace msacmsa=5800 if statefips==48 & placefips==48072
replace msacmsa=5800 if statefips==48 & placefips==53388
replace msacmsa=5880 if statefips==40 & placefips==52500
replace msacmsa=5880 if statefips==40 & placefips==55000
replace msacmsa=5880 if statefips==40 & placefips==66800
replace msacmsa=5920 if statefips==19 & placefips==16860
replace msacmsa=5920 if statefips==31 & placefips==37000
replace msacmsa=5960 if statefips==12 & placefips==53000
replace msacmsa=5990 if statefips==21 & placefips==58620
replace msacmsa=60 if statefips==72 & placefips==745
replace msacmsa=600 if statefips==13 & placefips==4204
replace msacmsa=600 if statefips==45 & placefips==550
replace msacmsa=6015 if statefips==12 & placefips==54700
replace msacmsa=6020 if statefips==39 & placefips==47628
replace msacmsa=6020 if statefips==54 & placefips==62140
replace msacmsa=6080 if statefips==12 & placefips==55925
replace msacmsa=6120 if statefips==17 & placefips==58447
replace msacmsa=6120 if statefips==17 & placefips==59000
replace msacmsa=6162 if statefips==10 & placefips==50670
replace msacmsa=6162 if statefips==10 & placefips==77580
replace msacmsa=6162 if statefips==34 & placefips==10000
replace msacmsa=6162 if statefips==34 & placefips==2080
replace msacmsa=6162 if statefips==34 & placefips==46680
replace msacmsa=6162 if statefips==34 & placefips==7600
replace msacmsa=6162 if statefips==34 & placefips==76070
replace msacmsa=6162 if statefips==42 & placefips==60000
replace msacmsa=6200 if statefips==4 & placefips==46000
replace msacmsa=6200 if statefips==4 & placefips==55000
replace msacmsa=6200 if statefips==4 & placefips==65000
replace msacmsa=6200 if statefips==4 & placefips==73000
replace msacmsa=6240 if statefips==5 & placefips==55310
replace msacmsa=6280 if statefips==42 & placefips==61000
replace msacmsa=6340 if statefips==16 & placefips==64090
replace msacmsa=6360 if statefips==72 & placefips==63820
replace msacmsa=640 if statefips==48 & placefips==5000
replace msacmsa=640 if statefips==48 & placefips==65600
replace msacmsa=6442 if statefips==41 & placefips==59000
replace msacmsa=6442 if statefips==41 & placefips==64900
replace msacmsa=6442 if statefips==53 & placefips==74060
replace msacmsa=6520 if statefips==49 & placefips==57300
replace msacmsa=6520 if statefips==49 & placefips==62470
replace msacmsa=6560 if statefips==8 & placefips==62000
replace msacmsa=6580 if statefips==12 & placefips==59200
replace msacmsa=6640 if statefips==37 & placefips==11800
replace msacmsa=6640 if statefips==37 & placefips==19000
replace msacmsa=6640 if statefips==37 & placefips==55000
replace msacmsa=6660 if statefips==46 & placefips==52980
replace msacmsa=6680 if statefips==42 & placefips==63624
replace msacmsa=6690 if statefips==6 & placefips==59920
replace msacmsa=6720 if statefips==32 & placefips==60600
replace msacmsa=6740 if statefips==53 & placefips==35275
replace msacmsa=6740 if statefips==53 & placefips==53545
replace msacmsa=6740 if statefips==53 & placefips==58235
replace msacmsa=6760 if statefips==51 & placefips==61832
replace msacmsa=6760 if statefips==51 & placefips==67000
replace msacmsa=680 if statefips==6 & placefips==3526
replace msacmsa=6800 if statefips==51 & placefips==68000
replace msacmsa=6820 if statefips==27 & placefips==54880
replace msacmsa=6840 if statefips==36 & placefips==63000
replace msacmsa=6880 if statefips==17 & placefips==65000
replace msacmsa=6895 if statefips==37 & placefips==57500
replace msacmsa=6922 if statefips==6 & placefips==18100
replace msacmsa=6922 if statefips==6 & placefips==64000
replace msacmsa=6922 if statefips==6 & placefips==86328
replace msacmsa=6960 if statefips==26 & placefips==53780
replace msacmsa=6960 if statefips==26 & placefips==6020
replace msacmsa=6960 if statefips==26 & placefips==70520
replace msacmsa=6980 if statefips==27 & placefips==56896
replace msacmsa=7000 if statefips==29 & placefips==64550
replace msacmsa=7040 if statefips==17 & placefips==1114
replace msacmsa=7040 if statefips==17 & placefips==22255
replace msacmsa=7040 if statefips==17 & placefips==30926
replace msacmsa=7040 if statefips==17 & placefips==4845
replace msacmsa=7040 if statefips==29 & placefips==64082
replace msacmsa=7040 if statefips==29 & placefips==65000
replace msacmsa=7120 if statefips==6 & placefips==48872
replace msacmsa=7120 if statefips==6 & placefips==64224
replace msacmsa=7160 if statefips==49 & placefips==13850
replace msacmsa=7160 if statefips==49 & placefips==55980
replace msacmsa=7160 if statefips==49 & placefips==67000
replace msacmsa=7200 if statefips==48 & placefips==64472
replace msacmsa=7240 if statefips==48 & placefips==50820
replace msacmsa=7240 if statefips==48 & placefips==65000
replace msacmsa=7320 if statefips==6 & placefips==16378
replace msacmsa=7320 if statefips==6 & placefips==22804
replace msacmsa=7320 if statefips==6 & placefips==66000
replace msacmsa=7362 if statefips==6 & placefips==23182
replace msacmsa=7362 if statefips==6 & placefips==29504
replace msacmsa=7362 if statefips==6 & placefips==50258
replace msacmsa=7362 if statefips==6 & placefips==53000
replace msacmsa=7362 if statefips==6 & placefips==55282
replace msacmsa=7362 if statefips==6 & placefips==562
replace msacmsa=7362 if statefips==6 & placefips==56784
replace msacmsa=7362 if statefips==6 & placefips==6000
replace msacmsa=7362 if statefips==6 & placefips==67000
replace msacmsa=7362 if statefips==6 & placefips==68000
replace msacmsa=7362 if statefips==6 & placefips==69084
replace msacmsa=7362 if statefips==6 & placefips==69112
replace msacmsa=7362 if statefips==6 & placefips==70098
replace msacmsa=7362 if statefips==6 & placefips==77000
replace msacmsa=7362 if statefips==6 & placefips==81666
replace msacmsa=7362 if statefips==6 & placefips==83668
replace msacmsa=7442 if statefips==72 & placefips==10334
replace msacmsa=7442 if statefips==72 & placefips==15494
replace msacmsa=7442 if statefips==72 & placefips==27964
replace msacmsa=7442 if statefips==72 & placefips==3368
replace msacmsa=7442 if statefips==72 & placefips==35532
replace msacmsa=7442 if statefips==72 & placefips==50152
replace msacmsa=7442 if statefips==72 & placefips==6593
replace msacmsa=7442 if statefips==72 & placefips==76770
replace msacmsa=7442 if statefips==72 & placefips==85326
replace msacmsa=7460 if statefips==6 & placefips==22300
replace msacmsa=7460 if statefips==6 & placefips==3064
replace msacmsa=7460 if statefips==6 & placefips==68154
replace msacmsa=7480 if statefips==6 & placefips==42524
replace msacmsa=7480 if statefips==6 & placefips==69070
replace msacmsa=7480 if statefips==6 & placefips==69196
replace msacmsa=7490 if statefips==35 & placefips==70500
replace msacmsa=7510 if statefips==12 & placefips==64175
replace msacmsa=7510 if statefips==12 & placefips==7950
replace msacmsa=7520 if statefips==13 & placefips==69000
replace msacmsa=7560 if statefips==42 & placefips==69000
replace msacmsa=7560 if statefips==42 & placefips==85152
replace msacmsa=760 if statefips==22 & placefips==5000
replace msacmsa=7602 if statefips==53 & placefips==22640
replace msacmsa=7602 if statefips==53 & placefips==51300
replace msacmsa=7602 if statefips==53 & placefips==5210
replace msacmsa=7602 if statefips==53 & placefips==63000
replace msacmsa=7602 if statefips==53 & placefips==70000
replace msacmsa=7602 if statefips==53 & placefips==7695
replace msacmsa=7610 if statefips==42 & placefips==69720
replace msacmsa=7620 if statefips==55 & placefips==72975
replace msacmsa=7640 if statefips==48 & placefips==19900
replace msacmsa=7640 if statefips==48 & placefips==67496
replace msacmsa=7680 if statefips==22 & placefips==70000
replace msacmsa=7680 if statefips==22 & placefips==8920
replace msacmsa=7720 if statefips==19 & placefips==73335
replace msacmsa=7760 if statefips==46 & placefips==59020
replace msacmsa=7800 if statefips==18 & placefips==71000
replace msacmsa=7840 if statefips==53 & placefips==67000
replace msacmsa=7880 if statefips==17 & placefips==72000
replace msacmsa=7920 if statefips==29 & placefips==70000
replace msacmsa=8050 if statefips==42 & placefips==73808
replace msacmsa=8080 if statefips==39 & placefips==74608
replace msacmsa=8080 if statefips==54 & placefips==85156
replace msacmsa=8120 if statefips==6 & placefips==42202
replace msacmsa=8120 if statefips==6 & placefips==75000
replace msacmsa=8140 if statefips==45 & placefips==70405
replace msacmsa=8160 if statefips==36 & placefips==3078
replace msacmsa=8160 if statefips==36 & placefips==73000
replace msacmsa=8240 if statefips==12 & placefips==70600
replace msacmsa=8280 if statefips==12 & placefips==12875
replace msacmsa=8280 if statefips==12 & placefips==63000
replace msacmsa=8280 if statefips==12 & placefips==71000
replace msacmsa=8320 if statefips==18 & placefips==75428
replace msacmsa=8360 if statefips==48 & placefips==72368
replace msacmsa=8360 if statefips==5 & placefips==68810
replace msacmsa=840 if statefips==48 & placefips==58820
replace msacmsa=840 if statefips==48 & placefips==7000
replace msacmsa=8400 if statefips==39 & placefips==77000
replace msacmsa=8400 if statefips==39 & placefips==7972
replace msacmsa=8440 if statefips==20 & placefips==71000
replace msacmsa=8520 if statefips==4 & placefips==77000
replace msacmsa=8560 if statefips==40 & placefips==75000
replace msacmsa=860 if statefips==53 & placefips==5280
replace msacmsa=8600 if statefips==1 & placefips==77256
replace msacmsa=8640 if statefips==48 & placefips==74144
replace msacmsa=8680 if statefips==36 & placefips==63418
replace msacmsa=8680 if statefips==36 & placefips==76540
replace msacmsa=870 if statefips==26 & placefips==7520
replace msacmsa=8750 if statefips==48 & placefips==75428
replace msacmsa=8780 if statefips==6 & placefips==58240
replace msacmsa=8780 if statefips==6 & placefips==80644
replace msacmsa=8780 if statefips==6 & placefips==82954
replace msacmsa=880 if statefips==30 & placefips==6550
replace msacmsa=8800 if statefips==48 & placefips==76000
replace msacmsa=8872 if statefips==11 & placefips==50000
replace msacmsa=8872 if statefips==24 & placefips==1600
replace msacmsa=8872 if statefips==24 & placefips==30325
replace msacmsa=8872 if statefips==24 & placefips==36075
replace msacmsa=8872 if statefips==24 & placefips==4000
replace msacmsa=8872 if statefips==51 & placefips==29744
replace msacmsa=8872 if statefips==51 & placefips==3000
replace msacmsa=8920 if statefips==19 & placefips==11755
replace msacmsa=8920 if statefips==19 & placefips==82425
replace msacmsa=8940 if statefips==55 & placefips==84475
replace msacmsa=8960 if statefips==12 & placefips==7300
replace msacmsa=8960 if statefips==12 & placefips==76600
replace msacmsa=9000 if statefips==54 & placefips==86452
replace msacmsa=9040 if statefips==20 & placefips==79000
replace msacmsa=9080 if statefips==48 & placefips==79000
replace msacmsa=9140 if statefips==42 & placefips==85312
replace msacmsa=920 if statefips==28 & placefips==29700
replace msacmsa=920 if statefips==28 & placefips==55360
replace msacmsa=920 if statefips==28 & placefips==6220
replace msacmsa=9200 if statefips==37 & placefips==74440
replace msacmsa=9260 if statefips==53 & placefips==80010
replace msacmsa=9280 if statefips==42 & placefips==87048
replace msacmsa=9320 if statefips==39 & placefips==80892
replace msacmsa=9320 if statefips==39 & placefips==88000
replace msacmsa=9340 if statefips==6 & placefips==86972
replace msacmsa=9360 if statefips==4 & placefips==85540
replace msacmsa=960 if statefips==36 & placefips==6607

** New England

#delimit ; 
replace msacmsa = 3283 if statefips==9 & (placefips==37000 | placefips==47290);
replace msacmsa = 5483 if statefips==9 & (placefips==52000 
| placefips==8000 | placefips==73000 | placefips==80000 |
placefips==18430 | placefips==46450 | placefips==55990);
replace msacmsa = 5523 if statefips==9 & (placefips==52280 |
placefips==56200);

replace msacmsa = 733 if statefips==23 & placefips==2795;
replace msacmsa = 4243 if statefips==23 & (placefips==38740 |
placefips==2060);
replace msacmsa = 6403 if statefips==23 & placefips==60545;

** Too small to be useful;
*replace msacmsa = 743 if statefips==25 & (placefips==3600 |
placefips==82525);
replace msacmsa = 1123 if statefips==25 & (placefips==7000 |
placefips==11000 | placefips==37490 | placefips==72600 |
placefips==26150 | placefips==9000 | placefips==23875 |
placefips==35075 | placefips==82000 | placefips==34550 |
placefips==37000 | placefips==45000 | 
placefips==2690 | placefips==23000);
replace msacmsa = 6323 if statefips==25 & placefips==53960;
replace msacmsa = 8003 if statefips==25 & (placefips==67000);
drop if statefips==25 & (placefips==30840 | placefips==46330
| placefips==76030);

replace msacmsa = 4760 if statefips==33 & (placefips==45140 | 
placefips==50260 | placefips==65140 | placefips==62900);

replace msacmsa = 6483 if statefips==44 & (placefips==59000 |
placefips==54640 | placefips==74300 |  placefips==80780);

replace msacmsa = 1303 if statefips==50 & placefips==10675;
#delimit cr

gen pmsa = -9

*** All But New England

replace pmsa=1125 if statefips==8 & placefips==45970
replace pmsa=1125 if statefips==8 & placefips==7850
replace pmsa=1150 if statefips==53 & placefips==7695
replace pmsa=1310 if statefips==72 & placefips==10334
replace pmsa=1310 if statefips==72 & placefips==15494
replace pmsa=1600 if statefips==17 & placefips==14000
replace pmsa=1600 if statefips==17 & placefips==19161
replace pmsa=1600 if statefips==17 & placefips==23074
replace pmsa=1600 if statefips==17 & placefips==24582
replace pmsa=1600 if statefips==17 & placefips==3012
replace pmsa=1600 if statefips==17 & placefips==38570
replace pmsa=1600 if statefips==17 & placefips==53559
replace pmsa=1640 if statefips==39 & placefips==15000
replace pmsa=1680 if statefips==39 & placefips==16000
replace pmsa=1680 if statefips==39 & placefips==25256
replace pmsa=1680 if statefips==39 & placefips==44856
replace pmsa=1920 if statefips==48 & placefips==19000
replace pmsa=1920 if statefips==48 & placefips==19972
replace pmsa=1920 if statefips==48 & placefips==37000
replace pmsa=2080 if statefips==8 & placefips==20000
replace pmsa=2160 if statefips==26 & placefips==21000
replace pmsa=2160 if statefips==26 & placefips==22000
replace pmsa=2160 if statefips==26 & placefips==65440
replace pmsa=2160 if statefips==26 & placefips==65820
replace pmsa=2281 if statefips==36 & placefips==59641
replace pmsa=2640 if statefips==26 & placefips==29000
replace pmsa=2680 if statefips==12 & placefips==24000
replace pmsa=2800 if statefips==48 & placefips==27000
replace pmsa=2800 if statefips==48 & placefips==4000
replace pmsa=2920 if statefips==48 & placefips==28068
replace pmsa=2920 if statefips==48 & placefips==72392
replace pmsa=2960 if statefips==18 & placefips==19486
replace pmsa=2960 if statefips==18 & placefips==27000
replace pmsa=3060 if statefips==8 & placefips==32155
replace pmsa=3180 if statefips==24 & placefips==36075
replace pmsa=3200 if statefips==39 & placefips==33012
replace pmsa=3200 if statefips==39 & placefips==49840
replace pmsa=3360 if statefips==48 & placefips==16432
replace pmsa=3360 if statefips==48 & placefips==35000
replace pmsa=3360 if statefips==48 & placefips==6128
replace pmsa=3640 if statefips==34 & placefips==3580
replace pmsa=3640 if statefips==34 & placefips==36000
replace pmsa=3740 if statefips==17 & placefips==38934
replace pmsa=3800 if statefips==55 & placefips==39225
replace pmsa=440 if statefips==26 & placefips==3000
replace pmsa=4480 if statefips==6 & placefips==40130
replace pmsa=4480 if statefips==6 & placefips==43000
replace pmsa=4480 if statefips==6 & placefips==44000
replace pmsa=4480 if statefips==6 & placefips==56000
replace pmsa=470 if statefips==72 & placefips==3368
replace pmsa=4760 if statefips==33 & placefips==45140
replace pmsa=5000 if statefips==12 & placefips==45000
replace pmsa=5000 if statefips==12 & placefips==45025
replace pmsa=5080 if statefips==55 & placefips==53000
replace pmsa=5080 if statefips==55 & placefips==84250
replace pmsa=5190 if statefips==34 & placefips==18130
replace pmsa=560 if statefips==34 & placefips==2080
replace pmsa=5600 if statefips==36 & placefips==51000
replace pmsa=5600 if statefips==36 & placefips==81677
replace pmsa=5640 if statefips==34 & placefips==51000
replace pmsa=5660 if statefips==36 & placefips==50034
replace pmsa=5775 if statefips==6 & placefips==53000
replace pmsa=5775 if statefips==6 & placefips==562
replace pmsa=5775 if statefips==6 & placefips==6000
replace pmsa=5910 if statefips==53 & placefips==51300
replace pmsa=5945 if statefips==6 & placefips==2000
replace pmsa=5945 if statefips==6 & placefips==36770
replace pmsa=5945 if statefips==6 & placefips==69000
replace pmsa=6160 if statefips==34 & placefips==10000
replace pmsa=6160 if statefips==42 & placefips==60000
replace pmsa=6440 if statefips==41 & placefips==59000
replace pmsa=6440 if statefips==53 & placefips==74060
replace pmsa=6450 if statefips==33 & placefips==62900
replace pmsa=6450 if statefips==33 & placefips==65140
replace pmsa=6600 if statefips==55 & placefips==66000
replace pmsa=6780 if statefips==6 & placefips==33182
replace pmsa=6780 if statefips==6 & placefips==55184
replace pmsa=6780 if statefips==6 & placefips==55254
replace pmsa=6780 if statefips==6 & placefips==62000
replace pmsa=6780 if statefips==6 & placefips==65000
replace pmsa=6780 if statefips==6 & placefips==78120
replace pmsa=6920 if statefips==6 & placefips==64000
replace pmsa=7080 if statefips==41 & placefips==64900
replace pmsa=720 if statefips==24 & placefips==1600
replace pmsa=720 if statefips==24 & placefips==4000
replace pmsa=7360 if statefips==6 & placefips==67000
replace pmsa=7400 if statefips==6 & placefips==29504
replace pmsa=7400 if statefips==6 & placefips==55282
replace pmsa=7400 if statefips==6 & placefips==68000
replace pmsa=7400 if statefips==6 & placefips==69084
replace pmsa=7400 if statefips==6 & placefips==77000
replace pmsa=7440 if statefips==72 & placefips==27964
replace pmsa=7440 if statefips==72 & placefips==35532
replace pmsa=7440 if statefips==72 & placefips==50152
replace pmsa=7440 if statefips==72 & placefips==6593
replace pmsa=7440 if statefips==72 & placefips==76770
replace pmsa=7440 if statefips==72 & placefips==85326
replace pmsa=7485 if statefips==6 & placefips==69112
replace pmsa=7485 if statefips==6 & placefips==83668
replace pmsa=7500 if statefips==6 & placefips==56784
replace pmsa=7500 if statefips==6 & placefips==70098
replace pmsa=7600 if statefips==53 & placefips==22640
replace pmsa=7600 if statefips==53 & placefips==5210
replace pmsa=7600 if statefips==53 & placefips==63000
replace pmsa=80 if statefips==39 & placefips==1000
replace pmsa=80 if statefips==39 & placefips==39872
replace pmsa=8200 if statefips==53 & placefips==70000
replace pmsa=8480 if statefips==34 & placefips==74000
replace pmsa=8720 if statefips==6 & placefips==23182
replace pmsa=8720 if statefips==6 & placefips==50258
replace pmsa=8720 if statefips==6 & placefips==81666
replace pmsa=8735 if statefips==6 & placefips==65042
replace pmsa=8760 if statefips==34 & placefips==46680
replace pmsa=8760 if statefips==34 & placefips==7600
replace pmsa=8760 if statefips==34 & placefips==76070
replace pmsa=8840 if statefips==11 & placefips==50000
replace pmsa=8840 if statefips==24 & placefips==30325
replace pmsa=8840 if statefips==51 & placefips==29744
replace pmsa=8840 if statefips==51 & placefips==3000
replace pmsa=9160 if statefips==10 & placefips==50670
replace pmsa=9160 if statefips==10 & placefips==77580
replace pmsa=9270 if statefips==6 & placefips==18100
replace pmsa=9270 if statefips==6 & placefips==86328

** None in New England


*** Recode Variables

gen msa = msacmsa
replace msa = pmsa if pmsa~=-9
gen cmsa = msacmsa

drop msacmsa pmsa

