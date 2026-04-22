/* Important: you need to put the .dat and .do files in one folder/
   directory and then set the working folder to that folder. */

clear
set mem 5000m

cd /scratch/datkin

set more off




clear

#delimit ;

infix 
 int     year          1-4 
 int     sample        5-8 
 double  serial        9-18 
 byte    urban        19 
 long    munimx       20-24 
 byte    sizemx       25 
 byte    mx00a_migstat  26 
 byte    mx00a_mign    27-28 
 int     pernum       29-31 
 float   wtper        32-39 
 int     related      40-43 
 int     age          44-46 
 byte    sex          47 
 int     marstd       48-50 
 byte    chborn       51-52 
 byte    chsurv       53-54 
 byte    lstbmth      55-56 
 int     lstbyr       57-60 
 byte    lststat      61 
 byte    agededy      62-63 
 byte    agededm      64-65 
 byte    agededd      66-67 
 byte    bplmx        68-69 
 byte    spkind       70 
 byte    school       71 
 byte    lit          72 
 int     edattand     73-75 
 byte    yrschl       76-77 
 int     educmx       78-80 
 byte    leftsch      81-82 
 int     empstatd     83-85 
 int     occ          86-89 
 long    ind          90-94 
 long    inctot       95-101 
 double  incearn     102-109 
 byte    mgrate5     110-111 
 byte    migmx2      112-113 
 byte    mgcause     114-115 
 byte    mx00a_imss  116 
 int     mx00a_resmun 117-119 
 int     mx00a_wkmun 120-122 
 int     mx00a_wkst  123-125 
 using datkin_princeton_edu_005.dat;
 
#delimit cr

replace wtper=wtper/10000

label var year "Year"
label var sample "IPUMS sample identifier"
label var serial "Serial number"
label var urban "Urban-rural status"
label var munimx "Municipality, Mexico"
label var sizemx "Size of locality, Mexico"
label var mx00a_migstat "International migration status"
label var mx00a_mign "Number of  international migrants"
label var pernum "Person number"
label var wtper "Person weight"
label var related "Relationship to household head [detailed version]"
label var age "Age"
label var sex "Sex"
label var marstd "Marital status [detailed version]"
label var chborn "Children ever born"
label var chsurv "Children surviving"
label var lstbmth "Month of last birth"
label var lstbyr "Year of last birth"
label var lststat "Mortality status of last birth"
label var agededy "Last child's age at death, years"
label var agededm "Last child's age at death, months"
label var agededd "Last child's age at death, days"
label var bplmx "State of birth, Mexico"
label var spkind "Speaks indigenous language"
label var school "School attendance"
label var lit "Literacy"
label var edattand "Educational attainment, international recode [detailed version]"
label var yrschl "Years of schooling"
label var educmx "Educational attainment, Mexico"
label var leftsch "Reason for leaving school"
label var empstatd "Employment status [detailed version]"
label var occ "Occupation, unrecoded"
label var ind "Industry, unrecoded"
label var inctot "Total income"
label var incearn "Earned income"
label var mgrate5 "Migration status, 5 years"
label var migmx2 "State of residence 5 years ago, Mexico"
label var mgcause "Reason for migration"
label var mx00a_imss "Insured by social security (IMSS)"
label var mx00a_resmun "Municipality of residence in 1995"
label var mx00a_wkmun "Municipality of work"
label var mx00a_wkst "State or country of work"

label define yearlbl 1960 "1960"
label define yearlbl 1962 "1962", add
label define yearlbl 1963 "1963", add
label define yearlbl 1964 "1964", add
label define yearlbl 1968 "1968", add
label define yearlbl 1970 "1970", add
label define yearlbl 1971 "1971", add
label define yearlbl 1972 "1972", add
label define yearlbl 1973 "1973", add
label define yearlbl 1974 "1974", add
label define yearlbl 1975 "1975", add
label define yearlbl 1980 "1980", add
label define yearlbl 1981 "1981", add
label define yearlbl 1982 "1982", add
label define yearlbl 1983 "1983", add
label define yearlbl 1984 "1984", add
label define yearlbl 1985 "1985", add
label define yearlbl 1989 "1989", add
label define yearlbl 1990 "1990", add
label define yearlbl 1991 "1991", add
label define yearlbl 1992 "1992", add
label define yearlbl 1993 "1993", add
label define yearlbl 1995 "1995", add
label define yearlbl 1996 "1996", add
label define yearlbl 1997 "1997", add
label define yearlbl 1998 "1998", add
label define yearlbl 1999 "1999", add
label define yearlbl 2000 "2000", add
label define yearlbl 2001 "2001", add
label define yearlbl 2002 "2002", add
label values year yearlbl

label define samplelbl 0321 "Argentina 1970"
label define samplelbl 0322 "Argentina 1980", add
label define samplelbl 0323 "Argentina 1991", add
label define samplelbl 0324 "Argentina 2001", add
label define samplelbl 0761 "Brazil 1960", add
label define samplelbl 0762 "Brazil 1970", add
label define samplelbl 0763 "Brazil 1980", add
label define samplelbl 0764 "Brazil 1991", add
label define samplelbl 0765 "Brazil 2000", add
label define samplelbl 1121 "Belarus 1999", add
label define samplelbl 1161 "Cambodia 1998", add
label define samplelbl 1521 "Chile 1960", add
label define samplelbl 1522 "Chile 1970", add
label define samplelbl 1523 "Chile 1982", add
label define samplelbl 1524 "Chile 1992", add
label define samplelbl 1525 "Chile 2002", add
label define samplelbl 1561 "China 1982", add
label define samplelbl 1701 "Colombia 1964", add
label define samplelbl 1702 "Colombia 1973", add
label define samplelbl 1703 "Colombia 1985", add
label define samplelbl 1704 "Colombia 1993", add
label define samplelbl 1881 "Costa Rica 1963", add
label define samplelbl 1882 "Costa Rica 1973", add
label define samplelbl 1883 "Costa Rica 1984", add
label define samplelbl 1884 "Costa Rica 2000", add
label define samplelbl 2181 "Ecuador 1962", add
label define samplelbl 2182 "Ecuador 1974", add
label define samplelbl 2183 "Ecuador 1982", add
label define samplelbl 2184 "Ecuador 1990", add
label define samplelbl 2185 "Ecuador 2001", add
label define samplelbl 2501 "France 1962", add
label define samplelbl 2502 "France 1968", add
label define samplelbl 2503 "France 1975", add
label define samplelbl 2504 "France 1982", add
label define samplelbl 2505 "France 1990", add
label define samplelbl 3001 "Greece 1971", add
label define samplelbl 3002 "Greece 1981", add
label define samplelbl 3003 "Greece 1991", add
label define samplelbl 3004 "Greece 2001", add
label define samplelbl 3481 "Hungary 1970", add
label define samplelbl 3482 "Hungary 1980", add
label define samplelbl 3483 "Hungary 1990", add
label define samplelbl 3484 "Hungary 2001", add
label define samplelbl 3761 "Israel 1972", add
label define samplelbl 3762 "Israel 1983", add
label define samplelbl 3763 "Israel 1995", add
label define samplelbl 4041 "Kenya 1989", add
label define samplelbl 4042 "Kenya 1999", add
label define samplelbl 4841 "Mexico 1960", add
label define samplelbl 4842 "Mexico 1970", add
label define samplelbl 4843 "Mexico 1990", add
label define samplelbl 4844 "Mexico 2000", add
label define samplelbl 6021 "Palestinian Terr 1997", add
label define samplelbl 6081 "Philippines 1990", add
label define samplelbl 6082 "Philippines 1995", add
label define samplelbl 6083 "Philippines 2000", add
label define samplelbl 6201 "Portugal 1981", add
label define samplelbl 6202 "Portugal 1991", add
label define samplelbl 6203 "Portugal 2001", add
label define samplelbl 6421 "Romania 1992", add
label define samplelbl 6422 "Romania 2002", add
label define samplelbl 6461 "Rwanda 1991", add
label define samplelbl 6462 "Rwanda 2002", add
label define samplelbl 7041 "Vietnam 1989", add
label define samplelbl 7042 "Vietnam 1999", add
label define samplelbl 7101 "South Africa 1996", add
label define samplelbl 7102 "South Africa 2001", add
label define samplelbl 7241 "Spain 1981", add
label define samplelbl 7242 "Spain 1991", add
label define samplelbl 7243 "Spain 2001", add
label define samplelbl 8001 "Uganda 1991", add
label define samplelbl 8002 "Uganda 2002", add
label define samplelbl 8401 "United States 1960", add
label define samplelbl 8402 "United States 1970", add
label define samplelbl 8403 "United States 1980", add
label define samplelbl 8404 "United States 1990", add
label define samplelbl 8405 "United States 2000", add
label define samplelbl 8621 "Venezuela 1971", add
label define samplelbl 8622 "Venezuela 1981", add
label define samplelbl 8623 "Venezuela 1990", add
label values sample samplelbl

label values serial seriallbl

label define urbanlbl 0 "NIU"
label define urbanlbl 1 "Rural", add
label define urbanlbl 2 "Urban", add
label define urbanlbl 9 "Unknown", add
label values urban urbanlbl

