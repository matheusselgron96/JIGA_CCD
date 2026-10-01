file="ccd_4.0.4.4.sof"
path="sof/$file"

echo "Iniciando gravacao para teste ccd"
echo "------------------------------------------------------"

quartus_pgm -m jtag -o "p;$path"

echo "------------------------------------------------------"
echo "Utilize a ihm para verificar o sinal do ccd"
echo "------------------------------------------------------"