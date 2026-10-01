#
# unlock_flash.tcl
#
# Unlocks (unprotects) every sector of the EPCQ configuration flash of the CCD
# board so it can be reprogrammed with quartus_pgm (progjic.sh / progboard.bat).
#
# Why: the fpga-bootloader firmware protects ALL flash sectors when it boots
# (bootloader.c: unprotectSectorsApp(PROTECT_ALL_SECTORS)). The block-protect
# bits live in the flash status register and are NON-VOLATILE, so the flash
# stays locked across power cycles and quartus_pgm cannot erase/program it.
#
# This script does exactly what the bootloader's unprotectAll() does:
#
#     IOWR(EPCQ_CONTROLLER_0_AVL_CSR_BASE, EPCS_PROTECT_ERASE, UNPROTECT_ALL_SECTORS)
#
# but from the PC, through the Nios II JTAG debug master of the bootloader
# design, using System Console.
#
# Usage (Nios II Command Shell, inside the scripts/ folder):
#     system-console --cli --script=unlock_flash.tcl
# or simply double-click unlock_flash.bat.
#
# Requirements:
#   - Exactly one JTAG device (USB-Blaster) connected.
#   - The board is running the BOOTLOADER design (what it boots into from
#     flash page 0). The application (ccd) design has no EPCQ controller, so
#     the script refuses to run if it detects that design.
#
# References:
#   C:/dev/fpga-bootloader/syn/altera-ccd/software/bootloader/bootloader.c
#   C:/dev/fpga-bootloader/syn/altera-ccd/software/bootloader_bsp/system.h
#   C:/intelFPGA_lite/18.1/ip/altera/altera_epcq_controller/inc/altera_epcq_controller_regs.h
#

namespace eval unlockFlash {

    # ---- Bootloader design addresses (bootloader_bsp/system.h) -----------
    variable EPCQ_CSR_BASE          0xe0

    # ---- EPCQ controller CSR registers (altera_epcq_controller_regs.h) ---
    variable EPCQ_STATUS_REG        0x0     ;# RO  flash status register
    variable EPCQ_SID_REG           0x4     ;# RO  silicon ID
    variable EPCQ_CAPACITY_REG      0x8     ;# RO  flash capacity
    variable EPCQ_MEM_OP_REG        0xc     ;# WO  erase / sector-protect command
                                            ;#     (= EPCS_PROTECT_ERASE, word 3, in bootloader.c)

    # ---- MEM_OP command values (bootloader.c) ----------------------------
    # bits [1:0] = 0x3      SECTOR_PROTECT command
    # bits [12:8]           protect value written to the flash status register
    variable UNPROTECT_ALL_SECTORS  0x1003
    variable PROTECT_ALL_SECTORS    0x1903

    # ---- Flash status register bits (EPCQ128 / N25Q128) ------------------
    # WIP=bit0  WEL=bit1  BP0..BP2=bits[4:2]  TB=bit5  BP3=bit6
    variable STATUS_WIP_MASK        0x01
    variable STATUS_BP_MASK         0x5c

    # ---- Master selection -------------------------------------------------
    # Prefer the bootloader's Nios II debug master. Refuse to run if the
    # application's JTAG-to-Avalon master (master_0) is visible.
    variable niosMasterPattern      "*nios2*"
    variable appMasterPattern       "*master_0*"

    variable masterPath  ""
    variable claimedPath ""

    proc log {msg} {
        puts "\[unlock_flash\] $msg"
    }

    proc readCsr {offset} {
        variable claimedPath
        variable EPCQ_CSR_BASE
        set value [lindex [master_read_32 $claimedPath [expr {$EPCQ_CSR_BASE + $offset}] 1] 0]
        return [expr {$value & 0xFFFFFFFF}]
    }

    proc writeCsr {offset value} {
        variable claimedPath
        variable EPCQ_CSR_BASE
        master_write_32 $claimedPath [expr {$EPCQ_CSR_BASE + $offset}] $value
    }

    proc readStatus {} {
        variable EPCQ_STATUS_REG
        return [expr {[readCsr $EPCQ_STATUS_REG] & 0xFF}]
    }

