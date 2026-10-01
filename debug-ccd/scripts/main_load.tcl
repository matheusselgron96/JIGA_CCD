source boardInit.tcl
source ctrlPIO.tcl

::ctrlPIO::dashBoard
#::boardInit::dashBoard

proc myInit {} {
    ::boardInit::init
}
proc myVal {} {
    ::boardInit::init
    ::ctrlPIO::dashBoard
}
