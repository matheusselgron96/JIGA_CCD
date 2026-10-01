#
# Unlocks (unprotects) the EPCQ flash of the CCD board through System Console.
# See unlock_flash.tcl for details. Launched by unlock_flash.bat.
#

echo ""
echo "Unlocking bootloader flash (EPCQ) ..."
echo "------------------------------------------------------"

system-console --cli --script=unlock_flash.tcl
status=$?

echo "------------------------------------------------------"
if [ $status -eq 0 ]; then
    echo "Flash unlocked. You can now program the board (progboard.bat)."
else
    echo "Flash unlock FAILED (exit code $status). Check the messages above."
fi
echo "------------------------------------------------------"
echo ""
printf "Press ENTER to close..."
read _dummy
