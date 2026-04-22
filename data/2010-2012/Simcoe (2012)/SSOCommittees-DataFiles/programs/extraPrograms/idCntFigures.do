********************************
*
* Extra Figure: Proposal Counts
*
********************************
use stata/idLevel, clear

* Variables
g wgIDs = (wgDum)
g indIDs = (!wgDum)
graph bar (sum) wgIDs indIDs if pubCohort>=1993 & pubCohort<=2004, over(pubCohort) stack legend(lab(1 "WG Drafts") lab(2 "Individual Drafts"))
graph export figures/idSubmissionCounts.pdf, replace