label define munimxlbl 01001 "Aguascalientes", add
label define munimxlbl 01002 "Asientos", add
label define munimxlbl 01003 "Calvillo", add
label define munimxlbl 01004 "Cosio", add
label define munimxlbl 01005 "Jesus Maria", add
label define munimxlbl 01006 "Pabellon de Arteaga", add
label define munimxlbl 01007 "Rincon de Romos", add
label define munimxlbl 01008 "San Jose de Gracia", add
label define munimxlbl 01009 "Tepezala", add
label define munimxlbl 01010 "Llano, El", add
label define munimxlbl 01011 "San Francisco de los Romo", add
label define munimxlbl 02001 "Ensenada", add
label define munimxlbl 02002 "Mexicali", add
label define munimxlbl 02003 "Tecate", add
label define munimxlbl 02004 "Tijuana", add
label define munimxlbl 02005 "Playas de Rosarito", add
label define munimxlbl 03001 "Comondu", add
label define munimxlbl 03002 "Mulege", add
label define munimxlbl 03003 "Paz, La", add
label define munimxlbl 03008 "Cabos, Los", add
label define munimxlbl 03009 "Loreto", add
label define munimxlbl 04001 "Calkini", add
label define munimxlbl 04002 "Campeche", add
label define munimxlbl 04003 "Carmen", add
label define munimxlbl 04004 "Champoton", add
label define munimxlbl 04005 "Hecelchakan", add
label define munimxlbl 04006 "Hopelchen", add
label define munimxlbl 04007 "Palizada", add
label define munimxlbl 04008 "Tenabo", add
label define munimxlbl 04009 "Escarcega", add
label define munimxlbl 04010 "Calakmul", add
label define munimxlbl 04011 "Candelaria", add
label define munimxlbl 05001 "Abasolo", add
label define munimxlbl 05002 "Acuna", add
label define munimxlbl 05003 "Allende", add
label define munimxlbl 05004 "Arteaga", add
label define munimxlbl 05005 "Candela", add
label define munimxlbl 05006 "Castanos", add
label define munimxlbl 05007 "Cuatrocienegas", add
label define munimxlbl 05008 "Escobedo", add
label define munimxlbl 05009 "Francisco I. Madero", add
label define munimxlbl 05010 "Frontera", add
label define munimxlbl 05011 "General Cepeda", add
label define munimxlbl 05012 "Guerrero", add
label define munimxlbl 05013 "Hidalgo", add
label define munimxlbl 05014 "Jimenez", add
label define munimxlbl 05015 "Juarez", add
label define munimxlbl 05016 "Lamadrid", add
label define munimxlbl 05017 "Matamoros", add
label define munimxlbl 05018 "Monclova", add
label define munimxlbl 05019 "Morelos", add
label define munimxlbl 05020 "Muzquiz", add
label define munimxlbl 05021 "Nadadores", add
label define munimxlbl 05022 "Nava", add
label define munimxlbl 05023 "Ocampo", add
label define munimxlbl 05024 "Parras", add
label define munimxlbl 05025 "Piedras Negras", add
label define munimxlbl 05026 "Progreso", add
label define munimxlbl 05027 "Ramos Arizpe", add
label define munimxlbl 05028 "Sabinas", add
label define munimxlbl 05029 "Sacramento", add
label define munimxlbl 05030 "Saltillo", add
label define munimxlbl 05031 "San Buenaventura", add
label define munimxlbl 05032 "San Juan de Sabinas", add
label define munimxlbl 05033 "San Pedro", add
label define munimxlbl 05034 "Sierra Mojada", add
label define munimxlbl 05035 "Torreon", add
label define munimxlbl 05036 "Viesca", add
label define munimxlbl 05037 "Villa Union", add
label define munimxlbl 05038 "Zaragoza", add
label define munimxlbl 06001 "Armeria", add
label define munimxlbl 06002 "Colima", add
label define munimxlbl 06003 "Comala", add
label define munimxlbl 06004 "Coquimatlan", add
label define munimxlbl 06005 "Cuauhtemoc", add
label define munimxlbl 06006 "Ixtlahuacan", add
label define munimxlbl 06007 "Manzanillo", add
label define munimxlbl 06008 "Minatitlan", add
label define munimxlbl 06009 "Tecoman", add
label define munimxlbl 06010 "Villa de Alvarez", add
label define munimxlbl 07001 "Acacoyagua", add
label define munimxlbl 07002 "Acala", add
label define munimxlbl 07003 "Acapetahua", add
label define munimxlbl 07004 "Altamirano", add
label define munimxlbl 07005 "Amatan", add
label define munimxlbl 07006 "Amatenango de la Frontera", add
label define munimxlbl 07007 "Amatenango del Valle", add
label define munimxlbl 07008 "Angel Albino Corzo", add
label define munimxlbl 07009 "Arriaga", add
label define munimxlbl 07010 "Bejucal de Ocampo", add
label define munimxlbl 07011 "Bella Vista", add
label define munimxlbl 07012 "Berriozabal", add
label define munimxlbl 07013 "Bochil", add
label define munimxlbl 07014 "Bosque, El", add
label define munimxlbl 07015 "Cacahoatan", add
label define munimxlbl 07016 "Catazaja", add
label define munimxlbl 07017 "Cintalapa", add
label define munimxlbl 07018 "Coapilla", add
label define munimxlbl 07019 "Comitan de Dominguez", add
label define munimxlbl 07020 "Concordia, La", add
label define munimxlbl 07021 "Copainala", add
label define munimxlbl 07022 "Chalchihuitan", add
label define munimxlbl 07023 "Chamula", add
label define munimxlbl 07024 "Chanal", add
label define munimxlbl 07025 "Chapultenango", add
label define munimxlbl 07026 "Chenalho", add
label define munimxlbl 07027 "Chiapa de Corzo", add
label define munimxlbl 07028 "Chiapilla", add
label define munimxlbl 07029 "Chicoasen", add
label define munimxlbl 07030 "Chicomuselo", add
label define munimxlbl 07031 "Chilon", add
label define munimxlbl 07032 "Escuintla", add
label define munimxlbl 07033 "Francisco Leon", add
label define munimxlbl 07034 "Frontera Comalapa", add
label define munimxlbl 07035 "Frontera Hidalgo", add
label define munimxlbl 07036 "Grandeza, La", add
label define munimxlbl 07037 "Huehuetan", add
label define munimxlbl 07038 "Huixtan", add
label define munimxlbl 07039 "Huitiupan", add
label define munimxlbl 07040 "Huixtla", add
label define munimxlbl 07041 "Independencia, La", add
label define munimxlbl 07042 "Ixhuatan", add
label define munimxlbl 07043 "Ixtacomitan", add
label define munimxlbl 07044 "Ixtapa", add
label define munimxlbl 07045 "Ixtapangajoya", add
label define munimxlbl 07046 "Jiquipilas", add
label define munimxlbl 07047 "Jitotol", add
label define munimxlbl 07048 "Juarez", add
label define munimxlbl 07049 "Larrainzar", add
label define munimxlbl 07050 "Libertad, La", add
label define munimxlbl 07051 "Mapastepec", add
label define munimxlbl 07052 "Margaritas, Las", add
label define munimxlbl 07053 "Mazapa de Madero", add
label define munimxlbl 07054 "Mazatan", add
label define munimxlbl 07055 "Metapa", add
label define munimxlbl 07056 "Mitontic", add
label define munimxlbl 07057 "Motozintla", add
label define munimxlbl 07058 "Nicolas Ruiz", add
label define munimxlbl 07059 "Ocosingo", add
label define munimxlbl 07060 "Ocotepec", add
label define munimxlbl 07061 "Ocozocoautla de Espinosa", add
label define munimxlbl 07062 "Ostuacan", add
label define munimxlbl 07063 "Osumacinta", add
label define munimxlbl 07064 "Oxchuc", add
label define munimxlbl 07065 "Palenque", add
label define munimxlbl 07066 "Pantelho", add
label define munimxlbl 07067 "Pantepec", add
label define munimxlbl 07068 "Pichucalco", add
label define munimxlbl 07069 "Pijijiapan", add
label define munimxlbl 07070 "Porvenir, El", add
label define munimxlbl 07071 "Villa Comaltitlan", add
label define munimxlbl 07072 "Pueblo Nuevo Solistahuacan", add
label define munimxlbl 07073 "Rayon", add
label define munimxlbl 07074 "Reforma", add
label define munimxlbl 07075 "Rosas, Las", add
label define munimxlbl 07076 "Sabanilla", add
label define munimxlbl 07077 "Salto de Agua", add
label define munimxlbl 07078 "San Cristobal de las Casas", add
label define munimxlbl 07079 "San Fernando", add
label define munimxlbl 07080 "Siltepec", add
label define munimxlbl 07081 "Simojovel", add
label define munimxlbl 07082 "Sitala", add
label define munimxlbl 07083 "Socoltenango", add
label define munimxlbl 07084 "Solosuchiapa", add
label define munimxlbl 07085 "Soyalo", add
label define munimxlbl 07086 "Suchiapa", add
label define munimxlbl 07087 "Suchiate", add
label define munimxlbl 07088 "Sunuapa", add
label define munimxlbl 07089 "Tapachula", add
label define munimxlbl 07090 "Tapalapa", add
label define munimxlbl 07091 "Tapilula", add
label define munimxlbl 07092 "Tecpatan", add
label define munimxlbl 07093 "Tenejapa", add
label define munimxlbl 07094 "Teopisca", add
label define munimxlbl 07096 "Tila", add
label define munimxlbl 07097 "Tonala", add
label define munimxlbl 07098 "Totolapa", add
label define munimxlbl 07099 "Trinitaria, La", add
label define munimxlbl 07100 "Tumbala", add
label define munimxlbl 07101 "Tuxtla Gutierrez", add
label define munimxlbl 07102 "Tuxtla Chico", add
label define munimxlbl 07103 "Tuzantan", add
label define munimxlbl 07104 "Tzimol", add
label define munimxlbl 07105 "Union Juarez", add
label define munimxlbl 07106 "Venustiano Carranza", add
label define munimxlbl 07107 "Villa Corzo", add
label define munimxlbl 07108 "Villaflores", add
label define munimxlbl 07109 "Yajalon", add
label define munimxlbl 07110 "San Lucas", add
label define munimxlbl 07111 "Zinacantan", add
label define munimxlbl 07112 "San Juan Cancuc", add
label define munimxlbl 07113 "Aldama", add
label define munimxlbl 07114 "Benemerito de las Americas", add
label define munimxlbl 07115 "Maravilla Tenejapa", add
label define munimxlbl 07116 "Marques de Comillas", add
label define munimxlbl 07117 "Monte Cristo de Guerrero", add
label define munimxlbl 07118 "San Andres Duraznal", add
label define munimxlbl 07119 "Santiago el Pinar", add
label define munimxlbl 08001 "Ahumada", add
label define munimxlbl 08002 "Aldama", add
label define munimxlbl 08003 "Allende", add
label define munimxlbl 08004 "Aquiles Serdan", add
label define munimxlbl 08005 "Ascension", add
label define munimxlbl 08006 "Bachiniva", add
label define munimxlbl 08007 "Balleza", add
label define munimxlbl 08008 "Batopilas", add
label define munimxlbl 08009 "Bocoyna", add
label define munimxlbl 08010 "Buenaventura", add
label define munimxlbl 08011 "Camargo", add
label define munimxlbl 08012 "Carichi", add
label define munimxlbl 08013 "Casas Grandes", add
label define munimxlbl 08014 "Coronado", add
label define munimxlbl 08015 "Coyame del Sotol", add
label define munimxlbl 08016 "Cruz, La", add
label define munimxlbl 08017 "Cuauhtemoc", add
label define munimxlbl 08018 "Cusihuiriachi", add
label define munimxlbl 08019 "Chihuahua", add
label define munimxlbl 08020 "Chinipas", add
label define munimxlbl 08021 "Delicias", add
label define munimxlbl 08022 "Dr. Belisario Dominguez", add
label define munimxlbl 08023 "Galeana", add
label define munimxlbl 08024 "Santa Isabel", add
label define munimxlbl 08025 "Gomez Farias", add
label define munimxlbl 08026 "Gran Morelos", add
label define munimxlbl 08027 "Guachochi", add
label define munimxlbl 08028 "Guadalupe", add
label define munimxlbl 08029 "Guadalupe y Calvo", add
label define munimxlbl 08030 "Guazapares", add
label define munimxlbl 08031 "Guerrero", add
label define munimxlbl 08032 "Hidalgo del Parral", add
label define munimxlbl 08033 "Huejotitan", add
label define munimxlbl 08034 "Ignacio Zaragoza", add
label define munimxlbl 08035 "Janos", add
label define munimxlbl 08036 "Jimenez", add
label define munimxlbl 08037 "Juarez", add
label define munimxlbl 08038 "Julimes", add
label define munimxlbl 08039 "Lopez", add
label define munimxlbl 08040 "Madera", add
label define munimxlbl 08041 "Maguarichi", add
label define munimxlbl 08042 "Manuel Benavides", add
label define munimxlbl 08043 "Matachi", add
label define munimxlbl 08044 "Matamoros", add
label define munimxlbl 08045 "Meoqui", add
label define munimxlbl 08046 "Morelos", add
label define munimxlbl 08047 "Moris", add
label define munimxlbl 08048 "Namiquipa", add
label define munimxlbl 08049 "Nonoava", add
label define munimxlbl 08050 "Nuevo Casas Grandes", add
label define munimxlbl 08051 "Ocampo", add
label define munimxlbl 08052 "Ojinaga", add
label define munimxlbl 08053 "Praxedis G. Guerrero", add
label define munimxlbl 08054 "Riva Palacio", add
label define munimxlbl 08055 "Rosales", add
label define munimxlbl 08056 "Rosario", add
label define munimxlbl 08057 "San Francisco de Borja", add
label define munimxlbl 08058 "San Francisco de Conchos", add
label define munimxlbl 08059 "San Francisco del Oro", add
label define munimxlbl 08060 "Santa Barbara", add
label define munimxlbl 08061 "Satevo", add
label define munimxlbl 08062 "Saucillo", add
label define munimxlbl 08063 "Temosachi", add
label define munimxlbl 08064 "Tule, El", add
label define munimxlbl 08065 "Urique", add
label define munimxlbl 08066 "Uruachi", add
label define munimxlbl 08067 "Valle de Zaragoza", add
label define munimxlbl 09002 "Azcapotzalco", add
label define munimxlbl 09003 "Coyoacan", add
label define munimxlbl 09004 "Cuajimalpa de Morelos", add
label define munimxlbl 09005 "Gustavo A. Madero", add
label define munimxlbl 09006 "Iztacalco", add
label define munimxlbl 09007 "Iztapalapa", add
label define munimxlbl 09008 "Magdalena Contreras, La", add
label define munimxlbl 09009 "Milpa Alta", add
label define munimxlbl 09010 "Alvaro Obregon", add
label define munimxlbl 09011 "Tlahuac", add
label define munimxlbl 09012 "Tlalpan", add
label define munimxlbl 09013 "Xochimilco", add
label define munimxlbl 09014 "Benito Juarez", add
label define munimxlbl 09015 "Cuauhtemoc", add
label define munimxlbl 09016 "Miguel Hidalgo", add
label define munimxlbl 09017 "Venustiano Carranza", add
label define munimxlbl 10001 "Canatlan", add
label define munimxlbl 10002 "Canelas", add
label define munimxlbl 10003 "Coneto de Comonfort", add
label define munimxlbl 10004 "Cuencame", add
label define munimxlbl 10005 "Durango", add
label define munimxlbl 10006 "General Simon Bolivar", add
label define munimxlbl 10007 "Gomez Palacio", add
label define munimxlbl 10008 "Guadalupe Victoria", add
label define munimxlbl 10009 "Guanacevi", add
label define munimxlbl 10010 "Hidalgo", add
label define munimxlbl 10011 "Inde", add
label define munimxlbl 10012 "Lerdo", add
label define munimxlbl 10013 "Mapimi", add
label define munimxlbl 10014 "Mezquital", add
label define munimxlbl 10015 "Nazas", add
label define munimxlbl 10016 "Nombre de Dios", add
label define munimxlbl 10017 "Ocampo", add
label define munimxlbl 10018 "Oro, El", add
label define munimxlbl 10019 "Otaez", add
label define munimxlbl 10020 "Panuco de Coronado", add
label define munimxlbl 10021 "Penon Blanco", add
label define munimxlbl 10022 "Poanas", add
label define munimxlbl 10023 "Pueblo Nuevo", add
label define munimxlbl 10024 "Rodeo", add
label define munimxlbl 10025 "San Bernardo", add
label define munimxlbl 10026 "San dimas", add
label define munimxlbl 10027 "San Juan de Guadalupe", add
label define munimxlbl 10028 "San Juan del Rio", add
label define munimxlbl 10029 "San Luis del Cordero", add
label define munimxlbl 10030 "San Pedro del Gallo", add
label define munimxlbl 10031 "Santa Clara", add
label define munimxlbl 10032 "Santiago Papasquiaro", add
label define munimxlbl 10033 "Suchil", add
label define munimxlbl 10034 "Tamazula", add
label define munimxlbl 10035 "Tepehuanes", add
label define munimxlbl 10036 "Tlahualilo", add
label define munimxlbl 10037 "Topia", add
label define munimxlbl 10038 "Vicente Guerrero", add
label define munimxlbl 10039 "Nuevo Ideal", add
label define munimxlbl 11001 "Abasolo", add
label define munimxlbl 11002 "Acambaro", add
label define munimxlbl 11003 "Allende", add
label define munimxlbl 11004 "Apaseo el Alto", add
label define munimxlbl 11005 "Apaseo el Grande", add
label define munimxlbl 11006 "Atarjea", add
label define munimxlbl 11007 "Celaya", add
label define munimxlbl 11008 "Manuel Doblado", add
label define munimxlbl 11009 "Comonfort", add
label define munimxlbl 11010 "Coroneo", add
label define munimxlbl 11011 "Cortazar", add
label define munimxlbl 11012 "Cueramaro", add
label define munimxlbl 11013 "Doctor Mora", add
label define munimxlbl 11014 "Dolores Hidalgo", add
label define munimxlbl 11015 "Guanajuato", add
label define munimxlbl 11016 "Huanimaro", add
label define munimxlbl 11017 "Irapuato", add
label define munimxlbl 11018 "Jaral del Progreso", add
label define munimxlbl 11019 "Jerecuaro", add
label define munimxlbl 11020 "Leon", add
label define munimxlbl 11021 "Moroleon", add
label define munimxlbl 11022 "Ocampo", add
label define munimxlbl 11023 "Penjamo", add
label define munimxlbl 11024 "Pueblo Nuevo", add
label define munimxlbl 11025 "Purisima del Rincon", add
label define munimxlbl 11026 "Romita", add
label define munimxlbl 11027 "Salamanca", add
label define munimxlbl 11028 "Salvatierra", add
label define munimxlbl 11029 "San Diego de la Union", add
label define munimxlbl 11030 "San Felipe", add
label define munimxlbl 11031 "San Francisco del Rincon", add
label define munimxlbl 11032 "San Jose Iturbide", add
label define munimxlbl 11033 "San Luis de la Paz", add
label define munimxlbl 11034 "Santa Catarina", add
label define munimxlbl 11035 "Santa Cruz de Juventino Rosas", add
label define munimxlbl 11036 "Santiago Maravatio", add
label define munimxlbl 11037 "Silao", add
label define munimxlbl 11038 "Tarandacuao", add
label define munimxlbl 11039 "Tarimoro", add
label define munimxlbl 11040 "Tierra Blanca", add
label define munimxlbl 11041 "Uriangato", add
label define munimxlbl 11042 "Valle de Santiago", add
label define munimxlbl 11043 "Victoria", add
label define munimxlbl 11044 "Villagran", add
label define munimxlbl 11045 "Xichu", add
label define munimxlbl 11046 "Yuriria", add
label define munimxlbl 12001 "Acapulco de Juarez", add
label define munimxlbl 12002 "Ahuacuotzingo", add
label define munimxlbl 12003 "Ajuchitlan del Progreso", add
label define munimxlbl 12004 "Alcozauca de Guerrero", add
label define munimxlbl 12005 "Alpoyeca", add
label define munimxlbl 12006 "Apaxtla", add
label define munimxlbl 12007 "Arcelia", add
label define munimxlbl 12008 "Atenango del Rio", add
label define munimxlbl 12009 "Atlamajalcingo del Monte", add
label define munimxlbl 12010 "Atlixtac", add
label define munimxlbl 12011 "Atoyac de Alvarez", add
label define munimxlbl 12012 "Ayutla de los Libres", add
label define munimxlbl 12013 "Azoyu", add
label define munimxlbl 12014 "Benito Juarez", add
label define munimxlbl 12015 "Buenavista de Cuellar", add
label define munimxlbl 12016 "Coahuayutla de Jose Maria Izazaga", add
label define munimxlbl 12017 "Cocula", add
label define munimxlbl 12018 "Copala", add
label define munimxlbl 12019 "Copalillo", add
label define munimxlbl 12020 "Copanatoyac", add
label define munimxlbl 12021 "Coyuca de Benitez", add
label define munimxlbl 12022 "Coyuca de Catalan", add
label define munimxlbl 12023 "Cuajinicuilapa", add
label define munimxlbl 12024 "Cualac", add
label define munimxlbl 12025 "Cuautepec", add
label define munimxlbl 12026 "Cuetzala del Progreso", add
label define munimxlbl 12027 "Cutzamala de Pinzon", add
label define munimxlbl 12028 "Chilapa de Alvarez", add
label define munimxlbl 12029 "Chilpancingo de los Bravo", add
label define munimxlbl 12030 "Florencio Villarreal", add
label define munimxlbl 12031 "General Canuto A. Neri", add
label define munimxlbl 12032 "General Heliodoro Castillo", add
label define munimxlbl 12033 "Huamuxtitlan", add
label define munimxlbl 12034 "Huitzuco de los Figueroa", add
label define munimxlbl 12035 "Iguala de la Independencia", add
label define munimxlbl 12036 "Igualapa", add
label define munimxlbl 12037 "Ixcateopan de Cuauhtemoc", add
label define munimxlbl 12038 "Jose Azueta", add
label define munimxlbl 12039 "Juan R. Escudero", add
label define munimxlbl 12040 "Leonardo Bravo", add
label define munimxlbl 12041 "Malinaltepec", add
label define munimxlbl 12042 "Martir de Cuilapan", add
label define munimxlbl 12043 "Metlatonoc", add
label define munimxlbl 12044 "Mochitlan", add
label define munimxlbl 12045 "Olinala", add
label define munimxlbl 12046 "Ometepec", add
label define munimxlbl 12047 "Pedro Ascencio Alquisiras", add
label define munimxlbl 12048 "Petatlan", add
label define munimxlbl 12049 "Pilcaya", add
label define munimxlbl 12050 "Pungarabato", add
label define munimxlbl 12051 "Quechultenango", add
label define munimxlbl 12052 "San Luis Acatlan", add
label define munimxlbl 12053 "San Marcos", add
label define munimxlbl 12054 "San Miguel Totolapan", add
label define munimxlbl 12055 "Taxco de Alarcon", add
label define munimxlbl 12056 "Tecoanapa", add
label define munimxlbl 12057 "Tecpan de Galeana", add
label define munimxlbl 12058 "Teloloapan", add
label define munimxlbl 12059 "Tepecoacuilco de Trujano", add
label define munimxlbl 12060 "Tetipac", add
label define munimxlbl 12061 "Tixtla de Guerrero", add
label define munimxlbl 12062 "Tlacoachistlahuaca", add
label define munimxlbl 12063 "Tlacoapa", add
label define munimxlbl 12064 "Tlalchapa", add
label define munimxlbl 12065 "Tlalixtaquilla de Maldonado", add
label define munimxlbl 12066 "Tlapa de Comonfort", add
label define munimxlbl 12067 "Tlapehuala", add
label define munimxlbl 12068 "Union de Isidoro Montes de Oca, La", add
label define munimxlbl 12069 "Xalpatlahuac", add
label define munimxlbl 12070 "Xochihuehuetlan", add
label define munimxlbl 12071 "Xochistlahuaca", add
label define munimxlbl 12072 "Zapotitlan Tablas", add
label define munimxlbl 12073 "Zirandaro", add
label define munimxlbl 12074 "Zitlala", add
label define munimxlbl 12075 "Eduardo Neri", add
label define munimxlbl 12076 "Acatepec", add
label define munimxlbl 13001 "Acatlan", add
label define munimxlbl 13002 "Acaxochitlan", add
label define munimxlbl 13003 "Actopan", add
label define munimxlbl 13004 "Agua Blanca de Iturbide", add
label define munimxlbl 13005 "Ajacuba", add
label define munimxlbl 13006 "Alfajayucan", add
label define munimxlbl 13007 "Almoloya", add
label define munimxlbl 13008 "Apan", add
label define munimxlbl 13009 "Arenal, El", add
label define munimxlbl 13010 "Atitalaquia", add
label define munimxlbl 13011 "Atlapexco", add
label define munimxlbl 13012 "Atotonilco el Grande", add
label define munimxlbl 13013 "Atotonilco de Tula", add
label define munimxlbl 13014 "Calnali", add
label define munimxlbl 13015 "Cardonal", add
label define munimxlbl 13016 "Cuautepec de Hinojosa", add
label define munimxlbl 13017 "Chapantongo", add
label define munimxlbl 13018 "Chapulhuacan", add
label define munimxlbl 13019 "Chilcuautla", add
label define munimxlbl 13020 "Eloxochitlan", add
label define munimxlbl 13021 "Emiliano Zapata", add
label define munimxlbl 13022 "Epazoyucan", add
label define munimxlbl 13023 "Francisco I. Madero", add
label define munimxlbl 13024 "Huasca de Ocampo", add
label define munimxlbl 13025 "Huautla", add
label define munimxlbl 13026 "Huazalingo", add
label define munimxlbl 13027 "Huehuetla", add
label define munimxlbl 13028 "Huejutla de Reyes", add
label define munimxlbl 13029 "Huichapan", add
label define munimxlbl 13030 "Ixmiquilpan", add
label define munimxlbl 13031 "Jacala de Ledezma", add
label define munimxlbl 13032 "Jaltocan", add
label define munimxlbl 13033 "Juarez Hidalgo", add
label define munimxlbl 13034 "Lolotla", add
label define munimxlbl 13035 "Metepec", add
label define munimxlbl 13036 "San Agustin Metzquititlan", add
label define munimxlbl 13037 "Metztitlan", add
label define munimxlbl 13038 "Mineral del Chico", add
label define munimxlbl 13039 "Mineral del Monte", add
label define munimxlbl 13040 "Mision, La", add
label define munimxlbl 13041 "Mixquiahuala de Juarez", add
label define munimxlbl 13042 "Molango de Escamilla", add
label define munimxlbl 13043 "Nicolas Flores", add
label define munimxlbl 13044 "Nopala de Villagran", add
label define munimxlbl 13045 "Omitlan de Juarez", add
label define munimxlbl 13046 "San Felipe Orizatlan", add
label define munimxlbl 13047 "Pacula", add
label define munimxlbl 13048 "Pachuca de Soto", add
label define munimxlbl 13049 "Pisaflores", add
label define munimxlbl 13050 "Progreso de Obregon", add
label define munimxlbl 13051 "Mineral de La Reforma", add
label define munimxlbl 13052 "San Agustin Tlaxiaca", add
label define munimxlbl 13053 "San Bartolo Tutotepec", add
label define munimxlbl 13054 "San Salvador", add
label define munimxlbl 13055 "Santiago de Anaya", add
label define munimxlbl 13056 "Santiago Tulantepec de Lugo Guerrero", add
label define munimxlbl 13057 "Singuilucan", add
label define munimxlbl 13058 "Tasquillo", add
label define munimxlbl 13059 "Tecozautla", add
label define munimxlbl 13060 "Tenango de Doria", add
label define munimxlbl 13061 "Tepeapulco", add
label define munimxlbl 13062 "Tepehuacan de Guerrero", add
label define munimxlbl 13063 "Tepeji del Rio de Ocampo", add
label define munimxlbl 13064 "Tepetitlan", add
label define munimxlbl 13065 "Tetepango", add
label define munimxlbl 13066 "Villa de Tezontepec", add
label define munimxlbl 13067 "Tezontepec de Aldama", add
label define munimxlbl 13068 "Tianguistengo", add
label define munimxlbl 13069 "Tizayuca", add
label define munimxlbl 13070 "Tlahuelilpan", add
label define munimxlbl 13071 "Tlahuiltepa", add
label define munimxlbl 13072 "Tlanalapa", add
label define munimxlbl 13073 "Tlanchinol", add
label define munimxlbl 13074 "Tlaxcoapan", add
label define munimxlbl 13075 "Tolcayuca", add
label define munimxlbl 13076 "Tula de Allende", add
label define munimxlbl 13077 "Tulancingo de Bravo", add
label define munimxlbl 13078 "Xochiatipan", add
label define munimxlbl 13079 "Xochicoatlan", add
label define munimxlbl 13080 "Yahualica", add
label define munimxlbl 13081 "Zacualtipan de Angeles", add
label define munimxlbl 13082 "Zapotlan de Juarez", add
label define munimxlbl 13083 "Zempoala", add
label define munimxlbl 13084 "Zimapan", add
label define munimxlbl 14001 "Acatic", add
label define munimxlbl 14002 "Acatlan de Juarez", add
label define munimxlbl 14003 "Ahualulco de Mercado", add
label define munimxlbl 14004 "Amacueca", add
label define munimxlbl 14005 "Amatitan", add
label define munimxlbl 14006 "Ameca", add
label define munimxlbl 14007 "San Juanito de Escobedo", add
label define munimxlbl 14008 "Arandas", add
label define munimxlbl 14009 "Arenal, El", add
label define munimxlbl 14010 "Atemajac de Brizuela", add
label define munimxlbl 14011 "Atengo", add
label define munimxlbl 14012 "Atenguillo", add
label define munimxlbl 14013 "Atotonilco el Alto", add
label define munimxlbl 14014 "Atoyac", add
label define munimxlbl 14015 "Autlan de Navarro", add
label define munimxlbl 14016 "Ayotlan", add
label define munimxlbl 14017 "Ayutla", add
label define munimxlbl 14018 "Barca, La", add
label define munimxlbl 14019 "Bolanos", add
label define munimxlbl 14020 "Cabo Corrientes", add
label define munimxlbl 14021 "Casimiro Castillo", add
label define munimxlbl 14022 "Cihuatlan", add
label define munimxlbl 14023 "Zapotlan el Grande", add
label define munimxlbl 14024 "Cocula", add
label define munimxlbl 14025 "Colotlan", add
label define munimxlbl 14026 "Concepcion de Buenos Aires", add
label define munimxlbl 14027 "Cuautitlan de Garcia Barragan", add
label define munimxlbl 14028 "Cuautla", add
label define munimxlbl 14029 "Cuquio", add
label define munimxlbl 14030 "Chapala", add
label define munimxlbl 14031 "Chimaltitan", add
label define munimxlbl 14032 "Chiquilistlan", add
label define munimxlbl 14033 "Degollado", add
label define munimxlbl 14034 "Ejutla", add
label define munimxlbl 14035 "Encarnacion de Diaz", add
label define munimxlbl 14036 "Etzatlan", add
label define munimxlbl 14037 "Grullo, El", add
label define munimxlbl 14038 "Guachinango", add
label define munimxlbl 14039 "Guadalajara", add
label define munimxlbl 14040 "Hostotipaquillo", add
label define munimxlbl 14041 "Huejucar", add
label define munimxlbl 14042 "Huejuquilla el Alto", add
label define munimxlbl 14043 "Huerta, La", add
label define munimxlbl 14044 "Ixtlahuacan de los Membrillos", add
label define munimxlbl 14045 "Ixtlahuacan del Rio", add
label define munimxlbl 14046 "Jalostotitlan", add
label define munimxlbl 14047 "Jamay", add
label define munimxlbl 14048 "Jesus Maria", add
label define munimxlbl 14049 "Jilotlan de los Dolores", add
label define munimxlbl 14050 "Jocotepec", add
label define munimxlbl 14051 "Juanacatlan", add
label define munimxlbl 14052 "Juchitlan", add
label define munimxlbl 14053 "Lagos de Moreno", add
label define munimxlbl 14054 "Limon, El", add
label define munimxlbl 14055 "Magdalena", add
label define munimxlbl 14056 "Santa Maria del Oro", add
label define munimxlbl 14057 "Manzanilla de la Paz, La", add
label define munimxlbl 14058 "Mascota", add
label define munimxlbl 14059 "Mazamitla", add
label define munimxlbl 14060 "Mexticacan", add
label define munimxlbl 14061 "Mezquitic", add
label define munimxlbl 14062 "Mixtlan", add
label define munimxlbl 14063 "Ocotlan", add
label define munimxlbl 14064 "Ojuelos de Jalisco", add
label define munimxlbl 14065 "Pihuamo", add
label define munimxlbl 14066 "Poncitlan", add
label define munimxlbl 14067 "Puerto Vallarta", add
label define munimxlbl 14068 "Villa Purificacion", add
label define munimxlbl 14069 "Quitupan", add
label define munimxlbl 14070 "Salto, El", add
label define munimxlbl 14071 "San Cristobal de la Barranca", add
label define munimxlbl 14072 "San Diego de Alejandria", add
label define munimxlbl 14073 "San Juan de los Lagos", add
label define munimxlbl 14074 "San Julian", add
label define munimxlbl 14075 "San Marcos", add
label define munimxlbl 14076 "San Martin de Bolanos", add
label define munimxlbl 14077 "San Martin de Hidalgo", add
label define munimxlbl 14078 "San Miguel el Alto", add
label define munimxlbl 14079 "Gomez Farias", add
label define munimxlbl 14080 "San Sebastian del Oeste", add
label define munimxlbl 14081 "Santa Maria de los Angeles", add
label define munimxlbl 14082 "Sayula", add
label define munimxlbl 14083 "Tala", add
label define munimxlbl 14084 "Talpa de Allende", add
label define munimxlbl 14085 "Tamazula de Gordiano", add
label define munimxlbl 14086 "Tapalpa", add
label define munimxlbl 14087 "Tecalitlan", add
label define munimxlbl 14088 "Tecolotlan", add
label define munimxlbl 14089 "Techaluta de Montenegro", add
label define munimxlbl 14090 "Tenamaxtlan", add
label define munimxlbl 14091 "Teocaltiche", add
label define munimxlbl 14092 "Teocuitatlan de Corona", add
label define munimxlbl 14093 "Tepatitlan de Morelos", add
label define munimxlbl 14094 "Tequila", add
label define munimxlbl 14095 "Teuchitlan", add
label define munimxlbl 14096 "Tizapan el Alto", add
label define munimxlbl 14097 "Tlajomulco de Zuniga", add
label define munimxlbl 14098 "Tlaquepaque", add
label define munimxlbl 14099 "Toliman", add
label define munimxlbl 14100 "Tomatlan", add
label define munimxlbl 14101 "Tonala", add
label define munimxlbl 14102 "Tonaya", add
label define munimxlbl 14103 "Tonila", add
label define munimxlbl 14104 "Totatiche", add
label define munimxlbl 14105 "Tototlan", add
label define munimxlbl 14106 "Tuxcacuesco", add
label define munimxlbl 14107 "Tuxcueca", add
label define munimxlbl 14108 "Tuxpan", add
label define munimxlbl 14109 "Union de San Antonio", add
label define munimxlbl 14110 "Union de Tula", add
label define munimxlbl 14111 "Valle de Guadalupe", add
label define munimxlbl 14112 "Valle de Juarez", add
label define munimxlbl 14113 "San Gabriel", add
label define munimxlbl 14114 "Villa Corona", add
label define munimxlbl 14115 "Villa Guerrero", add
label define munimxlbl 14116 "Villa Hidalgo", add
label define munimxlbl 14117 "Canadas de Obregon", add
label define munimxlbl 14118 "Yahualica de Gonzalez Gallo", add
label define munimxlbl 14119 "Zacoalco de Torres", add
label define munimxlbl 14120 "Zapopan", add
label define munimxlbl 14121 "Zapotiltic", add
label define munimxlbl 14122 "Zapotitlan de Vadillo", add
label define munimxlbl 14123 "Zapotlan del Rey", add
label define munimxlbl 14124 "Zapotlanejo", add
label define munimxlbl 15001 "Acambay", add
label define munimxlbl 15002 "Acolman", add
label define munimxlbl 15003 "Aculco", add
label define munimxlbl 15004 "Almoloya de Alquisiras", add
label define munimxlbl 15005 "Almoloya de Juarez", add
label define munimxlbl 15006 "Almoloya del Rio", add
label define munimxlbl 15007 "Amanalco", add
label define munimxlbl 15008 "Amatepec", add
label define munimxlbl 15009 "Amecameca", add
label define munimxlbl 15010 "Apaxco", add
label define munimxlbl 15011 "Atenco", add
label define munimxlbl 15012 "Atizapan", add
label define munimxlbl 15013 "Atizapan de Zaragoza", add
label define munimxlbl 15014 "Atlacomulco", add
label define munimxlbl 15015 "Atlautla", add
label define munimxlbl 15016 "Axapusco", add
label define munimxlbl 15017 "Ayapango", add
label define munimxlbl 15018 "Calimaya", add
label define munimxlbl 15019 "Capulhuac", add
label define munimxlbl 15020 "Coacalco de Berriozabal", add
label define munimxlbl 15021 "Coatepec Harinas", add
label define munimxlbl 15022 "Cocotitlan", add
label define munimxlbl 15023 "Coyotepec", add
label define munimxlbl 15024 "Cuautitlan", add
label define munimxlbl 15025 "Chalco", add
label define munimxlbl 15026 "Chapa de Mota", add
label define munimxlbl 15027 "Chapultepec", add
label define munimxlbl 15028 "Chiautla", add
label define munimxlbl 15029 "Chicoloapan", add
label define munimxlbl 15030 "Chiconcuac", add
label define munimxlbl 15031 "Chimalhuacan", add
label define munimxlbl 15032 "Donato Guerra", add
label define munimxlbl 15033 "Ecatepec de Morelos", add
label define munimxlbl 15034 "Ecatzingo", add
label define munimxlbl 15035 "Huehuetoca", add
label define munimxlbl 15036 "Hueypoxtla", add
label define munimxlbl 15037 "Huixquilucan", add
label define munimxlbl 15038 "Isidro Fabela", add
label define munimxlbl 15039 "Ixtapaluca", add
label define munimxlbl 15040 "Ixtapan de la Sal", add
label define munimxlbl 15041 "Ixtapan del Oro", add
label define munimxlbl 15042 "Ixtlahuaca", add
label define munimxlbl 15043 "Xalatlaco", add
label define munimxlbl 15044 "Jaltenco", add
label define munimxlbl 15045 "Jilotepec", add
label define munimxlbl 15046 "Jilotzingo", add
label define munimxlbl 15047 "Jiquipilco", add
label define munimxlbl 15048 "Jocotitlan", add
label define munimxlbl 15049 "Joquicingo", add
label define munimxlbl 15050 "Juchitepec", add
label define munimxlbl 15051 "Lerma", add
label define munimxlbl 15052 "Malinalco", add
label define munimxlbl 15053 "Melchor Ocampo", add
label define munimxlbl 15054 "Metepec", add
label define munimxlbl 15055 "Mexicaltzingo", add
label define munimxlbl 15056 "Morelos", add
label define munimxlbl 15057 "Naucalpan de Juarez", add
label define munimxlbl 15058 "Nezahualcoyotl", add
label define munimxlbl 15059 "Nextlalpan", add
label define munimxlbl 15060 "Nicolas Romero", add
label define munimxlbl 15061 "Nopaltepec", add
label define munimxlbl 15062 "Ocoyoacac", add
label define munimxlbl 15063 "Ocuilan", add
label define munimxlbl 15064 "Oro, El", add
label define munimxlbl 15065 "Otumba", add
label define munimxlbl 15066 "Otzoloapan", add
label define munimxlbl 15067 "Otzolotepec", add
label define munimxlbl 15068 "Ozumba", add
label define munimxlbl 15069 "Papalotla", add
label define munimxlbl 15070 "Paz, La", add
label define munimxlbl 15071 "Polotitlan", add
label define munimxlbl 15072 "Rayon", add
label define munimxlbl 15073 "San Antonio la Isla", add
label define munimxlbl 15074 "San Felipe del Progreso", add
label define munimxlbl 15075 "San Martin de las Piramides", add
label define munimxlbl 15076 "San Mateo Atenco", add
label define munimxlbl 15077 "San Simon de Guerrero", add
label define munimxlbl 15078 "Santo Tomas", add
label define munimxlbl 15079 "Soyaniquilpan de Juarez", add
label define munimxlbl 15080 "Sultepec", add
label define munimxlbl 15081 "Tecamac", add
label define munimxlbl 15082 "Tejupilco", add
label define munimxlbl 15083 "Temamatla", add
label define munimxlbl 15084 "Temascalapa", add
label define munimxlbl 15085 "Temascalcingo", add
label define munimxlbl 15086 "Temascaltepec", add
label define munimxlbl 15087 "Temoaya", add
label define munimxlbl 15088 "Tenancingo", add
label define munimxlbl 15089 "Tenango del Aire", add
label define munimxlbl 15090 "Tenango del Valle", add
label define munimxlbl 15091 "Teoloyucan", add
label define munimxlbl 15092 "Teotihuacan", add
label define munimxlbl 15093 "Tepetlaoxtoc", add
label define munimxlbl 15094 "Tepetlixpa", add
label define munimxlbl 15095 "Tepotzotlan", add
label define munimxlbl 15096 "Tequixquiac", add
label define munimxlbl 15097 "Texcaltitlan", add
label define munimxlbl 15098 "Texcalyacac", add
label define munimxlbl 15099 "Texcoco", add
label define munimxlbl 15100 "Tezoyuca", add
label define munimxlbl 15101 "Tianguistenco", add
label define munimxlbl 15102 "Timilpan", add
label define munimxlbl 15103 "Tlalmanalco", add
label define munimxlbl 15104 "Tlalnepantla de Baz", add
label define munimxlbl 15105 "Tlatlaya", add
label define munimxlbl 15106 "Toluca", add
label define munimxlbl 15107 "Tonatico", add
label define munimxlbl 15108 "Tultepec", add
label define munimxlbl 15109 "Tultitlan", add
label define munimxlbl 15110 "Valle de Bravo", add
label define munimxlbl 15111 "Villa de Allende", add
label define munimxlbl 15112 "Villa del Carbon", add
label define munimxlbl 15113 "Villa Guerrero", add
label define munimxlbl 15114 "Villa Victoria", add
label define munimxlbl 15115 "Xonacatlan", add
label define munimxlbl 15116 "Zacazonapan", add
label define munimxlbl 15117 "Zacualpan", add
label define munimxlbl 15118 "Zinacantepec", add
label define munimxlbl 15119 "Zumpahuacan", add
label define munimxlbl 15120 "Zumpango", add
label define munimxlbl 15121 "Cuautitlan Izcalli", add
label define munimxlbl 15122 "Valle de Chalco Solidaridad", add
label define munimxlbl 16001 "Acuitzio", add
label define munimxlbl 16002 "Aguililla", add
label define munimxlbl 16003 "Alvaro Obregon", add
label define munimxlbl 16004 "Angamacutiro", add
label define munimxlbl 16005 "Angangueo", add
label define munimxlbl 16006 "Apatzingan", add
label define munimxlbl 16007 "Aporo", add
label define munimxlbl 16008 "Aquila", add
label define munimxlbl 16009 "Ario", add
label define munimxlbl 16010 "Arteaga", add
label define munimxlbl 16011 "Brisenas", add
label define munimxlbl 16012 "Buenavista", add
label define munimxlbl 16013 "Caracuaro", add
label define munimxlbl 16014 "Coahuayana", add
label define munimxlbl 16015 "Coalcoman de Vazquez Pallares", add
label define munimxlbl 16016 "Coeneo", add
label define munimxlbl 16017 "Contepec", add
label define munimxlbl 16018 "Copandaro", add
label define munimxlbl 16019 "Cotija", add
label define munimxlbl 16020 "Cuitzeo", add
label define munimxlbl 16021 "Charapan", add
label define munimxlbl 16022 "Charo", add
label define munimxlbl 16023 "Chavinda", add
label define munimxlbl 16024 "Cheran", add
label define munimxlbl 16025 "Chilchota", add
label define munimxlbl 16026 "Chinicuila", add
label define munimxlbl 16027 "Chucandiro", add
label define munimxlbl 16028 "Churintzio", add
label define munimxlbl 16029 "Churumuco", add
label define munimxlbl 16030 "Ecuandureo", add
label define munimxlbl 16031 "Epitacio Huerta", add
label define munimxlbl 16032 "Erongaricuaro", add
label define munimxlbl 16033 "Gabriel Zamora", add
label define munimxlbl 16034 "Hidalgo", add
label define munimxlbl 16035 "Huacana, La", add
label define munimxlbl 16036 "Huandacareo", add
label define munimxlbl 16037 "Huaniqueo", add
label define munimxlbl 16038 "Huetamo", add
label define munimxlbl 16039 "Huiramba", add
label define munimxlbl 16040 "Indaparapeo", add
label define munimxlbl 16041 "Irimbo", add
label define munimxlbl 16042 "Ixtlan", add
label define munimxlbl 16043 "Jacona", add
label define munimxlbl 16044 "Jimenez", add
label define munimxlbl 16045 "Jiquilpan", add
label define munimxlbl 16046 "Juarez", add
label define munimxlbl 16047 "Jungapeo", add
label define munimxlbl 16048 "Lagunillas", add
label define munimxlbl 16049 "Madero", add
label define munimxlbl 16050 "Maravatio", add
label define munimxlbl 16051 "Marcos Castellanos", add
label define munimxlbl 16052 "Lazaro Cardenas", add
label define munimxlbl 16053 "Morelia", add
label define munimxlbl 16054 "Morelos", add
label define munimxlbl 16055 "Mugica", add
label define munimxlbl 16056 "Nahuatzen", add
label define munimxlbl 16057 "Nocupetaro", add
label define munimxlbl 16058 "Nuevo Parangaricutiro", add
label define munimxlbl 16059 "Nuevo Urecho", add
label define munimxlbl 16060 "Numaran", add
label define munimxlbl 16061 "Ocampo", add
label define munimxlbl 16062 "Pajacuaran", add
label define munimxlbl 16063 "Panindicuaro", add
label define munimxlbl 16064 "Paracuaro", add
label define munimxlbl 16065 "Paracho", add
label define munimxlbl 16066 "Patzcuaro", add
label define munimxlbl 16067 "Penjamillo", add
label define munimxlbl 16068 "Periban", add
label define munimxlbl 16069 "Piedad, La", add
label define munimxlbl 16070 "Purepero", add
label define munimxlbl 16071 "Puruandiro", add
label define munimxlbl 16072 "Querendaro", add
label define munimxlbl 16073 "Quiroga", add
label define munimxlbl 16074 "Cojumatlan de Regules", add
label define munimxlbl 16075 "Reyes, Los", add
label define munimxlbl 16076 "Sahuayo", add
label define munimxlbl 16077 "San Lucas", add
label define munimxlbl 16078 "Santa Ana Maya", add
label define munimxlbl 16079 "Salvador Escalante", add
label define munimxlbl 16080 "Senguio", add
label define munimxlbl 16081 "Susupuato", add
label define munimxlbl 16082 "Tacambaro", add
label define munimxlbl 16083 "Tancitaro", add
label define munimxlbl 16084 "Tangamandapio", add
label define munimxlbl 16085 "Tangancicuaro", add
label define munimxlbl 16086 "Tanhuato", add
label define munimxlbl 16087 "Taretan", add
label define munimxlbl 16088 "Tarimbaro", add
label define munimxlbl 16089 "Tepalcatepec", add
label define munimxlbl 16090 "Tingambato", add
label define munimxlbl 16091 "Tinguindin", add
label define munimxlbl 16092 "Tiquicheo de Nicolas Romero", add
label define munimxlbl 16093 "Tlalpujahua", add
label define munimxlbl 16094 "Tlazazalca", add
label define munimxlbl 16095 "Tocumbo", add
label define munimxlbl 16096 "Tumbiscatio", add
label define munimxlbl 16097 "Turicato", add
label define munimxlbl 16098 "Tuxpan", add
label define munimxlbl 16099 "Tuzantla", add
label define munimxlbl 16100 "Tzintzuntzan", add
label define munimxlbl 16101 "Tzitzio", add
label define munimxlbl 16102 "Uruapan", add
label define munimxlbl 16103 "Venustiano Carranza", add
label define munimxlbl 16104 "Villamar", add
label define munimxlbl 16105 "Vista Hermosa", add
label define munimxlbl 16106 "Yurecuaro", add
label define munimxlbl 16107 "Zacapu", add
label define munimxlbl 16108 "Zamora", add
label define munimxlbl 16109 "Zinaparo", add
label define munimxlbl 16110 "Zinapecuaro", add
label define munimxlbl 16111 "Ziracuaretiro", add
label define munimxlbl 16112 "Zitacuaro", add
label define munimxlbl 16113 "Jose Sixto Verduzco", add
label define munimxlbl 17001 "Amacuzac", add
label define munimxlbl 17002 "Atlatlahucan", add
label define munimxlbl 17003 "Axochiapan", add
label define munimxlbl 17004 "Ayala", add
label define munimxlbl 17005 "Coatlan del Rio", add
label define munimxlbl 17006 "Cuautla", add
label define munimxlbl 17007 "Cuernavaca", add
label define munimxlbl 17008 "Emiliano Zapata", add
label define munimxlbl 17009 "Huitzilac", add
label define munimxlbl 17010 "Jantetelco", add
label define munimxlbl 17011 "Jiutepec", add
label define munimxlbl 17012 "Jojutla", add
label define munimxlbl 17013 "Jonacatepec", add
label define munimxlbl 17014 "Mazatepec", add
label define munimxlbl 17015 "Miacatlan", add
label define munimxlbl 17016 "Ocuituco", add
label define munimxlbl 17017 "Puente de Ixtla", add
label define munimxlbl 17018 "Temixco", add
label define munimxlbl 17019 "Tepalcingo", add
label define munimxlbl 17020 "Tepoztlan", add
label define munimxlbl 17021 "Tetecala", add
label define munimxlbl 17022 "Tetela del Volcan", add
label define munimxlbl 17023 "Tlalnepantla", add
label define munimxlbl 17024 "Tlaltizapan", add
label define munimxlbl 17025 "Tlaquiltenango", add
label define munimxlbl 17026 "Tlayacapan", add
label define munimxlbl 17027 "Totolapan", add
label define munimxlbl 17028 "Xochitepec", add
label define munimxlbl 17029 "Yautepec", add
label define munimxlbl 17030 "Yecapixtla", add
label define munimxlbl 17031 "Zacatepec de Hidalgo", add
label define munimxlbl 17032 "Zacualpan de Amilpas", add
label define munimxlbl 17033 "Temoac", add
label define munimxlbl 18001 "Acaponeta", add
label define munimxlbl 18002 "Ahuacatlan", add
label define munimxlbl 18003 "Amatlan de Canas", add
label define munimxlbl 18004 "Compostela", add
label define munimxlbl 18005 "Huajicori", add
label define munimxlbl 18006 "Ixtlan del Rio", add
label define munimxlbl 18007 "Jala", add
label define munimxlbl 18008 "Xalisco", add
label define munimxlbl 18009 "Del Nayar", add
label define munimxlbl 18010 "Rosamorada", add
label define munimxlbl 18011 "Ruiz", add
label define munimxlbl 18012 "San Blas", add
label define munimxlbl 18013 "San Pedro Lagunillas", add
label define munimxlbl 18014 "Santa Maria del Oro", add
label define munimxlbl 18015 "Santiago Ixcuintla", add
label define munimxlbl 18016 "Tecuala", add
label define munimxlbl 18017 "Tepic", add
label define munimxlbl 18018 "Tuxpan", add
label define munimxlbl 18019 "Yesca, La", add
label define munimxlbl 18020 "Bahia de Banderas", add
label define munimxlbl 19001 "Abasolo", add
label define munimxlbl 19002 "Agualeguas", add
label define munimxlbl 19003 "Aldamas, Los", add
label define munimxlbl 19004 "Allende", add
label define munimxlbl 19005 "Anahuac", add
label define munimxlbl 19006 "Apodaca", add
label define munimxlbl 19007 "Aramberri", add
label define munimxlbl 19008 "Bustamante", add
label define munimxlbl 19009 "Cadereyta Jimenez", add
label define munimxlbl 19010 "Carmen", add
label define munimxlbl 19011 "Cerralvo", add
label define munimxlbl 19012 "Cienega de Flores", add
label define munimxlbl 19013 "China", add
label define munimxlbl 19014 "Doctor Arroyo", add
label define munimxlbl 19015 "Doctor Coss", add
label define munimxlbl 19016 "Doctor Gonzalez", add
label define munimxlbl 19017 "Galeana", add
label define munimxlbl 19018 "Garcia", add
label define munimxlbl 19019 "San Pedro Garza Garcia", add
label define munimxlbl 19020 "General Bravo", add
label define munimxlbl 19021 "General Escobedo", add
label define munimxlbl 19022 "General Teran", add
label define munimxlbl 19023 "General Trevino", add
label define munimxlbl 19024 "General Zaragoza", add
label define munimxlbl 19025 "General Zuazua", add
label define munimxlbl 19026 "Guadalupe", add
label define munimxlbl 19027 "Herreras, Los", add
label define munimxlbl 19028 "Higueras", add
label define munimxlbl 19029 "Hualahuises", add
label define munimxlbl 19030 "Iturbide", add
label define munimxlbl 19031 "Juarez", add
label define munimxlbl 19032 "Lampazos de Naranjo", add
label define munimxlbl 19033 "Linares", add
label define munimxlbl 19034 "Marin", add
label define munimxlbl 19035 "Melchor Ocampo", add
label define munimxlbl 19036 "Mier y Noriega", add
label define munimxlbl 19037 "Mina", add
label define munimxlbl 19038 "Montemorelos", add
label define munimxlbl 19039 "Monterrey", add
label define munimxlbl 19040 "Paras", add
label define munimxlbl 19041 "Pesqueria", add
label define munimxlbl 19042 "Ramones, Los", add
label define munimxlbl 19043 "Rayones", add
label define munimxlbl 19044 "Sabinas Hidalgo", add
label define munimxlbl 19045 "Salinas Victoria", add
label define munimxlbl 19046 "San Nicolas de los Garza", add
label define munimxlbl 19047 "Hidalgo", add
label define munimxlbl 19048 "Santa Catarina", add
label define munimxlbl 19049 "Santiago", add
label define munimxlbl 19050 "Vallecillo", add
label define munimxlbl 19051 "Villaldama", add
label define munimxlbl 20001 "Abejones", add
label define munimxlbl 20002 "Acatlan de Perez Figueroa", add
label define munimxlbl 20003 "Asuncion Cacalotepec", add
label define munimxlbl 20004 "Asuncion Cuyotepeji", add
label define munimxlbl 20005 "Asuncion Ixtaltepec", add
label define munimxlbl 20006 "Asuncion Nochixtlan", add
label define munimxlbl 20007 "Asuncion Ocotlan", add
label define munimxlbl 20008 "Asuncion Tlacolulita", add
label define munimxlbl 20009 "Ayotzintepec", add
label define munimxlbl 20010 "Barrio de la Soledad, El", add
label define munimxlbl 20011 "Calihuala", add
label define munimxlbl 20012 "Candelaria Loxicha", add
label define munimxlbl 20013 "Cienega de Zimatlan", add
label define munimxlbl 20014 "Ciudad Ixtepec", add
label define munimxlbl 20015 "Coatecas Altas", add
label define munimxlbl 20016 "Coicoyan de las Flores", add
label define munimxlbl 20017 "Compania, La", add
label define munimxlbl 20018 "Concepcion Buenavista", add
label define munimxlbl 20019 "Concepcion Papalo", add
label define munimxlbl 20020 "Constancia del Rosario", add
label define munimxlbl 20021 "Cosolapa", add
label define munimxlbl 20022 "Cosoltepec", add
label define munimxlbl 20023 "Cuilapam de Guerrero", add
label define munimxlbl 20024 "Cuyamecalco Villa de Zaragoza", add
label define munimxlbl 20025 "Chahuites", add
label define munimxlbl 20026 "Chalcatongo de Hidalgo", add
label define munimxlbl 20027 "Chiquihuitlan de Benito Juarez", add
label define munimxlbl 20028 "Heroica Ciudad de Ejutla de Crespo", add
label define munimxlbl 20029 "Eloxochitlan de Flores Magon", add
label define munimxlbl 20030 "Espinal, El", add
label define munimxlbl 20031 "Tamazulapam del Espiritu Santo", add
label define munimxlbl 20032 "Fresnillo de Trujano", add
label define munimxlbl 20033 "Guadalupe Etla", add
label define munimxlbl 20034 "Guadalupe de Ramirez", add
label define munimxlbl 20035 "Guelatao de Juarez", add
label define munimxlbl 20036 "Guevea de Humboldt", add
label define munimxlbl 20037 "Mesones Hidalgo", add
label define munimxlbl 20038 "Villa Hidalgo", add
label define munimxlbl 20039 "Heroica Ciudad de Huajuapan de Leon", add
label define munimxlbl 20040 "Huautepec", add
label define munimxlbl 20041 "Huautla de Jimenez", add
label define munimxlbl 20042 "Ixtlan de Juarez", add
label define munimxlbl 20043 "Juchitan de Zaragoza", add
label define munimxlbl 20044 "Loma Bonita", add
label define munimxlbl 20045 "Magdalena Apasco", add
label define munimxlbl 20046 "Magdalena Jaltepec", add
label define munimxlbl 20047 "Santa Magdalena Jicotlan", add
label define munimxlbl 20048 "Magdalena Mixtepec", add
label define munimxlbl 20049 "Magdalena Ocotlan", add
label define munimxlbl 20050 "Magdalena Penasco", add
label define munimxlbl 20051 "Magdalena Teitipac", add
label define munimxlbl 20052 "Magdalena Tequisistlan", add
label define munimxlbl 20053 "Magdalena Tlacotepec", add
label define munimxlbl 20054 "Magdalena Zahuatlan", add
label define munimxlbl 20055 "Mariscala de Juarez", add
label define munimxlbl 20056 "Martires de Tacubaya", add
label define munimxlbl 20057 "Matias Romero", add
label define munimxlbl 20058 "Mazatlan Villa de Flores", add
label define munimxlbl 20059 "Miahuatlan de Porfirio Diaz", add
label define munimxlbl 20060 "Mixistlan de la Reforma", add
label define munimxlbl 20061 "Monjas", add
label define munimxlbl 20062 "Natividad", add
label define munimxlbl 20063 "Nazareno Etla", add
label define munimxlbl 20064 "Nejapa de Madero", add
label define munimxlbl 20065 "Ixpantepec Nieves", add
label define munimxlbl 20066 "Santiago Niltepec", add
label define munimxlbl 20067 "Oaxaca de Juarez", add
label define munimxlbl 20068 "Ocotlan de Morelos", add
label define munimxlbl 20069 "Pe, La", add
label define munimxlbl 20070 "Pinotepa de Don Luis", add
label define munimxlbl 20071 "Pluma Hidalgo", add
label define munimxlbl 20072 "San Jose del Progreso", add
label define munimxlbl 20073 "Putla Villa de Guerrero", add
label define munimxlbl 20074 "Santa Catarina Quioquitani", add
label define munimxlbl 20075 "Reforma de Pineda", add
label define munimxlbl 20076 "Reforma, La", add
label define munimxlbl 20077 "Reyes Etla", add
label define munimxlbl 20078 "Rojas de Cuauhtemoc", add
label define munimxlbl 20079 "Salina Cruz", add
label define munimxlbl 20080 "San Agustin Amatengo", add
label define munimxlbl 20081 "San Agustin Atenango", add
label define munimxlbl 20082 "San Agustin Chayuco", add
label define munimxlbl 20083 "San Agustin de las Juntas", add
label define munimxlbl 20084 "San Agustin Etla", add
label define munimxlbl 20085 "San Agustin Loxicha", add
label define munimxlbl 20086 "San Agustin Tlacotepec", add
label define munimxlbl 20087 "San Agustin Yatareni", add
label define munimxlbl 20088 "San Andres Cabecera Nueva", add
label define munimxlbl 20089 "San Andres Dinicuiti", add
label define munimxlbl 20090 "San Andres Huaxpaltepec", add
label define munimxlbl 20091 "San Andres Huayapam", add
label define munimxlbl 20092 "San Andres Ixtlahuaca", add
label define munimxlbl 20093 "San Andres Lagunas", add
label define munimxlbl 20094 "San Andres Nuxino", add
label define munimxlbl 20095 "San Andres Paxtlan", add
label define munimxlbl 20096 "San Andres Sinaxtla", add
label define munimxlbl 20097 "San Andres Solaga", add
label define munimxlbl 20098 "San Andres Teotilalpam", add
label define munimxlbl 20099 "San Andres Tepetlapa", add
label define munimxlbl 20100 "San Andres Yaa", add
label define munimxlbl 20101 "San Andres Zabache", add
label define munimxlbl 20102 "San Andres Zautla", add
label define munimxlbl 20103 "San Antonino Castillo Velasco", add
label define munimxlbl 20104 "San Antonino el Alto", add
label define munimxlbl 20105 "San Antonino Monte Verde", add
label define munimxlbl 20106 "San Antonio Acutla", add
label define munimxlbl 20107 "San Antonio de la Cal", add
label define munimxlbl 20108 "San Antonio Huitepec", add
label define munimxlbl 20109 "San Antonio Nanahuatipam", add
label define munimxlbl 20110 "San Antonio Sinicahua", add
label define munimxlbl 20111 "San Antonio Tepetlapa", add
label define munimxlbl 20112 "San Baltazar Chichicapam", add
label define munimxlbl 20113 "San Baltazar Loxicha", add
label define munimxlbl 20114 "San Baltazar Yatzachi el Bajo", add
label define munimxlbl 20115 "San Bartolo Coyotepec", add
label define munimxlbl 20116 "San Bartolome Ayautla", add
label define munimxlbl 20117 "San Bartolome Loxicha", add
label define munimxlbl 20118 "San Bartolome Quialana", add
label define munimxlbl 20119 "San Bartolome Yucuane", add
label define munimxlbl 20120 "San Bartolome Zoogocho", add
label define munimxlbl 20121 "San Bartolo Soyaltepec", add
label define munimxlbl 20122 "San Bartolo Yautepec", add
label define munimxlbl 20123 "San Bernardo Mixtepec", add
label define munimxlbl 20124 "San Blas Atempa", add
label define munimxlbl 20125 "San Carlos Yautepec", add
label define munimxlbl 20126 "San Cristobal Amatlan", add
label define munimxlbl 20127 "San Cristobal Amoltepec", add
label define munimxlbl 20128 "San Cristobal Lachirioag", add
label define munimxlbl 20129 "San Cristobal Suchixtlahuaca", add
label define munimxlbl 20130 "San Dionisio del Mar", add
label define munimxlbl 20131 "San Dionisio Ocotepec", add
label define munimxlbl 20132 "San Dionisio Ocotlan", add
label define munimxlbl 20133 "San Esteban Atatlahuca", add
label define munimxlbl 20134 "San Felipe Jalapa de Diaz", add
label define munimxlbl 20135 "San Felipe Tejalapam", add
label define munimxlbl 20136 "San Felipe Usila", add
label define munimxlbl 20137 "San Francisco Cahuacua", add
label define munimxlbl 20138 "San Francisco Cajonos", add
label define munimxlbl 20139 "San Francisco Chapulapa", add
label define munimxlbl 20140 "San Francisco Chindua", add
label define munimxlbl 20141 "San Francisco del Mar", add
label define munimxlbl 20142 "San Francisco Huehuetlan", add
label define munimxlbl 20143 "San Francisco Ixhuatan", add
label define munimxlbl 20144 "San Francisco Jaltepetongo", add
label define munimxlbl 20145 "San Francisco Lachigolo", add
label define munimxlbl 20146 "San Francisco Logueche", add
label define munimxlbl 20147 "San Francisco Nuxano", add
label define munimxlbl 20148 "San Francisco Ozolotepec", add
label define munimxlbl 20149 "San Francisco Sola", add
label define munimxlbl 20150 "San Francisco Telixtlahuaca", add
label define munimxlbl 20151 "San Francisco Teopan", add
label define munimxlbl 20152 "San Francisco Tlapancingo", add
label define munimxlbl 20153 "San Gabriel Mixtepec", add
label define munimxlbl 20154 "San Ildefonso Amatlan", add
label define munimxlbl 20155 "San Ildefonso Sola", add
label define munimxlbl 20156 "San Ildefonso Villa Alta", add
label define munimxlbl 20157 "San Jacinto Amilpas", add
label define munimxlbl 20158 "San Jacinto Tlacotepec", add
label define munimxlbl 20159 "San Jeronimo Coatlan", add
label define munimxlbl 20160 "San Jeronimo Silacayoapilla", add
label define munimxlbl 20161 "San Jeronimo Sosola", add
label define munimxlbl 20162 "San Jeronimo Taviche", add
label define munimxlbl 20163 "San Jeronimo Tecoatl", add
label define munimxlbl 20164 "San Jorge Nuchita", add
label define munimxlbl 20165 "San Jose Ayuquila", add
label define munimxlbl 20166 "San Jose Chiltepec", add
label define munimxlbl 20167 "San Jose del Penasco", add
label define munimxlbl 20168 "San Jose Estancia Grande", add
label define munimxlbl 20169 "San Jose Independencia", add
label define munimxlbl 20170 "San Jose Lachiguiri", add
label define munimxlbl 20171 "San Jose Tenango", add
label define munimxlbl 20172 "San Juan Achiutla", add
label define munimxlbl 20173 "San Juan Atepec", add
label define munimxlbl 20174 "Animas Trujano", add
label define munimxlbl 20175 "San Juan Bautista Atatlahuca", add
label define munimxlbl 20176 "San Juan Bautista Coixtlahuaca", add
label define munimxlbl 20177 "San Juan Bautista Cuicatlan", add
label define munimxlbl 20178 "San Juan Bautista Guelache", add
label define munimxlbl 20179 "San Juan Bautista Jayacatlan", add
label define munimxlbl 20180 "San Juan Bautista lo de Soto", add
label define munimxlbl 20181 "San Juan Bautista Suchitepec", add
label define munimxlbl 20182 "San Juan Bautista Tlacoatzintepec", add
label define munimxlbl 20183 "San Juan Bautista Tlachichilco", add
label define munimxlbl 20184 "San Juan Bautista Tuxtepec", add
label define munimxlbl 20185 "San Juan Cacahuatepec", add
label define munimxlbl 20186 "San Juan Cieneguilla", add
label define munimxlbl 20187 "San Juan Coatzospam", add
label define munimxlbl 20188 "San Juan Colorado", add
label define munimxlbl 20189 "San Juan Comaltepec", add
label define munimxlbl 20190 "San Juan Cotzocon", add
label define munimxlbl 20191 "San Juan Chicomezuchil", add
label define munimxlbl 20192 "San Juan Chilateca", add
label define munimxlbl 20193 "San Juan del Estado", add
label define munimxlbl 20194 "San Juan del Rio", add
label define munimxlbl 20195 "San Juan Diuxi", add
label define munimxlbl 20196 "San Juan Evangelista Analco", add
label define munimxlbl 20197 "San Juan Guelavia", add
label define munimxlbl 20198 "San Juan Guichicovi", add
label define munimxlbl 20199 "San Juan Ihualtepec", add
label define munimxlbl 20200 "San Juan Juquila Mixes", add
label define munimxlbl 20201 "San Juan Juquila Vijanos", add
label define munimxlbl 20202 "San Juan Lachao", add
label define munimxlbl 20203 "San Juan Lachigalla", add
label define munimxlbl 20204 "San Juan Lajarcia", add
label define munimxlbl 20205 "San Juan Lalana", add
label define munimxlbl 20206 "San Juan de los Cues", add
label define munimxlbl 20207 "San Juan Mazatlan", add
label define munimxlbl 20208 "San Juan Mixtepec - distr. 08", add
label define munimxlbl 20209 "San Juan Mixtepec - distr. 26", add
label define munimxlbl 20210 "San Juan Numi", add
label define munimxlbl 20211 "San Juan Ozolotepec", add
label define munimxlbl 20212 "San Juan Petlapa", add
label define munimxlbl 20213 "San Juan Quiahije", add
label define munimxlbl 20214 "San Juan Quiotepec", add
label define munimxlbl 20215 "San Juan Sayultepec", add
label define munimxlbl 20216 "San Juan Tabaa", add
label define munimxlbl 20217 "San Juan Tamazola", add
label define munimxlbl 20218 "San Juan Teita", add
label define munimxlbl 20219 "San Juan Teitipac", add
label define munimxlbl 20220 "San Juan Tepeuxila", add
label define munimxlbl 20221 "San Juan Teposcolula", add
label define munimxlbl 20222 "San Juan Yaee", add
label define munimxlbl 20223 "San Juan Yatzona", add
label define munimxlbl 20224 "San Juan Yucuita", add
label define munimxlbl 20225 "San Lorenzo", add
label define munimxlbl 20226 "San Lorenzo Albarradas", add
label define munimxlbl 20227 "San Lorenzo Cacaotepec", add
label define munimxlbl 20228 "San Lorenzo Cuaunecuiltitla", add
label define munimxlbl 20229 "San Lorenzo Texmelucan", add
label define munimxlbl 20230 "San Lorenzo Victoria", add
label define munimxlbl 20231 "San Lucas Camotlan", add
label define munimxlbl 20232 "San Lucas Ojitlan", add
label define munimxlbl 20233 "San Lucas Quiavini", add
label define munimxlbl 20234 "San Lucas Zoquiapam", add
label define munimxlbl 20235 "San Luis Amatlan", add
label define munimxlbl 20236 "San Marcial Ozolotepec", add
label define munimxlbl 20237 "San Marcos Arteaga", add
label define munimxlbl 20238 "San Martin de los Cansecos", add
label define munimxlbl 20239 "San Martin Huamelulpam", add
label define munimxlbl 20240 "San Martin Itunyoso", add
label define munimxlbl 20241 "San Martin Lachila", add
label define munimxlbl 20242 "San Martin Peras", add
label define munimxlbl 20243 "San Martin Tilcajete", add
label define munimxlbl 20244 "San Martin Toxpalan", add
label define munimxlbl 20245 "San Martin Zacatepec", add
label define munimxlbl 20246 "San Mateo Cajonos", add
label define munimxlbl 20247 "Capulalpam de Mendez", add
label define munimxlbl 20248 "San Mateo del Mar", add
label define munimxlbl 20249 "San Mateo Yoloxochitlan", add
label define munimxlbl 20250 "San Mateo Etlatongo", add
label define munimxlbl 20251 "San Mateo Nejapam", add
label define munimxlbl 20252 "San Mateo Penasco", add
label define munimxlbl 20253 "San Mateo Pinas", add
label define munimxlbl 20254 "San Mateo Rio Hondo", add
label define munimxlbl 20255 "San Mateo Sindihui", add
label define munimxlbl 20256 "San Mateo Tlapiltepec", add
label define munimxlbl 20257 "San Melchor Betaza", add
label define munimxlbl 20258 "San Miguel Achiutla", add
label define munimxlbl 20259 "San Miguel Ahuehuetitlan", add
label define munimxlbl 20260 "San Miguel Aloapam", add
label define munimxlbl 20261 "San Miguel Amatitlan", add
label define munimxlbl 20262 "San Miguel Amatlan", add
label define munimxlbl 20263 "San Miguel Coatlan", add
label define munimxlbl 20264 "San Miguel Chicahua", add
label define munimxlbl 20265 "San Miguel Chimalapa", add
label define munimxlbl 20266 "San Miguel del Puerto", add
label define munimxlbl 20267 "San Miguel del Rio", add
label define munimxlbl 20268 "San Miguel Ejutla", add
label define munimxlbl 20269 "San Miguel el Grande", add
label define munimxlbl 20270 "San Miguel Huautla", add
label define munimxlbl 20271 "San Miguel Mixtepec", add
label define munimxlbl 20272 "San Miguel Panixtlahuaca", add
label define munimxlbl 20273 "San Miguel Peras", add
label define munimxlbl 20274 "San Miguel Piedras", add
label define munimxlbl 20275 "San Miguel Quetzaltepec", add
label define munimxlbl 20276 "San Miguel Santa Flor", add
label define munimxlbl 20277 "Villa Sola de Vega", add
label define munimxlbl 20278 "San Miguel Soyaltepec", add
label define munimxlbl 20279 "San Miguel Suchixtepec", add
label define munimxlbl 20280 "Villa Talea de Castro", add
label define munimxlbl 20281 "San Miguel Tecomatlan", add
label define munimxlbl 20282 "San Miguel Tenango", add
label define munimxlbl 20283 "San Miguel Tequixtepec", add
label define munimxlbl 20284 "San Miguel Tilquiapam", add
label define munimxlbl 20285 "San Miguel Tlacamama", add
label define munimxlbl 20286 "San Miguel Tlacotepec", add
label define munimxlbl 20287 "San Miguel Tulancingo", add
label define munimxlbl 20288 "San Miguel Yotao", add
label define munimxlbl 20289 "San Nicolas", add
label define munimxlbl 20290 "San Nicolas Hidalgo", add
label define munimxlbl 20291 "San Pablo Coatlan", add
label define munimxlbl 20292 "San Pablo Cuatro Venados", add
label define munimxlbl 20293 "San Pablo Etla", add
label define munimxlbl 20294 "San Pablo Huitzo", add
label define munimxlbl 20295 "San Pablo Huixtepec", add
label define munimxlbl 20296 "San Pablo Macuiltianguis", add
label define munimxlbl 20297 "San Pablo Tijaltepec", add
label define munimxlbl 20298 "San Pablo Villa de Mitla", add
label define munimxlbl 20299 "San Pablo Yaganiza", add
label define munimxlbl 20300 "San Pedro Amuzgos", add
label define munimxlbl 20301 "San Pedro Apostol", add
label define munimxlbl 20302 "San Pedro Atoyac", add
label define munimxlbl 20303 "San Pedro Cajonos", add
label define munimxlbl 20304 "San Pedro Coxcaltepec Cantaros", add
label define munimxlbl 20305 "San Pedro Comitancillo", add
label define munimxlbl 20306 "San Pedro el Alto", add
label define munimxlbl 20307 "San Pedro Huamelula", add
label define munimxlbl 20308 "San Pedro Huilotepec", add
label define munimxlbl 20309 "San Pedro Ixcatlan", add
label define munimxlbl 20310 "San Pedro Ixtlahuaca", add
label define munimxlbl 20311 "San Pedro Jaltepetongo", add
label define munimxlbl 20312 "San Pedro Jicayan", add
label define munimxlbl 20313 "San Pedro Jocotipac", add
label define munimxlbl 20314 "San Pedro Juchatengo", add
label define munimxlbl 20315 "San Pedro Martir", add
label define munimxlbl 20316 "San Pedro Martir Quiechapa", add
label define munimxlbl 20317 "San Pedro Martir Yucuxaco", add
label define munimxlbl 20318 "San Pedro Mixtepec - distr. 22", add
label define munimxlbl 20319 "San Pedro Mixtepec - distr. 26", add
label define munimxlbl 20320 "San Pedro Molinos", add
label define munimxlbl 20321 "San Pedro Nopala", add
label define munimxlbl 20322 "San Pedro Ocopetatillo", add
label define munimxlbl 20323 "San Pedro Ocotepec", add
label define munimxlbl 20324 "San Pedro Pochutla", add
label define munimxlbl 20325 "San Pedro Quiatoni", add
label define munimxlbl 20326 "San Pedro Sochiapam", add
label define munimxlbl 20327 "San Pedro Tapanatepec", add
label define munimxlbl 20328 "San Pedro Taviche", add
label define munimxlbl 20329 "San Pedro Teozacoalco", add
label define munimxlbl 20330 "San Pedro Teutila", add
label define munimxlbl 20331 "San Pedro Tidaa", add
label define munimxlbl 20332 "San Pedro Topiltepec", add
label define munimxlbl 20333 "San Pedro Totolapa", add
label define munimxlbl 20334 "Villa de Tututepec de Melchor Ocampo", add
label define munimxlbl 20335 "San Pedro Yaneri", add
label define munimxlbl 20336 "San Pedro Yolox", add
label define munimxlbl 20337 "San Pedro y San Pablo Ayutla", add
label define munimxlbl 20338 "Villa de Etla", add
label define munimxlbl 20339 "San Pedro y San Pablo Teposcolula", add
label define munimxlbl 20340 "San Pedro y San Pablo Tequixtepec", add
label define munimxlbl 20341 "San Pedro Yucunama", add
label define munimxlbl 20342 "San Raymundo Jalpan", add
label define munimxlbl 20343 "San Sebastian Abasolo", add
label define munimxlbl 20344 "San Sebastian Coatlan", add
label define munimxlbl 20345 "San Sebastian Ixcapa", add
label define munimxlbl 20346 "San Sebastian Nicananduta", add
label define munimxlbl 20347 "San Sebastian Rio Hondo", add
label define munimxlbl 20348 "San Sebastian Tecomaxtlahuaca", add
label define munimxlbl 20349 "San Sebastian Teitipac", add
label define munimxlbl 20350 "San Sebastian Tutla", add
label define munimxlbl 20351 "San Simon Almolongas", add
label define munimxlbl 20352 "San Simon Zahuatlan", add
label define munimxlbl 20353 "Santa Ana", add
label define munimxlbl 20354 "Santa Ana Ateixtlahuaca", add
label define munimxlbl 20355 "Santa Ana Cuauhtemoc", add
label define munimxlbl 20356 "Santa Ana del Valle", add
label define munimxlbl 20357 "Santa Ana Tavela", add
label define munimxlbl 20358 "Santa Ana Tlapacoyan", add
label define munimxlbl 20359 "Santa Ana Yareni", add
label define munimxlbl 20360 "Santa Ana Zegache", add
label define munimxlbl 20361 "Santa Catalina Quieri", add
label define munimxlbl 20362 "Santa Catarina Cuixtla", add
label define munimxlbl 20363 "Santa Catarina Ixtepeji", add
label define munimxlbl 20364 "Santa Catarina Juquila", add
label define munimxlbl 20365 "Santa Catarina Lachatao", add
label define munimxlbl 20366 "Santa Catarina Loxicha", add
label define munimxlbl 20367 "Santa Catarina Mechoacan", add
label define munimxlbl 20368 "Santa Catarina Minas", add
label define munimxlbl 20369 "Santa Catarina Quiane", add
label define munimxlbl 20370 "Santa Catarina Tayata", add
label define munimxlbl 20371 "Santa Catarina Ticua", add
label define munimxlbl 20372 "Santa Catarina Yosonotu", add
label define munimxlbl 20373 "Santa Catarina Zapoquila", add
label define munimxlbl 20374 "Santa Cruz Acatepec", add
label define munimxlbl 20375 "Santa Cruz Amilpas", add
label define munimxlbl 20376 "Santa Cruz de Bravo", add
label define munimxlbl 20377 "Santa Cruz Itundujia", add
label define munimxlbl 20378 "Santa Cruz Mixtepec", add
label define munimxlbl 20379 "Santa Cruz Nundaco", add
label define munimxlbl 20380 "Santa Cruz Papalutla", add
label define munimxlbl 20381 "Santa Cruz Tacache de Mina", add
label define munimxlbl 20382 "Santa Cruz Tacahua", add
label define munimxlbl 20383 "Santa Cruz Tayata", add
label define munimxlbl 20384 "Santa Cruz Xitla", add
label define munimxlbl 20385 "Santa Cruz Xoxocotlan", add
label define munimxlbl 20386 "Santa Cruz Zenzontepec", add
label define munimxlbl 20387 "Santa Gertrudis", add
label define munimxlbl 20388 "Santa Ines del Monte", add
label define munimxlbl 20389 "Santa Ines Yatzeche", add
label define munimxlbl 20390 "Santa Lucia del Camino", add
label define munimxlbl 20391 "Santa Lucia Miahuatlan", add
label define munimxlbl 20392 "Santa Lucia Monteverde", add
label define munimxlbl 20393 "Santa Lucia Ocotlan", add
label define munimxlbl 20394 "Santa Maria Alotepec", add
label define munimxlbl 20395 "Santa Maria Apazco", add
label define munimxlbl 20396 "Santa Maria la Asuncion", add
label define munimxlbl 20397 "Heroica Ciudad de Tlaxiaco", add
label define munimxlbl 20398 "Ayoquezco de Aldama", add
label define munimxlbl 20399 "Santa Maria Atzompa", add
label define munimxlbl 20400 "Santa Maria Camotlan", add
label define munimxlbl 20401 "Santa Maria Colotepec", add
label define munimxlbl 20402 "Santa Maria Cortijo", add
label define munimxlbl 20403 "Santa Maria Coyotepec", add
label define munimxlbl 20404 "Santa Maria Chachoapam", add
label define munimxlbl 20405 "Villa de Chilapa de Diaz", add
label define munimxlbl 20406 "Santa Maria Chilchotla", add
label define munimxlbl 20407 "Santa Maria Chimalapa", add
label define munimxlbl 20408 "Santa Maria del Rosario", add
label define munimxlbl 20409 "Santa Maria del Tule", add
label define munimxlbl 20410 "Santa Maria Ecatepec", add
label define munimxlbl 20411 "Santa Maria Guelace", add
label define munimxlbl 20412 "Santa Maria Guienagati", add
label define munimxlbl 20413 "Santa Maria Huatulco", add
label define munimxlbl 20414 "Santa Maria Huazolotitlan", add
label define munimxlbl 20415 "Santa Maria Ipalapa", add
label define munimxlbl 20416 "Santa Maria Ixcatlan", add
label define munimxlbl 20417 "Santa Maria Jacatepec", add
label define munimxlbl 20418 "Santa Maria Jalapa del Marques", add
label define munimxlbl 20419 "Santa Maria Jaltianguis", add
label define munimxlbl 20420 "Santa Maria Lachixio", add
label define munimxlbl 20421 "Santa Maria Mixtequilla", add
label define munimxlbl 20422 "Santa Maria Nativitas", add
label define munimxlbl 20423 "Santa Maria Nduayaco", add
label define munimxlbl 20424 "Santa Maria Ozolotepec", add
label define munimxlbl 20425 "Santa Maria Papalo", add
label define munimxlbl 20426 "Santa Maria Penoles", add
label define munimxlbl 20427 "Santa Maria Petapa", add
label define munimxlbl 20428 "Santa Maria Quiegolani", add
label define munimxlbl 20429 "Santa Maria Sola", add
label define munimxlbl 20430 "Santa Maria Tataltepec", add
label define munimxlbl 20431 "Santa Maria Tecomavaca", add
label define munimxlbl 20432 "Santa Maria Temaxcalapa", add
label define munimxlbl 20433 "Santa Maria Temaxcaltepec", add
label define munimxlbl 20434 "Santa Maria Teopoxco", add
label define munimxlbl 20435 "Santa Maria Tepantlali", add
label define munimxlbl 20436 "Santa Maria Texcatitlan", add
label define munimxlbl 20437 "Santa Maria Tlahuitoltepec", add
label define munimxlbl 20438 "Santa Maria Tlalixtac", add
label define munimxlbl 20439 "Santa Maria Tonameca", add
label define munimxlbl 20440 "Santa Maria Totolapilla", add
label define munimxlbl 20441 "Santa Maria Xadani", add
label define munimxlbl 20442 "Santa Maria Yalina", add
label define munimxlbl 20443 "Santa Maria Yavesia", add
label define munimxlbl 20444 "Santa Maria Yolotepec", add
label define munimxlbl 20445 "Santa Maria Yosoyua", add
label define munimxlbl 20446 "Santa Maria Yucuhiti", add
label define munimxlbl 20447 "Santa Maria Zacatepec", add
label define munimxlbl 20448 "Santa Maria Zaniza", add
label define munimxlbl 20449 "Santa Maria Zoquitlan", add
label define munimxlbl 20450 "Santiago Amoltepec", add
label define munimxlbl 20451 "Santiago Apoala", add
label define munimxlbl 20452 "Santiago Apostol", add
label define munimxlbl 20453 "Santiago Astata", add
label define munimxlbl 20454 "Santiago Atitlan", add
label define munimxlbl 20455 "Santiago Ayuquililla", add
label define munimxlbl 20456 "Santiago Cacaloxtepec", add
label define munimxlbl 20457 "Santiago Camotlan", add
label define munimxlbl 20458 "Santiago Comaltepec", add
label define munimxlbl 20459 "Santiago Chazumba", add
label define munimxlbl 20460 "Santiago Choapam", add
label define munimxlbl 20461 "Santiago del Rio", add
label define munimxlbl 20462 "Santiago Huajolotitlan", add
label define munimxlbl 20463 "Santiago Huauclilla", add
label define munimxlbl 20464 "Santiago Ihuitlan Plumas", add
label define munimxlbl 20465 "Santiago Ixcuintepec", add
label define munimxlbl 20466 "Santiago Ixtayutla", add
label define munimxlbl 20467 "Santiago Jamiltepec", add
label define munimxlbl 20468 "Santiago Jocotepec", add
label define munimxlbl 20469 "Santiago Juxtlahuaca", add
label define munimxlbl 20470 "Santiago Lachiguiri", add
label define munimxlbl 20471 "Santiago Lalopa", add
label define munimxlbl 20472 "Santiago Laollaga", add
label define munimxlbl 20473 "Santiago Laxopa", add
label define munimxlbl 20474 "Santiago Llano Grande", add
label define munimxlbl 20475 "Santiago Matatlan", add
label define munimxlbl 20476 "Santiago Miltepec", add
label define munimxlbl 20477 "Santiago Minas", add
label define munimxlbl 20478 "Santiago Nacaltepec", add
label define munimxlbl 20479 "Santiago Nejapilla", add
label define munimxlbl 20480 "Santiago Nundiche", add
label define munimxlbl 20481 "Santiago Nuyoo", add
label define munimxlbl 20482 "Santiago Pinotepa Nacional", add
label define munimxlbl 20483 "Santiago Suchilquitongo", add
label define munimxlbl 20484 "Santiago Tamazola", add
label define munimxlbl 20485 "Santiago Tapextla", add
label define munimxlbl 20486 "Villa Tejupam de la Union", add
label define munimxlbl 20487 "Santiago Tenango", add
label define munimxlbl 20488 "Santiago Tepetlapa", add
label define munimxlbl 20489 "Santiago Tetepec", add
label define munimxlbl 20490 "Santiago Texcalcingo", add
label define munimxlbl 20491 "Santiago Textitlan", add
label define munimxlbl 20492 "Santiago Tilantongo", add
label define munimxlbl 20493 "Santiago Tillo", add
label define munimxlbl 20494 "Santiago Tlazoyaltepec", add
label define munimxlbl 20495 "Santiago Xanica", add
label define munimxlbl 20496 "Santiago Xiacui", add
label define munimxlbl 20497 "Santiago Yaitepec", add
label define munimxlbl 20498 "Santiago Yaveo", add
label define munimxlbl 20499 "Santiago Yolomecatl", add
label define munimxlbl 20500 "Santiago Yosondua", add
label define munimxlbl 20501 "Santiago Yucuyachi", add
label define munimxlbl 20502 "Santiago Zacatepec", add
label define munimxlbl 20503 "Santiago Zoochila", add
label define munimxlbl 20504 "Nuevo Zoquiapam", add
label define munimxlbl 20505 "Santo Domingo Ingenio", add
label define munimxlbl 20506 "Santo Domingo Albarradas", add
label define munimxlbl 20507 "Santo Domingo Armenta", add
label define munimxlbl 20508 "Santo Domingo Chihuitan", add
label define munimxlbl 20509 "Santo Domingo de Morelos", add
label define munimxlbl 20510 "Santo Domingo Ixcatlan", add
label define munimxlbl 20511 "Santo Domingo Nuxaa", add
label define munimxlbl 20512 "Santo Domingo Ozolotepec", add
label define munimxlbl 20513 "Santo Domingo Petapa", add
label define munimxlbl 20514 "Santo Domingo Roayaga", add
label define munimxlbl 20515 "Santo Domingo Tehuantepec", add
label define munimxlbl 20516 "Santo Domingo Teojomulco", add
label define munimxlbl 20517 "Santo Domingo Tepuxtepec", add
label define munimxlbl 20518 "Santo Domingo Tlatayapam", add
label define munimxlbl 20519 "Santo Domingo Tomaltepec", add
label define munimxlbl 20520 "Santo Domingo Tonala", add
label define munimxlbl 20521 "Santo Domingo Tonaltepec", add
label define munimxlbl 20522 "Santo Domingo Xagacia", add
label define munimxlbl 20523 "Santo Domingo Yanhuitlan", add
label define munimxlbl 20524 "Santo Domingo Yodohino", add
label define munimxlbl 20525 "Santo Domingo Zanatepec", add
label define munimxlbl 20526 "Santos Reyes Nopala", add
label define munimxlbl 20527 "Santos Reyes papalo", add
label define munimxlbl 20528 "Santos Reyes Tepejillo", add
label define munimxlbl 20529 "Santos Reyes Yucuna", add
label define munimxlbl 20530 "Santo Tomas Jalieza", add
label define munimxlbl 20531 "Santo Tomas Mazaltepec", add
label define munimxlbl 20532 "Santo Tomas Ocotepec", add
label define munimxlbl 20533 "Santo Tomas Tamazulapan", add
label define munimxlbl 20534 "San Vicente Coatlan", add
label define munimxlbl 20535 "San Vicente Lachixio", add
label define munimxlbl 20536 "San Vicente Nunu", add
label define munimxlbl 20537 "Silacayoapam", add
label define munimxlbl 20538 "Sitio de Xitlapehua", add
label define munimxlbl 20539 "Soledad Etla", add
label define munimxlbl 20540 "Villa de Tamazulapam del Progreso", add
label define munimxlbl 20541 "Tanetze de Zaragoza", add
label define munimxlbl 20542 "Taniche", add
label define munimxlbl 20543 "Tataltepec de Valdes", add
label define munimxlbl 20544 "Teococuilco de Marcos Perez", add
label define munimxlbl 20545 "Teotitlan de Flores Magon", add
label define munimxlbl 20546 "Teotitlan del Valle", add
label define munimxlbl 20547 "Teotongo", add
label define munimxlbl 20548 "Tepelmeme Villa de Morelos", add
label define munimxlbl 20549 "Tezoatlan de Segura y Luna", add
label define munimxlbl 20550 "San Jeronimo Tlacochahuaya", add
label define munimxlbl 20551 "Tlacolula de Matamoros", add
label define munimxlbl 20552 "Tlacotepec Plumas", add
label define munimxlbl 20553 "Tlalixtac de Cabrera", add
label define munimxlbl 20554 "Totontepec Villa de Morelos", add
label define munimxlbl 20555 "Trinidad Zaachila", add
label define munimxlbl 20556 "Trinidad Vista Hermosa, La", add
label define munimxlbl 20557 "Union Hidalgo", add
label define munimxlbl 20558 "Valerio Trujano", add
label define munimxlbl 20559 "San Juan Bautista Valle Nacional", add
label define munimxlbl 20560 "Villa Diaz Ordaz", add
label define munimxlbl 20561 "Yaxe", add
label define munimxlbl 20562 "Magdalena Yodocono de Porfirio Diaz", add
label define munimxlbl 20563 "Yogana", add
label define munimxlbl 20564 "Yutanduchi de Guerrero", add
label define munimxlbl 20565 "Villa de Zaachila", add
label define munimxlbl 20566 "Zapotitlan del Rio", add
label define munimxlbl 20567 "Zapotitlan Lagunas", add
label define munimxlbl 20568 "Zapotitlan Palmas", add
label define munimxlbl 20569 "Santa ines de Zaragoza", add
label define munimxlbl 20570 "Zimatlan de Alvarez", add
label define munimxlbl 21001 "Acajete", add
label define munimxlbl 21002 "Acateno", add
label define munimxlbl 21003 "Acatlan", add
label define munimxlbl 21004 "Acatzingo", add
label define munimxlbl 21005 "Acteopan", add
label define munimxlbl 21006 "Ahuacatlan", add
label define munimxlbl 21007 "Ahuatlan", add
label define munimxlbl 21008 "Ahuazotepec", add
label define munimxlbl 21009 "Ahuehuetitla", add
label define munimxlbl 21010 "Ajalpan", add
label define munimxlbl 21011 "Albino Zertuche", add
label define munimxlbl 21012 "Aljojuca", add
label define munimxlbl 21013 "Altepexi", add
label define munimxlbl 21014 "Amixtlan", add
label define munimxlbl 21015 "Amozoc", add
label define munimxlbl 21016 "Aquixtla", add
label define munimxlbl 21017 "Atempan", add
label define munimxlbl 21018 "Atexcal", add
label define munimxlbl 21019 "Atlixco", add
label define munimxlbl 21020 "Atoyatempan", add
label define munimxlbl 21021 "Atzala", add
label define munimxlbl 21022 "Atzitzihuacan", add
label define munimxlbl 21023 "Atzitzintla", add
label define munimxlbl 21024 "Axutla", add
label define munimxlbl 21025 "Ayotoxco de Guerrero", add
label define munimxlbl 21026 "Calpan", add
label define munimxlbl 21027 "Caltepec", add
label define munimxlbl 21028 "Camocuautla", add
label define munimxlbl 21029 "Caxhuacan", add
label define munimxlbl 21030 "Coatepec", add
label define munimxlbl 21031 "Coatzingo", add
label define munimxlbl 21032 "Cohetzala", add
label define munimxlbl 21033 "Cohuecan", add
label define munimxlbl 21034 "Coronango", add
label define munimxlbl 21035 "Coxcatlan", add
label define munimxlbl 21036 "Coyomeapan", add
label define munimxlbl 21037 "Coyotepec", add
label define munimxlbl 21038 "Cuapiaxtla de Madero", add
label define munimxlbl 21039 "Cuautempan", add
label define munimxlbl 21040 "Cuautinchan", add
label define munimxlbl 21041 "Cuautlancingo", add
label define munimxlbl 21042 "Cuayuca de Andrade", add
label define munimxlbl 21043 "Cuetzalan del Progreso", add
label define munimxlbl 21044 "Cuyoaco", add
label define munimxlbl 21045 "Chalchicomula de Sesma", add
label define munimxlbl 21046 "Chapulco", add
label define munimxlbl 21047 "Chiautla", add
label define munimxlbl 21048 "Chiautzingo", add
label define munimxlbl 21049 "Chiconcuautla", add
label define munimxlbl 21050 "Chichiquila", add
label define munimxlbl 21051 "Chietla", add
label define munimxlbl 21052 "Chigmecatitlan", add
label define munimxlbl 21053 "Chignahuapan", add
label define munimxlbl 21054 "Chignautla", add
label define munimxlbl 21055 "Chila", add
label define munimxlbl 21056 "Chila de la Sal", add
label define munimxlbl 21057 "Honey", add
label define munimxlbl 21058 "Chilchotla", add
label define munimxlbl 21059 "Chinantla", add
label define munimxlbl 21060 "Domingo Arenas", add
label define munimxlbl 21061 "Eloxochitlan", add
label define munimxlbl 21062 "Epatlan", add
label define munimxlbl 21063 "Esperanza", add
label define munimxlbl 21064 "Francisco Z. Mena", add
label define munimxlbl 21065 "General Felipe Angeles", add
label define munimxlbl 21066 "Guadalupe", add
label define munimxlbl 21067 "Guadalupe Victoria", add
label define munimxlbl 21068 "Hermenegildo Galeana", add
label define munimxlbl 21069 "Huaquechula", add
label define munimxlbl 21070 "Huatlatlauca", add
label define munimxlbl 21071 "Huauchinango", add
label define munimxlbl 21072 "Huehuetla", add
label define munimxlbl 21073 "Huehuetlan el Chico", add
label define munimxlbl 21074 "Huejotzingo", add
label define munimxlbl 21075 "Hueyapan", add
label define munimxlbl 21076 "Hueytamalco", add
label define munimxlbl 21077 "Hueytlalpan", add
label define munimxlbl 21078 "Huitzilan de Serdan", add
label define munimxlbl 21079 "Huitziltepec", add
label define munimxlbl 21080 "Atlequizayan", add
label define munimxlbl 21081 "Ixcamilpa de Guerrero", add
label define munimxlbl 21082 "Ixcaquixtla", add
label define munimxlbl 21083 "Ixtacamaxtitlan", add
label define munimxlbl 21084 "Ixtepec", add
label define munimxlbl 21085 "Izucar de Matamoros", add
label define munimxlbl 21086 "Jalpan", add
label define munimxlbl 21087 "Jolalpan", add
label define munimxlbl 21088 "Jonotla", add
label define munimxlbl 21089 "Jopala", add
label define munimxlbl 21090 "Juan C. Bonilla", add
label define munimxlbl 21091 "Juan Galindo", add
label define munimxlbl 21092 "Juan N. Mendez", add
label define munimxlbl 21093 "Lafragua", add
label define munimxlbl 21094 "Libres", add
label define munimxlbl 21095 "Magdalena Tlatlauquitepec, La", add
label define munimxlbl 21096 "Mazapiltepec de Juarez", add
label define munimxlbl 21097 "Mixtla", add
label define munimxlbl 21098 "Molcaxac", add
label define munimxlbl 21099 "Canada Morelos", add
label define munimxlbl 21100 "Naupan", add
label define munimxlbl 21101 "Nauzontla", add
label define munimxlbl 21102 "Nealtican", add
label define munimxlbl 21103 "Nicolas Bravo", add
label define munimxlbl 21104 "Nopalucan", add
label define munimxlbl 21105 "Ocotepec", add
label define munimxlbl 21106 "Ocoyucan", add
label define munimxlbl 21107 "Olintla", add
label define munimxlbl 21108 "Oriental", add
label define munimxlbl 21109 "Pahuatlan", add
label define munimxlbl 21110 "Palmar de Bravo", add
label define munimxlbl 21111 "Pantepec", add
label define munimxlbl 21112 "Petlalcingo", add
label define munimxlbl 21113 "Piaxtla", add
label define munimxlbl 21114 "Puebla", add
label define munimxlbl 21115 "Quecholac", add
label define munimxlbl 21116 "Quimixtlan", add
label define munimxlbl 21117 "Rafael Lara Grajales", add
label define munimxlbl 21118 "Reyes de Juarez, Los", add
label define munimxlbl 21119 "San Andres Cholula", add
label define munimxlbl 21120 "San Antonio Canada", add
label define munimxlbl 21121 "San Diego la Mesa Tochimiltzingo", add
label define munimxlbl 21122 "San Felipe Teotlalcingo", add
label define munimxlbl 21123 "San Felipe Tepatlan", add
label define munimxlbl 21124 "San Gabriel Chilac", add
label define munimxlbl 21125 "San Gregorio Atzompa", add
label define munimxlbl 21126 "San Jeronimo Tecuanipan", add
label define munimxlbl 21127 "San Jeronimo Xayacatlan", add
label define munimxlbl 21128 "San Jose Chiapa", add
label define munimxlbl 21129 "San Jose Miahuatlan", add
label define munimxlbl 21130 "San Juan Atenco", add
label define munimxlbl 21131 "San Juan Atzompa", add
label define munimxlbl 21132 "San Martin Texmelucan", add
label define munimxlbl 21133 "San Martin Totoltepec", add
label define munimxlbl 21134 "San Matias Tlalancaleca", add
label define munimxlbl 21135 "San Miguel Ixitlan", add
label define munimxlbl 21136 "San Miguel Xoxtla", add
label define munimxlbl 21137 "San Nicolas Buenos Aires", add
label define munimxlbl 21138 "San Nicolas de los Ranchos", add
label define munimxlbl 21139 "San Pablo Anicano", add
label define munimxlbl 21140 "San Pedro Cholula", add
label define munimxlbl 21141 "San Pedro Yeloixtlahuaca", add
label define munimxlbl 21142 "San Salvador el Seco", add
label define munimxlbl 21143 "San Salvador el Verde", add
label define munimxlbl 21144 "San Salvador Huixcolotla", add
label define munimxlbl 21145 "San Sebastian Tlacotepec", add
label define munimxlbl 21146 "Santa Catarina Tlaltempan", add
label define munimxlbl 21147 "Santa Ines Ahuatempan", add
label define munimxlbl 21148 "Santa Isabel Cholula", add
label define munimxlbl 21149 "Santiago Miahuatlan", add
label define munimxlbl 21150 "Huehuetlan el Grande", add
label define munimxlbl 21151 "Santo Tomas Hueyotlipan", add
label define munimxlbl 21152 "Soltepec", add
label define munimxlbl 21153 "Tecali de Herrera", add
label define munimxlbl 21154 "Tecamachalco", add
label define munimxlbl 21155 "Tecomatlan", add
label define munimxlbl 21156 "Tehuacan", add
label define munimxlbl 21157 "Tehuitzingo", add
label define munimxlbl 21158 "Tenampulco", add
label define munimxlbl 21159 "Teopantlan", add
label define munimxlbl 21160 "Teotlalco", add
label define munimxlbl 21161 "Tepanco de Lopez", add
label define munimxlbl 21162 "Tepango de Rodriguez", add
label define munimxlbl 21163 "Tepatlaxco de Hidalgo", add
label define munimxlbl 21164 "Tepeaca", add
label define munimxlbl 21165 "Tepemaxalco", add
label define munimxlbl 21166 "Tepeojuma", add
label define munimxlbl 21167 "Tepetzintla", add
label define munimxlbl 21168 "Tepexco", add
label define munimxlbl 21169 "Tepexi de Rodriguez", add
label define munimxlbl 21170 "Tepeyahualco", add
label define munimxlbl 21171 "Tepeyahualco de Cuauhtemoc", add
label define munimxlbl 21172 "Tetela de Ocampo", add
label define munimxlbl 21173 "Teteles de Avila Castillo", add
label define munimxlbl 21174 "Teziutlan", add
label define munimxlbl 21175 "Tianguismanalco", add
label define munimxlbl 21176 "Tilapa", add
label define munimxlbl 21177 "Tlacotepec de Benito Juarez", add
label define munimxlbl 21178 "Tlacuilotepec", add
label define munimxlbl 21179 "Tlachichuca", add
label define munimxlbl 21180 "Tlahuapan", add
label define munimxlbl 21181 "Tlaltenango", add
label define munimxlbl 21182 "Tlanepantla", add
label define munimxlbl 21183 "Tlaola", add
label define munimxlbl 21184 "Tlapacoya", add
label define munimxlbl 21185 "Tlapanala", add
label define munimxlbl 21186 "Tlatlauquitepec", add
label define munimxlbl 21187 "Tlaxco", add
label define munimxlbl 21188 "Tochimilco", add
label define munimxlbl 21189 "Tochtepec", add
label define munimxlbl 21190 "Totoltepec de Guerrero", add
label define munimxlbl 21191 "Tulcingo", add
label define munimxlbl 21192 "Tuzamapan de Galeana", add
label define munimxlbl 21193 "Tzicatlacoyan", add
label define munimxlbl 21194 "Venustiano Carranza", add
label define munimxlbl 21195 "Vicente Guerrero", add
label define munimxlbl 21196 "Xayacatlan de Bravo", add
label define munimxlbl 21197 "Xicotepec", add
label define munimxlbl 21198 "Xicotlan", add
label define munimxlbl 21199 "Xiutetelco", add
label define munimxlbl 21200 "Xochiapulco", add
label define munimxlbl 21201 "Xochiltepec", add
label define munimxlbl 21202 "Xochitlan de Vicente Suarez", add
label define munimxlbl 21203 "Xochitlan Todos Santos", add
label define munimxlbl 21204 "Yaonahuac", add
label define munimxlbl 21205 "Yehualtepec", add
label define munimxlbl 21206 "Zacapala", add
label define munimxlbl 21207 "Zacapoaxtla", add
label define munimxlbl 21208 "Zacatlan", add
label define munimxlbl 21209 "Zapotitlan", add
label define munimxlbl 21210 "Zapotitlan de Mendez", add
label define munimxlbl 21211 "Zaragoza", add
label define munimxlbl 21212 "Zautla", add
label define munimxlbl 21213 "Zihuateutla", add
label define munimxlbl 21214 "Zinacatepec", add
label define munimxlbl 21215 "Zongozotla", add
label define munimxlbl 21216 "Zoquiapan", add
label define munimxlbl 21217 "Zoquitlan", add
label define munimxlbl 22001 "Amealco de Bonfil", add
label define munimxlbl 22002 "Pinal de Amoles", add
label define munimxlbl 22003 "Arroyo Seco", add
label define munimxlbl 22004 "Cadereyta de Montes", add
label define munimxlbl 22005 "Colon", add
label define munimxlbl 22006 "Corregidora", add
label define munimxlbl 22007 "Ezequiel Montes", add
label define munimxlbl 22008 "Huimilpan", add
label define munimxlbl 22009 "Jalpan de Serra", add
label define munimxlbl 22010 "Landa de Matamoros", add
label define munimxlbl 22011 "Marques, El", add
label define munimxlbl 22012 "Pedro Escobedo", add
label define munimxlbl 22013 "Penamiller", add
label define munimxlbl 22014 "Queretaro", add
label define munimxlbl 22015 "San Joaquin", add
label define munimxlbl 22016 "San Juan del Rio", add
label define munimxlbl 22017 "Tequisquiapan", add
label define munimxlbl 22018 "Toliman", add
label define munimxlbl 23001 "Cozumel", add
label define munimxlbl 23002 "Felipe Carrillo Puerto", add
label define munimxlbl 23003 "Isla Mujeres", add
label define munimxlbl 23004 "Othon p. Blanco", add
label define munimxlbl 23005 "Benito Juarez", add
label define munimxlbl 23006 "Jose Maria Morelos", add
label define munimxlbl 23007 "Lazaro Cardenas", add
label define munimxlbl 23008 "Solidaridad", add
label define munimxlbl 24001 "Ahualulco", add
label define munimxlbl 24002 "Alaquines", add
label define munimxlbl 24003 "Aquismon", add
label define munimxlbl 24004 "Armadillo de los Infante", add
label define munimxlbl 24005 "Cardenas", add
label define munimxlbl 24006 "Catorce", add
label define munimxlbl 24007 "Cedral", add
label define munimxlbl 24008 "Cerritos", add
label define munimxlbl 24009 "Cerro de San Pedro", add
label define munimxlbl 24010 "Ciudad del Maiz", add
label define munimxlbl 24011 "Ciudad Fernandez", add
label define munimxlbl 24012 "Tancanhuitz de Santos", add
label define munimxlbl 24013 "Ciudad Valles", add
label define munimxlbl 24014 "Coxcatlan", add
label define munimxlbl 24015 "Charcas", add
label define munimxlbl 24016 "Ebano", add
label define munimxlbl 24017 "Guadalcazar", add
label define munimxlbl 24018 "Huehuetlan", add
label define munimxlbl 24019 "Lagunillas", add
label define munimxlbl 24020 "Matehuala", add
label define munimxlbl 24021 "Mexquitic de Carmona", add
label define munimxlbl 24022 "Moctezuma", add
label define munimxlbl 24023 "Rayon", add
label define munimxlbl 24024 "Rioverde", add
label define munimxlbl 24025 "Salinas", add
label define munimxlbl 24026 "San Antonio", add
label define munimxlbl 24027 "San Ciro de Acosta", add
label define munimxlbl 24028 "San Luis Potosi", add
label define munimxlbl 24029 "San Martin Chalchicuautla", add
label define munimxlbl 24030 "San Nicolas Tolentino", add
label define munimxlbl 24031 "Santa Catarina", add
label define munimxlbl 24032 "Santa Maria del Rio", add
label define munimxlbl 24033 "Santo Domingo", add
label define munimxlbl 24034 "San Vicente Tancuayalab", add
label define munimxlbl 24035 "Soledad de Graciano Sanchez", add
label define munimxlbl 24036 "Tamasopo", add
label define munimxlbl 24037 "Tamazunchale", add
label define munimxlbl 24038 "Tampacan", add
label define munimxlbl 24039 "Tampamolon Corona", add
label define munimxlbl 24040 "Tamuin", add
label define munimxlbl 24041 "Tanlajas", add
label define munimxlbl 24042 "Tanquian de Escobedo", add
label define munimxlbl 24043 "Tierra Nueva", add
label define munimxlbl 24044 "Vanegas", add
label define munimxlbl 24045 "Venado", add
label define munimxlbl 24046 "Villa de Arriaga", add
label define munimxlbl 24047 "Villa de Guadalupe", add
label define munimxlbl 24048 "Villa de la Paz", add
label define munimxlbl 24049 "Villa de Ramos", add
label define munimxlbl 24050 "Villa de Reyes", add
label define munimxlbl 24051 "Villa Hidalgo", add
label define munimxlbl 24052 "Villa Juarez", add
label define munimxlbl 24053 "Axtla de Terrazas", add
label define munimxlbl 24054 "Xilitla", add
label define munimxlbl 24055 "Zaragoza", add
label define munimxlbl 24056 "Villa de Arista", add
label define munimxlbl 24057 "Matlapa", add
label define munimxlbl 24058 "Naranjo, El", add
label define munimxlbl 25001 "Ahome", add
label define munimxlbl 25002 "Angostura", add
label define munimxlbl 25003 "Badiraguato", add
label define munimxlbl 25004 "Concordia", add
label define munimxlbl 25005 "Cosala", add
label define munimxlbl 25006 "Culiacan", add
label define munimxlbl 25007 "Choix", add
label define munimxlbl 25008 "Elota", add
label define munimxlbl 25009 "Escuinapa", add
label define munimxlbl 25010 "Fuerte, El", add
label define munimxlbl 25011 "Guasave", add
label define munimxlbl 25012 "Mazatlan", add
label define munimxlbl 25013 "Mocorito", add
label define munimxlbl 25014 "Rosario", add
label define munimxlbl 25015 "Salvador Alvarado", add
label define munimxlbl 25016 "San Ignacio", add
label define munimxlbl 25017 "Sinaloa", add
label define munimxlbl 25018 "Navolato", add
label define munimxlbl 26001 "Aconchi", add
label define munimxlbl 26002 "Agua prieta", add
label define munimxlbl 26003 "Alamos", add
label define munimxlbl 26004 "Altar", add
label define munimxlbl 26005 "Arivechi", add
label define munimxlbl 26006 "Arizpe", add
label define munimxlbl 26007 "Atil", add
label define munimxlbl 26008 "Bacadehuachi", add
label define munimxlbl 26009 "Bacanora", add
label define munimxlbl 26010 "Bacerac", add
label define munimxlbl 26011 "Bacoachi", add
label define munimxlbl 26012 "Bacum", add
label define munimxlbl 26013 "Banamichi", add
label define munimxlbl 26014 "Baviacora", add
label define munimxlbl 26015 "Bavispe", add
label define munimxlbl 26016 "Benjamin Hill", add
label define munimxlbl 26017 "Caborca", add
label define munimxlbl 26018 "Cajeme", add
label define munimxlbl 26019 "Cananea", add
label define munimxlbl 26020 "Carbo", add
label define munimxlbl 26021 "Colorada, La", add
label define munimxlbl 26022 "Cucurpe", add
label define munimxlbl 26023 "Cumpas", add
label define munimxlbl 26024 "Divisaderos", add
label define munimxlbl 26025 "Empalme", add
label define munimxlbl 26026 "Etchojoa", add
label define munimxlbl 26027 "Fronteras", add
label define munimxlbl 26028 "Granados", add
label define munimxlbl 26029 "Guaymas", add
label define munimxlbl 26030 "Hermosillo", add
label define munimxlbl 26031 "Huachinera", add
label define munimxlbl 26032 "Huasabas", add
label define munimxlbl 26033 "Huatabampo", add
label define munimxlbl 26034 "Huepac", add
label define munimxlbl 26035 "Imuris", add
label define munimxlbl 26036 "Magdalena", add
label define munimxlbl 26037 "Mazatan", add
label define munimxlbl 26038 "Moctezuma", add
label define munimxlbl 26039 "Naco", add
label define munimxlbl 26040 "Nacori Chico", add
label define munimxlbl 26041 "Nacozari de Garcia", add
label define munimxlbl 26042 "Navojoa", add
label define munimxlbl 26043 "Nogales", add
label define munimxlbl 26044 "Onavas", add
label define munimxlbl 26045 "Opodepe", add
label define munimxlbl 26046 "Oquitoa", add
label define munimxlbl 26047 "Pitiquito", add
label define munimxlbl 26048 "Puerto Penasco", add
label define munimxlbl 26049 "Quiriego", add
label define munimxlbl 26050 "Rayon", add
label define munimxlbl 26051 "Rosario", add
label define munimxlbl 26052 "Sahuaripa", add
label define munimxlbl 26053 "San Felipe de Jesus", add
label define munimxlbl 26054 "San javier", add
label define munimxlbl 26055 "San Luis Rio Colorado", add
label define munimxlbl 26056 "San Miguel de Horcasitas", add
label define munimxlbl 26057 "San Pedro de la Cueva", add
label define munimxlbl 26058 "Santa Ana", add
label define munimxlbl 26059 "Santa Cruz", add
label define munimxlbl 26060 "Saric", add
label define munimxlbl 26061 "Soyopa", add
label define munimxlbl 26062 "Suaqui Grande", add
label define munimxlbl 26063 "Tepache", add
label define munimxlbl 26064 "Trincheras", add
label define munimxlbl 26065 "Tubutama", add
label define munimxlbl 26066 "Ures", add
label define munimxlbl 26067 "Villa Hidalgo", add
label define munimxlbl 26068 "Villa Pesqueira", add
label define munimxlbl 26069 "Yecora", add
label define munimxlbl 26070 "General Plutarco Elias Calles", add
label define munimxlbl 26071 "Benito Juarez", add
label define munimxlbl 26072 "San Ignacio Rio Muerto", add
label define munimxlbl 27001 "Balancan", add
label define munimxlbl 27002 "Cardenas", add
label define munimxlbl 27003 "Centla", add
label define munimxlbl 27004 "Centro", add
label define munimxlbl 27005 "Comalcalco", add
label define munimxlbl 27006 "Cunduacan", add
label define munimxlbl 27007 "Emiliano Zapata", add
label define munimxlbl 27008 "Huimanguillo", add
label define munimxlbl 27009 "Jalapa", add
label define munimxlbl 27010 "Jalpa de Mendez", add
label define munimxlbl 27011 "Jonuta", add
label define munimxlbl 27012 "Macuspana", add
label define munimxlbl 27013 "Nacajuca", add
label define munimxlbl 27014 "Paraiso", add
label define munimxlbl 27015 "Tacotalpa", add
label define munimxlbl 27016 "Teapa", add
label define munimxlbl 27017 "Tenosique", add
label define munimxlbl 28001 "Abasolo", add
label define munimxlbl 28002 "Aldama", add
label define munimxlbl 28003 "Altamira", add
label define munimxlbl 28004 "Antiguo Morelos", add
label define munimxlbl 28005 "Burgos", add
label define munimxlbl 28006 "Bustamante", add
label define munimxlbl 28007 "Camargo", add
label define munimxlbl 28008 "Casas", add
label define munimxlbl 28009 "Ciudad Madero", add
label define munimxlbl 28010 "Cruillas", add
label define munimxlbl 28011 "Gomez Farias", add
label define munimxlbl 28012 "Gonzalez", add
label define munimxlbl 28013 "Guemez", add
label define munimxlbl 28014 "Guerrero", add
label define munimxlbl 28015 "Gustavo Diaz Ordaz", add
label define munimxlbl 28016 "Hidalgo", add
label define munimxlbl 28017 "Jaumave", add
label define munimxlbl 28018 "Jimenez", add
label define munimxlbl 28019 "Llera", add
label define munimxlbl 28020 "Mainero", add
label define munimxlbl 28021 "Mante, El", add
label define munimxlbl 28022 "Matamoros", add
label define munimxlbl 28023 "Mendez", add
label define munimxlbl 28024 "Mier", add
label define munimxlbl 28025 "Miguel Aleman", add
label define munimxlbl 28026 "Miquihuana", add
label define munimxlbl 28027 "Nuevo Laredo", add
label define munimxlbl 28028 "Nuevo Morelos", add
label define munimxlbl 28029 "Ocampo", add
label define munimxlbl 28030 "Padilla", add
label define munimxlbl 28031 "Palmillas", add
label define munimxlbl 28032 "Reynosa", add
label define munimxlbl 28033 "Rio Bravo", add
label define munimxlbl 28034 "San Carlos", add
label define munimxlbl 28035 "San Fernando", add
label define munimxlbl 28036 "San Nicolas", add
label define munimxlbl 28037 "Soto la Marina", add
label define munimxlbl 28038 "Tampico", add
label define munimxlbl 28039 "Tula", add
label define munimxlbl 28040 "Valle Hermoso", add
label define munimxlbl 28041 "Victoria", add
label define munimxlbl 28042 "Villagran", add
label define munimxlbl 28043 "Xicotencatl", add
label define munimxlbl 29001 "Amaxac de Guerrero", add
label define munimxlbl 29002 "Apetatitlan de Antonio Carvajal", add
label define munimxlbl 29003 "Atlangatepec", add
label define munimxlbl 29004 "Altzayanca", add
label define munimxlbl 29005 "Apizaco", add
label define munimxlbl 29006 "Calpulalpan", add
label define munimxlbl 29007 "Carmen Tequexquitla, El", add
label define munimxlbl 29008 "Cuapiaxtla", add
label define munimxlbl 29009 "Cuaxomulco", add
label define munimxlbl 29010 "Chiautempan", add
label define munimxlbl 29011 "Munoz de Domingo Arenas", add
label define munimxlbl 29012 "Espanita", add
label define munimxlbl 29013 "Huamantla", add
label define munimxlbl 29014 "Hueyotlipan", add
label define munimxlbl 29015 "Ixtacuixtla de Mariano Matamoros", add
label define munimxlbl 29016 "Ixtenco", add
label define munimxlbl 29017 "Mazatecochco de Jose Maria Morelos", add
label define munimxlbl 29018 "Contla de Juan cuamatzi", add
label define munimxlbl 29019 "Tepetitla de Lardizabal", add
label define munimxlbl 29020 "Sanctorum de Lazaro Cardenas", add
label define munimxlbl 29021 "Nanacamilpa de Mariano Arista", add
label define munimxlbl 29022 "Acuamanala de Miguel Hidalgo", add
label define munimxlbl 29023 "Nativitas", add
label define munimxlbl 29024 "Panotla", add
label define munimxlbl 29025 "San Pablo del Monte", add
label define munimxlbl 29026 "Santa Cruz Tlaxcala", add
label define munimxlbl 29027 "Tenancingo", add
label define munimxlbl 29028 "Teolocholco", add
label define munimxlbl 29029 "Tepeyanco", add
label define munimxlbl 29030 "Terrenate", add
label define munimxlbl 29031 "Tetla de la Solidaridad", add
label define munimxlbl 29032 "Tetlatlahuca", add
label define munimxlbl 29033 "Tlaxcala", add
label define munimxlbl 29034 "Tlaxco", add
label define munimxlbl 29035 "Tocatlan", add
label define munimxlbl 29036 "Totolac", add
label define munimxlbl 29037 "Zitlaltepec de Trinidad Sanchez Santos", add
label define munimxlbl 29038 "Tzompantepec", add
label define munimxlbl 29039 "Xaloztoc", add
label define munimxlbl 29040 "Xaltocan", add
label define munimxlbl 29041 "Papalotla de Xicohtencatl", add
label define munimxlbl 29042 "Xicohtzinco", add
label define munimxlbl 29043 "Yauhquemecan", add
label define munimxlbl 29044 "Zacatelco", add
label define munimxlbl 29045 "Benito Juarez", add
label define munimxlbl 29046 "Emiliano Zapata", add
label define munimxlbl 29047 "Lazaro Cardenas", add
label define munimxlbl 29048 "Magdalena Tlaltelulco, La", add
label define munimxlbl 29049 "San Damian Texoloc", add
label define munimxlbl 29050 "San Francisco Tetlanohcan", add
label define munimxlbl 29051 "San Jeronimo Zacualpan", add
label define munimxlbl 29052 "San Jose Teacalco", add
label define munimxlbl 29053 "San Juan Huactzinco", add
label define munimxlbl 29054 "San Lorenzo Axocomanitla", add
label define munimxlbl 29055 "San Lucas Tecopilco", add
label define munimxlbl 29056 "Santa Ana Nopalucan", add
label define munimxlbl 29057 "Santa Apolonia Teacalco", add
label define munimxlbl 29058 "Santa Catarina Ayometla", add
label define munimxlbl 29059 "Santa Cruz Quilehtla", add
label define munimxlbl 29060 "Santa Isabel Xiloxoxtla", add
label define munimxlbl 30001 "Acajete", add
label define munimxlbl 30002 "Acatlan", add
label define munimxlbl 30003 "Acayucan", add
label define munimxlbl 30004 "Actopan", add
label define munimxlbl 30005 "Acula", add
label define munimxlbl 30006 "Acultzingo", add
label define munimxlbl 30007 "Camaron de Tejeda", add
label define munimxlbl 30008 "Alpatlahuac", add
label define munimxlbl 30009 "Alto Lucero de Gutierrez Barrios", add
label define munimxlbl 30010 "Altotonga", add
label define munimxlbl 30011 "Alvarado", add
label define munimxlbl 30012 "Amatitlan", add
label define munimxlbl 30013 "Naranjos Amatlan", add
label define munimxlbl 30014 "Amatlan de los Reyes", add
label define munimxlbl 30015 "Angel R. Cabada", add
label define munimxlbl 30016 "Antigua, La", add
label define munimxlbl 30017 "Apazapan", add
label define munimxlbl 30018 "Aquila", add
label define munimxlbl 30019 "Astacinga", add
label define munimxlbl 30020 "Atlahuilco", add
label define munimxlbl 30021 "Atoyac", add
label define munimxlbl 30022 "Atzacan", add
label define munimxlbl 30023 "Atzalan", add
label define munimxlbl 30024 "Tlaltetela", add
label define munimxlbl 30025 "Ayahualulco", add
label define munimxlbl 30026 "Banderilla", add
label define munimxlbl 30027 "Benito Juarez", add
label define munimxlbl 30028 "Boca del Rio", add
label define munimxlbl 30029 "Calcahualco", add
label define munimxlbl 30030 "Camerino Z. Mendoza", add
label define munimxlbl 30031 "Carrillo Puerto", add
label define munimxlbl 30032 "Catemaco", add
label define munimxlbl 30033 "Cazones", add
label define munimxlbl 30034 "Cerro azul", add
label define munimxlbl 30035 "Citlaltepetl", add
label define munimxlbl 30036 "Coacoatzintla", add
label define munimxlbl 30037 "Coahuitlan", add
label define munimxlbl 30038 "Coatepec", add
label define munimxlbl 30039 "Coatzacoalcos", add
label define munimxlbl 30040 "Coatzintla", add
label define munimxlbl 30041 "Coetzala", add
label define munimxlbl 30042 "Colipa", add
label define munimxlbl 30043 "Comapa", add
label define munimxlbl 30044 "Cordoba", add
label define munimxlbl 30045 "Cosamaloapan de Carpio", add
label define munimxlbl 30046 "Cosautlan de Carvajal", add
label define munimxlbl 30047 "Coscomatepec", add
label define munimxlbl 30048 "Cosoleacaque", add
label define munimxlbl 30049 "Cotaxtla", add
label define munimxlbl 30050 "Coxquihui", add
label define munimxlbl 30051 "Coyutla", add
label define munimxlbl 30052 "Cuichapa", add
label define munimxlbl 30053 "Cuitlahuac", add
label define munimxlbl 30054 "Chacaltianguis", add
label define munimxlbl 30055 "Chalma", add
label define munimxlbl 30056 "Chiconamel", add
label define munimxlbl 30057 "Chiconquiaco", add
label define munimxlbl 30058 "Chicontepec", add
label define munimxlbl 30059 "Chinameca", add
label define munimxlbl 30060 "Chinampa de Gorostiza", add
label define munimxlbl 30061 "Choapas, Las", add
label define munimxlbl 30062 "Chocaman", add
label define munimxlbl 30063 "Chontla", add
label define munimxlbl 30064 "Chumatlan", add
label define munimxlbl 30065 "Emiliano Zapata", add
label define munimxlbl 30066 "Espinal", add
label define munimxlbl 30067 "Filomeno Mata", add
label define munimxlbl 30068 "Fortin", add
label define munimxlbl 30069 "Gutierrez Zamora", add
label define munimxlbl 30070 "Hidalgotitlan", add
label define munimxlbl 30071 "Huatusco", add
label define munimxlbl 30072 "Huayacocotla", add
label define munimxlbl 30073 "Hueyapan de Ocampo", add
label define munimxlbl 30074 "Huiloapan", add
label define munimxlbl 30075 "Ignacio de la Llave", add
label define munimxlbl 30076 "Ilamatlan", add
label define munimxlbl 30077 "Isla", add
label define munimxlbl 30078 "Ixcatepec", add
label define munimxlbl 30079 "Ixhuacan de los Reyes", add
label define munimxlbl 30080 "Ixhuatlan del Cafe", add
label define munimxlbl 30081 "Ixhuatlancillo", add
label define munimxlbl 30082 "Ixhuatlan del Sureste", add
label define munimxlbl 30083 "Ixhuatlan de Madero", add
label define munimxlbl 30084 "Ixmatlahuacan", add
label define munimxlbl 30085 "Ixtaczoquitlan", add
label define munimxlbl 30086 "Jalacingo", add
label define munimxlbl 30087 "Xalapa", add
label define munimxlbl 30088 "Jalcomulco", add
label define munimxlbl 30089 "Jaltipan", add
label define munimxlbl 30090 "Jamapa", add
label define munimxlbl 30091 "Jesus Carranza", add
label define munimxlbl 30092 "Xico", add
label define munimxlbl 30093 "Jilotepec", add
label define munimxlbl 30094 "Juan Rodriguez Clara", add
label define munimxlbl 30095 "Juchique de Ferrer", add
label define munimxlbl 30096 "Landero y Coss", add
label define munimxlbl 30097 "Lerdo de Tejada", add
label define munimxlbl 30098 "Magdalena", add
label define munimxlbl 30099 "Maltrata", add
label define munimxlbl 30100 "Manlio Fabio Altamirano", add
label define munimxlbl 30101 "Mariano Escobedo", add
label define munimxlbl 30102 "Martinez de la Torre", add
label define munimxlbl 30103 "Mecatlan", add
label define munimxlbl 30104 "Mecayapan", add
label define munimxlbl 30105 "Medellin", add
label define munimxlbl 30106 "Miahuatlan", add
label define munimxlbl 30107 "Minas, Las", add
label define munimxlbl 30108 "Minatitlan", add
label define munimxlbl 30109 "Misantla", add
label define munimxlbl 30110 "Mixtla de Altamirano", add
label define munimxlbl 30111 "Moloacan", add
label define munimxlbl 30112 "Naolinco", add
label define munimxlbl 30113 "Naranjal", add
label define munimxlbl 30114 "Nautla", add
label define munimxlbl 30115 "Nogales", add
label define munimxlbl 30116 "Oluta", add
label define munimxlbl 30117 "Omealca", add
label define munimxlbl 30118 "Orizaba", add
label define munimxlbl 30119 "Otatitlan", add
label define munimxlbl 30120 "Oteapan", add
label define munimxlbl 30121 "Ozuluama de Mascarenas", add
label define munimxlbl 30122 "Pajapan", add
label define munimxlbl 30123 "Panuco", add
label define munimxlbl 30124 "Papantla", add
label define munimxlbl 30125 "Paso del Macho", add
label define munimxlbl 30126 "Paso de Ovejas", add
label define munimxlbl 30127 "Perla, La", add
label define munimxlbl 30128 "Perote", add
label define munimxlbl 30129 "Platon Sanchez", add
label define munimxlbl 30130 "Playa Vicente", add
label define munimxlbl 30131 "Poza Rica de Hidalgo", add
label define munimxlbl 30132 "Vigas de Ramirez, Las", add
label define munimxlbl 30133 "Pueblo Viejo", add
label define munimxlbl 30134 "Puente Nacional", add
label define munimxlbl 30135 "Rafael Delgado", add
label define munimxlbl 30136 "Rafael lucio", add
label define munimxlbl 30137 "Reyes, Los", add
label define munimxlbl 30138 "Rio Blanco", add
label define munimxlbl 30139 "Saltabarranca", add
label define munimxlbl 30140 "San Andres Tenejapan", add
label define munimxlbl 30141 "San Andres Tuxtla", add
label define munimxlbl 30142 "San Juan Evangelista", add
label define munimxlbl 30143 "Santiago Tuxtla", add
label define munimxlbl 30144 "Sayula de Aleman", add
label define munimxlbl 30145 "Soconusco", add
label define munimxlbl 30146 "Sochiapa", add
label define munimxlbl 30147 "Soledad Atzompa", add
label define munimxlbl 30148 "Soledad de Doblado", add
label define munimxlbl 30149 "Soteapan", add
label define munimxlbl 30150 "Tamalin", add
label define munimxlbl 30151 "Tamiahua", add
label define munimxlbl 30152 "Tampico Alto", add
label define munimxlbl 30153 "Tancoco", add
label define munimxlbl 30154 "Tantima", add
label define munimxlbl 30155 "Tantoyuca", add
label define munimxlbl 30156 "Tatatila", add
label define munimxlbl 30157 "Castillo de Teayo", add
label define munimxlbl 30158 "Tecolutla", add
label define munimxlbl 30159 "Tehuipango", add
label define munimxlbl 30160 "Temapache", add
label define munimxlbl 30161 "Tempoal", add
label define munimxlbl 30162 "Tenampa", add
label define munimxlbl 30163 "Tenochtitlan", add
label define munimxlbl 30164 "Teocelo", add
label define munimxlbl 30165 "Tepatlaxco", add
label define munimxlbl 30166 "Tepetlan", add
label define munimxlbl 30167 "Tepetzintla", add
label define munimxlbl 30168 "Tequila", add
label define munimxlbl 30169 "Jose Azueta", add
label define munimxlbl 30170 "Texcatepec", add
label define munimxlbl 30171 "Texhuacan", add
label define munimxlbl 30172 "Texistepec", add
label define munimxlbl 30173 "Tezonapa", add
label define munimxlbl 30174 "Tierra Blanca", add
label define munimxlbl 30175 "Tihuatlan", add
label define munimxlbl 30176 "Tlacojalpan", add
label define munimxlbl 30177 "Tlacolulan", add
label define munimxlbl 30178 "Tlacotalpan", add
label define munimxlbl 30179 "Tlacotepec de Mejia", add
label define munimxlbl 30180 "Tlachichilco", add
label define munimxlbl 30181 "Tlalixcoyan", add
label define munimxlbl 30182 "Tlalnelhuayocan", add
label define munimxlbl 30183 "Tlapacoyan", add
label define munimxlbl 30184 "Tlaquilpa", add
label define munimxlbl 30185 "Tlilapan", add
label define munimxlbl 30186 "Tomatlan", add
label define munimxlbl 30187 "Tonayan", add
label define munimxlbl 30188 "Totutla", add
label define munimxlbl 30189 "Tuxpam", add
label define munimxlbl 30190 "Tuxtilla", add
label define munimxlbl 30191 "Ursulo Galvan", add
label define munimxlbl 30192 "Vega de Alatorre", add
label define munimxlbl 30193 "Veracruz", add
label define munimxlbl 30194 "Villa Aldama", add
label define munimxlbl 30195 "Xoxocotla", add
label define munimxlbl 30196 "Yanga", add
label define munimxlbl 30197 "Yecuatla", add
label define munimxlbl 30198 "Zacualpan", add
label define munimxlbl 30199 "Zaragoza", add
label define munimxlbl 30200 "Zentla", add
label define munimxlbl 30201 "Zongolica", add
label define munimxlbl 30202 "Zontecomatlan de Lopez y Fuentes", add
label define munimxlbl 30203 "Zozocolco de Hidalgo", add
label define munimxlbl 30204 "Agua Dulce", add
label define munimxlbl 30205 "Higo, El", add
label define munimxlbl 30206 "Nanchital de Lazaro Cardenas del Rio", add
label define munimxlbl 30207 "Tres Valles", add
label define munimxlbl 30208 "Carlos A. Carrillo", add
label define munimxlbl 30209 "Tatahuicapan de Juarez", add
label define munimxlbl 30210 "Uxpanapa", add
label define munimxlbl 31001 "Abala", add
label define munimxlbl 31002 "Acanceh", add
label define munimxlbl 31003 "Akil", add
label define munimxlbl 31004 "Baca", add
label define munimxlbl 31005 "Bokoba", add
label define munimxlbl 31006 "Buctzotz", add
label define munimxlbl 31007 "Cacalchen", add
label define munimxlbl 31008 "Calotmul", add
label define munimxlbl 31009 "Cansahcab", add
label define munimxlbl 31010 "Cantamayec", add
label define munimxlbl 31011 "Celestun", add
label define munimxlbl 31012 "Cenotillo", add
label define munimxlbl 31013 "Conkal", add
label define munimxlbl 31014 "Cuncunul", add
label define munimxlbl 31015 "Cuzama", add
label define munimxlbl 31016 "Chacsinkin", add
label define munimxlbl 31017 "Chankom", add
label define munimxlbl 31018 "Chapab", add
label define munimxlbl 31019 "Chemax", add
label define munimxlbl 31020 "Chicxulub Pueblo", add
label define munimxlbl 31021 "Chichimila", add
label define munimxlbl 31022 "Chikindzonot", add
label define munimxlbl 31023 "Chochola", add
label define munimxlbl 31024 "Chumayel", add
label define munimxlbl 31025 "Dzan", add
label define munimxlbl 31026 "Dzemul", add
label define munimxlbl 31027 "Dzidzantun", add
label define munimxlbl 31028 "Dzilam de Bravo", add
label define munimxlbl 31029 "Dzilam Gonzalez", add
label define munimxlbl 31030 "Dzitas", add
label define munimxlbl 31031 "Dzoncauich", add
label define munimxlbl 31032 "Espita", add
label define munimxlbl 31033 "Halacho", add
label define munimxlbl 31034 "Hocaba", add
label define munimxlbl 31035 "Hoctun", add
label define munimxlbl 31036 "Homun", add
label define munimxlbl 31037 "Huhi", add
label define munimxlbl 31038 "Hunucma", add
label define munimxlbl 31039 "Ixil", add
label define munimxlbl 31040 "Izamal", add
label define munimxlbl 31041 "Kanasin", add
label define munimxlbl 31042 "Kantunil", add
label define munimxlbl 31043 "Kaua", add
label define munimxlbl 31044 "Kinchil", add
label define munimxlbl 31045 "Kopoma", add
label define munimxlbl 31046 "Mama", add
label define munimxlbl 31047 "Mani", add
label define munimxlbl 31048 "Maxcanu", add
label define munimxlbl 31049 "Mayapan", add
label define munimxlbl 31050 "Merida", add
label define munimxlbl 31051 "Mococha", add
label define munimxlbl 31052 "Motul", add
label define munimxlbl 31053 "Muna", add
label define munimxlbl 31054 "Muxupip", add
label define munimxlbl 31055 "Opichen", add
label define munimxlbl 31056 "Oxkutzcab", add
label define munimxlbl 31057 "Panaba", add
label define munimxlbl 31058 "Peto", add
label define munimxlbl 31059 "Progreso", add
label define munimxlbl 31060 "Quintana Roo", add
label define munimxlbl 31061 "Rio Lagartos", add
label define munimxlbl 31062 "Sacalum", add
label define munimxlbl 31063 "Samahil", add
label define munimxlbl 31064 "Sanahcat", add
label define munimxlbl 31065 "San Felipe", add
label define munimxlbl 31066 "Santa Elena", add
label define munimxlbl 31067 "Seye", add
label define munimxlbl 31068 "Sinanche", add
label define munimxlbl 31069 "Sotuta", add
label define munimxlbl 31070 "Sucila", add
label define munimxlbl 31071 "Sudzal", add
label define munimxlbl 31072 "Suma", add
label define munimxlbl 31073 "Tahdziu", add
label define munimxlbl 31074 "Tahmek", add
label define munimxlbl 31075 "Teabo", add
label define munimxlbl 31076 "Tecoh", add
label define munimxlbl 31077 "Tekal de Venegas", add
label define munimxlbl 31078 "Tekanto", add
label define munimxlbl 31079 "Tekax", add
label define munimxlbl 31080 "Tekit", add
label define munimxlbl 31081 "Tekom", add
label define munimxlbl 31082 "Telchac Pueblo", add
label define munimxlbl 31083 "Telchac Puerto", add
label define munimxlbl 31084 "Temax", add
label define munimxlbl 31085 "Temozon", add
label define munimxlbl 31086 "Tepakan", add
label define munimxlbl 31087 "Tetiz", add
label define munimxlbl 31088 "Teya", add
label define munimxlbl 31089 "Ticul", add
label define munimxlbl 31090 "Timucuy", add
label define munimxlbl 31091 "Tinum", add
label define munimxlbl 31092 "Tixcacalcupul", add
label define munimxlbl 31093 "Tixkokob", add
label define munimxlbl 31094 "Tixmehuac", add
label define munimxlbl 31095 "Tixpehual", add
label define munimxlbl 31096 "Tizimin", add
label define munimxlbl 31097 "Tunkas", add
label define munimxlbl 31098 "Tzucacab", add
label define munimxlbl 31099 "Uayma", add
label define munimxlbl 31100 "Ucu", add
label define munimxlbl 31101 "Uman", add
label define munimxlbl 31102 "Valladolid", add
label define munimxlbl 31103 "Xocchel", add
label define munimxlbl 31104 "Yaxcaba", add
label define munimxlbl 31105 "Yaxkukul", add
label define munimxlbl 31106 "Yobain", add
label define munimxlbl 32001 "Apozol", add
label define munimxlbl 32002 "Apulco", add
label define munimxlbl 32003 "Atolinga", add
label define munimxlbl 32004 "Benito Juarez", add
label define munimxlbl 32005 "Calera", add
label define munimxlbl 32006 "Canitas de Felipe Pescador", add
label define munimxlbl 32007 "Concepcion del Oro", add
label define munimxlbl 32008 "Cuauhtemoc", add
label define munimxlbl 32009 "Chalchihuites", add
label define munimxlbl 32010 "Fresnillo", add
label define munimxlbl 32011 "Trinidad Garcia de la Cadena", add
label define munimxlbl 32012 "Genaro codina", add
label define munimxlbl 32013 "General Enrique Estrada", add
label define munimxlbl 32014 "General Francisco R. Murguia", add
label define munimxlbl 32015 "Plateado de Joaquin Amaro, El", add
label define munimxlbl 32016 "General Panfilo Natera", add
label define munimxlbl 32017 "Guadalupe", add
label define munimxlbl 32018 "Huanusco", add
label define munimxlbl 32019 "Jalpa", add
label define munimxlbl 32020 "Jerez", add
label define munimxlbl 32021 "Jimenez del Teul", add
label define munimxlbl 32022 "Juan aldama", add
label define munimxlbl 32023 "Juchipila", add
label define munimxlbl 32024 "Loreto", add
label define munimxlbl 32025 "Luis Moya", add
label define munimxlbl 32026 "Mazapil", add
label define munimxlbl 32027 "Melchor Ocampo", add
label define munimxlbl 32028 "Mezquital del Oro", add
label define munimxlbl 32029 "Miguel Auza", add
label define munimxlbl 32030 "Momax", add
label define munimxlbl 32031 "Monte Escobedo", add
label define munimxlbl 32032 "Morelos", add
label define munimxlbl 32033 "Moyahua de Estrada", add
label define munimxlbl 32034 "Nochistlan de Mejia", add
label define munimxlbl 32035 "Noria de Angeles", add
label define munimxlbl 32036 "Ojocaliente", add
label define munimxlbl 32037 "Panuco", add
label define munimxlbl 32038 "Pinos", add
label define munimxlbl 32039 "Rio Grande", add
label define munimxlbl 32040 "Sain Alto", add
label define munimxlbl 32041 "Salvador, El", add
label define munimxlbl 32042 "Sombrerete", add
label define munimxlbl 32043 "Susticacan", add
label define munimxlbl 32044 "Tabasco", add
label define munimxlbl 32045 "Tepechitlan", add
label define munimxlbl 32046 "Tepetongo", add
label define munimxlbl 32047 "Teul de Gonzalez Ortega", add
label define munimxlbl 32048 "Tlaltenango de Sanchez Roman", add
label define munimxlbl 32049 "Valparaiso", add
label define munimxlbl 32050 "Vetagrande", add
label define munimxlbl 32051 "Villa de Cos", add
label define munimxlbl 32052 "Villa Garcia", add
label define munimxlbl 32053 "Villa Gonzalez Ortega", add
label define munimxlbl 32054 "Villa Hidalgo", add
label define munimxlbl 32055 "Villanueva", add
label define munimxlbl 32056 "Zacatecas", add
label define munimxlbl 32057 "Trancoso", add
label values munimx munimxlbl

