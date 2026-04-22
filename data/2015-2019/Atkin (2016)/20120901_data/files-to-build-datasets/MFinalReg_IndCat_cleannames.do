
local clean=subinstr("`interact'","_","",.)

if regexm("`clean'","ratio")==1 {
local clean=subinstr("`clean'","fem","f",.)
local clean=subinstr("`clean'","male","m",.)
local clean=subinstr("`clean'","nat","n",.)
local clean=subinstr("`clean'","sta","s",.)
local clean=subinstr("`clean'","delta","d",.)
local clean=subinstr("`clean'","hifi","h",.)
local clean=subinstr("`clean'","ratio","ra",.)
}


if regexm("`clean'","^s")==1 {
local clean=subinstr("`clean'","9m","",.)
local clean=subinstr("`clean'","wg","w",.)
local clean=subinstr("`clean'","vg","v",.)
local clean=subinstr("`clean'","sexp","indse",.)
local clean=subinstr("`clean'","sdif","indsd",.)
local clean=subinstr("`clean'","sschl","indss",.)
}


if regexm("`clean'","ind.age.*cat.*")==1 {
local clean=subinstr("`clean'","age","ag",.)

local clean=subinstr("`clean'","blue","b",.)
local clean=subinstr("`clean'","cat","c",.)

local clean=subinstr("`clean'","mig","m",.)
local clean=subinstr("`clean'","inf","a",.)
local clean=subinstr("`clean'","bme","b",.)
local clean=subinstr("`clean'","cme","c",.)
local clean=subinstr("`clean'","dme","d",.)
local clean=subinstr("`clean'","cne","f",.)
local clean=subinstr("`clean'","bne","g",.)

local clean=subinstr("`clean'","schl","s",.)
local clean=subinstr("`clean'","indm","ind",.)
}


if regexm("`clean'","ind.age.*")==1 {
local clean=subinstr("`clean'","infadj","a",.)
local clean=subinstr("`clean'","migadj","m",.)
local clean=subinstr("`clean'","indm","inde",.)
}

if regexm("`clean'","indmnschl.*male.*")==1    {
local clean=subinstr("`clean'","mnschl","mns",.)
local clean=subinstr("`clean'","male","",1)
local clean=subinstr("`clean'","cat","c",.)
local clean=subinstr("`clean'","nor","n",.)
local clean=subinstr("`clean'","exp","e",.)
local clean=subinstr("`clean'","inf","i",.)
local clean=subinstr("`clean'","old","o",.)
local clean=subinstr("`clean'","pld","p",.)
local clean=subinstr("`clean'","mig","m",.)
}
if regexm("`clean'","indmnschl.*fem.*")==1    {
local clean=subinstr("`clean'","mnschl","fns",.)
local clean=subinstr("`clean'","fem","",1)
local clean=subinstr("`clean'","cat","c",.)
local clean=subinstr("`clean'","nor","n",.)
local clean=subinstr("`clean'","exp","e",.)
local clean=subinstr("`clean'","inf","i",.)
local clean=subinstr("`clean'","old","o",.)
local clean=subinstr("`clean'","pld","p",.)
local clean=subinstr("`clean'","mig","m",.)
}
if regexm("`clean'","indmnschl.*emp.*")==1    {
local clean=subinstr("`clean'","mnschl","ens",.)
local clean=subinstr("`clean'","emp","",1)
local clean=subinstr("`clean'","cat","c",.)
local clean=subinstr("`clean'","nor","n",.)
local clean=subinstr("`clean'","exp","e",.)
local clean=subinstr("`clean'","inf","i",.)
local clean=subinstr("`clean'","old","o",.)
local clean=subinstr("`clean'","mig","m",.)
local clean=subinstr("`clean'","pld","p",.)
}


if regexm("`clean'","ind.schl.*cat.h.*")==1  | regexm("`clean'","ind.blue.*cat.h.*")==1  {
local clean=subinstr("`clean'","schl","scl",.)
local clean=subinstr("`clean'","h","",1)
local clean=subinstr("`clean'","indmblue","indhbl",.)
local clean=subinstr("`clean'","indmscl","indhsc",.)
local clean=subinstr("`clean'","cat","c",.)
local clean=subinstr("`clean'","infadj","a",.)
local clean=subinstr("`clean'","migadj","m",.)
}

