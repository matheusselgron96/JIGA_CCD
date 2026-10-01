namespace eval ctrlPIO {

    variable initialized 0
    variable ledValue 0
    variable switchValue 0
    variable dash_path ""
    variable dashboardActive 0
    variable r1Gain 0
    variable r2Gain 0
    variable g1Gain 0
    variable g2Gain 0
    variable b1Gain 0
    variable b2Gain 0
    variable operator "nome"
    variable boardLabel 00
    set graph_data "signal"
    variable testLED 0
    variable testSwitch 0
    variable testLVDS 0
    variable testCCD 0
    variable writeInit 0
    variable writeRAMValue 0
    variable readRamValue 0
    variable readRamValue 0
    variable eraseRAMValue 0
    variable resetRAMValue 0
    variable spiValue 0
    variable NIOS 0
    variable switchError 0
    variable LEDError 0
    variable log_file
    variable WriteRam 0 
    variable ReadRam 0 
    variable CleanRam 0
    variable CleanedRam 0
    variable CCDOutTest [list 0 0 0]
    variable testSRAM [list 0 0 0 0] 
    variable LVDSTest1 0
    variable LVDSTest2 0
    variable LVDSTest3 0
    variable CCDRed 0
    variable CCDGreen 0
    variable CCDBlue 0 
    

    proc init {} {

        set ::ctrlPIO::ledValue [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_NIOS_WRITE_LED_BASE} + 0 ] 1 ] & 0xFF ]

        set ::ctrlPIO::switchValue [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_BOARD_ID_BASE} + 0 ] 1 ] & 0xFF ]

        set ::ctrlPIO::writeRAMValue [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_BOARD_ID_BASE} + 0 ] 1 ] & 0xFF ]
        
        set ::ctrlPIO::readRAMValue [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_BOARD_ID_BASE} + 0 ] 1 ] & 0xFF ]

        set ::ctrlPIO::eraseRAMValue [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_BOARD_ID_BASE} + 0 ] 1 ] & 0xFF ]

        set ::ctrlPIO::resetRAMValue [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_BOARD_ID_BASE} + 0 ] 1 ] & 0xFF ]

        set ::ctrlPIO::spiValue [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_SPI_VALUE_BASE} + 0 ] 1 ] & 0xFF ]

        set ::ctrlPIO::NIOS [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] 1 ] & 0xFF ]

        set ::ctrlPIO::initialized 1

        return -code ok
    }

    
    proc toggleLed { position } {

        variable mask [ expr ( 0x01 << ${position} ) & 0xFF ]
        variable inverted_mask [ expr ( 0xFF ^ ${mask} ) & 0xFF ]
        variable temp 0

        set temp [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_NIOS_WRITE_LED_BASE} + 0 ] 1 ] & 0xFF ]
        
        if { [ expr ${temp} & ${mask} ] } {
            set temp [ expr ${temp} & ${inverted_mask} ]
        } else {
            set temp [ expr ${temp} | ${mask} ]
        }
        
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_NIOS_WRITE_LED_BASE} + 0 ] ${temp} 

        return -code ok
    }


    proc sendRGBGain {channel gain} {
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_SPI_VALUE_BASE} + 0 ] ${gain}  
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] ${channel}
        after 500
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] 0

        return -code ok

    }

    proc readCCDData {channel} {

        return -code ok

    }

    proc writeRam {} {
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] 7
        ::ctrlPIO::writeText {TESTE SRAM = Iniciando Escrita de dados na SRAM}
        set status 10
        while {$status != 1} {
            dashboard_set_property ${::ctrlPIO::dash_path} ram0LED color "green_off"
            set status [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RETURN_NIOS_BASE} + 0 ] 1 ]]
        }
         ::ctrlPIO::writeText {TESTE SRAM = Escrita de dados na SRAM Finalizada}
        dashboard_set_property ${::ctrlPIO::dash_path} ram0LED color "green"
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] 0
        set ::ctrlPIO::WriteRam 1
        return -code ok
    }

    proc readRam {} {
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] 8
        ::ctrlPIO::writeText {TESTE SRAM = Iniciando Leitura de dados na SRAM}
        set status 10
        while {$status != 3} {
            master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] 8
            dashboard_set_property ${::ctrlPIO::dash_path} ram1LED color "green_off"
            set status [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RETURN_NIOS_BASE} + 0 ] 1 ]]
        }
        while {$status != 1} {
            dashboard_set_property ${::ctrlPIO::dash_path} ram1LED color "green_off"
            set status [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RETURN_NIOS_BASE} + 0 ] 1 ]]
            if {$status > 10} {
                ::ctrlPIO::writeText {TESTE SRAM = Leitura de dados na SRAM com erro}
                dashboard_set_property ${::ctrlPIO::dash_path} ram1LED color "red"
                set ::ctrlPIO::ReadRam 5
                return -code ok
            }
        }
        set ::ctrlPIO::ReadRam 1
        ::ctrlPIO::writeText {TESTE SRAM = Leitura de dados na SRAM concluída}
        dashboard_set_property ${::ctrlPIO::dash_path} ram1LED color "green"
        return -code ok
    }

    proc cleanRam {} {
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] 9
        ::ctrlPIO::writeText {TESTE SRAM = Iniciando Limpeza de dados na SRAM}
        set status 10
        while {$status != 1} {
            dashboard_set_property ${::ctrlPIO::dash_path} ram2LED color "green_off"
            set status [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RETURN_NIOS_BASE} + 0 ] 1 ]]
        }
        ::ctrlPIO::writeText {TESTE SRAM = Limpeza de dados na SRAM concluída}
        set ::ctrlPIO::CleanRam 1
        dashboard_set_property ${::ctrlPIO::dash_path} ram2LED color "green"
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] 0
        return -code ok
    }

    proc readcleanRam {} {
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] 10
        ::ctrlPIO::writeText {TESTE SRAM = Leitura de dados na SRAM em branco}
        set status 10
        while {$status != 3} {
            master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_JTAG_TO_NIOS_BASE} + 0 ] 8
            dashboard_set_property ${::ctrlPIO::dash_path} ram3LED color "green_off"
            set status [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RETURN_NIOS_BASE} + 0 ] 1 ]]
        }
        while {$status != 1} {
            dashboard_set_property ${::ctrlPIO::dash_path} ram3LED color "green_off"
            set status [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RETURN_NIOS_BASE} + 0 ] 1 ]]
            if {$status > 10} {
                ::ctrlPIO::writeText {TESTE SRAM = Leitura de dados na SRAM em branco com erro}
                dashboard_set_property ${::ctrlPIO::dash_path} ram1LED color "red"
                set ::ctrlPIO::CleanedRam 5
                return -code ok                  
            }
        }
        set ctrlPIO::CleanedRam 1
        ::ctrlPIO::writeText {TESTE SRAM = Leitura de dados na SRAM em branco concluída}
        dashboard_set_property ${::ctrlPIO::dash_path} ram3LED color "green"
        return -code ok

    }

    proc testLVDS {} {

        set ::ctrlPIO::LVDSTest1 0
        set ::ctrlPIO::LVDSTest2 0
        set ::ctrlPIO::LVDSTest3 0
        ::ctrlPIO::writeText {TESTE LVDS = Iniciando teste LVDS}
		::ctrlPIO::controlButtons 0
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RJ45_TESTER_0_BASE} + 0 ] 1
        set i 0
		set temp 0
        dashboard_set_property ${::ctrlPIO::dash_path} con0LED color "green_off"
        while {$i < 5000} {
            set temp [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RJ45_TESTER_0_BASE} + 0x4 ] 1 ]]
            incr i
        }
        if {[expr $temp == 2]} {
            set ::ctrlPIO::LVDSTest1 1
            ::ctrlPIO::writeText {TESTE LVDS = par LVDS 1 OK!}
            dashboard_set_property ${::ctrlPIO::dash_path} con0LED color "green"
        } else {
            set ::ctrlPIO::LVDSTest1 2
            ::ctrlPIO::writeText {TESTE LVDS = par LVDS 1 com erro!}
            dashboard_set_property ${::ctrlPIO::dash_path} con0LED color "red"
        }

        dashboard_set_property ${::ctrlPIO::dash_path} con1LED color "green_off"
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RJ45_TESTER_0_BASE} + 0x8 ] 1
        set i 0
		set temp 0
        while {$i < 5000} {
            set temp [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RJ45_TESTER_0_BASE} + 0xc ] 1 ]]
            incr i
        }
        if {[expr $temp == 2]} {
            set ::ctrlPIO::LVDSTest2 1
            ::ctrlPIO::writeText {TESTE LVDS = par LVDS 2 OK!}
            dashboard_set_property ${::ctrlPIO::dash_path} con1LED color "green"
        } else {
            set ::ctrlPIO::LVDSTest2 1
            ::ctrlPIO::writeText {TESTE LVDS = par LVDS 2 com erro!}
            dashboard_set_property ${::ctrlPIO::dash_path} con1LED color "red"
        }   

        dashboard_set_property ${::ctrlPIO::dash_path} con2LED color "green_off"
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RJ45_TESTER_0_BASE} + 0x10 ] 1
        set i 0
		set temp 0
        while {$i < 5000} {
            set temp [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RJ45_TESTER_0_BASE} + 0x14 ] 1 ]]
            incr i
        }
        if {[expr $temp == 2]} {
            set ::ctrlPIO::LVDSTest3 1
            ::ctrlPIO::writeText {TESTE LVDS = par LVDS 3 OK!}
            dashboard_set_property ${::ctrlPIO::dash_path} con2LED color "green"
        } else {
            set ::ctrlPIO::LVDSTest3 2
            ::ctrlPIO::writeText {TESTE LVDS = par LVDS 3 com erro!}
            dashboard_set_property ${::ctrlPIO::dash_path} con2LED color "red"
        } 
        ::ctrlPIO::writeText {TESTE LVDS = encerrado}
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RJ45_TESTER_0_BASE} + 0 ] 0
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RJ45_TESTER_0_BASE} + 0x8 ] 0
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_RJ45_TESTER_0_BASE} + 0x10 ] 0
		::ctrlPIO::controlButtons 1

        return -code ok

    }

    proc updateCCDdata {channel} {
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_SAVE_FIFO_BASE} + 0 ] 0
        master_write_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_SAVE_FIFO_BASE} + 0 ] 1

        set i 0
        set datared "signal"
        set datagreen "signal"
        set datablue "signal"
        dashboard_set_property ${::ctrlPIO::dash_path} updateCCDLed color "green_off"
        while {$i < 2048} {
            set temp [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_BOARD_ID_BASE} + 0 ] 1 ]]

            set dataeven [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_FIFO_EVEN_BASE} + 0 ] 1 ]]
            set dataodd [ expr [ master_read_32 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_FIFO_ODD_BASE} + 0 ] 1 ]]
            set r_even [expr $dataeven >> 16]
            set g_even [expr [expr $dataeven & 0x0000ff00] >> 8]    
            set b_even [expr $dataeven & 0x000000ff]

            lappend datared [list $i [expr {$r_even}]] 
            lappend datagreen [list $i [expr {$g_even}]]
            lappend datablue [list $i [expr {$b_even}]]

            set r_odd [expr $dataodd >> 16]
            set g_odd [expr [expr $dataodd & 0x0000ff00] >> 8]    
            set b_odd [expr $dataodd & 0x000000ff]

            lappend datared [list $i [expr {$r_odd}]] 
            lappend datagreen [list $i [expr {$g_odd}]]
            lappend datablue [list $i [expr {$b_odd}]]

            incr i
        }
        dashboard_set_property ${::ctrlPIO::dash_path} updateCCDLed color "green"
        if {$channel == 1} {
            dashboard_set_property ${::ctrlPIO::dash_path} colorChart series $datared
        } elseif {$channel == 2} {
            dashboard_set_property ${::ctrlPIO::dash_path} colorChart series $datagreen
        } elseif {$channel == 3} {
            dashboard_set_property ${::ctrlPIO::dash_path} colorChart series $datablue
        }
        
        return -code ok

    }

    proc writeData {operator board} {
        set systemTime [clock seconds]
        puts "Escrevendo Laudo"
        set fp [open $::ctrlPIO::log_file a+]
        puts $fp "------------------------------------------------------------------------------"
        puts $fp "Laudo da placa CCD ID: $board realizado ([clock format $systemTime -format %H:%M:%S] -- [clock format $systemTime -format %D]) por: $operator"
        puts $fp "Status CCD Board: "
        if {[expr ${::ctrlPIO::LEDError} == 0 ]} {
            set ledOut "OK!"
        } else {
            set ledOut "ERROR!"
        }
        puts $fp "Teste LEDS: $::ctrlPIO::testLED, LEDs =  [format "%0*b" 4 $::ctrlPIO::ledValue], STATUS FINAL =  $ledOut"

        if {[expr ${::ctrlPIO::switchError} == 0 ]} {
            set switchOut "OK!"
        } else {
            set switchOut "ERROR!"
        }
        puts $fp "Teste Switch: Status = $::ctrlPIO::testSwitch, Switchs = [format "%0*b" 8 $::ctrlPIO::switchValue], STATUS FINAL = $switchOut"

        if {[expr ${::ctrlPIO::WriteRam} == 1] && [expr ${::ctrlPIO::ReadRam} == 1] && [expr ${::ctrlPIO::CleanRam} == 1] && [expr ${::ctrlPIO::CleanedRam} == 1]} {
            set RAMOut "OK!"
        } else {
            set RAMOut "ERROR!"
        }

        puts $fp "Teste SRAM: Write = $::ctrlPIO::WriteRam, Read = $::ctrlPIO::ReadRam, Erase = $::ctrlPIO::CleanRam, CleanedRAM = $::ctrlPIO::CleanedRam, STATUS FINAL = $RAMOut"
        
        if {[expr  ${::ctrlPIO::CCDRed} == 1] && [expr ${::ctrlPIO::CCDGreen}== 1] && [expr  ${::ctrlPIO::CCDBlue} == 1]} {
            set CCDout "OK!"
        } else {
            set CCDout "ERROR!"
        }
        puts $fp "Teste CCD: RED =  ${::ctrlPIO::CCDRed}, GREEN = ${::ctrlPIO::CCDGreen}, BLUE = ${::ctrlPIO::CCDBlue}, STATUS FINAL = $CCDout"

        if {[expr ${::ctrlPIO::LVDSTest1} == 1] && [expr ${::ctrlPIO::LVDSTest2} == 1] && [expr ${::ctrlPIO::LVDSTest3} == 1]} {
            set LVDSOut "OK!"
        } else {
            set LVDSOut "ERROR!"
        }

        puts $fp "Teste LVDS: Status = LVDS 1 = $::ctrlPIO::LVDSTest1, LVDS 2 = $::ctrlPIO::LVDSTest2, LVDS 3 = $::ctrlPIO::LVDSTest3, STATUS FINAL = $LVDSOut"

        puts $fp "***********************************END****************************************"
         puts $fp ""
        
        close $fp

        return -code ok

    }

    proc enableAD {} {
        master_write_16 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_AD_MODULE_0_BASE} + 0x2 ] 0x01AE
        master_write_16 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_AD_MODULE_0_BASE} + 0x4 ] 0x01AE
        master_write_16 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_AD_MODULE_0_BASE} + 0x6 ] 0x09AD
        master_write_16 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_AD_MODULE_0_BASE} + 0x8 ] 0x09AD
        master_write_16 ${::boardInit::masterPath} [ expr ${::QSYS_HEADER::MASTER_0_AD_MODULE_0_BASE} + 0xA ] 0x0001        
    }

    proc validLeds {} {
        ::ctrlPIO::writeText {TESTE LEDS = Ok!}
    }

    proc validSwitch {} {
        ::ctrlPIO::writeText {TESTE Switch = Ok!}
    }

    proc SRAMTest {} {
        ::ctrlPIO::writeText {TESTE SRAM = Iniciado}
        ::ctrlPIO::writeRam
        ::ctrlPIO::readRam
        ::ctrlPIO::cleanRam
        ::ctrlPIO::readcleanRam
        ::ctrlPIO::writeText {TESTE SRAM = Finalizado}
    }

    proc writeText {string} {

        set fp [open $::ctrlPIO::log_file a+]
        puts $fp $string
        close $fp  
        return -code ok
    }

    proc validateCCDRed {} {
        set ::ctrlPIO::CCDRed 1
        ::ctrlPIO::writeText {TESTE CCD = Canal Vermelho Confirmado}        
    }

    proc validateCCDGreen {} {
        set ::ctrlPIO::CCDGreen 1
        ::ctrlPIO::writeText {TESTE CCD = Canal Verde Confirmado}        
    }

    proc validateCCDBlue {} {
        set ::ctrlPIO::CCDBlue 1
        ::ctrlPIO::writeText {TESTE CCD = Canal Azul Confirmado}        
    }


    proc dashBoard {} {
        if { ${::ctrlPIO::dashboardActive} == 1 } {
            return -code ok "dashboard already active"
        }

        set ::ctrlPIO::dashboardActive 1
        #
        # Create dashboard 
        #
        variable ::ctrlPIO::dash_path [ add_service dashboard ctrlPIO "ctrlPIO" "Tools/ctrlPIO"]
        #
        # Set dashboard properties
        #
        dashboard_set_property ${::ctrlPIO::dash_path} self developmentMode true
        dashboard_set_property ${::ctrlPIO::dash_path} self itemsPerRow 4
        dashboard_set_property ${::ctrlPIO::dash_path} self visible true
        # Groups definition
        if { ${::ctrlPIO::dashboardActive} == 1 } {
            dashboard_add ${::ctrlPIO::dash_path} IOGroup group self
            dashboard_set_property ${::ctrlPIO::dash_path} IOGroup expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} IOGroup expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} IOGroup itemsPerRow 1
            dashboard_set_property ${::ctrlPIO::dash_path} IOGroup title "IOs"

            dashboard_add ${::ctrlPIO::dash_path} ComponentsGroup group self
            dashboard_set_property ${::ctrlPIO::dash_path} ComponentsGroup expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} ComponentsGroup expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} ComponentsGroup itemsPerRow 1
            dashboard_set_property ${::ctrlPIO::dash_path} ComponentsGroup title "Components"

            dashboard_add ${::ctrlPIO::dash_path} FileGroup group self
            dashboard_set_property ${::ctrlPIO::dash_path} FileGroup expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} FileGroup expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} FileGroup itemsPerRow 1
            dashboard_set_property ${::ctrlPIO::dash_path} FileGroup title "Salvar dados"
        }
        # SubGroups Defintion
        if { ${::ctrlPIO::dashboardActive} == 1 } {
            dashboard_add ${::ctrlPIO::dash_path} ledsGroup group IOGroup
            dashboard_set_property ${::ctrlPIO::dash_path} ledsGroup expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} ledsGroup expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} ledsGroup preferredWidth 200
            dashboard_set_property ${::ctrlPIO::dash_path} ledsGroup itemsPerRow 2
            dashboard_set_property ${::ctrlPIO::dash_path} ledsGroup title "LED State"

            dashboard_add ${::ctrlPIO::dash_path} switchGroup group IOGroup
            dashboard_set_property ${::ctrlPIO::dash_path} switchGroup expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} switchGroup expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} switchGroup preferredWidth 200
            dashboard_set_property ${::ctrlPIO::dash_path} switchGroup itemsPerRow 1
            dashboard_set_property ${::ctrlPIO::dash_path} switchGroup title "Switch State"

            dashboard_add ${::ctrlPIO::dash_path} SRAMGroup group ComponentsGroup
            dashboard_set_property ${::ctrlPIO::dash_path} SRAMGroup expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} SRAMGroup expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} SRAMGroup preferredWidth 200
            dashboard_set_property ${::ctrlPIO::dash_path} SRAMGroup itemsPerRow 1
            dashboard_set_property ${::ctrlPIO::dash_path} SRAMGroup title "RAM State"

            dashboard_add ${::ctrlPIO::dash_path} ConnectorGroup group ComponentsGroup
            dashboard_set_property ${::ctrlPIO::dash_path} ConnectorGroup expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} ConnectorGroup expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} ConnectorGroup preferredWidth 200
            dashboard_set_property ${::ctrlPIO::dash_path} ConnectorGroup itemsPerRow 1
            dashboard_set_property ${::ctrlPIO::dash_path} ConnectorGroup title "Connector State"

        }
        # ledsGroup
        if { ${::ctrlPIO::dashboardActive} == 1 } {
            dashboard_add ${::ctrlPIO::dash_path} led0Button button ledsGroup 
            dashboard_set_property ${::ctrlPIO::dash_path} led0Button enabled true
            dashboard_set_property ${::ctrlPIO::dash_path} led0Button expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led0Button expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led0Button text "Toggle"
            dashboard_set_property ${::ctrlPIO::dash_path} led0Button onClick {::ctrlPIO::toggleLed 0}
            
            dashboard_add ${::ctrlPIO::dash_path} led0LED led ledsGroup
            dashboard_set_property ${::ctrlPIO::dash_path} led0LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} led0LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led0LED text "LED 0"
            dashboard_set_property ${::ctrlPIO::dash_path} led0LED color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} led1Button button ledsGroup 
            dashboard_set_property ${::ctrlPIO::dash_path} led1Button enabled true
            dashboard_set_property ${::ctrlPIO::dash_path} led1Button expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led1Button expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led1Button text "Toggle"
            dashboard_set_property ${::ctrlPIO::dash_path} led1Button onClick {::ctrlPIO::toggleLed 1}

            dashboard_add ${::ctrlPIO::dash_path} led1LED led ledsGroup
            dashboard_set_property ${::ctrlPIO::dash_path} led1LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} led1LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led1LED text "LED 1"
            dashboard_set_property ${::ctrlPIO::dash_path} led1LED color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} led2Button button ledsGroup 
            dashboard_set_property ${::ctrlPIO::dash_path} led2Button enabled true
            dashboard_set_property ${::ctrlPIO::dash_path} led2Button expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led2Button expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led2Button text "Toggle"
            dashboard_set_property ${::ctrlPIO::dash_path} led2Button onClick {::ctrlPIO::toggleLed 2}

            dashboard_add ${::ctrlPIO::dash_path} led2LED led ledsGroup
            dashboard_set_property ${::ctrlPIO::dash_path} led2LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} led2LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led2LED text "LED 2"
            dashboard_set_property ${::ctrlPIO::dash_path} led2LED color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} led3Button button ledsGroup 
            dashboard_set_property ${::ctrlPIO::dash_path} led3Button enabled true
            dashboard_set_property ${::ctrlPIO::dash_path} led3Button expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led3Button expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led3Button text "Toggle"
            dashboard_set_property ${::ctrlPIO::dash_path} led3Button onClick {::ctrlPIO::toggleLed 3}

            dashboard_add ${::ctrlPIO::dash_path} led3LED led ledsGroup
            dashboard_set_property ${::ctrlPIO::dash_path} led3LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} led3LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led3LED text "LED 3"
            dashboard_set_property ${::ctrlPIO::dash_path} led3LED color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} led4LED led ledsGroup
            dashboard_set_property ${::ctrlPIO::dash_path} led4LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} led4LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} led4LED text "Status Teste Leds "
            dashboard_set_property ${::ctrlPIO::dash_path} led4LED color "red_off"
        }
        # switchsGroup
        if { ${::ctrlPIO::dashboardActive} == 1 } {
            dashboard_add ${::ctrlPIO::dash_path} switch1 led switchGroup
            dashboard_set_property ${::ctrlPIO::dash_path} switch1 expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} switch1 expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} switch1 text "       Interruptor 1"
            dashboard_set_property ${::ctrlPIO::dash_path} switch1 color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} switch2 led switchGroup
            dashboard_set_property ${::ctrlPIO::dash_path} switch2 expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} switch2 expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} switch2 text "       Interruptor 2"
            dashboard_set_property ${::ctrlPIO::dash_path} switch2 color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} switch3 led switchGroup
            dashboard_set_property ${::ctrlPIO::dash_path} switch3 expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} switch3 expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} switch3 text "       Interruptor 3"
            dashboard_set_property ${::ctrlPIO::dash_path} switch3 color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} switch4 led switchGroup
            dashboard_set_property ${::ctrlPIO::dash_path} switch4 expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} switch4 expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} switch4 text "       Interruptor 4"
            dashboard_set_property ${::ctrlPIO::dash_path} switch4 color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} switch5 led switchGroup
            dashboard_set_property ${::ctrlPIO::dash_path} switch5 expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} switch5 expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} switch5 text "       Interruptor 5"
            dashboard_set_property ${::ctrlPIO::dash_path} switch5 color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} switch6 led switchGroup
            dashboard_set_property ${::ctrlPIO::dash_path} switch6 expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} switch6 expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} switch6 text "       Interruptor 6"
            dashboard_set_property ${::ctrlPIO::dash_path} switch6 color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} switch7 led switchGroup
            dashboard_set_property ${::ctrlPIO::dash_path} switch7 expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} switch7 expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} switch7 text "       Interruptor 7"
            dashboard_set_property ${::ctrlPIO::dash_path} switch7 color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} switch8 led switchGroup
            dashboard_set_property ${::ctrlPIO::dash_path} switch8 expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} switch8 expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} switch8 text "       Interruptor 8"
            dashboard_set_property ${::ctrlPIO::dash_path} switch8 color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} switch9 led switchGroup
            dashboard_set_property ${::ctrlPIO::dash_path} switch9 expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} switch9 expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} switch9 text "       Status Teste Dip Switch"
            dashboard_set_property ${::ctrlPIO::dash_path} switch9 color "red_off"
        }
        # RAMGroup
        if { ${::ctrlPIO::dashboardActive} == 1 } {

            dashboard_add ${::ctrlPIO::dash_path} ram0Button button SRAMGroup 
            dashboard_set_property ${::ctrlPIO::dash_path} ram0Button enabled true
            dashboard_set_property ${::ctrlPIO::dash_path} ram0Button expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} ram0Button expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} ram0Button preferredWidth 150
            dashboard_set_property ${::ctrlPIO::dash_path} ram0Button text "Executar Teste SDRAM"
            dashboard_set_property ${::ctrlPIO::dash_path} ram0Button onClick {::ctrlPIO::SRAMTest}
            
            dashboard_add ${::ctrlPIO::dash_path} ram0LED led SRAMGroup
            dashboard_set_property ${::ctrlPIO::dash_path} ram0LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} ram0LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} ram0LED text "   Status Write"
            dashboard_set_property ${::ctrlPIO::dash_path} ram0LED color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} ram1LED led SRAMGroup
            dashboard_set_property ${::ctrlPIO::dash_path} ram1LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} ram1LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} ram1LED text "   Status Read"
            dashboard_set_property ${::ctrlPIO::dash_path} ram1LED color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} ram2LED led SRAMGroup
            dashboard_set_property ${::ctrlPIO::dash_path} ram2LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} ram2LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} ram2LED text "   Status Erase"
            dashboard_set_property ${::ctrlPIO::dash_path} ram2LED color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} ram3LED led SRAMGroup
            dashboard_set_property ${::ctrlPIO::dash_path} ram3LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} ram3LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} ram3LED text "   Status Erased RAM"
            dashboard_set_property ${::ctrlPIO::dash_path} ram3LED color "red_off"
        }
        # LVDS
        if { ${::ctrlPIO::dashboardActive} == 1 } {


           
            dashboard_add ${::ctrlPIO::dash_path} con0LED led ConnectorGroup
            dashboard_set_property ${::ctrlPIO::dash_path} con0LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} con0LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} con0LED text "   Status LVDS 1"
            dashboard_set_property ${::ctrlPIO::dash_path} con0LED color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} con1LED led ConnectorGroup
            dashboard_set_property ${::ctrlPIO::dash_path} con1LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} con1LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} con1LED text "   Status LVDS 2"
            dashboard_set_property ${::ctrlPIO::dash_path} con1LED color "red_off"

            dashboard_add ${::ctrlPIO::dash_path} con2LED led ConnectorGroup
            dashboard_set_property ${::ctrlPIO::dash_path} con2LED expandableX false
            dashboard_set_property ${::ctrlPIO::dash_path} con2LED expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} con2LED text "   Status LVDS 3"
            dashboard_set_property ${::ctrlPIO::dash_path} con2LED color "red_off"

             dashboard_add ${::ctrlPIO::dash_path} lvdsStart button ConnectorGroup 
            dashboard_set_property ${::ctrlPIO::dash_path} lvdsStart enabled true
            dashboard_set_property ${::ctrlPIO::dash_path} lvdsStart expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} lvdsStart expandableY false
            dashboard_set_property ${::ctrlPIO::dash_path} lvdsStart preferredWidth 150
            dashboard_set_property ${::ctrlPIO::dash_path} lvdsStart text "LVDS Test"
            dashboard_set_property ${::ctrlPIO::dash_path} lvdsStart onClick {::ctrlPIO::testLVDS}
            

        }
        # CCD
        
        # Text Output
        if { ${::ctrlPIO::dashboardActive} == 1 } {

            dashboard_add ${::ctrlPIO::dash_path} operator text FileGroup
            dashboard_set_property ${::ctrlPIO::dash_path} operator editable true
            dashboard_set_property ${::ctrlPIO::dash_path} operator htmlCapable false
            dashboard_set_property ${::ctrlPIO::dash_path} operator preferredWidth 100
            dashboard_set_property ${::ctrlPIO::dash_path} operator text ${::ctrlPIO::operator}

            dashboard_add ${::ctrlPIO::dash_path} boardLabel text FileGroup
            dashboard_set_property ${::ctrlPIO::dash_path} boardLabel editable true
            dashboard_set_property ${::ctrlPIO::dash_path} boardLabel htmlCapable false
            dashboard_set_property ${::ctrlPIO::dash_path} boardLabel preferredWidth 100
            dashboard_set_property ${::ctrlPIO::dash_path} boardLabel text ${::ctrlPIO::boardLabel}

            dashboard_add ${::ctrlPIO::dash_path} writeFile button FileGroup
            dashboard_set_property ${::ctrlPIO::dash_path} writeFile text "Salvar Laudo"
            dashboard_set_property ${::ctrlPIO::dash_path} writeFile preferredWidth 150
            dashboard_set_property ${::ctrlPIO::dash_path} writeFile onClick {::ctrlPIO::writeData [dashboard_get_property ${::ctrlPIO::dash_path} operator text] [dashboard_get_property ${::ctrlPIO::dash_path} boardLabel text]}
        }

        after idle ::ctrlPIO::updateDashboard

        return -code ok
    }
    
    proc updateDashboard {} {

        ::ctrlPIO::init

       

        if { ${::ctrlPIO::dashboardActive} > 0 } {

            if { ${::ctrlPIO::initialized} > 0 } {

                if { ${::ctrlPIO::writeInit} == 0 } {
                    set systemTime [clock seconds]
        
                    puts "**************************************************************"
                    puts "Inicializando Placa CCD"
                    puts "**************************************************************"

                    ::ctrlPIO::enableAD
                    set file "LOG_CCD_[clock format $systemTime -format %D].txt"
                    set log_file [regsub "/" $file "_"]
                    set ::ctrlPIO::log_file [regsub "/" $log_file "_"]
                    
                    set ::ctrlPIO::log_file "../log/$::ctrlPIO::log_file"
                    puts "log file = $::ctrlPIO::log_file"
                    set fp [open $::ctrlPIO::log_file a+]
                    puts $fp "**********************************START***************************************"
                    puts $fp "Estado Inicial da placa. Teste iniciado em ([clock format $systemTime -format %H:%M:%S] -- [clock format $systemTime -format %D])"
                    puts $fp "Status CCD Board: "
                    puts $fp "Teste LEDS: $::ctrlPIO::testLED, LEDs =  [format "%0*b" 4 $::ctrlPIO::ledValue]"
                    if {$::ctrlPIO::ledValue != 0xF} {
                        puts $fp "Teste LEDS: started with error!!"
                        puts "ERROR = Placa inicializada com erro nos LEDs, verificar placa"
                        set ::ctrlPIO::LEDError 1
                    }
                    puts $fp "Teste SRAM: Write = [lindex $::ctrlPIO::testSRAM 0], Read = [lindex $::ctrlPIO::testSRAM 1], Erase = [lindex $::ctrlPIO::testSRAM 2], CleanedRAM = [lindex $::ctrlPIO::testSRAM 3]"
                    puts $fp "Teste Switch: Status = $::ctrlPIO::testSwitch, Switchs = [format "%0*b" 8 $::ctrlPIO::switchValue]"
                    if {$::ctrlPIO::switchValue != 0xFF} {
                        puts $fp "Teste Switchs: started with error!!"
                        puts "ERROR = Placa inicializada com erro no DIP Switch, verificar se estão todos em '0'"
                        set ::ctrlPIO::switchError 1
                    }
                     puts $fp "**********************************TESTES***************************************"
                    close $fp
                    set ::ctrlPIO::writeInit 1
                } 
                

                # Update LED Group
                dashboard_set_property ${::ctrlPIO::dash_path} ledsGroup title "LED State"
                if { [ expr ${::ctrlPIO::ledValue} & 0x01 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} led0LED color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} led0LED color "green"
                }
                if { [ expr ${::ctrlPIO::ledValue} & 0x02 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} led1LED color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} led1LED color "green"
                }
                if { [ expr ${::ctrlPIO::ledValue} & 0x04 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} led2LED color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} led2LED color "green"
                }
                if { [ expr ${::ctrlPIO::ledValue} & 0x08 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} led3LED color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} led3LED color "green"
                }
                # LED TEST
                if { [ expr ${::ctrlPIO::ledValue} == 15 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} led4LED color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} led4LED color "green_off"
                    if { [ expr ${::ctrlPIO::ledValue} == 0 ] } {

                        dashboard_set_property ${::ctrlPIO::dash_path} led4LED color "blue"
                        if { [ expr ${::ctrlPIO::testLED} == 0] && [expr ${::ctrlPIO::LEDError} == 0]} {
                            set ::ctrlPIO::testLED 1
                            ::ctrlPIO::validLeds
                        }
                        if {[expr ${::ctrlPIO::LEDError} == 1]}  {
                            dashboard_set_property ${::ctrlPIO::dash_path} led4LED color "red"
                        } 
                        
                    }
                }

                # Update Switchs Group
                dashboard_set_property ${::ctrlPIO::dash_path} switchGroup title "Switch State"
                if { [ expr ${::ctrlPIO::switchValue} & 0x01 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch1 color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch1 color "green"
                }
                if { [ expr ${::ctrlPIO::switchValue} & 0x02 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch2 color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch2 color "green"
                }
                if { [ expr ${::ctrlPIO::switchValue} & 0x04 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch3 color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch3 color "green"
                }
                if { [ expr ${::ctrlPIO::switchValue} & 0x08 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch4 color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch4 color "green"
                }
                if { [ expr ${::ctrlPIO::switchValue} & 0x10 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch5 color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch5 color "green"
                }
                if { [ expr ${::ctrlPIO::switchValue} & 0x20 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch6 color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch6 color "green"
                }
                if { [ expr ${::ctrlPIO::switchValue} & 0x40 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch7 color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch7 color "green"
                }
                if { [ expr ${::ctrlPIO::switchValue} & 0x80 ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch8 color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch8 color "green"
                }
                # SWITCH TEST
                if { [ expr ${::ctrlPIO::switchValue} == 0xFF ] } {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch9 color "red_off"
                } else {
                    dashboard_set_property ${::ctrlPIO::dash_path} switch9 color "green_off"
                    if { [ expr ${::ctrlPIO::switchValue} == 0 ] } {
                        dashboard_set_property ${::ctrlPIO::dash_path} switch9 color "blue"
                        if {[expr ${::ctrlPIO::switchError} == 1]} {
                            dashboard_set_property ${::ctrlPIO::dash_path} switch9 color "red"
                        }
                        if { [expr ${::ctrlPIO::testSwitch} == 0 ] && [expr ${::ctrlPIO::switchError} == 0]} {
                            ::ctrlPIO::validSwitch
                            set ::ctrlPIO::testSwitch 1
                        }
                    } 
                }

                after 300 ::ctrlPIO::updateDashboard
            } else {
                dashboard_set_property ${::ctrlPIO::dash_path} ledsGroup title "Uninitialized"
                dashboard_set_property ${::ctrlPIO::dash_path} switchGroup title "Uninitialized"
                after 1000 ::ctrlPIO::updateDashboard
            }
        }
    }
	
	
	proc controlButtons {i} {
	
	
		if { $i == 1 } {
			dashboard_set_property ${::ctrlPIO::dash_path} led0Button enabled true
			dashboard_set_property ${::ctrlPIO::dash_path} led1Button enabled true
			dashboard_set_property ${::ctrlPIO::dash_path} led2Button enabled true
			dashboard_set_property ${::ctrlPIO::dash_path} led3Button enabled true
			dashboard_set_property ${::ctrlPIO::dash_path} ram0Button enabled true
			dashboard_set_property ${::ctrlPIO::dash_path} lvdsStart enabled true
		        
		        
			dashboard_set_property ${::ctrlPIO::dash_path} writeFile enabled true
			
		} else {
			dashboard_set_property ${::ctrlPIO::dash_path} led0Button enabled false
			dashboard_set_property ${::ctrlPIO::dash_path} led1Button enabled false
			dashboard_set_property ${::ctrlPIO::dash_path} led2Button enabled false
			dashboard_set_property ${::ctrlPIO::dash_path} led3Button enabled false
			dashboard_set_property ${::ctrlPIO::dash_path} ram0Button enabled false
			dashboard_set_property ${::ctrlPIO::dash_path} lvdsStart enabled false
		        
			dashboard_set_property ${::ctrlPIO::dash_path} writeFile enabled false
			
			}

	}

	
	
}