label define sizemxlbl 1 "1 to 2,499 population"
label define sizemxlbl 2 "2,500 to 14,999", add
label define sizemxlbl 3 "15,000 to 99,999", add
label define sizemxlbl 4 "15,000 to 19,999", add
label define sizemxlbl 5 "20,000 to 49,999", add
label define sizemxlbl 6 "50,000 to 99,999", add
label define sizemxlbl 7 "100,000 to 499,999", add
label define sizemxlbl 8 "500,000 or more", add
label values sizemx sizemxlbl

label define mx00a_migstatlbl 1 "Yes, there were international migrants in the last five years"
label define mx00a_migstatlbl 2 "There were no international migrants in the last five years", add
label define mx00a_migstatlbl 9 "Not specified", add
label values mx00a_migstat mx00a_migstatlbl

label define mx00a_mignlbl 00 "NIU"
label define mx00a_mignlbl 01 "1", add
label define mx00a_mignlbl 02 "2", add
label define mx00a_mignlbl 03 "3", add
label define mx00a_mignlbl 04 "4", add
label define mx00a_mignlbl 05 "5", add
label define mx00a_mignlbl 06 "6", add
label define mx00a_mignlbl 07 "7", add
label define mx00a_mignlbl 08 "8", add
label define mx00a_mignlbl 09 "9", add
label define mx00a_mignlbl 10 "10", add
label define mx00a_mignlbl 11 "11", add
label define mx00a_mignlbl 12 "12", add
label define mx00a_mignlbl 13 "13", add
label define mx00a_mignlbl 15 "15", add
label values mx00a_mign mx00a_mignlbl

