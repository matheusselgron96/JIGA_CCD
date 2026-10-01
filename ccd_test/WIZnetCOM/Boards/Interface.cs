using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace WIZnetCOM.Boards
{
    public class AndOrData
    {
        public event PropertyChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public AndOrData()
        {
            enableFMAnd  = false;
            enableBMAnd  = false;
            enableIRAnd  = false;
            enableFMOr   = true;
            enableBMOr   = true;
            enableIROr   = false;
            enableModule = false;
        }

        public void Set(AndOrData newData)
        {
            enableFMAnd  = newData.enableFMAnd;
            enableBMAnd  = newData.enableBMAnd;
            enableIRAnd  = newData.enableIRAnd;
            enableFMOr   = newData.enableFMOr;
            enableBMOr   = newData.enableBMOr;
            enableIROr   = newData.enableIROr;
            enableModule = newData.enableModule;

            OnPropertyChanged();
        }

        #region Properties

        private bool enableModule;

        public bool EnableModule
        {
            get { return enableModule; }
            set
            {
                enableModule = value;
                OnPropertyChanged();
            }
        }

        private bool enableFMAnd;

        public bool EnableFMAnd
        {
            get { return enableFMAnd; }
            set
            {
                enableFMAnd = value;
                OnPropertyChanged();
            }
        }

        private bool enableBMAnd;

        public bool EnableBMAnd
        {
            get { return enableBMAnd; }
            set
            {
                enableBMAnd = value;
                OnPropertyChanged();
            }
        }

        private bool enableIRAnd;

        public bool EnableIRAnd
        {
            get { return enableIRAnd; }
            set
            {
                enableIRAnd = value;
                OnPropertyChanged();
            }
        }

        private bool enableFMOr;

        public bool EnableFMOr
        {
            get { return enableFMOr; }
            set
            {
                enableFMOr = value;
                OnPropertyChanged();
            }
        }

        private bool enableBMOr;

        public bool EnableBMOr
        {
            get { return enableBMOr; }
            set
            {
                enableBMOr = value;
                OnPropertyChanged();
            }
        }

        private bool enableIROr;

        public bool EnableIROr
        {
            get { return enableIROr; }
            set
            {
                enableIROr = value;
                OnPropertyChanged();
            }
        }

        #endregion
    }

    public class InterfaceConfigData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // HW Line
            txData.Data[1] = 0x0;
            // Interface CMD
            txData.Data[2] = 0x0;
            txData.Data[3] = 0xA;
            // tx_debouncer_base
            txData.Data[4] = (byte)(TxDebouncerBase >> 8);
            txData.Data[5] = (byte)(TxDebouncerBase);
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
            txData.Data[14] = (byte)(AutoOscDebouncerBase >> 8);
            txData.Data[15] = (byte)(AutoOscDebouncerBase);
            txData.Data[16] = 0x0;
            txData.Data[17] = 0x0;
            // autoImgDebouncerBase
            txData.Data[18] = (byte)(AutoImgDebouncerBase >> 8);
            txData.Data[19] = (byte)(AutoImgDebouncerBase);
            txData.Data[20] = 0x0;
            txData.Data[21] = 0x0;

            PropertyChanged?.Invoke(txData);
        }

        public InterfaceConfigData()
        {
            txDebouncerBase      = 5;
            autoOscDebouncerBase = 2500;
            autoImgDebouncerBase = 2500;

            ejRateDebouncerBase = 500;
            ejRateSamplingTime  = 2500;
        }

        public void Set(InterfaceConfigData newData)
        {
            txDebouncerBase      = newData.TxDebouncerBase;
            autoOscDebouncerBase = newData.AutoOscDebouncerBase;
            autoImgDebouncerBase = newData.AutoImgDebouncerBase;
            ejRateDebouncerBase  = newData.EjRateDebouncerBase;
            ejRateSamplingTime   = newData.EjRateSamplingTime;

            OnPropertyChanged();
        }

        #region Properties

        private ushort txDebouncerBase;

        public ushort TxDebouncerBase
        {
            get { return txDebouncerBase; }
            set
            {
                txDebouncerBase = value;
                OnPropertyChanged();
            }
        }

        private short autoOscDebouncerBase;

        public short AutoOscDebouncerBase
        {
            get { return autoOscDebouncerBase; }
            set
            {
                autoOscDebouncerBase = value;
                OnPropertyChanged();
            }
        }

        private short autoImgDebouncerBase;

        public short AutoImgDebouncerBase
        {
            get { return autoImgDebouncerBase; }
            set
            {
                autoImgDebouncerBase = value;
                OnPropertyChanged();
            }
        }

        private short ejRateDebouncerBase;

        public short EjRateDebouncerBase
        {
            get { return ejRateDebouncerBase; }
            set
            {
                ejRateDebouncerBase = value;
                OnPropertyChanged();
            }
        }

        private short ejRateSamplingTime;

        public short EjRateSamplingTime
        {
            get { return ejRateSamplingTime; }
            set
            {
                ejRateSamplingTime = value;
                OnPropertyChanged();
            }
        }

        #endregion
    }

    public class Interface
    {
        public class EjectionPacketData
        {
            public delegate void CCDDataChangedEventHandler(TxData txData);

            public event CCDDataChangedEventHandler PropertyChanged;

            public void OnPropertyChanged([CallerMemberName] string propertyName = null)
            {
                TxData txData = new TxData();

                // Interface CMD
                txData.Data[2] = 0x0;
                txData.Data[3] = 0x11;
                //LAST BOARD, MUST BE 1
                txData.Data[4] = 0x0;
                txData.Data[5] = 0x1;
                //BURST START, MUST BE 1
                txData.Data[6] = 0x0;
                txData.Data[7] = 0x1;
                //BURST END, MUST BE 512 (0x200)
                txData.Data[8] = 0x2;
                txData.Data[9] = 0x0;
                //END PACKET, MUST BE 512 (0x200)
                txData.Data[10] = 0x2;
                txData.Data[11] = 0x0;
                // Enable
                txData.Data[12] = 0x0;
                txData.Data[13] = Enable;

                PropertyChanged?.Invoke(txData);
            }

            public EjectionPacketData()
            {
                enable = 0;

                OnPropertyChanged();
            }

            public void Set(EjectionPacketData newData)
            {
                enable = newData.Enable;

                OnPropertyChanged();
            }

            #region Properties

            private byte enable;

            public byte Enable
            {
                get { return enable; }
                set
                {
                    enable = value;
                    OnPropertyChanged();
                }
            }

            #endregion Properties
        }

        public EjectionPacketData EjectionPacket;

        public delegate void SendCommandHandler(TxData txData);

        public event SendCommandHandler SendCommand_OnRequested = delegate { };

        public Interface()
        {
            EjectionPacket = new EjectionPacketData();
            EjectionPacket.PropertyChanged += InterfaceData_PropertyChanged;
        }

        private void InterfaceData_PropertyChanged(TxData txData)
        {
            // HW Line
            txData.Data[0] = 0x0;
            txData.Data[1] = 0x0;

            SendCommand_OnRequested(txData);
        }
    }
}
