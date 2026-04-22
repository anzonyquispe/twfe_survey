*Policy Effects Years 4+ FOCS or GNCS
*focs - men
lincom focs-pre1
*focs - women
lincom focs+f_focs-pre1-f_pre1
*gncs - men
lincom gncs-pre1
*gncs - women
lincom gncs+f_gncs-pre1-f_pre1
* (gncs-focs) male
lincom gncs-focs
* (gncs-focs) female
lincom gncs+f_gncs - focs - f_focs
* (male-female) focs
lincom -f_focs+f_pre1
* (male-female) gncs
lincom -f_gncs+f_pre1

*Policy Effects Years 0-3 of FOCS or GNCS
* early focs - men
lincom focs+focs0-pre1
* early focs - women
lincom focs+f_focs+focs0+f_focs0-pre1-f_pre1
* early gncs - men
lincom gncs+gncs0-pre1
* early gncs - women
lincom gncs+f_gncs+gncs0+f_gncs0-pre1-f_pre1
* early (gncs-focs) male
lincom gncs+gncs0-focs-focs0
* early (gncs-focs) female
lincom gncs+f_gncs+gncs0+f_gncs0-focs-f_focs-focs0-f_focs0
* early (male-female) focs
lincom -f_focs-f_focs0+f_pre1
* early (male-female) gncs
lincom -f_gncs-f_gncs0+f_pre1

*Pre First Policy Year Effects of FOCS or GNCS (relative to period prior to first policy)
lincom pre3-pre1
lincom pre3+f_pre3-pre1-f_pre1
lincom pre2-pre1
lincom pre2+f_pre2-pre1-f_pre1
* male-female diff relative to pre1
lincom - f_pre3+f_pre1
lincom - f_pre2+f_pre1
