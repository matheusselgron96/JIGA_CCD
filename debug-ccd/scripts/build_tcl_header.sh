#!/bin/sh

SOPCINFO_FILE="../syn/altera/ccd_qsys.sopcinfo"
SHELL_HEADER_OUTPUT_FILE="./headers/ccd_qsys.sh"
TCL_HEADER_OUTPUT_FILE="./headers/test_sys_top_qsys.tcl"

#
# if headers directory does not exist, create it
#
[ -d "headers" ] || {
    mkdir headers
}

#
# make sure the sopcinfo file exists before we begin
#
[ -f "${SOPCINFO_FILE}" ] || {

    echo ""
    echo "ERROR: Could not locate sopcinfo input file."
    echo ""
    exit 1
}

#
# remove the expected output file before we begin
#
[ -f "${SHELL_HEADER_OUTPUT_FILE}" ] && {

    rm -f "${SHELL_HEADER_OUTPUT_FILE}"
}

#
# create the shell formatted header output
#
sopc-create-header-files ${SOPCINFO_FILE} --format sh --output-dir headers

#
# make sure the expected output file exists
#
[ -f "${SHELL_HEADER_OUTPUT_FILE}" ] || {

    echo ""
    echo "ERROR: Could not locate shell header output file."
    echo ""
    exit 1
}

#
# include the shell header file
#
. "${SHELL_HEADER_OUTPUT_FILE}"

#
# make sure that we collected all the macros that we expected
#
echo "
${MASTER_0_JTAG_TO_NIOS_BASE:?}
${MASTER_0_BOARD_ID_BASE:?}
${MASTER_0_NIOS_WRITE_LED_BASE:?}
${MASTER_0_SPI_0_BASE:?}
${MASTER_0_SPI_VALUE_BASE:?}
${MASTER_0_RETURN_NIOS_BASE:?}
${MASTER_0_RJ45_TESTER_0_BASE:?}
${MASTER_0_SAVE_FIFO_BASE:?}
${MASTER_0_FIFO_EVEN_BASE:?}
${MASTER_0_FIFO_ODD_BASE:?}
${MASTER_0_AD_MODULE_0_BASE:?}
${MASTER_0_RJ45_TESTER_1_BASE:?}



" >> /dev/null

cat << EOF > ${TCL_HEADER_OUTPUT_FILE}

namespace eval QSYS_HEADER {

    variable MASTER_0_JTAG_TO_NIOS_BASE ${MASTER_0_JTAG_TO_NIOS_BASE}
    variable MASTER_0_BOARD_ID_BASE ${MASTER_0_BOARD_ID_BASE}
    variable MASTER_0_NIOS_WRITE_LED_BASE ${MASTER_0_NIOS_WRITE_LED_BASE}
    variable MASTER_0_SPI_0_BASE ${MASTER_0_SPI_0_BASE}
    variable MASTER_0_SPI_VALUE_BASE ${MASTER_0_SPI_VALUE_BASE}
    variable MASTER_0_RETURN_NIOS_BASE ${MASTER_0_RETURN_NIOS_BASE}
    variable MASTER_0_RJ45_TESTER_0_BASE ${MASTER_0_RJ45_TESTER_0_BASE}
    variable MASTER_0_SAVE_FIFO_BASE ${MASTER_0_SAVE_FIFO_BASE}
    variable MASTER_0_FIFO_EVEN_BASE ${MASTER_0_FIFO_EVEN_BASE}
    variable MASTER_0_FIFO_ODD_BASE ${MASTER_0_FIFO_ODD_BASE}
    variable MASTER_0_AD_MODULE_0_BASE ${MASTER_0_AD_MODULE_0_BASE}
    variable MASTER_0_RJ45_TESTER_1_BASE ${MASTER_0_RJ45_TESTER_1_BASE}

}

EOF
