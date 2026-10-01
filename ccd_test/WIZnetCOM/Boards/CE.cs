using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace WIZnetCOM.Boards
{
    public class PacketIHMData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 0x1;
            txData.Data[5] = 0x0;

            // Last board
            txData.Data[6] = LastBoard;
            txData.Data[7] = 0x0;

#if NEW_COMMS
            // Enable
            txData.Data[8] = EnableReturnIHM;
            txData.Data[9] = 0;
#else
            // start_pack_pos
            txData.Data[8] = 0xA1;
            txData.Data[9] = 0x0;

            // end_pack_pos
            txData.Data[10] = (byte)(EndPacketData);
            txData.Data[11] = (byte)(EndPacketData >> 8);

            // enable
            txData.Data[12] = EnableReturnIHM;
            txData.Data[13] = 0x0;
#endif

            PropertyChanged?.Invoke(txData);
        }

        public PacketIHMData(int boardId, byte lastBoard)
        {
            this.lastBoard = lastBoard;
            endPacketData = 0x3F0;
            enableReturnIHM = 1;
        }

        public void Set(PacketIHMData newData)
        {
            lastBoard = newData.lastBoard;
            endPacketData = newData.endPacketData;
            enableReturnIHM = newData.enableReturnIHM;

            OnPropertyChanged();
        }

        private byte lastBoard;

        public byte LastBoard
        {
            get { return lastBoard; }
            set
            {
                lastBoard = value;
                OnPropertyChanged();
            }
        }

        private short endPacketData;

        public short EndPacketData
        {
            get { return endPacketData; }
            set
            {
                endPacketData = value;
                OnPropertyChanged();
            }
        }

        private byte enableReturnIHM;

        public byte EnableReturnIHM
        {
            get { return enableReturnIHM; }
            set
            {
                enableReturnIHM = value;
                OnPropertyChanged();
            }
        }
    }

    public class EjectionConfigData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            for (byte i = 1; i <= 8; i++)
            {
                //Config EJECTOR
                // HW Line
                txData.Data[1] = 0x5;
                // Set board ID
                txData.Data[2] = i;
                // Set Switch
                txData.Data[4] = 0x4;
                //t0
                txData.Data[6] = (byte)T0;
                txData.Data[7] = (byte)(T0 >> 8);
                //t1
                txData.Data[8] = (byte)T1;
                txData.Data[9] = (byte)(T1 >> 8);
                //t2
                txData.Data[10] = (byte)T2;
                txData.Data[11] = (byte)(T2 >> 8);
                //t3
                txData.Data[12] = (byte)T3;
                txData.Data[13] = (byte)(T3 >> 8);
                //t4
                txData.Data[14] = (byte)T4;
                txData.Data[15] = (byte)(T4 >> 8);
                //ndwell
                txData.Data[16] = (byte)Ndwell;
                txData.Data[17] = (byte)(Ndwell >> 8);
                //limit ejec
                txData.Data[18] = (byte)LimitEjection;
                txData.Data[19] = (byte)(LimitEjection >> 8);
                //enable
                txData.Data[20] = Convert.ToByte(Enable);
                txData.Data[21] = 0x0;
                // max state
                txData.Data[22] = (byte) MaxState;
                txData.Data[23] = (byte)(MaxState >> 8);

                PropertyChanged?.Invoke(txData);
            }
        }

        public EjectionConfigData()
        {
            t0 = 22;
            t1 = 0;
            t2 = 1;
            t3 = 0;
            t4 = 1;
            ndwell = 126;
            limitEjection = 32;
            enable = false;
            maxState = 5;
        }

        public void Set(EjectionConfigData newData)
        {
            t0 = newData.T0;
            t1 = newData.T1;
            t2 = newData.T2;
            t3 = newData.T3;
            t4 = newData.T4;
            ndwell = newData.Ndwell;
            limitEjection = newData.LimitEjection;
            enable = newData.Enable;
            maxState = newData.maxState;

            OnPropertyChanged();
        }

        #region Properties

        private short t0;

        public short T0
        {
            get { return t0; }
            set
            {
                t0 = value;
                OnPropertyChanged();
            }
        }

        private short t1;

        public short T1
        {
            get { return t1; }
            set
            {
                t1 = value;
                OnPropertyChanged();
            }
        }

        private short t2;

        public short T2
        {
            get { return t2; }
            set
            {
                t2 = value;
                OnPropertyChanged();
            }
        }

        private short t3;

        public short T3
        {
            get { return t3; }
            set
            {
                t3 = value;
                OnPropertyChanged();
            }
        }

        private short t4;

        public short T4
        {
            get { return t4; }
            set
            {
                t4 = value;
                OnPropertyChanged();
            }
        }

        private short ndwell;

        public short Ndwell
        {
            get { return ndwell; }
            set
            {
                ndwell = value;
                OnPropertyChanged();
            }
        }

        private short limitEjection;

        public short LimitEjection
        {
            get { return limitEjection; }
            set
            {
                limitEjection = value;
                OnPropertyChanged();
            }
        }

        private bool enable;

        public bool Enable
        {
            get { return enable; }
            set
            {
                enable = value;
                OnPropertyChanged();
            }
        }

        private short maxState;

        public short MaxState
        {
            get { return maxState; }
            set
            {
                maxState = value;
                OnPropertyChanged();
            }
        }

        #endregion Properties
    }

    public class CE
    {
        public delegate void SendCommandHandler(TxData txData);

        public event SendCommandHandler SendCommand_OnRequested = delegate { };

        public byte HWLine { get; set; }
        public byte BoardID { get; set; }
        public byte LastBoard { get; set; }

        public PacketIHMData PacketIHM;

        public CE(byte hwLine, byte boardID, byte lastBoard)
        {
            HWLine = hwLine;
            BoardID = boardID;
            LastBoard = lastBoard;

            PacketIHM = new PacketIHMData(BoardID, LastBoard);
            PacketIHM.PropertyChanged += CEData_PropertyChanged;
        }

        private void CEData_PropertyChanged(TxData txData)
        {
            txData.Data[1] = HWLine;
            txData.Data[2] = BoardID;

            SendCommand_OnRequested(txData);
        }
    }
}
