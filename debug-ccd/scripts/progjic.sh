file="ccd.v2.3.4.jic"
path="bitstream/$file"

echo "Initialize board's programming script ..."
echo "version: $file"
echo "------------------------------------------------------"

quartus_pgm -m jtag -o "ipv;$path"

echo "------------------------------------------------------"
echo "Procedimento finalizado"
echo "------------------------------------------------------"