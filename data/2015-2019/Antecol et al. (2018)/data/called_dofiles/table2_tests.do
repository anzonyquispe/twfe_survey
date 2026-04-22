*Policy Effects Years 4+ FOCS or GNCS
*focs - men
lincom focs
*focs - women
lincom focs+f_focs
*gncs - men
lincom gncs
*gncs - women
lincom gncs+f_gncs
* (gncs-focs) male
lincom gncs-focs
* (gncs-focs) female
lincom gncs+f_gncs - focs - f_focs
* (male-female) focs
lincom -f_focs
* (male-female) gncs
lincom -f_gncs

*Policy Effects Years 0-3 of FOCS or GNCS
* early focs - men
lincom focs+focs0
* early focs - women
lincom focs+f_focs+focs0+f_focs0
* early gncs - men
lincom gncs+gncs0
* early gncs - women
lincom gncs+f_gncs+gncs0+f_gncs0
* early (gncs-focs) male
lincom gncs+gncs0-focs-focs0
* early (gncs-focs) female
lincom gncs+f_gncs+gncs0+f_gncs0-focs-f_focs-focs0-f_focs0
* early (male-female) focs
lincom -f_focs-f_focs0
* early (male-female) gncs
lincom -f_gncs-f_gncs0
