/* Important: you need to put the .dat and .do files in one folder/
   directory and then set the working folder to that folder. */

set mem 500m


cd "C:\Users\datkin\Desktop\WORK\Mexico\mexico_censo\datkin_princeton_edu_011.dat\"

*cd /scratch/datkin

set more off

clear
infix ///
 int     sample                               1-4 ///
 double  serial                               5-14 ///
 int     persons                             15-17 ///
 byte    urban                               18 ///
 byte    statemx                             19-20 ///
 long    munimx                              21-25 ///
 byte    sizemx                              26 ///
 byte    intmig2                             27-28 ///
 byte    mx95a_state                         29-30 ///
 long    mx95a_munic                         31-35 ///
 int     pernum                              36-38 ///
 float  wtper                               39-46 ///
 int     age                                 47-49 ///
 byte    sex                                 50 ///
 int     marst                               51 ///
 int     marstd                              51-53 ///
 byte    agemarr                             54-55 ///
 byte    nativty                             56 ///
 long    bplctry                             57-61 ///
 byte    bplmx                               62-63 ///
 byte    school                              64 ///
 byte    yrschl                              65-66 ///
 int     empstat                             67 ///
 int     empstatd                            67-69 ///
 byte    occisco                             70-71 ///
 int     occ                                 72-75 ///
 int     indgen                              76-78 ///
 long    ind                                 79-83 ///
 int     classwk                             84 ///
 int     classwkd                            84-86 ///
 int     hrswrk1                             87-89 ///
 long    inctot                              90-96 ///
 double  incearn                             97-104 ///
 long    incwel                             105-110 ///
 long    incret                             111-116 ///
 long    incfmab                            117-122 ///
 byte    mgrate5                            123-124 ///
 byte    mgratep                            125-126 ///
 byte    migmx1                             127-128 ///
 byte    migmx2                             129-130 ///
 byte    mgyrs1                             131-132 ///
 long    mx95a_wtper                        133-137 ///
 byte    mx95a_respr                        138-139 ///
 byte    mx95a_resprm                       140-141 ///
 byte    mx95a_prespry                      142-143 ///
 byte    mx95a_resdurm                      144-145 ///
 byte    mx95a_resdury                      146-147 ///
 byte    mx95a_resst                        148-149 ///
 long    mx95a_resmun                       150-154 ///
 long    mx95a_inctotp                      155-160 ///
 using datkin_princeton_edu_011.dat

/* Modify weights to reflect customized samples. */
replace wtper = wtper * 0.999999985098839 if sample == 4844
replace wtper=wtper/10000

label var sample `"IPUMS sample identifier"'
label var serial `"Serial number"'
label var persons `"Number of person records in the household"'
label var urban `"Urban-rural status"'
label var statemx `"State, Mexico"'
label var munimx `"Municipality, Mexico"'
label var sizemx `"Size of locality, Mexico"'
label var intmig2 `"Number of international migrants, Mexico"'
label var mx95a_state `"Federal entity"'
label var mx95a_munic `"Municipality or delegation"'
label var pernum `"Person number"'
label var wtper `"Person weight"'
label var age `"Age"'
label var sex `"Sex"'
label var marst `"Marital status [general version]"'
label var marstd `"Marital status [detailed version]"'
label var agemarr `"Age at first marriage"'
label var nativty `"Nativity status"'
label var bplctry `"Country of birth"'
label var bplmx `"State of birth, Mexico"'
label var school `"School attendance"'
label var yrschl `"Years of schooling"'
label var empstat `"Employment status [general version]"'
label var empstatd `"Employment status [detailed version]"'
label var occisco `"Occupation, ISCO"'
label var occ `"Occupation, unrecoded"'
label var indgen `"Industry, general recode"'
label var ind `"Industry, unrecoded"'
label var classwk `"Class of worker [general version]"'
label var classwkd `"Class of worker [detailed version]"'
label var hrswrk1 `"Hours worked per week"'
label var inctot `"Total income"'
label var incearn `"Earned income"'
label var incwel `"Income from anti-poverty or welfare programs"'
label var incret `"Retirement or pension income"'
label var incfmab `"Income from family members living abroad"'
label var mgrate5 `"Migration status, 5 years"'
label var mgratep `"Migration status, previous residence"'
label var migmx1 `"State of previous residence, Mexico"'
label var migmx2 `"State of residence 5 years ago, Mexico"'
label var mgyrs1 `"Years residing in current locality"'
label var mx95a_wtper `"Expansion factor"'
label var mx95a_respr `"Previous residence"'
label var mx95a_resprm `"Duration in previous residence in months"'
label var mx95a_prespry `"Duration in previous residence in years"'
label var mx95a_resdurm `"Duration in current residence in months"'
label var mx95a_resdury `"Time in current residence in years"'
label var mx95a_resst `"State or country of residence in 1990"'
label var mx95a_resmun `"Municipality of residence in 1990"'
label var mx95a_inctotp `"Monthly total income of person"'

label define samplelbl 0321 `"Argentina 1970"'
label define samplelbl 0322 `"Argentina 1980"', add
label define samplelbl 0323 `"Argentina 1991"', add
label define samplelbl 0324 `"Argentina 2001"', add
label define samplelbl 0401 `"Austria 1971"', add
label define samplelbl 0402 `"Austria 1981"', add
label define samplelbl 0403 `"Austria 1991"', add
label define samplelbl 0404 `"Austria 2001"', add
label define samplelbl 0761 `"Brazil 1960"', add
label define samplelbl 0762 `"Brazil 1970"', add
label define samplelbl 0763 `"Brazil 1980"', add
label define samplelbl 0764 `"Brazil 1991"', add
label define samplelbl 0765 `"Brazil 2000"', add
label define samplelbl 1121 `"Belarus 1999"', add
label define samplelbl 1161 `"Cambodia 1998"', add
label define samplelbl 1241 `"Canada 1971"', add
label define samplelbl 1242 `"Canada 1981"', add
label define samplelbl 1243 `"Canada 1991"', add
label define samplelbl 1244 `"Canada 2001"', add
label define samplelbl 1521 `"Chile 1960"', add
label define samplelbl 1522 `"Chile 1970"', add
label define samplelbl 1523 `"Chile 1982"', add
label define samplelbl 1524 `"Chile 1992"', add
label define samplelbl 1525 `"Chile 2002"', add
label define samplelbl 1561 `"China 1982"', add
label define samplelbl 1562 `"China 1990"', add
label define samplelbl 1701 `"Colombia 1964"', add
label define samplelbl 1702 `"Colombia 1973"', add
label define samplelbl 1703 `"Colombia 1985"', add
label define samplelbl 1704 `"Colombia 1993"', add
label define samplelbl 1705 `"Colombia 2005"', add
label define samplelbl 1881 `"Costa Rica 1963"', add
label define samplelbl 1882 `"Costa Rica 1973"', add
label define samplelbl 1883 `"Costa Rica 1984"', add
label define samplelbl 1884 `"Costa Rica 2000"', add
label define samplelbl 2181 `"Ecuador 1962"', add
label define samplelbl 2182 `"Ecuador 1974"', add
label define samplelbl 2183 `"Ecuador 1982"', add
label define samplelbl 2184 `"Ecuador 1990"', add
label define samplelbl 2185 `"Ecuador 2001"', add
label define samplelbl 2501 `"France 1962"', add
label define samplelbl 2502 `"France 1968"', add
label define samplelbl 2503 `"France 1975"', add
label define samplelbl 2504 `"France 1982"', add
label define samplelbl 2505 `"France 1990"', add
label define samplelbl 2881 `"Ghana 2000"', add
label define samplelbl 3001 `"Greece 1971"', add
label define samplelbl 3002 `"Greece 1981"', add
label define samplelbl 3003 `"Greece 1991"', add
label define samplelbl 3004 `"Greece 2001"', add
label define samplelbl 3481 `"Hungary 1970"', add
label define samplelbl 3482 `"Hungary 1980"', add
label define samplelbl 3483 `"Hungary 1990"', add
label define samplelbl 3484 `"Hungary 2001"', add
label define samplelbl 3681 `"Iraq 1997"', add
label define samplelbl 3761 `"Israel 1972"', add
label define samplelbl 3762 `"Israel 1983"', add
label define samplelbl 3763 `"Israel 1995"', add
label define samplelbl 4041 `"Kenya 1989"', add
label define samplelbl 4042 `"Kenya 1999"', add
label define samplelbl 4581 `"Malaysia 1970"', add
label define samplelbl 4582 `"Malaysia 1980"', add
label define samplelbl 4583 `"Malaysia 1991"', add
label define samplelbl 4584 `"Malaysia 2000"', add
label define samplelbl 4841 `"Mexico 1960"', add
label define samplelbl 4842 `"Mexico 1970"', add
label define samplelbl 4843 `"Mexico 1990"', add
label define samplelbl 4844 `"Mexico 1995"', add
label define samplelbl 4845 `"Mexico 2000"', add
label define samplelbl 4846 `"Mexico 2005"', add
label define samplelbl 5281 `"Netherlands 1960"', add
label define samplelbl 5282 `"Netherlands 1971"', add
label define samplelbl 5283 `"Netherlands 2001"', add
label define samplelbl 5911 `"Panama 1960"', add
label define samplelbl 5912 `"Panama 1970"', add
label define samplelbl 5913 `"Panama 1980"', add
label define samplelbl 5914 `"Panama 1990"', add
label define samplelbl 5915 `"Panama 2000"', add
label define samplelbl 6021 `"Palestine 1997"', add
label define samplelbl 6081 `"Philippines 1990"', add
label define samplelbl 6082 `"Philippines 1995"', add
label define samplelbl 6083 `"Philippines 2000"', add
label define samplelbl 6201 `"Portugal 1981"', add
label define samplelbl 6202 `"Portugal 1991"', add
label define samplelbl 6203 `"Portugal 2001"', add
label define samplelbl 6421 `"Romania 1992"', add
label define samplelbl 6422 `"Romania 2002"', add
label define samplelbl 6461 `"Rwanda 1991"', add
label define samplelbl 6462 `"Rwanda 2002"', add
label define samplelbl 7041 `"Vietnam 1989"', add
label define samplelbl 7042 `"Vietnam 1999"', add
label define samplelbl 7101 `"South Africa 1996"', add
label define samplelbl 7102 `"South Africa 2001"', add
label define samplelbl 7241 `"Spain 1981"', add
label define samplelbl 7242 `"Spain 1991"', add
label define samplelbl 7243 `"Spain 2001"', add
label define samplelbl 8001 `"Uganda 1991"', add
label define samplelbl 8002 `"Uganda 2002"', add
label define samplelbl 8181 `"Egypt 1996"', add
label define samplelbl 8261 `"United Kingdom 1991"', add
label define samplelbl 8262 `"United Kingdom 2001"', add
label define samplelbl 8401 `"United States 1960"', add
label define samplelbl 8402 `"United States 1970"', add
label define samplelbl 8403 `"United States 1980"', add
label define samplelbl 8404 `"United States 1990"', add
label define samplelbl 8405 `"United States 2000"', add
label define samplelbl 8406 `"United States 2005"', add
label define samplelbl 8621 `"Venezuela 1971"', add
label define samplelbl 8622 `"Venezuela 1981"', add
label define samplelbl 8623 `"Venezuela 1990"', add
label define samplelbl 8624 `"Venezuela 2001"', add
label values sample samplelbl

label values serial seriallbl

label values persons personslbl

label define urbanlbl 0 `"NIU (not in universe)"'
label define urbanlbl 1 `"Rural"', add
label define urbanlbl 2 `"Urban"', add
label define urbanlbl 9 `"Unknown"', add
label values urban urbanlbl

label define statemxlbl 01 `"Aguascalientes"'
label define statemxlbl 02 `"Baja California"', add
label define statemxlbl 03 `"Baja California Sur"', add
label define statemxlbl 04 `"Campeche"', add
label define statemxlbl 05 `"Coahuila"', add
label define statemxlbl 06 `"Colima"', add
label define statemxlbl 07 `"Chiapas"', add
label define statemxlbl 08 `"Chihuahua"', add
label define statemxlbl 09 `"Distrito Federal"', add
label define statemxlbl 10 `"Durango"', add
label define statemxlbl 11 `"Guanajuato"', add
label define statemxlbl 12 `"Guerrero"', add
label define statemxlbl 13 `"Hidalgo"', add
label define statemxlbl 14 `"Jalisco"', add
label define statemxlbl 15 `"México"', add
label define statemxlbl 16 `"Michoacán"', add
label define statemxlbl 17 `"Morelos"', add
label define statemxlbl 18 `"Nayarit"', add
label define statemxlbl 19 `"Nuevo León"', add
label define statemxlbl 20 `"Oaxaca"', add
label define statemxlbl 21 `"Puebla"', add
label define statemxlbl 22 `"Querétaro"', add
label define statemxlbl 23 `"Quintana Roo"', add
label define statemxlbl 24 `"San Luis Potosí"', add
label define statemxlbl 25 `"Sinaloa"', add
label define statemxlbl 26 `"Sonora"', add
label define statemxlbl 27 `"Tabasco"', add
label define statemxlbl 28 `"Tamaulipas"', add
label define statemxlbl 29 `"Tlaxcala"', add
label define statemxlbl 30 `"Veracruz"', add
label define statemxlbl 31 `"Yucatán"', add
label define statemxlbl 32 `"Zacatecas"', add
label values statemx statemxlbl

label define munimxlbl 01001 `"Aguascalientes"', add
label define munimxlbl 01002 `"Asientos"', add
label define munimxlbl 01003 `"Calvillo"', add
label define munimxlbl 01004 `"Cosio"', add
label define munimxlbl 01005 `"Jesus Maria"', add
label define munimxlbl 01006 `"Pabellon de Arteaga"', add
label define munimxlbl 01007 `"Rincon de Romos"', add
label define munimxlbl 01008 `"San Jose de Gracia"', add
label define munimxlbl 01009 `"Tepezala"', add
label define munimxlbl 01010 `"Llano, El"', add
label define munimxlbl 01011 `"San Francisco de los Romo"', add
label define munimxlbl 02001 `"Ensenada"', add
label define munimxlbl 02002 `"Mexicali"', add
label define munimxlbl 02003 `"Tecate"', add
label define munimxlbl 02004 `"Tijuana"', add
label define munimxlbl 02005 `"Playas de Rosarito"', add
label define munimxlbl 03001 `"Comondu"', add
label define munimxlbl 03002 `"Mulege"', add
label define munimxlbl 03003 `"Paz, La"', add
label define munimxlbl 03008 `"Cabos, Los"', add
label define munimxlbl 03009 `"Loreto"', add
label define munimxlbl 04001 `"Calkini"', add
label define munimxlbl 04002 `"Campeche"', add
label define munimxlbl 04003 `"Carmen"', add
label define munimxlbl 04004 `"Champoton"', add
label define munimxlbl 04005 `"Hecelchakan"', add
label define munimxlbl 04006 `"Hopelchen"', add
label define munimxlbl 04007 `"Palizada"', add
label define munimxlbl 04008 `"Tenabo"', add
label define munimxlbl 04009 `"Escarcega"', add
label define munimxlbl 04010 `"Calakmul"', add
label define munimxlbl 04011 `"Candelaria"', add
label define munimxlbl 05001 `"Abasolo"', add
label define munimxlbl 05002 `"Acuna"', add
label define munimxlbl 05003 `"Allende"', add
label define munimxlbl 05004 `"Arteaga"', add
label define munimxlbl 05005 `"Candela"', add
label define munimxlbl 05006 `"Castanos"', add
label define munimxlbl 05007 `"Cuatrocienegas"', add
label define munimxlbl 05008 `"Escobedo"', add
label define munimxlbl 05009 `"Francisco I. Madero"', add
label define munimxlbl 05010 `"Frontera"', add
label define munimxlbl 05011 `"General Cepeda"', add
label define munimxlbl 05012 `"Guerrero"', add
label define munimxlbl 05013 `"Hidalgo"', add
label define munimxlbl 05014 `"Jimenez"', add
label define munimxlbl 05015 `"Juarez"', add
label define munimxlbl 05016 `"Lamadrid"', add
label define munimxlbl 05017 `"Matamoros"', add
label define munimxlbl 05018 `"Monclova"', add
label define munimxlbl 05019 `"Morelos"', add
label define munimxlbl 05020 `"Muzquiz"', add
label define munimxlbl 05021 `"Nadadores"', add
label define munimxlbl 05022 `"Nava"', add
label define munimxlbl 05023 `"Ocampo"', add
label define munimxlbl 05024 `"Parras"', add
label define munimxlbl 05025 `"Piedras Negras"', add
label define munimxlbl 05026 `"Progreso"', add
label define munimxlbl 05027 `"Ramos Arizpe"', add
label define munimxlbl 05028 `"Sabinas"', add
label define munimxlbl 05029 `"Sacramento"', add
label define munimxlbl 05030 `"Saltillo"', add
label define munimxlbl 05031 `"San Buenaventura"', add
label define munimxlbl 05032 `"San Juan de Sabinas"', add
label define munimxlbl 05033 `"San Pedro"', add
label define munimxlbl 05034 `"Sierra Mojada"', add
label define munimxlbl 05035 `"Torreon"', add
label define munimxlbl 05036 `"Viesca"', add
label define munimxlbl 05037 `"Villa Union"', add
label define munimxlbl 05038 `"Zaragoza"', add
label define munimxlbl 06001 `"Armeria"', add
label define munimxlbl 06002 `"Colima"', add
label define munimxlbl 06003 `"Comala"', add
label define munimxlbl 06004 `"Coquimatlan"', add
label define munimxlbl 06005 `"Cuauhtemoc"', add
label define munimxlbl 06006 `"Ixtlahuacan"', add
label define munimxlbl 06007 `"Manzanillo"', add
label define munimxlbl 06008 `"Minatitlan"', add
label define munimxlbl 06009 `"Tecoman"', add
label define munimxlbl 06010 `"Villa de Alvarez"', add
label define munimxlbl 07001 `"Acacoyagua"', add
label define munimxlbl 07002 `"Acala"', add
label define munimxlbl 07003 `"Acapetahua"', add
label define munimxlbl 07004 `"Altamirano"', add
label define munimxlbl 07005 `"Amatan"', add
label define munimxlbl 07006 `"Amatenango de la Frontera"', add
label define munimxlbl 07007 `"Amatenango del Valle"', add
label define munimxlbl 07008 `"Angel Albino Corzo"', add
label define munimxlbl 07009 `"Arriaga"', add
label define munimxlbl 07010 `"Bejucal de Ocampo"', add
label define munimxlbl 07011 `"Bella Vista"', add
label define munimxlbl 07012 `"Berriozabal"', add
label define munimxlbl 07013 `"Bochil"', add
label define munimxlbl 07014 `"Bosque, El"', add
label define munimxlbl 07015 `"Cacahoatan"', add
label define munimxlbl 07016 `"Catazaja"', add
label define munimxlbl 07017 `"Cintalapa"', add
label define munimxlbl 07018 `"Coapilla"', add
label define munimxlbl 07019 `"Comitan de Dominguez"', add
label define munimxlbl 07020 `"Concordia, La"', add
label define munimxlbl 07021 `"Copainala"', add
label define munimxlbl 07022 `"Chalchihuitan"', add
label define munimxlbl 07023 `"Chamula"', add
label define munimxlbl 07024 `"Chanal"', add
label define munimxlbl 07025 `"Chapultenango"', add
label define munimxlbl 07026 `"Chenalho"', add
label define munimxlbl 07027 `"Chiapa de Corzo"', add
label define munimxlbl 07028 `"Chiapilla"', add
label define munimxlbl 07029 `"Chicoasen"', add
label define munimxlbl 07030 `"Chicomuselo"', add
label define munimxlbl 07031 `"Chilon"', add
label define munimxlbl 07032 `"Escuintla"', add
label define munimxlbl 07033 `"Francisco Leon"', add
label define munimxlbl 07034 `"Frontera Comalapa"', add
label define munimxlbl 07035 `"Frontera Hidalgo"', add
label define munimxlbl 07036 `"Grandeza, La"', add
label define munimxlbl 07037 `"Huehuetan"', add
label define munimxlbl 07038 `"Huixtan"', add
label define munimxlbl 07039 `"Huitiupan"', add
label define munimxlbl 07040 `"Huixtla"', add
label define munimxlbl 07041 `"Independencia, La"', add
label define munimxlbl 07042 `"Ixhuatan"', add
label define munimxlbl 07043 `"Ixtacomitan"', add
label define munimxlbl 07044 `"Ixtapa"', add
label define munimxlbl 07045 `"Ixtapangajoya"', add
label define munimxlbl 07046 `"Jiquipilas"', add
label define munimxlbl 07047 `"Jitotol"', add
label define munimxlbl 07048 `"Juarez"', add
label define munimxlbl 07049 `"Larrainzar"', add
label define munimxlbl 07050 `"Libertad, La"', add
label define munimxlbl 07051 `"Mapastepec"', add
label define munimxlbl 07052 `"Margaritas, Las"', add
label define munimxlbl 07053 `"Mazapa de Madero"', add
label define munimxlbl 07054 `"Mazatan"', add
label define munimxlbl 07055 `"Metapa"', add
label define munimxlbl 07056 `"Mitontic"', add
label define munimxlbl 07057 `"Motozintla"', add
label define munimxlbl 07058 `"Nicolas Ruiz"', add
label define munimxlbl 07059 `"Ocosingo"', add
label define munimxlbl 07060 `"Ocotepec"', add
label define munimxlbl 07061 `"Ocozocoautla de Espinosa"', add
label define munimxlbl 07062 `"Ostuacan"', add
label define munimxlbl 07063 `"Osumacinta"', add
label define munimxlbl 07064 `"Oxchuc"', add
label define munimxlbl 07065 `"Palenque"', add
label define munimxlbl 07066 `"Pantelho"', add
label define munimxlbl 07067 `"Pantepec"', add
label define munimxlbl 07068 `"Pichucalco"', add
label define munimxlbl 07069 `"Pijijiapan"', add
label define munimxlbl 07070 `"Porvenir, El"', add
label define munimxlbl 07071 `"Villa Comaltitlan"', add
label define munimxlbl 07072 `"Pueblo Nuevo Solistahuacan"', add
label define munimxlbl 07073 `"Rayon"', add
label define munimxlbl 07074 `"Reforma"', add
label define munimxlbl 07075 `"Rosas, Las"', add
label define munimxlbl 07076 `"Sabanilla"', add
label define munimxlbl 07077 `"Salto de Agua"', add
label define munimxlbl 07078 `"San Cristobal de las Casas"', add
label define munimxlbl 07079 `"San Fernando"', add
label define munimxlbl 07080 `"Siltepec"', add
label define munimxlbl 07081 `"Simojovel"', add
label define munimxlbl 07082 `"Sitala"', add
label define munimxlbl 07083 `"Socoltenango"', add
label define munimxlbl 07084 `"Solosuchiapa"', add
label define munimxlbl 07085 `"Soyalo"', add
label define munimxlbl 07086 `"Suchiapa"', add
label define munimxlbl 07087 `"Suchiate"', add
label define munimxlbl 07088 `"Sunuapa"', add
label define munimxlbl 07089 `"Tapachula"', add
label define munimxlbl 07090 `"Tapalapa"', add
label define munimxlbl 07091 `"Tapilula"', add
label define munimxlbl 07092 `"Tecpatan"', add
label define munimxlbl 07093 `"Tenejapa"', add
label define munimxlbl 07094 `"Teopisca"', add
label define munimxlbl 07096 `"Tila"', add
label define munimxlbl 07097 `"Tonala"', add
label define munimxlbl 07098 `"Totolapa"', add
label define munimxlbl 07099 `"Trinitaria, La"', add
label define munimxlbl 07100 `"Tumbala"', add
label define munimxlbl 07101 `"Tuxtla Gutierrez"', add
label define munimxlbl 07102 `"Tuxtla Chico"', add
label define munimxlbl 07103 `"Tuzantan"', add
label define munimxlbl 07104 `"Tzimol"', add
label define munimxlbl 07105 `"Union Juarez"', add
label define munimxlbl 07106 `"Venustiano Carranza"', add
label define munimxlbl 07107 `"Villa Corzo"', add
label define munimxlbl 07108 `"Villaflores"', add
label define munimxlbl 07109 `"Yajalon"', add
label define munimxlbl 07110 `"San Lucas"', add
label define munimxlbl 07111 `"Zinacantan"', add
label define munimxlbl 07112 `"San Juan Cancuc"', add
label define munimxlbl 07113 `"Aldama"', add
label define munimxlbl 07114 `"Benemerito de las Americas"', add
label define munimxlbl 07115 `"Maravilla Tenejapa"', add
label define munimxlbl 07116 `"Marques de Comillas"', add
label define munimxlbl 07117 `"Monte Cristo de Guerrero"', add
label define munimxlbl 07118 `"San Andres Duraznal"', add
label define munimxlbl 07119 `"Santiago el Pinar"', add
label define munimxlbl 08001 `"Ahumada"', add
label define munimxlbl 08002 `"Aldama"', add
label define munimxlbl 08003 `"Allende"', add
label define munimxlbl 08004 `"Aquiles Serdan"', add
label define munimxlbl 08005 `"Ascension"', add
label define munimxlbl 08006 `"Bachiniva"', add
label define munimxlbl 08007 `"Balleza"', add
label define munimxlbl 08008 `"Batopilas"', add
label define munimxlbl 08009 `"Bocoyna"', add
label define munimxlbl 08010 `"Buenaventura"', add
label define munimxlbl 08011 `"Camargo"', add
label define munimxlbl 08012 `"Carichi"', add
label define munimxlbl 08013 `"Casas Grandes"', add
label define munimxlbl 08014 `"Coronado"', add
label define munimxlbl 08015 `"Coyame del Sotol"', add
label define munimxlbl 08016 `"Cruz, La"', add
label define munimxlbl 08017 `"Cuauhtemoc"', add
label define munimxlbl 08018 `"Cusihuiriachi"', add
label define munimxlbl 08019 `"Chihuahua"', add
label define munimxlbl 08020 `"Chinipas"', add
label define munimxlbl 08021 `"Delicias"', add
label define munimxlbl 08022 `"Dr. Belisario Dominguez"', add
label define munimxlbl 08023 `"Galeana"', add
label define munimxlbl 08024 `"Santa Isabel"', add
label define munimxlbl 08025 `"Gomez Farias"', add
label define munimxlbl 08026 `"Gran Morelos"', add
label define munimxlbl 08027 `"Guachochi"', add
label define munimxlbl 08028 `"Guadalupe"', add
label define munimxlbl 08029 `"Guadalupe y Calvo"', add
label define munimxlbl 08030 `"Guazapares"', add
label define munimxlbl 08031 `"Guerrero"', add
label define munimxlbl 08032 `"Hidalgo del Parral"', add
label define munimxlbl 08033 `"Huejotitan"', add
label define munimxlbl 08034 `"Ignacio Zaragoza"', add
label define munimxlbl 08035 `"Janos"', add
label define munimxlbl 08036 `"Jimenez"', add
label define munimxlbl 08037 `"Juarez"', add
label define munimxlbl 08038 `"Julimes"', add
label define munimxlbl 08039 `"Lopez"', add
label define munimxlbl 08040 `"Madera"', add
label define munimxlbl 08041 `"Maguarichi"', add
label define munimxlbl 08042 `"Manuel Benavides"', add
label define munimxlbl 08043 `"Matachi"', add
label define munimxlbl 08044 `"Matamoros"', add
label define munimxlbl 08045 `"Meoqui"', add
label define munimxlbl 08046 `"Morelos"', add
label define munimxlbl 08047 `"Moris"', add
label define munimxlbl 08048 `"Namiquipa"', add
label define munimxlbl 08049 `"Nonoava"', add
label define munimxlbl 08050 `"Nuevo Casas Grandes"', add
label define munimxlbl 08051 `"Ocampo"', add
label define munimxlbl 08052 `"Ojinaga"', add
label define munimxlbl 08053 `"Praxedis G. Guerrero"', add
label define munimxlbl 08054 `"Riva Palacio"', add
label define munimxlbl 08055 `"Rosales"', add
label define munimxlbl 08056 `"Rosario"', add
label define munimxlbl 08057 `"San Francisco de Borja"', add
label define munimxlbl 08058 `"San Francisco de Conchos"', add
label define munimxlbl 08059 `"San Francisco del Oro"', add
label define munimxlbl 08060 `"Santa Barbara"', add
label define munimxlbl 08061 `"Satevo"', add
label define munimxlbl 08062 `"Saucillo"', add
label define munimxlbl 08063 `"Temosachi"', add
label define munimxlbl 08064 `"Tule, El"', add
label define munimxlbl 08065 `"Urique"', add
label define munimxlbl 08066 `"Uruachi"', add
label define munimxlbl 08067 `"Valle de Zaragoza"', add
label define munimxlbl 09002 `"Azcapotzalco"', add
label define munimxlbl 09003 `"Coyoacan"', add
label define munimxlbl 09004 `"Cuajimalpa de Morelos"', add
label define munimxlbl 09005 `"Gustavo A. Madero"', add
label define munimxlbl 09006 `"Iztacalco"', add
label define munimxlbl 09007 `"Iztapalapa"', add
label define munimxlbl 09008 `"Magdalena Contreras, La"', add
label define munimxlbl 09009 `"Milpa Alta"', add
label define munimxlbl 09010 `"Alvaro Obregon"', add
label define munimxlbl 09011 `"Tlahuac"', add
label define munimxlbl 09012 `"Tlalpan"', add
label define munimxlbl 09013 `"Xochimilco"', add
label define munimxlbl 09014 `"Benito Juarez"', add
label define munimxlbl 09015 `"Cuauhtemoc"', add
label define munimxlbl 09016 `"Miguel Hidalgo"', add
label define munimxlbl 09017 `"Venustiano Carranza"', add
label define munimxlbl 10001 `"Canatlan"', add
label define munimxlbl 10002 `"Canelas"', add
label define munimxlbl 10003 `"Coneto de Comonfort"', add
label define munimxlbl 10004 `"Cuencame"', add
label define munimxlbl 10005 `"Durango"', add
label define munimxlbl 10006 `"General Simon Bolivar"', add
label define munimxlbl 10007 `"Gomez Palacio"', add
label define munimxlbl 10008 `"Guadalupe Victoria"', add
label define munimxlbl 10009 `"Guanacevi"', add
label define munimxlbl 10010 `"Hidalgo"', add
label define munimxlbl 10011 `"Inde"', add
label define munimxlbl 10012 `"Lerdo"', add
label define munimxlbl 10013 `"Mapimi"', add
label define munimxlbl 10014 `"Mezquital"', add
label define munimxlbl 10015 `"Nazas"', add
label define munimxlbl 10016 `"Nombre de Dios"', add
label define munimxlbl 10017 `"Ocampo"', add
label define munimxlbl 10018 `"Oro, El"', add
label define munimxlbl 10019 `"Otaez"', add
label define munimxlbl 10020 `"Panuco de Coronado"', add
label define munimxlbl 10021 `"Penon Blanco"', add
label define munimxlbl 10022 `"Poanas"', add
label define munimxlbl 10023 `"Pueblo Nuevo"', add
label define munimxlbl 10024 `"Rodeo"', add
label define munimxlbl 10025 `"San Bernardo"', add
label define munimxlbl 10026 `"San dimas"', add
label define munimxlbl 10027 `"San Juan de Guadalupe"', add
label define munimxlbl 10028 `"San Juan del Rio"', add
label define munimxlbl 10029 `"San Luis del Cordero"', add
label define munimxlbl 10030 `"San Pedro del Gallo"', add
label define munimxlbl 10031 `"Santa Clara"', add
label define munimxlbl 10032 `"Santiago Papasquiaro"', add
label define munimxlbl 10033 `"Suchil"', add
label define munimxlbl 10034 `"Tamazula"', add
label define munimxlbl 10035 `"Tepehuanes"', add
label define munimxlbl 10036 `"Tlahualilo"', add
label define munimxlbl 10037 `"Topia"', add
label define munimxlbl 10038 `"Vicente Guerrero"', add
label define munimxlbl 10039 `"Nuevo Ideal"', add
label define munimxlbl 11001 `"Abasolo"', add
label define munimxlbl 11002 `"Acambaro"', add
label define munimxlbl 11003 `"Allende"', add
label define munimxlbl 11004 `"Apaseo el Alto"', add
label define munimxlbl 11005 `"Apaseo el Grande"', add
label define munimxlbl 11006 `"Atarjea"', add
label define munimxlbl 11007 `"Celaya"', add
label define munimxlbl 11008 `"Manuel Doblado"', add
label define munimxlbl 11009 `"Comonfort"', add
label define munimxlbl 11010 `"Coroneo"', add
label define munimxlbl 11011 `"Cortazar"', add
label define munimxlbl 11012 `"Cueramaro"', add
label define munimxlbl 11013 `"Doctor Mora"', add
label define munimxlbl 11014 `"Dolores Hidalgo"', add
label define munimxlbl 11015 `"Guanajuato"', add
label define munimxlbl 11016 `"Huanimaro"', add
label define munimxlbl 11017 `"Irapuato"', add
label define munimxlbl 11018 `"Jaral del Progreso"', add
label define munimxlbl 11019 `"Jerecuaro"', add
label define munimxlbl 11020 `"Leon"', add
label define munimxlbl 11021 `"Moroleon"', add
label define munimxlbl 11022 `"Ocampo"', add
label define munimxlbl 11023 `"Penjamo"', add
label define munimxlbl 11024 `"Pueblo Nuevo"', add
label define munimxlbl 11025 `"Purisima del Rincon"', add
label define munimxlbl 11026 `"Romita"', add
label define munimxlbl 11027 `"Salamanca"', add
label define munimxlbl 11028 `"Salvatierra"', add
label define munimxlbl 11029 `"San Diego de la Union"', add
label define munimxlbl 11030 `"San Felipe"', add
label define munimxlbl 11031 `"San Francisco del Rincon"', add
label define munimxlbl 11032 `"San Jose Iturbide"', add
label define munimxlbl 11033 `"San Luis de la Paz"', add
label define munimxlbl 11034 `"Santa Catarina"', add
label define munimxlbl 11035 `"Santa Cruz de Juventino Rosas"', add
label define munimxlbl 11036 `"Santiago Maravatio"', add
label define munimxlbl 11037 `"Silao"', add
label define munimxlbl 11038 `"Tarandacuao"', add
label define munimxlbl 11039 `"Tarimoro"', add
label define munimxlbl 11040 `"Tierra Blanca"', add
label define munimxlbl 11041 `"Uriangato"', add
label define munimxlbl 11042 `"Valle de Santiago"', add
label define munimxlbl 11043 `"Victoria"', add
label define munimxlbl 11044 `"Villagran"', add
label define munimxlbl 11045 `"Xichu"', add
label define munimxlbl 11046 `"Yuriria"', add
label define munimxlbl 12001 `"Acapulco de Juarez"', add
label define munimxlbl 12002 `"Ahuacuotzingo"', add
label define munimxlbl 12003 `"Ajuchitlan del Progreso"', add
label define munimxlbl 12004 `"Alcozauca de Guerrero"', add
label define munimxlbl 12005 `"Alpoyeca"', add
label define munimxlbl 12006 `"Apaxtla"', add
label define munimxlbl 12007 `"Arcelia"', add
label define munimxlbl 12008 `"Atenango del Rio"', add
label define munimxlbl 12009 `"Atlamajalcingo del Monte"', add
label define munimxlbl 12010 `"Atlixtac"', add
label define munimxlbl 12011 `"Atoyac de Alvarez"', add
label define munimxlbl 12012 `"Ayutla de los Libres"', add
label define munimxlbl 12013 `"Azoyu"', add
label define munimxlbl 12014 `"Benito Juarez"', add
label define munimxlbl 12015 `"Buenavista de Cuellar"', add
label define munimxlbl 12016 `"Coahuayutla de Jose Maria Izazaga"', add
label define munimxlbl 12017 `"Cocula"', add
label define munimxlbl 12018 `"Copala"', add
label define munimxlbl 12019 `"Copalillo"', add
label define munimxlbl 12020 `"Copanatoyac"', add
label define munimxlbl 12021 `"Coyuca de Benitez"', add
label define munimxlbl 12022 `"Coyuca de Catalan"', add
label define munimxlbl 12023 `"Cuajinicuilapa"', add
label define munimxlbl 12024 `"Cualac"', add
label define munimxlbl 12025 `"Cuautepec"', add
label define munimxlbl 12026 `"Cuetzala del Progreso"', add
label define munimxlbl 12027 `"Cutzamala de Pinzon"', add
label define munimxlbl 12028 `"Chilapa de Alvarez"', add
label define munimxlbl 12029 `"Chilpancingo de los Bravo"', add
label define munimxlbl 12030 `"Florencio Villarreal"', add
label define munimxlbl 12031 `"General Canuto A. Neri"', add
label define munimxlbl 12032 `"General Heliodoro Castillo"', add
label define munimxlbl 12033 `"Huamuxtitlan"', add
label define munimxlbl 12034 `"Huitzuco de los Figueroa"', add
label define munimxlbl 12035 `"Iguala de la Independencia"', add
label define munimxlbl 12036 `"Igualapa"', add
label define munimxlbl 12037 `"Ixcateopan de Cuauhtemoc"', add
label define munimxlbl 12038 `"Jose Azueta"', add
label define munimxlbl 12039 `"Juan R. Escudero"', add
label define munimxlbl 12040 `"Leonardo Bravo"', add
label define munimxlbl 12041 `"Malinaltepec"', add
label define munimxlbl 12042 `"Martir de Cuilapan"', add
label define munimxlbl 12043 `"Metlatonoc"', add
label define munimxlbl 12044 `"Mochitlan"', add
label define munimxlbl 12045 `"Olinala"', add
label define munimxlbl 12046 `"Ometepec"', add
label define munimxlbl 12047 `"Pedro Ascencio Alquisiras"', add
label define munimxlbl 12048 `"Petatlan"', add
label define munimxlbl 12049 `"Pilcaya"', add
label define munimxlbl 12050 `"Pungarabato"', add
label define munimxlbl 12051 `"Quechultenango"', add
label define munimxlbl 12052 `"San Luis Acatlan"', add
label define munimxlbl 12053 `"San Marcos"', add
label define munimxlbl 12054 `"San Miguel Totolapan"', add
label define munimxlbl 12055 `"Taxco de Alarcon"', add
label define munimxlbl 12056 `"Tecoanapa"', add
label define munimxlbl 12057 `"Tecpan de Galeana"', add
label define munimxlbl 12058 `"Teloloapan"', add
label define munimxlbl 12059 `"Tepecoacuilco de Trujano"', add
label define munimxlbl 12060 `"Tetipac"', add
label define munimxlbl 12061 `"Tixtla de Guerrero"', add
label define munimxlbl 12062 `"Tlacoachistlahuaca"', add
label define munimxlbl 12063 `"Tlacoapa"', add
label define munimxlbl 12064 `"Tlalchapa"', add
label define munimxlbl 12065 `"Tlalixtaquilla de Maldonado"', add
label define munimxlbl 12066 `"Tlapa de Comonfort"', add
label define munimxlbl 12067 `"Tlapehuala"', add
label define munimxlbl 12068 `"Union de Isidoro Montes de Oca, La"', add
label define munimxlbl 12069 `"Xalpatlahuac"', add
label define munimxlbl 12070 `"Xochihuehuetlan"', add
label define munimxlbl 12071 `"Xochistlahuaca"', add
label define munimxlbl 12072 `"Zapotitlan Tablas"', add
label define munimxlbl 12073 `"Zirandaro"', add
label define munimxlbl 12074 `"Zitlala"', add
label define munimxlbl 12075 `"Eduardo Neri"', add
label define munimxlbl 12076 `"Acatepec"', add
label define munimxlbl 12077 `"Marquelia"', add
label define munimxlbl 12078 `"Cochoapa el Grande"', add
label define munimxlbl 12079 `"José Joaquín de Herrera"', add
label define munimxlbl 12080 `"Juchitán"', add
label define munimxlbl 12081 `"Iliatenco"', add
label define munimxlbl 13001 `"Acatlan"', add
label define munimxlbl 13002 `"Acaxochitlan"', add
label define munimxlbl 13003 `"Actopan"', add
label define munimxlbl 13004 `"Agua Blanca de Iturbide"', add
label define munimxlbl 13005 `"Ajacuba"', add
label define munimxlbl 13006 `"Alfajayucan"', add
label define munimxlbl 13007 `"Almoloya"', add
label define munimxlbl 13008 `"Apan"', add
label define munimxlbl 13009 `"Arenal, El"', add
label define munimxlbl 13010 `"Atitalaquia"', add
label define munimxlbl 13011 `"Atlapexco"', add
label define munimxlbl 13012 `"Atotonilco el Grande"', add
label define munimxlbl 13013 `"Atotonilco de Tula"', add
label define munimxlbl 13014 `"Calnali"', add
label define munimxlbl 13015 `"Cardonal"', add
label define munimxlbl 13016 `"Cuautepec de Hinojosa"', add
label define munimxlbl 13017 `"Chapantongo"', add
label define munimxlbl 13018 `"Chapulhuacan"', add
label define munimxlbl 13019 `"Chilcuautla"', add
label define munimxlbl 13020 `"Eloxochitlan"', add
label define munimxlbl 13021 `"Emiliano Zapata"', add
label define munimxlbl 13022 `"Epazoyucan"', add
label define munimxlbl 13023 `"Francisco I. Madero"', add
label define munimxlbl 13024 `"Huasca de Ocampo"', add
label define munimxlbl 13025 `"Huautla"', add
label define munimxlbl 13026 `"Huazalingo"', add
label define munimxlbl 13027 `"Huehuetla"', add
label define munimxlbl 13028 `"Huejutla de Reyes"', add
label define munimxlbl 13029 `"Huichapan"', add
label define munimxlbl 13030 `"Ixmiquilpan"', add
label define munimxlbl 13031 `"Jacala de Ledezma"', add
label define munimxlbl 13032 `"Jaltocan"', add
label define munimxlbl 13033 `"Juarez Hidalgo"', add
label define munimxlbl 13034 `"Lolotla"', add
label define munimxlbl 13035 `"Metepec"', add
label define munimxlbl 13036 `"San Agustin Metzquititlan"', add
label define munimxlbl 13037 `"Metztitlan"', add
label define munimxlbl 13038 `"Mineral del Chico"', add
label define munimxlbl 13039 `"Mineral del Monte"', add
label define munimxlbl 13040 `"Mision, La"', add
label define munimxlbl 13041 `"Mixquiahuala de Juarez"', add
label define munimxlbl 13042 `"Molango de Escamilla"', add
label define munimxlbl 13043 `"Nicolas Flores"', add
label define munimxlbl 13044 `"Nopala de Villagran"', add
label define munimxlbl 13045 `"Omitlan de Juarez"', add
label define munimxlbl 13046 `"San Felipe Orizatlan"', add
label define munimxlbl 13047 `"Pacula"', add
label define munimxlbl 13048 `"Pachuca de Soto"', add
label define munimxlbl 13049 `"Pisaflores"', add
label define munimxlbl 13050 `"Progreso de Obregon"', add
label define munimxlbl 13051 `"Mineral de La Reforma"', add
label define munimxlbl 13052 `"San Agustin Tlaxiaca"', add
label define munimxlbl 13053 `"San Bartolo Tutotepec"', add
label define munimxlbl 13054 `"San Salvador"', add
label define munimxlbl 13055 `"Santiago de Anaya"', add
label define munimxlbl 13056 `"Santiago Tulantepec de Lugo Guerrero"', add
label define munimxlbl 13057 `"Singuilucan"', add
label define munimxlbl 13058 `"Tasquillo"', add
label define munimxlbl 13059 `"Tecozautla"', add
label define munimxlbl 13060 `"Tenango de Doria"', add
label define munimxlbl 13061 `"Tepeapulco"', add
label define munimxlbl 13062 `"Tepehuacan de Guerrero"', add
label define munimxlbl 13063 `"Tepeji del Rio de Ocampo"', add
label define munimxlbl 13064 `"Tepetitlan"', add
label define munimxlbl 13065 `"Tetepango"', add
label define munimxlbl 13066 `"Villa de Tezontepec"', add
label define munimxlbl 13067 `"Tezontepec de Aldama"', add
label define munimxlbl 13068 `"Tianguistengo"', add
label define munimxlbl 13069 `"Tizayuca"', add
label define munimxlbl 13070 `"Tlahuelilpan"', add
label define munimxlbl 13071 `"Tlahuiltepa"', add
label define munimxlbl 13072 `"Tlanalapa"', add
label define munimxlbl 13073 `"Tlanchinol"', add
label define munimxlbl 13074 `"Tlaxcoapan"', add
label define munimxlbl 13075 `"Tolcayuca"', add
label define munimxlbl 13076 `"Tula de Allende"', add
label define munimxlbl 13077 `"Tulancingo de Bravo"', add
label define munimxlbl 13078 `"Xochiatipan"', add
label define munimxlbl 13079 `"Xochicoatlan"', add
label define munimxlbl 13080 `"Yahualica"', add
label define munimxlbl 13081 `"Zacualtipan de Angeles"', add
label define munimxlbl 13082 `"Zapotlan de Juarez"', add
label define munimxlbl 13083 `"Zempoala"', add
label define munimxlbl 13084 `"Zimapan"', add
label define munimxlbl 14001 `"Acatic"', add
label define munimxlbl 14002 `"Acatlan de Juarez"', add
label define munimxlbl 14003 `"Ahualulco de Mercado"', add
label define munimxlbl 14004 `"Amacueca"', add
label define munimxlbl 14005 `"Amatitan"', add
label define munimxlbl 14006 `"Ameca"', add
label define munimxlbl 14007 `"San Juanito de Escobedo"', add
label define munimxlbl 14008 `"Arandas"', add
label define munimxlbl 14009 `"Arenal, El"', add
label define munimxlbl 14010 `"Atemajac de Brizuela"', add
label define munimxlbl 14011 `"Atengo"', add
label define munimxlbl 14012 `"Atenguillo"', add
label define munimxlbl 14013 `"Atotonilco el Alto"', add
label define munimxlbl 14014 `"Atoyac"', add
label define munimxlbl 14015 `"Autlan de Navarro"', add
label define munimxlbl 14016 `"Ayotlan"', add
label define munimxlbl 14017 `"Ayutla"', add
label define munimxlbl 14018 `"Barca, La"', add
label define munimxlbl 14019 `"Bolanos"', add
label define munimxlbl 14020 `"Cabo Corrientes"', add
label define munimxlbl 14021 `"Casimiro Castillo"', add
label define munimxlbl 14022 `"Cihuatlan"', add
label define munimxlbl 14023 `"Zapotlan el Grande"', add
label define munimxlbl 14024 `"Cocula"', add
label define munimxlbl 14025 `"Colotlan"', add
label define munimxlbl 14026 `"Concepcion de Buenos Aires"', add
label define munimxlbl 14027 `"Cuautitlan de Garcia Barragan"', add
label define munimxlbl 14028 `"Cuautla"', add
label define munimxlbl 14029 `"Cuquio"', add
label define munimxlbl 14030 `"Chapala"', add
label define munimxlbl 14031 `"Chimaltitan"', add
label define munimxlbl 14032 `"Chiquilistlan"', add
label define munimxlbl 14033 `"Degollado"', add
label define munimxlbl 14034 `"Ejutla"', add
label define munimxlbl 14035 `"Encarnacion de Diaz"', add
label define munimxlbl 14036 `"Etzatlan"', add
label define munimxlbl 14037 `"Grullo, El"', add
label define munimxlbl 14038 `"Guachinango"', add
label define munimxlbl 14039 `"Guadalajara"', add
label define munimxlbl 14040 `"Hostotipaquillo"', add
label define munimxlbl 14041 `"Huejucar"', add
label define munimxlbl 14042 `"Huejuquilla el Alto"', add
label define munimxlbl 14043 `"Huerta, La"', add
label define munimxlbl 14044 `"Ixtlahuacan de los Membrillos"', add
label define munimxlbl 14045 `"Ixtlahuacan del Rio"', add
label define munimxlbl 14046 `"Jalostotitlan"', add
label define munimxlbl 14047 `"Jamay"', add
label define munimxlbl 14048 `"Jesus Maria"', add
label define munimxlbl 14049 `"Jilotlan de los Dolores"', add
label define munimxlbl 14050 `"Jocotepec"', add
label define munimxlbl 14051 `"Juanacatlan"', add
label define munimxlbl 14052 `"Juchitlan"', add
label define munimxlbl 14053 `"Lagos de Moreno"', add
label define munimxlbl 14054 `"Limon, El"', add
label define munimxlbl 14055 `"Magdalena"', add
label define munimxlbl 14056 `"Santa Maria del Oro"', add
label define munimxlbl 14057 `"Manzanilla de la Paz, La"', add
label define munimxlbl 14058 `"Mascota"', add
label define munimxlbl 14059 `"Mazamitla"', add
label define munimxlbl 14060 `"Mexticacan"', add
label define munimxlbl 14061 `"Mezquitic"', add
label define munimxlbl 14062 `"Mixtlan"', add
label define munimxlbl 14063 `"Ocotlan"', add
label define munimxlbl 14064 `"Ojuelos de Jalisco"', add
label define munimxlbl 14065 `"Pihuamo"', add
label define munimxlbl 14066 `"Poncitlan"', add
label define munimxlbl 14067 `"Puerto Vallarta"', add
label define munimxlbl 14068 `"Villa Purificacion"', add
label define munimxlbl 14069 `"Quitupan"', add
label define munimxlbl 14070 `"Salto, El"', add
label define munimxlbl 14071 `"San Cristobal de la Barranca"', add
label define munimxlbl 14072 `"San Diego de Alejandria"', add
label define munimxlbl 14073 `"San Juan de los Lagos"', add
label define munimxlbl 14074 `"San Julian"', add
label define munimxlbl 14075 `"San Marcos"', add
label define munimxlbl 14076 `"San Martin de Bolanos"', add
label define munimxlbl 14077 `"San Martin de Hidalgo"', add
label define munimxlbl 14078 `"San Miguel el Alto"', add
label define munimxlbl 14079 `"Gomez Farias"', add
label define munimxlbl 14080 `"San Sebastian del Oeste"', add
label define munimxlbl 14081 `"Santa Maria de los Angeles"', add
label define munimxlbl 14082 `"Sayula"', add
label define munimxlbl 14083 `"Tala"', add
label define munimxlbl 14084 `"Talpa de Allende"', add
label define munimxlbl 14085 `"Tamazula de Gordiano"', add
label define munimxlbl 14086 `"Tapalpa"', add
label define munimxlbl 14087 `"Tecalitlan"', add
label define munimxlbl 14088 `"Tecolotlan"', add
label define munimxlbl 14089 `"Techaluta de Montenegro"', add
label define munimxlbl 14090 `"Tenamaxtlan"', add
label define munimxlbl 14091 `"Teocaltiche"', add
label define munimxlbl 14092 `"Teocuitatlan de Corona"', add
label define munimxlbl 14093 `"Tepatitlan de Morelos"', add
label define munimxlbl 14094 `"Tequila"', add
label define munimxlbl 14095 `"Teuchitlan"', add
label define munimxlbl 14096 `"Tizapan el Alto"', add
label define munimxlbl 14097 `"Tlajomulco de Zuniga"', add
label define munimxlbl 14098 `"Tlaquepaque"', add
label define munimxlbl 14099 `"Toliman"', add
label define munimxlbl 14100 `"Tomatlan"', add
label define munimxlbl 14101 `"Tonala"', add
label define munimxlbl 14102 `"Tonaya"', add
label define munimxlbl 14103 `"Tonila"', add
label define munimxlbl 14104 `"Totatiche"', add
label define munimxlbl 14105 `"Tototlan"', add
label define munimxlbl 14106 `"Tuxcacuesco"', add
label define munimxlbl 14107 `"Tuxcueca"', add
label define munimxlbl 14108 `"Tuxpan"', add
label define munimxlbl 14109 `"Union de San Antonio"', add
label define munimxlbl 14110 `"Union de Tula"', add
label define munimxlbl 14111 `"Valle de Guadalupe"', add
label define munimxlbl 14112 `"Valle de Juarez"', add
label define munimxlbl 14113 `"San Gabriel"', add
label define munimxlbl 14114 `"Villa Corona"', add
label define munimxlbl 14115 `"Villa Guerrero"', add
label define munimxlbl 14116 `"Villa Hidalgo"', add
label define munimxlbl 14117 `"Canadas de Obregon"', add
label define munimxlbl 14118 `"Yahualica de Gonzalez Gallo"', add
label define munimxlbl 14119 `"Zacoalco de Torres"', add
label define munimxlbl 14120 `"Zapopan"', add
label define munimxlbl 14121 `"Zapotiltic"', add
label define munimxlbl 14122 `"Zapotitlan de Vadillo"', add
label define munimxlbl 14123 `"Zapotlan del Rey"', add
label define munimxlbl 14124 `"Zapotlanejo"', add
label define munimxlbl 15001 `"Acambay"', add
label define munimxlbl 15002 `"Acolman"', add
label define munimxlbl 15003 `"Aculco"', add
label define munimxlbl 15004 `"Almoloya de Alquisiras"', add
label define munimxlbl 15005 `"Almoloya de Juarez"', add
label define munimxlbl 15006 `"Almoloya del Rio"', add
label define munimxlbl 15007 `"Amanalco"', add
label define munimxlbl 15008 `"Amatepec"', add
label define munimxlbl 15009 `"Amecameca"', add
label define munimxlbl 15010 `"Apaxco"', add
label define munimxlbl 15011 `"Atenco"', add
label define munimxlbl 15012 `"Atizapan"', add
label define munimxlbl 15013 `"Atizapan de Zaragoza"', add
label define munimxlbl 15014 `"Atlacomulco"', add
label define munimxlbl 15015 `"Atlautla"', add
label define munimxlbl 15016 `"Axapusco"', add
label define munimxlbl 15017 `"Ayapango"', add
label define munimxlbl 15018 `"Calimaya"', add
label define munimxlbl 15019 `"Capulhuac"', add
label define munimxlbl 15020 `"Coacalco de Berriozabal"', add
label define munimxlbl 15021 `"Coatepec Harinas"', add
label define munimxlbl 15022 `"Cocotitlan"', add
label define munimxlbl 15023 `"Coyotepec"', add
label define munimxlbl 15024 `"Cuautitlan"', add
label define munimxlbl 15025 `"Chalco"', add
label define munimxlbl 15026 `"Chapa de Mota"', add
label define munimxlbl 15027 `"Chapultepec"', add
label define munimxlbl 15028 `"Chiautla"', add
label define munimxlbl 15029 `"Chicoloapan"', add
label define munimxlbl 15030 `"Chiconcuac"', add
label define munimxlbl 15031 `"Chimalhuacan"', add
label define munimxlbl 15032 `"Donato Guerra"', add
label define munimxlbl 15033 `"Ecatepec de Morelos"', add
label define munimxlbl 15034 `"Ecatzingo"', add
label define munimxlbl 15035 `"Huehuetoca"', add
label define munimxlbl 15036 `"Hueypoxtla"', add
label define munimxlbl 15037 `"Huixquilucan"', add
label define munimxlbl 15038 `"Isidro Fabela"', add
label define munimxlbl 15039 `"Ixtapaluca"', add
label define munimxlbl 15040 `"Ixtapan de la Sal"', add
label define munimxlbl 15041 `"Ixtapan del Oro"', add
label define munimxlbl 15042 `"Ixtlahuaca"', add
label define munimxlbl 15043 `"Xalatlaco"', add
label define munimxlbl 15044 `"Jaltenco"', add
label define munimxlbl 15045 `"Jilotepec"', add
label define munimxlbl 15046 `"Jilotzingo"', add
label define munimxlbl 15047 `"Jiquipilco"', add
label define munimxlbl 15048 `"Jocotitlan"', add
label define munimxlbl 15049 `"Joquicingo"', add
label define munimxlbl 15050 `"Juchitepec"', add
label define munimxlbl 15051 `"Lerma"', add
label define munimxlbl 15052 `"Malinalco"', add
label define munimxlbl 15053 `"Melchor Ocampo"', add
label define munimxlbl 15054 `"Metepec"', add
label define munimxlbl 15055 `"Mexicaltzingo"', add
label define munimxlbl 15056 `"Morelos"', add
label define munimxlbl 15057 `"Naucalpan de Juarez"', add
label define munimxlbl 15058 `"Nezahualcoyotl"', add
label define munimxlbl 15059 `"Nextlalpan"', add
label define munimxlbl 15060 `"Nicolas Romero"', add
label define munimxlbl 15061 `"Nopaltepec"', add
label define munimxlbl 15062 `"Ocoyoacac"', add
label define munimxlbl 15063 `"Ocuilan"', add
label define munimxlbl 15064 `"Oro, El"', add
label define munimxlbl 15065 `"Otumba"', add
label define munimxlbl 15066 `"Otzoloapan"', add
label define munimxlbl 15067 `"Otzolotepec"', add
label define munimxlbl 15068 `"Ozumba"', add
label define munimxlbl 15069 `"Papalotla"', add
label define munimxlbl 15070 `"Paz, La"', add
label define munimxlbl 15071 `"Polotitlan"', add
label define munimxlbl 15072 `"Rayon"', add
label define munimxlbl 15073 `"San Antonio la Isla"', add
label define munimxlbl 15074 `"San Felipe del Progreso"', add
label define munimxlbl 15075 `"San Martin de las Piramides"', add
label define munimxlbl 15076 `"San Mateo Atenco"', add
label define munimxlbl 15077 `"San Simon de Guerrero"', add
label define munimxlbl 15078 `"Santo Tomas"', add
label define munimxlbl 15079 `"Soyaniquilpan de Juarez"', add
label define munimxlbl 15080 `"Sultepec"', add
label define munimxlbl 15081 `"Tecamac"', add
label define munimxlbl 15082 `"Tejupilco"', add
label define munimxlbl 15083 `"Temamatla"', add
label define munimxlbl 15084 `"Temascalapa"', add
label define munimxlbl 15085 `"Temascalcingo"', add
label define munimxlbl 15086 `"Temascaltepec"', add
label define munimxlbl 15087 `"Temoaya"', add
label define munimxlbl 15088 `"Tenancingo"', add
label define munimxlbl 15089 `"Tenango del Aire"', add
label define munimxlbl 15090 `"Tenango del Valle"', add
label define munimxlbl 15091 `"Teoloyucan"', add
label define munimxlbl 15092 `"Teotihuacan"', add
label define munimxlbl 15093 `"Tepetlaoxtoc"', add
label define munimxlbl 15094 `"Tepetlixpa"', add
label define munimxlbl 15095 `"Tepotzotlan"', add
label define munimxlbl 15096 `"Tequixquiac"', add
label define munimxlbl 15097 `"Texcaltitlan"', add
label define munimxlbl 15098 `"Texcalyacac"', add
label define munimxlbl 15099 `"Texcoco"', add
label define munimxlbl 15100 `"Tezoyuca"', add
label define munimxlbl 15101 `"Tianguistenco"', add
label define munimxlbl 15102 `"Timilpan"', add
label define munimxlbl 15103 `"Tlalmanalco"', add
label define munimxlbl 15104 `"Tlalnepantla de Baz"', add
label define munimxlbl 15105 `"Tlatlaya"', add
label define munimxlbl 15106 `"Toluca"', add
label define munimxlbl 15107 `"Tonatico"', add
label define munimxlbl 15108 `"Tultepec"', add
label define munimxlbl 15109 `"Tultitlan"', add
label define munimxlbl 15110 `"Valle de Bravo"', add
label define munimxlbl 15111 `"Villa de Allende"', add
label define munimxlbl 15112 `"Villa del Carbon"', add
label define munimxlbl 15113 `"Villa Guerrero"', add
label define munimxlbl 15114 `"Villa Victoria"', add
label define munimxlbl 15115 `"Xonacatlan"', add
label define munimxlbl 15116 `"Zacazonapan"', add
label define munimxlbl 15117 `"Zacualpan"', add
label define munimxlbl 15118 `"Zinacantepec"', add
label define munimxlbl 15119 `"Zumpahuacan"', add
label define munimxlbl 15120 `"Zumpango"', add
label define munimxlbl 15121 `"Cuautitlan Izcalli"', add
label define munimxlbl 15122 `"Valle de Chalco Solidaridad"', add
label define munimxlbl 15123 `"Luvianos"', add
label define munimxlbl 15124 `"San José del Rincón"', add
label define munimxlbl 15125 `"Tonanitla"', add
label define munimxlbl 16001 `"Acuitzio"', add
label define munimxlbl 16002 `"Aguililla"', add
label define munimxlbl 16003 `"Alvaro Obregon"', add
label define munimxlbl 16004 `"Angamacutiro"', add
label define munimxlbl 16005 `"Angangueo"', add
label define munimxlbl 16006 `"Apatzingan"', add
label define munimxlbl 16007 `"Aporo"', add
label define munimxlbl 16008 `"Aquila"', add
label define munimxlbl 16009 `"Ario"', add
label define munimxlbl 16010 `"Arteaga"', add
label define munimxlbl 16011 `"Brisenas"', add
label define munimxlbl 16012 `"Buenavista"', add
label define munimxlbl 16013 `"Caracuaro"', add
label define munimxlbl 16014 `"Coahuayana"', add
label define munimxlbl 16015 `"Coalcoman de Vazquez Pallares"', add
label define munimxlbl 16016 `"Coeneo"', add
label define munimxlbl 16017 `"Contepec"', add
label define munimxlbl 16018 `"Copandaro"', add
label define munimxlbl 16019 `"Cotija"', add
label define munimxlbl 16020 `"Cuitzeo"', add
label define munimxlbl 16021 `"Charapan"', add
label define munimxlbl 16022 `"Charo"', add
label define munimxlbl 16023 `"Chavinda"', add
label define munimxlbl 16024 `"Cheran"', add
label define munimxlbl 16025 `"Chilchota"', add
label define munimxlbl 16026 `"Chinicuila"', add
label define munimxlbl 16027 `"Chucandiro"', add
label define munimxlbl 16028 `"Churintzio"', add
label define munimxlbl 16029 `"Churumuco"', add
label define munimxlbl 16030 `"Ecuandureo"', add
label define munimxlbl 16031 `"Epitacio Huerta"', add
label define munimxlbl 16032 `"Erongaricuaro"', add
label define munimxlbl 16033 `"Gabriel Zamora"', add
label define munimxlbl 16034 `"Hidalgo"', add
label define munimxlbl 16035 `"Huacana, La"', add
label define munimxlbl 16036 `"Huandacareo"', add
label define munimxlbl 16037 `"Huaniqueo"', add
label define munimxlbl 16038 `"Huetamo"', add
label define munimxlbl 16039 `"Huiramba"', add
label define munimxlbl 16040 `"Indaparapeo"', add
label define munimxlbl 16041 `"Irimbo"', add
label define munimxlbl 16042 `"Ixtlan"', add
label define munimxlbl 16043 `"Jacona"', add
label define munimxlbl 16044 `"Jimenez"', add
label define munimxlbl 16045 `"Jiquilpan"', add
label define munimxlbl 16046 `"Juarez"', add
label define munimxlbl 16047 `"Jungapeo"', add
label define munimxlbl 16048 `"Lagunillas"', add
label define munimxlbl 16049 `"Madero"', add
label define munimxlbl 16050 `"Maravatio"', add
label define munimxlbl 16051 `"Marcos Castellanos"', add
label define munimxlbl 16052 `"Lazaro Cardenas"', add
label define munimxlbl 16053 `"Morelia"', add
label define munimxlbl 16054 `"Morelos"', add
label define munimxlbl 16055 `"Mugica"', add
label define munimxlbl 16056 `"Nahuatzen"', add
label define munimxlbl 16057 `"Nocupetaro"', add
label define munimxlbl 16058 `"Nuevo Parangaricutiro"', add
label define munimxlbl 16059 `"Nuevo Urecho"', add
label define munimxlbl 16060 `"Numaran"', add
label define munimxlbl 16061 `"Ocampo"', add
label define munimxlbl 16062 `"Pajacuaran"', add
label define munimxlbl 16063 `"Panindicuaro"', add
label define munimxlbl 16064 `"Paracuaro"', add
label define munimxlbl 16065 `"Paracho"', add
label define munimxlbl 16066 `"Patzcuaro"', add
label define munimxlbl 16067 `"Penjamillo"', add
label define munimxlbl 16068 `"Periban"', add
label define munimxlbl 16069 `"Piedad, La"', add
label define munimxlbl 16070 `"Purepero"', add
label define munimxlbl 16071 `"Puruandiro"', add
label define munimxlbl 16072 `"Querendaro"', add
label define munimxlbl 16073 `"Quiroga"', add
label define munimxlbl 16074 `"Cojumatlan de Regules"', add
label define munimxlbl 16075 `"Reyes, Los"', add
label define munimxlbl 16076 `"Sahuayo"', add
label define munimxlbl 16077 `"San Lucas"', add
label define munimxlbl 16078 `"Santa Ana Maya"', add
label define munimxlbl 16079 `"Salvador Escalante"', add
label define munimxlbl 16080 `"Senguio"', add
label define munimxlbl 16081 `"Susupuato"', add
label define munimxlbl 16082 `"Tacambaro"', add
label define munimxlbl 16083 `"Tancitaro"', add
label define munimxlbl 16084 `"Tangamandapio"', add
label define munimxlbl 16085 `"Tangancicuaro"', add
label define munimxlbl 16086 `"Tanhuato"', add
label define munimxlbl 16087 `"Taretan"', add
label define munimxlbl 16088 `"Tarimbaro"', add
label define munimxlbl 16089 `"Tepalcatepec"', add
label define munimxlbl 16090 `"Tingambato"', add
label define munimxlbl 16091 `"Tinguindin"', add
label define munimxlbl 16092 `"Tiquicheo de Nicolas Romero"', add
label define munimxlbl 16093 `"Tlalpujahua"', add
label define munimxlbl 16094 `"Tlazazalca"', add
label define munimxlbl 16095 `"Tocumbo"', add
label define munimxlbl 16096 `"Tumbiscatio"', add
label define munimxlbl 16097 `"Turicato"', add
label define munimxlbl 16098 `"Tuxpan"', add
label define munimxlbl 16099 `"Tuzantla"', add
label define munimxlbl 16100 `"Tzintzuntzan"', add
label define munimxlbl 16101 `"Tzitzio"', add
label define munimxlbl 16102 `"Uruapan"', add
label define munimxlbl 16103 `"Venustiano Carranza"', add
label define munimxlbl 16104 `"Villamar"', add
label define munimxlbl 16105 `"Vista Hermosa"', add
label define munimxlbl 16106 `"Yurecuaro"', add
label define munimxlbl 16107 `"Zacapu"', add
label define munimxlbl 16108 `"Zamora"', add
label define munimxlbl 16109 `"Zinaparo"', add
label define munimxlbl 16110 `"Zinapecuaro"', add
label define munimxlbl 16111 `"Ziracuaretiro"', add
label define munimxlbl 16112 `"Zitacuaro"', add
label define munimxlbl 16113 `"Jose Sixto Verduzco"', add
label define munimxlbl 17001 `"Amacuzac"', add
label define munimxlbl 17002 `"Atlatlahucan"', add
label define munimxlbl 17003 `"Axochiapan"', add
label define munimxlbl 17004 `"Ayala"', add
label define munimxlbl 17005 `"Coatlan del Rio"', add
label define munimxlbl 17006 `"Cuautla"', add
label define munimxlbl 17007 `"Cuernavaca"', add
label define munimxlbl 17008 `"Emiliano Zapata"', add
label define munimxlbl 17009 `"Huitzilac"', add
label define munimxlbl 17010 `"Jantetelco"', add
label define munimxlbl 17011 `"Jiutepec"', add
label define munimxlbl 17012 `"Jojutla"', add
label define munimxlbl 17013 `"Jonacatepec"', add
label define munimxlbl 17014 `"Mazatepec"', add
label define munimxlbl 17015 `"Miacatlan"', add
label define munimxlbl 17016 `"Ocuituco"', add
label define munimxlbl 17017 `"Puente de Ixtla"', add
label define munimxlbl 17018 `"Temixco"', add
label define munimxlbl 17019 `"Tepalcingo"', add
label define munimxlbl 17020 `"Tepoztlan"', add
label define munimxlbl 17021 `"Tetecala"', add
label define munimxlbl 17022 `"Tetela del Volcan"', add
label define munimxlbl 17023 `"Tlalnepantla"', add
label define munimxlbl 17024 `"Tlaltizapan"', add
label define munimxlbl 17025 `"Tlaquiltenango"', add
label define munimxlbl 17026 `"Tlayacapan"', add
label define munimxlbl 17027 `"Totolapan"', add
label define munimxlbl 17028 `"Xochitepec"', add
label define munimxlbl 17029 `"Yautepec"', add
label define munimxlbl 17030 `"Yecapixtla"', add
label define munimxlbl 17031 `"Zacatepec de Hidalgo"', add
label define munimxlbl 17032 `"Zacualpan de Amilpas"', add
label define munimxlbl 17033 `"Temoac"', add
label define munimxlbl 18001 `"Acaponeta"', add
label define munimxlbl 18002 `"Ahuacatlan"', add
label define munimxlbl 18003 `"Amatlan de Canas"', add
label define munimxlbl 18004 `"Compostela"', add
label define munimxlbl 18005 `"Huajicori"', add
label define munimxlbl 18006 `"Ixtlan del Rio"', add
label define munimxlbl 18007 `"Jala"', add
label define munimxlbl 18008 `"Xalisco"', add
label define munimxlbl 18009 `"Del Nayar"', add
label define munimxlbl 18010 `"Rosamorada"', add
label define munimxlbl 18011 `"Ruiz"', add
label define munimxlbl 18012 `"San Blas"', add
label define munimxlbl 18013 `"San Pedro Lagunillas"', add
label define munimxlbl 18014 `"Santa Maria del Oro"', add
label define munimxlbl 18015 `"Santiago Ixcuintla"', add
label define munimxlbl 18016 `"Tecuala"', add
label define munimxlbl 18017 `"Tepic"', add
label define munimxlbl 18018 `"Tuxpan"', add
label define munimxlbl 18019 `"Yesca, La"', add
label define munimxlbl 18020 `"Bahia de Banderas"', add
label define munimxlbl 19001 `"Abasolo"', add
label define munimxlbl 19002 `"Agualeguas"', add
label define munimxlbl 19003 `"Aldamas, Los"', add
label define munimxlbl 19004 `"Allende"', add
label define munimxlbl 19005 `"Anahuac"', add
label define munimxlbl 19006 `"Apodaca"', add
label define munimxlbl 19007 `"Aramberri"', add
label define munimxlbl 19008 `"Bustamante"', add
label define munimxlbl 19009 `"Cadereyta Jimenez"', add
label define munimxlbl 19010 `"Carmen"', add
label define munimxlbl 19011 `"Cerralvo"', add
label define munimxlbl 19012 `"Cienega de Flores"', add
label define munimxlbl 19013 `"China"', add
label define munimxlbl 19014 `"Doctor Arroyo"', add
label define munimxlbl 19015 `"Doctor Coss"', add
label define munimxlbl 19016 `"Doctor Gonzalez"', add
label define munimxlbl 19017 `"Galeana"', add
label define munimxlbl 19018 `"Garcia"', add
label define munimxlbl 19019 `"San Pedro Garza Garcia"', add
label define munimxlbl 19020 `"General Bravo"', add
label define munimxlbl 19021 `"General Escobedo"', add
label define munimxlbl 19022 `"General Teran"', add
label define munimxlbl 19023 `"General Trevino"', add
label define munimxlbl 19024 `"General Zaragoza"', add
label define munimxlbl 19025 `"General Zuazua"', add
label define munimxlbl 19026 `"Guadalupe"', add
label define munimxlbl 19027 `"Herreras, Los"', add
label define munimxlbl 19028 `"Higueras"', add
label define munimxlbl 19029 `"Hualahuises"', add
label define munimxlbl 19030 `"Iturbide"', add
label define munimxlbl 19031 `"Juarez"', add
label define munimxlbl 19032 `"Lampazos de Naranjo"', add
label define munimxlbl 19033 `"Linares"', add
label define munimxlbl 19034 `"Marin"', add
label define munimxlbl 19035 `"Melchor Ocampo"', add
label define munimxlbl 19036 `"Mier y Noriega"', add
label define munimxlbl 19037 `"Mina"', add
label define munimxlbl 19038 `"Montemorelos"', add
label define munimxlbl 19039 `"Monterrey"', add
label define munimxlbl 19040 `"Paras"', add
label define munimxlbl 19041 `"Pesqueria"', add
label define munimxlbl 19042 `"Ramones, Los"', add
label define munimxlbl 19043 `"Rayones"', add
label define munimxlbl 19044 `"Sabinas Hidalgo"', add
label define munimxlbl 19045 `"Salinas Victoria"', add
label define munimxlbl 19046 `"San Nicolas de los Garza"', add
label define munimxlbl 19047 `"Hidalgo"', add
label define munimxlbl 19048 `"Santa Catarina"', add
label define munimxlbl 19049 `"Santiago"', add
label define munimxlbl 19050 `"Vallecillo"', add
label define munimxlbl 19051 `"Villaldama"', add
label define munimxlbl 20001 `"Abejones"', add
label define munimxlbl 20002 `"Acatlan de Perez Figueroa"', add
label define munimxlbl 20003 `"Asuncion Cacalotepec"', add
label define munimxlbl 20004 `"Asuncion Cuyotepeji"', add
label define munimxlbl 20005 `"Asuncion Ixtaltepec"', add
label define munimxlbl 20006 `"Asuncion Nochixtlan"', add
label define munimxlbl 20007 `"Asuncion Ocotlan"', add
label define munimxlbl 20008 `"Asuncion Tlacolulita"', add
label define munimxlbl 20009 `"Ayotzintepec"', add
label define munimxlbl 20010 `"Barrio de la Soledad, El"', add
label define munimxlbl 20011 `"Calihuala"', add
label define munimxlbl 20012 `"Candelaria Loxicha"', add
label define munimxlbl 20013 `"Cienega de Zimatlan"', add
label define munimxlbl 20014 `"Ciudad Ixtepec"', add
label define munimxlbl 20015 `"Coatecas Altas"', add
label define munimxlbl 20016 `"Coicoyan de las Flores"', add
label define munimxlbl 20017 `"Compania, La"', add
label define munimxlbl 20018 `"Concepcion Buenavista"', add
label define munimxlbl 20019 `"Concepcion Papalo"', add
label define munimxlbl 20020 `"Constancia del Rosario"', add
label define munimxlbl 20021 `"Cosolapa"', add
label define munimxlbl 20022 `"Cosoltepec"', add
label define munimxlbl 20023 `"Cuilapam de Guerrero"', add
label define munimxlbl 20024 `"Cuyamecalco Villa de Zaragoza"', add
label define munimxlbl 20025 `"Chahuites"', add
label define munimxlbl 20026 `"Chalcatongo de Hidalgo"', add
label define munimxlbl 20027 `"Chiquihuitlan de Benito Juarez"', add
label define munimxlbl 20028 `"Heroica Ciudad de Ejutla de Crespo"', add
label define munimxlbl 20029 `"Eloxochitlan de Flores Magon"', add
label define munimxlbl 20030 `"Espinal, El"', add
label define munimxlbl 20031 `"Tamazulapam del Espiritu Santo"', add
label define munimxlbl 20032 `"Fresnillo de Trujano"', add
label define munimxlbl 20033 `"Guadalupe Etla"', add
label define munimxlbl 20034 `"Guadalupe de Ramirez"', add
label define munimxlbl 20035 `"Guelatao de Juarez"', add
label define munimxlbl 20036 `"Guevea de Humboldt"', add
label define munimxlbl 20037 `"Mesones Hidalgo"', add
label define munimxlbl 20038 `"Villa Hidalgo"', add
label define munimxlbl 20039 `"Heroica Ciudad de Huajuapan de Leon"', add
label define munimxlbl 20040 `"Huautepec"', add
label define munimxlbl 20041 `"Huautla de Jimenez"', add
label define munimxlbl 20042 `"Ixtlan de Juarez"', add
label define munimxlbl 20043 `"Juchitan de Zaragoza"', add
label define munimxlbl 20044 `"Loma Bonita"', add
label define munimxlbl 20045 `"Magdalena Apasco"', add
label define munimxlbl 20046 `"Magdalena Jaltepec"', add
label define munimxlbl 20047 `"Santa Magdalena Jicotlan"', add
label define munimxlbl 20048 `"Magdalena Mixtepec"', add
label define munimxlbl 20049 `"Magdalena Ocotlan"', add
label define munimxlbl 20050 `"Magdalena Penasco"', add
label define munimxlbl 20051 `"Magdalena Teitipac"', add
label define munimxlbl 20052 `"Magdalena Tequisistlan"', add
label define munimxlbl 20053 `"Magdalena Tlacotepec"', add
label define munimxlbl 20054 `"Magdalena Zahuatlan"', add
label define munimxlbl 20055 `"Mariscala de Juarez"', add
label define munimxlbl 20056 `"Martires de Tacubaya"', add
label define munimxlbl 20057 `"Matias Romero"', add
label define munimxlbl 20058 `"Mazatlan Villa de Flores"', add
label define munimxlbl 20059 `"Miahuatlan de Porfirio Diaz"', add
label define munimxlbl 20060 `"Mixistlan de la Reforma"', add
label define munimxlbl 20061 `"Monjas"', add
label define munimxlbl 20062 `"Natividad"', add
label define munimxlbl 20063 `"Nazareno Etla"', add
label define munimxlbl 20064 `"Nejapa de Madero"', add
label define munimxlbl 20065 `"Ixpantepec Nieves"', add
label define munimxlbl 20066 `"Santiago Niltepec"', add
label define munimxlbl 20067 `"Oaxaca de Juarez"', add
label define munimxlbl 20068 `"Ocotlan de Morelos"', add
label define munimxlbl 20069 `"Pe, La"', add
label define munimxlbl 20070 `"Pinotepa de Don Luis"', add
label define munimxlbl 20071 `"Pluma Hidalgo"', add
label define munimxlbl 20072 `"San Jose del Progreso"', add
label define munimxlbl 20073 `"Putla Villa de Guerrero"', add
label define munimxlbl 20074 `"Santa Catarina Quioquitani"', add
label define munimxlbl 20075 `"Reforma de Pineda"', add
label define munimxlbl 20076 `"Reforma, La"', add
label define munimxlbl 20077 `"Reyes Etla"', add
label define munimxlbl 20078 `"Rojas de Cuauhtemoc"', add
label define munimxlbl 20079 `"Salina Cruz"', add
label define munimxlbl 20080 `"San Agustin Amatengo"', add
label define munimxlbl 20081 `"San Agustin Atenango"', add
label define munimxlbl 20082 `"San Agustin Chayuco"', add
label define munimxlbl 20083 `"San Agustin de las Juntas"', add
label define munimxlbl 20084 `"San Agustin Etla"', add
label define munimxlbl 20085 `"San Agustin Loxicha"', add
label define munimxlbl 20086 `"San Agustin Tlacotepec"', add
label define munimxlbl 20087 `"San Agustin Yatareni"', add
label define munimxlbl 20088 `"San Andres Cabecera Nueva"', add
label define munimxlbl 20089 `"San Andres Dinicuiti"', add
label define munimxlbl 20090 `"San Andres Huaxpaltepec"', add
label define munimxlbl 20091 `"San Andres Huayapam"', add
label define munimxlbl 20092 `"San Andres Ixtlahuaca"', add
label define munimxlbl 20093 `"San Andres Lagunas"', add
label define munimxlbl 20094 `"San Andres Nuxino"', add
label define munimxlbl 20095 `"San Andres Paxtlan"', add
label define munimxlbl 20096 `"San Andres Sinaxtla"', add
label define munimxlbl 20097 `"San Andres Solaga"', add
label define munimxlbl 20098 `"San Andres Teotilalpam"', add
label define munimxlbl 20099 `"San Andres Tepetlapa"', add
label define munimxlbl 20100 `"San Andres Yaa"', add
label define munimxlbl 20101 `"San Andres Zabache"', add
label define munimxlbl 20102 `"San Andres Zautla"', add
label define munimxlbl 20103 `"San Antonino Castillo Velasco"', add
label define munimxlbl 20104 `"San Antonino el Alto"', add
label define munimxlbl 20105 `"San Antonino Monte Verde"', add
label define munimxlbl 20106 `"San Antonio Acutla"', add
label define munimxlbl 20107 `"San Antonio de la Cal"', add
label define munimxlbl 20108 `"San Antonio Huitepec"', add
label define munimxlbl 20109 `"San Antonio Nanahuatipam"', add
label define munimxlbl 20110 `"San Antonio Sinicahua"', add
label define munimxlbl 20111 `"San Antonio Tepetlapa"', add
label define munimxlbl 20112 `"San Baltazar Chichicapam"', add
label define munimxlbl 20113 `"San Baltazar Loxicha"', add
label define munimxlbl 20114 `"San Baltazar Yatzachi el Bajo"', add
label define munimxlbl 20115 `"San Bartolo Coyotepec"', add
label define munimxlbl 20116 `"San Bartolome Ayautla"', add
label define munimxlbl 20117 `"San Bartolome Loxicha"', add
label define munimxlbl 20118 `"San Bartolome Quialana"', add
label define munimxlbl 20119 `"San Bartolome Yucuane"', add
label define munimxlbl 20120 `"San Bartolome Zoogocho"', add
label define munimxlbl 20121 `"San Bartolo Soyaltepec"', add
label define munimxlbl 20122 `"San Bartolo Yautepec"', add
label define munimxlbl 20123 `"San Bernardo Mixtepec"', add
label define munimxlbl 20124 `"San Blas Atempa"', add
label define munimxlbl 20125 `"San Carlos Yautepec"', add
label define munimxlbl 20126 `"San Cristobal Amatlan"', add
label define munimxlbl 20127 `"San Cristobal Amoltepec"', add
label define munimxlbl 20128 `"San Cristobal Lachirioag"', add
label define munimxlbl 20129 `"San Cristobal Suchixtlahuaca"', add
label define munimxlbl 20130 `"San Dionisio del Mar"', add
label define munimxlbl 20131 `"San Dionisio Ocotepec"', add
label define munimxlbl 20132 `"San Dionisio Ocotlan"', add
label define munimxlbl 20133 `"San Esteban Atatlahuca"', add
label define munimxlbl 20134 `"San Felipe Jalapa de Diaz"', add
label define munimxlbl 20135 `"San Felipe Tejalapam"', add
label define munimxlbl 20136 `"San Felipe Usila"', add
label define munimxlbl 20137 `"San Francisco Cahuacua"', add
label define munimxlbl 20138 `"San Francisco Cajonos"', add
label define munimxlbl 20139 `"San Francisco Chapulapa"', add
label define munimxlbl 20140 `"San Francisco Chindua"', add
label define munimxlbl 20141 `"San Francisco del Mar"', add
label define munimxlbl 20142 `"San Francisco Huehuetlan"', add
label define munimxlbl 20143 `"San Francisco Ixhuatan"', add
label define munimxlbl 20144 `"San Francisco Jaltepetongo"', add
label define munimxlbl 20145 `"San Francisco Lachigolo"', add
label define munimxlbl 20146 `"San Francisco Logueche"', add
label define munimxlbl 20147 `"San Francisco Nuxano"', add
label define munimxlbl 20148 `"San Francisco Ozolotepec"', add
label define munimxlbl 20149 `"San Francisco Sola"', add
label define munimxlbl 20150 `"San Francisco Telixtlahuaca"', add
label define munimxlbl 20151 `"San Francisco Teopan"', add
label define munimxlbl 20152 `"San Francisco Tlapancingo"', add
label define munimxlbl 20153 `"San Gabriel Mixtepec"', add
label define munimxlbl 20154 `"San Ildefonso Amatlan"', add
label define munimxlbl 20155 `"San Ildefonso Sola"', add
label define munimxlbl 20156 `"San Ildefonso Villa Alta"', add
label define munimxlbl 20157 `"San Jacinto Amilpas"', add
label define munimxlbl 20158 `"San Jacinto Tlacotepec"', add
label define munimxlbl 20159 `"San Jeronimo Coatlan"', add
label define munimxlbl 20160 `"San Jeronimo Silacayoapilla"', add
label define munimxlbl 20161 `"San Jeronimo Sosola"', add
label define munimxlbl 20162 `"San Jeronimo Taviche"', add
label define munimxlbl 20163 `"San Jeronimo Tecoatl"', add
label define munimxlbl 20164 `"San Jorge Nuchita"', add
label define munimxlbl 20165 `"San Jose Ayuquila"', add
label define munimxlbl 20166 `"San Jose Chiltepec"', add
label define munimxlbl 20167 `"San Jose del Penasco"', add
label define munimxlbl 20168 `"San Jose Estancia Grande"', add
label define munimxlbl 20169 `"San Jose Independencia"', add
label define munimxlbl 20170 `"San Jose Lachiguiri"', add
label define munimxlbl 20171 `"San Jose Tenango"', add
label define munimxlbl 20172 `"San Juan Achiutla"', add
label define munimxlbl 20173 `"San Juan Atepec"', add
label define munimxlbl 20174 `"Animas Trujano"', add
label define munimxlbl 20175 `"San Juan Bautista Atatlahuca"', add
label define munimxlbl 20176 `"San Juan Bautista Coixtlahuaca"', add
label define munimxlbl 20177 `"San Juan Bautista Cuicatlan"', add
label define munimxlbl 20178 `"San Juan Bautista Guelache"', add
label define munimxlbl 20179 `"San Juan Bautista Jayacatlan"', add
label define munimxlbl 20180 `"San Juan Bautista lo de Soto"', add
label define munimxlbl 20181 `"San Juan Bautista Suchitepec"', add
label define munimxlbl 20182 `"San Juan Bautista Tlacoatzintepec"', add
label define munimxlbl 20183 `"San Juan Bautista Tlachichilco"', add
label define munimxlbl 20184 `"San Juan Bautista Tuxtepec"', add
label define munimxlbl 20185 `"San Juan Cacahuatepec"', add
label define munimxlbl 20186 `"San Juan Cieneguilla"', add
label define munimxlbl 20187 `"San Juan Coatzospam"', add
label define munimxlbl 20188 `"San Juan Colorado"', add
label define munimxlbl 20189 `"San Juan Comaltepec"', add
label define munimxlbl 20190 `"San Juan Cotzocon"', add
label define munimxlbl 20191 `"San Juan Chicomezuchil"', add
label define munimxlbl 20192 `"San Juan Chilateca"', add
label define munimxlbl 20193 `"San Juan del Estado"', add
label define munimxlbl 20194 `"San Juan del Rio"', add
label define munimxlbl 20195 `"San Juan Diuxi"', add
label define munimxlbl 20196 `"San Juan Evangelista Analco"', add
label define munimxlbl 20197 `"San Juan Guelavia"', add
label define munimxlbl 20198 `"San Juan Guichicovi"', add
label define munimxlbl 20199 `"San Juan Ihualtepec"', add
label define munimxlbl 20200 `"San Juan Juquila Mixes"', add
label define munimxlbl 20201 `"San Juan Juquila Vijanos"', add
label define munimxlbl 20202 `"San Juan Lachao"', add
label define munimxlbl 20203 `"San Juan Lachigalla"', add
label define munimxlbl 20204 `"San Juan Lajarcia"', add
label define munimxlbl 20205 `"San Juan Lalana"', add
label define munimxlbl 20206 `"San Juan de los Cues"', add
label define munimxlbl 20207 `"San Juan Mazatlan"', add
label define munimxlbl 20208 `"San Juan Mixtepec - distr. 08"', add
label define munimxlbl 20209 `"San Juan Mixtepec - distr. 26"', add
label define munimxlbl 20210 `"San Juan Numi"', add
label define munimxlbl 20211 `"San Juan Ozolotepec"', add
label define munimxlbl 20212 `"San Juan Petlapa"', add
label define munimxlbl 20213 `"San Juan Quiahije"', add
label define munimxlbl 20214 `"San Juan Quiotepec"', add
label define munimxlbl 20215 `"San Juan Sayultepec"', add
label define munimxlbl 20216 `"San Juan Tabaa"', add
label define munimxlbl 20217 `"San Juan Tamazola"', add
label define munimxlbl 20218 `"San Juan Teita"', add
label define munimxlbl 20219 `"San Juan Teitipac"', add
label define munimxlbl 20220 `"San Juan Tepeuxila"', add
label define munimxlbl 20221 `"San Juan Teposcolula"', add
label define munimxlbl 20222 `"San Juan Yaee"', add
label define munimxlbl 20223 `"San Juan Yatzona"', add
label define munimxlbl 20224 `"San Juan Yucuita"', add
label define munimxlbl 20225 `"San Lorenzo"', add
label define munimxlbl 20226 `"San Lorenzo Albarradas"', add
label define munimxlbl 20227 `"San Lorenzo Cacaotepec"', add
label define munimxlbl 20228 `"San Lorenzo Cuaunecuiltitla"', add
label define munimxlbl 20229 `"San Lorenzo Texmelucan"', add
label define munimxlbl 20230 `"San Lorenzo Victoria"', add
label define munimxlbl 20231 `"San Lucas Camotlan"', add
label define munimxlbl 20232 `"San Lucas Ojitlan"', add
label define munimxlbl 20233 `"San Lucas Quiavini"', add
label define munimxlbl 20234 `"San Lucas Zoquiapam"', add
label define munimxlbl 20235 `"San Luis Amatlan"', add
label define munimxlbl 20236 `"San Marcial Ozolotepec"', add
label define munimxlbl 20237 `"San Marcos Arteaga"', add
label define munimxlbl 20238 `"San Martin de los Cansecos"', add
label define munimxlbl 20239 `"San Martin Huamelulpam"', add
label define munimxlbl 20240 `"San Martin Itunyoso"', add
label define munimxlbl 20241 `"San Martin Lachila"', add
label define munimxlbl 20242 `"San Martin Peras"', add
label define munimxlbl 20243 `"San Martin Tilcajete"', add
label define munimxlbl 20244 `"San Martin Toxpalan"', add
label define munimxlbl 20245 `"San Martin Zacatepec"', add
label define munimxlbl 20246 `"San Mateo Cajonos"', add
label define munimxlbl 20247 `"Capulalpam de Mendez"', add
label define munimxlbl 20248 `"San Mateo del Mar"', add
label define munimxlbl 20249 `"San Mateo Yoloxochitlan"', add
label define munimxlbl 20250 `"San Mateo Etlatongo"', add
label define munimxlbl 20251 `"San Mateo Nejapam"', add
label define munimxlbl 20252 `"San Mateo Penasco"', add
label define munimxlbl 20253 `"San Mateo Pinas"', add
label define munimxlbl 20254 `"San Mateo Rio Hondo"', add
label define munimxlbl 20255 `"San Mateo Sindihui"', add
label define munimxlbl 20256 `"San Mateo Tlapiltepec"', add
label define munimxlbl 20257 `"San Melchor Betaza"', add
label define munimxlbl 20258 `"San Miguel Achiutla"', add
label define munimxlbl 20259 `"San Miguel Ahuehuetitlan"', add
label define munimxlbl 20260 `"San Miguel Aloapam"', add
label define munimxlbl 20261 `"San Miguel Amatitlan"', add
label define munimxlbl 20262 `"San Miguel Amatlan"', add
label define munimxlbl 20263 `"San Miguel Coatlan"', add
label define munimxlbl 20264 `"San Miguel Chicahua"', add
label define munimxlbl 20265 `"San Miguel Chimalapa"', add
label define munimxlbl 20266 `"San Miguel del Puerto"', add
label define munimxlbl 20267 `"San Miguel del Rio"', add
label define munimxlbl 20268 `"San Miguel Ejutla"', add
label define munimxlbl 20269 `"San Miguel el Grande"', add
label define munimxlbl 20270 `"San Miguel Huautla"', add
label define munimxlbl 20271 `"San Miguel Mixtepec"', add
label define munimxlbl 20272 `"San Miguel Panixtlahuaca"', add
label define munimxlbl 20273 `"San Miguel Peras"', add
label define munimxlbl 20274 `"San Miguel Piedras"', add
label define munimxlbl 20275 `"San Miguel Quetzaltepec"', add
label define munimxlbl 20276 `"San Miguel Santa Flor"', add
label define munimxlbl 20277 `"Villa Sola de Vega"', add
label define munimxlbl 20278 `"San Miguel Soyaltepec"', add
label define munimxlbl 20279 `"San Miguel Suchixtepec"', add
label define munimxlbl 20280 `"Villa Talea de Castro"', add
label define munimxlbl 20281 `"San Miguel Tecomatlan"', add
label define munimxlbl 20282 `"San Miguel Tenango"', add
label define munimxlbl 20283 `"San Miguel Tequixtepec"', add
label define munimxlbl 20284 `"San Miguel Tilquiapam"', add
label define munimxlbl 20285 `"San Miguel Tlacamama"', add
label define munimxlbl 20286 `"San Miguel Tlacotepec"', add
label define munimxlbl 20287 `"San Miguel Tulancingo"', add
label define munimxlbl 20288 `"San Miguel Yotao"', add
label define munimxlbl 20289 `"San Nicolas"', add
label define munimxlbl 20290 `"San Nicolas Hidalgo"', add
label define munimxlbl 20291 `"San Pablo Coatlan"', add
label define munimxlbl 20292 `"San Pablo Cuatro Venados"', add
label define munimxlbl 20293 `"San Pablo Etla"', add
label define munimxlbl 20294 `"San Pablo Huitzo"', add
label define munimxlbl 20295 `"San Pablo Huixtepec"', add
label define munimxlbl 20296 `"San Pablo Macuiltianguis"', add
label define munimxlbl 20297 `"San Pablo Tijaltepec"', add
label define munimxlbl 20298 `"San Pablo Villa de Mitla"', add
label define munimxlbl 20299 `"San Pablo Yaganiza"', add
label define munimxlbl 20300 `"San Pedro Amuzgos"', add
label define munimxlbl 20301 `"San Pedro Apostol"', add
label define munimxlbl 20302 `"San Pedro Atoyac"', add
label define munimxlbl 20303 `"San Pedro Cajonos"', add
label define munimxlbl 20304 `"San Pedro Coxcaltepec Cantaros"', add
label define munimxlbl 20305 `"San Pedro Comitancillo"', add
label define munimxlbl 20306 `"San Pedro el Alto"', add
label define munimxlbl 20307 `"San Pedro Huamelula"', add
label define munimxlbl 20308 `"San Pedro Huilotepec"', add
label define munimxlbl 20309 `"San Pedro Ixcatlan"', add
label define munimxlbl 20310 `"San Pedro Ixtlahuaca"', add
label define munimxlbl 20311 `"San Pedro Jaltepetongo"', add
label define munimxlbl 20312 `"San Pedro Jicayan"', add
label define munimxlbl 20313 `"San Pedro Jocotipac"', add
label define munimxlbl 20314 `"San Pedro Juchatengo"', add
label define munimxlbl 20315 `"San Pedro Martir"', add
label define munimxlbl 20316 `"San Pedro Martir Quiechapa"', add
label define munimxlbl 20317 `"San Pedro Martir Yucuxaco"', add
label define munimxlbl 20318 `"San Pedro Mixtepec - distr. 22"', add
label define munimxlbl 20319 `"San Pedro Mixtepec - distr. 26"', add
label define munimxlbl 20320 `"San Pedro Molinos"', add
label define munimxlbl 20321 `"San Pedro Nopala"', add
label define munimxlbl 20322 `"San Pedro Ocopetatillo"', add
label define munimxlbl 20323 `"San Pedro Ocotepec"', add
label define munimxlbl 20324 `"San Pedro Pochutla"', add
label define munimxlbl 20325 `"San Pedro Quiatoni"', add
label define munimxlbl 20326 `"San Pedro Sochiapam"', add
label define munimxlbl 20327 `"San Pedro Tapanatepec"', add
label define munimxlbl 20328 `"San Pedro Taviche"', add
label define munimxlbl 20329 `"San Pedro Teozacoalco"', add
label define munimxlbl 20330 `"San Pedro Teutila"', add
label define munimxlbl 20331 `"San Pedro Tidaa"', add
label define munimxlbl 20332 `"San Pedro Topiltepec"', add
label define munimxlbl 20333 `"San Pedro Totolapa"', add
label define munimxlbl 20334 `"Villa de Tututepec de Melchor Ocampo"', add
label define munimxlbl 20335 `"San Pedro Yaneri"', add
label define munimxlbl 20336 `"San Pedro Yolox"', add
label define munimxlbl 20337 `"San Pedro y San Pablo Ayutla"', add
label define munimxlbl 20338 `"Villa de Etla"', add
label define munimxlbl 20339 `"San Pedro y San Pablo Teposcolula"', add
label define munimxlbl 20340 `"San Pedro y San Pablo Tequixtepec"', add
label define munimxlbl 20341 `"San Pedro Yucunama"', add
label define munimxlbl 20342 `"San Raymundo Jalpan"', add
label define munimxlbl 20343 `"San Sebastian Abasolo"', add
label define munimxlbl 20344 `"San Sebastian Coatlan"', add
label define munimxlbl 20345 `"San Sebastian Ixcapa"', add
label define munimxlbl 20346 `"San Sebastian Nicananduta"', add
label define munimxlbl 20347 `"San Sebastian Rio Hondo"', add
label define munimxlbl 20348 `"San Sebastian Tecomaxtlahuaca"', add
label define munimxlbl 20349 `"San Sebastian Teitipac"', add
label define munimxlbl 20350 `"San Sebastian Tutla"', add
label define munimxlbl 20351 `"San Simon Almolongas"', add
label define munimxlbl 20352 `"San Simon Zahuatlan"', add
label define munimxlbl 20353 `"Santa Ana"', add
label define munimxlbl 20354 `"Santa Ana Ateixtlahuaca"', add
label define munimxlbl 20355 `"Santa Ana Cuauhtemoc"', add
label define munimxlbl 20356 `"Santa Ana del Valle"', add
label define munimxlbl 20357 `"Santa Ana Tavela"', add
label define munimxlbl 20358 `"Santa Ana Tlapacoyan"', add
label define munimxlbl 20359 `"Santa Ana Yareni"', add
label define munimxlbl 20360 `"Santa Ana Zegache"', add
label define munimxlbl 20361 `"Santa Catalina Quieri"', add
label define munimxlbl 20362 `"Santa Catarina Cuixtla"', add
label define munimxlbl 20363 `"Santa Catarina Ixtepeji"', add
label define munimxlbl 20364 `"Santa Catarina Juquila"', add
label define munimxlbl 20365 `"Santa Catarina Lachatao"', add
label define munimxlbl 20366 `"Santa Catarina Loxicha"', add
label define munimxlbl 20367 `"Santa Catarina Mechoacan"', add
label define munimxlbl 20368 `"Santa Catarina Minas"', add
label define munimxlbl 20369 `"Santa Catarina Quiane"', add
label define munimxlbl 20370 `"Santa Catarina Tayata"', add
label define munimxlbl 20371 `"Santa Catarina Ticua"', add
label define munimxlbl 20372 `"Santa Catarina Yosonotu"', add
label define munimxlbl 20373 `"Santa Catarina Zapoquila"', add
label define munimxlbl 20374 `"Santa Cruz Acatepec"', add
label define munimxlbl 20375 `"Santa Cruz Amilpas"', add
label define munimxlbl 20376 `"Santa Cruz de Bravo"', add
label define munimxlbl 20377 `"Santa Cruz Itundujia"', add
label define munimxlbl 20378 `"Santa Cruz Mixtepec"', add
label define munimxlbl 20379 `"Santa Cruz Nundaco"', add
label define munimxlbl 20380 `"Santa Cruz Papalutla"', add
label define munimxlbl 20381 `"Santa Cruz Tacache de Mina"', add
label define munimxlbl 20382 `"Santa Cruz Tacahua"', add
label define munimxlbl 20383 `"Santa Cruz Tayata"', add
label define munimxlbl 20384 `"Santa Cruz Xitla"', add
label define munimxlbl 20385 `"Santa Cruz Xoxocotlan"', add
label define munimxlbl 20386 `"Santa Cruz Zenzontepec"', add
label define munimxlbl 20387 `"Santa Gertrudis"', add
label define munimxlbl 20388 `"Santa Ines del Monte"', add
label define munimxlbl 20389 `"Santa Ines Yatzeche"', add
label define munimxlbl 20390 `"Santa Lucia del Camino"', add
label define munimxlbl 20391 `"Santa Lucia Miahuatlan"', add
label define munimxlbl 20392 `"Santa Lucia Monteverde"', add
label define munimxlbl 20393 `"Santa Lucia Ocotlan"', add
label define munimxlbl 20394 `"Santa Maria Alotepec"', add
label define munimxlbl 20395 `"Santa Maria Apazco"', add
label define munimxlbl 20396 `"Santa Maria la Asuncion"', add
label define munimxlbl 20397 `"Heroica Ciudad de Tlaxiaco"', add
label define munimxlbl 20398 `"Ayoquezco de Aldama"', add
label define munimxlbl 20399 `"Santa Maria Atzompa"', add
label define munimxlbl 20400 `"Santa Maria Camotlan"', add
label define munimxlbl 20401 `"Santa Maria Colotepec"', add
label define munimxlbl 20402 `"Santa Maria Cortijo"', add
label define munimxlbl 20403 `"Santa Maria Coyotepec"', add
label define munimxlbl 20404 `"Santa Maria Chachoapam"', add
label define munimxlbl 20405 `"Villa de Chilapa de Diaz"', add
label define munimxlbl 20406 `"Santa Maria Chilchotla"', add
label define munimxlbl 20407 `"Santa Maria Chimalapa"', add
label define munimxlbl 20408 `"Santa Maria del Rosario"', add
label define munimxlbl 20409 `"Santa Maria del Tule"', add
label define munimxlbl 20410 `"Santa Maria Ecatepec"', add
label define munimxlbl 20411 `"Santa Maria Guelace"', add
label define munimxlbl 20412 `"Santa Maria Guienagati"', add
label define munimxlbl 20413 `"Santa Maria Huatulco"', add
label define munimxlbl 20414 `"Santa Maria Huazolotitlan"', add
label define munimxlbl 20415 `"Santa Maria Ipalapa"', add
label define munimxlbl 20416 `"Santa Maria Ixcatlan"', add
label define munimxlbl 20417 `"Santa Maria Jacatepec"', add
label define munimxlbl 20418 `"Santa Maria Jalapa del Marques"', add
label define munimxlbl 20419 `"Santa Maria Jaltianguis"', add
label define munimxlbl 20420 `"Santa Maria Lachixio"', add
label define munimxlbl 20421 `"Santa Maria Mixtequilla"', add
label define munimxlbl 20422 `"Santa Maria Nativitas"', add
label define munimxlbl 20423 `"Santa Maria Nduayaco"', add
label define munimxlbl 20424 `"Santa Maria Ozolotepec"', add
label define munimxlbl 20425 `"Santa Maria Papalo"', add
label define munimxlbl 20426 `"Santa Maria Penoles"', add
label define munimxlbl 20427 `"Santa Maria Petapa"', add
label define munimxlbl 20428 `"Santa Maria Quiegolani"', add
label define munimxlbl 20429 `"Santa Maria Sola"', add
label define munimxlbl 20430 `"Santa Maria Tataltepec"', add
label define munimxlbl 20431 `"Santa Maria Tecomavaca"', add
label define munimxlbl 20432 `"Santa Maria Temaxcalapa"', add
label define munimxlbl 20433 `"Santa Maria Temaxcaltepec"', add
label define munimxlbl 20434 `"Santa Maria Teopoxco"', add
label define munimxlbl 20435 `"Santa Maria Tepantlali"', add
label define munimxlbl 20436 `"Santa Maria Texcatitlan"', add
label define munimxlbl 20437 `"Santa Maria Tlahuitoltepec"', add
label define munimxlbl 20438 `"Santa Maria Tlalixtac"', add
label define munimxlbl 20439 `"Santa Maria Tonameca"', add
label define munimxlbl 20440 `"Santa Maria Totolapilla"', add
label define munimxlbl 20441 `"Santa Maria Xadani"', add
label define munimxlbl 20442 `"Santa Maria Yalina"', add
label define munimxlbl 20443 `"Santa Maria Yavesia"', add
label define munimxlbl 20444 `"Santa Maria Yolotepec"', add
label define munimxlbl 20445 `"Santa Maria Yosoyua"', add
label define munimxlbl 20446 `"Santa Maria Yucuhiti"', add
label define munimxlbl 20447 `"Santa Maria Zacatepec"', add
label define munimxlbl 20448 `"Santa Maria Zaniza"', add
label define munimxlbl 20449 `"Santa Maria Zoquitlan"', add
label define munimxlbl 20450 `"Santiago Amoltepec"', add
label define munimxlbl 20451 `"Santiago Apoala"', add
label define munimxlbl 20452 `"Santiago Apostol"', add
label define munimxlbl 20453 `"Santiago Astata"', add
label define munimxlbl 20454 `"Santiago Atitlan"', add
label define munimxlbl 20455 `"Santiago Ayuquililla"', add
label define munimxlbl 20456 `"Santiago Cacaloxtepec"', add
label define munimxlbl 20457 `"Santiago Camotlan"', add
label define munimxlbl 20458 `"Santiago Comaltepec"', add
label define munimxlbl 20459 `"Santiago Chazumba"', add
label define munimxlbl 20460 `"Santiago Choapam"', add
label define munimxlbl 20461 `"Santiago del Rio"', add
label define munimxlbl 20462 `"Santiago Huajolotitlan"', add
label define munimxlbl 20463 `"Santiago Huauclilla"', add
label define munimxlbl 20464 `"Santiago Ihuitlan Plumas"', add
label define munimxlbl 20465 `"Santiago Ixcuintepec"', add
label define munimxlbl 20466 `"Santiago Ixtayutla"', add
label define munimxlbl 20467 `"Santiago Jamiltepec"', add
label define munimxlbl 20468 `"Santiago Jocotepec"', add
label define munimxlbl 20469 `"Santiago Juxtlahuaca"', add
label define munimxlbl 20470 `"Santiago Lachiguiri"', add
label define munimxlbl 20471 `"Santiago Lalopa"', add
label define munimxlbl 20472 `"Santiago Laollaga"', add
label define munimxlbl 20473 `"Santiago Laxopa"', add
label define munimxlbl 20474 `"Santiago Llano Grande"', add
label define munimxlbl 20475 `"Santiago Matatlan"', add
label define munimxlbl 20476 `"Santiago Miltepec"', add
label define munimxlbl 20477 `"Santiago Minas"', add
label define munimxlbl 20478 `"Santiago Nacaltepec"', add
label define munimxlbl 20479 `"Santiago Nejapilla"', add
label define munimxlbl 20480 `"Santiago Nundiche"', add
label define munimxlbl 20481 `"Santiago Nuyoo"', add
label define munimxlbl 20482 `"Santiago Pinotepa Nacional"', add
label define munimxlbl 20483 `"Santiago Suchilquitongo"', add
label define munimxlbl 20484 `"Santiago Tamazola"', add
label define munimxlbl 20485 `"Santiago Tapextla"', add
label define munimxlbl 20486 `"Villa Tejupam de la Union"', add
label define munimxlbl 20487 `"Santiago Tenango"', add
label define munimxlbl 20488 `"Santiago Tepetlapa"', add
label define munimxlbl 20489 `"Santiago Tetepec"', add
label define munimxlbl 20490 `"Santiago Texcalcingo"', add
label define munimxlbl 20491 `"Santiago Textitlan"', add
label define munimxlbl 20492 `"Santiago Tilantongo"', add
label define munimxlbl 20493 `"Santiago Tillo"', add
label define munimxlbl 20494 `"Santiago Tlazoyaltepec"', add
label define munimxlbl 20495 `"Santiago Xanica"', add
label define munimxlbl 20496 `"Santiago Xiacui"', add
label define munimxlbl 20497 `"Santiago Yaitepec"', add
label define munimxlbl 20498 `"Santiago Yaveo"', add
label define munimxlbl 20499 `"Santiago Yolomecatl"', add
label define munimxlbl 20500 `"Santiago Yosondua"', add
label define munimxlbl 20501 `"Santiago Yucuyachi"', add
label define munimxlbl 20502 `"Santiago Zacatepec"', add
label define munimxlbl 20503 `"Santiago Zoochila"', add
label define munimxlbl 20504 `"Nuevo Zoquiapam"', add
label define munimxlbl 20505 `"Santo Domingo Ingenio"', add
label define munimxlbl 20506 `"Santo Domingo Albarradas"', add
label define munimxlbl 20507 `"Santo Domingo Armenta"', add
label define munimxlbl 20508 `"Santo Domingo Chihuitan"', add
label define munimxlbl 20509 `"Santo Domingo de Morelos"', add
label define munimxlbl 20510 `"Santo Domingo Ixcatlan"', add
label define munimxlbl 20511 `"Santo Domingo Nuxaa"', add
label define munimxlbl 20512 `"Santo Domingo Ozolotepec"', add
label define munimxlbl 20513 `"Santo Domingo Petapa"', add
label define munimxlbl 20514 `"Santo Domingo Roayaga"', add
label define munimxlbl 20515 `"Santo Domingo Tehuantepec"', add
label define munimxlbl 20516 `"Santo Domingo Teojomulco"', add
label define munimxlbl 20517 `"Santo Domingo Tepuxtepec"', add
label define munimxlbl 20518 `"Santo Domingo Tlatayapam"', add
label define munimxlbl 20519 `"Santo Domingo Tomaltepec"', add
label define munimxlbl 20520 `"Santo Domingo Tonala"', add
label define munimxlbl 20521 `"Santo Domingo Tonaltepec"', add
label define munimxlbl 20522 `"Santo Domingo Xagacia"', add
label define munimxlbl 20523 `"Santo Domingo Yanhuitlan"', add
label define munimxlbl 20524 `"Santo Domingo Yodohino"', add
label define munimxlbl 20525 `"Santo Domingo Zanatepec"', add
label define munimxlbl 20526 `"Santos Reyes Nopala"', add
label define munimxlbl 20527 `"Santos Reyes papalo"', add
label define munimxlbl 20528 `"Santos Reyes Tepejillo"', add
label define munimxlbl 20529 `"Santos Reyes Yucuna"', add
label define munimxlbl 20530 `"Santo Tomas Jalieza"', add
label define munimxlbl 20531 `"Santo Tomas Mazaltepec"', add
label define munimxlbl 20532 `"Santo Tomas Ocotepec"', add
label define munimxlbl 20533 `"Santo Tomas Tamazulapan"', add
label define munimxlbl 20534 `"San Vicente Coatlan"', add
label define munimxlbl 20535 `"San Vicente Lachixio"', add
label define munimxlbl 20536 `"San Vicente Nunu"', add
label define munimxlbl 20537 `"Silacayoapam"', add
label define munimxlbl 20538 `"Sitio de Xitlapehua"', add
label define munimxlbl 20539 `"Soledad Etla"', add
label define munimxlbl 20540 `"Villa de Tamazulapam del Progreso"', add
label define munimxlbl 20541 `"Tanetze de Zaragoza"', add
label define munimxlbl 20542 `"Taniche"', add
label define munimxlbl 20543 `"Tataltepec de Valdes"', add
label define munimxlbl 20544 `"Teococuilco de Marcos Perez"', add
label define munimxlbl 20545 `"Teotitlan de Flores Magon"', add
label define munimxlbl 20546 `"Teotitlan del Valle"', add
label define munimxlbl 20547 `"Teotongo"', add
label define munimxlbl 20548 `"Tepelmeme Villa de Morelos"', add
label define munimxlbl 20549 `"Tezoatlan de Segura y Luna"', add
label define munimxlbl 20550 `"San Jeronimo Tlacochahuaya"', add
label define munimxlbl 20551 `"Tlacolula de Matamoros"', add
label define munimxlbl 20552 `"Tlacotepec Plumas"', add
label define munimxlbl 20553 `"Tlalixtac de Cabrera"', add
label define munimxlbl 20554 `"Totontepec Villa de Morelos"', add
label define munimxlbl 20555 `"Trinidad Zaachila"', add
label define munimxlbl 20556 `"Trinidad Vista Hermosa, La"', add
label define munimxlbl 20557 `"Union Hidalgo"', add
label define munimxlbl 20558 `"Valerio Trujano"', add
label define munimxlbl 20559 `"San Juan Bautista Valle Nacional"', add
label define munimxlbl 20560 `"Villa Diaz Ordaz"', add
label define munimxlbl 20561 `"Yaxe"', add
label define munimxlbl 20562 `"Magdalena Yodocono de Porfirio Diaz"', add
label define munimxlbl 20563 `"Yogana"', add
label define munimxlbl 20564 `"Yutanduchi de Guerrero"', add
label define munimxlbl 20565 `"Villa de Zaachila"', add
label define munimxlbl 20566 `"Zapotitlan del Rio"', add
label define munimxlbl 20567 `"Zapotitlan Lagunas"', add
label define munimxlbl 20568 `"Zapotitlan Palmas"', add
label define munimxlbl 20569 `"Santa ines de Zaragoza"', add
label define munimxlbl 20570 `"Zimatlan de Alvarez"', add
label define munimxlbl 21001 `"Acajete"', add
label define munimxlbl 21002 `"Acateno"', add
label define munimxlbl 21003 `"Acatlan"', add
label define munimxlbl 21004 `"Acatzingo"', add
label define munimxlbl 21005 `"Acteopan"', add
label define munimxlbl 21006 `"Ahuacatlan"', add
label define munimxlbl 21007 `"Ahuatlan"', add
label define munimxlbl 21008 `"Ahuazotepec"', add
label define munimxlbl 21009 `"Ahuehuetitla"', add
label define munimxlbl 21010 `"Ajalpan"', add
label define munimxlbl 21011 `"Albino Zertuche"', add
label define munimxlbl 21012 `"Aljojuca"', add
label define munimxlbl 21013 `"Altepexi"', add
label define munimxlbl 21014 `"Amixtlan"', add
label define munimxlbl 21015 `"Amozoc"', add
label define munimxlbl 21016 `"Aquixtla"', add
label define munimxlbl 21017 `"Atempan"', add
label define munimxlbl 21018 `"Atexcal"', add
label define munimxlbl 21019 `"Atlixco"', add
label define munimxlbl 21020 `"Atoyatempan"', add
label define munimxlbl 21021 `"Atzala"', add
label define munimxlbl 21022 `"Atzitzihuacan"', add
label define munimxlbl 21023 `"Atzitzintla"', add
label define munimxlbl 21024 `"Axutla"', add
label define munimxlbl 21025 `"Ayotoxco de Guerrero"', add
label define munimxlbl 21026 `"Calpan"', add
label define munimxlbl 21027 `"Caltepec"', add
label define munimxlbl 21028 `"Camocuautla"', add
label define munimxlbl 21029 `"Caxhuacan"', add
label define munimxlbl 21030 `"Coatepec"', add
label define munimxlbl 21031 `"Coatzingo"', add
label define munimxlbl 21032 `"Cohetzala"', add
label define munimxlbl 21033 `"Cohuecan"', add
label define munimxlbl 21034 `"Coronango"', add
label define munimxlbl 21035 `"Coxcatlan"', add
label define munimxlbl 21036 `"Coyomeapan"', add
label define munimxlbl 21037 `"Coyotepec"', add
label define munimxlbl 21038 `"Cuapiaxtla de Madero"', add
label define munimxlbl 21039 `"Cuautempan"', add
label define munimxlbl 21040 `"Cuautinchan"', add
label define munimxlbl 21041 `"Cuautlancingo"', add
label define munimxlbl 21042 `"Cuayuca de Andrade"', add
label define munimxlbl 21043 `"Cuetzalan del Progreso"', add
label define munimxlbl 21044 `"Cuyoaco"', add
label define munimxlbl 21045 `"Chalchicomula de Sesma"', add
label define munimxlbl 21046 `"Chapulco"', add
label define munimxlbl 21047 `"Chiautla"', add
label define munimxlbl 21048 `"Chiautzingo"', add
label define munimxlbl 21049 `"Chiconcuautla"', add
label define munimxlbl 21050 `"Chichiquila"', add
label define munimxlbl 21051 `"Chietla"', add
label define munimxlbl 21052 `"Chigmecatitlan"', add
label define munimxlbl 21053 `"Chignahuapan"', add
label define munimxlbl 21054 `"Chignautla"', add
label define munimxlbl 21055 `"Chila"', add
label define munimxlbl 21056 `"Chila de la Sal"', add
label define munimxlbl 21057 `"Honey"', add
label define munimxlbl 21058 `"Chilchotla"', add
label define munimxlbl 21059 `"Chinantla"', add
label define munimxlbl 21060 `"Domingo Arenas"', add
label define munimxlbl 21061 `"Eloxochitlan"', add
label define munimxlbl 21062 `"Epatlan"', add
label define munimxlbl 21063 `"Esperanza"', add
label define munimxlbl 21064 `"Francisco Z. Mena"', add
label define munimxlbl 21065 `"General Felipe Angeles"', add
label define munimxlbl 21066 `"Guadalupe"', add
label define munimxlbl 21067 `"Guadalupe Victoria"', add
label define munimxlbl 21068 `"Hermenegildo Galeana"', add
label define munimxlbl 21069 `"Huaquechula"', add
label define munimxlbl 21070 `"Huatlatlauca"', add
label define munimxlbl 21071 `"Huauchinango"', add
label define munimxlbl 21072 `"Huehuetla"', add
label define munimxlbl 21073 `"Huehuetlan el Chico"', add
label define munimxlbl 21074 `"Huejotzingo"', add
label define munimxlbl 21075 `"Hueyapan"', add
label define munimxlbl 21076 `"Hueytamalco"', add
label define munimxlbl 21077 `"Hueytlalpan"', add
label define munimxlbl 21078 `"Huitzilan de Serdan"', add
label define munimxlbl 21079 `"Huitziltepec"', add
label define munimxlbl 21080 `"Atlequizayan"', add
label define munimxlbl 21081 `"Ixcamilpa de Guerrero"', add
label define munimxlbl 21082 `"Ixcaquixtla"', add
label define munimxlbl 21083 `"Ixtacamaxtitlan"', add
label define munimxlbl 21084 `"Ixtepec"', add
label define munimxlbl 21085 `"Izucar de Matamoros"', add
label define munimxlbl 21086 `"Jalpan"', add
label define munimxlbl 21087 `"Jolalpan"', add
label define munimxlbl 21088 `"Jonotla"', add
label define munimxlbl 21089 `"Jopala"', add
label define munimxlbl 21090 `"Juan C. Bonilla"', add
label define munimxlbl 21091 `"Juan Galindo"', add
label define munimxlbl 21092 `"Juan N. Mendez"', add
label define munimxlbl 21093 `"Lafragua"', add
label define munimxlbl 21094 `"Libres"', add
label define munimxlbl 21095 `"Magdalena Tlatlauquitepec, La"', add
label define munimxlbl 21096 `"Mazapiltepec de Juarez"', add
label define munimxlbl 21097 `"Mixtla"', add
label define munimxlbl 21098 `"Molcaxac"', add
label define munimxlbl 21099 `"Canada Morelos"', add
label define munimxlbl 21100 `"Naupan"', add
label define munimxlbl 21101 `"Nauzontla"', add
label define munimxlbl 21102 `"Nealtican"', add
label define munimxlbl 21103 `"Nicolas Bravo"', add
label define munimxlbl 21104 `"Nopalucan"', add
label define munimxlbl 21105 `"Ocotepec"', add
label define munimxlbl 21106 `"Ocoyucan"', add
label define munimxlbl 21107 `"Olintla"', add
label define munimxlbl 21108 `"Oriental"', add
label define munimxlbl 21109 `"Pahuatlan"', add
label define munimxlbl 21110 `"Palmar de Bravo"', add
label define munimxlbl 21111 `"Pantepec"', add
label define munimxlbl 21112 `"Petlalcingo"', add
label define munimxlbl 21113 `"Piaxtla"', add
label define munimxlbl 21114 `"Puebla"', add
label define munimxlbl 21115 `"Quecholac"', add
label define munimxlbl 21116 `"Quimixtlan"', add
label define munimxlbl 21117 `"Rafael Lara Grajales"', add
label define munimxlbl 21118 `"Reyes de Juarez, Los"', add
label define munimxlbl 21119 `"San Andres Cholula"', add
label define munimxlbl 21120 `"San Antonio Canada"', add
label define munimxlbl 21121 `"San Diego la Mesa Tochimiltzingo"', add
label define munimxlbl 21122 `"San Felipe Teotlalcingo"', add
label define munimxlbl 21123 `"San Felipe Tepatlan"', add
label define munimxlbl 21124 `"San Gabriel Chilac"', add
label define munimxlbl 21125 `"San Gregorio Atzompa"', add
label define munimxlbl 21126 `"San Jeronimo Tecuanipan"', add
label define munimxlbl 21127 `"San Jeronimo Xayacatlan"', add
label define munimxlbl 21128 `"San Jose Chiapa"', add
label define munimxlbl 21129 `"San Jose Miahuatlan"', add
label define munimxlbl 21130 `"San Juan Atenco"', add
label define munimxlbl 21131 `"San Juan Atzompa"', add
label define munimxlbl 21132 `"San Martin Texmelucan"', add
label define munimxlbl 21133 `"San Martin Totoltepec"', add
label define munimxlbl 21134 `"San Matias Tlalancaleca"', add
label define munimxlbl 21135 `"San Miguel Ixitlan"', add
label define munimxlbl 21136 `"San Miguel Xoxtla"', add
label define munimxlbl 21137 `"San Nicolas Buenos Aires"', add
label define munimxlbl 21138 `"San Nicolas de los Ranchos"', add
label define munimxlbl 21139 `"San Pablo Anicano"', add
label define munimxlbl 21140 `"San Pedro Cholula"', add
label define munimxlbl 21141 `"San Pedro Yeloixtlahuaca"', add
label define munimxlbl 21142 `"San Salvador el Seco"', add
label define munimxlbl 21143 `"San Salvador el Verde"', add
label define munimxlbl 21144 `"San Salvador Huixcolotla"', add
label define munimxlbl 21145 `"San Sebastian Tlacotepec"', add
label define munimxlbl 21146 `"Santa Catarina Tlaltempan"', add
label define munimxlbl 21147 `"Santa Ines Ahuatempan"', add
label define munimxlbl 21148 `"Santa Isabel Cholula"', add
label define munimxlbl 21149 `"Santiago Miahuatlan"', add
label define munimxlbl 21150 `"Huehuetlan el Grande"', add
label define munimxlbl 21151 `"Santo Tomas Hueyotlipan"', add
label define munimxlbl 21152 `"Soltepec"', add
label define munimxlbl 21153 `"Tecali de Herrera"', add
label define munimxlbl 21154 `"Tecamachalco"', add
label define munimxlbl 21155 `"Tecomatlan"', add
label define munimxlbl 21156 `"Tehuacan"', add
label define munimxlbl 21157 `"Tehuitzingo"', add
label define munimxlbl 21158 `"Tenampulco"', add
label define munimxlbl 21159 `"Teopantlan"', add
label define munimxlbl 21160 `"Teotlalco"', add
label define munimxlbl 21161 `"Tepanco de Lopez"', add
label define munimxlbl 21162 `"Tepango de Rodriguez"', add
label define munimxlbl 21163 `"Tepatlaxco de Hidalgo"', add
label define munimxlbl 21164 `"Tepeaca"', add
label define munimxlbl 21165 `"Tepemaxalco"', add
label define munimxlbl 21166 `"Tepeojuma"', add
label define munimxlbl 21167 `"Tepetzintla"', add
label define munimxlbl 21168 `"Tepexco"', add
label define munimxlbl 21169 `"Tepexi de Rodriguez"', add
label define munimxlbl 21170 `"Tepeyahualco"', add
label define munimxlbl 21171 `"Tepeyahualco de Cuauhtemoc"', add
label define munimxlbl 21172 `"Tetela de Ocampo"', add
label define munimxlbl 21173 `"Teteles de Avila Castillo"', add
label define munimxlbl 21174 `"Teziutlan"', add
label define munimxlbl 21175 `"Tianguismanalco"', add
label define munimxlbl 21176 `"Tilapa"', add
label define munimxlbl 21177 `"Tlacotepec de Benito Juarez"', add
label define munimxlbl 21178 `"Tlacuilotepec"', add
label define munimxlbl 21179 `"Tlachichuca"', add
label define munimxlbl 21180 `"Tlahuapan"', add
label define munimxlbl 21181 `"Tlaltenango"', add
label define munimxlbl 21182 `"Tlanepantla"', add
label define munimxlbl 21183 `"Tlaola"', add
label define munimxlbl 21184 `"Tlapacoya"', add
label define munimxlbl 21185 `"Tlapanala"', add
label define munimxlbl 21186 `"Tlatlauquitepec"', add
label define munimxlbl 21187 `"Tlaxco"', add
label define munimxlbl 21188 `"Tochimilco"', add
label define munimxlbl 21189 `"Tochtepec"', add
label define munimxlbl 21190 `"Totoltepec de Guerrero"', add
label define munimxlbl 21191 `"Tulcingo"', add
label define munimxlbl 21192 `"Tuzamapan de Galeana"', add
label define munimxlbl 21193 `"Tzicatlacoyan"', add
label define munimxlbl 21194 `"Venustiano Carranza"', add
label define munimxlbl 21195 `"Vicente Guerrero"', add
label define munimxlbl 21196 `"Xayacatlan de Bravo"', add
label define munimxlbl 21197 `"Xicotepec"', add
label define munimxlbl 21198 `"Xicotlan"', add
label define munimxlbl 21199 `"Xiutetelco"', add
label define munimxlbl 21200 `"Xochiapulco"', add
label define munimxlbl 21201 `"Xochiltepec"', add
label define munimxlbl 21202 `"Xochitlan de Vicente Suarez"', add
label define munimxlbl 21203 `"Xochitlan Todos Santos"', add
label define munimxlbl 21204 `"Yaonahuac"', add
label define munimxlbl 21205 `"Yehualtepec"', add
label define munimxlbl 21206 `"Zacapala"', add
label define munimxlbl 21207 `"Zacapoaxtla"', add
label define munimxlbl 21208 `"Zacatlan"', add
label define munimxlbl 21209 `"Zapotitlan"', add
label define munimxlbl 21210 `"Zapotitlan de Mendez"', add
label define munimxlbl 21211 `"Zaragoza"', add
label define munimxlbl 21212 `"Zautla"', add
label define munimxlbl 21213 `"Zihuateutla"', add
label define munimxlbl 21214 `"Zinacatepec"', add
label define munimxlbl 21215 `"Zongozotla"', add
label define munimxlbl 21216 `"Zoquiapan"', add
label define munimxlbl 21217 `"Zoquitlan"', add
label define munimxlbl 22001 `"Amealco de Bonfil"', add
label define munimxlbl 22002 `"Pinal de Amoles"', add
label define munimxlbl 22003 `"Arroyo Seco"', add
label define munimxlbl 22004 `"Cadereyta de Montes"', add
label define munimxlbl 22005 `"Colon"', add
label define munimxlbl 22006 `"Corregidora"', add
label define munimxlbl 22007 `"Ezequiel Montes"', add
label define munimxlbl 22008 `"Huimilpan"', add
label define munimxlbl 22009 `"Jalpan de Serra"', add
label define munimxlbl 22010 `"Landa de Matamoros"', add
label define munimxlbl 22011 `"Marques, El"', add
label define munimxlbl 22012 `"Pedro Escobedo"', add
label define munimxlbl 22013 `"Penamiller"', add
label define munimxlbl 22014 `"Queretaro"', add
label define munimxlbl 22015 `"San Joaquin"', add
label define munimxlbl 22016 `"San Juan del Rio"', add
label define munimxlbl 22017 `"Tequisquiapan"', add
label define munimxlbl 22018 `"Toliman"', add
label define munimxlbl 23001 `"Cozumel"', add
label define munimxlbl 23002 `"Felipe Carrillo Puerto"', add
label define munimxlbl 23003 `"Isla Mujeres"', add
label define munimxlbl 23004 `"Othon p. Blanco"', add
label define munimxlbl 23005 `"Benito Juarez"', add
label define munimxlbl 23006 `"Jose Maria Morelos"', add
label define munimxlbl 23007 `"Lazaro Cardenas"', add
label define munimxlbl 23008 `"Solidaridad"', add
label define munimxlbl 24001 `"Ahualulco"', add
label define munimxlbl 24002 `"Alaquines"', add
label define munimxlbl 24003 `"Aquismon"', add
label define munimxlbl 24004 `"Armadillo de los Infante"', add
label define munimxlbl 24005 `"Cardenas"', add
label define munimxlbl 24006 `"Catorce"', add
label define munimxlbl 24007 `"Cedral"', add
label define munimxlbl 24008 `"Cerritos"', add
label define munimxlbl 24009 `"Cerro de San Pedro"', add
label define munimxlbl 24010 `"Ciudad del Maiz"', add
label define munimxlbl 24011 `"Ciudad Fernandez"', add
label define munimxlbl 24012 `"Tancanhuitz de Santos"', add
label define munimxlbl 24013 `"Ciudad Valles"', add
label define munimxlbl 24014 `"Coxcatlan"', add
label define munimxlbl 24015 `"Charcas"', add
label define munimxlbl 24016 `"Ebano"', add
label define munimxlbl 24017 `"Guadalcazar"', add
label define munimxlbl 24018 `"Huehuetlan"', add
label define munimxlbl 24019 `"Lagunillas"', add
label define munimxlbl 24020 `"Matehuala"', add
label define munimxlbl 24021 `"Mexquitic de Carmona"', add
label define munimxlbl 24022 `"Moctezuma"', add
label define munimxlbl 24023 `"Rayon"', add
label define munimxlbl 24024 `"Rioverde"', add
label define munimxlbl 24025 `"Salinas"', add
label define munimxlbl 24026 `"San Antonio"', add
label define munimxlbl 24027 `"San Ciro de Acosta"', add
label define munimxlbl 24028 `"San Luis Potosi"', add
label define munimxlbl 24029 `"San Martin Chalchicuautla"', add
label define munimxlbl 24030 `"San Nicolas Tolentino"', add
label define munimxlbl 24031 `"Santa Catarina"', add
label define munimxlbl 24032 `"Santa Maria del Rio"', add
label define munimxlbl 24033 `"Santo Domingo"', add
label define munimxlbl 24034 `"San Vicente Tancuayalab"', add
label define munimxlbl 24035 `"Soledad de Graciano Sanchez"', add
label define munimxlbl 24036 `"Tamasopo"', add
label define munimxlbl 24037 `"Tamazunchale"', add
label define munimxlbl 24038 `"Tampacan"', add
label define munimxlbl 24039 `"Tampamolon Corona"', add
label define munimxlbl 24040 `"Tamuin"', add
label define munimxlbl 24041 `"Tanlajas"', add
label define munimxlbl 24042 `"Tanquian de Escobedo"', add
label define munimxlbl 24043 `"Tierra Nueva"', add
label define munimxlbl 24044 `"Vanegas"', add
label define munimxlbl 24045 `"Venado"', add
label define munimxlbl 24046 `"Villa de Arriaga"', add
label define munimxlbl 24047 `"Villa de Guadalupe"', add
label define munimxlbl 24048 `"Villa de la Paz"', add
label define munimxlbl 24049 `"Villa de Ramos"', add
label define munimxlbl 24050 `"Villa de Reyes"', add
label define munimxlbl 24051 `"Villa Hidalgo"', add
label define munimxlbl 24052 `"Villa Juarez"', add
label define munimxlbl 24053 `"Axtla de Terrazas"', add
label define munimxlbl 24054 `"Xilitla"', add
label define munimxlbl 24055 `"Zaragoza"', add
label define munimxlbl 24056 `"Villa de Arista"', add
label define munimxlbl 24057 `"Matlapa"', add
label define munimxlbl 24058 `"Naranjo, El"', add
label define munimxlbl 25001 `"Ahome"', add
label define munimxlbl 25002 `"Angostura"', add
label define munimxlbl 25003 `"Badiraguato"', add
label define munimxlbl 25004 `"Concordia"', add
label define munimxlbl 25005 `"Cosala"', add
label define munimxlbl 25006 `"Culiacan"', add
label define munimxlbl 25007 `"Choix"', add
label define munimxlbl 25008 `"Elota"', add
label define munimxlbl 25009 `"Escuinapa"', add
label define munimxlbl 25010 `"Fuerte, El"', add
label define munimxlbl 25011 `"Guasave"', add
label define munimxlbl 25012 `"Mazatlan"', add
label define munimxlbl 25013 `"Mocorito"', add
label define munimxlbl 25014 `"Rosario"', add
label define munimxlbl 25015 `"Salvador Alvarado"', add
label define munimxlbl 25016 `"San Ignacio"', add
label define munimxlbl 25017 `"Sinaloa"', add
label define munimxlbl 25018 `"Navolato"', add
label define munimxlbl 26001 `"Aconchi"', add
label define munimxlbl 26002 `"Agua prieta"', add
label define munimxlbl 26003 `"Alamos"', add
label define munimxlbl 26004 `"Altar"', add
label define munimxlbl 26005 `"Arivechi"', add
label define munimxlbl 26006 `"Arizpe"', add
label define munimxlbl 26007 `"Atil"', add
label define munimxlbl 26008 `"Bacadehuachi"', add
label define munimxlbl 26009 `"Bacanora"', add
label define munimxlbl 26010 `"Bacerac"', add
label define munimxlbl 26011 `"Bacoachi"', add
label define munimxlbl 26012 `"Bacum"', add
label define munimxlbl 26013 `"Banamichi"', add
label define munimxlbl 26014 `"Baviacora"', add
label define munimxlbl 26015 `"Bavispe"', add
label define munimxlbl 26016 `"Benjamin Hill"', add
label define munimxlbl 26017 `"Caborca"', add
label define munimxlbl 26018 `"Cajeme"', add
label define munimxlbl 26019 `"Cananea"', add
label define munimxlbl 26020 `"Carbo"', add
label define munimxlbl 26021 `"Colorada, La"', add
label define munimxlbl 26022 `"Cucurpe"', add
label define munimxlbl 26023 `"Cumpas"', add
label define munimxlbl 26024 `"Divisaderos"', add
label define munimxlbl 26025 `"Empalme"', add
label define munimxlbl 26026 `"Etchojoa"', add
label define munimxlbl 26027 `"Fronteras"', add
label define munimxlbl 26028 `"Granados"', add
label define munimxlbl 26029 `"Guaymas"', add
label define munimxlbl 26030 `"Hermosillo"', add
label define munimxlbl 26031 `"Huachinera"', add
label define munimxlbl 26032 `"Huasabas"', add
label define munimxlbl 26033 `"Huatabampo"', add
label define munimxlbl 26034 `"Huepac"', add
label define munimxlbl 26035 `"Imuris"', add
label define munimxlbl 26036 `"Magdalena"', add
label define munimxlbl 26037 `"Mazatan"', add
label define munimxlbl 26038 `"Moctezuma"', add
label define munimxlbl 26039 `"Naco"', add
label define munimxlbl 26040 `"Nacori Chico"', add
label define munimxlbl 26041 `"Nacozari de Garcia"', add
label define munimxlbl 26042 `"Navojoa"', add
label define munimxlbl 26043 `"Nogales"', add
label define munimxlbl 26044 `"Onavas"', add
label define munimxlbl 26045 `"Opodepe"', add
label define munimxlbl 26046 `"Oquitoa"', add
label define munimxlbl 26047 `"Pitiquito"', add
label define munimxlbl 26048 `"Puerto Penasco"', add
label define munimxlbl 26049 `"Quiriego"', add
label define munimxlbl 26050 `"Rayon"', add
label define munimxlbl 26051 `"Rosario"', add
label define munimxlbl 26052 `"Sahuaripa"', add
label define munimxlbl 26053 `"San Felipe de Jesus"', add
label define munimxlbl 26054 `"San javier"', add
label define munimxlbl 26055 `"San Luis Rio Colorado"', add
label define munimxlbl 26056 `"San Miguel de Horcasitas"', add
label define munimxlbl 26057 `"San Pedro de la Cueva"', add
label define munimxlbl 26058 `"Santa Ana"', add
label define munimxlbl 26059 `"Santa Cruz"', add
label define munimxlbl 26060 `"Saric"', add
label define munimxlbl 26061 `"Soyopa"', add
label define munimxlbl 26062 `"Suaqui Grande"', add
label define munimxlbl 26063 `"Tepache"', add
label define munimxlbl 26064 `"Trincheras"', add
label define munimxlbl 26065 `"Tubutama"', add
label define munimxlbl 26066 `"Ures"', add
label define munimxlbl 26067 `"Villa Hidalgo"', add
label define munimxlbl 26068 `"Villa Pesqueira"', add
label define munimxlbl 26069 `"Yecora"', add
label define munimxlbl 26070 `"General Plutarco Elias Calles"', add
label define munimxlbl 26071 `"Benito Juarez"', add
label define munimxlbl 26072 `"San Ignacio Rio Muerto"', add
label define munimxlbl 27001 `"Balancan"', add
label define munimxlbl 27002 `"Cardenas"', add
label define munimxlbl 27003 `"Centla"', add
label define munimxlbl 27004 `"Centro"', add
label define munimxlbl 27005 `"Comalcalco"', add
label define munimxlbl 27006 `"Cunduacan"', add
label define munimxlbl 27007 `"Emiliano Zapata"', add
label define munimxlbl 27008 `"Huimanguillo"', add
label define munimxlbl 27009 `"Jalapa"', add
label define munimxlbl 27010 `"Jalpa de Mendez"', add
label define munimxlbl 27011 `"Jonuta"', add
label define munimxlbl 27012 `"Macuspana"', add
label define munimxlbl 27013 `"Nacajuca"', add
label define munimxlbl 27014 `"Paraiso"', add
label define munimxlbl 27015 `"Tacotalpa"', add
label define munimxlbl 27016 `"Teapa"', add
label define munimxlbl 27017 `"Tenosique"', add
label define munimxlbl 28001 `"Abasolo"', add
label define munimxlbl 28002 `"Aldama"', add
label define munimxlbl 28003 `"Altamira"', add
label define munimxlbl 28004 `"Antiguo Morelos"', add
label define munimxlbl 28005 `"Burgos"', add
label define munimxlbl 28006 `"Bustamante"', add
label define munimxlbl 28007 `"Camargo"', add
label define munimxlbl 28008 `"Casas"', add
label define munimxlbl 28009 `"Ciudad Madero"', add
label define munimxlbl 28010 `"Cruillas"', add
label define munimxlbl 28011 `"Gomez Farias"', add
label define munimxlbl 28012 `"Gonzalez"', add
label define munimxlbl 28013 `"Guemez"', add
label define munimxlbl 28014 `"Guerrero"', add
label define munimxlbl 28015 `"Gustavo Diaz Ordaz"', add
label define munimxlbl 28016 `"Hidalgo"', add
label define munimxlbl 28017 `"Jaumave"', add
label define munimxlbl 28018 `"Jimenez"', add
label define munimxlbl 28019 `"Llera"', add
label define munimxlbl 28020 `"Mainero"', add
label define munimxlbl 28021 `"Mante, El"', add
label define munimxlbl 28022 `"Matamoros"', add
label define munimxlbl 28023 `"Mendez"', add
label define munimxlbl 28024 `"Mier"', add
label define munimxlbl 28025 `"Miguel Aleman"', add
label define munimxlbl 28026 `"Miquihuana"', add
label define munimxlbl 28027 `"Nuevo Laredo"', add
label define munimxlbl 28028 `"Nuevo Morelos"', add
label define munimxlbl 28029 `"Ocampo"', add
label define munimxlbl 28030 `"Padilla"', add
label define munimxlbl 28031 `"Palmillas"', add
label define munimxlbl 28032 `"Reynosa"', add
label define munimxlbl 28033 `"Rio Bravo"', add
label define munimxlbl 28034 `"San Carlos"', add
label define munimxlbl 28035 `"San Fernando"', add
label define munimxlbl 28036 `"San Nicolas"', add
label define munimxlbl 28037 `"Soto la Marina"', add
label define munimxlbl 28038 `"Tampico"', add
label define munimxlbl 28039 `"Tula"', add
label define munimxlbl 28040 `"Valle Hermoso"', add
label define munimxlbl 28041 `"Victoria"', add
label define munimxlbl 28042 `"Villagran"', add
label define munimxlbl 28043 `"Xicotencatl"', add
label define munimxlbl 29001 `"Amaxac de Guerrero"', add
label define munimxlbl 29002 `"Apetatitlan de Antonio Carvajal"', add
label define munimxlbl 29003 `"Atlangatepec"', add
label define munimxlbl 29004 `"Altzayanca"', add
label define munimxlbl 29005 `"Apizaco"', add
label define munimxlbl 29006 `"Calpulalpan"', add
label define munimxlbl 29007 `"Carmen Tequexquitla, El"', add
label define munimxlbl 29008 `"Cuapiaxtla"', add
label define munimxlbl 29009 `"Cuaxomulco"', add
label define munimxlbl 29010 `"Chiautempan"', add
label define munimxlbl 29011 `"Munoz de Domingo Arenas"', add
label define munimxlbl 29012 `"Espanita"', add
label define munimxlbl 29013 `"Huamantla"', add
label define munimxlbl 29014 `"Hueyotlipan"', add
label define munimxlbl 29015 `"Ixtacuixtla de Mariano Matamoros"', add
label define munimxlbl 29016 `"Ixtenco"', add
label define munimxlbl 29017 `"Mazatecochco de Jose Maria Morelos"', add
label define munimxlbl 29018 `"Contla de Juan cuamatzi"', add
label define munimxlbl 29019 `"Tepetitla de Lardizabal"', add
label define munimxlbl 29020 `"Sanctorum de Lazaro Cardenas"', add
label define munimxlbl 29021 `"Nanacamilpa de Mariano Arista"', add
label define munimxlbl 29022 `"Acuamanala de Miguel Hidalgo"', add
label define munimxlbl 29023 `"Nativitas"', add
label define munimxlbl 29024 `"Panotla"', add
label define munimxlbl 29025 `"San Pablo del Monte"', add
label define munimxlbl 29026 `"Santa Cruz Tlaxcala"', add
label define munimxlbl 29027 `"Tenancingo"', add
label define munimxlbl 29028 `"Teolocholco"', add
label define munimxlbl 29029 `"Tepeyanco"', add
label define munimxlbl 29030 `"Terrenate"', add
label define munimxlbl 29031 `"Tetla de la Solidaridad"', add
label define munimxlbl 29032 `"Tetlatlahuca"', add
label define munimxlbl 29033 `"Tlaxcala"', add
label define munimxlbl 29034 `"Tlaxco"', add
label define munimxlbl 29035 `"Tocatlan"', add
label define munimxlbl 29036 `"Totolac"', add
label define munimxlbl 29037 `"Zitlaltepec de Trinidad Sanchez Santos"', add
label define munimxlbl 29038 `"Tzompantepec"', add
label define munimxlbl 29039 `"Xaloztoc"', add
label define munimxlbl 29040 `"Xaltocan"', add
label define munimxlbl 29041 `"Papalotla de Xicohtencatl"', add
label define munimxlbl 29042 `"Xicohtzinco"', add
label define munimxlbl 29043 `"Yauhquemecan"', add
label define munimxlbl 29044 `"Zacatelco"', add
label define munimxlbl 29045 `"Benito Juarez"', add
label define munimxlbl 29046 `"Emiliano Zapata"', add
label define munimxlbl 29047 `"Lazaro Cardenas"', add
label define munimxlbl 29048 `"Magdalena Tlaltelulco, La"', add
label define munimxlbl 29049 `"San Damian Texoloc"', add
label define munimxlbl 29050 `"San Francisco Tetlanohcan"', add
label define munimxlbl 29051 `"San Jeronimo Zacualpan"', add
label define munimxlbl 29052 `"San Jose Teacalco"', add
label define munimxlbl 29053 `"San Juan Huactzinco"', add
label define munimxlbl 29054 `"San Lorenzo Axocomanitla"', add
label define munimxlbl 29055 `"San Lucas Tecopilco"', add
label define munimxlbl 29056 `"Santa Ana Nopalucan"', add
label define munimxlbl 29057 `"Santa Apolonia Teacalco"', add
label define munimxlbl 29058 `"Santa Catarina Ayometla"', add
label define munimxlbl 29059 `"Santa Cruz Quilehtla"', add
label define munimxlbl 29060 `"Santa Isabel Xiloxoxtla"', add
label define munimxlbl 30001 `"Acajete"', add
label define munimxlbl 30002 `"Acatlan"', add
label define munimxlbl 30003 `"Acayucan"', add
label define munimxlbl 30004 `"Actopan"', add
label define munimxlbl 30005 `"Acula"', add
label define munimxlbl 30006 `"Acultzingo"', add
label define munimxlbl 30007 `"Camaron de Tejeda"', add
label define munimxlbl 30008 `"Alpatlahuac"', add
label define munimxlbl 30009 `"Alto Lucero de Gutierrez Barrios"', add
label define munimxlbl 30010 `"Altotonga"', add
label define munimxlbl 30011 `"Alvarado"', add
label define munimxlbl 30012 `"Amatitlan"', add
label define munimxlbl 30013 `"Naranjos Amatlan"', add
label define munimxlbl 30014 `"Amatlan de los Reyes"', add
label define munimxlbl 30015 `"Angel R. Cabada"', add
label define munimxlbl 30016 `"Antigua, La"', add
label define munimxlbl 30017 `"Apazapan"', add
label define munimxlbl 30018 `"Aquila"', add
label define munimxlbl 30019 `"Astacinga"', add
label define munimxlbl 30020 `"Atlahuilco"', add
label define munimxlbl 30021 `"Atoyac"', add
label define munimxlbl 30022 `"Atzacan"', add
label define munimxlbl 30023 `"Atzalan"', add
label define munimxlbl 30024 `"Tlaltetela"', add
label define munimxlbl 30025 `"Ayahualulco"', add
label define munimxlbl 30026 `"Banderilla"', add
label define munimxlbl 30027 `"Benito Juarez"', add
label define munimxlbl 30028 `"Boca del Rio"', add
label define munimxlbl 30029 `"Calcahualco"', add
label define munimxlbl 30030 `"Camerino Z. Mendoza"', add
label define munimxlbl 30031 `"Carrillo Puerto"', add
label define munimxlbl 30032 `"Catemaco"', add
label define munimxlbl 30033 `"Cazones"', add
label define munimxlbl 30034 `"Cerro azul"', add
label define munimxlbl 30035 `"Citlaltepetl"', add
label define munimxlbl 30036 `"Coacoatzintla"', add
label define munimxlbl 30037 `"Coahuitlan"', add
label define munimxlbl 30038 `"Coatepec"', add
label define munimxlbl 30039 `"Coatzacoalcos"', add
label define munimxlbl 30040 `"Coatzintla"', add
label define munimxlbl 30041 `"Coetzala"', add
label define munimxlbl 30042 `"Colipa"', add
label define munimxlbl 30043 `"Comapa"', add
label define munimxlbl 30044 `"Cordoba"', add
label define munimxlbl 30045 `"Cosamaloapan de Carpio"', add
label define munimxlbl 30046 `"Cosautlan de Carvajal"', add
label define munimxlbl 30047 `"Coscomatepec"', add
label define munimxlbl 30048 `"Cosoleacaque"', add
label define munimxlbl 30049 `"Cotaxtla"', add
label define munimxlbl 30050 `"Coxquihui"', add
label define munimxlbl 30051 `"Coyutla"', add
label define munimxlbl 30052 `"Cuichapa"', add
label define munimxlbl 30053 `"Cuitlahuac"', add
label define munimxlbl 30054 `"Chacaltianguis"', add
label define munimxlbl 30055 `"Chalma"', add
label define munimxlbl 30056 `"Chiconamel"', add
label define munimxlbl 30057 `"Chiconquiaco"', add
label define munimxlbl 30058 `"Chicontepec"', add
label define munimxlbl 30059 `"Chinameca"', add
label define munimxlbl 30060 `"Chinampa de Gorostiza"', add
label define munimxlbl 30061 `"Choapas, Las"', add
label define munimxlbl 30062 `"Chocaman"', add
label define munimxlbl 30063 `"Chontla"', add
label define munimxlbl 30064 `"Chumatlan"', add
label define munimxlbl 30065 `"Emiliano Zapata"', add
label define munimxlbl 30066 `"Espinal"', add
label define munimxlbl 30067 `"Filomeno Mata"', add
label define munimxlbl 30068 `"Fortin"', add
label define munimxlbl 30069 `"Gutierrez Zamora"', add
label define munimxlbl 30070 `"Hidalgotitlan"', add
label define munimxlbl 30071 `"Huatusco"', add
label define munimxlbl 30072 `"Huayacocotla"', add
label define munimxlbl 30073 `"Hueyapan de Ocampo"', add
label define munimxlbl 30074 `"Huiloapan"', add
label define munimxlbl 30075 `"Ignacio de la Llave"', add
label define munimxlbl 30076 `"Ilamatlan"', add
label define munimxlbl 30077 `"Isla"', add
label define munimxlbl 30078 `"Ixcatepec"', add
label define munimxlbl 30079 `"Ixhuacan de los Reyes"', add
label define munimxlbl 30080 `"Ixhuatlan del Cafe"', add
label define munimxlbl 30081 `"Ixhuatlancillo"', add
label define munimxlbl 30082 `"Ixhuatlan del Sureste"', add
label define munimxlbl 30083 `"Ixhuatlan de Madero"', add
label define munimxlbl 30084 `"Ixmatlahuacan"', add
label define munimxlbl 30085 `"Ixtaczoquitlan"', add
label define munimxlbl 30086 `"Jalacingo"', add
label define munimxlbl 30087 `"Xalapa"', add
label define munimxlbl 30088 `"Jalcomulco"', add
label define munimxlbl 30089 `"Jaltipan"', add
label define munimxlbl 30090 `"Jamapa"', add
label define munimxlbl 30091 `"Jesus Carranza"', add
label define munimxlbl 30092 `"Xico"', add
label define munimxlbl 30093 `"Jilotepec"', add
label define munimxlbl 30094 `"Juan Rodriguez Clara"', add
label define munimxlbl 30095 `"Juchique de Ferrer"', add
label define munimxlbl 30096 `"Landero y Coss"', add
label define munimxlbl 30097 `"Lerdo de Tejada"', add
label define munimxlbl 30098 `"Magdalena"', add
label define munimxlbl 30099 `"Maltrata"', add
label define munimxlbl 30100 `"Manlio Fabio Altamirano"', add
label define munimxlbl 30101 `"Mariano Escobedo"', add
label define munimxlbl 30102 `"Martinez de la Torre"', add
label define munimxlbl 30103 `"Mecatlan"', add
label define munimxlbl 30104 `"Mecayapan"', add
label define munimxlbl 30105 `"Medellin"', add
label define munimxlbl 30106 `"Miahuatlan"', add
label define munimxlbl 30107 `"Minas, Las"', add
label define munimxlbl 30108 `"Minatitlan"', add
label define munimxlbl 30109 `"Misantla"', add
label define munimxlbl 30110 `"Mixtla de Altamirano"', add
label define munimxlbl 30111 `"Moloacan"', add
label define munimxlbl 30112 `"Naolinco"', add
label define munimxlbl 30113 `"Naranjal"', add
label define munimxlbl 30114 `"Nautla"', add
label define munimxlbl 30115 `"Nogales"', add
label define munimxlbl 30116 `"Oluta"', add
label define munimxlbl 30117 `"Omealca"', add
label define munimxlbl 30118 `"Orizaba"', add
label define munimxlbl 30119 `"Otatitlan"', add
label define munimxlbl 30120 `"Oteapan"', add
label define munimxlbl 30121 `"Ozuluama de Mascarenas"', add
label define munimxlbl 30122 `"Pajapan"', add
label define munimxlbl 30123 `"Panuco"', add
label define munimxlbl 30124 `"Papantla"', add
label define munimxlbl 30125 `"Paso del Macho"', add
label define munimxlbl 30126 `"Paso de Ovejas"', add
label define munimxlbl 30127 `"Perla, La"', add
label define munimxlbl 30128 `"Perote"', add
label define munimxlbl 30129 `"Platon Sanchez"', add
label define munimxlbl 30130 `"Playa Vicente"', add
label define munimxlbl 30131 `"Poza Rica de Hidalgo"', add
label define munimxlbl 30132 `"Vigas de Ramirez, Las"', add
label define munimxlbl 30133 `"Pueblo Viejo"', add
label define munimxlbl 30134 `"Puente Nacional"', add
label define munimxlbl 30135 `"Rafael Delgado"', add
label define munimxlbl 30136 `"Rafael lucio"', add
label define munimxlbl 30137 `"Reyes, Los"', add
label define munimxlbl 30138 `"Rio Blanco"', add
label define munimxlbl 30139 `"Saltabarranca"', add
label define munimxlbl 30140 `"San Andres Tenejapan"', add
label define munimxlbl 30141 `"San Andres Tuxtla"', add
label define munimxlbl 30142 `"San Juan Evangelista"', add
label define munimxlbl 30143 `"Santiago Tuxtla"', add
label define munimxlbl 30144 `"Sayula de Aleman"', add
label define munimxlbl 30145 `"Soconusco"', add
label define munimxlbl 30146 `"Sochiapa"', add
label define munimxlbl 30147 `"Soledad Atzompa"', add
label define munimxlbl 30148 `"Soledad de Doblado"', add
label define munimxlbl 30149 `"Soteapan"', add
label define munimxlbl 30150 `"Tamalin"', add
label define munimxlbl 30151 `"Tamiahua"', add
label define munimxlbl 30152 `"Tampico Alto"', add
label define munimxlbl 30153 `"Tancoco"', add
label define munimxlbl 30154 `"Tantima"', add
label define munimxlbl 30155 `"Tantoyuca"', add
label define munimxlbl 30156 `"Tatatila"', add
label define munimxlbl 30157 `"Castillo de Teayo"', add
label define munimxlbl 30158 `"Tecolutla"', add
label define munimxlbl 30159 `"Tehuipango"', add
label define munimxlbl 30160 `"Temapache"', add
label define munimxlbl 30161 `"Tempoal"', add
label define munimxlbl 30162 `"Tenampa"', add
label define munimxlbl 30163 `"Tenochtitlan"', add
label define munimxlbl 30164 `"Teocelo"', add
label define munimxlbl 30165 `"Tepatlaxco"', add
label define munimxlbl 30166 `"Tepetlan"', add
label define munimxlbl 30167 `"Tepetzintla"', add
label define munimxlbl 30168 `"Tequila"', add
label define munimxlbl 30169 `"Jose Azueta"', add
label define munimxlbl 30170 `"Texcatepec"', add
label define munimxlbl 30171 `"Texhuacan"', add
label define munimxlbl 30172 `"Texistepec"', add
label define munimxlbl 30173 `"Tezonapa"', add
label define munimxlbl 30174 `"Tierra Blanca"', add
label define munimxlbl 30175 `"Tihuatlan"', add
label define munimxlbl 30176 `"Tlacojalpan"', add
label define munimxlbl 30177 `"Tlacolulan"', add
label define munimxlbl 30178 `"Tlacotalpan"', add
label define munimxlbl 30179 `"Tlacotepec de Mejia"', add
label define munimxlbl 30180 `"Tlachichilco"', add
label define munimxlbl 30181 `"Tlalixcoyan"', add
label define munimxlbl 30182 `"Tlalnelhuayocan"', add
label define munimxlbl 30183 `"Tlapacoyan"', add
label define munimxlbl 30184 `"Tlaquilpa"', add
label define munimxlbl 30185 `"Tlilapan"', add
label define munimxlbl 30186 `"Tomatlan"', add
label define munimxlbl 30187 `"Tonayan"', add
label define munimxlbl 30188 `"Totutla"', add
label define munimxlbl 30189 `"Tuxpam"', add
label define munimxlbl 30190 `"Tuxtilla"', add
label define munimxlbl 30191 `"Ursulo Galvan"', add
label define munimxlbl 30192 `"Vega de Alatorre"', add
label define munimxlbl 30193 `"Veracruz"', add
label define munimxlbl 30194 `"Villa Aldama"', add
label define munimxlbl 30195 `"Xoxocotla"', add
label define munimxlbl 30196 `"Yanga"', add
label define munimxlbl 30197 `"Yecuatla"', add
label define munimxlbl 30198 `"Zacualpan"', add
label define munimxlbl 30199 `"Zaragoza"', add
label define munimxlbl 30200 `"Zentla"', add
label define munimxlbl 30201 `"Zongolica"', add
label define munimxlbl 30202 `"Zontecomatlan de Lopez y Fuentes"', add
label define munimxlbl 30203 `"Zozocolco de Hidalgo"', add
label define munimxlbl 30204 `"Agua Dulce"', add
label define munimxlbl 30205 `"Higo, El"', add
label define munimxlbl 30206 `"Nanchital de Lazaro Cardenas del Rio"', add
label define munimxlbl 30207 `"Tres Valles"', add
label define munimxlbl 30208 `"Carlos A. Carrillo"', add
label define munimxlbl 30209 `"Tatahuicapan de Juarez"', add
label define munimxlbl 30210 `"Uxpanapa"', add
label define munimxlbl 30211 `"San Rafael"', add
label define munimxlbl 30212 `"Santiago Sochiapan"', add
label define munimxlbl 31001 `"Abala"', add
label define munimxlbl 31002 `"Acanceh"', add
label define munimxlbl 31003 `"Akil"', add
label define munimxlbl 31004 `"Baca"', add
label define munimxlbl 31005 `"Bokoba"', add
label define munimxlbl 31006 `"Buctzotz"', add
label define munimxlbl 31007 `"Cacalchen"', add
label define munimxlbl 31008 `"Calotmul"', add
label define munimxlbl 31009 `"Cansahcab"', add
label define munimxlbl 31010 `"Cantamayec"', add
label define munimxlbl 31011 `"Celestun"', add
label define munimxlbl 31012 `"Cenotillo"', add
label define munimxlbl 31013 `"Conkal"', add
label define munimxlbl 31014 `"Cuncunul"', add
label define munimxlbl 31015 `"Cuzama"', add
label define munimxlbl 31016 `"Chacsinkin"', add
label define munimxlbl 31017 `"Chankom"', add
label define munimxlbl 31018 `"Chapab"', add
label define munimxlbl 31019 `"Chemax"', add
label define munimxlbl 31020 `"Chicxulub Pueblo"', add
label define munimxlbl 31021 `"Chichimila"', add
label define munimxlbl 31022 `"Chikindzonot"', add
label define munimxlbl 31023 `"Chochola"', add
label define munimxlbl 31024 `"Chumayel"', add
label define munimxlbl 31025 `"Dzan"', add
label define munimxlbl 31026 `"Dzemul"', add
label define munimxlbl 31027 `"Dzidzantun"', add
label define munimxlbl 31028 `"Dzilam de Bravo"', add
label define munimxlbl 31029 `"Dzilam Gonzalez"', add
label define munimxlbl 31030 `"Dzitas"', add
label define munimxlbl 31031 `"Dzoncauich"', add
label define munimxlbl 31032 `"Espita"', add
label define munimxlbl 31033 `"Halacho"', add
label define munimxlbl 31034 `"Hocaba"', add
label define munimxlbl 31035 `"Hoctun"', add
label define munimxlbl 31036 `"Homun"', add
label define munimxlbl 31037 `"Huhi"', add
label define munimxlbl 31038 `"Hunucma"', add
label define munimxlbl 31039 `"Ixil"', add
label define munimxlbl 31040 `"Izamal"', add
label define munimxlbl 31041 `"Kanasin"', add
label define munimxlbl 31042 `"Kantunil"', add
label define munimxlbl 31043 `"Kaua"', add
label define munimxlbl 31044 `"Kinchil"', add
label define munimxlbl 31045 `"Kopoma"', add
label define munimxlbl 31046 `"Mama"', add
label define munimxlbl 31047 `"Mani"', add
label define munimxlbl 31048 `"Maxcanu"', add
label define munimxlbl 31049 `"Mayapan"', add
label define munimxlbl 31050 `"Merida"', add
label define munimxlbl 31051 `"Mococha"', add
label define munimxlbl 31052 `"Motul"', add
label define munimxlbl 31053 `"Muna"', add
label define munimxlbl 31054 `"Muxupip"', add
label define munimxlbl 31055 `"Opichen"', add
label define munimxlbl 31056 `"Oxkutzcab"', add
label define munimxlbl 31057 `"Panaba"', add
label define munimxlbl 31058 `"Peto"', add
label define munimxlbl 31059 `"Progreso"', add
label define munimxlbl 31060 `"Quintana Roo"', add
label define munimxlbl 31061 `"Rio Lagartos"', add
label define munimxlbl 31062 `"Sacalum"', add
label define munimxlbl 31063 `"Samahil"', add
label define munimxlbl 31064 `"Sanahcat"', add
label define munimxlbl 31065 `"San Felipe"', add
label define munimxlbl 31066 `"Santa Elena"', add
label define munimxlbl 31067 `"Seye"', add
label define munimxlbl 31068 `"Sinanche"', add
label define munimxlbl 31069 `"Sotuta"', add
label define munimxlbl 31070 `"Sucila"', add
label define munimxlbl 31071 `"Sudzal"', add
label define munimxlbl 31072 `"Suma"', add
label define munimxlbl 31073 `"Tahdziu"', add
label define munimxlbl 31074 `"Tahmek"', add
label define munimxlbl 31075 `"Teabo"', add
label define munimxlbl 31076 `"Tecoh"', add
label define munimxlbl 31077 `"Tekal de Venegas"', add
label define munimxlbl 31078 `"Tekanto"', add
label define munimxlbl 31079 `"Tekax"', add
label define munimxlbl 31080 `"Tekit"', add
label define munimxlbl 31081 `"Tekom"', add
label define munimxlbl 31082 `"Telchac Pueblo"', add
label define munimxlbl 31083 `"Telchac Puerto"', add
label define munimxlbl 31084 `"Temax"', add
label define munimxlbl 31085 `"Temozon"', add
label define munimxlbl 31086 `"Tepakan"', add
label define munimxlbl 31087 `"Tetiz"', add
label define munimxlbl 31088 `"Teya"', add
label define munimxlbl 31089 `"Ticul"', add
label define munimxlbl 31090 `"Timucuy"', add
label define munimxlbl 31091 `"Tinum"', add
label define munimxlbl 31092 `"Tixcacalcupul"', add
label define munimxlbl 31093 `"Tixkokob"', add
label define munimxlbl 31094 `"Tixmehuac"', add
label define munimxlbl 31095 `"Tixpehual"', add
label define munimxlbl 31096 `"Tizimin"', add
label define munimxlbl 31097 `"Tunkas"', add
label define munimxlbl 31098 `"Tzucacab"', add
label define munimxlbl 31099 `"Uayma"', add
label define munimxlbl 31100 `"Ucu"', add
label define munimxlbl 31101 `"Uman"', add
label define munimxlbl 31102 `"Valladolid"', add
label define munimxlbl 31103 `"Xocchel"', add
label define munimxlbl 31104 `"Yaxcaba"', add
label define munimxlbl 31105 `"Yaxkukul"', add
label define munimxlbl 31106 `"Yobain"', add
label define munimxlbl 32001 `"Apozol"', add
label define munimxlbl 32002 `"Apulco"', add
label define munimxlbl 32003 `"Atolinga"', add
label define munimxlbl 32004 `"Benito Juarez"', add
label define munimxlbl 32005 `"Calera"', add
label define munimxlbl 32006 `"Canitas de Felipe Pescador"', add
label define munimxlbl 32007 `"Concepcion del Oro"', add
label define munimxlbl 32008 `"Cuauhtemoc"', add
label define munimxlbl 32009 `"Chalchihuites"', add
label define munimxlbl 32010 `"Fresnillo"', add
label define munimxlbl 32011 `"Trinidad Garcia de la Cadena"', add
label define munimxlbl 32012 `"Genaro codina"', add
label define munimxlbl 32013 `"General Enrique Estrada"', add
label define munimxlbl 32014 `"General Francisco R. Murguia"', add
label define munimxlbl 32015 `"Plateado de Joaquin Amaro, El"', add
label define munimxlbl 32016 `"General Panfilo Natera"', add
label define munimxlbl 32017 `"Guadalupe"', add
label define munimxlbl 32018 `"Huanusco"', add
label define munimxlbl 32019 `"Jalpa"', add
label define munimxlbl 32020 `"Jerez"', add
label define munimxlbl 32021 `"Jimenez del Teul"', add
label define munimxlbl 32022 `"Juan aldama"', add
label define munimxlbl 32023 `"Juchipila"', add
label define munimxlbl 32024 `"Loreto"', add
label define munimxlbl 32025 `"Luis Moya"', add
label define munimxlbl 32026 `"Mazapil"', add
label define munimxlbl 32027 `"Melchor Ocampo"', add
label define munimxlbl 32028 `"Mezquital del Oro"', add
label define munimxlbl 32029 `"Miguel Auza"', add
label define munimxlbl 32030 `"Momax"', add
label define munimxlbl 32031 `"Monte Escobedo"', add
label define munimxlbl 32032 `"Morelos"', add
label define munimxlbl 32033 `"Moyahua de Estrada"', add
label define munimxlbl 32034 `"Nochistlan de Mejia"', add
label define munimxlbl 32035 `"Noria de Angeles"', add
label define munimxlbl 32036 `"Ojocaliente"', add
label define munimxlbl 32037 `"Panuco"', add
label define munimxlbl 32038 `"Pinos"', add
label define munimxlbl 32039 `"Rio Grande"', add
label define munimxlbl 32040 `"Sain Alto"', add
label define munimxlbl 32041 `"Salvador, El"', add
label define munimxlbl 32042 `"Sombrerete"', add
label define munimxlbl 32043 `"Susticacan"', add
label define munimxlbl 32044 `"Tabasco"', add
label define munimxlbl 32045 `"Tepechitlan"', add
label define munimxlbl 32046 `"Tepetongo"', add
label define munimxlbl 32047 `"Teul de Gonzalez Ortega"', add
label define munimxlbl 32048 `"Tlaltenango de Sanchez Roman"', add
label define munimxlbl 32049 `"Valparaiso"', add
label define munimxlbl 32050 `"Vetagrande"', add
label define munimxlbl 32051 `"Villa de Cos"', add
label define munimxlbl 32052 `"Villa Garcia"', add
label define munimxlbl 32053 `"Villa Gonzalez Ortega"', add
label define munimxlbl 32054 `"Villa Hidalgo"', add
label define munimxlbl 32055 `"Villanueva"', add
label define munimxlbl 32056 `"Zacatecas"', add
label define munimxlbl 32057 `"Trancoso"', add
label define munimxlbl 32058 `"Santa María de la Paz"', add
label values munimx munimxlbl

label define sizemxlbl 1 `"1 to 2,499 population"'
label define sizemxlbl 2 `"2,500 to 14,999"', add
label define sizemxlbl 3 `"15,000 to 99,999"', add
label define sizemxlbl 4 `"15,000 to 19,999"', add
label define sizemxlbl 5 `"20,000 to 49,999"', add
label define sizemxlbl 6 `"50,000 to 99,999"', add
label define sizemxlbl 7 `"100,000 or more"', add
label define sizemxlbl 8 `"100,000 to 499,999"', add
label define sizemxlbl 9 `"500,000 or more"', add
label values sizemx sizemxlbl

label define intmig2lbl 00 `"No international migrants"'
label define intmig2lbl 01 `"1 migrant"', add
label define intmig2lbl 02 `"2 migrants"', add
label define intmig2lbl 03 `"3 migrants"', add
label define intmig2lbl 04 `"4 migrants"', add
label define intmig2lbl 05 `"5 migrants"', add
label define intmig2lbl 06 `"6 migrants"', add
label define intmig2lbl 07 `"7 migrants"', add
label define intmig2lbl 08 `"8 migrants"', add
label define intmig2lbl 09 `"9 migrants"', add
label define intmig2lbl 10 `"10 migrants"', add
label define intmig2lbl 11 `"11 migrants"', add
label define intmig2lbl 12 `"12 migrants"', add
label define intmig2lbl 13 `"13 migrants"', add
label define intmig2lbl 15 `"15 migrants"', add
label define intmig2lbl 99 `"Unknown/missing"', add
label values intmig2 intmig2lbl

label define mx95a_statelbl 01 `"Aguascalientes"'
label define mx95a_statelbl 02 `"Baja California"', add
label define mx95a_statelbl 03 `"Baja California Sur"', add
label define mx95a_statelbl 04 `"Campeche"', add
label define mx95a_statelbl 05 `"Coahuila"', add
label define mx95a_statelbl 06 `"Colima"', add
label define mx95a_statelbl 07 `"Chiapas"', add
label define mx95a_statelbl 08 `"Chihuahua"', add
label define mx95a_statelbl 09 `"Federal District"', add
label define mx95a_statelbl 10 `"Durango"', add
label define mx95a_statelbl 11 `"Guanajuato"', add
label define mx95a_statelbl 12 `"Guerrero"', add
label define mx95a_statelbl 13 `"Hidalgo"', add
label define mx95a_statelbl 14 `"Jalisco"', add
label define mx95a_statelbl 15 `"México"', add
label define mx95a_statelbl 16 `"Michoacán"', add
label define mx95a_statelbl 17 `"Morelos"', add
label define mx95a_statelbl 18 `"Nayarit"', add
label define mx95a_statelbl 19 `"Nuevo León"', add
label define mx95a_statelbl 20 `"Oaxaca"', add
label define mx95a_statelbl 21 `"Puebla"', add
label define mx95a_statelbl 22 `"Querétaro"', add
label define mx95a_statelbl 23 `"Quintana Roo"', add
label define mx95a_statelbl 24 `"San Luis Potosí"', add
label define mx95a_statelbl 25 `"Sinaloa"', add
label define mx95a_statelbl 26 `"Sonora"', add
label define mx95a_statelbl 27 `"Tabasco"', add
label define mx95a_statelbl 28 `"Tamaulipas"', add
label define mx95a_statelbl 29 `"Tlaxcala"', add
label define mx95a_statelbl 30 `"Veracruz"', add
label define mx95a_statelbl 31 `"Yucatán"', add
label define mx95a_statelbl 32 `"Zacatecas"', add
label values mx95a_state mx95a_statelbl

label define mx95a_municlbl 01001 `"Aguascalientes"'
label define mx95a_municlbl 01002 `"Asientos"', add
label define mx95a_municlbl 01003 `"Calvillo"', add
label define mx95a_municlbl 01004 `"Cosio"', add
label define mx95a_municlbl 01005 `"Jesus Maria"', add
label define mx95a_municlbl 01006 `"Pabellon De Arteaga"', add
label define mx95a_municlbl 01007 `"Rincon De Romos"', add
label define mx95a_municlbl 01009 `"Tepezala"', add
label define mx95a_municlbl 01010 `"Llano, El"', add
label define mx95a_municlbl 01011 `"San Francisco De Los Romo"', add
label define mx95a_municlbl 02001 `"Ensenada"', add
label define mx95a_municlbl 02002 `"Mexicali"', add
label define mx95a_municlbl 02003 `"Tecate"', add
label define mx95a_municlbl 02004 `"Tijuana"', add
label define mx95a_municlbl 03001 `"Comondu"', add
label define mx95a_municlbl 03002 `"Mulege"', add
label define mx95a_municlbl 03003 `"Paz, La"', add
label define mx95a_municlbl 03008 `"Cabos, Los"', add
label define mx95a_municlbl 04001 `"Calkini"', add
label define mx95a_municlbl 04002 `"Campeche"', add
label define mx95a_municlbl 04003 `"Carmen"', add
label define mx95a_municlbl 04004 `"Champoton"', add
label define mx95a_municlbl 04005 `"Hecelchakan"', add
label define mx95a_municlbl 04006 `"Hopelchen"', add
label define mx95a_municlbl 04007 `"Palizada"', add
label define mx95a_municlbl 04009 `"Escarcega"', add
label define mx95a_municlbl 05002 `"Acuña"', add
label define mx95a_municlbl 05004 `"Arteaga"', add
label define mx95a_municlbl 05006 `"Castaños"', add
label define mx95a_municlbl 05007 `"Cuatrocienegas"', add
label define mx95a_municlbl 05010 `"Frontera"', add
label define mx95a_municlbl 05014 `"Jimenez"', add
label define mx95a_municlbl 05017 `"Matamoros"', add
label define mx95a_municlbl 05018 `"Monclova"', add
label define mx95a_municlbl 05020 `"Muzquiz"', add
label define mx95a_municlbl 05022 `"Nava"', add
label define mx95a_municlbl 05023 `"Ocampo"', add
label define mx95a_municlbl 05024 `"Parras De La Fuente"', add
label define mx95a_municlbl 05025 `"Piedras Negras"', add
label define mx95a_municlbl 05026 `"Progreso"', add
label define mx95a_municlbl 05027 `"Ramos Arizpe"', add
label define mx95a_municlbl 05030 `"Saltillo"', add
label define mx95a_municlbl 05032 `"San Juan De Sabinas"', add
label define mx95a_municlbl 05033 `"San Pedro"', add
label define mx95a_municlbl 05035 `"Torreon"', add
label define mx95a_municlbl 05038 `"Zaragoza"', add
label define mx95a_municlbl 06001 `"Armeria"', add
label define mx95a_municlbl 06002 `"Colima"', add
label define mx95a_municlbl 06003 `"Comala"', add
label define mx95a_municlbl 06004 `"Coquimatlan"', add
label define mx95a_municlbl 06005 `"Cuauhtemoc"', add
label define mx95a_municlbl 06006 `"Ixtlahuacan"', add
label define mx95a_municlbl 06007 `"Manzanillo"', add
label define mx95a_municlbl 06009 `"Tecoman"', add
label define mx95a_municlbl 06010 `"Villa De Alvarez"', add
label define mx95a_municlbl 07003 `"Acapetahua"', add
label define mx95a_municlbl 07009 `"Arriaga"', add
label define mx95a_municlbl 07017 `"Cintalapa"', add
label define mx95a_municlbl 07019 `"Comitan De Dominguez"', add
label define mx95a_municlbl 07020 `"Concordia, La"', add
label define mx95a_municlbl 07025 `"Chapultenango"', add
label define mx95a_municlbl 07027 `"Chiapa De Corzo"', add
label define mx95a_municlbl 07032 `"Escuintla"', add
label define mx95a_municlbl 07036 `"Grandeza, La"', add
label define mx95a_municlbl 07040 `"Huixtla"', add
label define mx95a_municlbl 07046 `"Jiquipilas"', add
label define mx95a_municlbl 07049 `"Larrainzar"', add
label define mx95a_municlbl 07051 `"Mapastepec"', add
label define mx95a_municlbl 07061 `"Ocozocoautla De Espinosa"', add
label define mx95a_municlbl 07068 `"Pichucalco"', add
label define mx95a_municlbl 07071 `"Villa Comaltitlan"', add
label define mx95a_municlbl 07072 `"Pueblo Nuevo Solistahuacan"', add
label define mx95a_municlbl 07080 `"Siltepec"', add
label define mx95a_municlbl 07089 `"Tapachula"', add
label define mx95a_municlbl 07093 `"Tenejapa"', add
label define mx95a_municlbl 07097 `"Tonala"', add
label define mx95a_municlbl 07098 `"Totolapa"', add
label define mx95a_municlbl 07101 `"Tuxtla Gutierrez"', add
label define mx95a_municlbl 07102 `"Tuxtla Chico"', add
label define mx95a_municlbl 07107 `"Villa Corzo"', add
label define mx95a_municlbl 07108 `"Villaflores"', add
label define mx95a_municlbl 07109 `"Yajalon"', add
label define mx95a_municlbl 08011 `"Camargo"', add
label define mx95a_municlbl 08013 `"Casas Grandes"', add
label define mx95a_municlbl 08017 `"Cuauhtemoc"', add
label define mx95a_municlbl 08019 `"Chihuahua"', add
label define mx95a_municlbl 08020 `"Chinipas"', add
label define mx95a_municlbl 08021 `"Delicias"', add
label define mx95a_municlbl 08031 `"Guerrero"', add
label define mx95a_municlbl 08032 `"Hidalgo Del Parral"', add
label define mx95a_municlbl 08033 `"Huejotitan"', add
label define mx95a_municlbl 08034 `"Ignacio Zaragoza"', add
label define mx95a_municlbl 08036 `"Jimenez"', add
label define mx95a_municlbl 08037 `"Juarez"', add
label define mx95a_municlbl 08040 `"Madera"', add
label define mx95a_municlbl 08045 `"Meoqui"', add
label define mx95a_municlbl 08048 `"Namiquipa"', add
label define mx95a_municlbl 08050 `"Nuevo Casas Grandes"', add
label define mx95a_municlbl 08054 `"Riva Palacio"', add
label define mx95a_municlbl 08060 `"Santa Barbara"', add
label define mx95a_municlbl 08062 `"Saucillo"', add
label define mx95a_municlbl 08063 `"Temosachi"', add
label define mx95a_municlbl 08065 `"Urique"', add
label define mx95a_municlbl 09003 `"Coyoacan"', add
label define mx95a_municlbl 09004 `"Cuajimalpa De Morelos"', add
label define mx95a_municlbl 09005 `"Gustavo A. Madero"', add
label define mx95a_municlbl 09006 `"Iztacalco"', add
label define mx95a_municlbl 09007 `"Iztapalapa"', add
label define mx95a_municlbl 09008 `"Magdalena Contreras, La"', add
label define mx95a_municlbl 09009 `"Milpa Alta"', add
label define mx95a_municlbl 09010 `"Alvaro Obregon"', add
label define mx95a_municlbl 09012 `"Tlalpan"', add
label define mx95a_municlbl 09013 `"Xochimilco"', add
label define mx95a_municlbl 09014 `"Benito Juarez"', add
label define mx95a_municlbl 09015 `"Cuauhtemoc"', add
label define mx95a_municlbl 09016 `"Miguel Hidalgo"', add
label define mx95a_municlbl 09017 `"Venustiano Carranza"', add
label define mx95a_municlbl 10001 `"Canatlan"', add
label define mx95a_municlbl 10004 `"Cuencame"', add
label define mx95a_municlbl 10005 `"Durango"', add
label define mx95a_municlbl 10007 `"Gomez Palacio"', add
label define mx95a_municlbl 10008 `"Guadalupe Victoria"', add
label define mx95a_municlbl 10012 `"Lerdo"', add
label define mx95a_municlbl 10014 `"Mezquital"', add
label define mx95a_municlbl 10016 `"Nombre De Dios"', add
label define mx95a_municlbl 10017 `"Ocampo"', add
label define mx95a_municlbl 10018 `"Oro, El"', add
label define mx95a_municlbl 10020 `"Panuco De Coronado"', add
label define mx95a_municlbl 10023 `"Pueblo Nuevo"', add
label define mx95a_municlbl 10027 `"San Juan De Guadalupe"', add
label define mx95a_municlbl 10028 `"San Juan Del Rio"', add
label define mx95a_municlbl 10032 `"Santiago Papasquiaro"', add
label define mx95a_municlbl 10035 `"Tepehuanes"', add
label define mx95a_municlbl 10037 `"Topia"', add
label define mx95a_municlbl 10038 `"Vicente Guerrero"', add
label define mx95a_municlbl 10039 `"Nuevo Ideal"', add
label define mx95a_municlbl 11003 `"Allende"', add
label define mx95a_municlbl 11004 `"Apaseo El Alto"', add
label define mx95a_municlbl 11005 `"Apaseo El Grande"', add
label define mx95a_municlbl 11007 `"Celaya"', add
label define mx95a_municlbl 11009 `"Comonfort"', add
label define mx95a_municlbl 11014 `"Dolores Hidalgo"', add
label define mx95a_municlbl 11015 `"Guanajuato"', add
label define mx95a_municlbl 11016 `"Huanimaro"', add
label define mx95a_municlbl 11017 `"Irapuato"', add
label define mx95a_municlbl 11018 `"Jaral Del Progreso"', add
label define mx95a_municlbl 11020 `"Leon"', add
label define mx95a_municlbl 11023 `"Penjamo"', add
label define mx95a_municlbl 11027 `"Salamanca"', add
label define mx95a_municlbl 11030 `"San Felipe"', add
label define mx95a_municlbl 11031 `"San Francisco Del Rincon"', add
label define mx95a_municlbl 11032 `"San Jose Iturbide"', add
label define mx95a_municlbl 11033 `"San Luis De La Paz"', add
label define mx95a_municlbl 11037 `"Silao"', add
label define mx95a_municlbl 11039 `"Tarimoro"', add
label define mx95a_municlbl 11042 `"Valle De Santiago"', add
label define mx95a_municlbl 11044 `"Villagran"', add
label define mx95a_municlbl 11046 `"Yuriria"', add
label define mx95a_municlbl 12001 `"Acapulco De Juarez"', add
label define mx95a_municlbl 12005 `"Alpoyeca"', add
label define mx95a_municlbl 12011 `"Atoyac De Alvarez"', add
label define mx95a_municlbl 12012 `"Ayutla De Los Libres"', add
label define mx95a_municlbl 12021 `"Coyuca De Benitez"', add
label define mx95a_municlbl 12023 `"Cuajinicuilapa"', add
label define mx95a_municlbl 12027 `"Cutzamala De Pinzon"', add
label define mx95a_municlbl 12028 `"Chilapa De Alvarez"', add
label define mx95a_municlbl 12029 `"Chilpancingo De Los Bravo"', add
label define mx95a_municlbl 12032 `"General Heliodoro Castillo"', add
label define mx95a_municlbl 12034 `"Huitzuco De Los Figueroa"', add
label define mx95a_municlbl 12035 `"Iguala De La Independencia"', add
label define mx95a_municlbl 12038 `"Jose Azueta"', add
label define mx95a_municlbl 12039 `"Juan R. Escudero"', add
label define mx95a_municlbl 12045 `"Olinala"', add
label define mx95a_municlbl 12046 `"Ometepec"', add
label define mx95a_municlbl 12048 `"Petatlan"', add
label define mx95a_municlbl 12050 `"Pungarabato"', add
label define mx95a_municlbl 12051 `"Quechultenango"', add
label define mx95a_municlbl 12052 `"San Luis Acatlan"', add
label define mx95a_municlbl 12053 `"San Marcos"', add
label define mx95a_municlbl 12055 `"Taxco De Alarcon"', add
label define mx95a_municlbl 12058 `"Teloloapan"', add
label define mx95a_municlbl 12066 `"Tlapa De Comonfort"', add
label define mx95a_municlbl 12067 `"Tlapehuala"', add
label define mx95a_municlbl 12068 `"Union De Isidoro Montes De Oca, La"', add
label define mx95a_municlbl 12072 `"Zapotitlan Tablas"', add
label define mx95a_municlbl 12073 `"Zirandaro"', add
label define mx95a_municlbl 13002 `"Acaxochitlan"', add
label define mx95a_municlbl 13008 `"Apan"', add
label define mx95a_municlbl 13012 `"Atotonilco El Grande"', add
label define mx95a_municlbl 13013 `"Atotonilco De Tula"', add
label define mx95a_municlbl 13014 `"Calnali"', add
label define mx95a_municlbl 13015 `"Cardonal"', add
label define mx95a_municlbl 13018 `"Chapulhuacan"', add
label define mx95a_municlbl 13022 `"Epazoyucan"', add
label define mx95a_municlbl 13023 `"Francisco I. Madero"', add
label define mx95a_municlbl 13024 `"Huasca De Ocampo"', add
label define mx95a_municlbl 13027 `"Huehuetla"', add
label define mx95a_municlbl 13028 `"Huejutla De Reyes"', add
label define mx95a_municlbl 13030 `"Ixmiquilpan"', add
label define mx95a_municlbl 13031 `"Jacala De Ledezma"', add
label define mx95a_municlbl 13034 `"Lolotla"', add
label define mx95a_municlbl 13038 `"Mineral Del Chico"', add
label define mx95a_municlbl 13048 `"Pachuca De Soto"', add
label define mx95a_municlbl 13049 `"Pisaflores"', add
label define mx95a_municlbl 13050 `"Progreso De Obregon"', add
label define mx95a_municlbl 13051 `"Mineral De La Reforma"', add
label define mx95a_municlbl 13053 `"San Bartolo Tutotepec"', add
label define mx95a_municlbl 13054 `"San Salvador"', add
label define mx95a_municlbl 13055 `"Santiago De Anaya"', add
label define mx95a_municlbl 13057 `"Singuilucan"', add
label define mx95a_municlbl 13063 `"Tepeji Del Rio De Ocampo"', add
label define mx95a_municlbl 13068 `"Tianguistengo"', add
label define mx95a_municlbl 13069 `"Tizayuca"', add
label define mx95a_municlbl 13072 `"Tlanalapa"', add
label define mx95a_municlbl 13073 `"Tlanchinol"', add
label define mx95a_municlbl 13074 `"Tlaxcoapan"', add
label define mx95a_municlbl 13076 `"Tula De Allende"', add
label define mx95a_municlbl 13077 `"Tulancingo De Bravo"', add
label define mx95a_municlbl 13080 `"Yahualica"', add
label define mx95a_municlbl 13082 `"Zapotlan De Juarez"', add
label define mx95a_municlbl 13083 `"Zempoala"', add
label define mx95a_municlbl 14006 `"Ameca"', add
label define mx95a_municlbl 14013 `"Atotonilco El Alto"', add
label define mx95a_municlbl 14016 `"Ayotlan"', add
label define mx95a_municlbl 14018 `"Barca, La"', add
label define mx95a_municlbl 14024 `"Cocula"', add
label define mx95a_municlbl 14033 `"Degollado"', add
label define mx95a_municlbl 14037 `"Grullo, El"', add
label define mx95a_municlbl 14038 `"Guachinango"', add
label define mx95a_municlbl 14039 `"Guadalajara"', add
label define mx95a_municlbl 14046 `"Jalostotitlan"', add
label define mx95a_municlbl 14049 `"Jilotlan De Los Dolores"', add
label define mx95a_municlbl 14053 `"Lagos De Moreno"', add
label define mx95a_municlbl 14057 `"Manzanilla De La Paz, La"', add
label define mx95a_municlbl 14061 `"Mezquitic"', add
label define mx95a_municlbl 14067 `"Puerto Vallarta"', add
label define mx95a_municlbl 14070 `"Salto, El"', add
label define mx95a_municlbl 14079 `"Gomez Farias"', add
label define mx95a_municlbl 14083 `"Tala"', add
label define mx95a_municlbl 14085 `"Tamazula De Gordiano"', add
label define mx95a_municlbl 14097 `"Tlajomulco De Zuñiga"', add
label define mx95a_municlbl 14098 `"Tlaquepaque"', add
label define mx95a_municlbl 14100 `"Tomatlan"', add
label define mx95a_municlbl 14101 `"Tonala"', add
label define mx95a_municlbl 14114 `"Villa Corona"', add
label define mx95a_municlbl 14120 `"Zapopan"', add
label define mx95a_municlbl 14121 `"Zapotiltic"', add
label define mx95a_municlbl 14124 `"Zapotlanejo"', add
label define mx95a_municlbl 15001 `"Acambay"', add
label define mx95a_municlbl 15005 `"Almoloya De Juarez"', add
label define mx95a_municlbl 15023 `"Coyotepec"', add
label define mx95a_municlbl 15031 `"Chimalhuacan"', add
label define mx95a_municlbl 15032 `"Donato Guerra"', add
label define mx95a_municlbl 15033 `"Ecatepec"', add
label define mx95a_municlbl 15046 `"Jilotzingo"', add
label define mx95a_municlbl 15054 `"Metepec"', add
label define mx95a_municlbl 15057 `"Naucalpan De Juarez"', add
label define mx95a_municlbl 15058 `"Nezahualcoyotl"', add
label define mx95a_municlbl 15060 `"Nicolas Romero"', add
label define mx95a_municlbl 15064 `"Oro, El"', add
label define mx95a_municlbl 15067 `"Otzolotepec"', add
label define mx95a_municlbl 15074 `"San Felipe Del Progreso"', add
label define mx95a_municlbl 15075 `"San Martin De Las Piramides"', add
label define mx95a_municlbl 15076 `"San Mateo Atenco"', add
label define mx95a_municlbl 15080 `"Sultepec"', add
label define mx95a_municlbl 15081 `"Tecamac"', add
label define mx95a_municlbl 15094 `"Tepetlixpa"', add
label define mx95a_municlbl 15096 `"Tequixquiac"', add
label define mx95a_municlbl 15101 `"Tianguistenco"', add
label define mx95a_municlbl 15103 `"Tlalmanalco"', add
label define mx95a_municlbl 15106 `"Toluca"', add
label define mx95a_municlbl 15107 `"Tonatico"', add
label define mx95a_municlbl 15109 `"Tultitlan"', add
label define mx95a_municlbl 15114 `"Villa Victoria"', add
label define mx95a_municlbl 15115 `"Xonacatlan"', add
label define mx95a_municlbl 15118 `"Zinacantepec"', add
label define mx95a_municlbl 15120 `"Zumpango"', add
label define mx95a_municlbl 15121 `"Cuautitlan Izcalli"', add
label define mx95a_municlbl 15122 `"Valle De Chalco Solidaridad"', add
label define mx95a_municlbl 16001 `"Acuitzio"', add
label define mx95a_municlbl 16008 `"Aquila"', add
label define mx95a_municlbl 16018 `"Copandaro"', add
label define mx95a_municlbl 16019 `"Cotija"', add
label define mx95a_municlbl 16032 `"Erongaricuaro"', add
label define mx95a_municlbl 16033 `"Gabriel Zamora"', add
label define mx95a_municlbl 16042 `"Ixtlan"', add
label define mx95a_municlbl 16043 `"Jacona"', add
label define mx95a_municlbl 16045 `"Jiquilpan"', add
label define mx95a_municlbl 16046 `"Juarez"', add
label define mx95a_municlbl 16047 `"Jungapeo"', add
label define mx95a_municlbl 16050 `"Maravatio"', add
label define mx95a_municlbl 16051 `"Marcos Castellanos"', add
label define mx95a_municlbl 16052 `"Lazaro Cardenas"', add
label define mx95a_municlbl 16053 `"Morelia"', add
label define mx95a_municlbl 16054 `"Morelos"', add
label define mx95a_municlbl 16056 `"Nahuatzen"', add
label define mx95a_municlbl 16061 `"Ocampo"', add
label define mx95a_municlbl 16067 `"Penjamillo"', add
label define mx95a_municlbl 16071 `"Puruandiro"', add
label define mx95a_municlbl 16075 `"Reyes, Los"', add
label define mx95a_municlbl 16077 `"San Lucas"', add
label define mx95a_municlbl 16082 `"Tacambaro"', add
label define mx95a_municlbl 16085 `"Tangancicuaro"', add
label define mx95a_municlbl 16093 `"Tlalpujahua"', add
label define mx95a_municlbl 16094 `"Tlazazalca"', add
label define mx95a_municlbl 16095 `"Tocumbo"', add
label define mx95a_municlbl 16097 `"Turicato"', add
label define mx95a_municlbl 16102 `"Uruapan"', add
label define mx95a_municlbl 16104 `"Villamar"', add
label define mx95a_municlbl 16108 `"Zamora"', add
label define mx95a_municlbl 16112 `"Zitacuaro"', add
label define mx95a_municlbl 17001 `"Amacuzac"', add
label define mx95a_municlbl 17002 `"Atlatlahucan"', add
label define mx95a_municlbl 17004 `"Ayala"', add
label define mx95a_municlbl 17006 `"Cuautla"', add
label define mx95a_municlbl 17007 `"Cuernavaca"', add
label define mx95a_municlbl 17008 `"Emiliano Zapata"', add
label define mx95a_municlbl 17009 `"Huitzilac"', add
label define mx95a_municlbl 17011 `"Jiutepec"', add
label define mx95a_municlbl 17012 `"Jojutla"', add
label define mx95a_municlbl 17014 `"Mazatepec"', add
label define mx95a_municlbl 17015 `"Miacatlan"', add
label define mx95a_municlbl 17016 `"Ocuituco"', add
label define mx95a_municlbl 17017 `"Puente De Ixtla"', add
label define mx95a_municlbl 17018 `"Temixco"', add
label define mx95a_municlbl 17019 `"Tepalcingo"', add
label define mx95a_municlbl 17024 `"Tlaltizapan"', add
label define mx95a_municlbl 17025 `"Tlaquiltenango"', add
label define mx95a_municlbl 17028 `"Xochitepec"', add
label define mx95a_municlbl 17029 `"Yautepec"', add
label define mx95a_municlbl 17030 `"Yecapixtla"', add
label define mx95a_municlbl 17031 `"Zacatepec De Hidalgo"', add
label define mx95a_municlbl 18001 `"Acaponeta"', add
label define mx95a_municlbl 18002 `"Ahuacatlan"', add
label define mx95a_municlbl 18004 `"Compostela"', add
label define mx95a_municlbl 18005 `"Huajicori"', add
label define mx95a_municlbl 18006 `"Ixtlan Del Rio"', add
label define mx95a_municlbl 18008 `"Xalisco"', add
label define mx95a_municlbl 18009 `"Nayar, El"', add
label define mx95a_municlbl 18010 `"Rosamorada"', add
label define mx95a_municlbl 18012 `"San Blas"', add
label define mx95a_municlbl 18013 `"San Pedro Lagunillas"', add
label define mx95a_municlbl 18014 `"Santa Maria Del Oro"', add
label define mx95a_municlbl 18015 `"Santiago Ixcuintla"', add
label define mx95a_municlbl 18016 `"Tecuala"', add
label define mx95a_municlbl 18017 `"Tepic"', add
label define mx95a_municlbl 18018 `"Tuxpan"', add
label define mx95a_municlbl 18019 `"Yesca, La"', add
label define mx95a_municlbl 18020 `"Bahia De Banderas"', add
label define mx95a_municlbl 19003 `"Aldamas, Los"', add
label define mx95a_municlbl 19004 `"Allende"', add
label define mx95a_municlbl 19006 `"Apodaca"', add
label define mx95a_municlbl 19009 `"Cadereyta Jimenez"', add
label define mx95a_municlbl 19013 `"China"', add
label define mx95a_municlbl 19014 `"Doctor Arroyo"', add
label define mx95a_municlbl 19017 `"Galeana"', add
label define mx95a_municlbl 19022 `"General Teran"', add
label define mx95a_municlbl 19026 `"Guadalupe"', add
label define mx95a_municlbl 19033 `"Linares"', add
label define mx95a_municlbl 19034 `"Marin"', add
label define mx95a_municlbl 19035 `"Melchor Ocampo"', add
label define mx95a_municlbl 19036 `"Mier Y Noriega"', add
label define mx95a_municlbl 19038 `"Montemorelos"', add
label define mx95a_municlbl 19039 `"Monterrey"', add
label define mx95a_municlbl 19041 `"Pesqueria"', add
label define mx95a_municlbl 19042 `"Ramones, Los"', add
label define mx95a_municlbl 19044 `"Sabinas Hidalgo"', add
label define mx95a_municlbl 19046 `"San Nicolas De Los Garza"', add
label define mx95a_municlbl 19047 `"Hidalgo"', add
label define mx95a_municlbl 19049 `"Santiago"', add
label define mx95a_municlbl 20002 `"Acatlan De Perez Figueroa"', add
label define mx95a_municlbl 20016 `"Coicoyan De Las Flores"', add
label define mx95a_municlbl 20021 `"Cosolapa"', add
label define mx95a_municlbl 20023 `"Cuilapam De Guerrero"', add
label define mx95a_municlbl 20036 `"Guevea De Humboldt"', add
label define mx95a_municlbl 20039 `"Ciudad De Huajuapam De Leon"', add
label define mx95a_municlbl 20041 `"Huautla De Jimenez"', add
label define mx95a_municlbl 20044 `"Loma Bonita"', add
label define mx95a_municlbl 20067 `"Oaxaca De Juarez"', add
label define mx95a_municlbl 20072 `"San Jose Del Progreso"', add
label define mx95a_municlbl 20079 `"Salina Cruz"', add
label define mx95a_municlbl 20102 `"San Andres Zautla"', add
label define mx95a_municlbl 20107 `"San Antonio De La Cal"', add
label define mx95a_municlbl 20131 `"San Dionisio Ocotepec"', add
label define mx95a_municlbl 20134 `"San Felipe Jalapa De Diaz"', add
label define mx95a_municlbl 20177 `"San Juan Bautista Cuicatlan"', add
label define mx95a_municlbl 20184 `"San Juan Bautista Tuxtepec"', add
label define mx95a_municlbl 20194 `"San Juan Del Rio"', add
label define mx95a_municlbl 20198 `"San Juan Guichicovi"', add
label define mx95a_municlbl 20223 `"San Juan Yatzona"', add
label define mx95a_municlbl 20253 `"San Mateo Piñas"', add
label define mx95a_municlbl 20278 `"San Miguel Soyaltepec"', add
label define mx95a_municlbl 20289 `"San Nicolas"', add
label define mx95a_municlbl 20292 `"San Pablo Cuatro Venados"', add
label define mx95a_municlbl 20318 `"San Pedro Mixtepec -Distr. 22-"', add
label define mx95a_municlbl 20324 `"San Pedro Pochutla"', add
label define mx95a_municlbl 20366 `"Santa Catarina Loxicha"', add
label define mx95a_municlbl 20375 `"Santa Cruz Amilpas"', add
label define mx95a_municlbl 20378 `"Santa Cruz Mixtepec"', add
label define mx95a_municlbl 20385 `"Santa Cruz Xoxocotlan"', add
label define mx95a_municlbl 20386 `"Santa Cruz Zenzontepec"', add
label define mx95a_municlbl 20399 `"Santa Maria Atzompa"', add
label define mx95a_municlbl 20407 `"Santa Maria Chimalapa"', add
label define mx95a_municlbl 20413 `"Santa Maria Huatulco"', add
label define mx95a_municlbl 20454 `"Santiago Atitlan"', add
label define mx95a_municlbl 20470 `"Santiago Lachiguiri"', add
label define mx95a_municlbl 20474 `"Santiago Llano Grande"', add
label define mx95a_municlbl 20482 `"Santiago Pinotepa Nacional"', add
label define mx95a_municlbl 20486 `"Villa Tejupam De La Union"', add
label define mx95a_municlbl 20515 `"Santo Domingo Tehuantepec"', add
label define mx95a_municlbl 20525 `"Santo Domingo Zanatepec"', add
label define mx95a_municlbl 20544 `"Teococuilco De Marcos Perez"', add
label define mx95a_municlbl 20559 `"San Juan Bautista Valle Nacional"', add
label define mx95a_municlbl 20562 `"Magdalena Yodocono De Porfirio Diaz"', add
label define mx95a_municlbl 20569 `"Santa Ines De Zaragoza"', add
label define mx95a_municlbl 21002 `"Acateno"', add
label define mx95a_municlbl 21003 `"Acatlan"', add
label define mx95a_municlbl 21019 `"Atlixco"', add
label define mx95a_municlbl 21022 `"Atzitzihuacan"', add
label define mx95a_municlbl 21043 `"Cuetzalan Del Progreso"', add
label define mx95a_municlbl 21048 `"Chiautzingo"', add
label define mx95a_municlbl 21067 `"Guadalupe Victoria"', add
label define mx95a_municlbl 21069 `"Huaquechula"', add
label define mx95a_municlbl 21073 `"Huehuetlan El Chico"', add
label define mx95a_municlbl 21078 `"Huitzilan De Serdan"', add
label define mx95a_municlbl 21083 `"Ixtacamaxtitlan"', add
label define mx95a_municlbl 21090 `"Juan C. Bonilla"', add
label define mx95a_municlbl 21099 `"Cañada Morelos"', add
label define mx95a_municlbl 21112 `"Petlalcingo"', add
label define mx95a_municlbl 21114 `"Puebla"', add
label define mx95a_municlbl 21116 `"Quimixtlan"', add
label define mx95a_municlbl 21132 `"San Martin Texmelucan"', add
label define mx95a_municlbl 21150 `"Huehuetlan El Grande"', add
label define mx95a_municlbl 21153 `"Tecali De Herrera"', add
label define mx95a_municlbl 21154 `"Tecamachalco"', add
label define mx95a_municlbl 21156 `"Tehuacan"', add
label define mx95a_municlbl 21180 `"Tlahuapan"', add
label define mx95a_municlbl 21183 `"Tlaola"', add
label define mx95a_municlbl 21197 `"Xicotepec"', add
label define mx95a_municlbl 21209 `"Zapotitlan"', add
label define mx95a_municlbl 21211 `"Zaragoza"', add
label define mx95a_municlbl 22001 `"Amealco De Bonfil"', add
label define mx95a_municlbl 22003 `"Arroyo Seco"', add
label define mx95a_municlbl 22004 `"Cadereyta De Montes"', add
label define mx95a_municlbl 22005 `"Colon"', add
label define mx95a_municlbl 22006 `"Corregidora"', add
label define mx95a_municlbl 22010 `"Landa De Matamoros"', add
label define mx95a_municlbl 22011 `"Marques, El"', add
label define mx95a_municlbl 22012 `"Pedro Escobedo"', add
label define mx95a_municlbl 22013 `"Peñamiller"', add
label define mx95a_municlbl 22014 `"Queretaro"', add
label define mx95a_municlbl 22016 `"San Juan Del Rio"', add
label define mx95a_municlbl 22017 `"Tequisquiapan"', add
label define mx95a_municlbl 22018 `"Toliman"', add
label define mx95a_municlbl 23001 `"Cozumel"', add
label define mx95a_municlbl 23002 `"Felipe Carrillo Puerto"', add
label define mx95a_municlbl 23004 `"Othon P. Blanco"', add
label define mx95a_municlbl 23005 `"Benito Juarez"', add
label define mx95a_municlbl 23006 `"Jose Maria Morelos"', add
label define mx95a_municlbl 23007 `"Lazaro Cardenas"', add
label define mx95a_municlbl 23008 `"Solidaridad"', add
label define mx95a_municlbl 24001 `"Ahualulco"', add
label define mx95a_municlbl 24008 `"Cerritos"', add
label define mx95a_municlbl 24011 `"Ciudad Fernandez"', add
label define mx95a_municlbl 24013 `"Ciudad Valles"', add
label define mx95a_municlbl 24015 `"Charcas"', add
label define mx95a_municlbl 24016 `"Ebano"', add
label define mx95a_municlbl 24017 `"Guadalcazar"', add
label define mx95a_municlbl 24018 `"Huehuetlan"', add
label define mx95a_municlbl 24020 `"Matehuala"', add
label define mx95a_municlbl 24024 `"Rioverde"', add
label define mx95a_municlbl 24028 `"San Luis Potosi"', add
label define mx95a_municlbl 24030 `"San Nicolas Tolentino"', add
label define mx95a_municlbl 24032 `"Santa Maria Del Rio"', add
label define mx95a_municlbl 24034 `"San Vicente Tancuayalab"', add
label define mx95a_municlbl 24035 `"Soledad De Graciano Sanchez"', add
label define mx95a_municlbl 24036 `"Tamasopo"', add
label define mx95a_municlbl 24043 `"Tierranueva"', add
label define mx95a_municlbl 24045 `"Venado"', add
label define mx95a_municlbl 24050 `"Villa De Reyes"', add
label define mx95a_municlbl 24052 `"Villa Juarez"', add
label define mx95a_municlbl 24054 `"Xilitla"', add
label define mx95a_municlbl 24055 `"Zaragoza"', add
label define mx95a_municlbl 24057 `"Matlapa"', add
label define mx95a_municlbl 25001 `"Ahome"', add
label define mx95a_municlbl 25003 `"Badiraguato"', add
label define mx95a_municlbl 25005 `"Cosala"', add
label define mx95a_municlbl 25006 `"Culiacan"', add
label define mx95a_municlbl 25007 `"Choix"', add
label define mx95a_municlbl 25008 `"Elota"', add
label define mx95a_municlbl 25009 `"Escuinapa"', add
label define mx95a_municlbl 25010 `"Fuerte, El"', add
label define mx95a_municlbl 25011 `"Guasave"', add
label define mx95a_municlbl 25012 `"Mazatlan"', add
label define mx95a_municlbl 25014 `"Rosario"', add
label define mx95a_municlbl 25016 `"San Ignacio"', add
label define mx95a_municlbl 25017 `"Sinaloa"', add
label define mx95a_municlbl 25018 `"Navolato"', add
label define mx95a_municlbl 26002 `"Agua Prieta"', add
label define mx95a_municlbl 26003 `"Alamos"', add
label define mx95a_municlbl 26008 `"Bacadehuachi"', add
label define mx95a_municlbl 26012 `"Bacum"', add
label define mx95a_municlbl 26018 `"Cajeme"', add
label define mx95a_municlbl 26019 `"Cananea"', add
label define mx95a_municlbl 26025 `"Empalme"', add
label define mx95a_municlbl 26026 `"Etchojoa"', add
label define mx95a_municlbl 26029 `"Guaymas"', add
label define mx95a_municlbl 26030 `"Hermosillo"', add
label define mx95a_municlbl 26033 `"Huatabampo"', add
label define mx95a_municlbl 26041 `"Nacozari De Garcia"', add
label define mx95a_municlbl 26042 `"Navojoa"', add
label define mx95a_municlbl 26043 `"Nogales"', add
label define mx95a_municlbl 26048 `"Puerto Peñasco"', add
label define mx95a_municlbl 26055 `"San Luis Rio Colorado"', add
label define mx95a_municlbl 27001 `"Balancan"', add
label define mx95a_municlbl 27002 `"Cardenas"', add
label define mx95a_municlbl 27003 `"Centla"', add
label define mx95a_municlbl 27004 `"Centro"', add
label define mx95a_municlbl 27005 `"Comalcalco"', add
label define mx95a_municlbl 27006 `"Cunduacan"', add
label define mx95a_municlbl 27008 `"Huimanguillo"', add
label define mx95a_municlbl 27010 `"Jalpa De Mendez"', add
label define mx95a_municlbl 27011 `"Jonuta"', add
label define mx95a_municlbl 27012 `"Macuspana"', add
label define mx95a_municlbl 27013 `"Nacajuca"', add
label define mx95a_municlbl 27015 `"Tacotalpa"', add
label define mx95a_municlbl 27016 `"Teapa"', add
label define mx95a_municlbl 27017 `"Tenosique"', add
label define mx95a_municlbl 28003 `"Altamira"', add
label define mx95a_municlbl 28009 `"Ciudad Madero"', add
label define mx95a_municlbl 28012 `"Gonzalez"', add
label define mx95a_municlbl 28013 `"Güemez"', add
label define mx95a_municlbl 28015 `"Gustavo Diaz Ordaz"', add
label define mx95a_municlbl 28017 `"Jaumave"', add
label define mx95a_municlbl 28019 `"Llera"', add
label define mx95a_municlbl 28021 `"Mante, El"', add
label define mx95a_municlbl 28022 `"Matamoros"', add
label define mx95a_municlbl 28027 `"Nuevo Laredo"', add
label define mx95a_municlbl 28032 `"Reynosa"', add
label define mx95a_municlbl 28035 `"San Fernando"', add
label define mx95a_municlbl 28037 `"Soto La Marina"', add
label define mx95a_municlbl 28038 `"Tampico"', add
label define mx95a_municlbl 28039 `"Tula"', add
label define mx95a_municlbl 28040 `"Valle Hermoso"', add
label define mx95a_municlbl 28041 `"Victoria"', add
label define mx95a_municlbl 28043 `"Xicotencatl"', add
label define mx95a_municlbl 29002 `"Apetatitlan De Antonio Carvajal"', add
label define mx95a_municlbl 29005 `"Apizaco"', add
label define mx95a_municlbl 29006 `"Calpulalpan"', add
label define mx95a_municlbl 29009 `"Cuaxomulco"', add
label define mx95a_municlbl 29010 `"Chiautempan"', add
label define mx95a_municlbl 29013 `"Huamantla"', add
label define mx95a_municlbl 29014 `"Hueyotlipan"', add
label define mx95a_municlbl 29015 `"Ixtacuixtla De Mariano Matamoros"', add
label define mx95a_municlbl 29016 `"Ixtenco"', add
label define mx95a_municlbl 29018 `"Contla De Juan Cuamatzi"', add
label define mx95a_municlbl 29019 `"Tepetitla De Lardizabal"', add
label define mx95a_municlbl 29020 `"Sanctorum De Lazaro Cardenas"', add
label define mx95a_municlbl 29022 `"Acuamanala De Miguel Hidalgo"', add
label define mx95a_municlbl 29023 `"Nativitas"', add
label define mx95a_municlbl 29024 `"Panotla"', add
label define mx95a_municlbl 29025 `"San Pablo Del Monte"', add
label define mx95a_municlbl 29028 `"Teolocholco"', add
label define mx95a_municlbl 29029 `"Tepeyanco"', add
label define mx95a_municlbl 29030 `"Terrenate"', add
label define mx95a_municlbl 29031 `"Tetla De La Solidaridad"', add
label define mx95a_municlbl 29033 `"Tlaxcala"', add
label define mx95a_municlbl 29034 `"Tlaxco"', add
label define mx95a_municlbl 29036 `"Totolac"', add
label define mx95a_municlbl 29037 `"Zitlaltepec De Trinidad Sanchez Santos"', add
label define mx95a_municlbl 29038 `"Tzompantepec"', add
label define mx95a_municlbl 29039 `"Xalostoc"', add
label define mx95a_municlbl 29043 `"Yauhquemecan"', add
label define mx95a_municlbl 29044 `"Zacatelco"', add
label define mx95a_municlbl 30003 `"Acayucan"', add
label define mx95a_municlbl 30010 `"Altotonga"', add
label define mx95a_municlbl 30011 `"Alvarado"', add
label define mx95a_municlbl 30014 `"Amatlan De Los Reyes"', add
label define mx95a_municlbl 30023 `"Atzalan"', add
label define mx95a_municlbl 30028 `"Boca Del Rio"', add
label define mx95a_municlbl 30039 `"Coatzacoalcos"', add
label define mx95a_municlbl 30044 `"Cordoba"', add
label define mx95a_municlbl 30045 `"Cosamaloapan"', add
label define mx95a_municlbl 30057 `"Chiconquiaco"', add
label define mx95a_municlbl 30058 `"Chicontepec"', add
label define mx95a_municlbl 30059 `"Chinameca"', add
label define mx95a_municlbl 30061 `"Choapas, Las"', add
label define mx95a_municlbl 30065 `"Emiliano Zapata"', add
label define mx95a_municlbl 30069 `"Gutierrez Zamora"', add
label define mx95a_municlbl 30077 `"Isla"', add
label define mx95a_municlbl 30085 `"Ixtaczoquitlan"', add
label define mx95a_municlbl 30087 `"Xalapa"', add
label define mx95a_municlbl 30089 `"Jaltipan"', add
label define mx95a_municlbl 30091 `"Jesus Carranza"', add
label define mx95a_municlbl 30093 `"Jilotepec"', add
label define mx95a_municlbl 30102 `"Martinez De La Torre"', add
label define mx95a_municlbl 30106 `"Miahuatlan"', add
label define mx95a_municlbl 30118 `"Orizaba"', add
label define mx95a_municlbl 30123 `"Panuco"', add
label define mx95a_municlbl 30124 `"Papantla"', add
label define mx95a_municlbl 30128 `"Perote"', add
label define mx95a_municlbl 30131 `"Poza Rica De Hidalgo"', add
label define mx95a_municlbl 30132 `"Vigas De Ramirez, Las"', add
label define mx95a_municlbl 30133 `"Pueblo Viejo"', add
label define mx95a_municlbl 30189 `"Tuxpam"', add
label define mx95a_municlbl 30193 `"Veracruz"', add
label define mx95a_municlbl 30199 `"Zaragoza"', add
label define mx95a_municlbl 30205 `"Higo, El"', add
label define mx95a_municlbl 31002 `"Acanceh"', add
label define mx95a_municlbl 31003 `"Akil"', add
label define mx95a_municlbl 31006 `"Buctzotz"', add
label define mx95a_municlbl 31022 `"Chikindzonot"', add
label define mx95a_municlbl 31024 `"Chumayel"', add
label define mx95a_municlbl 31032 `"Espita"', add
label define mx95a_municlbl 31035 `"Hoctun"', add
label define mx95a_municlbl 31040 `"Izamal"', add
label define mx95a_municlbl 31050 `"Merida"', add
label define mx95a_municlbl 31052 `"Motul"', add
label define mx95a_municlbl 31055 `"Opichen"', add
label define mx95a_municlbl 31056 `"Oxkutzcab"', add
label define mx95a_municlbl 31058 `"Peto"', add
label define mx95a_municlbl 31059 `"Progreso"', add
label define mx95a_municlbl 31060 `"Quintana Roo"', add
label define mx95a_municlbl 31063 `"Samahil"', add
label define mx95a_municlbl 31065 `"San Felipe"', add
label define mx95a_municlbl 31067 `"Seye"', add
label define mx95a_municlbl 31078 `"Tekanto"', add
label define mx95a_municlbl 31083 `"Telchac Puerto"', add
label define mx95a_municlbl 31088 `"Teya"', add
label define mx95a_municlbl 31089 `"Ticul"', add
label define mx95a_municlbl 31091 `"Tinum"', add
label define mx95a_municlbl 31093 `"Tixkokob"', add
label define mx95a_municlbl 31095 `"Tixpehual"', add
label define mx95a_municlbl 31096 `"Tizimin"', add
label define mx95a_municlbl 31097 `"Tunkas"', add
label define mx95a_municlbl 31098 `"Tzucacab"', add
label define mx95a_municlbl 31102 `"Valladolid"', add
label define mx95a_municlbl 32001 `"Apozol"', add
label define mx95a_municlbl 32009 `"Chalchihuites"', add
label define mx95a_municlbl 32010 `"Fresnillo"', add
label define mx95a_municlbl 32013 `"General Enrique Estrada"', add
label define mx95a_municlbl 32016 `"General Panfilo Natera"', add
label define mx95a_municlbl 32017 `"Guadalupe"', add
label define mx95a_municlbl 32019 `"Jalpa"', add
label define mx95a_municlbl 32020 `"Jerez"', add
label define mx95a_municlbl 32021 `"Jimenez Del Teul"', add
label define mx95a_municlbl 32023 `"Juchipila"', add
label define mx95a_municlbl 32025 `"Luis Moya"', add
label define mx95a_municlbl 32028 `"Mezquital Del Oro"', add
label define mx95a_municlbl 32029 `"Miguel Auza"', add
label define mx95a_municlbl 32034 `"Nochistlan De Mejia"', add
label define mx95a_municlbl 32035 `"Noria De Angeles"', add
label define mx95a_municlbl 32036 `"Ojocaliente"', add
label define mx95a_municlbl 32037 `"Panuco"', add
label define mx95a_municlbl 32038 `"Pinos"', add
label define mx95a_municlbl 32039 `"Rio Grande"', add
label define mx95a_municlbl 32041 `"Salvador, El"', add
label define mx95a_municlbl 32042 `"Sombrerete"', add
label define mx95a_municlbl 32044 `"Tabasco"', add
label define mx95a_municlbl 32046 `"Tepetongo"', add
label define mx95a_municlbl 32049 `"Valparaiso"', add
label define mx95a_municlbl 32051 `"Villa De Cos"', add
label define mx95a_municlbl 32055 `"Villanueva"', add
label define mx95a_municlbl 32056 `"Zacatecas"', add
label values mx95a_munic mx95a_municlbl

label values pernum pernumlbl

label values wtper wtperlbl

label define agelbl 000 `"Less than 1 year"'
label define agelbl 001 `"1 year"', add
label define agelbl 002 `"2 years"', add
label define agelbl 003 `"3"', add
label define agelbl 004 `"4"', add
label define agelbl 005 `"5"', add
label define agelbl 006 `"6"', add
label define agelbl 007 `"7"', add
label define agelbl 008 `"8"', add
label define agelbl 009 `"9"', add
label define agelbl 010 `"10"', add
label define agelbl 011 `"11"', add
label define agelbl 012 `"12"', add
label define agelbl 013 `"13"', add
label define agelbl 014 `"14"', add
label define agelbl 015 `"15"', add
label define agelbl 016 `"16"', add
label define agelbl 017 `"17"', add
label define agelbl 018 `"18"', add
label define agelbl 019 `"19"', add
label define agelbl 020 `"20"', add
label define agelbl 021 `"21"', add
label define agelbl 022 `"22"', add
label define agelbl 023 `"23"', add
label define agelbl 024 `"24"', add
label define agelbl 025 `"25"', add
label define agelbl 026 `"26"', add
label define agelbl 027 `"27"', add
label define agelbl 028 `"28"', add
label define agelbl 029 `"29"', add
label define agelbl 030 `"30"', add
label define agelbl 031 `"31"', add
label define agelbl 032 `"32"', add
label define agelbl 033 `"33"', add
label define agelbl 034 `"34"', add
label define agelbl 035 `"35"', add
label define agelbl 036 `"36"', add
label define agelbl 037 `"37"', add
label define agelbl 038 `"38"', add
label define agelbl 039 `"39"', add
label define agelbl 040 `"40"', add
label define agelbl 041 `"41"', add
label define agelbl 042 `"42"', add
label define agelbl 043 `"43"', add
label define agelbl 044 `"44"', add
label define agelbl 045 `"45"', add
label define agelbl 046 `"46"', add
label define agelbl 047 `"47"', add
label define agelbl 048 `"48"', add
label define agelbl 049 `"49"', add
label define agelbl 050 `"50"', add
label define agelbl 051 `"51"', add
label define agelbl 052 `"52"', add
label define agelbl 053 `"53"', add
label define agelbl 054 `"54"', add
label define agelbl 055 `"55"', add
label define agelbl 056 `"56"', add
label define agelbl 057 `"57"', add
label define agelbl 058 `"58"', add
label define agelbl 059 `"59"', add
label define agelbl 060 `"60"', add
label define agelbl 061 `"61"', add
label define agelbl 062 `"62"', add
label define agelbl 063 `"63"', add
label define agelbl 064 `"64"', add
label define agelbl 065 `"65"', add
label define agelbl 066 `"66"', add
label define agelbl 067 `"67"', add
label define agelbl 068 `"68"', add
label define agelbl 069 `"69"', add
label define agelbl 070 `"70"', add
label define agelbl 071 `"71"', add
label define agelbl 072 `"72"', add
label define agelbl 073 `"73"', add
label define agelbl 074 `"74"', add
label define agelbl 075 `"75"', add
label define agelbl 076 `"76"', add
label define agelbl 077 `"77"', add
label define agelbl 078 `"78"', add
label define agelbl 079 `"79"', add
label define agelbl 080 `"80"', add
label define agelbl 081 `"81"', add
label define agelbl 082 `"82"', add
label define agelbl 083 `"83"', add
label define agelbl 084 `"84"', add
label define agelbl 085 `"85"', add
label define agelbl 086 `"86"', add
label define agelbl 087 `"87"', add
label define agelbl 088 `"88"', add
label define agelbl 089 `"89"', add
label define agelbl 090 `"90"', add
label define agelbl 091 `"91"', add
label define agelbl 092 `"92"', add
label define agelbl 093 `"93"', add
label define agelbl 094 `"94"', add
label define agelbl 095 `"95"', add
label define agelbl 096 `"96"', add
label define agelbl 097 `"97"', add
label define agelbl 098 `"98"', add
label define agelbl 099 `"99"', add
label define agelbl 100 `"100+"', add
label define agelbl 999 `"Not reported/missing"', add
label values age agelbl

label define sexlbl 1 `"Male"'
label define sexlbl 2 `"Female"', add
label define sexlbl 9 `"Unknown"', add
label values sex sexlbl

label define marstlbl 0 `"NIU (not in universe)"'
label define marstlbl 1 `"Single/never married"', add
label define marstlbl 2 `"Married/in union"', add
label define marstlbl 3 `"Separated/divorced/spouse absent"', add
label define marstlbl 4 `"Widowed"', add
label define marstlbl 9 `"Unknown/missing"', add
label values marst marstlbl

label define marstdlbl 000 `"NIU (not in universe)"'
label define marstdlbl 100 `"Single/never married"', add
label define marstdlbl 110 `"Engaged"', add
label define marstdlbl 200 `"Married/in union"', add
label define marstdlbl 210 `"Married (type not specified)"', add
label define marstdlbl 211 `"Married, civil"', add
label define marstdlbl 212 `"Married, religious"', add
label define marstdlbl 213 `"Married, civil and religious"', add
label define marstdlbl 214 `"Married, civil or religious"', add
label define marstdlbl 215 `"Married, traditional/customary"', add
label define marstdlbl 216 `"Married, monogamous"', add
label define marstdlbl 217 `"Married, polygamous"', add
label define marstdlbl 220 `"Consensual union"', add
label define marstdlbl 300 `"Separated/divorced/spouse absent"', add
label define marstdlbl 310 `"Separated or divorced"', add
label define marstdlbl 320 `"Separated or annulled"', add
label define marstdlbl 330 `"Separated"', add
label define marstdlbl 331 `"Separated legally"', add
label define marstdlbl 332 `"Separated de facto"', add
label define marstdlbl 333 `"Separated from marriage"', add
label define marstdlbl 334 `"Separated from consensual union"', add
label define marstdlbl 340 `"Annulled"', add
label define marstdlbl 350 `"Divorced"', add
label define marstdlbl 360 `"Married, spouse absent"', add
label define marstdlbl 400 `"Widowed"', add
label define marstdlbl 410 `"Widowed or divorced"', add
label define marstdlbl 999 `"Unknown/missing"', add
label values marstd marstdlbl

label define agemarrlbl 00 `"NIU (not in universe)"'
label define agemarrlbl 10 `"10"', add
label define agemarrlbl 11 `"11"', add
label define agemarrlbl 12 `"12"', add
label define agemarrlbl 13 `"13"', add
label define agemarrlbl 14 `"14"', add
label define agemarrlbl 15 `"15"', add
label define agemarrlbl 16 `"16"', add
label define agemarrlbl 17 `"17"', add
label define agemarrlbl 18 `"18"', add
label define agemarrlbl 19 `"19"', add
label define agemarrlbl 20 `"20"', add
label define agemarrlbl 21 `"21"', add
label define agemarrlbl 22 `"22"', add
label define agemarrlbl 23 `"23"', add
label define agemarrlbl 24 `"24"', add
label define agemarrlbl 25 `"25"', add
label define agemarrlbl 26 `"26"', add
label define agemarrlbl 27 `"27"', add
label define agemarrlbl 28 `"28"', add
label define agemarrlbl 29 `"29"', add
label define agemarrlbl 30 `"30"', add
label define agemarrlbl 31 `"31"', add
label define agemarrlbl 32 `"32"', add
label define agemarrlbl 33 `"33"', add
label define agemarrlbl 34 `"34"', add
label define agemarrlbl 35 `"35"', add
label define agemarrlbl 36 `"36"', add
label define agemarrlbl 37 `"37"', add
label define agemarrlbl 38 `"38"', add
label define agemarrlbl 39 `"39"', add
label define agemarrlbl 40 `"40"', add
label define agemarrlbl 41 `"41"', add
label define agemarrlbl 42 `"42"', add
label define agemarrlbl 43 `"43"', add
label define agemarrlbl 44 `"44"', add
label define agemarrlbl 45 `"45"', add
label define agemarrlbl 46 `"46"', add
label define agemarrlbl 47 `"47"', add
label define agemarrlbl 48 `"48"', add
label define agemarrlbl 49 `"49"', add
label define agemarrlbl 50 `"50"', add
label define agemarrlbl 51 `"51"', add
label define agemarrlbl 52 `"52"', add
label define agemarrlbl 53 `"53"', add
label define agemarrlbl 54 `"54"', add
label define agemarrlbl 55 `"55"', add
label define agemarrlbl 56 `"56"', add
label define agemarrlbl 57 `"57"', add
label define agemarrlbl 58 `"58"', add
label define agemarrlbl 59 `"59"', add
label define agemarrlbl 60 `"60"', add
label define agemarrlbl 61 `"61"', add
label define agemarrlbl 62 `"62"', add
label define agemarrlbl 63 `"63"', add
label define agemarrlbl 64 `"64"', add
label define agemarrlbl 65 `"65"', add
label define agemarrlbl 66 `"66"', add
label define agemarrlbl 67 `"67"', add
label define agemarrlbl 68 `"68"', add
label define agemarrlbl 69 `"69"', add
label define agemarrlbl 70 `"70"', add
label define agemarrlbl 71 `"71"', add
label define agemarrlbl 72 `"72"', add
label define agemarrlbl 73 `"73"', add
label define agemarrlbl 74 `"74"', add
label define agemarrlbl 75 `"75"', add
label define agemarrlbl 76 `"76"', add
label define agemarrlbl 77 `"77"', add
label define agemarrlbl 78 `"78"', add
label define agemarrlbl 79 `"79"', add
label define agemarrlbl 80 `"80"', add
label define agemarrlbl 81 `"81"', add
label define agemarrlbl 82 `"82"', add
label define agemarrlbl 83 `"83"', add
label define agemarrlbl 84 `"84"', add
label define agemarrlbl 85 `"85"', add
label define agemarrlbl 86 `"86"', add
label define agemarrlbl 87 `"87"', add
label define agemarrlbl 88 `"88"', add
label define agemarrlbl 89 `"89"', add
label define agemarrlbl 90 `"90"', add
label define agemarrlbl 91 `"91"', add
label define agemarrlbl 92 `"92"', add
label define agemarrlbl 93 `"93"', add
label define agemarrlbl 94 `"94"', add
label define agemarrlbl 95 `"95"', add
label define agemarrlbl 96 `"96"', add
label define agemarrlbl 97 `"97"', add
label define agemarrlbl 98 `"98"', add
label define agemarrlbl 99 `"Unknown"', add
label values agemarr agemarrlbl

label define nativtylbl 0 `"NIU (not universe)"'
label define nativtylbl 1 `"Native-born"', add
label define nativtylbl 2 `"Foreign-born"', add
label define nativtylbl 8 `"Response suppressed"', add
label define nativtylbl 9 `"Unknown/missing"', add
label values nativty nativtylbl

label define bplctrylbl 00000 `"NIU (not in universe)"'
label define bplctrylbl 10000 `"Africa"', add
label define bplctrylbl 11000 `"Eastern Africa"', add
label define bplctrylbl 11010 `"Burundi"', add
label define bplctrylbl 11020 `"Comoros"', add
label define bplctrylbl 11030 `"Djibouti"', add
label define bplctrylbl 11040 `"Eritrea"', add
label define bplctrylbl 11050 `"Ethiopia"', add
label define bplctrylbl 11060 `"Kenya"', add
label define bplctrylbl 11070 `"Madagascar"', add
label define bplctrylbl 11080 `"Malawi"', add
label define bplctrylbl 11090 `"Mauritius"', add
label define bplctrylbl 11100 `"Mozambique"', add
label define bplctrylbl 11110 `"Reunion"', add
label define bplctrylbl 11120 `"Rwanda"', add
label define bplctrylbl 11130 `"Seychelles"', add
label define bplctrylbl 11140 `"Somalia"', add
label define bplctrylbl 11150 `"Uganda"', add
label define bplctrylbl 11160 `"Tanzania"', add
label define bplctrylbl 11170 `"Zambia"', add
label define bplctrylbl 11180 `"Zimbabwe"', add
label define bplctrylbl 11999 `"Eastern Africa, n.s."', add
label define bplctrylbl 12000 `"Middle Africa"', add
label define bplctrylbl 12010 `"Angola"', add
label define bplctrylbl 12020 `"Cameroon"', add
label define bplctrylbl 12030 `"Central African Republic"', add
label define bplctrylbl 12040 `"Chad"', add
label define bplctrylbl 12050 `"Congo"', add
label define bplctrylbl 12060 `"Democratic Republic of Congo"', add
label define bplctrylbl 12070 `"Equatorial Guinea"', add
label define bplctrylbl 12080 `"Gabon"', add
label define bplctrylbl 12090 `"Sao Tome and Principe"', add
label define bplctrylbl 12999 `"Middle Africa, n.s."', add
label define bplctrylbl 13000 `"Northern Africa"', add
label define bplctrylbl 13010 `"Algeria"', add
label define bplctrylbl 13011 `"Algeria/Tunisia"', add
label define bplctrylbl 13020 `"Egypt"', add
label define bplctrylbl 13021 `"Egypt/Sudan"', add
label define bplctrylbl 13030 `"Libya"', add
label define bplctrylbl 13040 `"Morocco"', add
label define bplctrylbl 13050 `"Sudan"', add
label define bplctrylbl 13060 `"Tunisia"', add
label define bplctrylbl 13070 `"Western Sahara"', add
label define bplctrylbl 13999 `"Northern Africa, n.s."', add
label define bplctrylbl 14000 `"Southern Africa"', add
label define bplctrylbl 14010 `"Botswana"', add
label define bplctrylbl 14020 `"Lesotho"', add
label define bplctrylbl 14030 `"Namibia"', add
label define bplctrylbl 14040 `"South Africa (Union of)"', add
label define bplctrylbl 14050 `"Swaziland"', add
label define bplctrylbl 14999 `"Southern Africa, n.s."', add
label define bplctrylbl 15000 `"Western Africa"', add
label define bplctrylbl 15010 `"Benin"', add
label define bplctrylbl 15020 `"Burkina Faso"', add
label define bplctrylbl 15030 `"Cape Verde"', add
label define bplctrylbl 15040 `"Ivory Coast"', add
label define bplctrylbl 15050 `"Gambia"', add
label define bplctrylbl 15060 `"Ghana"', add
label define bplctrylbl 15070 `"Guinea"', add
label define bplctrylbl 15080 `"Guinea-Bissau"', add
label define bplctrylbl 15090 `"Liberia"', add
label define bplctrylbl 15100 `"Mali"', add
label define bplctrylbl 15110 `"Mauritania"', add
label define bplctrylbl 15120 `"Niger"', add
label define bplctrylbl 15130 `"Nigeria"', add
label define bplctrylbl 15140 `"St. Helena and Ascension"', add
label define bplctrylbl 15150 `"Senegal"', add
label define bplctrylbl 15160 `"Sierra Leone"', add
label define bplctrylbl 15170 `"Togo"', add
label define bplctrylbl 15999 `"West Africa, n.s."', add
label define bplctrylbl 19999 `"Africa, n.s."', add
label define bplctrylbl 20000 `"Americas"', add
label define bplctrylbl 21000 `"Caribbean"', add
label define bplctrylbl 21010 `"Anguilla"', add
label define bplctrylbl 21020 `"Antigua-Barbuda"', add
label define bplctrylbl 21030 `"Aruba"', add
label define bplctrylbl 21040 `"Bahamas"', add
label define bplctrylbl 21050 `"Barbados"', add
label define bplctrylbl 21060 `"British Virgin Islands"', add
label define bplctrylbl 21070 `"Cayman Isles"', add
label define bplctrylbl 21080 `"Cuba"', add
label define bplctrylbl 21090 `"Dominica"', add
label define bplctrylbl 21100 `"Dominican Republic"', add
label define bplctrylbl 21110 `"Grenada"', add
label define bplctrylbl 21120 `"Guadeloupe"', add
label define bplctrylbl 21130 `"Haiti"', add
label define bplctrylbl 21140 `"Jamaica"', add
label define bplctrylbl 21150 `"Martinique"', add
label define bplctrylbl 21160 `"Montserrat"', add
label define bplctrylbl 21170 `"Netherlands Antilles"', add
label define bplctrylbl 21180 `"Puerto Rico"', add
label define bplctrylbl 21190 `"St. Kitts-Nevis"', add
label define bplctrylbl 21200 `"St. Lucia"', add
label define bplctrylbl 21210 `"St. Vincent"', add
label define bplctrylbl 21220 `"Trinidad and Tobago"', add
label define bplctrylbl 21230 `"Turks and Caicos"', add
label define bplctrylbl 21999 `"Caribbean, n.s."', add
label define bplctrylbl 22000 `"Central America"', add
label define bplctrylbl 22010 `"Belize/British Honduras"', add
label define bplctrylbl 22020 `"Costa Rica"', add
label define bplctrylbl 22030 `"El Salvador"', add
label define bplctrylbl 22040 `"Guatemala"', add
label define bplctrylbl 22050 `"Honduras"', add
label define bplctrylbl 22060 `"Mexico"', add
label define bplctrylbl 22070 `"Nicaragua"', add
label define bplctrylbl 22080 `"Panama"', add
label define bplctrylbl 22081 `"Panama Canal Zone"', add
label define bplctrylbl 22999 `"Central America, n.s."', add
label define bplctrylbl 23000 `"South America"', add
label define bplctrylbl 23010 `"Argentina"', add
label define bplctrylbl 23020 `"Bolivia"', add
label define bplctrylbl 23030 `"Brazil"', add
label define bplctrylbl 23040 `"Chile"', add
label define bplctrylbl 23050 `"Colombia"', add
label define bplctrylbl 23060 `"Ecuador"', add
label define bplctrylbl 23070 `"Falkland Islands"', add
label define bplctrylbl 23080 `"French Guiana"', add
label define bplctrylbl 23090 `"Guyana/British Guiana"', add
label define bplctrylbl 23100 `"Paraguay"', add
label define bplctrylbl 23110 `"Peru"', add
label define bplctrylbl 23120 `"Suriname"', add
label define bplctrylbl 23130 `"Uruguay"', add
label define bplctrylbl 23140 `"Venezuela"', add
label define bplctrylbl 23990 `"South America, n.s."', add
label define bplctrylbl 23991 `"South America or Central America, n.s."', add
label define bplctrylbl 23992 `"Central/South America and Caribbean"', add
label define bplctrylbl 24000 `"North America"', add
label define bplctrylbl 24010 `"Bermuda"', add
label define bplctrylbl 24020 `"Canada"', add
label define bplctrylbl 24030 `"Greenland"', add
label define bplctrylbl 24040 `"United States"', add
label define bplctrylbl 24041 `"U.S. Outlying Areas and Territories"', add
label define bplctrylbl 24990 `"North America, n.s."', add
label define bplctrylbl 24991 `"North America/Oceania"', add
label define bplctrylbl 29990 `"Americas, n.s."', add
label define bplctrylbl 30000 `"Asia"', add
label define bplctrylbl 31000 `"Eastern Asia"', add
label define bplctrylbl 31010 `"China"', add
label define bplctrylbl 31011 `"Hong Kong"', add
label define bplctrylbl 31012 `"Macau"', add
label define bplctrylbl 31013 `"Taiwan"', add
label define bplctrylbl 31020 `"Japan"', add
label define bplctrylbl 31030 `"Korea"', add
label define bplctrylbl 31031 `"North Korea"', add
label define bplctrylbl 31032 `"South Korea"', add
label define bplctrylbl 31040 `"Mongolia"', add
label define bplctrylbl 31999 `"Eastern Asia, n.s."', add
label define bplctrylbl 32000 `"South-Central Asia"', add
label define bplctrylbl 32010 `"Afghanistan"', add
label define bplctrylbl 32020 `"Bangladesh"', add
label define bplctrylbl 32030 `"Bhutan"', add
label define bplctrylbl 32040 `"India"', add
label define bplctrylbl 32041 `"India/Pakistan"', add
label define bplctrylbl 32042 `"India/Pakistan/Bangladesh/Sri Lanka"', add
label define bplctrylbl 32050 `"Iran"', add
label define bplctrylbl 32060 `"Kazakhstan"', add
label define bplctrylbl 32070 `"Kyrgyzstan"', add
label define bplctrylbl 32080 `"Maldives"', add
label define bplctrylbl 32090 `"Nepal"', add
label define bplctrylbl 32100 `"Pakistan"', add
label define bplctrylbl 32101 `"Pakistan/Bangladesh"', add
label define bplctrylbl 32110 `"Sri Lanka (Ceylon)"', add
label define bplctrylbl 32120 `"Tajikistan"', add
label define bplctrylbl 32130 `"Turkmenistan"', add
label define bplctrylbl 32140 `"Uzbekistan"', add
label define bplctrylbl 32999 `"South-Central Asia, n.s."', add
label define bplctrylbl 33000 `"South-Eastern Asia"', add
label define bplctrylbl 33010 `"Brunei"', add
label define bplctrylbl 33020 `"Cambodia (Kampuchea)"', add
label define bplctrylbl 33030 `"East Timor"', add
label define bplctrylbl 33040 `"Indonesia"', add
label define bplctrylbl 33050 `"Laos"', add
label define bplctrylbl 33060 `"Malaysia"', add
label define bplctrylbl 33070 `"Myanmar (Burma)"', add
label define bplctrylbl 33080 `"Philippines"', add
label define bplctrylbl 33090 `"Singapore"', add
label define bplctrylbl 33100 `"Thailand"', add
label define bplctrylbl 33110 `"Vietnam"', add
label define bplctrylbl 33990 `"South-Eastern Asia, n.s."', add
label define bplctrylbl 34000 `"Western Asia"', add
label define bplctrylbl 34010 `"Armenia"', add
label define bplctrylbl 34020 `"Azerbaijan"', add
label define bplctrylbl 34030 `"Bahrain"', add
label define bplctrylbl 34040 `"Cyprus"', add
label define bplctrylbl 34050 `"Georgia"', add
label define bplctrylbl 34060 `"Iraq"', add
label define bplctrylbl 34070 `"Israel"', add
label define bplctrylbl 34080 `"Jordan"', add
label define bplctrylbl 34090 `"Kuwait"', add
label define bplctrylbl 34100 `"Lebanon"', add
label define bplctrylbl 34110 `"Palestinian Territories"', add
label define bplctrylbl 34111 `"West Bank"', add
label define bplctrylbl 34112 `"Gaza Strip"', add
label define bplctrylbl 34120 `"Oman"', add
label define bplctrylbl 34130 `"Qatar"', add
label define bplctrylbl 34140 `"Saudi Arabia"', add
label define bplctrylbl 34150 `"Syria"', add
label define bplctrylbl 34151 `"Syria/Lebanon"', add
label define bplctrylbl 34160 `"Turkey"', add
label define bplctrylbl 34170 `"United Arab Emirates"', add
label define bplctrylbl 34180 `"Yemen"', add
label define bplctrylbl 34990 `"Western Asia, n.s."', add
label define bplctrylbl 34991 `"Middle East"', add
label define bplctrylbl 39990 `"Asia, n.s."', add
label define bplctrylbl 39991 `"Central Asia and Middle East, n.s."', add
label define bplctrylbl 39992 `"Far East, n.s."', add
label define bplctrylbl 39993 `"Eastern/Southeast Asia, n.s."', add
label define bplctrylbl 40000 `"Europe"', add
label define bplctrylbl 41000 `"Eastern Europe"', add
label define bplctrylbl 41010 `"Belarus"', add
label define bplctrylbl 41020 `"Bulgaria"', add
label define bplctrylbl 41021 `"Bulgaria/Greece"', add
label define bplctrylbl 41030 `"Czech Republic"', add
label define bplctrylbl 41040 `"Hungary"', add
label define bplctrylbl 41050 `"Poland"', add
label define bplctrylbl 41060 `"Moldova"', add
label define bplctrylbl 41070 `"Romania"', add
label define bplctrylbl 41080 `"Russia/USSR"', add
label define bplctrylbl 41090 `"Slovakia"', add
label define bplctrylbl 41100 `"Ukraine"', add
label define bplctrylbl 41990 `"Eastern Europe, n.s."', add
label define bplctrylbl 41991 `"Albania, Bulgaria, Czech, Hungary, Romania,  Yugoslavia"', add
label define bplctrylbl 42000 `"Northern Europe"', add
label define bplctrylbl 42010 `"Denmark"', add
label define bplctrylbl 42020 `"Estonia"', add
label define bplctrylbl 42030 `"Faroe Islands"', add
label define bplctrylbl 42040 `"Finland"', add
label define bplctrylbl 42050 `"Iceland"', add
label define bplctrylbl 42060 `"Ireland"', add
label define bplctrylbl 42070 `"Latvia"', add
label define bplctrylbl 42080 `"Lithuania"', add
label define bplctrylbl 42090 `"Norway"', add
label define bplctrylbl 42100 `"Svalbard and Jan Mayen Islands"', add
label define bplctrylbl 42110 `"Sweden"', add
label define bplctrylbl 42120 `"United Kingdom"', add
label define bplctrylbl 42999 `"Northern Europe, n.s."', add
label define bplctrylbl 43000 `"Southern Europe"', add
label define bplctrylbl 43010 `"Albania"', add
label define bplctrylbl 43020 `"Andorra"', add
label define bplctrylbl 43030 `"Bosnia and Herzegovian"', add
label define bplctrylbl 43040 `"Croatia"', add
label define bplctrylbl 43050 `"Gibraltar"', add
label define bplctrylbl 43060 `"Greece"', add
label define bplctrylbl 43070 `"Italy"', add
label define bplctrylbl 43071 `"Vatican City"', add
label define bplctrylbl 43080 `"Malta"', add
label define bplctrylbl 43090 `"Portugal"', add
label define bplctrylbl 43100 `"San Marino"', add
label define bplctrylbl 43110 `"Slovenia"', add
label define bplctrylbl 43120 `"Spain"', add
label define bplctrylbl 43121 `"Spain/Portugal"', add
label define bplctrylbl 43130 `"Macedonia"', add
label define bplctrylbl 43140 `"Yugoslavia"', add
label define bplctrylbl 43141 `"Montenegro"', add
label define bplctrylbl 43142 `"Serbia"', add
label define bplctrylbl 43143 `"Kosovo"', add
label define bplctrylbl 43990 `"Southern Europe, n.s."', add
label define bplctrylbl 43991 `"Gibraltar/Malta"', add
label define bplctrylbl 43992 `"Portugal/Greece"', add
label define bplctrylbl 44000 `"Western Europe"', add
label define bplctrylbl 44010 `"Austria"', add
label define bplctrylbl 44020 `"Belgium"', add
label define bplctrylbl 44021 `"Belgium/Luxemburg"', add
label define bplctrylbl 44030 `"France"', add
label define bplctrylbl 44040 `"Germany"', add
label define bplctrylbl 44041 `"Germany/Austria"', add
label define bplctrylbl 44050 `"Liechtenstein"', add
label define bplctrylbl 44060 `"Luxembourg"', add
label define bplctrylbl 44070 `"Monaco"', add
label define bplctrylbl 44080 `"Netherlands"', add
label define bplctrylbl 44090 `"Switzerland"', add
label define bplctrylbl 44990 `"Western Europe, n.s."', add
label define bplctrylbl 44991 `"Belgium, Denmark, Luxembourg, Netherlands"', add
label define bplctrylbl 49900 `"Europe, n.s."', add
label define bplctrylbl 49910 `"Turkey and U.S.S.R."', add
label define bplctrylbl 50000 `"Oceania"', add
label define bplctrylbl 51000 `"Australia and New Zealand"', add
label define bplctrylbl 51010 `"Australia"', add
label define bplctrylbl 51020 `"New Zealand"', add
label define bplctrylbl 51030 `"Norfolk Islands"', add
label define bplctrylbl 51999 `"Australia and New Zealand, n.s."', add
label define bplctrylbl 52000 `"Melanesia"', add
label define bplctrylbl 52010 `"Fiji"', add
label define bplctrylbl 52020 `"New Caledonia"', add
label define bplctrylbl 52030 `"Papua New Guinea"', add
label define bplctrylbl 52040 `"Solomon Islands"', add
label define bplctrylbl 52050 `"Vanuatu (New Hebrides)"', add
label define bplctrylbl 52999 `"Melanesia, n.s."', add
label define bplctrylbl 53000 `"Micronesia"', add
label define bplctrylbl 53010 `"Kiribati"', add
label define bplctrylbl 53020 `"Marshall Islands"', add
label define bplctrylbl 53030 `"Nauru"', add
label define bplctrylbl 53040 `"Northern Mariana Isls."', add
label define bplctrylbl 53050 `"Palau"', add
label define bplctrylbl 53999 `"Micronesia, n.e.c."', add
label define bplctrylbl 54000 `"Polynesia"', add
label define bplctrylbl 54010 `"Cook Islands"', add
label define bplctrylbl 54020 `"French Polynesia"', add
label define bplctrylbl 54030 `"Niue"', add
label define bplctrylbl 54040 `"Pitcairn Island"', add
label define bplctrylbl 54050 `"Western Samoa"', add
label define bplctrylbl 54060 `"Eastern Samoa"', add
label define bplctrylbl 54070 `"Tokelau"', add
label define bplctrylbl 54080 `"Tonga"', add
label define bplctrylbl 54090 `"Tuvalu"', add
label define bplctrylbl 54100 `"Wallis and Futuna Isls."', add
label define bplctrylbl 54999 `"Polynesia, n.s."', add
label define bplctrylbl 59999 `"Oceania, n.s."', add
label define bplctrylbl 99999 `"Unknown"', add
label values bplctry bplctrylbl

label define bplmxlbl 01 `"Aguascalientes"'
label define bplmxlbl 02 `"Baja California"', add
label define bplmxlbl 03 `"Baja California Sur"', add
label define bplmxlbl 04 `"Campeche"', add
label define bplmxlbl 05 `"Coahuila"', add
label define bplmxlbl 06 `"Colima"', add
label define bplmxlbl 07 `"Chiapas"', add
label define bplmxlbl 08 `"Chihuahua"', add
label define bplmxlbl 09 `"Distrito Federal"', add
label define bplmxlbl 10 `"Durango"', add
label define bplmxlbl 11 `"Guanajuato"', add
label define bplmxlbl 12 `"Guerrero"', add
label define bplmxlbl 13 `"Hidalgo"', add
label define bplmxlbl 14 `"Jalisco"', add
label define bplmxlbl 15 `"México"', add
label define bplmxlbl 16 `"Michoacán"', add
label define bplmxlbl 17 `"Morelos"', add
label define bplmxlbl 18 `"Nayarit"', add
label define bplmxlbl 19 `"Nuevo León"', add
label define bplmxlbl 20 `"Oaxaca"', add
label define bplmxlbl 21 `"Puebla"', add
label define bplmxlbl 22 `"Querétaro"', add
label define bplmxlbl 23 `"Quintana Roo"', add
label define bplmxlbl 24 `"San Luis Potosí"', add
label define bplmxlbl 25 `"Sinaloa"', add
label define bplmxlbl 26 `"Sonora"', add
label define bplmxlbl 27 `"Tabasco"', add
label define bplmxlbl 28 `"Tamaulipas"', add
label define bplmxlbl 29 `"Tlaxcala"', add
label define bplmxlbl 30 `"Veracruz"', add
label define bplmxlbl 31 `"Yucatán"', add
label define bplmxlbl 32 `"Zacatecas"', add
label define bplmxlbl 98 `"Foreign-born"', add
label define bplmxlbl 99 `"Missing/unknown"', add
label values bplmx bplmxlbl

label define schoollbl 0 `"NIU (not in universe)"'
label define schoollbl 1 `"Yes"', add
label define schoollbl 2 `"No, not specified"', add
label define schoollbl 3 `"No, attended in the past"', add
label define schoollbl 4 `"No, never attended"', add
label define schoollbl 9 `"Unknown/missing"', add
label values school schoollbl

label define yrschllbl 00 `"None or pre-school"'
label define yrschllbl 01 `"1 year"', add
label define yrschllbl 02 `"2 years"', add
label define yrschllbl 03 `"3 years"', add
label define yrschllbl 04 `"4 years"', add
label define yrschllbl 05 `"5 years"', add
label define yrschllbl 06 `"6 years"', add
label define yrschllbl 07 `"7 years"', add
label define yrschllbl 08 `"8 years"', add
label define yrschllbl 09 `"9 years"', add
label define yrschllbl 10 `"10 years"', add
label define yrschllbl 11 `"11 years"', add
label define yrschllbl 12 `"12 years"', add
label define yrschllbl 13 `"13 years"', add
label define yrschllbl 14 `"14 years"', add
label define yrschllbl 15 `"15 years"', add
label define yrschllbl 16 `"16 years"', add
label define yrschllbl 17 `"17 years"', add
label define yrschllbl 18 `"18 years or more"', add
label define yrschllbl 90 `"Not specified"', add
label define yrschllbl 91 `"Some primary"', add
label define yrschllbl 92 `"Some technical after primary"', add
label define yrschllbl 93 `"Some secondary"', add
label define yrschllbl 94 `"Some tertiary"', add
label define yrschllbl 95 `"Adult literacy"', add
label define yrschllbl 96 `"Special education (Venezuela)"', add
label define yrschllbl 97 `"Response suppressed"', add
label define yrschllbl 98 `"Unknown/missing"', add
label define yrschllbl 99 `"NIU (not in universe)"', add
label values yrschl yrschllbl

label define empstatlbl 0 `"NIU"'
label define empstatlbl 1 `"Employed"', add
label define empstatlbl 2 `"Unemployed"', add
label define empstatlbl 3 `"Inactive"', add
label define empstatlbl 9 `"Unknown/missing"', add
label values empstat empstatlbl

label define empstatdlbl 000 `"NIU (not in universe)"', add
label define empstatdlbl 100 `"Employed, not specified"', add
label define empstatdlbl 110 `"At work"', add
label define empstatdlbl 111 `"At work, and 'student'"', add
label define empstatdlbl 112 `"At work, and 'housework'"', add
label define empstatdlbl 113 `"At work, and 'seeking work'"', add
label define empstatdlbl 114 `"At work, and 'retired'"', add
label define empstatdlbl 115 `"At work, and 'no work'"', add
label define empstatdlbl 116 `"At work, and 'other'"', add
label define empstatdlbl 117 `"At work, family holding, not specified"', add
label define empstatdlbl 118 `"At work, family holding, not agricultural"', add
label define empstatdlbl 119 `"At work, family holding, agricultural"', add
label define empstatdlbl 120 `"Have job, not at work last week"', add
label define empstatdlbl 130 `"Armed forces"', add
label define empstatdlbl 131 `"Armed forces, at work"', add
label define empstatdlbl 132 `"Armed forces, not at work last week"', add
label define empstatdlbl 133 `"Military trainee"', add
label define empstatdlbl 140 `"Marginally employed"', add
label define empstatdlbl 200 `"Unemployed, not specified"', add
label define empstatdlbl 201 `"Unemployed 6 or more months"', add
label define empstatdlbl 202 `"Worked less than 6 months, permanent job"', add
label define empstatdlbl 203 `"Worked less than 6 months, temporary job"', add
label define empstatdlbl 210 `"Unemployed, experienced worker"', add
label define empstatdlbl 220 `"Unemployed, new worker"', add
label define empstatdlbl 230 `"No work available"', add
label define empstatdlbl 240 `"Inactive unemployed"', add
label define empstatdlbl 300 `"Inactive (not in labor force)"', add
label define empstatdlbl 310 `"Housework"', add
label define empstatdlbl 320 `"Unable to work/disabled"', add
label define empstatdlbl 321 `"Permanent disability"', add
label define empstatdlbl 322 `"Temporary illness"', add
label define empstatdlbl 323 `"Disabled or imprisoned"', add
label define empstatdlbl 330 `"In school"', add
label define empstatdlbl 340 `"Retirees and living on rent"', add
label define empstatdlbl 341 `"Living on rents"', add
label define empstatdlbl 342 `"Living on rents or pension"', add
label define empstatdlbl 343 `"Retirees/pensioners"', add
label define empstatdlbl 344 `"Retired"', add
label define empstatdlbl 345 `"Pensioner"', add
label define empstatdlbl 346 `"Non-retirement pension"', add
label define empstatdlbl 347 `"Disability pension"', add
label define empstatdlbl 348 `"Retired without benefits"', add
label define empstatdlbl 350 `"Elderly"', add
label define empstatdlbl 360 `"Institutionalized"', add
label define empstatdlbl 361 `"Prisoner"', add
label define empstatdlbl 370 `"Intermittant worker"', add
label define empstatdlbl 371 `"Not working, seasonal worker"', add
label define empstatdlbl 372 `"Not working, occasional worker"', add
label define empstatdlbl 380 `"Other income recipient"', add
label define empstatdlbl 390 `"Inactive, other reasons"', add
label define empstatdlbl 999 `"Unknown/missing"', add
label values empstatd empstatdlbl

label define occiscolbl 01 `"Legislators, senior officials and managers"'
label define occiscolbl 02 `"Professionals"', add
label define occiscolbl 03 `"Technicians and associate professionals"', add
label define occiscolbl 04 `"Clerks"', add
label define occiscolbl 05 `"Service workers and shop and market sales"', add
label define occiscolbl 06 `"Skilled agricultural and fishery workers"', add
label define occiscolbl 07 `"Crafts and related trades workers"', add
label define occiscolbl 08 `"Plant and machine operators and assemblers"', add
label define occiscolbl 09 `"Elementary occupations"', add
label define occiscolbl 10 `"Armed forces"', add
label define occiscolbl 11 `"Other occupations, unspecified or n.e.c."', add
label define occiscolbl 97 `"Response suppressed"', add
label define occiscolbl 98 `"Unknown"', add
label define occiscolbl 99 `"NIU (not in universe)"', add
label values occisco occiscolbl

label values occ occlbl

label define indgenlbl 000 `"NIU (not in universe)"'
label define indgenlbl 010 `"Agriculture, fishing, and forestry"', add
label define indgenlbl 020 `"Mining"', add
label define indgenlbl 030 `"Manufacturing"', add
label define indgenlbl 040 `"Electricity, gas and water"', add
label define indgenlbl 050 `"Construction"', add
label define indgenlbl 060 `"Wholesale and retail trade"', add
label define indgenlbl 070 `"Hotels and restaurants"', add
label define indgenlbl 080 `"Transportation and communications"', add
label define indgenlbl 090 `"Financial services and insurance"', add
label define indgenlbl 100 `"Public administration and defense"', add
label define indgenlbl 110 `"Services, n.e.c."', add
label define indgenlbl 111 `"Real estate and business services"', add
label define indgenlbl 112 `"Education"', add
label define indgenlbl 113 `"Health and social work"', add
label define indgenlbl 114 `"Other community and personal services"', add
label define indgenlbl 120 `"Private household services"', add
label define indgenlbl 130 `"Other industry, n.e.c."', add
label define indgenlbl 998 `"Response suppressed"', add
label define indgenlbl 999 `"Unknown"', add
label values indgen indgenlbl

label values ind indlbl

label define classwklbl 0 `"NIU"'
label define classwklbl 1 `"Self-employed"', add
label define classwklbl 2 `"Wage/salary worker"', add
label define classwklbl 3 `"Unpaid worker"', add
label define classwklbl 4 `"Other"', add
label define classwklbl 9 `"Unknown/missing"', add
label values classwk classwklbl

label define classwkdlbl 000 `"NIU (not in universe)"'
label define classwkdlbl 100 `"Self-employed"', add
label define classwkdlbl 101 `"Self-employed, unincorporated"', add
label define classwkdlbl 102 `"Self-employed, incorporated"', add
label define classwkdlbl 110 `"Employer"', add
label define classwkdlbl 111 `"Sharecropper, employer"', add
label define classwkdlbl 120 `"Working on own account"', add
label define classwkdlbl 121 `"Own account, agriculture"', add
label define classwkdlbl 122 `"Domestic worker, self-employed"', add
label define classwkdlbl 123 `"Subsistence worker, own consumption"', add
label define classwkdlbl 124 `"Own account, other"', add
label define classwkdlbl 130 `"Member of cooperative"', add
label define classwkdlbl 140 `"Sharecropper"', add
label define classwkdlbl 141 `"Sharecropper, self-employed"', add
label define classwkdlbl 142 `"Sharecropper, employee"', add
label define classwkdlbl 150 `"Kibbutz member"', add
label define classwkdlbl 200 `"Wage/salary worker"', add
label define classwkdlbl 201 `"Works on salary"', add
label define classwkdlbl 202 `"White collar"', add
label define classwkdlbl 203 `"Blue collar"', add
label define classwkdlbl 204 `"White and blue collar"', add
label define classwkdlbl 205 `"Day laborer"', add
label define classwkdlbl 206 `"Employee, with signed work card"', add
label define classwkdlbl 207 `"Employee, without signed work card"', add
label define classwkdlbl 208 `"Employee, with a permanent job"', add
label define classwkdlbl 209 `"Employee, with an occasional or temporary job"', add
label define classwkdlbl 210 `"Domestic worker (work for private household)"', add
label define classwkdlbl 211 `"Domestic worker, with signed work card"', add
label define classwkdlbl 212 `"Domestic worker, without signed work card"', add
label define classwkdlbl 220 `"Seasonal migrant"', add
label define classwkdlbl 221 `"Seasonal migrant, no broker"', add
label define classwkdlbl 222 `"Seasonal migrant, uses broker"', add
label define classwkdlbl 230 `"Wage/salary worker, private employer"', add
label define classwkdlbl 231 `"Apprentice"', add
label define classwkdlbl 232 `"Religious worker"', add
label define classwkdlbl 233 `"Wage/salary worker, non-profit"', add
label define classwkdlbl 234 `"White collar"', add
label define classwkdlbl 235 `"Blue collar"', add
label define classwkdlbl 236 `"Paid family worker"', add
label define classwkdlbl 237 `"Cooperative employee"', add
label define classwkdlbl 240 `"Wage/salary worker, government"', add
label define classwkdlbl 241 `"Federal, government employee"', add
label define classwkdlbl 242 `"State government employee"', add
label define classwkdlbl 243 `"Local government employee"', add
label define classwkdlbl 244 `"White collar, public"', add
label define classwkdlbl 245 `"Blue collar, public"', add
label define classwkdlbl 246 `"Public companies"', add
label define classwkdlbl 247 `"Civil servants, local collectives"', add
label define classwkdlbl 248 `"Public servant"', add
label define classwkdlbl 249 `"Public employee, state-owned company"', add
label define classwkdlbl 250 `"Other wage and salary"', add
label define classwkdlbl 251 `"Canal zone/commission employee"', add
label define classwkdlbl 252 `"Government employment/training program"', add
label define classwkdlbl 300 `"Unpaid worker"', add
label define classwkdlbl 310 `"Unpaid family worker"', add
label define classwkdlbl 320 `"Apprentice or trainee"', add
label define classwkdlbl 400 `"Other"', add
label define classwkdlbl 999 `"Unknown/missing"', add
label values classwkd classwkdlbl

label define hrswrk1lbl 000 `"0 hours"'
label define hrswrk1lbl 001 `"1 hour"', add
label define hrswrk1lbl 002 `"2 hours"', add
label define hrswrk1lbl 003 `"3 hours"', add
label define hrswrk1lbl 004 `"4 hours"', add
label define hrswrk1lbl 005 `"5 hours"', add
label define hrswrk1lbl 006 `"6 hours"', add
label define hrswrk1lbl 007 `"7 hours"', add
label define hrswrk1lbl 008 `"8 hours"', add
label define hrswrk1lbl 009 `"9 hours"', add
label define hrswrk1lbl 010 `"10 hours"', add
label define hrswrk1lbl 011 `"11 hours"', add
label define hrswrk1lbl 012 `"12 hours"', add
label define hrswrk1lbl 013 `"13 hours"', add
label define hrswrk1lbl 014 `"14 hours"', add
label define hrswrk1lbl 015 `"15 hours"', add
label define hrswrk1lbl 016 `"16 hours"', add
label define hrswrk1lbl 017 `"17 hours"', add
label define hrswrk1lbl 018 `"18 hours"', add
label define hrswrk1lbl 019 `"19 hours"', add
label define hrswrk1lbl 020 `"20 hours"', add
label define hrswrk1lbl 021 `"21 hours"', add
label define hrswrk1lbl 022 `"22 hours"', add
label define hrswrk1lbl 023 `"23 hours"', add
label define hrswrk1lbl 024 `"24 hours"', add
label define hrswrk1lbl 025 `"25 hours"', add
label define hrswrk1lbl 026 `"26 hours"', add
label define hrswrk1lbl 027 `"27 hours"', add
label define hrswrk1lbl 028 `"28 hours"', add
label define hrswrk1lbl 029 `"29 hours"', add
label define hrswrk1lbl 030 `"30 hours"', add
label define hrswrk1lbl 031 `"31 hours"', add
label define hrswrk1lbl 032 `"32 hours"', add
label define hrswrk1lbl 033 `"33 hours"', add
label define hrswrk1lbl 034 `"34 hours"', add
label define hrswrk1lbl 035 `"35 hours"', add
label define hrswrk1lbl 036 `"36 hours"', add
label define hrswrk1lbl 037 `"37 hours"', add
label define hrswrk1lbl 038 `"38 hours"', add
label define hrswrk1lbl 039 `"39 hours"', add
label define hrswrk1lbl 040 `"40 hours"', add
label define hrswrk1lbl 041 `"41 hours"', add
label define hrswrk1lbl 042 `"42 hours"', add
label define hrswrk1lbl 043 `"43 hours"', add
label define hrswrk1lbl 044 `"44 hours"', add
label define hrswrk1lbl 045 `"45 hours"', add
label define hrswrk1lbl 046 `"46 hours"', add
label define hrswrk1lbl 047 `"47 hours"', add
label define hrswrk1lbl 048 `"48 hours"', add
label define hrswrk1lbl 049 `"49 hours"', add
label define hrswrk1lbl 050 `"50 hours"', add
label define hrswrk1lbl 051 `"51 hours"', add
label define hrswrk1lbl 052 `"52 hours"', add
label define hrswrk1lbl 053 `"53 hours"', add
label define hrswrk1lbl 054 `"54 hours"', add
label define hrswrk1lbl 055 `"55 hours"', add
label define hrswrk1lbl 056 `"56 hours"', add
label define hrswrk1lbl 057 `"57 hours"', add
label define hrswrk1lbl 058 `"58 hours"', add
label define hrswrk1lbl 059 `"59 hours"', add
label define hrswrk1lbl 060 `"60 hours"', add
label define hrswrk1lbl 061 `"61 hours"', add
label define hrswrk1lbl 062 `"62 hours"', add
label define hrswrk1lbl 063 `"63 hours"', add
label define hrswrk1lbl 064 `"64 hours"', add
label define hrswrk1lbl 065 `"65 hours"', add
label define hrswrk1lbl 066 `"66 hours"', add
label define hrswrk1lbl 067 `"67 hours"', add
label define hrswrk1lbl 068 `"68 hours"', add
label define hrswrk1lbl 069 `"69 hours"', add
label define hrswrk1lbl 070 `"70 hours"', add
label define hrswrk1lbl 071 `"71 hours"', add
label define hrswrk1lbl 072 `"72 hours"', add
label define hrswrk1lbl 073 `"73 hours"', add
label define hrswrk1lbl 074 `"74 hours"', add
label define hrswrk1lbl 075 `"75 hours"', add
label define hrswrk1lbl 076 `"76 hours"', add
label define hrswrk1lbl 077 `"77 hours"', add
label define hrswrk1lbl 078 `"78 hours"', add
label define hrswrk1lbl 079 `"79 hours"', add
label define hrswrk1lbl 080 `"80 hours"', add
label define hrswrk1lbl 081 `"81 hours"', add
label define hrswrk1lbl 082 `"82 hours"', add
label define hrswrk1lbl 083 `"83 hours"', add
label define hrswrk1lbl 084 `"84 hours"', add
label define hrswrk1lbl 085 `"85 hours"', add
label define hrswrk1lbl 086 `"86 hours"', add
label define hrswrk1lbl 087 `"87 hours"', add
label define hrswrk1lbl 088 `"88 hours"', add
label define hrswrk1lbl 089 `"89 hours"', add
label define hrswrk1lbl 090 `"90 hours"', add
label define hrswrk1lbl 091 `"91 hours"', add
label define hrswrk1lbl 092 `"92 hours"', add
label define hrswrk1lbl 093 `"93 hours"', add
label define hrswrk1lbl 094 `"94 hours"', add
label define hrswrk1lbl 095 `"95 hours"', add
label define hrswrk1lbl 096 `"96 hours"', add
label define hrswrk1lbl 097 `"97 hours"', add
label define hrswrk1lbl 098 `"98 hours"', add
label define hrswrk1lbl 099 `"99 hours"', add
label define hrswrk1lbl 100 `"100 hours"', add
label define hrswrk1lbl 101 `"101 hours"', add
label define hrswrk1lbl 102 `"102 hours"', add
label define hrswrk1lbl 103 `"103 hours"', add
label define hrswrk1lbl 104 `"104 hours"', add
label define hrswrk1lbl 105 `"105 hours"', add
label define hrswrk1lbl 106 `"106 hours"', add
label define hrswrk1lbl 107 `"107 hours"', add
label define hrswrk1lbl 108 `"108 hours"', add
label define hrswrk1lbl 109 `"109 hours"', add
label define hrswrk1lbl 110 `"110 hours"', add
label define hrswrk1lbl 111 `"111 hours"', add
label define hrswrk1lbl 112 `"112 hours"', add
label define hrswrk1lbl 113 `"113 hours"', add
label define hrswrk1lbl 114 `"114 hours"', add
label define hrswrk1lbl 115 `"115 hours"', add
label define hrswrk1lbl 116 `"116 hours"', add
label define hrswrk1lbl 117 `"117 hours"', add
label define hrswrk1lbl 118 `"118 hours"', add
label define hrswrk1lbl 119 `"119 hours"', add
label define hrswrk1lbl 120 `"120 hours"', add
label define hrswrk1lbl 121 `"121 hours"', add
label define hrswrk1lbl 122 `"122 hours"', add
label define hrswrk1lbl 123 `"123 hours"', add
label define hrswrk1lbl 124 `"124 hours"', add
label define hrswrk1lbl 125 `"125 hours"', add
label define hrswrk1lbl 126 `"126 hours"', add
label define hrswrk1lbl 127 `"127 hours"', add
label define hrswrk1lbl 128 `"128 hours"', add
label define hrswrk1lbl 129 `"129 hours"', add
label define hrswrk1lbl 130 `"130 hours"', add
label define hrswrk1lbl 131 `"131 hours"', add
label define hrswrk1lbl 132 `"132 hours"', add
label define hrswrk1lbl 133 `"133 hours"', add
label define hrswrk1lbl 134 `"134 hours"', add
label define hrswrk1lbl 135 `"135 hours"', add
label define hrswrk1lbl 136 `"136 hours"', add
label define hrswrk1lbl 137 `"137 hours"', add
label define hrswrk1lbl 138 `"138 hours"', add
label define hrswrk1lbl 139 `"139 hours"', add
label define hrswrk1lbl 140 `"140+ hours"', add
label define hrswrk1lbl 998 `"Unknown"', add
label define hrswrk1lbl 999 `"NIU (not in universe)"', add
label values hrswrk1 hrswrk1lbl

label define inctotlbl 9999998 `"Unknown"', add
label define inctotlbl 9999999 `"NIU (not in universe)"', add
label values inctot inctotlbl

label define incearnlbl 00000000 `"0"'
label define incearnlbl 00000125 `"125"', add
label define incearnlbl 00000375 `"375"', add
label define incearnlbl 00000550 `"550"', add
label define incearnlbl 00000625 `"625"', add
label define incearnlbl 00000875 `"875"', add
label define incearnlbl 00001050 `"1050"', add
label define incearnlbl 00001250 `"1250"', add
label define incearnlbl 00001750 `"1750"', add
label define incearnlbl 00002000 `"2000"', add
label define incearnlbl 00003500 `"3500"', add
label define incearnlbl 00005000 `"5000"', add
label define incearnlbl 00006500 `"6500"', add
label define incearnlbl 00007700 `"7700"', add
label define incearnlbl 00009200 `"9200"', add
label define incearnlbl 00011000 `"11000"', add
label define incearnlbl 00014000 `"14000"', add
label define incearnlbl 00016000 `"16000"', add
label define incearnlbl 99999998 `"Missing/unknown"', add
label define incearnlbl 99999999 `"NIU (not in universe)"', add
label values incearn incearnlbl

label define incwellbl 000000 `"0"'
label define incwellbl 000175 `"175"', add
label define incwellbl 000375 `"375"', add
label define incwellbl 000625 `"625"', add
label define incwellbl 000875 `"875"', add
label define incwellbl 001250 `"1250"', add
label define incwellbl 001750 `"1750"', add
label define incwellbl 002500 `"2500"', add
label define incwellbl 003000 `"3000"', add
label define incwellbl 999998 `"Unknown/missing"', add
label define incwellbl 999999 `"NIU (not in universe)"', add
label values incwel incwellbl

label define incretlbl 999998 `"Unknown/missing"', add
label define incretlbl 999999 `"NIU (not in universe)"', add
label values incret incretlbl

label define incfmablbl 999998 `"Unknown/missing"'
label define incfmablbl 999999 `"NIU (not in universe)"', add
label values incfmab incfmablbl

label define mgrate5lbl 00 `"NIU (not in universe)"'
label define mgrate5lbl 10 `"Same major administrative unit"', add
label define mgrate5lbl 11 `"Same major, same minor administrative unit"', add
label define mgrate5lbl 12 `"Same major, different minor administrative unit"', add
label define mgrate5lbl 20 `"Different major administrative unit"', add
label define mgrate5lbl 30 `"Abroad"', add
label define mgrate5lbl 99 `"Unknown/missing"', add
label values mgrate5 mgrate5lbl

label define mgrateplbl 00 `"NIU (not in universe)"'
label define mgrateplbl 10 `"Same major administrative unit"', add
label define mgrateplbl 11 `"Same major, same minor administrative unit"', add
label define mgrateplbl 12 `"Same major, different minor administrative unit"', add
label define mgrateplbl 20 `"Different major administrative unit"', add
label define mgrateplbl 30 `"Abroad"', add
label define mgrateplbl 98 `"Response suppressed"', add
label define mgrateplbl 99 `"Not reported/missing"', add
label values mgratep mgrateplbl

label define migmx1lbl 00 `"NIU (not in universe)"'
label define migmx1lbl 01 `"Aguascalientes"', add
label define migmx1lbl 02 `"Baja California"', add
label define migmx1lbl 03 `"Baja California Sur"', add
label define migmx1lbl 04 `"Campeche"', add
label define migmx1lbl 05 `"Coahuila"', add
label define migmx1lbl 06 `"Colima"', add
label define migmx1lbl 07 `"Chiapas"', add
label define migmx1lbl 08 `"Chihuahua"', add
label define migmx1lbl 09 `"Distrito Federal"', add
label define migmx1lbl 10 `"Durango"', add
label define migmx1lbl 11 `"Guanajuato"', add
label define migmx1lbl 12 `"Guerrero"', add
label define migmx1lbl 13 `"Hidalgo"', add
label define migmx1lbl 14 `"Jalisco"', add
label define migmx1lbl 15 `"México"', add
label define migmx1lbl 16 `"Michoacán"', add
label define migmx1lbl 17 `"Morelos"', add
label define migmx1lbl 18 `"Nayarit"', add
label define migmx1lbl 19 `"Nuevo León"', add
label define migmx1lbl 20 `"Oaxaca"', add
label define migmx1lbl 21 `"Puebla"', add
label define migmx1lbl 22 `"Querétaro"', add
label define migmx1lbl 23 `"Quintana Roo"', add
label define migmx1lbl 24 `"San Luis Potosí"', add
label define migmx1lbl 25 `"Sinaloa"', add
label define migmx1lbl 26 `"Sonora"', add
label define migmx1lbl 27 `"Tabasco"', add
label define migmx1lbl 28 `"Tamaulipas"', add
label define migmx1lbl 29 `"Tlaxcala"', add
label define migmx1lbl 30 `"Veracruz"', add
label define migmx1lbl 31 `"Yucatán"', add
label define migmx1lbl 32 `"Zacatecas"', add
label define migmx1lbl 98 `"Abroad"', add
label define migmx1lbl 99 `"Unknown"', add
label values migmx1 migmx1lbl

label define migmx2lbl 00 `"NIU (not in universe)"'
label define migmx2lbl 01 `"Aguascalientes"', add
label define migmx2lbl 02 `"Baja California"', add
label define migmx2lbl 03 `"Baja California Sur"', add
label define migmx2lbl 04 `"Campeche"', add
label define migmx2lbl 05 `"Coahuila"', add
label define migmx2lbl 06 `"Colima"', add
label define migmx2lbl 07 `"Chiapas"', add
label define migmx2lbl 08 `"Chihuahua"', add
label define migmx2lbl 09 `"Distrito Federal"', add
label define migmx2lbl 10 `"Durango"', add
label define migmx2lbl 11 `"Guanajuato"', add
label define migmx2lbl 12 `"Guerrero"', add
label define migmx2lbl 13 `"Hidalgo"', add
label define migmx2lbl 14 `"Jalisco"', add
label define migmx2lbl 15 `"México"', add
label define migmx2lbl 16 `"Michoacán"', add
label define migmx2lbl 17 `"Morelos"', add
label define migmx2lbl 18 `"Nayarit"', add
label define migmx2lbl 19 `"Nuevo León"', add
label define migmx2lbl 20 `"Oaxaca"', add
label define migmx2lbl 21 `"Puebla"', add
label define migmx2lbl 22 `"Querétaro"', add
label define migmx2lbl 23 `"Quintana Roo"', add
label define migmx2lbl 24 `"San Luis Potosí"', add
label define migmx2lbl 25 `"Sinaloa"', add
label define migmx2lbl 26 `"Sonora"', add
label define migmx2lbl 27 `"Tabasco"', add
label define migmx2lbl 28 `"Tamaulipas"', add
label define migmx2lbl 29 `"Tlaxcala"', add
label define migmx2lbl 30 `"Veracruz"', add
label define migmx2lbl 31 `"Yucatán"', add
label define migmx2lbl 32 `"Zacatecas"', add
label define migmx2lbl 98 `"Abroad"', add
label define migmx2lbl 99 `"Unknown"', add
label values migmx2 migmx2lbl

label define mgyrs1lbl 00 `"Less than 1 year"'
label define mgyrs1lbl 01 `"1 year (or 1 year or less)"', add
label define mgyrs1lbl 02 `"2 years"', add
label define mgyrs1lbl 03 `"3 years"', add
label define mgyrs1lbl 04 `"4 years"', add
label define mgyrs1lbl 05 `"5 years"', add
label define mgyrs1lbl 06 `"6 years"', add
label define mgyrs1lbl 07 `"7 years"', add
label define mgyrs1lbl 08 `"8 years"', add
label define mgyrs1lbl 09 `"9 years"', add
label define mgyrs1lbl 10 `"10 years"', add
label define mgyrs1lbl 11 `"11 years"', add
label define mgyrs1lbl 12 `"12 years"', add
label define mgyrs1lbl 13 `"13 years"', add
label define mgyrs1lbl 14 `"14 years"', add
label define mgyrs1lbl 15 `"15 years"', add
label define mgyrs1lbl 16 `"16 years"', add
label define mgyrs1lbl 17 `"17 years"', add
label define mgyrs1lbl 18 `"18 years"', add
label define mgyrs1lbl 19 `"19 years"', add
label define mgyrs1lbl 20 `"20 years"', add
label define mgyrs1lbl 21 `"21 years"', add
label define mgyrs1lbl 22 `"22 years"', add
label define mgyrs1lbl 23 `"23 years"', add
label define mgyrs1lbl 24 `"24 years"', add
label define mgyrs1lbl 25 `"25 years"', add
label define mgyrs1lbl 26 `"26 years"', add
label define mgyrs1lbl 27 `"27 years"', add
label define mgyrs1lbl 28 `"28 years"', add
label define mgyrs1lbl 29 `"29 years"', add
label define mgyrs1lbl 30 `"30 years"', add
label define mgyrs1lbl 31 `"31 years"', add
label define mgyrs1lbl 32 `"32 years"', add
label define mgyrs1lbl 33 `"33 years"', add
label define mgyrs1lbl 34 `"34 years"', add
label define mgyrs1lbl 35 `"35 years"', add
label define mgyrs1lbl 36 `"36 years"', add
label define mgyrs1lbl 37 `"37 years"', add
label define mgyrs1lbl 38 `"38 years"', add
label define mgyrs1lbl 39 `"39 years"', add
label define mgyrs1lbl 40 `"40 years"', add
label define mgyrs1lbl 41 `"41 years"', add
label define mgyrs1lbl 42 `"42 years"', add
label define mgyrs1lbl 43 `"43 years"', add
label define mgyrs1lbl 44 `"44 years"', add
label define mgyrs1lbl 45 `"45 years"', add
label define mgyrs1lbl 46 `"46 years"', add
label define mgyrs1lbl 47 `"47 years"', add
label define mgyrs1lbl 48 `"48 years"', add
label define mgyrs1lbl 49 `"49 years"', add
label define mgyrs1lbl 50 `"50 years"', add
label define mgyrs1lbl 51 `"51 years"', add
label define mgyrs1lbl 52 `"52 years"', add
label define mgyrs1lbl 53 `"53 years"', add
label define mgyrs1lbl 54 `"54 years"', add
label define mgyrs1lbl 55 `"55 years"', add
label define mgyrs1lbl 56 `"56 years"', add
label define mgyrs1lbl 57 `"57 years"', add
label define mgyrs1lbl 58 `"58 years"', add
label define mgyrs1lbl 59 `"59 years"', add
label define mgyrs1lbl 60 `"60 years"', add
label define mgyrs1lbl 61 `"61 years"', add
label define mgyrs1lbl 62 `"62 years"', add
label define mgyrs1lbl 63 `"63 years"', add
label define mgyrs1lbl 64 `"64 years"', add
label define mgyrs1lbl 65 `"65 years"', add
label define mgyrs1lbl 66 `"66 years"', add
label define mgyrs1lbl 67 `"67 years"', add
label define mgyrs1lbl 68 `"68 years"', add
label define mgyrs1lbl 69 `"69 years"', add
label define mgyrs1lbl 70 `"70 years"', add
label define mgyrs1lbl 71 `"71 years"', add
label define mgyrs1lbl 72 `"72 years"', add
label define mgyrs1lbl 73 `"73 years"', add
label define mgyrs1lbl 74 `"74 years"', add
label define mgyrs1lbl 75 `"75 years"', add
label define mgyrs1lbl 76 `"76 years"', add
label define mgyrs1lbl 77 `"77 years"', add
label define mgyrs1lbl 78 `"78 years"', add
label define mgyrs1lbl 79 `"79 years"', add
label define mgyrs1lbl 80 `"80 years"', add
label define mgyrs1lbl 81 `"81 years"', add
label define mgyrs1lbl 82 `"82 years"', add
label define mgyrs1lbl 83 `"83 years"', add
label define mgyrs1lbl 84 `"84 years"', add
label define mgyrs1lbl 85 `"85 years"', add
label define mgyrs1lbl 86 `"86 years"', add
label define mgyrs1lbl 87 `"87 years"', add
label define mgyrs1lbl 88 `"88 years"', add
label define mgyrs1lbl 89 `"89 years"', add
label define mgyrs1lbl 90 `"90 years"', add
label define mgyrs1lbl 91 `"91 years"', add
label define mgyrs1lbl 92 `"92 years"', add
label define mgyrs1lbl 93 `"93 years"', add
label define mgyrs1lbl 94 `"94 years"', add
label define mgyrs1lbl 95 `"95 years"', add
label define mgyrs1lbl 96 `"96 years"', add
label define mgyrs1lbl 97 `"97+"', add
label define mgyrs1lbl 98 `"Unknown"', add
label define mgyrs1lbl 99 `"NIU (not in universe)"', add
label values mgyrs1 mgyrs1lbl

label values mx95a_wtper mx95a_wtperlbl

label define mx95a_resprlbl 00 `"NIU (not in universe)"'
label define mx95a_resprlbl 01 `"Aguascalientes"', add
label define mx95a_resprlbl 02 `"Baja California"', add
label define mx95a_resprlbl 03 `"Baja California Sur"', add
label define mx95a_resprlbl 04 `"Campeche"', add
label define mx95a_resprlbl 05 `"Coahuila"', add
label define mx95a_resprlbl 06 `"Colima"', add
label define mx95a_resprlbl 07 `"Chiapas"', add
label define mx95a_resprlbl 08 `"Chihuahua"', add
label define mx95a_resprlbl 09 `"Federal District"', add
label define mx95a_resprlbl 10 `"Durango"', add
label define mx95a_resprlbl 11 `"Guanajuato"', add
label define mx95a_resprlbl 12 `"Guerrero"', add
label define mx95a_resprlbl 13 `"Hidalgo"', add
label define mx95a_resprlbl 14 `"Jalisco"', add
label define mx95a_resprlbl 15 `"Mexico"', add
label define mx95a_resprlbl 16 `"Michoacan"', add
label define mx95a_resprlbl 17 `"Morelos"', add
label define mx95a_resprlbl 18 `"Nayarit"', add
label define mx95a_resprlbl 19 `"Nuevo Leon"', add
label define mx95a_resprlbl 20 `"Oaxaca"', add
label define mx95a_resprlbl 21 `"Puebla"', add
label define mx95a_resprlbl 22 `"Queretaro"', add
label define mx95a_resprlbl 23 `"Quintana Roo"', add
label define mx95a_resprlbl 24 `"San Luis Potosi"', add
label define mx95a_resprlbl 25 `"Sinaloa"', add
label define mx95a_resprlbl 26 `"Sonora"', add
label define mx95a_resprlbl 27 `"Tabasco"', add
label define mx95a_resprlbl 28 `"Tamaulipas"', add
label define mx95a_resprlbl 29 `"Tlaxcala"', add
label define mx95a_resprlbl 30 `"Veracruz"', add
label define mx95a_resprlbl 31 `"Yucatan"', add
label define mx95a_resprlbl 32 `"Zacatecas"', add
label define mx95a_resprlbl 33 `"Africa"', add
label define mx95a_resprlbl 34 `"America (except the United States of America)"', add
label define mx95a_resprlbl 35 `"United States of America"', add
label define mx95a_resprlbl 36 `"Asia"', add
label define mx95a_resprlbl 37 `"Europe"', add
label define mx95a_resprlbl 38 `"Oceania"', add
label define mx95a_resprlbl 99 `"Unknown"', add
label values mx95a_respr mx95a_resprlbl

label define mx95a_resprmlbl 00 `"Less than a month"'
label define mx95a_resprmlbl 01 `"1 month"', add
label define mx95a_resprmlbl 02 `"2 months"', add
label define mx95a_resprmlbl 03 `"3 months"', add
label define mx95a_resprmlbl 04 `"4 months"', add
label define mx95a_resprmlbl 05 `"5 months"', add
label define mx95a_resprmlbl 06 `"6 months"', add
label define mx95a_resprmlbl 07 `"7 months"', add
label define mx95a_resprmlbl 08 `"8 months"', add
label define mx95a_resprmlbl 09 `"9 months"', add
label define mx95a_resprmlbl 10 `"10 months"', add
label define mx95a_resprmlbl 11 `"11 months"', add
label define mx95a_resprmlbl 98 `"Unknown"', add
label define mx95a_resprmlbl 99 `"NIU (not in universe)"', add
label values mx95a_resprm mx95a_resprmlbl

label define mx95a_presprylbl 00 `"NIU (not in universe)"'
label define mx95a_presprylbl 01 `"1"', add
label define mx95a_presprylbl 02 `"2"', add
label define mx95a_presprylbl 03 `"3"', add
label define mx95a_presprylbl 04 `"4"', add
label define mx95a_presprylbl 05 `"5"', add
label define mx95a_presprylbl 06 `"6"', add
label define mx95a_presprylbl 07 `"7"', add
label define mx95a_presprylbl 08 `"8"', add
label define mx95a_presprylbl 09 `"9"', add
label define mx95a_presprylbl 10 `"10"', add
label define mx95a_presprylbl 11 `"11"', add
label define mx95a_presprylbl 12 `"12"', add
label define mx95a_presprylbl 13 `"13"', add
label define mx95a_presprylbl 14 `"14"', add
label define mx95a_presprylbl 15 `"15"', add
label define mx95a_presprylbl 16 `"16"', add
label define mx95a_presprylbl 17 `"17"', add
label define mx95a_presprylbl 18 `"18"', add
label define mx95a_presprylbl 19 `"19"', add
label define mx95a_presprylbl 20 `"20"', add
label define mx95a_presprylbl 21 `"21"', add
label define mx95a_presprylbl 22 `"22"', add
label define mx95a_presprylbl 23 `"23"', add
label define mx95a_presprylbl 24 `"24"', add
label define mx95a_presprylbl 25 `"25"', add
label define mx95a_presprylbl 26 `"26"', add
label define mx95a_presprylbl 27 `"27"', add
label define mx95a_presprylbl 28 `"28"', add
label define mx95a_presprylbl 29 `"29"', add
label define mx95a_presprylbl 30 `"30"', add
label define mx95a_presprylbl 31 `"31"', add
label define mx95a_presprylbl 32 `"32"', add
label define mx95a_presprylbl 33 `"33"', add
label define mx95a_presprylbl 34 `"34"', add
label define mx95a_presprylbl 35 `"35"', add
label define mx95a_presprylbl 36 `"36"', add
label define mx95a_presprylbl 37 `"37"', add
label define mx95a_presprylbl 38 `"38"', add
label define mx95a_presprylbl 39 `"39"', add
label define mx95a_presprylbl 40 `"40"', add
label define mx95a_presprylbl 41 `"41"', add
label define mx95a_presprylbl 42 `"42"', add
label define mx95a_presprylbl 43 `"43"', add
label define mx95a_presprylbl 44 `"44"', add
label define mx95a_presprylbl 45 `"45"', add
label define mx95a_presprylbl 46 `"46"', add
label define mx95a_presprylbl 47 `"47"', add
label define mx95a_presprylbl 48 `"48"', add
label define mx95a_presprylbl 49 `"49"', add
label define mx95a_presprylbl 50 `"50"', add
label define mx95a_presprylbl 51 `"51"', add
label define mx95a_presprylbl 52 `"52"', add
label define mx95a_presprylbl 53 `"53"', add
label define mx95a_presprylbl 54 `"54"', add
label define mx95a_presprylbl 55 `"55"', add
label define mx95a_presprylbl 56 `"56"', add
label define mx95a_presprylbl 57 `"57"', add
label define mx95a_presprylbl 58 `"58"', add
label define mx95a_presprylbl 59 `"59"', add
label define mx95a_presprylbl 60 `"60"', add
label define mx95a_presprylbl 61 `"61"', add
label define mx95a_presprylbl 62 `"62"', add
label define mx95a_presprylbl 63 `"63"', add
label define mx95a_presprylbl 64 `"64"', add
label define mx95a_presprylbl 65 `"65"', add
label define mx95a_presprylbl 66 `"66"', add
label define mx95a_presprylbl 67 `"67"', add
label define mx95a_presprylbl 68 `"68"', add
label define mx95a_presprylbl 69 `"69"', add
label define mx95a_presprylbl 70 `"70"', add
label define mx95a_presprylbl 71 `"71"', add
label define mx95a_presprylbl 72 `"72"', add
label define mx95a_presprylbl 73 `"73"', add
label define mx95a_presprylbl 74 `"74"', add
label define mx95a_presprylbl 75 `"75"', add
label define mx95a_presprylbl 76 `"76"', add
label define mx95a_presprylbl 77 `"77"', add
label define mx95a_presprylbl 78 `"78"', add
label define mx95a_presprylbl 79 `"79"', add
label define mx95a_presprylbl 80 `"80"', add
label define mx95a_presprylbl 81 `"81"', add
label define mx95a_presprylbl 82 `"82"', add
label define mx95a_presprylbl 83 `"83"', add
label define mx95a_presprylbl 84 `"84"', add
label define mx95a_presprylbl 85 `"85"', add
label define mx95a_presprylbl 86 `"86"', add
label define mx95a_presprylbl 87 `"87"', add
label define mx95a_presprylbl 89 `"89"', add
label define mx95a_presprylbl 90 `"90"', add
label define mx95a_presprylbl 94 `"94"', add
label define mx95a_presprylbl 95 `"95"', add
label define mx95a_presprylbl 98 `"98"', add
label define mx95a_presprylbl 99 `"Unknown"', add
label values mx95a_prespry mx95a_presprylbl

label define mx95a_resdurmlbl 00 `"Less than a month"'
label define mx95a_resdurmlbl 01 `"1 month"', add
label define mx95a_resdurmlbl 02 `"2 months"', add
label define mx95a_resdurmlbl 03 `"3 months"', add
label define mx95a_resdurmlbl 04 `"4 months"', add
label define mx95a_resdurmlbl 05 `"5 months"', add
label define mx95a_resdurmlbl 06 `"6 months"', add
label define mx95a_resdurmlbl 07 `"7 months"', add
label define mx95a_resdurmlbl 08 `"8 months"', add
label define mx95a_resdurmlbl 09 `"9 months"', add
label define mx95a_resdurmlbl 10 `"10 months"', add
label define mx95a_resdurmlbl 11 `"11 months"', add
label define mx95a_resdurmlbl 98 `"Unknown"', add
label define mx95a_resdurmlbl 99 `"NIU (not in universe)"', add
label values mx95a_resdurm mx95a_resdurmlbl

label define mx95a_resdurylbl 00 `"NIU (not in universe)"'
label define mx95a_resdurylbl 01 `"1"', add
label define mx95a_resdurylbl 02 `"2"', add
label define mx95a_resdurylbl 03 `"3"', add
label define mx95a_resdurylbl 04 `"4"', add
label define mx95a_resdurylbl 05 `"5"', add
label define mx95a_resdurylbl 06 `"6"', add
label define mx95a_resdurylbl 07 `"7"', add
label define mx95a_resdurylbl 08 `"8"', add
label define mx95a_resdurylbl 09 `"9"', add
label define mx95a_resdurylbl 10 `"10"', add
label define mx95a_resdurylbl 11 `"11"', add
label define mx95a_resdurylbl 12 `"12"', add
label define mx95a_resdurylbl 13 `"13"', add
label define mx95a_resdurylbl 14 `"14"', add
label define mx95a_resdurylbl 15 `"15"', add
label define mx95a_resdurylbl 16 `"16"', add
label define mx95a_resdurylbl 17 `"17"', add
label define mx95a_resdurylbl 18 `"18"', add
label define mx95a_resdurylbl 19 `"19"', add
label define mx95a_resdurylbl 20 `"20"', add
label define mx95a_resdurylbl 21 `"21"', add
label define mx95a_resdurylbl 22 `"22"', add
label define mx95a_resdurylbl 23 `"23"', add
label define mx95a_resdurylbl 24 `"24"', add
label define mx95a_resdurylbl 25 `"25"', add
label define mx95a_resdurylbl 26 `"26"', add
label define mx95a_resdurylbl 27 `"27"', add
label define mx95a_resdurylbl 28 `"28"', add
label define mx95a_resdurylbl 29 `"29"', add
label define mx95a_resdurylbl 30 `"30"', add
label define mx95a_resdurylbl 31 `"31"', add
label define mx95a_resdurylbl 32 `"32"', add
label define mx95a_resdurylbl 33 `"33"', add
label define mx95a_resdurylbl 34 `"34"', add
label define mx95a_resdurylbl 35 `"35"', add
label define mx95a_resdurylbl 36 `"36"', add
label define mx95a_resdurylbl 37 `"37"', add
label define mx95a_resdurylbl 38 `"38"', add
label define mx95a_resdurylbl 39 `"39"', add
label define mx95a_resdurylbl 40 `"40"', add
label define mx95a_resdurylbl 41 `"41"', add
label define mx95a_resdurylbl 42 `"42"', add
label define mx95a_resdurylbl 43 `"43"', add
label define mx95a_resdurylbl 44 `"44"', add
label define mx95a_resdurylbl 45 `"45"', add
label define mx95a_resdurylbl 46 `"46"', add
label define mx95a_resdurylbl 47 `"47"', add
label define mx95a_resdurylbl 48 `"48"', add
label define mx95a_resdurylbl 49 `"49"', add
label define mx95a_resdurylbl 50 `"50"', add
label define mx95a_resdurylbl 51 `"51"', add
label define mx95a_resdurylbl 52 `"52"', add
label define mx95a_resdurylbl 53 `"53"', add
label define mx95a_resdurylbl 54 `"54"', add
label define mx95a_resdurylbl 55 `"55"', add
label define mx95a_resdurylbl 56 `"56"', add
label define mx95a_resdurylbl 57 `"57"', add
label define mx95a_resdurylbl 58 `"58"', add
label define mx95a_resdurylbl 59 `"59"', add
label define mx95a_resdurylbl 60 `"60"', add
label define mx95a_resdurylbl 61 `"61"', add
label define mx95a_resdurylbl 62 `"62"', add
label define mx95a_resdurylbl 63 `"63"', add
label define mx95a_resdurylbl 64 `"64"', add
label define mx95a_resdurylbl 65 `"65"', add
label define mx95a_resdurylbl 66 `"66"', add
label define mx95a_resdurylbl 67 `"67"', add
label define mx95a_resdurylbl 68 `"68"', add
label define mx95a_resdurylbl 69 `"69"', add
label define mx95a_resdurylbl 70 `"70"', add
label define mx95a_resdurylbl 71 `"71"', add
label define mx95a_resdurylbl 72 `"72"', add
label define mx95a_resdurylbl 73 `"73"', add
label define mx95a_resdurylbl 74 `"74"', add
label define mx95a_resdurylbl 75 `"75"', add
label define mx95a_resdurylbl 76 `"76"', add
label define mx95a_resdurylbl 77 `"77"', add
label define mx95a_resdurylbl 78 `"78"', add
label define mx95a_resdurylbl 79 `"79"', add
label define mx95a_resdurylbl 80 `"80"', add
label define mx95a_resdurylbl 81 `"81"', add
label define mx95a_resdurylbl 82 `"82"', add
label define mx95a_resdurylbl 83 `"83"', add
label define mx95a_resdurylbl 84 `"84"', add
label define mx95a_resdurylbl 85 `"85"', add
label define mx95a_resdurylbl 86 `"86"', add
label define mx95a_resdurylbl 87 `"87"', add
label define mx95a_resdurylbl 88 `"88"', add
label define mx95a_resdurylbl 92 `"92"', add
label define mx95a_resdurylbl 93 `"93"', add
label define mx95a_resdurylbl 98 `"98"', add
label define mx95a_resdurylbl 99 `"Unknown"', add
label values mx95a_resdury mx95a_resdurylbl

label define mx95a_resstlbl 00 `"NIU (not in universe)"'
label define mx95a_resstlbl 01 `"Aguascalientes"', add
label define mx95a_resstlbl 02 `"Baja California"', add
label define mx95a_resstlbl 03 `"Baja California Sur"', add
label define mx95a_resstlbl 04 `"Campeche"', add
label define mx95a_resstlbl 05 `"Coahuila"', add
label define mx95a_resstlbl 06 `"Colima"', add
label define mx95a_resstlbl 07 `"Chiapas"', add
label define mx95a_resstlbl 08 `"Chihuahua"', add
label define mx95a_resstlbl 09 `"Federal District"', add
label define mx95a_resstlbl 10 `"Durango"', add
label define mx95a_resstlbl 11 `"Guanajuato"', add
label define mx95a_resstlbl 12 `"Guerrero"', add
label define mx95a_resstlbl 13 `"Hidalgo"', add
label define mx95a_resstlbl 14 `"Jalisco"', add
label define mx95a_resstlbl 15 `"Mexico"', add
label define mx95a_resstlbl 16 `"Michoacan"', add
label define mx95a_resstlbl 17 `"Morelos"', add
label define mx95a_resstlbl 18 `"Nayarit"', add
label define mx95a_resstlbl 19 `"Nuevo Leon"', add
label define mx95a_resstlbl 20 `"Oaxaca"', add
label define mx95a_resstlbl 21 `"Puebla"', add
label define mx95a_resstlbl 22 `"Queretaro"', add
label define mx95a_resstlbl 23 `"Quintana Roo"', add
label define mx95a_resstlbl 24 `"San Luis Potosi"', add
label define mx95a_resstlbl 25 `"Sinaloa"', add
label define mx95a_resstlbl 26 `"Sonora"', add
label define mx95a_resstlbl 27 `"Tabasco"', add
label define mx95a_resstlbl 28 `"Tamaulipas"', add
label define mx95a_resstlbl 29 `"Tlaxcala"', add
label define mx95a_resstlbl 30 `"Veracruz"', add
label define mx95a_resstlbl 31 `"Yucatan"', add
label define mx95a_resstlbl 32 `"Zacatecas"', add
label define mx95a_resstlbl 34 `"America (except the United States of America)"', add
label define mx95a_resstlbl 35 `"United States of America"', add
label define mx95a_resstlbl 36 `"Asia"', add
label define mx95a_resstlbl 37 `"Europe"', add
label define mx95a_resstlbl 38 `"Oceania"', add
label define mx95a_resstlbl 99 `"Unknown"', add
label values mx95a_resst mx95a_resstlbl

label define mx95a_resmunlbl 01001 `"Aguascalientes"'
label define mx95a_resmunlbl 01002 `"Asientos"', add
label define mx95a_resmunlbl 01003 `"Calvillo"', add
label define mx95a_resmunlbl 01004 `"Cosio"', add
label define mx95a_resmunlbl 01005 `"Jesus Maria"', add
label define mx95a_resmunlbl 01006 `"Pabellon De Arteaga"', add
label define mx95a_resmunlbl 01007 `"Rincon De Romos"', add
label define mx95a_resmunlbl 01008 `"San Jose De Gracia"', add
label define mx95a_resmunlbl 01009 `"Tepezala"', add
label define mx95a_resmunlbl 01010 `"Llano, El"', add
label define mx95a_resmunlbl 01011 `"San Francisco De Los Romo"', add
label define mx95a_resmunlbl 01999 `"Undocumented"', add
label define mx95a_resmunlbl 02001 `"Ensenada"', add
label define mx95a_resmunlbl 02002 `"Mexicali"', add
label define mx95a_resmunlbl 02003 `"Tecate"', add
label define mx95a_resmunlbl 02004 `"Tijuana"', add
label define mx95a_resmunlbl 02999 `"Undocumented"', add
label define mx95a_resmunlbl 03001 `"Comondu"', add
label define mx95a_resmunlbl 03002 `"Mulege"', add
label define mx95a_resmunlbl 03003 `"Paz, La"', add
label define mx95a_resmunlbl 03008 `"Cabos, Los"', add
label define mx95a_resmunlbl 03009 `"Loreto"', add
label define mx95a_resmunlbl 03999 `"Undocumented"', add
label define mx95a_resmunlbl 04001 `"Calkini"', add
label define mx95a_resmunlbl 04002 `"Campeche"', add
label define mx95a_resmunlbl 04003 `"Carmen"', add
label define mx95a_resmunlbl 04004 `"Champoton"', add
label define mx95a_resmunlbl 04005 `"Hecelchakan"', add
label define mx95a_resmunlbl 04006 `"Hopelchen"', add
label define mx95a_resmunlbl 04007 `"Palizada"', add
label define mx95a_resmunlbl 04008 `"Tenabo"', add
label define mx95a_resmunlbl 04009 `"Escarcega"', add
label define mx95a_resmunlbl 04999 `"Undocumented"', add
label define mx95a_resmunlbl 05002 `"Acuña"', add
label define mx95a_resmunlbl 05003 `"Allende"', add
label define mx95a_resmunlbl 05004 `"Arteaga"', add
label define mx95a_resmunlbl 05005 `"Candela"', add
label define mx95a_resmunlbl 05006 `"Castaños"', add
label define mx95a_resmunlbl 05007 `"Cuatrocienegas"', add
label define mx95a_resmunlbl 05008 `"Escobedo"', add
label define mx95a_resmunlbl 05009 `"Francisco I. Madero"', add
label define mx95a_resmunlbl 05010 `"Frontera"', add
label define mx95a_resmunlbl 05011 `"General Cepeda"', add
label define mx95a_resmunlbl 05012 `"Guerrero"', add
label define mx95a_resmunlbl 05014 `"Jimenez"', add
label define mx95a_resmunlbl 05017 `"Matamoros"', add
label define mx95a_resmunlbl 05018 `"Monclova"', add
label define mx95a_resmunlbl 05019 `"Morelos"', add
label define mx95a_resmunlbl 05020 `"Muzquiz"', add
label define mx95a_resmunlbl 05021 `"Nadadores"', add
label define mx95a_resmunlbl 05022 `"Nava"', add
label define mx95a_resmunlbl 05023 `"Ocampo"', add
label define mx95a_resmunlbl 05024 `"Parras De La Fuente"', add
label define mx95a_resmunlbl 05025 `"Piedras Negras"', add
label define mx95a_resmunlbl 05026 `"Progreso"', add
label define mx95a_resmunlbl 05027 `"Ramos Arizpe"', add
label define mx95a_resmunlbl 05028 `"Sabinas"', add
label define mx95a_resmunlbl 05030 `"Saltillo"', add
label define mx95a_resmunlbl 05031 `"San Buenaventura"', add
label define mx95a_resmunlbl 05032 `"San Juan De Sabinas"', add
label define mx95a_resmunlbl 05033 `"San Pedro"', add
label define mx95a_resmunlbl 05034 `"Sierra Mojada"', add
label define mx95a_resmunlbl 05035 `"Torreon"', add
label define mx95a_resmunlbl 05036 `"Viesca"', add
label define mx95a_resmunlbl 05038 `"Zaragoza"', add
label define mx95a_resmunlbl 05999 `"Undocumented"', add
label define mx95a_resmunlbl 06001 `"Armeria"', add
label define mx95a_resmunlbl 06002 `"Colima"', add
label define mx95a_resmunlbl 06003 `"Comala"', add
label define mx95a_resmunlbl 06004 `"Coquimatlan"', add
label define mx95a_resmunlbl 06005 `"Cuauhtemoc"', add
label define mx95a_resmunlbl 06006 `"Ixtlahuacan"', add
label define mx95a_resmunlbl 06007 `"Manzanillo"', add
label define mx95a_resmunlbl 06008 `"Minatitlan"', add
label define mx95a_resmunlbl 06009 `"Tecoman"', add
label define mx95a_resmunlbl 06010 `"Villa De Alvarez"', add
label define mx95a_resmunlbl 06999 `"Undocumented"', add
label define mx95a_resmunlbl 07002 `"Acala"', add
label define mx95a_resmunlbl 07003 `"Acapetahua"', add
label define mx95a_resmunlbl 07005 `"Amatan"', add
label define mx95a_resmunlbl 07007 `"Amatenango Del Valle"', add
label define mx95a_resmunlbl 07008 `"Angel Albino Corzo"', add
label define mx95a_resmunlbl 07009 `"Arriaga"', add
label define mx95a_resmunlbl 07011 `"Bella Vista"', add
label define mx95a_resmunlbl 07012 `"Berriozabal"', add
label define mx95a_resmunlbl 07015 `"Cacahoatan"', add
label define mx95a_resmunlbl 07016 `"Catazaja"', add
label define mx95a_resmunlbl 07017 `"Cintalapa"', add
label define mx95a_resmunlbl 07019 `"Comitan De Dominguez"', add
label define mx95a_resmunlbl 07020 `"Concordia, La"', add
label define mx95a_resmunlbl 07023 `"Chamula"', add
label define mx95a_resmunlbl 07025 `"Chapultenango"', add
label define mx95a_resmunlbl 07027 `"Chiapa De Corzo"', add
label define mx95a_resmunlbl 07029 `"Chicoasen"', add
label define mx95a_resmunlbl 07030 `"Chicomuselo"', add
label define mx95a_resmunlbl 07031 `"Chilon"', add
label define mx95a_resmunlbl 07032 `"Escuintla"', add
label define mx95a_resmunlbl 07033 `"Francisco Leon"', add
label define mx95a_resmunlbl 07034 `"Frontera Comalapa"', add
label define mx95a_resmunlbl 07035 `"Frontera Hidalgo"', add
label define mx95a_resmunlbl 07036 `"Grandeza, La"', add
label define mx95a_resmunlbl 07037 `"Huehuetan"', add
label define mx95a_resmunlbl 07038 `"Huixtan"', add
label define mx95a_resmunlbl 07039 `"Huitiupan"', add
label define mx95a_resmunlbl 07040 `"Huixtla"', add
label define mx95a_resmunlbl 07041 `"Independencia, La"', add
label define mx95a_resmunlbl 07043 `"Ixtacomitan"', add
label define mx95a_resmunlbl 07044 `"Ixtapa"', add
label define mx95a_resmunlbl 07046 `"Jiquipilas"', add
label define mx95a_resmunlbl 07048 `"Juarez"', add
label define mx95a_resmunlbl 07049 `"Larrainzar"', add
label define mx95a_resmunlbl 07050 `"Libertad, La"', add
label define mx95a_resmunlbl 07051 `"Mapastepec"', add
label define mx95a_resmunlbl 07052 `"Margaritas, Las"', add
label define mx95a_resmunlbl 07053 `"Mazapa De Madero"', add
label define mx95a_resmunlbl 07054 `"Mazatan"', add
label define mx95a_resmunlbl 07055 `"Metapa"', add
label define mx95a_resmunlbl 07057 `"Motozintla"', add
label define mx95a_resmunlbl 07059 `"Ocosingo"', add
label define mx95a_resmunlbl 07061 `"Ocozocoautla De Espinosa"', add
label define mx95a_resmunlbl 07062 `"Ostuacan"', add
label define mx95a_resmunlbl 07064 `"Oxchuc"', add
label define mx95a_resmunlbl 07065 `"Palenque"', add
label define mx95a_resmunlbl 07066 `"Pantelho"', add
label define mx95a_resmunlbl 07068 `"Pichucalco"', add
label define mx95a_resmunlbl 07069 `"Pijijiapan"', add
label define mx95a_resmunlbl 07070 `"Porvenir, El"', add
label define mx95a_resmunlbl 07071 `"Villa Comaltitlan"', add
label define mx95a_resmunlbl 07072 `"Pueblo Nuevo Solistahuacan"', add
label define mx95a_resmunlbl 07074 `"Reforma"', add
label define mx95a_resmunlbl 07076 `"Sabanilla"', add
label define mx95a_resmunlbl 07077 `"Salto De Agua"', add
label define mx95a_resmunlbl 07078 `"San Cristobal De Las Casas"', add
label define mx95a_resmunlbl 07079 `"San Fernando"', add
label define mx95a_resmunlbl 07080 `"Siltepec"', add
label define mx95a_resmunlbl 07081 `"Simojovel"', add
label define mx95a_resmunlbl 07083 `"Socoltenango"', add
label define mx95a_resmunlbl 07085 `"Soyalo"', add
label define mx95a_resmunlbl 07086 `"Suchiapa"', add
label define mx95a_resmunlbl 07087 `"Suchiate"', add
label define mx95a_resmunlbl 07089 `"Tapachula"', add
label define mx95a_resmunlbl 07091 `"Tapilula"', add
label define mx95a_resmunlbl 07092 `"Tecpatan"', add
label define mx95a_resmunlbl 07093 `"Tenejapa"', add
label define mx95a_resmunlbl 07096 `"Tila"', add
label define mx95a_resmunlbl 07097 `"Tonala"', add
label define mx95a_resmunlbl 07098 `"Totolapa"', add
label define mx95a_resmunlbl 07099 `"Trinitaria, La"', add
label define mx95a_resmunlbl 07101 `"Tuxtla Gutierrez"', add
label define mx95a_resmunlbl 07102 `"Tuxtla Chico"', add
label define mx95a_resmunlbl 07103 `"Tuzantan"', add
label define mx95a_resmunlbl 07105 `"Union Juarez"', add
label define mx95a_resmunlbl 07106 `"Venustiano Carranza"', add
label define mx95a_resmunlbl 07107 `"Villa Corzo"', add
label define mx95a_resmunlbl 07108 `"Villaflores"', add
label define mx95a_resmunlbl 07109 `"Yajalon"', add
label define mx95a_resmunlbl 07999 `"Undocumented"', add
label define mx95a_resmunlbl 08001 `"Ahumada"', add
label define mx95a_resmunlbl 08002 `"Aldama"', add
label define mx95a_resmunlbl 08004 `"Aquiles Serdan"', add
label define mx95a_resmunlbl 08005 `"Ascension"', add
label define mx95a_resmunlbl 08006 `"Bachiniva"', add
label define mx95a_resmunlbl 08007 `"Balleza"', add
label define mx95a_resmunlbl 08008 `"Batopilas"', add
label define mx95a_resmunlbl 08009 `"Bocoyna"', add
label define mx95a_resmunlbl 08010 `"Buenaventura"', add
label define mx95a_resmunlbl 08011 `"Camargo"', add
label define mx95a_resmunlbl 08012 `"Carichi"', add
label define mx95a_resmunlbl 08013 `"Casas Grandes"', add
label define mx95a_resmunlbl 08016 `"Cruz, La"', add
label define mx95a_resmunlbl 08017 `"Cuauhtemoc"', add
label define mx95a_resmunlbl 08018 `"Cusihuiriachi"', add
label define mx95a_resmunlbl 08019 `"Chihuahua"', add
label define mx95a_resmunlbl 08020 `"Chinipas"', add
label define mx95a_resmunlbl 08021 `"Delicias"', add
label define mx95a_resmunlbl 08022 `"Dr. Belisario Dominguez"', add
label define mx95a_resmunlbl 08025 `"Gomez Farias"', add
label define mx95a_resmunlbl 08026 `"Gran Morelos"', add
label define mx95a_resmunlbl 08027 `"Guachochi"', add
label define mx95a_resmunlbl 08029 `"Guadalupe Y Calvo"', add
label define mx95a_resmunlbl 08030 `"Guazapares"', add
label define mx95a_resmunlbl 08031 `"Guerrero"', add
label define mx95a_resmunlbl 08032 `"Hidalgo Del Parral"', add
label define mx95a_resmunlbl 08033 `"Huejotitan"', add
label define mx95a_resmunlbl 08034 `"Ignacio Zaragoza"', add
label define mx95a_resmunlbl 08035 `"Janos"', add
label define mx95a_resmunlbl 08036 `"Jimenez"', add
label define mx95a_resmunlbl 08037 `"Juarez"', add
label define mx95a_resmunlbl 08038 `"Julimes"', add
label define mx95a_resmunlbl 08039 `"Lopez"', add
label define mx95a_resmunlbl 08040 `"Madera"', add
label define mx95a_resmunlbl 08043 `"Matachi"', add
label define mx95a_resmunlbl 08044 `"Matamoros"', add
label define mx95a_resmunlbl 08045 `"Meoqui"', add
label define mx95a_resmunlbl 08046 `"Morelos"', add
label define mx95a_resmunlbl 08047 `"Moris"', add
label define mx95a_resmunlbl 08048 `"Namiquipa"', add
label define mx95a_resmunlbl 08050 `"Nuevo Casas Grandes"', add
label define mx95a_resmunlbl 08051 `"Ocampo"', add
label define mx95a_resmunlbl 08054 `"Riva Palacio"', add
label define mx95a_resmunlbl 08057 `"San Francisco De Borja"', add
label define mx95a_resmunlbl 08059 `"San Francisco Del Oro"', add
label define mx95a_resmunlbl 08060 `"Santa Barbara"', add
label define mx95a_resmunlbl 08062 `"Saucillo"', add
label define mx95a_resmunlbl 08063 `"Temosachi"', add
label define mx95a_resmunlbl 08065 `"Urique"', add
label define mx95a_resmunlbl 08066 `"Uruachi"', add
label define mx95a_resmunlbl 08067 `"Valle De Zaragoza"', add
label define mx95a_resmunlbl 08999 `"Undocumented"', add
label define mx95a_resmunlbl 09002 `"Azcapotzalco"', add
label define mx95a_resmunlbl 09003 `"Coyoacan"', add
label define mx95a_resmunlbl 09004 `"Cuajimalpa De Morelos"', add
label define mx95a_resmunlbl 09005 `"Gustavo A. Madero"', add
label define mx95a_resmunlbl 09006 `"Iztacalco"', add
label define mx95a_resmunlbl 09007 `"Iztapalapa"', add
label define mx95a_resmunlbl 09008 `"Magdalena Contreras, La"', add
label define mx95a_resmunlbl 09009 `"Milpa Alta"', add
label define mx95a_resmunlbl 09010 `"Alvaro Obregon"', add
label define mx95a_resmunlbl 09011 `"Tlahuac"', add
label define mx95a_resmunlbl 09012 `"Tlalpan"', add
label define mx95a_resmunlbl 09013 `"Xochimilco"', add
label define mx95a_resmunlbl 09014 `"Benito Juarez"', add
label define mx95a_resmunlbl 09015 `"Cuauhtemoc"', add
label define mx95a_resmunlbl 09016 `"Miguel Hidalgo"', add
label define mx95a_resmunlbl 09017 `"Venustiano Carranza"', add
label define mx95a_resmunlbl 09999 `"Undocumented"', add
label define mx95a_resmunlbl 10001 `"Canatlan"', add
label define mx95a_resmunlbl 10002 `"Canelas"', add
label define mx95a_resmunlbl 10004 `"Cuencame"', add
label define mx95a_resmunlbl 10005 `"Durango"', add
label define mx95a_resmunlbl 10006 `"General Simon Bolivar"', add
label define mx95a_resmunlbl 10007 `"Gomez Palacio"', add
label define mx95a_resmunlbl 10008 `"Guadalupe Victoria"', add
label define mx95a_resmunlbl 10009 `"Guanacevi"', add
label define mx95a_resmunlbl 10011 `"Inde"', add
label define mx95a_resmunlbl 10012 `"Lerdo"', add
label define mx95a_resmunlbl 10013 `"Mapimi"', add
label define mx95a_resmunlbl 10014 `"Mezquital"', add
label define mx95a_resmunlbl 10015 `"Nazas"', add
label define mx95a_resmunlbl 10016 `"Nombre De Dios"', add
label define mx95a_resmunlbl 10017 `"Ocampo"', add
label define mx95a_resmunlbl 10018 `"Oro, El"', add
label define mx95a_resmunlbl 10019 `"Otaez"', add
label define mx95a_resmunlbl 10020 `"Panuco De Coronado"', add
label define mx95a_resmunlbl 10021 `"Peñon Blanco"', add
label define mx95a_resmunlbl 10022 `"Poanas"', add
label define mx95a_resmunlbl 10023 `"Pueblo Nuevo"', add
label define mx95a_resmunlbl 10024 `"Rodeo"', add
label define mx95a_resmunlbl 10025 `"San Bernardo"', add
label define mx95a_resmunlbl 10026 `"San Dimas"', add
label define mx95a_resmunlbl 10027 `"San Juan De Guadalupe"', add
label define mx95a_resmunlbl 10028 `"San Juan Del Rio"', add
label define mx95a_resmunlbl 10029 `"San Luis Del Cordero"', add
label define mx95a_resmunlbl 10030 `"San Pedro Del Gallo"', add
label define mx95a_resmunlbl 10032 `"Santiago Papasquiaro"', add
label define mx95a_resmunlbl 10033 `"Suchil"', add
label define mx95a_resmunlbl 10034 `"Tamazula"', add
label define mx95a_resmunlbl 10035 `"Tepehuanes"', add
label define mx95a_resmunlbl 10036 `"Tlahualilo"', add
label define mx95a_resmunlbl 10037 `"Topia"', add
label define mx95a_resmunlbl 10038 `"Vicente Guerrero"', add
label define mx95a_resmunlbl 10039 `"Nuevo Ideal"', add
label define mx95a_resmunlbl 10999 `"Undocumented"', add
label define mx95a_resmunlbl 11001 `"Abasolo"', add
label define mx95a_resmunlbl 11002 `"Acambaro"', add
label define mx95a_resmunlbl 11003 `"Allende"', add
label define mx95a_resmunlbl 11004 `"Apaseo El Alto"', add
label define mx95a_resmunlbl 11005 `"Apaseo El Grande"', add
label define mx95a_resmunlbl 11006 `"Atarjea"', add
label define mx95a_resmunlbl 11007 `"Celaya"', add
label define mx95a_resmunlbl 11008 `"Manuel Doblado"', add
label define mx95a_resmunlbl 11009 `"Comonfort"', add
label define mx95a_resmunlbl 11011 `"Cortazar"', add
label define mx95a_resmunlbl 11012 `"Cueramaro"', add
label define mx95a_resmunlbl 11013 `"Doctor Mora"', add
label define mx95a_resmunlbl 11014 `"Dolores Hidalgo"', add
label define mx95a_resmunlbl 11015 `"Guanajuato"', add
label define mx95a_resmunlbl 11016 `"Huanimaro"', add
label define mx95a_resmunlbl 11017 `"Irapuato"', add
label define mx95a_resmunlbl 11018 `"Jaral Del Progreso"', add
label define mx95a_resmunlbl 11019 `"Jerecuaro"', add
label define mx95a_resmunlbl 11020 `"Leon"', add
label define mx95a_resmunlbl 11021 `"Moroleon"', add
label define mx95a_resmunlbl 11022 `"Ocampo"', add
label define mx95a_resmunlbl 11023 `"Penjamo"', add
label define mx95a_resmunlbl 11025 `"Purisima Del Rincon"', add
label define mx95a_resmunlbl 11026 `"Romita"', add
label define mx95a_resmunlbl 11027 `"Salamanca"', add
label define mx95a_resmunlbl 11028 `"Salvatierra"', add
label define mx95a_resmunlbl 11029 `"San Diego De La Union"', add
label define mx95a_resmunlbl 11030 `"San Felipe"', add
label define mx95a_resmunlbl 11031 `"San Francisco Del Rincon"', add
label define mx95a_resmunlbl 11032 `"San Jose Iturbide"', add
label define mx95a_resmunlbl 11033 `"San Luis De La Paz"', add
label define mx95a_resmunlbl 11034 `"Santa Catarina"', add
label define mx95a_resmunlbl 11037 `"Silao"', add
label define mx95a_resmunlbl 11039 `"Tarimoro"', add
label define mx95a_resmunlbl 11040 `"Tierra Blanca"', add
label define mx95a_resmunlbl 11042 `"Valle De Santiago"', add
label define mx95a_resmunlbl 11043 `"Victoria"', add
label define mx95a_resmunlbl 11044 `"Villagran"', add
label define mx95a_resmunlbl 11046 `"Yuriria"', add
label define mx95a_resmunlbl 11999 `"Undocumented"', add
label define mx95a_resmunlbl 12001 `"Acapulco De Juarez"', add
label define mx95a_resmunlbl 12004 `"Alcozauca De Guerrero"', add
label define mx95a_resmunlbl 12005 `"Alpoyeca"', add
label define mx95a_resmunlbl 12006 `"Apaxtla"', add
label define mx95a_resmunlbl 12007 `"Arcelia"', add
label define mx95a_resmunlbl 12009 `"Atlamajalcingo Del Monte"', add
label define mx95a_resmunlbl 12010 `"Atlixtac"', add
label define mx95a_resmunlbl 12011 `"Atoyac De Alvarez"', add
label define mx95a_resmunlbl 12012 `"Ayutla De Los Libres"', add
label define mx95a_resmunlbl 12013 `"Azoyu"', add
label define mx95a_resmunlbl 12014 `"Benito Juarez"', add
label define mx95a_resmunlbl 12015 `"Buenavista De Cuellar"', add
label define mx95a_resmunlbl 12017 `"Cocula"', add
label define mx95a_resmunlbl 12018 `"Copala"', add
label define mx95a_resmunlbl 12019 `"Copalillo"', add
label define mx95a_resmunlbl 12020 `"Copanatoyac"', add
label define mx95a_resmunlbl 12021 `"Coyuca De Benitez"', add
label define mx95a_resmunlbl 12022 `"Coyuca De Catalan"', add
label define mx95a_resmunlbl 12023 `"Cuajinicuilapa"', add
label define mx95a_resmunlbl 12025 `"Cuautepec"', add
label define mx95a_resmunlbl 12027 `"Cutzamala De Pinzon"', add
label define mx95a_resmunlbl 12028 `"Chilapa De Alvarez"', add
label define mx95a_resmunlbl 12029 `"Chilpancingo De Los Bravo"', add
label define mx95a_resmunlbl 12030 `"Florencio Villarreal"', add
label define mx95a_resmunlbl 12032 `"General Heliodoro Castillo"', add
label define mx95a_resmunlbl 12033 `"Huamuxtitlan"', add
label define mx95a_resmunlbl 12034 `"Huitzuco De Los Figueroa"', add
label define mx95a_resmunlbl 12035 `"Iguala De La Independencia"', add
label define mx95a_resmunlbl 12037 `"Ixcateopan De Cuauhtemoc"', add
label define mx95a_resmunlbl 12038 `"Jose Azueta"', add
label define mx95a_resmunlbl 12039 `"Juan R. Escudero"', add
label define mx95a_resmunlbl 12040 `"Leonardo Bravo"', add
label define mx95a_resmunlbl 12041 `"Malinaltepec"', add
label define mx95a_resmunlbl 12042 `"Martir De Cuilapan"', add
label define mx95a_resmunlbl 12044 `"Mochitlan"', add
label define mx95a_resmunlbl 12045 `"Olinala"', add
label define mx95a_resmunlbl 12046 `"Ometepec"', add
label define mx95a_resmunlbl 12048 `"Petatlan"', add
label define mx95a_resmunlbl 12050 `"Pungarabato"', add
label define mx95a_resmunlbl 12051 `"Quechultenango"', add
label define mx95a_resmunlbl 12052 `"San Luis Acatlan"', add
label define mx95a_resmunlbl 12053 `"San Marcos"', add
label define mx95a_resmunlbl 12054 `"San Miguel Totolapan"', add
label define mx95a_resmunlbl 12055 `"Taxco De Alarcon"', add
label define mx95a_resmunlbl 12057 `"Tecpan De Galeana"', add
label define mx95a_resmunlbl 12058 `"Teloloapan"', add
label define mx95a_resmunlbl 12059 `"Tepecoacuilco De Trujano"', add
label define mx95a_resmunlbl 12060 `"Tetipac"', add
label define mx95a_resmunlbl 12061 `"Tixtla De Guerrero"', add
label define mx95a_resmunlbl 12063 `"Tlacoapa"', add
label define mx95a_resmunlbl 12064 `"Tlalchapa"', add
label define mx95a_resmunlbl 12065 `"Tlalixtaquilla De Maldonado"', add
label define mx95a_resmunlbl 12066 `"Tlapa De Comonfort"', add
label define mx95a_resmunlbl 12067 `"Tlapehuala"', add
label define mx95a_resmunlbl 12068 `"Union De Isidoro Montes De Oca, La"', add
label define mx95a_resmunlbl 12069 `"Xalpatlahuac"', add
label define mx95a_resmunlbl 12070 `"Xochihuehuetlan"', add
label define mx95a_resmunlbl 12071 `"Xochistlahuaca"', add
label define mx95a_resmunlbl 12072 `"Zapotitlan Tablas"', add
label define mx95a_resmunlbl 12073 `"Zirandaro"', add
label define mx95a_resmunlbl 12075 `"Eduardo Neri"', add
label define mx95a_resmunlbl 12076 `"Acatepec"', add
label define mx95a_resmunlbl 12999 `"Undocumented"', add
label define mx95a_resmunlbl 13001 `"Acatlan"', add
label define mx95a_resmunlbl 13002 `"Acaxochitlan"', add
label define mx95a_resmunlbl 13003 `"Actopan"', add
label define mx95a_resmunlbl 13005 `"Ajacuba"', add
label define mx95a_resmunlbl 13006 `"Alfajayucan"', add
label define mx95a_resmunlbl 13007 `"Almoloya"', add
label define mx95a_resmunlbl 13008 `"Apan"', add
label define mx95a_resmunlbl 13010 `"Atitalaquia"', add
label define mx95a_resmunlbl 13012 `"Atotonilco El Grande"', add
label define mx95a_resmunlbl 13013 `"Atotonilco De Tula"', add
label define mx95a_resmunlbl 13014 `"Calnali"', add
label define mx95a_resmunlbl 13015 `"Cardonal"', add
label define mx95a_resmunlbl 13016 `"Cuautepec De Hinojosa"', add
label define mx95a_resmunlbl 13018 `"Chapulhuacan"', add
label define mx95a_resmunlbl 13019 `"Chilcuautla"', add
label define mx95a_resmunlbl 13021 `"Emiliano Zapata"', add
label define mx95a_resmunlbl 13022 `"Epazoyucan"', add
label define mx95a_resmunlbl 13023 `"Francisco I. Madero"', add
label define mx95a_resmunlbl 13024 `"Huasca De Ocampo"', add
label define mx95a_resmunlbl 13025 `"Huautla"', add
label define mx95a_resmunlbl 13026 `"Huazalingo"', add
label define mx95a_resmunlbl 13027 `"Huehuetla"', add
label define mx95a_resmunlbl 13028 `"Huejutla De Reyes"', add
label define mx95a_resmunlbl 13029 `"Huichapan"', add
label define mx95a_resmunlbl 13030 `"Ixmiquilpan"', add
label define mx95a_resmunlbl 13031 `"Jacala De Ledezma"', add
label define mx95a_resmunlbl 13034 `"Lolotla"', add
label define mx95a_resmunlbl 13035 `"Metepec"', add
label define mx95a_resmunlbl 13037 `"Metztitlan"', add
label define mx95a_resmunlbl 13038 `"Mineral Del Chico"', add
label define mx95a_resmunlbl 13039 `"Mineral Del Monte"', add
label define mx95a_resmunlbl 13040 `"Mision, La"', add
label define mx95a_resmunlbl 13041 `"Mixquiahuala De Juarez"', add
label define mx95a_resmunlbl 13042 `"Molango De Escamilla"', add
label define mx95a_resmunlbl 13044 `"Nopala De Villagran"', add
label define mx95a_resmunlbl 13045 `"Omitlan De Juarez"', add
label define mx95a_resmunlbl 13046 `"San Felipe Orizatlan"', add
label define mx95a_resmunlbl 13048 `"Pachuca De Soto"', add
label define mx95a_resmunlbl 13049 `"Pisaflores"', add
label define mx95a_resmunlbl 13050 `"Progreso De Obregon"', add
label define mx95a_resmunlbl 13051 `"Mineral De La Reforma"', add
label define mx95a_resmunlbl 13052 `"San Agustin Tlaxiaca"', add
label define mx95a_resmunlbl 13053 `"San Bartolo Tutotepec"', add
label define mx95a_resmunlbl 13054 `"San Salvador"', add
label define mx95a_resmunlbl 13055 `"Santiago De Anaya"', add
label define mx95a_resmunlbl 13056 `"Santiago Tulantepec De Lugo Guerrero"', add
label define mx95a_resmunlbl 13057 `"Singuilucan"', add
label define mx95a_resmunlbl 13058 `"Tasquillo"', add
label define mx95a_resmunlbl 13059 `"Tecozautla"', add
label define mx95a_resmunlbl 13060 `"Tenango De Doria"', add
label define mx95a_resmunlbl 13061 `"Tepeapulco"', add
label define mx95a_resmunlbl 13062 `"Tepehuacan De Guerrero"', add
label define mx95a_resmunlbl 13063 `"Tepeji Del Rio De Ocampo"', add
label define mx95a_resmunlbl 13064 `"Tepetitlan"', add
label define mx95a_resmunlbl 13066 `"Villa De Tezontepec"', add
label define mx95a_resmunlbl 13067 `"Tezontepec De Aldama"', add
label define mx95a_resmunlbl 13068 `"Tianguistengo"', add
label define mx95a_resmunlbl 13069 `"Tizayuca"', add
label define mx95a_resmunlbl 13070 `"Tlahuelilpan"', add
label define mx95a_resmunlbl 13072 `"Tlanalapa"', add
label define mx95a_resmunlbl 13073 `"Tlanchinol"', add
label define mx95a_resmunlbl 13074 `"Tlaxcoapan"', add
label define mx95a_resmunlbl 13075 `"Tolcayuca"', add
label define mx95a_resmunlbl 13076 `"Tula De Allende"', add
label define mx95a_resmunlbl 13077 `"Tulancingo De Bravo"', add
label define mx95a_resmunlbl 13080 `"Yahualica"', add
label define mx95a_resmunlbl 13081 `"Zacualtipan De Angeles"', add
label define mx95a_resmunlbl 13082 `"Zapotlan De Juarez"', add
label define mx95a_resmunlbl 13083 `"Zempoala"', add
label define mx95a_resmunlbl 13084 `"Zimapan"', add
label define mx95a_resmunlbl 13999 `"Undocumented"', add
label define mx95a_resmunlbl 14001 `"Acatic"', add
label define mx95a_resmunlbl 14002 `"Acatlan De Juarez"', add
label define mx95a_resmunlbl 14003 `"Ahualulco De Mercado"', add
label define mx95a_resmunlbl 14005 `"Amatitan"', add
label define mx95a_resmunlbl 14006 `"Ameca"', add
label define mx95a_resmunlbl 14007 `"Antonio Escobedo"', add
label define mx95a_resmunlbl 14008 `"Arandas"', add
label define mx95a_resmunlbl 14010 `"Atemajac De Brizuela"', add
label define mx95a_resmunlbl 14013 `"Atotonilco El Alto"', add
label define mx95a_resmunlbl 14014 `"Atoyac"', add
label define mx95a_resmunlbl 14015 `"Autlan De Navarro"', add
label define mx95a_resmunlbl 14016 `"Ayotlan"', add
label define mx95a_resmunlbl 14017 `"Ayutla"', add
label define mx95a_resmunlbl 14018 `"Barca, La"', add
label define mx95a_resmunlbl 14019 `"Bolaños"', add
label define mx95a_resmunlbl 14021 `"Casimiro Castillo"', add
label define mx95a_resmunlbl 14022 `"Cihuatlan"', add
label define mx95a_resmunlbl 14023 `"Ciudad Guzman"', add
label define mx95a_resmunlbl 14024 `"Cocula"', add
label define mx95a_resmunlbl 14025 `"Colotlan"', add
label define mx95a_resmunlbl 14026 `"Concepcion De Buenos Aires"', add
label define mx95a_resmunlbl 14027 `"Cuautitlan De Garcia Barragan"', add
label define mx95a_resmunlbl 14030 `"Chapala"', add
label define mx95a_resmunlbl 14032 `"Chiquilistlan"', add
label define mx95a_resmunlbl 14033 `"Degollado"', add
label define mx95a_resmunlbl 14034 `"Ejutla"', add
label define mx95a_resmunlbl 14035 `"Encarnacion De Diaz"', add
label define mx95a_resmunlbl 14036 `"Etzatlan"', add
label define mx95a_resmunlbl 14037 `"Grullo, El"', add
label define mx95a_resmunlbl 14038 `"Guachinango"', add
label define mx95a_resmunlbl 14039 `"Guadalajara"', add
label define mx95a_resmunlbl 14040 `"Hostotipaquillo"', add
label define mx95a_resmunlbl 14041 `"Huejucar"', add
label define mx95a_resmunlbl 14043 `"Huerta, La"', add
label define mx95a_resmunlbl 14046 `"Jalostotitlan"', add
label define mx95a_resmunlbl 14047 `"Jamay"', add
label define mx95a_resmunlbl 14048 `"Jesus Maria"', add
label define mx95a_resmunlbl 14049 `"Jilotlan De Los Dolores"', add
label define mx95a_resmunlbl 14050 `"Jocotepec"', add
label define mx95a_resmunlbl 14053 `"Lagos De Moreno"', add
label define mx95a_resmunlbl 14054 `"Limon, El"', add
label define mx95a_resmunlbl 14055 `"Magdalena"', add
label define mx95a_resmunlbl 14057 `"Manzanilla De La Paz, La"', add
label define mx95a_resmunlbl 14059 `"Mazamitla"', add
label define mx95a_resmunlbl 14060 `"Mexticacan"', add
label define mx95a_resmunlbl 14061 `"Mezquitic"', add
label define mx95a_resmunlbl 14063 `"Ocotlan"', add
label define mx95a_resmunlbl 14064 `"Ojuelos De Jalisco"', add
label define mx95a_resmunlbl 14065 `"Pihuamo"', add
label define mx95a_resmunlbl 14066 `"Poncitlan"', add
label define mx95a_resmunlbl 14067 `"Puerto Vallarta"', add
label define mx95a_resmunlbl 14069 `"Quitupan"', add
label define mx95a_resmunlbl 14070 `"Salto, El"', add
label define mx95a_resmunlbl 14072 `"San Diego De Alejandria"', add
label define mx95a_resmunlbl 14073 `"San Juan De Los Lagos"', add
label define mx95a_resmunlbl 14074 `"San Julian"', add
label define mx95a_resmunlbl 14075 `"San Marcos"', add
label define mx95a_resmunlbl 14077 `"San Martin Hidalgo"', add
label define mx95a_resmunlbl 14078 `"San Miguel El Alto"', add
label define mx95a_resmunlbl 14079 `"Gomez Farias"', add
label define mx95a_resmunlbl 14080 `"San Sebastian Del Oeste"', add
label define mx95a_resmunlbl 14081 `"Santa Maria De Los Angeles"', add
label define mx95a_resmunlbl 14082 `"Sayula"', add
label define mx95a_resmunlbl 14083 `"Tala"', add
label define mx95a_resmunlbl 14085 `"Tamazula De Gordiano"', add
label define mx95a_resmunlbl 14087 `"Tecalitlan"', add
label define mx95a_resmunlbl 14091 `"Teocaltiche"', add
label define mx95a_resmunlbl 14093 `"Tepatitlan De Morelos"', add
label define mx95a_resmunlbl 14094 `"Tequila"', add
label define mx95a_resmunlbl 14096 `"Tizapan El Alto"', add
label define mx95a_resmunlbl 14097 `"Tlajomulco De Zuñiga"', add
label define mx95a_resmunlbl 14098 `"Tlaquepaque"', add
label define mx95a_resmunlbl 14100 `"Tomatlan"', add
label define mx95a_resmunlbl 14101 `"Tonala"', add
label define mx95a_resmunlbl 14103 `"Tonila"', add
label define mx95a_resmunlbl 14104 `"Totatiche"', add
label define mx95a_resmunlbl 14105 `"Tototlan"', add
label define mx95a_resmunlbl 14108 `"Tuxpan"', add
label define mx95a_resmunlbl 14113 `"San Gabriel"', add
label define mx95a_resmunlbl 14114 `"Villa Corona"', add
label define mx95a_resmunlbl 14116 `"Villa Hidalgo"', add
label define mx95a_resmunlbl 14118 `"Yahualica De Gonzalez Gallo"', add
label define mx95a_resmunlbl 14119 `"Zacoalco De Torres"', add
label define mx95a_resmunlbl 14120 `"Zapopan"', add
label define mx95a_resmunlbl 14121 `"Zapotiltic"', add
label define mx95a_resmunlbl 14122 `"Zapotitlan De Vadillo"', add
label define mx95a_resmunlbl 14124 `"Zapotlanejo"', add
label define mx95a_resmunlbl 14999 `"Undocumented"', add
label define mx95a_resmunlbl 15001 `"Acambay"', add
label define mx95a_resmunlbl 15002 `"Acolman"', add
label define mx95a_resmunlbl 15003 `"Aculco"', add
label define mx95a_resmunlbl 15004 `"Almoloya De Alquisiras"', add
label define mx95a_resmunlbl 15005 `"Almoloya De Juarez"', add
label define mx95a_resmunlbl 15007 `"Amanalco"', add
label define mx95a_resmunlbl 15008 `"Amatepec"', add
label define mx95a_resmunlbl 15009 `"Amecameca"', add
label define mx95a_resmunlbl 15010 `"Apaxco"', add
label define mx95a_resmunlbl 15012 `"Atizapan"', add
label define mx95a_resmunlbl 15013 `"Atizapan De Zaragoza"', add
label define mx95a_resmunlbl 15014 `"Atlacomulco"', add
label define mx95a_resmunlbl 15016 `"Axapusco"', add
label define mx95a_resmunlbl 15017 `"Ayapango"', add
label define mx95a_resmunlbl 15018 `"Calimaya"', add
label define mx95a_resmunlbl 15020 `"Coacalco De Berriozabal"', add
label define mx95a_resmunlbl 15021 `"Coatepec Harinas"', add
label define mx95a_resmunlbl 15023 `"Coyotepec"', add
label define mx95a_resmunlbl 15024 `"Cuautitlan"', add
label define mx95a_resmunlbl 15025 `"Chalco"', add
label define mx95a_resmunlbl 15029 `"Chicoloapan"', add
label define mx95a_resmunlbl 15031 `"Chimalhuacan"', add
label define mx95a_resmunlbl 15032 `"Donato Guerra"', add
label define mx95a_resmunlbl 15033 `"Ecatepec"', add
label define mx95a_resmunlbl 15035 `"Huehuetoca"', add
label define mx95a_resmunlbl 15036 `"Hueypoxtla"', add
label define mx95a_resmunlbl 15037 `"Huixquilucan"', add
label define mx95a_resmunlbl 15039 `"Ixtapaluca"', add
label define mx95a_resmunlbl 15040 `"Ixtapan De La Sal"', add
label define mx95a_resmunlbl 15041 `"Ixtapan Del Oro"', add
label define mx95a_resmunlbl 15042 `"Ixtlahuaca"', add
label define mx95a_resmunlbl 15043 `"Xalatlaco"', add
label define mx95a_resmunlbl 15045 `"Jilotepec"', add
label define mx95a_resmunlbl 15046 `"Jilotzingo"', add
label define mx95a_resmunlbl 15048 `"Jocotitlan"', add
label define mx95a_resmunlbl 15050 `"Juchitepec"', add
label define mx95a_resmunlbl 15051 `"Lerma"', add
label define mx95a_resmunlbl 15052 `"Malinalco"', add
label define mx95a_resmunlbl 15053 `"Melchor Ocampo"', add
label define mx95a_resmunlbl 15054 `"Metepec"', add
label define mx95a_resmunlbl 15056 `"Morelos"', add
label define mx95a_resmunlbl 15057 `"Naucalpan De Juarez"', add
label define mx95a_resmunlbl 15058 `"Nezahualcoyotl"', add
label define mx95a_resmunlbl 15060 `"Nicolas Romero"', add
label define mx95a_resmunlbl 15063 `"Ocuilan"', add
label define mx95a_resmunlbl 15064 `"Oro, El"', add
label define mx95a_resmunlbl 15065 `"Otumba"', add
label define mx95a_resmunlbl 15067 `"Otzolotepec"', add
label define mx95a_resmunlbl 15068 `"Ozumba"', add
label define mx95a_resmunlbl 15069 `"Papalotla"', add
label define mx95a_resmunlbl 15070 `"Paz, La"', add
label define mx95a_resmunlbl 15071 `"Polotitlan"', add
label define mx95a_resmunlbl 15074 `"San Felipe Del Progreso"', add
label define mx95a_resmunlbl 15075 `"San Martin De Las Piramides"', add
label define mx95a_resmunlbl 15076 `"San Mateo Atenco"', add
label define mx95a_resmunlbl 15079 `"Soyaniquilpan De Juarez"', add
label define mx95a_resmunlbl 15080 `"Sultepec"', add
label define mx95a_resmunlbl 15081 `"Tecamac"', add
label define mx95a_resmunlbl 15082 `"Tejupilco"', add
label define mx95a_resmunlbl 15083 `"Temamatla"', add
label define mx95a_resmunlbl 15084 `"Temascalapa"', add
label define mx95a_resmunlbl 15085 `"Temascalcingo"', add
label define mx95a_resmunlbl 15087 `"Temoaya"', add
label define mx95a_resmunlbl 15088 `"Tenancingo"', add
label define mx95a_resmunlbl 15090 `"Tenango Del Valle"', add
label define mx95a_resmunlbl 15091 `"Teoloyucan"', add
label define mx95a_resmunlbl 15092 `"Teotihuacan"', add
label define mx95a_resmunlbl 15093 `"Tepetlaoxtoc"', add
label define mx95a_resmunlbl 15094 `"Tepetlixpa"', add
label define mx95a_resmunlbl 15095 `"Tepotzotlan"', add
label define mx95a_resmunlbl 15096 `"Tequixquiac"', add
label define mx95a_resmunlbl 15099 `"Texcoco"', add
label define mx95a_resmunlbl 15101 `"Tianguistenco"', add
label define mx95a_resmunlbl 15102 `"Timilpan"', add
label define mx95a_resmunlbl 15103 `"Tlalmanalco"', add
label define mx95a_resmunlbl 15104 `"Tlalnepantla De Baz"', add
label define mx95a_resmunlbl 15105 `"Tlatlaya"', add
label define mx95a_resmunlbl 15106 `"Toluca"', add
label define mx95a_resmunlbl 15107 `"Tonatico"', add
label define mx95a_resmunlbl 15108 `"Tultepec"', add
label define mx95a_resmunlbl 15109 `"Tultitlan"', add
label define mx95a_resmunlbl 15110 `"Valle De Bravo"', add
label define mx95a_resmunlbl 15111 `"Villa De Allende"', add
label define mx95a_resmunlbl 15114 `"Villa Victoria"', add
label define mx95a_resmunlbl 15115 `"Xonacatlan"', add
label define mx95a_resmunlbl 15117 `"Zacualpan"', add
label define mx95a_resmunlbl 15118 `"Zinacantepec"', add
label define mx95a_resmunlbl 15120 `"Zumpango"', add
label define mx95a_resmunlbl 15121 `"Cuautitlan Izcalli"', add
label define mx95a_resmunlbl 15122 `"Valle De Chalco Solidaridad"', add
label define mx95a_resmunlbl 15999 `"Undocumented"', add
label define mx95a_resmunlbl 16001 `"Acuitzio"', add
label define mx95a_resmunlbl 16002 `"Aguililla"', add
label define mx95a_resmunlbl 16003 `"Alvaro Obregon"', add
label define mx95a_resmunlbl 16004 `"Angamacutiro"', add
label define mx95a_resmunlbl 16005 `"Angangueo"', add
label define mx95a_resmunlbl 16006 `"Apatzingan"', add
label define mx95a_resmunlbl 16008 `"Aquila"', add
label define mx95a_resmunlbl 16009 `"Ario"', add
label define mx95a_resmunlbl 16010 `"Arteaga"', add
label define mx95a_resmunlbl 16011 `"Briseñas"', add
label define mx95a_resmunlbl 16012 `"Buenavista"', add
label define mx95a_resmunlbl 16014 `"Coahuayana"', add
label define mx95a_resmunlbl 16015 `"Coalcoman De Vazquez Pallares"', add
label define mx95a_resmunlbl 16016 `"Coeneo"', add
label define mx95a_resmunlbl 16017 `"Contepec"', add
label define mx95a_resmunlbl 16018 `"Copandaro"', add
label define mx95a_resmunlbl 16019 `"Cotija"', add
label define mx95a_resmunlbl 16022 `"Charo"', add
label define mx95a_resmunlbl 16023 `"Chavinda"', add
label define mx95a_resmunlbl 16024 `"Cheran"', add
label define mx95a_resmunlbl 16026 `"Chinicuila"', add
label define mx95a_resmunlbl 16029 `"Churumuco"', add
label define mx95a_resmunlbl 16030 `"Ecuandureo"', add
label define mx95a_resmunlbl 16031 `"Epitacio Huerta"', add
label define mx95a_resmunlbl 16032 `"Erongaricuaro"', add
label define mx95a_resmunlbl 16033 `"Gabriel Zamora"', add
label define mx95a_resmunlbl 16034 `"Hidalgo"', add
label define mx95a_resmunlbl 16035 `"Huacana, La"', add
label define mx95a_resmunlbl 16036 `"Huandacareo"', add
label define mx95a_resmunlbl 16038 `"Huetamo"', add
label define mx95a_resmunlbl 16042 `"Ixtlan"', add
label define mx95a_resmunlbl 16043 `"Jacona"', add
label define mx95a_resmunlbl 16045 `"Jiquilpan"', add
label define mx95a_resmunlbl 16046 `"Juarez"', add
label define mx95a_resmunlbl 16047 `"Jungapeo"', add
label define mx95a_resmunlbl 16049 `"Madero"', add
label define mx95a_resmunlbl 16050 `"Maravatio"', add
label define mx95a_resmunlbl 16051 `"Marcos Castellanos"', add
label define mx95a_resmunlbl 16052 `"Lazaro Cardenas"', add
label define mx95a_resmunlbl 16053 `"Morelia"', add
label define mx95a_resmunlbl 16054 `"Morelos"', add
label define mx95a_resmunlbl 16055 `"Mugica"', add
label define mx95a_resmunlbl 16056 `"Nahuatzen"', add
label define mx95a_resmunlbl 16057 `"Nocupetaro"', add
label define mx95a_resmunlbl 16061 `"Ocampo"', add
label define mx95a_resmunlbl 16064 `"Paracuaro"', add
label define mx95a_resmunlbl 16065 `"Paracho"', add
label define mx95a_resmunlbl 16066 `"Patzcuaro"', add
label define mx95a_resmunlbl 16067 `"Penjamillo"', add
label define mx95a_resmunlbl 16068 `"Periban"', add
label define mx95a_resmunlbl 16069 `"Piedad, La"', add
label define mx95a_resmunlbl 16071 `"Puruandiro"', add
label define mx95a_resmunlbl 16073 `"Quiroga"', add
label define mx95a_resmunlbl 16075 `"Reyes, Los"', add
label define mx95a_resmunlbl 16076 `"Sahuayo"', add
label define mx95a_resmunlbl 16077 `"San Lucas"', add
label define mx95a_resmunlbl 16078 `"Santa Ana Maya"', add
label define mx95a_resmunlbl 16079 `"Salvador Escalante"', add
label define mx95a_resmunlbl 16082 `"Tacambaro"', add
label define mx95a_resmunlbl 16083 `"Tancitaro"', add
label define mx95a_resmunlbl 16084 `"Tangamandapio"', add
label define mx95a_resmunlbl 16085 `"Tangancicuaro"', add
label define mx95a_resmunlbl 16087 `"Taretan"', add
label define mx95a_resmunlbl 16088 `"Tarimbaro"', add
label define mx95a_resmunlbl 16089 `"Tepalcatepec"', add
label define mx95a_resmunlbl 16092 `"Tiquicheo De Nicolas Romero"', add
label define mx95a_resmunlbl 16093 `"Tlalpujahua"', add
label define mx95a_resmunlbl 16094 `"Tlazazalca"', add
label define mx95a_resmunlbl 16095 `"Tocumbo"', add
label define mx95a_resmunlbl 16096 `"Tumbiscatio"', add
label define mx95a_resmunlbl 16097 `"Turicato"', add
label define mx95a_resmunlbl 16098 `"Tuxpan"', add
label define mx95a_resmunlbl 16100 `"Tzintzuntzan"', add
label define mx95a_resmunlbl 16101 `"Tzitzio"', add
label define mx95a_resmunlbl 16102 `"Uruapan"', add
label define mx95a_resmunlbl 16104 `"Villamar"', add
label define mx95a_resmunlbl 16107 `"Zacapu"', add
label define mx95a_resmunlbl 16108 `"Zamora"', add
label define mx95a_resmunlbl 16110 `"Zinapecuaro"', add
label define mx95a_resmunlbl 16111 `"Ziracuaretiro"', add
label define mx95a_resmunlbl 16112 `"Zitacuaro"', add
label define mx95a_resmunlbl 16113 `"Jose Sixto Verduzco"', add
label define mx95a_resmunlbl 16999 `"Undocumented"', add
label define mx95a_resmunlbl 17001 `"Amacuzac"', add
label define mx95a_resmunlbl 17002 `"Atlatlahucan"', add
label define mx95a_resmunlbl 17003 `"Axochiapan"', add
label define mx95a_resmunlbl 17004 `"Ayala"', add
label define mx95a_resmunlbl 17005 `"Coatlan Del Rio"', add
label define mx95a_resmunlbl 17006 `"Cuautla"', add
label define mx95a_resmunlbl 17007 `"Cuernavaca"', add
label define mx95a_resmunlbl 17008 `"Emiliano Zapata"', add
label define mx95a_resmunlbl 17009 `"Huitzilac"', add
label define mx95a_resmunlbl 17010 `"Jantetelco"', add
label define mx95a_resmunlbl 17011 `"Jiutepec"', add
label define mx95a_resmunlbl 17012 `"Jojutla"', add
label define mx95a_resmunlbl 17013 `"Jonacatepec"', add
label define mx95a_resmunlbl 17014 `"Mazatepec"', add
label define mx95a_resmunlbl 17015 `"Miacatlan"', add
label define mx95a_resmunlbl 17016 `"Ocuituco"', add
label define mx95a_resmunlbl 17017 `"Puente De Ixtla"', add
label define mx95a_resmunlbl 17018 `"Temixco"', add
label define mx95a_resmunlbl 17019 `"Tepalcingo"', add
label define mx95a_resmunlbl 17021 `"Tetecala"', add
label define mx95a_resmunlbl 17022 `"Tetela Del Volcan"', add
label define mx95a_resmunlbl 17024 `"Tlaltizapan"', add
label define mx95a_resmunlbl 17025 `"Tlaquiltenango"', add
label define mx95a_resmunlbl 17028 `"Xochitepec"', add
label define mx95a_resmunlbl 17029 `"Yautepec"', add
label define mx95a_resmunlbl 17030 `"Yecapixtla"', add
label define mx95a_resmunlbl 17031 `"Zacatepec De Hidalgo"', add
label define mx95a_resmunlbl 17999 `"Undocumented"', add
label define mx95a_resmunlbl 18001 `"Acaponeta"', add
label define mx95a_resmunlbl 18002 `"Ahuacatlan"', add
label define mx95a_resmunlbl 18004 `"Compostela"', add
label define mx95a_resmunlbl 18005 `"Huajicori"', add
label define mx95a_resmunlbl 18006 `"Ixtlan Del Rio"', add
label define mx95a_resmunlbl 18007 `"Jala"', add
label define mx95a_resmunlbl 18008 `"Xalisco"', add
label define mx95a_resmunlbl 18009 `"Nayar, El"', add
label define mx95a_resmunlbl 18010 `"Rosamorada"', add
label define mx95a_resmunlbl 18011 `"Ruiz"', add
label define mx95a_resmunlbl 18012 `"San Blas"', add
label define mx95a_resmunlbl 18013 `"San Pedro Lagunillas"', add
label define mx95a_resmunlbl 18014 `"Santa Maria Del Oro"', add
label define mx95a_resmunlbl 18015 `"Santiago Ixcuintla"', add
label define mx95a_resmunlbl 18016 `"Tecuala"', add
label define mx95a_resmunlbl 18017 `"Tepic"', add
label define mx95a_resmunlbl 18018 `"Tuxpan"', add
label define mx95a_resmunlbl 18019 `"Yesca, La"', add
label define mx95a_resmunlbl 18020 `"Bahia De Banderas"', add
label define mx95a_resmunlbl 18999 `"Undocumented"', add
label define mx95a_resmunlbl 19001 `"Abasolo"', add
label define mx95a_resmunlbl 19003 `"Aldamas, Los"', add
label define mx95a_resmunlbl 19004 `"Allende"', add
label define mx95a_resmunlbl 19005 `"Anahuac"', add
label define mx95a_resmunlbl 19006 `"Apodaca"', add
label define mx95a_resmunlbl 19007 `"Aramberri"', add
label define mx95a_resmunlbl 19008 `"Bustamante"', add
label define mx95a_resmunlbl 19009 `"Cadereyta Jimenez"', add
label define mx95a_resmunlbl 19010 `"Carmen"', add
label define mx95a_resmunlbl 19011 `"Cerralvo"', add
label define mx95a_resmunlbl 19013 `"China"', add
label define mx95a_resmunlbl 19014 `"Doctor Arroyo"', add
label define mx95a_resmunlbl 19015 `"Doctor Coss"', add
label define mx95a_resmunlbl 19017 `"Galeana"', add
label define mx95a_resmunlbl 19019 `"San Pedro Garza Garcia"', add
label define mx95a_resmunlbl 19021 `"General Escobedo"', add
label define mx95a_resmunlbl 19022 `"General Teran"', add
label define mx95a_resmunlbl 19024 `"General Zaragoza"', add
label define mx95a_resmunlbl 19025 `"General Zuazua"', add
label define mx95a_resmunlbl 19026 `"Guadalupe"', add
label define mx95a_resmunlbl 19028 `"Higueras"', add
label define mx95a_resmunlbl 19029 `"Hualahuises"', add
label define mx95a_resmunlbl 19032 `"Lampazos De Naranjo"', add
label define mx95a_resmunlbl 19033 `"Linares"', add
label define mx95a_resmunlbl 19034 `"Marin"', add
label define mx95a_resmunlbl 19035 `"Melchor Ocampo"', add
label define mx95a_resmunlbl 19036 `"Mier Y Noriega"', add
label define mx95a_resmunlbl 19037 `"Mina"', add
label define mx95a_resmunlbl 19038 `"Montemorelos"', add
label define mx95a_resmunlbl 19039 `"Monterrey"', add
label define mx95a_resmunlbl 19040 `"Paras"', add
label define mx95a_resmunlbl 19041 `"Pesqueria"', add
label define mx95a_resmunlbl 19042 `"Ramones, Los"', add
label define mx95a_resmunlbl 19044 `"Sabinas Hidalgo"', add
label define mx95a_resmunlbl 19046 `"San Nicolas De Los Garza"', add
label define mx95a_resmunlbl 19047 `"Hidalgo"', add
label define mx95a_resmunlbl 19048 `"Santa Catarina"', add
label define mx95a_resmunlbl 19049 `"Santiago"', add
label define mx95a_resmunlbl 19050 `"Vallecillo"', add
label define mx95a_resmunlbl 19051 `"Villaldama"', add
label define mx95a_resmunlbl 19999 `"Undocumented"', add
label define mx95a_resmunlbl 20002 `"Acatlan De Perez Figueroa"', add
label define mx95a_resmunlbl 20005 `"Asuncion Ixtaltepec"', add
label define mx95a_resmunlbl 20006 `"Asuncion Nochixtlan"', add
label define mx95a_resmunlbl 20010 `"Barrio De La Soledad, El"', add
label define mx95a_resmunlbl 20012 `"Candelaria Loxicha"', add
label define mx95a_resmunlbl 20013 `"Cienega De Zimatlan"', add
label define mx95a_resmunlbl 20014 `"Ciudad Ixtepec"', add
label define mx95a_resmunlbl 20016 `"Coicoyan De Las Flores"', add
label define mx95a_resmunlbl 20021 `"Cosolapa"', add
label define mx95a_resmunlbl 20022 `"Cosoltepec"', add
label define mx95a_resmunlbl 20023 `"Cuilapam De Guerrero"', add
label define mx95a_resmunlbl 20025 `"Chahuites"', add
label define mx95a_resmunlbl 20026 `"Chalcatongo De Hidalgo"', add
label define mx95a_resmunlbl 20028 `"Heroica Ciudad De Ejutla De Crespo"', add
label define mx95a_resmunlbl 20035 `"Guelatao De Juarez"', add
label define mx95a_resmunlbl 20036 `"Guevea De Humboldt"', add
label define mx95a_resmunlbl 20038 `"Villa Hidalgo"', add
label define mx95a_resmunlbl 20039 `"Ciudad De Huajuapam De Leon"', add
label define mx95a_resmunlbl 20041 `"Huautla De Jimenez"', add
label define mx95a_resmunlbl 20042 `"Ixtlan De Juarez"', add
label define mx95a_resmunlbl 20043 `"Juchitan De Zaragoza"', add
label define mx95a_resmunlbl 20044 `"Loma Bonita"', add
label define mx95a_resmunlbl 20052 `"Magdalena Tequisistlan"', add
label define mx95a_resmunlbl 20057 `"Matias Romero"', add
label define mx95a_resmunlbl 20059 `"Miahuatlan De Porfirio Diaz"', add
label define mx95a_resmunlbl 20066 `"Santiago Niltepec"', add
label define mx95a_resmunlbl 20067 `"Oaxaca De Juarez"', add
label define mx95a_resmunlbl 20068 `"Ocotlan De Morelos"', add
label define mx95a_resmunlbl 20071 `"Pluma Hidalgo"', add
label define mx95a_resmunlbl 20072 `"San Jose Del Progreso"', add
label define mx95a_resmunlbl 20073 `"Putla Villa De Guerrero"', add
label define mx95a_resmunlbl 20077 `"Reyes Etla"', add
label define mx95a_resmunlbl 20079 `"Salina Cruz"', add
label define mx95a_resmunlbl 20102 `"San Andres Zautla"', add
label define mx95a_resmunlbl 20104 `"San Antonino El Alto"', add
label define mx95a_resmunlbl 20107 `"San Antonio De La Cal"', add
label define mx95a_resmunlbl 20114 `"San Baltazar Yatzachi El Bajo"', add
label define mx95a_resmunlbl 20122 `"San Bartolo Yautepec"', add
label define mx95a_resmunlbl 20125 `"San Carlos Yautepec"', add
label define mx95a_resmunlbl 20131 `"San Dionisio Ocotepec"', add
label define mx95a_resmunlbl 20134 `"San Felipe Jalapa De Diaz"', add
label define mx95a_resmunlbl 20147 `"San Francisco Nuxaño"', add
label define mx95a_resmunlbl 20150 `"San Francisco Telixtlahuaca"', add
label define mx95a_resmunlbl 20176 `"San Juan Bautista Coixtlahuaca"', add
label define mx95a_resmunlbl 20177 `"San Juan Bautista Cuicatlan"', add
label define mx95a_resmunlbl 20180 `"San Juan Bautista Lo De Soto"', add
label define mx95a_resmunlbl 20184 `"San Juan Bautista Tuxtepec"', add
label define mx95a_resmunlbl 20190 `"San Juan Cotzocon"', add
label define mx95a_resmunlbl 20194 `"San Juan Del Rio"', add
label define mx95a_resmunlbl 20198 `"San Juan Guichicovi"', add
label define mx95a_resmunlbl 20207 `"San Juan Mazatlan"', add
label define mx95a_resmunlbl 20208 `"San Juan Mixtepec -Distr. 08-"', add
label define mx95a_resmunlbl 20209 `"San Juan Mixtepec -Distr. 26-"', add
label define mx95a_resmunlbl 20210 `"San Juan Ñumi"', add
label define mx95a_resmunlbl 20220 `"San Juan Tepeuxila"', add
label define mx95a_resmunlbl 20223 `"San Juan Yatzona"', add
label define mx95a_resmunlbl 20226 `"San Lorenzo Albarradas"', add
label define mx95a_resmunlbl 20232 `"San Lucas Ojitlan"', add
label define mx95a_resmunlbl 20253 `"San Mateo Piñas"', add
label define mx95a_resmunlbl 20258 `"San Miguel Achiutla"', add
label define mx95a_resmunlbl 20277 `"Villa Sola De Vega"', add
label define mx95a_resmunlbl 20278 `"San Miguel Soyaltepec"', add
label define mx95a_resmunlbl 20285 `"San Miguel Tlacamama"', add
label define mx95a_resmunlbl 20286 `"San Miguel Tlacotepec"', add
label define mx95a_resmunlbl 20289 `"San Nicolas"', add
label define mx95a_resmunlbl 20292 `"San Pablo Cuatro Venados"', add
label define mx95a_resmunlbl 20293 `"San Pablo Etla"', add
label define mx95a_resmunlbl 20318 `"San Pedro Mixtepec -Distr. 22-"', add
label define mx95a_resmunlbl 20324 `"San Pedro Pochutla"', add
label define mx95a_resmunlbl 20325 `"San Pedro Quiatoni"', add
label define mx95a_resmunlbl 20327 `"San Pedro Tapanatepec"', add
label define mx95a_resmunlbl 20333 `"San Pedro Totolapa"', add
label define mx95a_resmunlbl 20334 `"Villa De Tututepec De Melchor Ocampo"', add
label define mx95a_resmunlbl 20345 `"San Sebastian Ixcapa"', add
label define mx95a_resmunlbl 20348 `"San Sebastian Tecomaxtlahuaca"', add
label define mx95a_resmunlbl 20350 `"San Sebastian Tutla"', add
label define mx95a_resmunlbl 20364 `"Santa Catarina Juquila"', add
label define mx95a_resmunlbl 20365 `"Santa Catarina Lachatao"', add
label define mx95a_resmunlbl 20366 `"Santa Catarina Loxicha"', add
label define mx95a_resmunlbl 20371 `"Santa Catarina Ticua"', add
label define mx95a_resmunlbl 20375 `"Santa Cruz Amilpas"', add
label define mx95a_resmunlbl 20378 `"Santa Cruz Mixtepec"', add
label define mx95a_resmunlbl 20385 `"Santa Cruz Xoxocotlan"', add
label define mx95a_resmunlbl 20386 `"Santa Cruz Zenzontepec"', add
label define mx95a_resmunlbl 20390 `"Santa Lucia Del Camino"', add
label define mx95a_resmunlbl 20397 `"Heroica Ciudad De Tlaxiaco"', add
label define mx95a_resmunlbl 20399 `"Santa Maria Atzompa"', add
label define mx95a_resmunlbl 20401 `"Santa Maria Colotepec"', add
label define mx95a_resmunlbl 20407 `"Santa Maria Chimalapa"', add
label define mx95a_resmunlbl 20409 `"Santa Maria Del Tule"', add
label define mx95a_resmunlbl 20413 `"Santa Maria Huatulco"', add
label define mx95a_resmunlbl 20437 `"Santa Maria Tlahuitoltepec"', add
label define mx95a_resmunlbl 20446 `"Santa Maria Yucuhiti"', add
label define mx95a_resmunlbl 20453 `"Santiago Astata"', add
label define mx95a_resmunlbl 20454 `"Santiago Atitlan"', add
label define mx95a_resmunlbl 20459 `"Santiago Chazumba"', add
label define mx95a_resmunlbl 20460 `"Santiago Choapam"', add
label define mx95a_resmunlbl 20467 `"Santiago Jamiltepec"', add
label define mx95a_resmunlbl 20469 `"Santiago Juxtlahuaca"', add
label define mx95a_resmunlbl 20470 `"Santiago Lachiguiri"', add
label define mx95a_resmunlbl 20474 `"Santiago Llano Grande"', add
label define mx95a_resmunlbl 20477 `"Santiago Minas"', add
label define mx95a_resmunlbl 20482 `"Santiago Pinotepa Nacional"', add
label define mx95a_resmunlbl 20486 `"Villa Tejupam De La Union"', add
label define mx95a_resmunlbl 20495 `"Santiago Xanica"', add
label define mx95a_resmunlbl 20498 `"Santiago Yaveo"', add
label define mx95a_resmunlbl 20506 `"Santo Domingo Albarradas"', add
label define mx95a_resmunlbl 20515 `"Santo Domingo Tehuantepec"', add
label define mx95a_resmunlbl 20520 `"Santo Domingo Tonala"', add
label define mx95a_resmunlbl 20525 `"Santo Domingo Zanatepec"', add
label define mx95a_resmunlbl 20528 `"Santos Reyes Tepejillo"', add
label define mx95a_resmunlbl 20530 `"Santo Tomas Jalieza"', add
label define mx95a_resmunlbl 20532 `"Santo Tomas Ocotepec"', add
label define mx95a_resmunlbl 20537 `"Silacayoapam"', add
label define mx95a_resmunlbl 20539 `"Soledad Etla"', add
label define mx95a_resmunlbl 20544 `"Teococuilco De Marcos Perez"', add
label define mx95a_resmunlbl 20545 `"Teotitlan De Flores Magon"', add
label define mx95a_resmunlbl 20546 `"Teotitlan Del Valle"', add
label define mx95a_resmunlbl 20547 `"Teotongo"', add
label define mx95a_resmunlbl 20551 `"Tlacolula De Matamoros"', add
label define mx95a_resmunlbl 20554 `"Totontepec Villa De Morelos"', add
label define mx95a_resmunlbl 20558 `"Valerio Trujano"', add
label define mx95a_resmunlbl 20559 `"San Juan Bautista Valle Nacional"', add
label define mx95a_resmunlbl 20562 `"Magdalena Yodocono De Porfirio Diaz"', add
label define mx95a_resmunlbl 20569 `"Santa Ines De Zaragoza"', add
label define mx95a_resmunlbl 20570 `"Zimatlan De Alvarez"', add
label define mx95a_resmunlbl 20999 `"Undocumented"', add
label define mx95a_resmunlbl 21002 `"Acateno"', add
label define mx95a_resmunlbl 21003 `"Acatlan"', add
label define mx95a_resmunlbl 21004 `"Acatzingo"', add
label define mx95a_resmunlbl 21007 `"Ahuatlan"', add
label define mx95a_resmunlbl 21008 `"Ahuazotepec"', add
label define mx95a_resmunlbl 21015 `"Amozoc"', add
label define mx95a_resmunlbl 21019 `"Atlixco"', add
label define mx95a_resmunlbl 21020 `"Atoyatempan"', add
label define mx95a_resmunlbl 21022 `"Atzitzihuacan"', add
label define mx95a_resmunlbl 21025 `"Ayotoxco De Guerrero"', add
label define mx95a_resmunlbl 21026 `"Calpan"', add
label define mx95a_resmunlbl 21029 `"Caxhuacan"', add
label define mx95a_resmunlbl 21034 `"Coronango"', add
label define mx95a_resmunlbl 21041 `"Cuautlancingo"', add
label define mx95a_resmunlbl 21043 `"Cuetzalan Del Progreso"', add
label define mx95a_resmunlbl 21044 `"Cuyoaco"', add
label define mx95a_resmunlbl 21045 `"Chalchicomula De Sesma"', add
label define mx95a_resmunlbl 21047 `"Chiautla"', add
label define mx95a_resmunlbl 21048 `"Chiautzingo"', add
label define mx95a_resmunlbl 21050 `"Chichiquila"', add
label define mx95a_resmunlbl 21051 `"Chietla"', add
label define mx95a_resmunlbl 21053 `"Chignahuapan"', add
label define mx95a_resmunlbl 21055 `"Chila"', add
label define mx95a_resmunlbl 21064 `"Francisco Z. Mena"', add
label define mx95a_resmunlbl 21066 `"Guadalupe"', add
label define mx95a_resmunlbl 21067 `"Guadalupe Victoria"', add
label define mx95a_resmunlbl 21069 `"Huaquechula"', add
label define mx95a_resmunlbl 21071 `"Huauchinango"', add
label define mx95a_resmunlbl 21073 `"Huehuetlan El Chico"', add
label define mx95a_resmunlbl 21074 `"Huejotzingo"', add
label define mx95a_resmunlbl 21076 `"Hueytamalco"', add
label define mx95a_resmunlbl 21078 `"Huitzilan De Serdan"', add
label define mx95a_resmunlbl 21083 `"Ixtacamaxtitlan"', add
label define mx95a_resmunlbl 21085 `"Izucar De Matamoros"', add
label define mx95a_resmunlbl 21087 `"Jolalpan"', add
label define mx95a_resmunlbl 21088 `"Jonotla"', add
label define mx95a_resmunlbl 21090 `"Juan C. Bonilla"', add
label define mx95a_resmunlbl 21093 `"Lafragua"', add
label define mx95a_resmunlbl 21094 `"Libres"', add
label define mx95a_resmunlbl 21099 `"Cañada Morelos"', add
label define mx95a_resmunlbl 21108 `"Oriental"', add
label define mx95a_resmunlbl 21109 `"Pahuatlan"', add
label define mx95a_resmunlbl 21111 `"Pantepec"', add
label define mx95a_resmunlbl 21112 `"Petlalcingo"', add
label define mx95a_resmunlbl 21113 `"Piaxtla"', add
label define mx95a_resmunlbl 21114 `"Puebla"', add
label define mx95a_resmunlbl 21115 `"Quecholac"', add
label define mx95a_resmunlbl 21116 `"Quimixtlan"', add
label define mx95a_resmunlbl 21117 `"Rafael Lara Grajales"', add
label define mx95a_resmunlbl 21119 `"San Andres Cholula"', add
label define mx95a_resmunlbl 21121 `"San Diego La Mesa Tochimiltzingo"', add
label define mx95a_resmunlbl 21123 `"San Felipe Tepatlan"', add
label define mx95a_resmunlbl 21132 `"San Martin Texmelucan"', add
label define mx95a_resmunlbl 21136 `"San Miguel Xoxtla"', add
label define mx95a_resmunlbl 21137 `"San Nicolas Buenos Aires"', add
label define mx95a_resmunlbl 21140 `"San Pedro Cholula"', add
label define mx95a_resmunlbl 21145 `"San Sebastian Tlacotepec"', add
label define mx95a_resmunlbl 21147 `"Santa Ines Ahuatempan"', add
label define mx95a_resmunlbl 21150 `"Huehuetlan El Grande"', add
label define mx95a_resmunlbl 21152 `"Soltepec"', add
label define mx95a_resmunlbl 21153 `"Tecali De Herrera"', add
label define mx95a_resmunlbl 21154 `"Tecamachalco"', add
label define mx95a_resmunlbl 21156 `"Tehuacan"', add
label define mx95a_resmunlbl 21157 `"Tehuitzingo"', add
label define mx95a_resmunlbl 21158 `"Tenampulco"', add
label define mx95a_resmunlbl 21163 `"Tepatlaxco De Hidalgo"', add
label define mx95a_resmunlbl 21164 `"Tepeaca"', add
label define mx95a_resmunlbl 21165 `"Tepemaxalco"', add
label define mx95a_resmunlbl 21166 `"Tepeojuma"', add
label define mx95a_resmunlbl 21169 `"Tepexi De Rodriguez"', add
label define mx95a_resmunlbl 21172 `"Tetela De Ocampo"', add
label define mx95a_resmunlbl 21174 `"Teziutlan"', add
label define mx95a_resmunlbl 21176 `"Tilapa"', add
label define mx95a_resmunlbl 21177 `"Tlacotepec De Benito Juarez"', add
label define mx95a_resmunlbl 21178 `"Tlacuilotepec"', add
label define mx95a_resmunlbl 21179 `"Tlachichuca"', add
label define mx95a_resmunlbl 21180 `"Tlahuapan"', add
label define mx95a_resmunlbl 21183 `"Tlaola"', add
label define mx95a_resmunlbl 21186 `"Tlatlauquitepec"', add
label define mx95a_resmunlbl 21188 `"Tochimilco"', add
label define mx95a_resmunlbl 21194 `"Venustiano Carranza"', add
label define mx95a_resmunlbl 21197 `"Xicotepec"', add
label define mx95a_resmunlbl 21199 `"Xiutetelco"', add
label define mx95a_resmunlbl 21201 `"Xochiltepec"', add
label define mx95a_resmunlbl 21207 `"Zacapoaxtla"', add
label define mx95a_resmunlbl 21208 `"Zacatlan"', add
label define mx95a_resmunlbl 21209 `"Zapotitlan"', add
label define mx95a_resmunlbl 21211 `"Zaragoza"', add
label define mx95a_resmunlbl 21212 `"Zautla"', add
label define mx95a_resmunlbl 21214 `"Zinacatepec"', add
label define mx95a_resmunlbl 21216 `"Zoquiapan"', add
label define mx95a_resmunlbl 21217 `"Zoquitlan"', add
label define mx95a_resmunlbl 21999 `"Undocumented"', add
label define mx95a_resmunlbl 22001 `"Amealco De Bonfil"', add
label define mx95a_resmunlbl 22002 `"Pinal De Amoles"', add
label define mx95a_resmunlbl 22003 `"Arroyo Seco"', add
label define mx95a_resmunlbl 22004 `"Cadereyta De Montes"', add
label define mx95a_resmunlbl 22005 `"Colon"', add
label define mx95a_resmunlbl 22006 `"Corregidora"', add
label define mx95a_resmunlbl 22007 `"Ezequiel Montes"', add
label define mx95a_resmunlbl 22008 `"Huimilpan"', add
label define mx95a_resmunlbl 22009 `"Jalpan De Serra"', add
label define mx95a_resmunlbl 22010 `"Landa De Matamoros"', add
label define mx95a_resmunlbl 22011 `"Marques, El"', add
label define mx95a_resmunlbl 22012 `"Pedro Escobedo"', add
label define mx95a_resmunlbl 22013 `"Peñamiller"', add
label define mx95a_resmunlbl 22014 `"Queretaro"', add
label define mx95a_resmunlbl 22015 `"San Joaquin"', add
label define mx95a_resmunlbl 22016 `"San Juan Del Rio"', add
label define mx95a_resmunlbl 22017 `"Tequisquiapan"', add
label define mx95a_resmunlbl 22018 `"Toliman"', add
label define mx95a_resmunlbl 22999 `"Undocumented"', add
label define mx95a_resmunlbl 23001 `"Cozumel"', add
label define mx95a_resmunlbl 23002 `"Felipe Carrillo Puerto"', add
label define mx95a_resmunlbl 23003 `"Isla Mujeres"', add
label define mx95a_resmunlbl 23004 `"Othon P. Blanco"', add
label define mx95a_resmunlbl 23005 `"Benito Juarez"', add
label define mx95a_resmunlbl 23006 `"Jose Maria Morelos"', add
label define mx95a_resmunlbl 23007 `"Lazaro Cardenas"', add
label define mx95a_resmunlbl 23008 `"Solidaridad"', add
label define mx95a_resmunlbl 23999 `"Undocumented"', add
label define mx95a_resmunlbl 24001 `"Ahualulco"', add
label define mx95a_resmunlbl 24003 `"Aquismon"', add
label define mx95a_resmunlbl 24004 `"Armadillo De Los Infante"', add
label define mx95a_resmunlbl 24005 `"Cardenas"', add
label define mx95a_resmunlbl 24007 `"Cedral"', add
label define mx95a_resmunlbl 24008 `"Cerritos"', add
label define mx95a_resmunlbl 24010 `"Ciudad Del Maiz"', add
label define mx95a_resmunlbl 24011 `"Ciudad Fernandez"', add
label define mx95a_resmunlbl 24012 `"Tancanhuitz De Santos"', add
label define mx95a_resmunlbl 24013 `"Ciudad Valles"', add
label define mx95a_resmunlbl 24014 `"Coxcatlan"', add
label define mx95a_resmunlbl 24015 `"Charcas"', add
label define mx95a_resmunlbl 24016 `"Ebano"', add
label define mx95a_resmunlbl 24017 `"Guadalcazar"', add
label define mx95a_resmunlbl 24018 `"Huehuetlan"', add
label define mx95a_resmunlbl 24019 `"Lagunillas"', add
label define mx95a_resmunlbl 24020 `"Matehuala"', add
label define mx95a_resmunlbl 24021 `"Mexquitic De Carmona"', add
label define mx95a_resmunlbl 24022 `"Moctezuma"', add
label define mx95a_resmunlbl 24023 `"Rayon"', add
label define mx95a_resmunlbl 24024 `"Rioverde"', add
label define mx95a_resmunlbl 24025 `"Salinas"', add
label define mx95a_resmunlbl 24026 `"San Antonio"', add
label define mx95a_resmunlbl 24027 `"San Ciro De Acosta"', add
label define mx95a_resmunlbl 24028 `"San Luis Potosi"', add
label define mx95a_resmunlbl 24029 `"San Martin Chalchicuautla"', add
label define mx95a_resmunlbl 24030 `"San Nicolas Tolentino"', add
label define mx95a_resmunlbl 24032 `"Santa Maria Del Rio"', add
label define mx95a_resmunlbl 24034 `"San Vicente Tancuayalab"', add
label define mx95a_resmunlbl 24035 `"Soledad De Graciano Sanchez"', add
label define mx95a_resmunlbl 24036 `"Tamasopo"', add
label define mx95a_resmunlbl 24037 `"Tamazunchale"', add
label define mx95a_resmunlbl 24038 `"Tampacan"', add
label define mx95a_resmunlbl 24040 `"Tamuin"', add
label define mx95a_resmunlbl 24042 `"Tanquian De Escobedo"', add
label define mx95a_resmunlbl 24043 `"Tierranueva"', add
label define mx95a_resmunlbl 24044 `"Vanegas"', add
label define mx95a_resmunlbl 24045 `"Venado"', add
label define mx95a_resmunlbl 24047 `"Villa De Guadalupe"', add
label define mx95a_resmunlbl 24048 `"Villa De La Paz"', add
label define mx95a_resmunlbl 24049 `"Villa De Ramos"', add
label define mx95a_resmunlbl 24050 `"Villa De Reyes"', add
label define mx95a_resmunlbl 24051 `"Villa Hidalgo"', add
label define mx95a_resmunlbl 24052 `"Villa Juarez"', add
label define mx95a_resmunlbl 24053 `"Axtla De Terrazas"', add
label define mx95a_resmunlbl 24054 `"Xilitla"', add
label define mx95a_resmunlbl 24055 `"Zaragoza"', add
label define mx95a_resmunlbl 24056 `"Villa De Arista"', add
label define mx95a_resmunlbl 24057 `"Matlapa"', add
label define mx95a_resmunlbl 24999 `"Undocumented"', add
label define mx95a_resmunlbl 25001 `"Ahome"', add
label define mx95a_resmunlbl 25002 `"Angostura"', add
label define mx95a_resmunlbl 25003 `"Badiraguato"', add
label define mx95a_resmunlbl 25004 `"Concordia"', add
label define mx95a_resmunlbl 25005 `"Cosala"', add
label define mx95a_resmunlbl 25006 `"Culiacan"', add
label define mx95a_resmunlbl 25007 `"Choix"', add
label define mx95a_resmunlbl 25008 `"Elota"', add
label define mx95a_resmunlbl 25009 `"Escuinapa"', add
label define mx95a_resmunlbl 25010 `"Fuerte, El"', add
label define mx95a_resmunlbl 25011 `"Guasave"', add
label define mx95a_resmunlbl 25012 `"Mazatlan"', add
label define mx95a_resmunlbl 25013 `"Mocorito"', add
label define mx95a_resmunlbl 25014 `"Rosario"', add
label define mx95a_resmunlbl 25015 `"Salvador Alvarado"', add
label define mx95a_resmunlbl 25016 `"San Ignacio"', add
label define mx95a_resmunlbl 25017 `"Sinaloa"', add
label define mx95a_resmunlbl 25018 `"Navolato"', add
label define mx95a_resmunlbl 25999 `"Undocumented"', add
label define mx95a_resmunlbl 26002 `"Agua Prieta"', add
label define mx95a_resmunlbl 26003 `"Alamos"', add
label define mx95a_resmunlbl 26005 `"Arivechi"', add
label define mx95a_resmunlbl 26008 `"Bacadehuachi"', add
label define mx95a_resmunlbl 26012 `"Bacum"', add
label define mx95a_resmunlbl 26014 `"Baviacora"', add
label define mx95a_resmunlbl 26015 `"Bavispe"', add
label define mx95a_resmunlbl 26016 `"Benjamin Hill"', add
label define mx95a_resmunlbl 26017 `"Caborca"', add
label define mx95a_resmunlbl 26018 `"Cajeme"', add
label define mx95a_resmunlbl 26019 `"Cananea"', add
label define mx95a_resmunlbl 26020 `"Carbo"', add
label define mx95a_resmunlbl 26021 `"Colorada, La"', add
label define mx95a_resmunlbl 26023 `"Cumpas"', add
label define mx95a_resmunlbl 26024 `"Divisaderos"', add
label define mx95a_resmunlbl 26025 `"Empalme"', add
label define mx95a_resmunlbl 26026 `"Etchojoa"', add
label define mx95a_resmunlbl 26027 `"Fronteras"', add
label define mx95a_resmunlbl 26029 `"Guaymas"', add
label define mx95a_resmunlbl 26030 `"Hermosillo"', add
label define mx95a_resmunlbl 26033 `"Huatabampo"', add
label define mx95a_resmunlbl 26034 `"Huepac"', add
label define mx95a_resmunlbl 26036 `"Magdalena"', add
label define mx95a_resmunlbl 26039 `"Naco"', add
label define mx95a_resmunlbl 26041 `"Nacozari De Garcia"', add
label define mx95a_resmunlbl 26042 `"Navojoa"', add
label define mx95a_resmunlbl 26043 `"Nogales"', add
label define mx95a_resmunlbl 26048 `"Puerto Peñasco"', add
label define mx95a_resmunlbl 26052 `"Sahuaripa"', add
label define mx95a_resmunlbl 26055 `"San Luis Rio Colorado"', add
label define mx95a_resmunlbl 26056 `"San Miguel De Horcasitas"', add
label define mx95a_resmunlbl 26058 `"Santa Ana"', add
label define mx95a_resmunlbl 26061 `"Soyopa"', add
label define mx95a_resmunlbl 26066 `"Ures"', add
label define mx95a_resmunlbl 26070 `"General Plutarco Elias Calles"', add
label define mx95a_resmunlbl 26999 `"Undocumented"', add
label define mx95a_resmunlbl 27001 `"Balancan"', add
label define mx95a_resmunlbl 27002 `"Cardenas"', add
label define mx95a_resmunlbl 27003 `"Centla"', add
label define mx95a_resmunlbl 27004 `"Centro"', add
label define mx95a_resmunlbl 27005 `"Comalcalco"', add
label define mx95a_resmunlbl 27006 `"Cunduacan"', add
label define mx95a_resmunlbl 27007 `"Emiliano Zapata"', add
label define mx95a_resmunlbl 27008 `"Huimanguillo"', add
label define mx95a_resmunlbl 27009 `"Jalapa"', add
label define mx95a_resmunlbl 27010 `"Jalpa De Mendez"', add
label define mx95a_resmunlbl 27011 `"Jonuta"', add
label define mx95a_resmunlbl 27012 `"Macuspana"', add
label define mx95a_resmunlbl 27013 `"Nacajuca"', add
label define mx95a_resmunlbl 27014 `"Paraiso"', add
label define mx95a_resmunlbl 27015 `"Tacotalpa"', add
label define mx95a_resmunlbl 27016 `"Teapa"', add
label define mx95a_resmunlbl 27017 `"Tenosique"', add
label define mx95a_resmunlbl 27999 `"Undocumented"', add
label define mx95a_resmunlbl 28001 `"Abasolo"', add
label define mx95a_resmunlbl 28002 `"Aldama"', add
label define mx95a_resmunlbl 28003 `"Altamira"', add
label define mx95a_resmunlbl 28005 `"Burgos"', add
label define mx95a_resmunlbl 28006 `"Bustamante"', add
label define mx95a_resmunlbl 28008 `"Casas"', add
label define mx95a_resmunlbl 28009 `"Ciudad Madero"', add
label define mx95a_resmunlbl 28011 `"Gomez Farias"', add
label define mx95a_resmunlbl 28012 `"Gonzalez"', add
label define mx95a_resmunlbl 28013 `"Güemez"', add
label define mx95a_resmunlbl 28015 `"Gustavo Diaz Ordaz"', add
label define mx95a_resmunlbl 28016 `"Hidalgo"', add
label define mx95a_resmunlbl 28017 `"Jaumave"', add
label define mx95a_resmunlbl 28018 `"Jimenez"', add
label define mx95a_resmunlbl 28019 `"Llera"', add
label define mx95a_resmunlbl 28021 `"Mante, El"', add
label define mx95a_resmunlbl 28022 `"Matamoros"', add
label define mx95a_resmunlbl 28023 `"Mendez"', add
label define mx95a_resmunlbl 28025 `"Miguel Aleman"', add
label define mx95a_resmunlbl 28026 `"Miquihuana"', add
label define mx95a_resmunlbl 28027 `"Nuevo Laredo"', add
label define mx95a_resmunlbl 28029 `"Ocampo"', add
label define mx95a_resmunlbl 28030 `"Padilla"', add
label define mx95a_resmunlbl 28031 `"Palmillas"', add
label define mx95a_resmunlbl 28032 `"Reynosa"', add
label define mx95a_resmunlbl 28033 `"Rio Bravo"', add
label define mx95a_resmunlbl 28034 `"San Carlos"', add
label define mx95a_resmunlbl 28035 `"San Fernando"', add
label define mx95a_resmunlbl 28037 `"Soto La Marina"', add
label define mx95a_resmunlbl 28038 `"Tampico"', add
label define mx95a_resmunlbl 28039 `"Tula"', add
label define mx95a_resmunlbl 28040 `"Valle Hermoso"', add
label define mx95a_resmunlbl 28041 `"Victoria"', add
label define mx95a_resmunlbl 28042 `"Villagran"', add
label define mx95a_resmunlbl 28043 `"Xicotencatl"', add
label define mx95a_resmunlbl 28999 `"Undocumented"', add
label define mx95a_resmunlbl 29001 `"Amaxac De Guerrero"', add
label define mx95a_resmunlbl 29002 `"Apetatitlan De Antonio Carvajal"', add
label define mx95a_resmunlbl 29003 `"Atlangatepec"', add
label define mx95a_resmunlbl 29004 `"Altzayanca"', add
label define mx95a_resmunlbl 29005 `"Apizaco"', add
label define mx95a_resmunlbl 29006 `"Calpulalpan"', add
label define mx95a_resmunlbl 29007 `"Carmen Tequexquitla, El"', add
label define mx95a_resmunlbl 29009 `"Cuaxomulco"', add
label define mx95a_resmunlbl 29010 `"Chiautempan"', add
label define mx95a_resmunlbl 29012 `"Españita"', add
label define mx95a_resmunlbl 29013 `"Huamantla"', add
label define mx95a_resmunlbl 29014 `"Hueyotlipan"', add
label define mx95a_resmunlbl 29015 `"Ixtacuixtla De Mariano Matamoros"', add
label define mx95a_resmunlbl 29016 `"Ixtenco"', add
label define mx95a_resmunlbl 29018 `"Contla De Juan Cuamatzi"', add
label define mx95a_resmunlbl 29019 `"Tepetitla De Lardizabal"', add
label define mx95a_resmunlbl 29020 `"Sanctorum De Lazaro Cardenas"', add
label define mx95a_resmunlbl 29021 `"Nanacamilpa De Mariano Arista"', add
label define mx95a_resmunlbl 29022 `"Acuamanala De Miguel Hidalgo"', add
label define mx95a_resmunlbl 29023 `"Nativitas"', add
label define mx95a_resmunlbl 29024 `"Panotla"', add
label define mx95a_resmunlbl 29025 `"San Pablo Del Monte"', add
label define mx95a_resmunlbl 29026 `"Santa Cruz Tlaxcala"', add
label define mx95a_resmunlbl 29028 `"Teolocholco"', add
label define mx95a_resmunlbl 29029 `"Tepeyanco"', add
label define mx95a_resmunlbl 29030 `"Terrenate"', add
label define mx95a_resmunlbl 29031 `"Tetla De La Solidaridad"', add
label define mx95a_resmunlbl 29032 `"Tetlatlahuca"', add
label define mx95a_resmunlbl 29033 `"Tlaxcala"', add
label define mx95a_resmunlbl 29034 `"Tlaxco"', add
label define mx95a_resmunlbl 29035 `"Tocatlan"', add
label define mx95a_resmunlbl 29036 `"Totolac"', add
label define mx95a_resmunlbl 29037 `"Zitlaltepec De Trinidad Sanchez Santos"', add
label define mx95a_resmunlbl 29038 `"Tzompantepec"', add
label define mx95a_resmunlbl 29039 `"Xalostoc"', add
label define mx95a_resmunlbl 29040 `"Xaltocan"', add
label define mx95a_resmunlbl 29041 `"Papalotla De Xicohtencatl"', add
label define mx95a_resmunlbl 29043 `"Yauhquemecan"', add
label define mx95a_resmunlbl 29044 `"Zacatelco"', add
label define mx95a_resmunlbl 29999 `"Undocumented"', add
label define mx95a_resmunlbl 30001 `"Acajete"', add
label define mx95a_resmunlbl 30003 `"Acayucan"', add
label define mx95a_resmunlbl 30004 `"Actopan"', add
label define mx95a_resmunlbl 30009 `"Alto Lucero De Gutierrez Barrios"', add
label define mx95a_resmunlbl 30010 `"Altotonga"', add
label define mx95a_resmunlbl 30011 `"Alvarado"', add
label define mx95a_resmunlbl 30014 `"Amatlan De Los Reyes"', add
label define mx95a_resmunlbl 30015 `"Angel R. Cabada"', add
label define mx95a_resmunlbl 30016 `"Antigua, La"', add
label define mx95a_resmunlbl 30021 `"Atoyac"', add
label define mx95a_resmunlbl 30023 `"Atzalan"', add
label define mx95a_resmunlbl 30024 `"Tlaltetela"', add
label define mx95a_resmunlbl 30027 `"Benito Juarez"', add
label define mx95a_resmunlbl 30028 `"Boca Del Rio"', add
label define mx95a_resmunlbl 30029 `"Calcahualco"', add
label define mx95a_resmunlbl 30030 `"Camerino Z. Mendoza"', add
label define mx95a_resmunlbl 30031 `"Carrillo Puerto"', add
label define mx95a_resmunlbl 30032 `"Catemaco"', add
label define mx95a_resmunlbl 30033 `"Cazones De Herrera"', add
label define mx95a_resmunlbl 30034 `"Cerro Azul"', add
label define mx95a_resmunlbl 30035 `"Citlaltepetl"', add
label define mx95a_resmunlbl 30038 `"Coatepec"', add
label define mx95a_resmunlbl 30039 `"Coatzacoalcos"', add
label define mx95a_resmunlbl 30040 `"Coatzintla"', add
label define mx95a_resmunlbl 30042 `"Colipa"', add
label define mx95a_resmunlbl 30044 `"Cordoba"', add
label define mx95a_resmunlbl 30045 `"Cosamaloapan"', add
label define mx95a_resmunlbl 30047 `"Coscomatepec"', add
label define mx95a_resmunlbl 30048 `"Cosoleacaque"', add
label define mx95a_resmunlbl 30049 `"Cotaxtla"', add
label define mx95a_resmunlbl 30050 `"Coxquihui"', add
label define mx95a_resmunlbl 30051 `"Coyutla"', add
label define mx95a_resmunlbl 30053 `"Cuitlahuac"', add
label define mx95a_resmunlbl 30054 `"Chacaltianguis"', add
label define mx95a_resmunlbl 30055 `"Chalma"', add
label define mx95a_resmunlbl 30056 `"Chiconamel"', add
label define mx95a_resmunlbl 30057 `"Chiconquiaco"', add
label define mx95a_resmunlbl 30058 `"Chicontepec"', add
label define mx95a_resmunlbl 30059 `"Chinameca"', add
label define mx95a_resmunlbl 30060 `"Chinampa De Gorostiza"', add
label define mx95a_resmunlbl 30061 `"Choapas, Las"', add
label define mx95a_resmunlbl 30063 `"Chontla"', add
label define mx95a_resmunlbl 30065 `"Emiliano Zapata"', add
label define mx95a_resmunlbl 30066 `"Espinal"', add
label define mx95a_resmunlbl 30068 `"Fortin"', add
label define mx95a_resmunlbl 30069 `"Gutierrez Zamora"', add
label define mx95a_resmunlbl 30071 `"Huatusco"', add
label define mx95a_resmunlbl 30072 `"Huayacocotla"', add
label define mx95a_resmunlbl 30075 `"Ignacio De La Llave"', add
label define mx95a_resmunlbl 30076 `"Ilamatlan"', add
label define mx95a_resmunlbl 30077 `"Isla"', add
label define mx95a_resmunlbl 30083 `"Ixhuatlan De Madero"', add
label define mx95a_resmunlbl 30085 `"Ixtaczoquitlan"', add
label define mx95a_resmunlbl 30087 `"Xalapa"', add
label define mx95a_resmunlbl 30089 `"Jaltipan"', add
label define mx95a_resmunlbl 30090 `"Jamapa"', add
label define mx95a_resmunlbl 30091 `"Jesus Carranza"', add
label define mx95a_resmunlbl 30092 `"Xico"', add
label define mx95a_resmunlbl 30093 `"Jilotepec"', add
label define mx95a_resmunlbl 30094 `"Juan Rodriguez Clara"', add
label define mx95a_resmunlbl 30095 `"Juchique De Ferrer"', add
label define mx95a_resmunlbl 30097 `"Lerdo De Tejada"', add
label define mx95a_resmunlbl 30099 `"Maltrata"', add
label define mx95a_resmunlbl 30100 `"Manlio Fabio Altamirano"', add
label define mx95a_resmunlbl 30102 `"Martinez De La Torre"', add
label define mx95a_resmunlbl 30103 `"Mecatlan"', add
label define mx95a_resmunlbl 30105 `"Medellin"', add
label define mx95a_resmunlbl 30106 `"Miahuatlan"', add
label define mx95a_resmunlbl 30108 `"Minatitlan"', add
label define mx95a_resmunlbl 30109 `"Misantla"', add
label define mx95a_resmunlbl 30111 `"Moloacan"', add
label define mx95a_resmunlbl 30112 `"Naolinco"', add
label define mx95a_resmunlbl 30115 `"Nogales"', add
label define mx95a_resmunlbl 30116 `"Oluta"', add
label define mx95a_resmunlbl 30117 `"Omealca"', add
label define mx95a_resmunlbl 30118 `"Orizaba"', add
label define mx95a_resmunlbl 30121 `"Ozuluama"', add
label define mx95a_resmunlbl 30123 `"Panuco"', add
label define mx95a_resmunlbl 30124 `"Papantla"', add
label define mx95a_resmunlbl 30125 `"Paso Del Macho"', add
label define mx95a_resmunlbl 30126 `"Paso De Ovejas"', add
label define mx95a_resmunlbl 30128 `"Perote"', add
label define mx95a_resmunlbl 30129 `"Platon Sanchez"', add
label define mx95a_resmunlbl 30130 `"Playa Vicente"', add
label define mx95a_resmunlbl 30131 `"Poza Rica De Hidalgo"', add
label define mx95a_resmunlbl 30132 `"Vigas De Ramirez, Las"', add
label define mx95a_resmunlbl 30133 `"Pueblo Viejo"', add
label define mx95a_resmunlbl 30134 `"Puente Nacional"', add
label define mx95a_resmunlbl 30138 `"Rio Blanco"', add
label define mx95a_resmunlbl 30139 `"Saltabarranca"', add
label define mx95a_resmunlbl 30141 `"San Andres Tuxtla"', add
label define mx95a_resmunlbl 30142 `"San Juan Evangelista"', add
label define mx95a_resmunlbl 30143 `"Santiago Tuxtla"', add
label define mx95a_resmunlbl 30144 `"Sayula De Aleman"', add
label define mx95a_resmunlbl 30148 `"Soledad De Doblado"', add
label define mx95a_resmunlbl 30151 `"Tamiahua"', add
label define mx95a_resmunlbl 30152 `"Tampico Alto"', add
label define mx95a_resmunlbl 30155 `"Tantoyuca"', add
label define mx95a_resmunlbl 30156 `"Tatatila"', add
label define mx95a_resmunlbl 30158 `"Tecolutla"', add
label define mx95a_resmunlbl 30160 `"Temapache"', add
label define mx95a_resmunlbl 30161 `"Tempoal"', add
label define mx95a_resmunlbl 30164 `"Teocelo"', add
label define mx95a_resmunlbl 30167 `"Tepetzintla"', add
label define mx95a_resmunlbl 30169 `"Jose Azueta"', add
label define mx95a_resmunlbl 30171 `"Texhuacan"', add
label define mx95a_resmunlbl 30172 `"Texistepec"', add
label define mx95a_resmunlbl 30173 `"Tezonapa"', add
label define mx95a_resmunlbl 30174 `"Tierra Blanca"', add
label define mx95a_resmunlbl 30175 `"Tihuatlan"', add
label define mx95a_resmunlbl 30180 `"Tlachichilco"', add
label define mx95a_resmunlbl 30181 `"Tlalixcoyan"', add
label define mx95a_resmunlbl 30183 `"Tlapacoyan"', add
label define mx95a_resmunlbl 30186 `"Tomatlan"', add
label define mx95a_resmunlbl 30189 `"Tuxpam"', add
label define mx95a_resmunlbl 30191 `"Ursulo Galvan"', add
label define mx95a_resmunlbl 30192 `"Vega De Alatorre"', add
label define mx95a_resmunlbl 30193 `"Veracruz"', add
label define mx95a_resmunlbl 30195 `"Xoxocotla"', add
label define mx95a_resmunlbl 30196 `"Yanga"', add
label define mx95a_resmunlbl 30199 `"Zaragoza"', add
label define mx95a_resmunlbl 30201 `"Zongolica"', add
label define mx95a_resmunlbl 30202 `"Zontecomatlan"', add
label define mx95a_resmunlbl 30203 `"Zozocolco De Hidalgo"', add
label define mx95a_resmunlbl 30204 `"Agua Dulce"', add
label define mx95a_resmunlbl 30205 `"Higo, El"', add
label define mx95a_resmunlbl 30206 `"Nanchital De Lazaro Cardenas Del Rio"', add
label define mx95a_resmunlbl 30207 `"Tres Valles"', add
label define mx95a_resmunlbl 30999 `"Undocumented"', add
label define mx95a_resmunlbl 31001 `"Abala"', add
label define mx95a_resmunlbl 31002 `"Acanceh"', add
label define mx95a_resmunlbl 31003 `"Akil"', add
label define mx95a_resmunlbl 31004 `"Baca"', add
label define mx95a_resmunlbl 31005 `"Bokoba"', add
label define mx95a_resmunlbl 31006 `"Buctzotz"', add
label define mx95a_resmunlbl 31007 `"Cacalchen"', add
label define mx95a_resmunlbl 31009 `"Cansahcab"', add
label define mx95a_resmunlbl 31010 `"Cantamayec"', add
label define mx95a_resmunlbl 31011 `"Celestun"', add
label define mx95a_resmunlbl 31012 `"Cenotillo"', add
label define mx95a_resmunlbl 31017 `"Chankom"', add
label define mx95a_resmunlbl 31018 `"Chapab"', add
label define mx95a_resmunlbl 31019 `"Chemax"', add
label define mx95a_resmunlbl 31020 `"Chicxulub Pueblo"', add
label define mx95a_resmunlbl 31021 `"Chichimila"', add
label define mx95a_resmunlbl 31022 `"Chikindzonot"', add
label define mx95a_resmunlbl 31023 `"Chochola"', add
label define mx95a_resmunlbl 31024 `"Chumayel"', add
label define mx95a_resmunlbl 31027 `"Dzidzantun"', add
label define mx95a_resmunlbl 31028 `"Dzilam De Bravo"', add
label define mx95a_resmunlbl 31029 `"Dzilam Gonzalez"', add
label define mx95a_resmunlbl 31030 `"Dzitas"', add
label define mx95a_resmunlbl 31032 `"Espita"', add
label define mx95a_resmunlbl 31033 `"Halacho"', add
label define mx95a_resmunlbl 31034 `"Hocaba"', add
label define mx95a_resmunlbl 31035 `"Hoctun"', add
label define mx95a_resmunlbl 31036 `"Homun"', add
label define mx95a_resmunlbl 31037 `"Huhi"', add
label define mx95a_resmunlbl 31038 `"Hunucma"', add
label define mx95a_resmunlbl 31040 `"Izamal"', add
label define mx95a_resmunlbl 31041 `"Kanasin"', add
label define mx95a_resmunlbl 31042 `"Kantunil"', add
label define mx95a_resmunlbl 31044 `"Kinchil"', add
label define mx95a_resmunlbl 31047 `"Mani"', add
label define mx95a_resmunlbl 31048 `"Maxcanu"', add
label define mx95a_resmunlbl 31050 `"Merida"', add
label define mx95a_resmunlbl 31052 `"Motul"', add
label define mx95a_resmunlbl 31055 `"Opichen"', add
label define mx95a_resmunlbl 31056 `"Oxkutzcab"', add
label define mx95a_resmunlbl 31057 `"Panaba"', add
label define mx95a_resmunlbl 31058 `"Peto"', add
label define mx95a_resmunlbl 31059 `"Progreso"', add
label define mx95a_resmunlbl 31060 `"Quintana Roo"', add
label define mx95a_resmunlbl 31061 `"Rio Lagartos"', add
label define mx95a_resmunlbl 31063 `"Samahil"', add
label define mx95a_resmunlbl 31065 `"San Felipe"', add
label define mx95a_resmunlbl 31067 `"Seye"', add
label define mx95a_resmunlbl 31068 `"Sinanche"', add
label define mx95a_resmunlbl 31069 `"Sotuta"', add
label define mx95a_resmunlbl 31070 `"Sucila"', add
label define mx95a_resmunlbl 31071 `"Sudzal"', add
label define mx95a_resmunlbl 31072 `"Suma"', add
label define mx95a_resmunlbl 31073 `"Tahdziu"', add
label define mx95a_resmunlbl 31075 `"Teabo"', add
label define mx95a_resmunlbl 31076 `"Tecoh"', add
label define mx95a_resmunlbl 31078 `"Tekanto"', add
label define mx95a_resmunlbl 31079 `"Tekax"', add
label define mx95a_resmunlbl 31080 `"Tekit"', add
label define mx95a_resmunlbl 31083 `"Telchac Puerto"', add
label define mx95a_resmunlbl 31084 `"Temax"', add
label define mx95a_resmunlbl 31085 `"Temozon"', add
label define mx95a_resmunlbl 31088 `"Teya"', add
label define mx95a_resmunlbl 31089 `"Ticul"', add
label define mx95a_resmunlbl 31090 `"Timucuy"', add
label define mx95a_resmunlbl 31091 `"Tinum"', add
label define mx95a_resmunlbl 31093 `"Tixkokob"', add
label define mx95a_resmunlbl 31094 `"Tixmehuac"', add
label define mx95a_resmunlbl 31095 `"Tixpehual"', add
label define mx95a_resmunlbl 31096 `"Tizimin"', add
label define mx95a_resmunlbl 31097 `"Tunkas"', add
label define mx95a_resmunlbl 31098 `"Tzucacab"', add
label define mx95a_resmunlbl 31099 `"Uayma"', add
label define mx95a_resmunlbl 31101 `"Uman"', add
label define mx95a_resmunlbl 31102 `"Valladolid"', add
label define mx95a_resmunlbl 31103 `"Xocchel"', add
label define mx95a_resmunlbl 31104 `"Yaxcaba"', add
label define mx95a_resmunlbl 31999 `"Undocumented"', add
label define mx95a_resmunlbl 32001 `"Apozol"', add
label define mx95a_resmunlbl 32005 `"Calera"', add
label define mx95a_resmunlbl 32006 `"Cañitas De Felipe Pescador"', add
label define mx95a_resmunlbl 32007 `"Concepcion Del Oro"', add
label define mx95a_resmunlbl 32008 `"Cuauhtemoc"', add
label define mx95a_resmunlbl 32009 `"Chalchihuites"', add
label define mx95a_resmunlbl 32010 `"Fresnillo"', add
label define mx95a_resmunlbl 32011 `"Trinidad Garcia De La Cadena"', add
label define mx95a_resmunlbl 32012 `"Genaro Codina"', add
label define mx95a_resmunlbl 32013 `"General Enrique Estrada"', add
label define mx95a_resmunlbl 32014 `"General Francisco R. Murguia"', add
label define mx95a_resmunlbl 32016 `"General Panfilo Natera"', add
label define mx95a_resmunlbl 32017 `"Guadalupe"', add
label define mx95a_resmunlbl 32018 `"Huanusco"', add
label define mx95a_resmunlbl 32019 `"Jalpa"', add
label define mx95a_resmunlbl 32020 `"Jerez"', add
label define mx95a_resmunlbl 32021 `"Jimenez Del Teul"', add
label define mx95a_resmunlbl 32022 `"Juan Aldama"', add
label define mx95a_resmunlbl 32023 `"Juchipila"', add
label define mx95a_resmunlbl 32024 `"Loreto"', add
label define mx95a_resmunlbl 32025 `"Luis Moya"', add
label define mx95a_resmunlbl 32026 `"Mazapil"', add
label define mx95a_resmunlbl 32027 `"Melchor Ocampo"', add
label define mx95a_resmunlbl 32028 `"Mezquital Del Oro"', add
label define mx95a_resmunlbl 32029 `"Miguel Auza"', add
label define mx95a_resmunlbl 32031 `"Monte Escobedo"', add
label define mx95a_resmunlbl 32032 `"Morelos"', add
label define mx95a_resmunlbl 32033 `"Moyahua De Estrada"', add
label define mx95a_resmunlbl 32034 `"Nochistlan De Mejia"', add
label define mx95a_resmunlbl 32035 `"Noria De Angeles"', add
label define mx95a_resmunlbl 32036 `"Ojocaliente"', add
label define mx95a_resmunlbl 32037 `"Panuco"', add
label define mx95a_resmunlbl 32038 `"Pinos"', add
label define mx95a_resmunlbl 32039 `"Rio Grande"', add
label define mx95a_resmunlbl 32040 `"Sain Alto"', add
label define mx95a_resmunlbl 32041 `"Salvador, El"', add
label define mx95a_resmunlbl 32042 `"Sombrerete"', add
label define mx95a_resmunlbl 32044 `"Tabasco"', add
label define mx95a_resmunlbl 32045 `"Tepechitlan"', add
label define mx95a_resmunlbl 32046 `"Tepetongo"', add
label define mx95a_resmunlbl 32047 `"Teul De Gonzalez Ortega"', add
label define mx95a_resmunlbl 32048 `"Tlaltenango De Sanchez Roman"', add
label define mx95a_resmunlbl 32049 `"Valparaiso"', add
label define mx95a_resmunlbl 32050 `"Vetagrande"', add
label define mx95a_resmunlbl 32051 `"Villa De Cos"', add
label define mx95a_resmunlbl 32052 `"Villa Garcia"', add
label define mx95a_resmunlbl 32053 `"Villa Gonzalez Ortega"', add
label define mx95a_resmunlbl 32054 `"Villa Hidalgo"', add
label define mx95a_resmunlbl 32055 `"Villanueva"', add
label define mx95a_resmunlbl 32056 `"Zacatecas"', add
label define mx95a_resmunlbl 32999 `"Undocumented"', add
label define mx95a_resmunlbl 99998 `"Unknown"', add
label define mx95a_resmunlbl 99999 `"NIU (not in universe)"', add
label values mx95a_resmun mx95a_resmunlbl

label define mx95a_inctotplbl 000000 `"0"'
label define mx95a_inctotplbl 999998 `"Unknown"', add
label define mx95a_inctotplbl 999999 `"NIU (not in universe)"', add
label values mx95a_inctotp mx95a_inctotplbl


save mexico_censo_11.dta, replace


