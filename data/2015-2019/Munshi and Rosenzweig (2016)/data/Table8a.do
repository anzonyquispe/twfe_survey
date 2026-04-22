#delimit ;

use table8a.dta, clear ;

cgmwildboot dpout10     pdinc10 pjdincx10 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999);

cgmwildboot dpout10     pdinc10 pjdincx10 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999) null(0 0 . . . .);

cgmwildboot dpoutvb5     pdinc5 pjdincx5 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999);

cgmwildboot dpoutvb5     pdinc5 pjdincx5 mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999) null(0 0 . . . .);

use table8b.dta, clear ;

cgmwildboot deither     pdinc pjdincx mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999);

cgmwildboot deither     pdinc pjdincx mark3d jmark3d  share71 jshare71,   cluster(state) bootcluster(state) seed(999) null(0 0 . . . .);