label values pernum pernumlbl

label values wtper wtperlbl

label define relatedlbl 1000 "Head"
label define relatedlbl 2000 "Spouse/partner", add
label define relatedlbl 2100 "Spouse", add
label define relatedlbl 2200 "Unmarried partner", add
label define relatedlbl 3000 "Child", add
label define relatedlbl 3100 "Biological child", add
label define relatedlbl 3200 "Adopted child", add
label define relatedlbl 3300 "Stepchild", add
label define relatedlbl 3400 "Child/child-in-law", add
label define relatedlbl 3500 "Child/child-in-law/grandchild", add
label define relatedlbl 4000 "Other relative", add
label define relatedlbl 4100 "Grandchild", add
label define relatedlbl 4110 "Grandchild or great grandchild", add
label define relatedlbl 4120 "Great grandchild", add
label define relatedlbl 4130 "Great-great grandchild", add
label define relatedlbl 4200 "Parent/parent-in-law", add
label define relatedlbl 4210 "Parent", add
label define relatedlbl 4211 "Stepparent", add
label define relatedlbl 4220 "Parent-in-law", add
label define relatedlbl 4300 "Child-in-law", add
label define relatedlbl 4400 "Sibling/sibling-in-law", add
label define relatedlbl 4410 "Sibling", add
label define relatedlbl 4420 "Stepsibling", add
label define relatedlbl 4430 "Sibling-in-law", add
label define relatedlbl 4431 "Sibling of spouse/partner", add
label define relatedlbl 4432 "Spouse/partner of sibling", add
label define relatedlbl 4500 "Grandparent", add
label define relatedlbl 4510 "Great grandparent", add
label define relatedlbl 4600 "Aunt/uncle", add
label define relatedlbl 4700 "Other specified relative", add
label define relatedlbl 4710 "Nephew/niece", add
label define relatedlbl 4720 "Cousin", add
label define relatedlbl 4730 "Sibling of sibling-in-law", add
label define relatedlbl 4740 "Parent of child-in-law", add
label define relatedlbl 4750 "Godparent related to head", add
label define relatedlbl 4800 "Other relative, not specified", add
label define relatedlbl 4810 "Other relative, n.e.c.", add
label define relatedlbl 4811 "Other relative with same family name", add
label define relatedlbl 4812 "Other relative with different family name", add
label define relatedlbl 4820 "Other relative, not specified (secondary family)", add
label define relatedlbl 5000 "Non-relative", add
label define relatedlbl 5100 "Friend/guest/visitor/partner", add
label define relatedlbl 5110 "Partner/friend", add
label define relatedlbl 5111 "Friend", add
label define relatedlbl 5112 "Partner/roommate", add
label define relatedlbl 5113 "Housemate/roommate", add
label define relatedlbl 5120 "Visitor", add
label define relatedlbl 5130 "Ex-spouse", add
label define relatedlbl 5140 "Godparent", add
label define relatedlbl 5150 "Godchild", add
label define relatedlbl 5200 "Employee", add
label define relatedlbl 5210 "Domestic employee", add
label define relatedlbl 5220 "Relative of employee, n.s.", add
label define relatedlbl 5221 "Spouse of servant", add
label define relatedlbl 5222 "Child of servant", add
label define relatedlbl 5223 "Other relative of servant", add
label define relatedlbl 5300 "Roomer/boarder/lodger/foster child", add
label define relatedlbl 5310 "Boarder", add
label define relatedlbl 5311 "Boarder or guest", add
label define relatedlbl 5320 "Lodger", add
label define relatedlbl 5330 "Foster child", add
label define relatedlbl 5340 "Tutored/foster child", add
label define relatedlbl 5350 "Tutored child", add
label define relatedlbl 5400 "Employee, boarder or guest", add
label define relatedlbl 5500 "Other specified non-relative", add
label define relatedlbl 5510 "Agregado", add
label define relatedlbl 5520 "Temporary resident, guest", add
label define relatedlbl 5600 "Group quarters", add
label define relatedlbl 5610 "Group quarters, non-inmates", add
label define relatedlbl 5620 "Institutional inmates", add
label define relatedlbl 5900 "Non-relative, n.e.c.", add
label define relatedlbl 6000 "Other relative or non-relative", add
label define relatedlbl 9999 "Unknown", add
label values related relatedlbl