    # Wait until the flash Write-In-Progress bit clears.
    proc waitIdle {{timeout_ms 2000}} {
        variable STATUS_WIP_MASK
        set elapsed 0
        while { ([readStatus] & $STATUS_WIP_MASK) != 0 } {
            if { $elapsed >= $timeout_ms } {
                return -code error "timeout waiting for the flash to become idle (WIP stuck at 1) - is the bootloader design really loaded?"
            }
            after 10
            incr elapsed 10
        }
    }

    # Locate the JTAG device and pick the master service to use.
    proc findMaster {} {
        variable niosMasterPattern
        variable appMasterPattern

        set devices [get_service_paths device]
        if { [llength $devices] == 0 } {
            return -code error "no JTAG devices located - is the board powered and the USB-Blaster connected?"
        }
        if { [llength $devices] > 1 } {
            return -code error "too many JTAG devices located: $devices"
        }
        log "device : [lindex $devices 0]"

        set masters [get_service_paths master]
        if { [llength $masters] == 0 } {
            return -code error "no master service found (the bootloader Nios II debug core is not visible)"
        }
        foreach m $masters {
            log "master : $m"
        }

        # The application (ccd) design exposes a JTAG-to-Avalon master called
        # master_0 and has no EPCQ controller; address 0xe0 there is some
        # other peripheral.
        if { [lsearch -glob $masters $appMasterPattern] >= 0 } {
            return -code error "application design detected (master_0 present). Power-cycle the board so the bootloader is running, then retry."
        }

        set idx [lsearch -glob $masters $niosMasterPattern]
        if { $idx < 0 } {
            if { [llength $masters] == 1 } {
                set idx 0
            } else {
                return -code error "several masters found and none matches '$niosMasterPattern' - edit niosMasterPattern in unlock_flash.tcl"
            }
        }
        return [lindex $masters $idx]
    }

    proc run {} {
        variable masterPath
        variable claimedPath
        variable EPCQ_SID_REG
        variable EPCQ_CAPACITY_REG
        variable EPCQ_MEM_OP_REG
        variable UNPROTECT_ALL_SECTORS
        variable STATUS_BP_MASK

        set masterPath  [findMaster]
        set claimedPath [claim_service master $masterPath unlockFlash]

        set failed [catch {
            log "using  : $masterPath"
            log [format "EPCQ silicon id : 0x%02x   capacity : 0x%02x" \
                    [expr {[readCsr $EPCQ_SID_REG] & 0xFF}] \
                    [expr {[readCsr $EPCQ_CAPACITY_REG] & 0xFF}]]

            waitIdle
            set before [readStatus]
            log [format "status before   : 0x%02x  (protect bits 0x%02x)" \
                    $before [expr {$before & $STATUS_BP_MASK}]]
            if { ($before & $STATUS_BP_MASK) == 0 } {
                log "flash already reports no protected sectors - sending UNPROTECT_ALL_SECTORS anyway"
            }

            log [format "writing 0x%04x to the EPCQ MEM_OP register (unprotect all sectors) ..." \
                    $UNPROTECT_ALL_SECTORS]
            writeCsr $EPCQ_MEM_OP_REG $UNPROTECT_ALL_SECTORS
            waitIdle

            set after [readStatus]
            log [format "status after    : 0x%02x  (protect bits 0x%02x)" \
                    $after [expr {$after & $STATUS_BP_MASK}]]

            if { ($after & $STATUS_BP_MASK) != 0 } {
                error [format "flash still reports protected sectors (status 0x%02x)" $after]
            }

            log "OK - all flash sectors unprotected. The flash can now be programmed (progjic.sh / progboard.bat)."
            log "NOTE: the bootloader protects the flash again every time it boots."
        } err]

        close_service master $claimedPath
        set claimedPath ""

        if { $failed } {
            return -code error $err
        }
        return -code ok
    }
}

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
# System Console (--script mode) has no 'exit' command: it terminates by itself
# when the script ends (exit code 0), or when an error is left uncaught
# (non-zero exit code, which unlock_flash.sh checks).
if { [catch { ::unlockFlash::run } err] } {
    ::unlockFlash::log "ERROR: $err"
    error "unlock_flash failed: $err"
}