if regexm("`clean'","ind.schl.*cat.f.*")==1  | regexm("`clean'","ind.blue.*cat.f.*")==1 {
local clean=subinstr("`clean'","f","",1)
local clean=subinstr("`clean'","indmblue","indfbl",.)
local clean=subinstr("`clean'","indmschl","indfsc",.)
local clean=subinstr("`clean'","cat","c",.)
local clean=subinstr("`clean'","infadj","a",.)
local clean=subinstr("`clean'","migadj","m",.)
}


if regexm("`clean'","indhschl.*cat.*")==1 | regexm("`clean'","indhblue.*cat.*")==1 | regexm("`clean'","indfschl.*cat.*")==1 | regexm("`clean'","indfblue.*cat.*")==1{
local clean=subinstr("`clean'","cat","c",.)
local clean=subinstr("`clean'","blue","bl",.)
local clean=subinstr("`clean'","schl","sc",.)
local clean=subinstr("`clean'","infadj","a",.)
local clean=subinstr("`clean'","migadj","m",.)
}



if regexm("`clean'","ind.schl.*cat.*")==1 | regexm("`clean'","ind.blue.*cat.*")==1 {
local clean=subinstr("`clean'","cat","c",.)
}



if  regexm("`clean'","indfw*")==1 | regexm("`clean'","indfv*")==1 | regexm("`clean'","indhw*")==1 | regexm("`clean'","indhv*")==1  {
local clean=subinstr("`clean'","schlz","z",.)
local clean=subinstr("`clean'","blue","b",.)
local clean=subinstr("`clean'","mig","m",.)
local clean=subinstr("`clean'","inf","a",.)
local clean=subinstr("`clean'","cat","c",.)
}


if  regexm("`clean'","ind.w.schl.*cat.h.*")==1 | regexm("`clean'","ind.v.schl.*cat.h.*")==1 | regexm("`clean'","ind.w.blue.*cat.h.*")==1 | regexm("`clean'","ind.v.blue.*cat.h.*")==1 {
local clean=subinstr("`clean'","schlz","z",.)
local clean=subinstr("`clean'","blue","b",.)
local clean=subinstr("`clean'","mig","m",.)
local clean=subinstr("`clean'","inf","a",.)
local clean=subinstr("`clean'","h","",1)
local clean=subinstr("`clean'","indmwn","indhwn",.)
local clean=subinstr("`clean'","indmvn","indhvn",.)
local clean=subinstr("`clean'","indmvg","indhvg",.)
local clean=subinstr("`clean'","cat","c",.)
}

if    regexm("`clean'","ind.w.schl.*cat.f.*")==1 | regexm("`clean'","ind.v.schl.*cat.f.*")==1 | regexm("`clean'","ind.w.blue.*cat.f.*")==1 | regexm("`clean'","ind.v.blue.*cat.f.*")==1 {
local clean=subinstr("`clean'","schlz","z",.)
local clean=subinstr("`clean'","blue","b",.)
local clean=subinstr("`clean'","mig","m",.)
local clean=subinstr("`clean'","inf","a",.)
local clean=subinstr("`clean'","f","",1)
local clean=subinstr("`clean'","indmwn","indfwn",.)
local clean=subinstr("`clean'","indmvn","indfvn",.)
local clean=subinstr("`clean'","indmvg","indfvg",.)
local clean=subinstr("`clean'","cat","c",.)
local clean=subinstr("`clean'","blue","b",.)
}

if regexm("`clean'","ind.schl.*cat.*")==1 | regexm("`clean'","ind.blue.*cat.*")==1 {
local clean=subinstr("`clean'","cat","c",.)
}







if regexm("`clean'","ind.w.*cat.*")==1 | regexm("`clean'","ind.v.*cat.*")==1 {
local clean=subinstr("`clean'","cat","c",.)
local clean=subinstr("`clean'","mig","m",.)
local clean=subinstr("`clean'","inf","a",.)
local clean=subinstr("`clean'","bme","b",.)
local clean=subinstr("`clean'","cme","c",.)
local clean=subinstr("`clean'","dme","d",.)
local clean=subinstr("`clean'","cne","f",.)
local clean=subinstr("`clean'","bne","g",.)

local clean=subinstr("`clean'","schl","s",.)
local clean=subinstr("`clean'","indm","ind",.)
}