label define agelbl 000 "Less than 1 year"
label define agelbl 001 "1 year", add
label define agelbl 002 "2 years", add
label define agelbl 003 "3", add
label define agelbl 004 "4", add
label define agelbl 005 "5", add
label define agelbl 006 "6", add
label define agelbl 007 "7", add
label define agelbl 008 "8", add
label define agelbl 009 "9", add
label define agelbl 010 "10", add
label define agelbl 011 "11", add
label define agelbl 012 "12", add
label define agelbl 013 "13", add
label define agelbl 014 "14", add
label define agelbl 015 "15", add
label define agelbl 016 "16", add
label define agelbl 017 "17", add
label define agelbl 018 "18", add
label define agelbl 019 "19", add
label define agelbl 020 "20", add
label define agelbl 021 "21", add
label define agelbl 022 "22", add
label define agelbl 023 "23", add
label define agelbl 024 "24", add
label define agelbl 025 "25", add
label define agelbl 026 "26", add
label define agelbl 027 "27", add
label define agelbl 028 "28", add
label define agelbl 029 "29", add
label define agelbl 030 "30", add
label define agelbl 031 "31", add
label define agelbl 032 "32", add
label define agelbl 033 "33", add
label define agelbl 034 "34", add
label define agelbl 035 "35", add
label define agelbl 036 "36", add
label define agelbl 037 "37", add
label define agelbl 038 "38", add
label define agelbl 039 "39", add
label define agelbl 040 "40", add
label define agelbl 041 "41", add
label define agelbl 042 "42", add
label define agelbl 043 "43", add
label define agelbl 044 "44", add
label define agelbl 045 "45", add
label define agelbl 046 "46", add
label define agelbl 047 "47", add
label define agelbl 048 "48", add
label define agelbl 049 "49", add
label define agelbl 050 "50", add
label define agelbl 051 "51", add
label define agelbl 052 "52", add
label define agelbl 053 "53", add
label define agelbl 054 "54", add
label define agelbl 055 "55", add
label define agelbl 056 "56", add
label define agelbl 057 "57", add
label define agelbl 058 "58", add
label define agelbl 059 "59", add
label define agelbl 060 "60", add
label define agelbl 061 "61", add
label define agelbl 062 "62", add
label define agelbl 063 "63", add
label define agelbl 064 "64", add
label define agelbl 065 "65", add
label define agelbl 066 "66", add
label define agelbl 067 "67", add
label define agelbl 068 "68", add
label define agelbl 069 "69", add
label define agelbl 070 "70", add
label define agelbl 071 "71", add
label define agelbl 072 "72", add
label define agelbl 073 "73", add
label define agelbl 074 "74", add
label define agelbl 075 "75", add
label define agelbl 076 "76", add
label define agelbl 077 "77", add
label define agelbl 078 "78", add
label define agelbl 079 "79", add
label define agelbl 080 "80", add
label define agelbl 081 "81", add
label define agelbl 082 "82", add
label define agelbl 083 "83", add
label define agelbl 084 "84", add
label define agelbl 085 "85", add
label define agelbl 086 "86", add
label define agelbl 087 "87", add
label define agelbl 088 "88", add
label define agelbl 089 "89", add
label define agelbl 090 "90", add
label define agelbl 091 "91", add
label define agelbl 092 "92", add
label define agelbl 093 "93", add
label define agelbl 094 "94", add
label define agelbl 095 "95", add
label define agelbl 096 "96", add
label define agelbl 097 "97", add
label define agelbl 098 "98", add
label define agelbl 099 "99", add
label define agelbl 100 "100+", add
label define agelbl 999 "Not reported/missing", add
label values age agelbl

