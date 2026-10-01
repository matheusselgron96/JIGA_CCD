using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;

namespace WIZnetCOM.Boards
{
    public class TemperatureData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // HW Line
            txData.Data[1] = 0x4;
            // Board ID
            txData.Data[2] = BoardID;
            // Set Switch
            txData.Data[4] = 0x2;
            // Max Temp
            txData.Data[6] = (byte)(MaxTemp);
            txData.Data[7] = (byte)(MaxTemp >> 8);
            // Delta Temp
            txData.Data[8] = (byte)(DeltaTemp);
            txData.Data[9] = (byte)(DeltaTemp >> 8);
            // Max Temp Time
            txData.Data[10] = (byte)(MaxTempTime);
            txData.Data[11] = (byte)(MaxTempTime >> 8);

            PropertyChanged?.Invoke(txData);   
        }

        public TemperatureData()
        {
            maxTemp     = 80;
            deltaTemp   = 5;
            maxTempTime = 10;
        }

        public void Set(TemperatureData newData)
        {
            maxTemp = newData.maxTemp;
            deltaTemp = newData.deltaTemp;
            maxTempTime = newData.maxTempTime;

            OnPropertyChanged();
        }

        #region Properties

        public byte BoardID;

        private short maxTemp;

        public short MaxTemp
        {
            get { return maxTemp; }
            set
            {
                maxTemp = value;
                OnPropertyChanged();
            }
        }

        private short deltaTemp;

        public short DeltaTemp
        {
            get { return deltaTemp; }
            set
            {
                deltaTemp = value;
                OnPropertyChanged();
            }
        }

        private short maxTempTime;

        public short MaxTempTime
        {
            get { return maxTempTime; }
            set
            {
                maxTempTime = value;
                OnPropertyChanged();
            }
        }

        #endregion
    }

    public class FailureData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 0x3;
            // overrideFailures
            txData.Data[6] = OverrideFailures;
            txData.Data[7] = 0x0;
            // resetAllFailures
            txData.Data[8] = ResetFailures;
            txData.Data[9] = 0x0;
            // resetFailuresSns1
            txData.Data[10] = ResetFailure1;
            txData.Data[11] = 0x0;
            // resetFailuresSns2
            txData.Data[12] = ResetFailure2;
            txData.Data[13] = 0x0;
            // resetFailuresSns3
            txData.Data[14] = ResetFailure3;
            txData.Data[15] = 0x0;

            PropertyChanged?.Invoke(txData);
        }

        public FailureData()
        {
            overrideFailures = 0;
            resetFailures = 0;
            resetFailure1 = 0;
            resetFailure2 = 0;
            resetFailure3 = 0;
        }

        public void Set(FailureData newData)
        {
            overrideFailures = newData.overrideFailures;
            resetFailures = newData.resetFailures;
            resetFailure1 = newData.resetFailure1;
            resetFailure2 = newData.resetFailure2;
            resetFailure3 = newData.resetFailure3;

            OnPropertyChanged();
        }

        #region Properties

        private byte overrideFailures;

        public byte OverrideFailures
        {
            get { return overrideFailures; }
            set
            {
                overrideFailures = value;
                OnPropertyChanged();
            }
        }

        private byte resetFailures;

        public byte ResetFailures
        {
            get { return resetFailures; }
            set
            {
                resetFailures = value;
                OnPropertyChanged();
                resetFailures = 0;
            }
        }

        private byte resetFailure1;

        public byte ResetFailure1
        {
            get { return resetFailure1; }
            set
            {
                resetFailure1 = value;
                OnPropertyChanged();
                resetFailure1 = 0;
            }
        }

        private byte resetFailure2;

        public byte ResetFailure2
        {
            get { return resetFailure2; }
            set
            {
                resetFailure2 = value;
                OnPropertyChanged();
                resetFailure2 = 0;
            }
        }

        private byte resetFailure3;

        public byte ResetFailure3
        {
            get { return resetFailure3; }
            set
            {
                resetFailure3 = value;
                OnPropertyChanged();
                resetFailure3 = 0;
            }
        }

        #endregion
    }

    public class DRVLED
    {
        public delegate void SendCommandHandler(TxData txData);

        public event SendCommandHandler SendCommand_OnRequested = delegate { };

        public byte HWLine { get; set; }
        public byte BoardID { get; set; }
        public byte LastBoard { get; set; }

        public PacketIHMData PacketIHM;
        public FailureData FailureControl;

        public DRVLED(byte hwLine, byte boardID, byte lastBoard)
        {
            HWLine = hwLine;
            BoardID = boardID;
            LastBoard = lastBoard;

            PacketIHM = new PacketIHMData(BoardID, LastBoard);
            PacketIHM.PropertyChanged += DRVLEDData_PropertyChanged;

            FailureControl = new FailureData();
            FailureControl.PropertyChanged += DRVLEDData_PropertyChanged;
        }

        private void DRVLEDData_PropertyChanged(TxData txData)
        {
            txData.Data[1] = HWLine;
            txData.Data[2] = BoardID;

            SendCommand_OnRequested(txData);
        }
    }
}
