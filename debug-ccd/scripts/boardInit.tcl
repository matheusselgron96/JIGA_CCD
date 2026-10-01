namespace eval boardInit {

    variable initialized 0
    variable errors 0
    variable sofFilename "sof/ccd.sof"
    variable sofFilename2 "sof/ccd_v3.0.0.sof"
    variable qsys_headerFilename "headers/test_sys_top_qsys.tcl"
    variable masterPath ""
    variable bytestreamPath ""
    variable jtaguartPath ""
    variable dash_path ""
    variable dashboardActive 0

    proc init {} {

        if { ${::boardInit::initialized} == 1 } {
            return -code ok "already initialized"
        }

        set ::boardInit::errors 0

        #
        # make sure that the SOF files exist
        #
        if { ![ file isfile ${::boardInit::sofFilename} ] } {
            set ::boardInit::errors 1
            #::boardInit::updateDashboard
            return -code error "unable to locate SOF file"
        }

        #
        # make sure that BeMicroSDK board appears to be the only board available
        #
        if { [ llength [ get_service_paths device ] ] > 1 } {
            set ::boardInit::errors 1
            #::boardInit::updateDashboard
            return -code error "too many devices located"
        }

        if { [ llength [ get_service_paths device ] ] == 0 } {
            set ::boardInit::errors 1
            #::boardInit::updateDashboard
            return -code error "no devices located"
        }

        #if { [ lsearch [ get_service_paths device ] "*EP3C25|EP4CE22@1*" ] < 0 } {
        #    set ::boardInit::errors 1
        #    ::boardInit::updateDashboard
        #    return -code error "the one device available does not appear to be a BeMicro SDK"
        #}

        #
        # download the SOF file into the device
        #

        
        

    

        device_download_sof [ get_service_paths device ] ${::boardInit::sofFilename}

        #
        # setup the service path variables
        #

        #if { [ lsearch [ get_service_paths bytestream ] "*/jtag_uart.jtag" ] < 0 } {
        #    set ::boardInit::errors 1
        #    ::boardInit::updateDashboard
        #    return -code error "jtaguart service path was not identified correctly"
        #}

        #if { [  lsearch [ get_service_paths bytestream ] "*/phy_1" ] < 0 } {
        #    set ::boardInit::errors 1
        #    ::boardInit::updateDashboard
        #    return -code error "bytestream service path was not identified correctly"
        #}

        set service_paths [get_service_paths master]
        set master_service_path [lindex $service_paths 0]
        set ::boardInit::masterPath  [claim_service master $master_service_path mylib]
      
        #set ::boardInit::masterPath     [ lindex [ get_service_paths master ] [ lsearch [ get_service_paths master ] "*/phy_0/master_0.master" ] ]
        #set ::boardInit::jtaguartPath    [ lindex [ get_service_paths bytestream ] [ lsearch [ get_service_paths bytestream ] "*/jtag_uart.jtag" ] ]
        #set ::boardInit::bytestreamPath    [ lindex [ get_service_paths bytestream ] [  lsearch [ get_service_paths bytestream ] "*/phy_1" ] ]
        
        #
        # load the Qsys header namespace if it isn't already loaded
        #
        if { ![ namespace exists ::QSYS_HEADER ] } {
            if { ![ file isfile ${::boardInit::qsys_headerFilename} ] } {
                set ::boardInit::errors 1
               # ::boardInit::updateDashboard
                return -code error "unable to locate Qsys header file"
            }
            namespace eval :: {
                source ${::boardInit::qsys_headerFilename}
            }
            if { ![ namespace exists ::QSYS_HEADER ] } {
                set ::boardInit::errors 1
               # ::boardInit::updateDashboard
                return -code error "Qsys header did not load properly"
            }
        }

        set ::boardInit::initialized 1

        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_NIOS_WRITE_LED_BASE} + 0 ] 0xF

        #::boardInit::updateDashboard
        return -code ok
    }

}