local clean=subinstr("`clean'","nor1dig","d",.)
local clean=subinstr("`clean'","inf1dig","j",.)





***ignore these
local clean=subinstr("`clean'","indmwischl","indwis",.)
local clean=subinstr("`clean'","indmweschl","indwes",.)
local clean=subinstr("`clean'","indmwnschl","indwns",.)
local clean=subinstr("`clean'","indmwkschl","indwks",.)
local clean=subinstr("`clean'","indmwgschl","indwgs",.)
local clean=subinstr("`clean'","indmwmschl","indwms",.)
local clean=subinstr("`clean'","indmvischl","indvis",.)
local clean=subinstr("`clean'","indmveschl","indves",.)
local clean=subinstr("`clean'","indmvnschl","indvns",.)
local clean=subinstr("`clean'","indmvkschl","indvks",.)
local clean=subinstr("`clean'","indmvgschl","indvgs",.)
local clean=subinstr("`clean'","indmvmschl","indvms",.)
local clean=subinstr("`clean'","indmwiblue","indwibl",.)
local clean=subinstr("`clean'","indmweblue","indwebl",.)
local clean=subinstr("`clean'","indmwnblue","indwnbl",.)
local clean=subinstr("`clean'","indmwkblue","indwkbl",.)
local clean=subinstr("`clean'","indmwgblue","indwgbl",.)
local clean=subinstr("`clean'","indmwmblue","indwmbl",.)
local clean=subinstr("`clean'","indmviblue","indvibl",.)
local clean=subinstr("`clean'","indmveblue","indvebl",.)
local clean=subinstr("`clean'","indmvnblue","indvnbl",.)
local clean=subinstr("`clean'","indmvkblue","indvkbl",.)
local clean=subinstr("`clean'","indmvgblue","indvgbl",.)
local clean=subinstr("`clean'","indmvmblue","indvmbl",.)


