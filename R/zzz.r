.onAttach <- function(libname, pkgname) {
   rJava::.jpackage(pkgname, jars = "*", lib.loc = libname)
   stop_logging()
}