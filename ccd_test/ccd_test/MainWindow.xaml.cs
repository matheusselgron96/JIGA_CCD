using ccd_test.Communication;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Media;
using System.Windows.Threading;
using WIZnetCOM;

namespace ccd_test
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        #region Fields

        private OsciloscopeGraphic oscNormal = new OsciloscopeGraphic()
        {
            MinHorizontal = 0,
            MaxHorizontal = 4095,
            MinVertical = 0,
            MaxVertical = 255,
            StepsLines = 50,
            StepsColumns = 512
        };

        private short rGain = 1;
        private short gGain = 1;
        private short bGain = 1;

        int numberOfChutes = 1;

        #endregion Fields

        private DispatcherTimer dtCheckWIZnetReception = new DispatcherTimer();

        public MainWindow()
        {
            InitializeComponent();

            oscNormal.CurrentConfig = new Models.OscilloscopeConfig();
            osc.Content = oscNormal;

            InterfaceCOM.COMInstance.COMData.OnOscilloscopeChanged += COMData_OnOscilloscopeChanged;

            dtCheckWIZnetReception.Interval = TimeSpan.FromMilliseconds(50);
            dtCheckWIZnetReception.Tick += DtCheckWIZnetReception_Tick;

            byte[] hmiIP = new byte[] { 192, 168, 0, 73 };
            int hmiPort = 5001;
            byte[] wizIP = new byte[] { 192, 168, 0, 1 };
            int wizPort = 5000;

            // Configure transmission speed.
            InterfaceCOM.COMInstance.UpdateTimerInterval(100);
            InterfaceCOM.COMInstance.NumberOfChutes = numberOfChutes;
            InterfaceCOM.COMInstance.NumberOfDRVLEDs = 1;

            InterfaceCOM.COMInstance.InitModules();
            bool isConnected = InterfaceCOM.COMInstance.Connect(hmiIP, hmiPort, wizIP, wizPort).Result;

            if (isConnected)
            {
                dtCheckWIZnetReception.Start();

                ellpsWIZnetStatus.Fill = Brushes.Green;
            }
        }

        int bytesReceived = 0;
        List<byte> rawData = new List<byte>();

        private async void DtCheckWIZnetReception_Tick(object sender, EventArgs e)
        {
            Stopwatch sw = new Stopwatch();
            sw.Start();

            bool waitedOnce = false;
            bool received = false;

            List<List<byte>> packets = new List<List<byte>>();

            while (true)
            {
                try
                {
                    if (InterfaceCOM.COMInstance.Stream.DataAvailable)
                    {
                        // If waited, and received another packet, enable to wait again
                        if (waitedOnce)
                        {
                            waitedOnce = false;
                        }

                        received = true;
                        Byte[] rx_data = new Byte[16384];
                        int rx_size = InterfaceCOM.COMInstance.Stream.Read(rx_data, 0, rx_data.Length);

                        for (int i = 0; i < rx_size; i++)
                        {
                            rawData.Add(rx_data[i]);
                        }

                        bytesReceived += rx_size;

                        while (rawData.Count >= 580)
                        {
                            // Found a packet, add to packet list
                            if (rawData[0] == 0x55 && rawData[1] == 0xAA && rawData[2] == 0xFF && rawData[3] == 0x3C)
                            {
                                packets.Add(new List<byte>(rawData.GetRange(0, 580)));
                                rawData.RemoveRange(0, 580);
                            }
                            else
                            {
                                rawData.RemoveRange(0, 1);
                            }
                        }
                    }
                    else
                    {
                        // If data was received and there was no data in the next check, wait a little in case data took a little bit to arrive
                        if (received)
                        {
                            await Task.Delay(50);

                            if (waitedOnce)
                            {
                                break;
                            }

                            waitedOnce = true;
                        }
                        else
                        {
                            break;
                        }
                    }
                }
                catch (Exception ex)
                {
                    dtCheckWIZnetReception.Stop();
                    break;
                }
            }

            //SystemLogger.Report($"Stream Reading Elapsed Time: {sw.ElapsedMilliseconds}");
            sw.Restart();

            if (received)
            {
                //SystemLogger.Report($"WIZnet - Received Data - {rxRawData.Count} bytes");
                InterfaceCOM.COMInstance.COMData.ProcessRxData(packets);
            }

            //SystemLogger.Report($"InterfaceCOM ProcessRxData Elapsed Time: {sw.ElapsedMilliseconds}");
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            InterfaceCOM.COMInstance.PauseTimer();
        }

        #region Private/Local Methods

        public async Task StartOscRequest()
        {
            TxData txData = new TxData();

            // HW Line
            txData.Data[0] = 0x0;
            txData.Data[1] = 0x0;
            // Set Switch
            txData.Data[2] = 0x0;
            txData.Data[3] = 0x12;
            // t0
            txData.Data[4] = 0x0;
            txData.Data[5] = 0x1;
            // t0
            txData.Data[6] = 0x0;
            txData.Data[7] = 1;
            // t0
            txData.Data[8] = 1;
            txData.Data[9] = 0x0;

            InterfaceCOM.COMInstance.SendCommand_OnRequested(txData);

            await Task.Delay(150);
        }

        public async Task StopOscRequest()
        {
            TxData txData = new TxData();

            // HW Line
            txData.Data[0] = 0x0;
            txData.Data[1] = 0x0;
            // Set Switch
            txData.Data[2] = 0x0;
            txData.Data[3] = 0x12;
            // t0
            txData.Data[4] = 0x0;
            txData.Data[5] = 0x0;
            // t0
            txData.Data[6] = 0x0;
            txData.Data[7] = 1;
            // t0
            txData.Data[8] = 1;
            txData.Data[9] = 0x0;

            InterfaceCOM.COMInstance.SendCommand_OnRequested(txData);

            await Task.Delay(1500);
        }

        private async Task SendDefaultWIZnetValues()
        {
            TxData txData = new TxData();

            // HW Line
            txData.Data[1] = 0x0;
            // Interface CMD
            txData.Data[2] = 0x0;
            txData.Data[3] = 0xA;
            // tx_debouncer_base
            txData.Data[4] = (byte)(5 >> 8);
            txData.Data[5] = (byte)(5);
            // fifoFillingBase
            txData.Data[6] = 0;
            txData.Data[7] = 10;
            // rx_fifo_level_timeout_base
            txData.Data[8] = 195;
            txData.Data[9] = 80;
            // rx_fifo_level_timeout_base
            txData.Data[10] = 0;
            txData.Data[11] = 0;
            // stm_debouncer_base
            txData.Data[12] = 0;
            txData.Data[13] = 1;
            // autoOscDebouncerBase
            int autoOscDebouncerBase = 2000;
            txData.Data[14] = (byte)(autoOscDebouncerBase >> 8);
            txData.Data[15] = (byte)(autoOscDebouncerBase);
            txData.Data[16] = 0x0;
            txData.Data[17] = 0x0;
            // autoImgDebouncerBase
            int autoImgDebouncerBase = 5000;
            txData.Data[18] = (byte)(autoImgDebouncerBase >> 8);
            txData.Data[19] = (byte)(autoImgDebouncerBase);
            txData.Data[20] = 0x0;
            txData.Data[21] = 0x0;

            InterfaceCOM.COMInstance.SendCommand_OnRequested(txData);

            await Task.Delay(1000);

            try
            {
                // Configure CCDs
                for (int i = 0; i < numberOfChutes; i++)
                {
                    InterfaceCOM.COMInstance.FrontCCDs[i].LedConfig.LedValue = 0xA;
                    InterfaceCOM.COMInstance.FrontCCDs[i].SyncBuffer.Enable = 1;
                    InterfaceCOM.COMInstance.FrontCCDs[i].SDRAMConfig.OnPropertyChanged();
                    InterfaceCOM.COMInstance.FrontCCDs[i].HMIReturnPacket.OnPropertyChanged();
                    InterfaceCOM.COMInstance.FrontCCDs[i].EjectionPacket.OnPropertyChanged();
                    InterfaceCOM.COMInstance.FrontCCDs[i].OscilloscopeConfig.OnPropertyChanged();
                    InterfaceCOM.COMInstance.FrontCCDs[i].WhiteBalance.OnPropertyChanged();
                    InterfaceCOM.COMInstance.FrontCCDs[i].ADConfig.OnPropertyChanged();
                    InterfaceCOM.COMInstance.FrontCCDs[i].LedConfig.LedValue = 0x5;
                }
            }
            catch (Exception e)
            {

            }
        }

        private async Task SendStartEndPixels()
        {
            TxData txData = new TxData();

            // Set HW Line
            txData.Data[1] = 1;
            // Set board ID
            txData.Data[2] = 1;
            // Set Switch
            txData.Data[4] = 0x7;

            short startPixel = 400;
            short endPixel = (short)(startPixel + 2047);

            // data to sdram start offset
            txData.Data[6] = (byte)(startPixel);
            txData.Data[7] = (byte)(startPixel >> 8);
            // data to analysis start offset
            txData.Data[8] = (byte)(startPixel);
            txData.Data[9] = (byte)(startPixel >> 8);
            // data to sdram end offset
            txData.Data[10] = (byte)(endPixel);
            txData.Data[11] = (byte)(endPixel >> 8);
            // data to analysis end offset
            txData.Data[12] = (byte)(endPixel);
            txData.Data[13] = (byte)(endPixel >> 8);
            // enable
            txData.Data[14] = 0x0;
            txData.Data[15] = 0x0;

            InterfaceCOM.COMInstance.SendCommand_OnRequested(txData);

            await Task.Delay(50);

            // enable
            txData.Data[14] = 0x1;
            txData.Data[15] = 0x0;

            InterfaceCOM.COMInstance.SendCommand_OnRequested(txData);

            await Task.Delay(50);
        }

        private async Task DisableWB()
        {
            bool state = false;

            TxData txData = new TxData();

            // Set HW Line
            txData.Data[1] = 1;
            // Set board ID
            txData.Data[2] = 1;
            // Set Switch
            txData.Data[4] = 0x8;

            // enableWB
            txData.Data[6] = 0x0;
            txData.Data[7] = 0x0;
            // enableWBOutput
            txData.Data[8] = Convert.ToByte(state);
            txData.Data[9] = 0x0;

            InterfaceCOM.COMInstance.SendCommand_OnRequested(txData);
            await Task.Delay(250);

            // Set HW Line
            txData.Data[1] = 1;
            // Set board ID
            txData.Data[2] = 1;
            // Set Switch
            txData.Data[4] = 0x8;

            // enableWB
            txData.Data[6] = 0x1;
            txData.Data[7] = 0x0;
            // enableWBOutput
            txData.Data[8] = Convert.ToByte(state);
            txData.Data[9] = 0x0;

            InterfaceCOM.COMInstance.SendCommand_OnRequested(txData);
        }

        private async Task SendRGBGains()
        {
            TxData txData = new TxData();

            // Set HW Line
            txData.Data[1] = 1;
            // Set board ID
            txData.Data[2] = 1;
            // Set Switch
            txData.Data[4] = 0xA;

            txData.Data[6] = (byte)(rGain);
            txData.Data[7] = (byte)(rGain >> 8);

            InterfaceCOM.COMInstance.SendCommand_OnRequested(txData);

            await Task.Delay(50);

            // Set Switch
            txData.Data[4] = 0xB;
            txData.Data[6] = (byte)(gGain);
            txData.Data[7] = (byte)(gGain >> 8);

            InterfaceCOM.COMInstance.SendCommand_OnRequested(txData);

            await Task.Delay(50);

            // Set Switch
            txData.Data[4] = 0xC;
            txData.Data[6] = (byte)(bGain);
            txData.Data[7] = (byte)(bGain >> 8);

            InterfaceCOM.COMInstance.SendCommand_OnRequested(txData);

            await Task.Delay(50);
        }

        #endregion Private/Local Methods

        #region UI Events

        private async void btRGain1_Click(object sender, RoutedEventArgs e)
        {
            rGain = 1;
            await SendRGBGains();
        }

        private async void btGGain1_Click(object sender, RoutedEventArgs e)
        {
            gGain = 1;
            await SendRGBGains();
        }

        private async void btBGain1_Click(object sender, RoutedEventArgs e)
        {
            bGain = 1;
            await SendRGBGains();
        }

        private async void btRGain500_Click(object sender, RoutedEventArgs e)
        {
            rGain = 500;
            await SendRGBGains();
        }

        private async void btGGain500_Click(object sender, RoutedEventArgs e)
        {
            gGain = 500;
            await SendRGBGains();
        }

        private async void btBGain500_Click(object sender, RoutedEventArgs e)
        {
            bGain = 500;
            await SendRGBGains();
        }

        private async void btStart_Click(object sender, RoutedEventArgs e)
        {
            await StartOscRequest();
        }

        private async void btStop_Click(object sender, RoutedEventArgs e)
        {
            await StopOscRequest();
        }

        #endregion UI Events

        #region Global Events

        private async void COMData_OnOscilloscopeChanged()
        {
            List<int> rData = new List<int>(InterfaceCOM.COMInstance.COMData.OscilloscopeRed);
            List<int> gData = new List<int>(InterfaceCOM.COMInstance.COMData.OscilloscopeGreen);
            List<int> bData = new List<int>(InterfaceCOM.COMInstance.COMData.OscilloscopeBlue);

            // Set the graph to the UI element
            oscNormal.MaxHorizontal = 4095;
            oscNormal.UpdateGraphValues(rData, gData, bData);
            oscNormal.DisplayConfigButton();
        }

        #endregion Global Events

        private async void Window_ContentRendered(object sender, EventArgs e)
        {
            oscNormal.DrawGrid();

            await SendDefaultWIZnetValues();

            await SendStartEndPixels();

            await DisableWB();
        }
    }
}