local clean=subinstr("`clean'","indmweperca","indweeo",.)
local clean=subinstr("`clean'","indfweperca","indwefo",.)
local clean=subinstr("`clean'","indhweperca","indwemo",.)
local clean=subinstr("`clean'","indmwiperca","indwieo",.)
local clean=subinstr("`clean'","indfwiperca","indwifo",.)
local clean=subinstr("`clean'","indhwiperca","indwimo",.)
local clean=subinstr("`clean'","indmwnperca","indwneo",.)
local clean=subinstr("`clean'","indfwnperca","indwnfo",.)
local clean=subinstr("`clean'","indhwnperca","indwnmo",.)
local clean=subinstr("`clean'","indmwgperca","indwgeo",.)
local clean=subinstr("`clean'","indfwgperca","indwgfo",.)
local clean=subinstr("`clean'","indhwgperca","indwgmo",.)
local clean=subinstr("`clean'","indmperca","indeo",.)
local clean=subinstr("`clean'","indfperca","indfo",.)
local clean=subinstr("`clean'","indhperca","indmo",.)
local clean=subinstr("`clean'","indmvischl","indvis",.)
local clean=subinstr("`clean'","indmveschl","indves",.)
local clean=subinstr("`clean'","indmvnschl","indvns",.)
local clean=subinstr("`clean'","indmveperca","indveeo",.)
local clean=subinstr("`clean'","indfveperca","indvefo",.)
local clean=subinstr("`clean'","indhveperca","indvemo",.)
local clean=subinstr("`clean'","indmviperca","indvieo",.)
local clean=subinstr("`clean'","indfviperca","indvifo",.)
local clean=subinstr("`clean'","indhviperca","indvimo",.)
local clean=subinstr("`clean'","indmvnperca","indvneo",.)
local clean=subinstr("`clean'","indfvnperca","indvnfo",.)
local clean=subinstr("`clean'","indhvnperca","indvnmo",.)
local clean=subinstr("`clean'","indmvgperca","indvgeo",.)
local clean=subinstr("`clean'","indfvgperca","indvgfo",.)
local clean=subinstr("`clean'","indhvgperca","indvgmo",.)
local clean=subinstr("`clean'","indmwiaperca","indwiea",.)
local clean=subinstr("`clean'","indfwiaperca","indwifa",.)
local clean=subinstr("`clean'","indhwiaperca","indwima",.)
local clean=subinstr("`clean'","indmwnaperca","indwnea",.)
local clean=subinstr("`clean'","indfwnaperca","indwnfa",.)
local clean=subinstr("`clean'","indhwnaperca","indwnma",.)
local clean=subinstr("`clean'","indmwgaperca","indwgea",.)
local clean=subinstr("`clean'","indfwgaperca","indwgfa",.)
local clean=subinstr("`clean'","indhwgaperca","indwgma",.)
local clean=subinstr("`clean'","indmaperca","indea",.)
local clean=subinstr("`clean'","indfaperca","indfa",.)
local clean=subinstr("`clean'","indhaperca","indma",.)
local clean=subinstr("`clean'","indmwicperca","indwiec",.)
local clean=subinstr("`clean'","indfwicperca","indwifc",.)
local clean=subinstr("`clean'","indhwicperca","indwimc",.)
local clean=subinstr("`clean'","indmwncperca","indwnec",.)
local clean=subinstr("`clean'","indfwncperca","indwnfc",.)
local clean=subinstr("`clean'","indhwncperca","indwnmc",.)
local clean=subinstr("`clean'","indmwgcperca","indwgec",.)
local clean=subinstr("`clean'","indfwgcperca","indwgfc",.)
local clean=subinstr("`clean'","indhwgcperca","indwgmc",.)
local clean=subinstr("`clean'","indmcperca","indec",.)
local clean=subinstr("`clean'","indfcperca","indfc",.)
local clean=subinstr("`clean'","indhcperca","indmc",.)
local clean=subinstr("`clean'","indmwidperca","indwied",.)
local clean=subinstr("`clean'","indfwidperca","indwifd",.)
local clean=subinstr("`clean'","indhwidperca","indwimd",.)
local clean=subinstr("`clean'","indmwndperca","indwned",.)
local clean=subinstr("`clean'","indfwndperca","indwnfd",.)
local clean=subinstr("`clean'","indhwndperca","indwnmd",.)
local clean=subinstr("`clean'","indmwgdperca","indwged",.)
local clean=subinstr("`clean'","indfwgdperca","indwgfd",.)
local clean=subinstr("`clean'","indhwgdperca","indwgmd",.)
local clean=subinstr("`clean'","indmdperca","inded",.)
local clean=subinstr("`clean'","indfdperca","indfd",.)
local clean=subinstr("`clean'","indhdperca","indmd",.)
local clean=subinstr("`clean'","indmwijperca","indwiej",.)
local clean=subinstr("`clean'","indfwijperca","indwifj",.)
local clean=subinstr("`clean'","indhwijperca","indwimj",.)
local clean=subinstr("`clean'","indmwnjperca","indwnej",.)
local clean=subinstr("`clean'","indfwnjperca","indwnfj",.)
local clean=subinstr("`clean'","indhwnjperca","indwnmj",.)
local clean=subinstr("`clean'","indmwgjperca","indwgej",.)
local clean=subinstr("`clean'","indfwgjperca","indwgfj",.)
local clean=subinstr("`clean'","indhwgjperca","indwgmj",.)
local clean=subinstr("`clean'","indmjperca","indej",.)
local clean=subinstr("`clean'","indfjperca","indfj",.)
local clean=subinstr("`clean'","indhjperca","indmj",.)
local clean=subinstr("`clean'","indmwikperca","indwiek",.)
local clean=subinstr("`clean'","indfwikperca","indwifk",.)
local clean=subinstr("`clean'","indhwikperca","indwimk",.)
local clean=subinstr("`clean'","indmwnkperca","indwnek",.)
local clean=subinstr("`clean'","indfwnkperca","indwnfk",.)
local clean=subinstr("`clean'","indhwnkperca","indwnmk",.)
local clean=subinstr("`clean'","indmwgkperca","indwgek",.)
local clean=subinstr("`clean'","indfwgkperca","indwgfk",.)
local clean=subinstr("`clean'","indhwgkperca","indwgmk",.)
local clean=subinstr("`clean'","indmkperca","indek",.)
local clean=subinstr("`clean'","indfkperca","indfk",.)
local clean=subinstr("`clean'","indhkperca","indmk",.)
*****