label define sexlbl 1 "Male"
label define sexlbl 2 "Female", add
label define sexlbl 9 "Unknown", add
label values sex sexlbl

label define marstdlbl 000 "NIU"
label define marstdlbl 100 "Single/never married", add
label define marstdlbl 110 "Engaged", add
label define marstdlbl 200 "Married/in union", add
label define marstdlbl 210 "Married (not specified)", add
label define marstdlbl 211 "Civil", add
label define marstdlbl 212 "Religious", add
label define marstdlbl 213 "Civil and religious", add
label define marstdlbl 214 "Civil or religious", add
label define marstdlbl 215 "Traditional/customary", add
label define marstdlbl 216 "Monogamous", add
label define marstdlbl 217 "Polygamous", add
label define marstdlbl 220 "Consensual union", add
label define marstdlbl 300 "Separated/divorced/spouse absent", add
label define marstdlbl 310 "Separated or divorced", add
label define marstdlbl 320 "Separated or annulled", add
label define marstdlbl 330 "Separated", add
label define marstdlbl 331 "Separated legally", add
label define marstdlbl 332 "Separated de facto", add
label define marstdlbl 340 "Annulled", add
label define marstdlbl 350 "Divorced", add
label define marstdlbl 360 "Married, spouse absent", add
label define marstdlbl 400 "Widowed", add
label define marstdlbl 999 "Unknown", add
label values marstd marstdlbl

