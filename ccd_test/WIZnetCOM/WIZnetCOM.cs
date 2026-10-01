using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Threading.Tasks;
using WIZnetCOM.Boards;
using WIZnetCOM.LogSystem;

namespace WIZnetCOM
{
    public class WIZnetCOM
    {
        public Action<bool> OnConnectionChanged;
        public Action<string> OnPacketSent;

        int totalPackagesSent = 0;

        public int TransmissionInterval { get; private set; }
        public bool IsConnected { get; set; }

        byte[] sourceIp;
        int sourcePort;

        byte[] destIp;
        int destPort;

        public int PacketsPerTransmission = 20;

        public int NumberOfChutes { get; set; }
        public int NumberOfDRVLEDs { get; set; }

        TcpClient client;
        public NetworkStream Stream { get; private set; }

        Mutex cmdQueueMutex = new Mutex();

        Timer receiverTimer;

        public WIZnetData COMData;

        public Interface Interface { get; private set; }

        public List<List<CCD>> CcdSelector { get; private set; }

        public List<CCD> FrontCCDs { get; set; }
        public List<CCD> RearCCDs { get; set; }
        public List<CCD> IRCCDs { get; set; }

        public List<CE> CEs;

        public DRVLED DRVLEDFront;
        public DRVLED DRVLEDRear;

        LinkedList<TxPacket> cmdBuffers = new LinkedList<TxPacket>();
        MicroLibrary.MicroTimer uTimer;

        public WIZnetCOM()
        {
            LogWriter.Instance.WriteToLog($"WIZnet Instance Created");

            uTimer = new MicroLibrary.MicroTimer();
            uTimer.MicroTimerElapsed += new MicroLibrary.MicroTimer.MicroTimerElapsedEventHandler(OnTimedEvent);

            COMData = new WIZnetData(this);
        }

        public bool InitModules()
        {
            if (NumberOfChutes == 0) return false;
            if (NumberOfDRVLEDs == 0) return false;

            Interface = new Interface();
            Interface.SendCommand_OnRequested += SendCommand_OnRequested;

            FrontCCDs = new List<CCD>();
            RearCCDs = new List<CCD>();
            IRCCDs = new List<CCD>();

            for (byte i = 1; i <= NumberOfChutes; i++)
            {
                byte lastBoard = (byte)(i == NumberOfChutes ? 1 : 0);
                FrontCCDs.Add(new CCD(1, i, lastBoard));
                RearCCDs.Add(new CCD(2, i, lastBoard));
                IRCCDs.Add(new CCD(3, i, lastBoard));

                FrontCCDs[i - 1].SendCommand_OnRequested += SendCommand_OnRequested;
                RearCCDs[i - 1].SendCommand_OnRequested += SendCommand_OnRequested;
                IRCCDs[i - 1].SendCommand_OnRequested += SendCommand_OnRequested;
            }

            CcdSelector = new List<List<CCD>>();
            CcdSelector.Add(FrontCCDs);
            CcdSelector.Add(RearCCDs);
            CcdSelector.Add(IRCCDs);

            // Create CE boards
            CEs = new List<CE>();

            for (byte i = 1; i <= NumberOfChutes; i++)
            {
                byte lastBoard = (byte)(i == NumberOfChutes ? 1 : 0);
                CEs.Add(new CE(5, i, lastBoard));
                CEs[i - 1].SendCommand_OnRequested += SendCommand_OnRequested;
            }

            // Create DRVLED boards
            if (NumberOfDRVLEDs == 1)
            {
                DRVLEDFront = new DRVLED(4, 1, 1);
                DRVLEDFront.SendCommand_OnRequested += SendCommand_OnRequested;
            }
            else if (NumberOfDRVLEDs == 2)
            {
                DRVLEDFront = new DRVLED(4, 1, 0);
                DRVLEDFront.SendCommand_OnRequested += SendCommand_OnRequested;

                DRVLEDRear = new DRVLED(4, 2, 1);
                DRVLEDRear.SendCommand_OnRequested += SendCommand_OnRequested;
            }

            return true;
        }