local clean=subinstr("`clean'","indmblue","indebl",.)
local clean=subinstr("`clean'","indmschl","indesc",.)

local clean=subinstr("`clean'","indfblue","indffbl",.)
local clean=subinstr("`clean'","indhblue","indmmbl",.)
local clean=subinstr("`clean'","indfschl","indffsc",.)
local clean=subinstr("`clean'","indhschl","indmmsc",.)



local clean=subinstr("`clean'","indmw","indew",.)
local clean=subinstr("`clean'","indmv","indev",.)
local clean=subinstr("`clean'","indhw","indmw",.)
local clean=subinstr("`clean'","indhv","indmv",.)
local clean=subinstr("`clean'","indmsc","indesc",.)
local clean=subinstr("`clean'","indhsc","indmsc",.)

local clean=subinstr("`clean'","indmwgschl","indwgs",.)
local clean=subinstr("`clean'","indmschl","inds",.)




local clean=subinstr("`clean'","infadj","a",.)
local clean=subinstr("`clean'","migadj","m",.)
local clean=subinstr("`clean'","bmeadj","b",.)
local clean=subinstr("`clean'","cmeadj","c",.)
local clean=subinstr("`clean'","dmeadj","d",.)

*local clean=subinstr("`clean'","madj","m",.)
*local clean=subinstr("`clean'","iadj","i",.)


local clean=subinstr("`clean'","nonmigrant","nzig",.)
local clean=subinstr("`clean'","indmsch","indms",.)
local clean=subinstr("`clean'","indmwg5e","indmew",.)
local clean=subinstr("`clean'","indmwg","indmw",.)
local clean=subinstr("`clean'","indmrur","indmr",.)
local clean=subinstr("`clean'","indmmig","indmm",.)
local clean=subinstr("`clean'","indmsbin","indmb",.)
local clean=subinstr("`clean'","norpur","p",.)
local clean=subinstr("`clean'","nor","n",.)
local clean=subinstr("`clean'","exppw","xxppw",.)
local clean=subinstr("`clean'","expmpw","xxpmpw",.)
local clean=subinstr("`clean'","exp","e",.)
local clean=subinstr("`clean'","xxppw","exppw",.)
local clean=subinstr("`clean'","xxpmpw","expmpw",.)

local clean=subinstr("`clean'","inf","i",.)
local clean=subinstr("`clean'","mig","b",.)

local clean=subinstr("`clean'","cne","f",.)
local clean=subinstr("`clean'","bne","g",.)
local clean=subinstr("`clean'","cme","c",.)
local clean=subinstr("`clean'","bme","b",.)
local clean=subinstr("`clean'","dme","d",.)

local clean=subinstr("`clean'","zig","mig",.)
local clean=subinstr("`clean'","npur","p",.)


local clean=subinstr("`clean'","sch","sc",.)
local clean=subinstr("`clean'","wage","wg",.)
local clean=subinstr("`clean'","all","a",.)
local clean=subinstr("`clean'","bin","b",.)
*local clean=subinstr("`clean'","ind","",.)
local clean=subinstr("`clean'","ageold","ao",.)
local clean=subinstr("`clean'","old","o",.)
local clean=subinstr("`clean'","pld","p",.)
local clean=subinstr("`clean'","dif","df",.)
local clean=subinstr("`clean'","rat","rt",.)
local clean=subinstr("`clean'","df20","df2",.)
local clean=subinstr("`clean'","rt20","rt2",.)

if regexm("`clean'","df90ra")!=1 {
local clean=subinstr("`clean'","df90","df9",.)
}
if regexm("`clean'","dm90ra")!=1 {
local clean=subinstr("`clean'","dm90","dm9",.)
}
local clean=subinstr("`clean'","rt90","rt9",.)




if length("`clean'")>13 {
local clean=subinstr("`clean'","ddf","dd",.)
}

if length("`clean'")>13 {

local a1=substr("`clean'",4,1)
local a2=substr("`clean'",7,1)
local abbrev "`a1'`a2'"
local ends=substr("`clean'",-8,.)
}
else {
local abbrev=substr("`clean'",4,.)
local ends=""
}
noi di "`thing'`abbrev'`ends'_"