label define chbornlbl 00 "No children"
label define chbornlbl 01 "1 child", add
label define chbornlbl 02 "2 children", add
label define chbornlbl 03 "3", add
label define chbornlbl 04 "4", add
label define chbornlbl 05 "5", add
label define chbornlbl 06 "6", add
label define chbornlbl 07 "7", add
label define chbornlbl 08 "8", add
label define chbornlbl 09 "9", add
label define chbornlbl 10 "10", add
label define chbornlbl 11 "11", add
label define chbornlbl 12 "12", add
label define chbornlbl 13 "13", add
label define chbornlbl 14 "14", add
label define chbornlbl 15 "15", add
label define chbornlbl 16 "16", add
label define chbornlbl 17 "17", add
label define chbornlbl 18 "18", add
label define chbornlbl 19 "19", add
label define chbornlbl 20 "20", add
label define chbornlbl 21 "21", add
label define chbornlbl 22 "22", add
label define chbornlbl 23 "23", add
label define chbornlbl 24 "24", add
label define chbornlbl 25 "25", add
label define chbornlbl 26 "26", add
label define chbornlbl 27 "27", add
label define chbornlbl 28 "28", add
label define chbornlbl 29 "29", add
label define chbornlbl 30 "30+", add
label define chbornlbl 98 "Unknown", add
label define chbornlbl 99 "NIU", add
label values chborn chbornlbl

label define chsurvlbl 00 "No children"
label define chsurvlbl 01 "1 child", add
label define chsurvlbl 02 "2 children", add
label define chsurvlbl 03 "3", add
label define chsurvlbl 04 "4", add
label define chsurvlbl 05 "5", add
label define chsurvlbl 06 "6", add
label define chsurvlbl 07 "7", add
label define chsurvlbl 08 "8", add
label define chsurvlbl 09 "9", add
label define chsurvlbl 10 "10", add
label define chsurvlbl 11 "11", add
label define chsurvlbl 12 "12", add
label define chsurvlbl 13 "13", add
label define chsurvlbl 14 "14", add
label define chsurvlbl 15 "15", add
label define chsurvlbl 16 "16", add
label define chsurvlbl 17 "17", add
label define chsurvlbl 18 "18", add
label define chsurvlbl 19 "19", add
label define chsurvlbl 20 "20", add
label define chsurvlbl 21 "21", add
label define chsurvlbl 22 "22", add
label define chsurvlbl 23 "23", add
label define chsurvlbl 24 "24", add
label define chsurvlbl 25 "25", add
label define chsurvlbl 26 "26", add
label define chsurvlbl 27 "27", add
label define chsurvlbl 28 "28", add
label define chsurvlbl 29 "29", add
label define chsurvlbl 30 "30+", add
label define chsurvlbl 98 "Unknown", add
label define chsurvlbl 99 "NIU", add
label values chsurv chsurvlbl

label define lstbmthlbl 01 "January"
label define lstbmthlbl 02 "February", add
label define lstbmthlbl 03 "March", add
label define lstbmthlbl 04 "April", add
label define lstbmthlbl 05 "May", add
label define lstbmthlbl 06 "June", add
label define lstbmthlbl 07 "July", add
label define lstbmthlbl 08 "August", add
label define lstbmthlbl 09 "September", add
label define lstbmthlbl 10 "October", add
label define lstbmthlbl 11 "November", add
label define lstbmthlbl 12 "December", add
label define lstbmthlbl 98 "Unknown", add
label define lstbmthlbl 99 "NIU", add
label values lstbmth lstbmthlbl

label define lstbyrlbl 1900 "1900"
label define lstbyrlbl 1901 "1901", add
label define lstbyrlbl 1902 "1902", add
label define lstbyrlbl 1903 "1903", add
label define lstbyrlbl 1904 "1904", add
label define lstbyrlbl 1905 "1905", add
label define lstbyrlbl 1906 "1906", add
label define lstbyrlbl 1907 "1907", add
label define lstbyrlbl 1908 "1908", add
label define lstbyrlbl 1909 "1909", add
label define lstbyrlbl 1910 "1910", add
label define lstbyrlbl 1911 "1911", add
label define lstbyrlbl 1912 "1912", add
label define lstbyrlbl 1913 "1913", add
label define lstbyrlbl 1914 "1914", add
label define lstbyrlbl 1915 "1915", add
label define lstbyrlbl 1916 "1916", add
label define lstbyrlbl 1917 "1917", add
label define lstbyrlbl 1918 "1918", add
label define lstbyrlbl 1919 "1919", add
label define lstbyrlbl 1920 "1920", add
label define lstbyrlbl 1921 "1921", add
label define lstbyrlbl 1922 "1922", add
label define lstbyrlbl 1923 "1923", add
label define lstbyrlbl 1924 "1924", add
label define lstbyrlbl 1925 "1925", add
label define lstbyrlbl 1926 "1926", add
label define lstbyrlbl 1927 "1927", add
label define lstbyrlbl 1928 "1928", add
label define lstbyrlbl 1929 "1929", add
label define lstbyrlbl 1930 "1930", add
label define lstbyrlbl 1931 "1931", add
label define lstbyrlbl 1932 "1932", add
label define lstbyrlbl 1933 "1933", add
label define lstbyrlbl 1934 "1934", add
label define lstbyrlbl 1935 "1935", add
label define lstbyrlbl 1936 "1936", add
label define lstbyrlbl 1937 "1937", add
label define lstbyrlbl 1938 "1938", add
label define lstbyrlbl 1939 "1939", add
label define lstbyrlbl 1940 "1940", add
label define lstbyrlbl 1941 "1941", add
label define lstbyrlbl 1942 "1942", add
label define lstbyrlbl 1943 "1943", add
label define lstbyrlbl 1944 "1944", add
label define lstbyrlbl 1945 "1945", add
label define lstbyrlbl 1946 "1946", add
label define lstbyrlbl 1947 "1947", add
label define lstbyrlbl 1948 "1948", add
label define lstbyrlbl 1949 "1949", add
label define lstbyrlbl 1950 "1950", add
label define lstbyrlbl 1951 "1951", add
label define lstbyrlbl 1952 "1952", add
label define lstbyrlbl 1953 "1953", add
label define lstbyrlbl 1954 "1954", add
label define lstbyrlbl 1955 "1955", add
label define lstbyrlbl 1956 "1956", add
label define lstbyrlbl 1957 "1957", add
label define lstbyrlbl 1958 "1958", add
label define lstbyrlbl 1959 "1959", add
label define lstbyrlbl 1960 "1960", add
label define lstbyrlbl 1961 "1961", add
label define lstbyrlbl 1962 "1962", add
label define lstbyrlbl 1963 "1963", add
label define lstbyrlbl 1964 "1964", add
label define lstbyrlbl 1965 "1965", add
label define lstbyrlbl 1966 "1966", add
label define lstbyrlbl 1967 "1967", add
label define lstbyrlbl 1968 "1968", add
label define lstbyrlbl 1969 "1969", add
label define lstbyrlbl 1970 "1970", add
label define lstbyrlbl 1971 "1971", add
label define lstbyrlbl 1972 "1972", add
label define lstbyrlbl 1973 "1973", add
label define lstbyrlbl 1974 "1974", add
label define lstbyrlbl 1975 "1975", add
label define lstbyrlbl 1976 "1976", add
label define lstbyrlbl 1977 "1977", add
label define lstbyrlbl 1978 "1978", add
label define lstbyrlbl 1979 "1979", add
label define lstbyrlbl 1980 "1980", add
label define lstbyrlbl 1981 "1981", add
label define lstbyrlbl 1982 "1982", add
label define lstbyrlbl 1983 "1983", add
label define lstbyrlbl 1984 "1984", add
label define lstbyrlbl 1985 "1985", add
label define lstbyrlbl 1986 "1986", add
label define lstbyrlbl 1987 "1987", add
label define lstbyrlbl 1988 "1988", add
label define lstbyrlbl 1989 "1989", add
label define lstbyrlbl 1990 "1990", add
label define lstbyrlbl 1991 "1991", add
label define lstbyrlbl 1992 "1992", add
label define lstbyrlbl 1993 "1993", add
label define lstbyrlbl 1994 "1994", add
label define lstbyrlbl 1995 "1995", add
label define lstbyrlbl 1996 "1996", add
label define lstbyrlbl 1997 "1997", add
label define lstbyrlbl 1998 "1998", add
label define lstbyrlbl 1999 "1999", add
label define lstbyrlbl 2000 "2000", add
label define lstbyrlbl 2001 "2001", add
label define lstbyrlbl 2002 "2002", add
label define lstbyrlbl 9998 "Unknown", add
label define lstbyrlbl 9999 "NIU", add
label values lstbyr lstbyrlbl

label define lststatlbl 0 "NIU"
label define lststatlbl 1 "Alive", add
label define lststatlbl 2 "Dead", add
label define lststatlbl 8 "Does not know", add
label define lststatlbl 9 "Missing/not reported", add
label values lststat lststatlbl

label define agededylbl 01 "1"
label define agededylbl 02 "2", add
label define agededylbl 03 "3", add
label define agededylbl 04 "4", add
label define agededylbl 05 "5", add
label define agededylbl 06 "6", add
label define agededylbl 07 "7", add
label define agededylbl 08 "8", add
label define agededylbl 09 "9", add
label define agededylbl 10 "10", add
label define agededylbl 11 "11", add
label define agededylbl 12 "12", add
label define agededylbl 13 "13", add
label define agededylbl 14 "14", add
label define agededylbl 15 "15", add
label define agededylbl 16 "16", add
label define agededylbl 17 "17", add
label define agededylbl 18 "18", add
label define agededylbl 19 "19", add
label define agededylbl 20 "20", add
label define agededylbl 21 "21", add
label define agededylbl 22 "22", add
label define agededylbl 23 "23", add
label define agededylbl 24 "24", add
label define agededylbl 25 "25", add
label define agededylbl 26 "26", add
label define agededylbl 27 "27", add
label define agededylbl 28 "28", add
label define agededylbl 29 "29", add
label define agededylbl 30 "30", add
label define agededylbl 31 "31", add
label define agededylbl 32 "32", add
label define agededylbl 33 "33", add
label define agededylbl 34 "34", add
label define agededylbl 35 "35", add
label define agededylbl 36 "36", add
label define agededylbl 37 "37", add
label define agededylbl 38 "38", add
label define agededylbl 39 "39", add
label define agededylbl 40 "40", add
label define agededylbl 41 "41", add
label define agededylbl 42 "42", add
label define agededylbl 43 "43", add
label define agededylbl 44 "44", add
label define agededylbl 45 "45", add
label define agededylbl 46 "46", add
label define agededylbl 47 "47", add
label define agededylbl 48 "48", add
label define agededylbl 49 "49", add
label define agededylbl 50 "50", add
label define agededylbl 51 "51", add
label define agededylbl 52 "52", add
label define agededylbl 53 "53", add
label define agededylbl 54 "54", add
label define agededylbl 55 "55", add
label define agededylbl 56 "56", add
label define agededylbl 57 "57", add
label define agededylbl 58 "58", add
label define agededylbl 59 "59", add
label define agededylbl 60 "60", add
label define agededylbl 61 "61", add
label define agededylbl 62 "62", add
label define agededylbl 63 "63", add
label define agededylbl 64 "64", add
label define agededylbl 65 "65", add
label define agededylbl 66 "66", add
label define agededylbl 67 "67", add
label define agededylbl 68 "68", add
label define agededylbl 69 "69", add
label define agededylbl 70 "70", add
label define agededylbl 71 "71", add
label define agededylbl 72 "72", add
label define agededylbl 73 "73", add
label define agededylbl 74 "74", add
label define agededylbl 75 "75", add
label define agededylbl 77 "77", add
label define agededylbl 78 "78", add
label define agededylbl 90 "Less than one year", add
label define agededylbl 99 "NIU", add
label values agededy agededylbl

label define agededmlbl 00 "Less than 1 month"
label define agededmlbl 01 "1", add
label define agededmlbl 02 "2", add
label define agededmlbl 03 "3", add
label define agededmlbl 04 "4", add
label define agededmlbl 05 "5", add
label define agededmlbl 06 "6", add
label define agededmlbl 07 "7", add
label define agededmlbl 08 "8", add
label define agededmlbl 09 "9", add
label define agededmlbl 10 "10", add
label define agededmlbl 11 "11", add
label define agededmlbl 12 "12", add
label define agededmlbl 13 "13", add
label define agededmlbl 14 "14", add
label define agededmlbl 15 "15", add
label define agededmlbl 16 "16", add
label define agededmlbl 17 "17", add
label define agededmlbl 18 "18", add
label define agededmlbl 19 "19", add
label define agededmlbl 20 "20", add
label define agededmlbl 21 "21", add
label define agededmlbl 22 "22", add
label define agededmlbl 23 "23", add
label define agededmlbl 24 "24", add
label define agededmlbl 25 "25", add
label define agededmlbl 26 "26", add
label define agededmlbl 27 "27", add
label define agededmlbl 28 "28", add
label define agededmlbl 29 "29", add
label define agededmlbl 30 "30", add
label define agededmlbl 31 "31", add
label define agededmlbl 32 "32", add
label define agededmlbl 33 "33", add
label define agededmlbl 34 "34", add
label define agededmlbl 35 "35", add
label define agededmlbl 36 "36", add
label define agededmlbl 37 "37", add
label define agededmlbl 38 "38", add
label define agededmlbl 39 "39", add
label define agededmlbl 40 "40", add
label define agededmlbl 41 "41", add
label define agededmlbl 42 "42", add
label define agededmlbl 43 "43", add
label define agededmlbl 44 "44", add
label define agededmlbl 45 "45", add
label define agededmlbl 46 "46", add
label define agededmlbl 47 "47", add
label define agededmlbl 48 "48", add
label define agededmlbl 49 "49", add
label define agededmlbl 50 "50", add
label define agededmlbl 51 "51", add
label define agededmlbl 52 "52", add
label define agededmlbl 53 "53", add
label define agededmlbl 54 "54", add
label define agededmlbl 55 "55", add
label define agededmlbl 56 "56", add
label define agededmlbl 57 "57", add
label define agededmlbl 58 "58", add
label define agededmlbl 59 "59", add
label define agededmlbl 60 "60+", add
label define agededmlbl 90 "Less than 1 month, or 1 year or more", add
label define agededmlbl 98 "Unknown", add
label define agededmlbl 99 "NIU", add
label values agededm agededmlbl