        private void OnTimedEvent(object sender, MicroLibrary.MicroTimerEventArgs timerEventArgs)
        {
            cmdQueueMutex.WaitOne();

            if (cmdBuffers.Count > 0)
            {
                try
                {
                    TxPacket packet = cmdBuffers.First.Value;
                    List<byte> temp = packet.Data.GetRange(0, packet.Data.Count);
                    Stream?.Write(temp.ToArray(), 0, temp.Count);
                    cmdBuffers.RemoveFirst();

                    if (packet.NotifyOnSend)
                    {
                        OnPacketSent(packet.NotifyIdentifier);
                    }
                }
                catch (IOException ioe)
                {
                    uTimer.Enabled = false;

                    OnConnectionChanged(false);

                    LogWriter.Instance.WriteToLog($"IO Exception when writing to Stream: {ioe.ToString()}", EMessagePriority.Info);
                }
                catch (Exception e)
                {
                    uTimer.Enabled = false;

                    OnConnectionChanged(false);

                    LogWriter.Instance.WriteToLog($"General Exception when writing to Stream: {e.ToString()}", EMessagePriority.Info);
                }
            }

            cmdQueueMutex.ReleaseMutex();

            if (timerEventArgs.TimerCount % 1000 == 0)
            {
                LogWriter.Instance.WriteToLog(string.Format(
                    "Count = {0:#,0}  Timer = {1:#,0} µs, " +
                    "LateBy = {2:#,0} µs, ExecutionTime = {3:#,0} µs",
                    timerEventArgs.TimerCount, timerEventArgs.ElapsedMicroseconds,
                    timerEventArgs.TimerLateBy, timerEventArgs.CallbackFunctionExecutionTime));
            }
        }

        public void SendCommand_OnRequested(TxData txData)
        {
            if (txData.Data.Length == 34)
            {
                // Get HW line byte.
                int buffIdx = txData.Data[1];

                cmdQueueMutex.WaitOne();

                if (txData.Prioritize == true)
                {
                    cmdBuffers.AddFirst(new TxPacket(txData));
                }
                else
                {
                    if (cmdBuffers.Count == 0)
                    {
                        cmdBuffers.AddLast(new TxPacket(txData));
                    }

                    var packet = cmdBuffers.Last.Value;

                    if (packet.Data.Count >= PacketsPerTransmission * 36)
                    {
                        // If previous node was full, create a new node and insert data into it.
                        cmdBuffers.AddLast(new TxPacket(txData));
                    }
                    else
                    {
                        // If notify on send is already set for this packet, put the data into a new packet.
                        if (packet.NotifyOnSend == true)
                        {
                            cmdBuffers.AddLast(new TxPacket(txData));
                        }
                        else
                        {
                            packet.Add(txData);
                        }
                    }
                }

                cmdQueueMutex.ReleaseMutex();
            }
            else
            {
                LogWriter.Instance.WriteToLog($"Invalid TX_DATA size. Should be 34 but was {txData.Data.Length}");
            }
        }

        public async Task<bool> Connect(byte[] sIp, int sPort, byte[] dIp, int dPort)
        {
            sourceIp = sIp;
            sourcePort = sPort;

            destIp = dIp;
            destPort = dPort;

            IsConnected = false;

            // Can choose to ignore event if late by Xµs (by default will try to catch up)
            //uTimer.IgnoreEventIfLateBy = 2500;

            try
            {
                if (client != null && Stream != null)
                {
                    Stream.Close();
                    client.Close();
                }

                IPAddress ipAddressSource = new IPAddress(sourceIp);
                IPEndPoint ipSourceEndPoint = new IPEndPoint(ipAddressSource, sourcePort);
                client = new TcpClient(ipSourceEndPoint);

                IPAddress ipAddressDest = new IPAddress(destIp);
                IPEndPoint ipDestEndPoint = new IPEndPoint(ipAddressDest, destPort);
                client.Connect(ipDestEndPoint);

                client.NoDelay = true;

                Stream = client.GetStream();

                if (client.Connected)
                {
                    LogWriter.Instance.WriteToLog($"Connected to TCP Server");

                    IsConnected = true;

                    uTimer.Enabled = true; // Start timer
                }
            }
            catch (ArgumentNullException e)
            {
                LogWriter.Instance.WriteToLog($"ArgumentNullException: {e.ToString()}");
            }
            catch (SocketException e)
            {
                LogWriter.Instance.WriteToLog($"SocketException: {e.ToString()}");
            }

            return IsConnected;
        }

        public void PauseTimer()
        {
            uTimer.Enabled = false;
        }

        public void StartTimer()
        {
            uTimer.Enabled = true;
        }

        public void UpdateTimerInterval(int newInterval)
        {
            TransmissionInterval = newInterval;
            uTimer.Interval = TransmissionInterval * 1000; // Call micro timer every 25000µs (25ms)
        }

        public void SendNotificationPacket(string key)
        {
            TxData txData = new TxData();
            txData.NotifyOnSend = true;
            txData.NotifyIdentifier = key;

            SendCommand_OnRequested(txData);
        }

        public int GetNumberOfPacketsInQueue()
        {
            return cmdBuffers.Count;
        }
    }
}
