## ----eval=FALSE---------------------------------------------------------------
## MinMode = function(x){
##     ta = table(x)
##     tam = max(ta)
##     if(is.numeric(x))
##          mod = as.numeric(names(ta)[ta == tam])
##     else
##          mod = names(ta)[ta == tam]
##     mod = ifelse("TM" %in% mod,"TM",
##            ifelse("M" %in% mod, "M",
##                   ifelse("MOY" %in% mod, "MOY",
##                          ifelse("B" %in% mod, "B",
##                                 ifelse("TB" %in% mod, "TB",
##                                 NA)))))
##     return(mod)}