label define agededdlbl 00 "Less than 1 day"
label define agededdlbl 01 "1 day", add
label define agededdlbl 02 "2 days", add
label define agededdlbl 03 "3 days", add
label define agededdlbl 04 "4 days", add
label define agededdlbl 05 "5 days", add
label define agededdlbl 06 "6 days", add
label define agededdlbl 07 "7 days", add
label define agededdlbl 08 "8 days", add
label define agededdlbl 09 "9 days", add
label define agededdlbl 10 "10 days", add
label define agededdlbl 11 "11 days", add
label define agededdlbl 12 "12 days", add
label define agededdlbl 13 "13 days", add
label define agededdlbl 14 "14 days", add
label define agededdlbl 15 "15 days", add
label define agededdlbl 16 "16 days", add
label define agededdlbl 17 "17 days", add
label define agededdlbl 18 "18 days", add
label define agededdlbl 19 "19 days", add
label define agededdlbl 20 "20 days", add
label define agededdlbl 21 "21 days", add
label define agededdlbl 22 "22 days", add
label define agededdlbl 23 "23 days", add
label define agededdlbl 24 "24 days", add
label define agededdlbl 25 "25 days", add
label define agededdlbl 26 "26 days", add
label define agededdlbl 27 "27 days", add
label define agededdlbl 28 "28 days", add
label define agededdlbl 29 "29 days", add
label define agededdlbl 90 "One month or more", add
label define agededdlbl 98 "Unknown", add
label define agededdlbl 99 "NIU", add
label values agededd agededdlbl

label define bplmxlbl 01 "Aguascalientes"
label define bplmxlbl 02 "Baja California", add
label define bplmxlbl 03 "Baja California Sur", add
label define bplmxlbl 04 "Campeche", add
label define bplmxlbl 05 "Coahuila", add
label define bplmxlbl 06 "Colima", add
label define bplmxlbl 07 "Chiapas", add
label define bplmxlbl 08 "Chihuahua", add
label define bplmxlbl 09 "Distrito Federal", add
label define bplmxlbl 10 "Durango", add
label define bplmxlbl 11 "Guanajuato", add
label define bplmxlbl 12 "Guerrero", add
label define bplmxlbl 13 "Hidalgo", add
label define bplmxlbl 14 "Jalisco", add
label define bplmxlbl 15 "México", add
label define bplmxlbl 16 "Michoacán", add
label define bplmxlbl 17 "Morelos", add
label define bplmxlbl 18 "Nayarit", add
label define bplmxlbl 19 "Nuevo León", add
label define bplmxlbl 20 "Oaxaca", add
label define bplmxlbl 21 "Puebla", add
label define bplmxlbl 22 "Querétaro", add
label define bplmxlbl 23 "Quintana Roo", add
label define bplmxlbl 24 "San Luis Potosí", add
label define bplmxlbl 25 "Sinaloa", add
label define bplmxlbl 26 "Sonora", add
label define bplmxlbl 27 "Tabasco", add
label define bplmxlbl 28 "Tamaulipas", add
label define bplmxlbl 29 "Tlaxcala", add
label define bplmxlbl 30 "Veracruz", add
label define bplmxlbl 31 "Yucatán", add
label define bplmxlbl 32 "Zacatecas", add
label define bplmxlbl 98 "Foreign-born", add
label define bplmxlbl 99 "Missing/unknown", add
label values bplmx bplmxlbl

label define spkindlbl 0 "NIU"
label define spkindlbl 1 "Yes, speaks indigenous language", add
label define spkindlbl 2 "Yes, speaks indigenous and Spanish", add
label define spkindlbl 3 "Yes, speaks only indigenous", add
label define spkindlbl 4 "No, does not speak indigenous language", add
label define spkindlbl 9 "Unknown", add
label values spkind spkindlbl

label define schoollbl 0 "NIU"
label define schoollbl 1 "Yes", add
label define schoollbl 2 "No, not specified", add
label define schoollbl 3 "No, attended in the past", add
label define schoollbl 4 "No, never attended", add
label define schoollbl 9 "Unknown/missing", add
label values school schoollbl

label define litlbl 0 "NIU"
label define litlbl 1 "No, illiterate", add
label define litlbl 2 "Yes, literate", add
label define litlbl 9 "Unknown/missing", add
label values lit litlbl

label define edattandlbl 000 "NIU", add
label define edattandlbl 100 "Less than primary completed (n.s.)", add
label define edattandlbl 110 "No schooling", add
label define edattandlbl 120 "Some primary completed", add
label define edattandlbl 130 "Primary (4 yrs) completed", add
label define edattandlbl 211 "Primary (5 yrs) completed", add
label define edattandlbl 212 "Primary (6 yrs) completed", add
label define edattandlbl 221 "Lower secondary general completed", add
label define edattandlbl 222 "Lower secondary technical completed", add
label define edattandlbl 311 "Secondary, general track completed", add
label define edattandlbl 312 "Some college completed", add
label define edattandlbl 320 "Secondary or post-secondary technical completed", add
label define edattandlbl 321 "Secondary, technical track completed", add
label define edattandlbl 322 "Post-secondary technical education", add
label define edattandlbl 400 "University completed", add
label define edattandlbl 998 "Response suppressed", add
label define edattandlbl 999 "Unknown/missing", add
label values edattand edattandlbl

label define yrschllbl 00 "None or pre-school"
label define yrschllbl 01 "1 year", add
label define yrschllbl 02 "2 years", add
label define yrschllbl 03 "3 years", add
label define yrschllbl 04 "4 years", add
label define yrschllbl 05 "5 years", add
label define yrschllbl 06 "6 years", add
label define yrschllbl 07 "7 years", add
label define yrschllbl 08 "8 years", add
label define yrschllbl 09 "9 years", add
label define yrschllbl 10 "10 years", add
label define yrschllbl 11 "11 years", add
label define yrschllbl 12 "12 years", add
label define yrschllbl 13 "13 years", add
label define yrschllbl 14 "14 years", add
label define yrschllbl 15 "15 years", add
label define yrschllbl 16 "16 years", add
label define yrschllbl 17 "17 years", add
label define yrschllbl 18 "18 years or more", add
label define yrschllbl 90 "Not specified", add
label define yrschllbl 91 "Some primary", add
label define yrschllbl 92 "Some technical after primary", add
label define yrschllbl 93 "Some secondary", add
label define yrschllbl 94 "Some tertiary", add
label define yrschllbl 95 "Adult literacy", add
label define yrschllbl 96 "Special education (Ecuador)", add
label define yrschllbl 97 "Response suppressed", add
label define yrschllbl 98 "Unknown/missing", add
label define yrschllbl 99 "NIU", add
label values yrschl yrschllbl

label define educmxlbl 000 "Less than primary"
label define educmxlbl 010 "None, or never attended school", add
label define educmxlbl 020 "Preschool or kindergarten", add
label define educmxlbl 021 "Preschool, 1 year", add
label define educmxlbl 022 "Preschool, 2 years", add
label define educmxlbl 023 "Preschool, 3 years", add
label define educmxlbl 029 "Preschool, unspecified years", add
label define educmxlbl 100 "Primary", add
label define educmxlbl 101 "Primary, 1 year", add
label define educmxlbl 102 "Primary, 2 years", add
label define educmxlbl 103 "Primary, 3 years", add
label define educmxlbl 104 "Primary, 4 years", add
label define educmxlbl 105 "Primary, 5 years", add
label define educmxlbl 106 "Primary, 6 years", add
label define educmxlbl 107 "Primary, 7+ years", add
label define educmxlbl 109 "Primary, years unspecified", add
label define educmxlbl 200 "Lower secondary (middle or junior high school)", add
label define educmxlbl 210 "Lower secondary, tech/commercial", add
label define educmxlbl 211 "Lower secondary, tech/commercial, 1 year", add
label define educmxlbl 212 "Lower secondary, tech/commercial, 2 years", add
label define educmxlbl 213 "Lower secondary, tech/commercial, 3 years", add
label define educmxlbl 214 "Lower secondary, tech/commercial, 4 years", add
label define educmxlbl 219 "Lower secondary, tech/commercial, years unspec.", add
label define educmxlbl 220 "Lower secondary, general track", add
label define educmxlbl 221 "Lower secondary, general track, 1 year", add
label define educmxlbl 222 "Lower secondary, general track, 2 years", add
label define educmxlbl 223 "Lower secondary, general track, 3 years", add
label define educmxlbl 229 "Lower secondary, general track, years unspec.", add
label define educmxlbl 230 "Lower secondary, track unspec.", add
label define educmxlbl 231 "Lower secondary, track unspec., 1 year", add
label define educmxlbl 232 "Lower secondary, track unspec., 2 years", add
label define educmxlbl 233 "Lower secondary, track unspec., 3 years", add
label define educmxlbl 300 "Secondary (high school)", add
label define educmxlbl 310 "Secondary tech/commercial", add
label define educmxlbl 311 "Secondary tech/commercial, 1 year", add
label define educmxlbl 312 "Secondary tech/commercial, 2 years", add
label define educmxlbl 313 "Secondary tech/commercial, 3 years", add
label define educmxlbl 314 "Secondary tech/commercial, 4 years", add
label define educmxlbl 319 "Secondary tech/commercial, years unspec.", add
label define educmxlbl 320 "Secondary, general track", add
label define educmxlbl 321 "Secondary, general track, 1 year", add
label define educmxlbl 322 "Secondary, general track, 2 years", add
label define educmxlbl 323 "Secondary, general track, 3 years", add
label define educmxlbl 329 "Secondary, general track, years unspec.", add
label define educmxlbl 390 "Secondary, track unspec.", add
label define educmxlbl 391 "Secondary, track unspec., 1 year", add
label define educmxlbl 392 "Secondary, track unspec., 2 years", add
label define educmxlbl 393 "Secondary, track unspec., 3 years", add
label define educmxlbl 400 "Normal school (teacher-training)", add
label define educmxlbl 401 "Normal, 1 year", add
label define educmxlbl 402 "Normal, 2 years", add
label define educmxlbl 403 "Normal, 3 years", add
label define educmxlbl 404 "Normal, 4 years", add
label define educmxlbl 409 "Normal, years unspec.", add
label define educmxlbl 500 "Post-secondary technical", add
label define educmxlbl 501 "Post-secondary technical, 1 year", add
label define educmxlbl 502 "Post-secondary technical, 2 years", add
label define educmxlbl 503 "Post-secondary technical, 3 years", add
label define educmxlbl 504 "Post-secondary technical, 4 years", add
label define educmxlbl 505 "Post-secondary technical, 5 years", add
label define educmxlbl 509 "Post-secondary technical, years unspec.", add
label define educmxlbl 600 "University", add
label define educmxlbl 610 "University undergraduate", add
label define educmxlbl 611 "University undergraduate, 1 year", add
label define educmxlbl 612 "University undergraduate, 2 years", add
label define educmxlbl 613 "University undergraduate, 3 years", add
label define educmxlbl 614 "University undergraduate, 4 years", add
label define educmxlbl 615 "University undergraduate, 5 years", add
label define educmxlbl 616 "University undergraduate, 6 years", add
label define educmxlbl 617 "University undergraduate, 7 years", add
label define educmxlbl 618 "University undergraduate, 8+ years", add
label define educmxlbl 619 "University undergraduate, years unspec.", add
label define educmxlbl 620 "University graduate", add
label define educmxlbl 621 "University graduate, 1 year", add
label define educmxlbl 622 "University graduate, 2 years", add
label define educmxlbl 623 "University graduate, 3 years", add
label define educmxlbl 624 "University graduate, 4 years", add
label define educmxlbl 625 "University graduate, 5 years", add
label define educmxlbl 626 "University graduate, 6 years", add
label define educmxlbl 627 "University graduate, 7 years", add
label define educmxlbl 628 "University graduate, 8+ years", add
label define educmxlbl 629 "University graduate, years unspec.", add
label define educmxlbl 700 "Unspecified post-secondary", add
label define educmxlbl 701 "Unspecified post-secondary, 1 year", add
label define educmxlbl 702 "Unspecified post-secondary, 2 years", add
label define educmxlbl 703 "Unspecified post-secondary, 3 years", add
label define educmxlbl 704 "Unspecified post-secondary, 4 years", add
label define educmxlbl 705 "Unspecified post-secondary, 5 years", add
label define educmxlbl 706 "Unspecified post-secondary, 6 years", add
label define educmxlbl 707 "Unspecified post-secondary, 7 years", add
label define educmxlbl 708 "Unspecified post-secondary, 8+ years", add
label define educmxlbl 800 "Unknown/missing", add
label define educmxlbl 900 "NIU", add
label values educmx educmxlbl

label define leftschlbl 00 "NIU"
label define leftschlbl 10 "Finished studies", add
label define leftschlbl 20 "Financial considerations", add
label define leftschlbl 21 "Insufficient economic means", add
label define leftschlbl 22 "Working", add
label define leftschlbl 30 "School too far away or nonexistent", add
label define leftschlbl 31 "School too far away", add
label define leftschlbl 32 "No school available", add
label define leftschlbl 40 "Other reasons", add
label define leftschlbl 41 "Family required for household tasks", add
label define leftschlbl 42 "Got married or entered a consensual union", add
label define leftschlbl 43 "Never attended school", add
label define leftschlbl 44 "Did not want to attend or to study", add
label define leftschlbl 45 "No higher grades offered", add
label define leftschlbl 46 "No places available in school", add
label define leftschlbl 47 "Other, not elsewhere classified", add
label define leftschlbl 99 "Unknown/missing", add
label values leftsch leftschlbl

label define empstatdlbl 000 "NIU", add
label define empstatdlbl 100 "Employed, not specified", add
label define empstatdlbl 110 "At work", add
label define empstatdlbl 111 "At work, and 'student'", add
label define empstatdlbl 112 "At work, and 'housework'", add
label define empstatdlbl 113 "At work, and 'seeking work'", add
label define empstatdlbl 114 "At work, and 'retired'", add
label define empstatdlbl 115 "At work, and 'no work'", add
label define empstatdlbl 116 "At work, and 'other'", add
label define empstatdlbl 117 "At work, family holding, not specified", add
label define empstatdlbl 118 "At work, family holding, not agricultural", add
label define empstatdlbl 119 "At work, family holding, agricultural", add
label define empstatdlbl 120 "Have job, not at work last week", add
label define empstatdlbl 130 "Armed forces", add
label define empstatdlbl 131 "Armed forces, at work", add
label define empstatdlbl 132 "Armed forces, not at work last week", add
label define empstatdlbl 133 "Military trainee", add
label define empstatdlbl 200 "Unemployed, not specified", add
label define empstatdlbl 201 "Unemployed (Vietnam, Cambodia)", add
label define empstatdlbl 202 "Worked less than 6 months, permanent job", add
label define empstatdlbl 203 "Worked less than 6 months, temporary job", add
label define empstatdlbl 210 "Unemployed, experienced worker", add
label define empstatdlbl 220 "Unemployed, new worker", add
label define empstatdlbl 230 "No work available", add
label define empstatdlbl 240 "Unemployed, awaiting government job", add
label define empstatdlbl 300 "Inactive (not in labor force)", add
label define empstatdlbl 310 "Housework", add
label define empstatdlbl 320 "Unable to work/disabled", add
label define empstatdlbl 321 "Permanent disability", add
label define empstatdlbl 322 "Temporary illness", add
label define empstatdlbl 323 "Disabled or imprisoned", add
label define empstatdlbl 330 "In school", add
label define empstatdlbl 331 "Awaiting school enrollment", add
label define empstatdlbl 340 "Retirees and living on rent", add
label define empstatdlbl 341 "Living on rents", add
label define empstatdlbl 342 "Retirees/pensioners", add
label define empstatdlbl 343 "Retired", add
label define empstatdlbl 344 "Pensioner", add
label define empstatdlbl 345 "Non-retirement pension", add
label define empstatdlbl 346 "Disability pension", add
label define empstatdlbl 350 "Elderly", add
label define empstatdlbl 360 "Institutionalized", add
label define empstatdlbl 361 "Prisoner", add
label define empstatdlbl 370 "Not working, seasonal worker", add
label define empstatdlbl 380 "Inactive, other reasons", add
label define empstatdlbl 999 "Unknown", add
label values empstatd empstatdlbl

label values occ occlbl

label define indlbl 00000 "NIU"
label values ind indlbl

label define inctotlbl 9999998 "Unknown", add
label define inctotlbl 9999999 "NIU", add
label values inctot inctotlbl

label define incearnlbl 00000000 "0"
label define incearnlbl 00000125 "125", add
label define incearnlbl 00000375 "375", add
label define incearnlbl 00000625 "625", add
label define incearnlbl 00000875 "875", add
label define incearnlbl 00001050 "1050", add
label define incearnlbl 00001250 "1250", add
label define incearnlbl 00001750 "1750", add
label define incearnlbl 00002000 "2000", add
label define incearnlbl 99999998 "Missing/unknown", add
label define incearnlbl 99999999 "NIU", add
label values incearn incearnlbl

label define mgrate5lbl 00 "NIU"
label define mgrate5lbl 10 "Same state/department/province/region, n.s.", add
label define mgrate5lbl 11 "Same county/district/municipality", add
label define mgrate5lbl 12 "Different county/district/municipality", add
label define mgrate5lbl 20 "Different state/department/province/region", add
label define mgrate5lbl 30 "Abroad", add
label define mgrate5lbl 99 "Unknown/missing", add
label values mgrate5 mgrate5lbl

label define migmx2lbl 00 "NIU"
label define migmx2lbl 01 "Aguascalientes", add
label define migmx2lbl 02 "Baja California", add
label define migmx2lbl 03 "Baja California Sur", add
label define migmx2lbl 04 "Campeche", add
label define migmx2lbl 05 "Coahuila", add
label define migmx2lbl 06 "Colima", add
label define migmx2lbl 07 "Chiapas", add
label define migmx2lbl 08 "Chihuahua", add
label define migmx2lbl 09 "Distrito Federal", add
label define migmx2lbl 10 "Durango", add
label define migmx2lbl 11 "Guanajuato", add
label define migmx2lbl 12 "Guerrero", add
label define migmx2lbl 13 "Hidalgo", add
label define migmx2lbl 14 "Jalisco", add
label define migmx2lbl 15 "México", add
label define migmx2lbl 16 "Michoacán", add
label define migmx2lbl 17 "Morelos", add
label define migmx2lbl 18 "Nayarit", add
label define migmx2lbl 19 "Nuevo León", add
label define migmx2lbl 20 "Oaxaca", add
label define migmx2lbl 21 "Puebla", add
label define migmx2lbl 22 "Querétaro", add
label define migmx2lbl 23 "Quintana Roo", add
label define migmx2lbl 24 "San Luis Potosí", add
label define migmx2lbl 25 "Sinaloa", add
label define migmx2lbl 26 "Sonora", add
label define migmx2lbl 27 "Tabasco", add
label define migmx2lbl 28 "Tamaulipas", add
label define migmx2lbl 29 "Tlaxcala", add
label define migmx2lbl 30 "Veracruz", add
label define migmx2lbl 31 "Yucatán", add
label define migmx2lbl 32 "Zacatecas", add
label define migmx2lbl 98 "Abroad", add
label define migmx2lbl 99 "Unknown", add
label values migmx2 migmx2lbl

label define mgcauselbl 00 "NIU"
label define mgcauselbl 10 "Seeking work", add
label define mgcauselbl 20 "Family move", add
label define mgcauselbl 30 "Changed workplace", add
label define mgcauselbl 40 "Study", add
label define mgcauselbl 50 "Married or in union", add
label define mgcauselbl 60 "Other reason", add
label define mgcauselbl 61 "Health", add
label define mgcauselbl 62 "Violence or insecurity", add
label define mgcauselbl 63 "Calamity", add
label define mgcauselbl 64 "Repatriation", add
label define mgcauselbl 65 "Visiting", add
label define mgcauselbl 66 "Other reason, not elsewhere classified", add
label define mgcauselbl 99 "Not specified", add
label values mgcause mgcauselbl

label define mx00a_imsslbl 1 "Yes"
label define mx00a_imsslbl 2 "No", add
label define mx00a_imsslbl 9 "Unknown", add
label values mx00a_imss mx00a_imsslbl

label define mx00a_resmunlbl 000 "NIU"
label define mx00a_resmunlbl 999 "Unknown", add
label values mx00a_resmun mx00a_resmunlbl

label define mx00a_wkmunlbl 999 "NIU"
label values mx00a_wkmun mx00a_wkmunlbl

label define mx00a_wkstlbl 000 "NIU"
label define mx00a_wkstlbl 001 "Aguascalientes", add
label define mx00a_wkstlbl 002 "Baja California", add
label define mx00a_wkstlbl 003 "Baja California Sur", add
label define mx00a_wkstlbl 004 "Campeche", add
label define mx00a_wkstlbl 005 "Coahuila", add
label define mx00a_wkstlbl 006 "Colima", add
label define mx00a_wkstlbl 007 "Chiapas", add
label define mx00a_wkstlbl 008 "Chihuahua", add
label define mx00a_wkstlbl 009 "Distrito Federal", add
label define mx00a_wkstlbl 010 "Durango", add
label define mx00a_wkstlbl 011 "Guanajuato", add
label define mx00a_wkstlbl 012 "Guerrero", add
label define mx00a_wkstlbl 013 "Hidalgo", add
label define mx00a_wkstlbl 014 "Jalisco", add
label define mx00a_wkstlbl 015 "Mexico", add
label define mx00a_wkstlbl 016 "Michoacan", add
label define mx00a_wkstlbl 017 "Morelos", add
label define mx00a_wkstlbl 018 "Nayarit", add
label define mx00a_wkstlbl 019 "Nuevo Leon", add
label define mx00a_wkstlbl 020 "Oaxaca", add
label define mx00a_wkstlbl 021 "Puebla", add
label define mx00a_wkstlbl 022 "Queretaro", add
label define mx00a_wkstlbl 023 "Quintana Roo", add
label define mx00a_wkstlbl 024 "San Luis Potosi", add
label define mx00a_wkstlbl 025 "Sinaloa", add
label define mx00a_wkstlbl 026 "Sonora", add
label define mx00a_wkstlbl 027 "Tabasco", add
label define mx00a_wkstlbl 028 "Tamaulipas", add
label define mx00a_wkstlbl 029 "Tlaxcala", add
label define mx00a_wkstlbl 030 "Veracruz", add
label define mx00a_wkstlbl 031 "Yucatan", add
label define mx00a_wkstlbl 032 "Zacatecas", add
label define mx00a_wkstlbl 117 "Egypt", add
label define mx00a_wkstlbl 118 "Eritrea", add
label define mx00a_wkstlbl 119 "Ethiopia", add
label define mx00a_wkstlbl 135 "Morocco", add
label define mx00a_wkstlbl 200 "America", add
label define mx00a_wkstlbl 204 "Argentina", add
label define mx00a_wkstlbl 208 "Belize", add
label define mx00a_wkstlbl 210 "Bolivia", add
label define mx00a_wkstlbl 211 "Brazil", add
label define mx00a_wkstlbl 213 "Canada", add
label define mx00a_wkstlbl 214 "Colombia", add
label define mx00a_wkstlbl 215 "Costa Rica", add
label define mx00a_wkstlbl 216 "Cuba", add
label define mx00a_wkstlbl 217 "Chile", add
label define mx00a_wkstlbl 219 "Ecuador", add
label define mx00a_wkstlbl 220 "El Salvador", add
label define mx00a_wkstlbl 221 "United States of America", add
label define mx00a_wkstlbl 222 "Grenada", add
label define mx00a_wkstlbl 225 "Guatemala", add
label define mx00a_wkstlbl 227 "French Guyana", add
label define mx00a_wkstlbl 228 "Haiti", add
label define mx00a_wkstlbl 229 "Honduras", add
label define mx00a_wkstlbl 230 "Jamaica", add
label define mx00a_wkstlbl 234 "Nicaragua", add
label define mx00a_wkstlbl 235 "Panama", add
label define mx00a_wkstlbl 237 "Peru", add
label define mx00a_wkstlbl 238 "Puerto Rico", add
label define mx00a_wkstlbl 239 "Dominican Republic", add
label define mx00a_wkstlbl 247 "Uruguay", add
label define mx00a_wkstlbl 250 "Venezuela", add
label define mx00a_wkstlbl 313 "South Korea", add
label define mx00a_wkstlbl 315 "People's Republic of China", add
label define mx00a_wkstlbl 317 "Cyprus", add
label define mx00a_wkstlbl 322 "Philippines", add
label define mx00a_wkstlbl 323 "Georgia", add
label define mx00a_wkstlbl 325 "India", add
label define mx00a_wkstlbl 329 "Israel", add
label define mx00a_wkstlbl 330 "Japan", add
label define mx00a_wkstlbl 400 "Europa", add
label define mx00a_wkstlbl 402 "Germany", add
label define mx00a_wkstlbl 415 "Spain", add
label define mx00a_wkstlbl 419 "France", add
label define mx00a_wkstlbl 423 "Ireland", add
label define mx00a_wkstlbl 425 "Italy", add
label define mx00a_wkstlbl 435 "Norway", add
label define mx00a_wkstlbl 437 "Poland", add
label define mx00a_wkstlbl 439 "United Kingdon", add
label define mx00a_wkstlbl 442 "Russia", add
label define mx00a_wkstlbl 446 "Switzerland", add
label define mx00a_wkstlbl 501 "Australia", add
label define mx00a_wkstlbl 505 "Guam Island", add
label define mx00a_wkstlbl 600 "Foreigner, Other country", add
label define mx00a_wkstlbl 999 "Unknown", add
label values mx00a_wkst mx00a_wkstlbl

save mexico_censo_05.dta, replace
