#delimit;

local syr: piece 2 2 of "${passthru_lyr}";

infix

	newid 1-8
	age_ref 11-13
	str age_ref_ 14-14
	str sex_ref 903-903
	str sex_ref_ 904-904
	age2 15-17
	str age2_ 18-18
	str bls_urbn 70-70
	str cutenure 267-267
	str cute_ure 268-268
	str educ_ref 284-284
	str educ0ref 285-285
	str educa2 286-286
	str educa2_ 288-288
	fam_size 335-336
	str fam__ize 337-337
	str fam_type 338-338
	str fam__ype 339-339
	fincatax 386-394
	str fincat_x 395-395
	fincbtax 396-404
	str fincbt_x 405-405
	finincx 415-422
	str finicx_ 423-423
	finlwt21 424-434
	fpripenx 463-470
	str fpri_enx 471-471
	findretx 406-413
	str find_etx 414-414
	inc_hrs1 548-550
	str inc__rs1 551-551
	inc_hrs2 552-554
	str inc__rs2 555-555
	incweek1 616-617
	str incw_ek1 618-618
	incweek2 619-620
	str incw_ek2 621-621
	intearnx 631-638
	str inte_rnx 639-639
	jfdstmpa 640-647
	str jfds_mpa 648-648
	str marital1 673-673
	str mari_al1 674-674
	str origin1 739-739
	str origin1_ 740-740
	str origin2 741-741
	str origin2_ 742-742
	pensionx 775-782
	str pens_onx 783-783
	perslt18 784-785
	str pers_t18 786-786
	persot64 787-788
	str pers_t64 789-789
	str race2 828-828
	str race2_ 829-829
	str ref_race 830-830
	str ref__ace 831-831
	str region 832-832
	str respstat 840-840
	str resp_tat 841-841
	savacctx 861-870
	str sava_ctx 871-871
	str compsav 218-218
	str compsav_ 219-219
	compsavx 220-227
	str comp_avx 228-228
	ckbkactx 109-118
	str ckbk_ctx 119-119
	str compckg 183-183
	str compckg_ 184-184
	compckgx 185-192
	str comp_kgx 193-193
	usbndx 992-999
	str usbndx_ 1000-1000
	str compbnd 172-172
	str compbnd_ 173-173
	compbndx 174-181
	str comp_ndx 182-182
	secestx 872-881
	str secestx_ 882-882
	str compsec 229-229
	str compsec_ 230-230
	compsecx 231-238
	str comp_ecx 239-239
	foodpq 1551-1562
	foodcq 1563-1574
	str pov_cy 2256-2256
	str pov_cy_ 2257-2257
	str pov_py 2258-2258
	str pov_py_ 2259-2259
	str state 3528-3529
	renteqvx 833-838
	inclossa 586-593
	inclossb 595-602
	fsalaryx 490-497
	no_earnr 693-694
	earncomp 272
	str prinearn 793-794
	vehq 1001-1002
	str incomey1 608
	str incomey2 610
	nonincmx 712-719
		
using ${syf_root}\\${passthru_lyr}\Rawdata\cdrom\fmlyi`syr'${passthru_qtr}.txt, clear;

exit;

