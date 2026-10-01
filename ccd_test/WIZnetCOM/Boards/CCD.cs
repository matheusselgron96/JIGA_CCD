using System;
using System.ComponentModel;
using System.Runtime.CompilerServices;
using System.Xml.Serialization;

namespace WIZnetCOM.Boards
{
    // CMD 0x0
    public class LedConfigData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 0x0;
            // sync enable
            txData.Data[6] = ledValue;

            PropertyChanged?.Invoke(txData);
        }

        public LedConfigData()
        {
            ledValue = 0;

            OnPropertyChanged();
        }

        public void Set(LedConfigData newData)
        {
            ledValue = newData.LedValue;

            OnPropertyChanged();
        }

        #region Properties

        private byte ledValue;

        public byte LedValue
        {
            get { return ledValue; }
            set
            {
                ledValue = value;
                OnPropertyChanged();
            }
        }

        #endregion Properties
    }

    // CMD 0x1E
    public class ClassificationData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        [XmlIgnore]
        public Action OnClassificationDataChanged = delegate { };

        public void OnPropertyChanged()
        {
            TxData txData = new TxData();

            OnClassificationDataChanged();

            for (byte i = 1; i <= 8; i++)
            {
                // Set board ID
                txData.Data[2] = i;

                // Set Switch
                txData.Data[4] = 0x1E;
                // grain size lines max
                txData.Data[6] = (byte)(GrainSize);
                txData.Data[7] = (byte)(GrainSize >> 8);
                // grain min pixels
                txData.Data[8] = (byte)(MinPixels);
                txData.Data[9] = (byte)(MinPixels >> 8);
                // sync buffer offset
                txData.Data[10] = (byte)(Delay);
                txData.Data[11] = (byte)(Delay >> 8);
                // sync buffer dwell
                txData.Data[12] = Convert.ToByte(StaticPulse);
                txData.Data[13] = 0x0;
                //  pixels per ch
                txData.Data[14] = 0x3F;
                txData.Data[15] = 0x0;
                // Classification type
                txData.Data[16] = (byte)(VerticalErosion);
                txData.Data[17] = (byte)(VerticalErosion >> 8);

                txData.Data[18] = (byte)(Dwell);
                txData.Data[19] = (byte)(Dwell >> 8);

                txData.Data[20] = EjectionPosition;
                txData.Data[21] = 0x0;

                txData.Data[22] = BackgroundMode;
                txData.Data[23] = 0x0;

                if (IsIr == false)
                {
                    // HW Line
                    txData.Data[1] = 0x1;

                    PropertyChanged?.Invoke(txData);

                    // HW Line
                    txData.Data[1] = 0x2;

                    // sync buffer offset
                    int offsettedDelay = Delay + RearOffset;
                    txData.Data[10] = (byte)(offsettedDelay);
                    txData.Data[11] = (byte)(offsettedDelay >> 8);

                    PropertyChanged?.Invoke(txData);
                }
                else
                {
                    // HW Line
                    txData.Data[1] = 0x3;

                    PropertyChanged?.Invoke(txData);
                }
            }
        }

        public ClassificationData()
        {
            grainSize          = 0;
            minPixels          = 0;
            sens               = 0;
            delay              = 0;
            dwell              = 0;
            staticPulse        = false;
            rearOffset         = 0;
            verticalErosion    = 0;
        }

        public void Set(ClassificationData newData)
        {
            grainSize          = newData.grainSize;
            minPixels          = newData.minPixels;
            sens               = newData.sens;
            delay              = newData.delay;
            dwell              = newData.dwell;
            staticPulse        = newData.staticPulse;
            rearOffset         = newData.rearOffset;
            verticalErosion    = newData.verticalErosion;

            OnPropertyChanged();
        }

        #region Properties

        public bool IsIr {  get; set; }

        private short grainSize;

        public short GrainSize
        {
            get { return grainSize; }
            set
            {
                grainSize = value;
                OnPropertyChanged();
            }
        }

        private short minPixels;

        public short MinPixels
        {
            get { return minPixels; }
            set
            {
                minPixels = value;
                OnPropertyChanged();
            }
        }

        private short sens;

        public short Sens
        {
            get { return sens; }
            set
            {
                sens = value;
                OnPropertyChanged();
            }
        }

        private short delay;

        public short Delay
        {
            get { return delay; }
            set
            {
                delay = value;
                OnPropertyChanged();
            }
        }

        private short dwell;

        public short Dwell
        {
            get { return dwell; }
            set
            {
                dwell = value;
                OnPropertyChanged();
            }
        }

        private bool staticPulse;

        public bool StaticPulse
        {
            get { return staticPulse; }
            set
            {
                staticPulse = value;
                OnPropertyChanged();
            }
        }

        private short rearOffset;

        public short RearOffset
        {
            get { return rearOffset; }
            set
            {
                rearOffset = value;
                OnPropertyChanged();
            }
        }

        private short verticalErosion;

        public short VerticalErosion
        {
            get { return verticalErosion; }
            set
            {
                verticalErosion = value;
                OnPropertyChanged();
            }
        }

        private byte ejectionPosition;

        public byte EjectionPosition
        {
            get { return ejectionPosition; }
            set
            {
                ejectionPosition = value;
                OnPropertyChanged();
            }
        }

        private byte backgroundMode;

        public byte BackgroundMode
        {
            get { return backgroundMode; }
            set
            {
                backgroundMode = value;
                OnPropertyChanged();
            }
        }

        #endregion
    }

    // CMD 0x1
    public class SyncBufferData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 0x1;
            // sync enable
            txData.Data[6] = enable;

            PropertyChanged?.Invoke(txData);
        }

        public SyncBufferData(int boardId)
        {
            enable = 0;

            OnPropertyChanged();
        }

        public void Set(SyncBufferData newData)
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

    // CMD 0x2
    public class HMIReturnPacketData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 0x2;

            // lastBoard
            txData.Data[6] = LastBoard;
            txData.Data[7] = 0x0;
#if NEW_COMMS
            // Enable
            txData.Data[8] = EnableReturnIHM;
            txData.Data[9] = 0;

            // Enable
            txData.Data[8] = EnableReturnIHM;
            txData.Data[9] = 0;
#else
            // endPacketData
            txData.Data[8] = (byte)(EndPacketData);
            txData.Data[9] = (byte)(EndPacketData >> 8);

            // endPosition
            txData.Data[10] = (byte)(EndPosition);
            txData.Data[11] = (byte)(EndPosition >> 8);

            // enableReturnIHM
            txData.Data[12] = EnableReturnIHM;
            txData.Data[13] = 0x0;

            // tor
            txData.Data[14] = (byte)(Tor);
            txData.Data[15] = (byte)(Tor >> 8);
#endif

            PropertyChanged?.Invoke(txData);
        }

        public HMIReturnPacketData(int boardId, byte lastBoard)
        {
            this.lastBoard  = lastBoard;
            endPacketData   = 0x1210;
            endPosition     = 0x1210;
            enableReturnIHM = 1;
            tor             = 0x0101;

            OnPropertyChanged();
        }

        public void Set(HMIReturnPacketData newData)
        {
            lastBoard       = newData.lastBoard;
            endPacketData   = newData.endPacketData;
            endPosition     = newData.endPosition;
            enableReturnIHM = newData.enableReturnIHM;
            tor             = newData.tor;

            OnPropertyChanged();
        }

        #region Properties

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

        private short endPosition;

        public short EndPosition
        {
            get { return endPosition; }
            set
            {
                endPosition = value;
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

        private short tor;

        public short Tor
        {
            get { return tor; }
            set
            {
                tor = value;
                OnPropertyChanged();
            }
        }

        #endregion Properties
    }

    // CMD 0x3
    public class EjectionPacketData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 0x3;
            // lastBoard
            txData.Data[6] = LastBoard;
            txData.Data[7] = 0x0;
            // burst start
            txData.Data[8] = (byte)(BurstStart);
            txData.Data[9] = (byte)(BurstStart >> 8);
            // burst end
            txData.Data[10] = (byte)(BurstEnd);
            txData.Data[11] = (byte)(BurstEnd >> 8);
            //end eje
            txData.Data[12] = 0x0;
            txData.Data[13] = EndEj;
            //enable eje
            txData.Data[14] = EnableEj;

            PropertyChanged?.Invoke(txData);
        }

        public EjectionPacketData(int boardId, byte lastBoard)
        {
            this.lastBoard = lastBoard;
            burstStart     = (short)(((boardId - 1) * 64) + 1);
            burstEnd       = (short)(((boardId - 1) * 64) + 64);
            endEj          = 2;
            enableEj       = 1;

            OnPropertyChanged();
        }

        public void Set(EjectionPacketData newData)
        {
            lastBoard = newData.LastBoard;
            burstStart = newData.BurstStart;
            burstEnd = newData.BurstEnd;
            endEj = newData.EndEj;
            enableEj = newData.EnableEj;

            OnPropertyChanged();
        }

        #region Properties

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

        private short burstStart;

        public short BurstStart
        {
            get { return burstStart; }
            set
            {
                burstStart = value;
                OnPropertyChanged();
            }
        }

        private short burstEnd;

        public short BurstEnd
        {
            get { return burstEnd; }
            set
            {
                burstEnd = value;
                OnPropertyChanged();
            }
        }

        private byte endEj;

        public byte EndEj
        {
            get { return endEj; }
            set
            {
                endEj = value;
                OnPropertyChanged();
            }
        }

        private byte enableEj;

        public byte EnableEj
        {
            get { return enableEj; }
            set
            {
                enableEj = value;
                OnPropertyChanged();
            }
        }

        #endregion Properties
    }

    // CMD 0x4
    public class OscilloscopeConfigData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 0x4;

            // max bytes per sync
            txData.Data[6] = (byte)(MaxBytesPerSync);
            txData.Data[7] = (byte)(MaxBytesPerSync >> 8);
            // syncs to send again
            txData.Data[8] = SyncsToSendAgain;
            // enable submodule
            txData.Data[10] = EnableModule;

            PropertyChanged?.Invoke(txData);
        }

        public OscilloscopeConfigData()
        {
            maxBytesPerSync = 0x800;
            syncsToSendAgain = 0x64;
            enableModule = 0x1;

            OnPropertyChanged();
        }

        public void Set(OscilloscopeConfigData newData)
        {
            maxBytesPerSync = newData.maxBytesPerSync;
            syncsToSendAgain = newData.syncsToSendAgain;
            enableModule = newData.enableModule;

            OnPropertyChanged();
        }

        #region Properties

        private short maxBytesPerSync;

        public short MaxBytesPerSync
        {
            get { return maxBytesPerSync; }
            set
            {
                maxBytesPerSync = value;
                OnPropertyChanged();
            }
        }

        private byte syncsToSendAgain;

        public byte SyncsToSendAgain
        {
            get { return syncsToSendAgain; }
            set
            {
                syncsToSendAgain = value;
                OnPropertyChanged();
            }
        }

        private byte enableModule;

        public byte EnableModule
        {
            get { return enableModule; }
            set
            {
                enableModule = value;
                OnPropertyChanged();
            }
        }

        #endregion Properties
    }

    // CMD 0x5
    public class SDRAMConfigData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 0x5;

            // npixels
            txData.Data[6] = (byte)(NPixels);
            txData.Data[7] = (byte)(NPixels >> 8);
            // nlines
            txData.Data[8] = (byte)(NLines);
            txData.Data[9] = (byte)(NLines >> 8);
            // capture flag
            txData.Data[10] = CaptureFlag;
            txData.Data[11] = 0x0;
            // target blue
            txData.Data[12] = TargetBlue;
            txData.Data[13] = 0x0;
            // enable capture
            txData.Data[14] = EnableCapture;
            txData.Data[15] = 0x0;
            // TODO - type of return
            txData.Data[16] = 0x0;
            txData.Data[17] = 0x0;
            // Reset
            txData.Data[18] = 0x0;
            txData.Data[19] = 0x0;
            // No Target
            txData.Data[20] = EnableTarget;
            txData.Data[21] = 0x0;

            PropertyChanged?.Invoke(txData);
        }

        public SDRAMConfigData()
        {
            nPixels       = 0x800;
            nLines        = 0x31F;
            captureFlag   = 0x0;
            targetBlue    = 0xFF;
            enableCapture = 0x0;
            tor           = 0x0;
            enableTarget  = 0x0;

            OnPropertyChanged();
        }

        public void Set(SDRAMConfigData newData)
        {
            nPixels       = newData.NPixels;
            nLines        = newData.NLines;
            captureFlag   = newData.CaptureFlag;
            targetBlue    = newData.TargetBlue;
            enableCapture = newData.EnableCapture;
            tor           = newData.Tor;
            enableTarget  = newData.EnableTarget;

            OnPropertyChanged();
        }

        // Return a deep copy, but with no PropertyChanged event set
        public SDRAMConfigData GetCopy()
        {
            SDRAMConfigData copy = new SDRAMConfigData();
            copy.nPixels       = NPixels;
            copy.nLines        = NLines;
            copy.captureFlag   = CaptureFlag;
            copy.targetBlue    = TargetBlue;
            copy.enableCapture = EnableCapture;
            copy.tor           = Tor;

            return copy;
        }

        #region Properties

        private short nPixels;

        public short NPixels
        {
            get { return nPixels; }
            set
            {
                nPixels = value;
                OnPropertyChanged();
            }
        }

        private short nLines;

        public short NLines
        {
            get { return nLines; }
            set
            {
                nLines = value;
                OnPropertyChanged();
            }
        }

        private byte captureFlag;

        public byte CaptureFlag
        {
            get { return captureFlag; }
            set
            {
                captureFlag = value;
                OnPropertyChanged();
            }
        }

        private byte targetBlue;

        public byte TargetBlue
        {
            get { return targetBlue; }
            set
            {
                targetBlue = value;
                OnPropertyChanged();
            }
        }

        private byte enableCapture;

        public byte EnableCapture
        {
            get { return enableCapture; }
            set
            {
                enableCapture = value;
                OnPropertyChanged();
            }
        }

        private short tor;

        public short Tor
        {
            get { return tor; }
            set
            {
                tor = value;
                OnPropertyChanged();
            }
        }

        private byte enableTarget;

        public byte EnableTarget
        {
            get { return enableTarget; }
            set
            {
                enableTarget = value;
                OnPropertyChanged();
            }
        }

        #endregion Properties
    }

    // CMD 0x7
    public class ADConfigData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 0x7;

            // data to sdram start offset
            txData.Data[6] = (byte)(SdramStartOffset);
            txData.Data[7] = (byte)(SdramStartOffset >> 8);
            // data to analysis start offset
            txData.Data[8] = (byte)(AnalysisStartOffset);
            txData.Data[9] = (byte)(AnalysisStartOffset >> 8);
            // data to sdram end offset
            txData.Data[10] = (byte)(SdramEndOffset);
            txData.Data[11] = (byte)(SdramEndOffset >> 8);
            // data to analysis end offset
            txData.Data[12] = (byte)(AnalysisEndOffset);
            txData.Data[13] = (byte)(AnalysisEndOffset >> 8);
            // enable
            txData.Data[14] = Enable;
            txData.Data[15] = 0x0;

            PropertyChanged?.Invoke(txData);
        }

        public ADConfigData()
        {
            sdramStartOffset    = 0x1AE;
            analysisStartOffset = 0x1AE;
            sdramEndOffset      = 0x9AD;
            analysisEndOffset   = 0x9AD;
            enable              = 1;

            OnPropertyChanged();
        }

        public void Set(ADConfigData newData)
        {
            sdramStartOffset    = newData.sdramStartOffset;
            analysisStartOffset = newData.analysisStartOffset;
            sdramEndOffset      = newData.sdramEndOffset;
            analysisEndOffset   = newData.analysisEndOffset;
            enable              = newData.enable;

            OnPropertyChanged();
        }

        #region Properties

        private short sdramStartOffset;

        public short SdramStartOffset
        {
            get { return sdramStartOffset; }
            set
            {
                sdramStartOffset = value;
                OnPropertyChanged();
            }
        }

        private short analysisStartOffset;

        public short AnalysisStartOffset
        {
            get { return analysisStartOffset; }
            set
            {
                analysisStartOffset = value;
                OnPropertyChanged();
            }
        }

        private short sdramEndOffset;

        public short SdramEndOffset
        {
            get { return sdramEndOffset; }
            set
            {
                sdramEndOffset = value;
                OnPropertyChanged();
            }
        }

        private short analysisEndOffset;

        public short AnalysisEndOffset
        {
            get { return analysisEndOffset; }
            set
            {
                analysisEndOffset = value;
                OnPropertyChanged();
            }
        }

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

    // CMD 0x8
    public class WhiteBalanceData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 0x8;

            // enableWB
            txData.Data[6] = EnableWB;
            txData.Data[7] = 0x0;
            // enableWBOutput
            txData.Data[8] = EnableWBOutput;
            txData.Data[9] = 0x0;

            PropertyChanged?.Invoke(txData);
        }

        public WhiteBalanceData()
        {
            enableWB       = 1;
            enableWBOutput = 1;

            OnPropertyChanged();
        }

        public void Set(WhiteBalanceData newData)
        {
            enableWB       = newData.EnableWB;
            enableWBOutput = newData.EnableWBOutput;

            OnPropertyChanged();
        }

        // Return a deep copy, but with no PropertyChanged event set
        public WhiteBalanceData GetCopy()
        {
            WhiteBalanceData copy = new WhiteBalanceData();
            copy.enableWB       = EnableWB;
            copy.enableWBOutput = EnableWBOutput;

            return copy;
        }

        #region Properties

        private byte enableWB;

        public byte EnableWB
        {
            get { return enableWB; }
            set
            {
                enableWB = value;
                OnPropertyChanged();
            }
        }

        private byte enableWBOutput;

        public byte EnableWBOutput
        {
            get { return enableWBOutput; }
            set
            {
                enableWBOutput = value;
                OnPropertyChanged();
            }
        }

        #endregion Properties
    }

    public class RgbBackgroundConfig
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 18;

            // red target
            txData.Data[6] = (byte)(MinRTarget);
            txData.Data[7] = (byte)(MinRTarget >> 8);
            // green target
            txData.Data[8] = (byte)(MinGTarget);
            txData.Data[9] = (byte)(MinGTarget >> 8);
            // blue target
            txData.Data[10] = (byte)(MinBTarget);
            txData.Data[11] = (byte)(MinBTarget >> 8);
            // red target
            txData.Data[12] = (byte)(MaxRTarget);
            txData.Data[13] = (byte)(MaxRTarget >> 8);
            // green target
            txData.Data[14] = (byte)(MaxGTarget);
            txData.Data[15] = (byte)(MaxGTarget >> 8);
            // blue target
            txData.Data[16] = (byte)(MaxBTarget);
            txData.Data[17] = (byte)(MaxBTarget >> 8);

            for (byte i = 0; i < HwLines.Length; i++)
            {
                for (byte j = 1; j <= 8; j++)
                {
                    // Hw line
                    txData.Data[1] = (byte)HwLines[i];
                    // Set board ID
                    txData.Data[2] = j;

                    PropertyChanged?.Invoke(txData);
                }
            }
        }

        public int[] HwLines { get; set; }

        private short minRTarget;

        public short MinRTarget
        {
            get { return minRTarget; }
            set
            {
                minRTarget = value;
                OnPropertyChanged();
            }
        }

        private short minGTarget;

        public short MinGTarget
        {
            get { return minGTarget; }
            set
            {
                minGTarget = value;
                OnPropertyChanged();
            }
        }

        private short minBTarget;

        public short MinBTarget
        {
            get { return minBTarget; }
            set
            {
                minBTarget = value;
                OnPropertyChanged();
            }
        }

        private short maxRTarget;

        public short MaxRTarget
        {
            get { return maxRTarget; }
            set
            {
                maxRTarget = value;
                OnPropertyChanged();
            }
        }

        private short maxGTarget;

        public short MaxGTarget
        {
            get { return maxGTarget; }
            set
            {
                maxGTarget = value;
                OnPropertyChanged();
            }
        }

        private short maxBTarget;

        public short MaxBTarget
        {
            get { return maxBTarget; }
            set
            {
                maxBTarget = value;
                OnPropertyChanged();
            }
        }
    }

    public class HslBackgroundConfig
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();

            // Set Switch
            txData.Data[4] = 19;

            byte minHTarget = (byte)(((double)MinHTarget / 360.0) * 255.0);
            txData.Data[6] = (byte)(minHTarget);
            txData.Data[7] = (byte)(minHTarget >> 8);

            byte maxHTarget = (byte)(((double)MaxHTarget / 360.0) * 255.0);
            txData.Data[8] = (byte)(maxHTarget);
            txData.Data[9] = (byte)(maxHTarget >> 8);

            byte sTarget = (byte)(((double)STarget / 100.0) * 255.0);
            txData.Data[10] = (byte)(sTarget);
            txData.Data[11] = (byte)(sTarget >> 8);

            byte lTarget = (byte)(((double)LTarget / 100.0) * 255.0);
            txData.Data[12] = (byte)(lTarget);
            txData.Data[13] = (byte)(lTarget >> 8);

            for (byte i = 0; i < HwLines.Length; i++)
            {
                for (byte j = 1; j <= 8; j++)
                {
                    // Hw line
                    txData.Data[1] = (byte)HwLines[i];
                    // Set board ID
                    txData.Data[2] = j;

                    PropertyChanged?.Invoke(txData);
                }
            }
        }

        public int[] HwLines { get; set; }

        private short minHTarget;

        public short MinHTarget
        {
            get { return minHTarget; }
            set
            {
                minHTarget = value;
                OnPropertyChanged();
            }
        }

        private short maxHTarget;

        public short MaxHTarget
        {
            get { return maxHTarget; }
            set
            {
                maxHTarget = value;
                OnPropertyChanged();
            }
        }

        private short sTarget;

        public short STarget
        {
            get { return sTarget; }
            set
            {
                sTarget = value;
                OnPropertyChanged();
            }
        }

        private short lTarget;

        public short LTarget
        {
            get { return lTarget; }
            set
            {
                lTarget = value;
                OnPropertyChanged();
            }
        }
    }

    // CMD 0x32
    public class EjectionSimData
    {
        public delegate void CCDDataChangedEventHandler(TxData txData);

        public event CCDDataChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            TxData txData = new TxData();
            
            // Set Switch
            txData.Data[4] = 0x32;
            //null
            txData.Data[6] = 0x0;
            //high_cycles
            txData.Data[8] = HighCycles;
            txData.Data[9] = 0x0;
            //low_cycles
            txData.Data[10] = LowCycles;
            txData.Data[11] = 0x0;
            //rep_cycles
            txData.Data[12] = (byte) RepCycles;
            txData.Data[13] = (byte)(RepCycles >> 8);
            //sync low
            int syncsLow = 1500 - Frequency;
            txData.Data[14] = (byte) syncsLow;       // LSB
            txData.Data[15] = (byte)(syncsLow >> 8); // MSB
            //ch test
            txData.Data[16] = EjecChannel;
            // group
            txData.Data[18] = GroupChannel;
            //fixed channel
            txData.Data[20] = 0x1;
            //enable
            txData.Data[22] = Enabled;

            PropertyChanged?.Invoke(txData);
        }

        public EjectionSimData()
        {
            highCycles = 1;
            lowCycles = 1;
            repCycles = 1;
            ejecChannel = 0;
            groupChannel = 0;
            enabled = 0;
        }

        public void Set(EjectionSimData newData)
        {
            highCycles = newData.HighCycles;
            lowCycles = newData.LowCycles;
            repCycles = newData.RepCycles;
            ejecChannel = newData.EjecChannel;
            groupChannel = newData.GroupChannel;
            enabled = newData.Enabled;

            OnPropertyChanged();
        }

        // Return a deep copy, but with no PropertyChanged event set
        public EjectionSimData GetCopy()
        {
            EjectionSimData copy = new EjectionSimData();
            copy.highCycles = HighCycles;
            copy.lowCycles = LowCycles;
            copy.repCycles = RepCycles;
            copy.ejecChannel = EjecChannel;
            copy.groupChannel = GroupChannel;
            copy.enabled = Enabled;

            return copy;
        }

        #region Properties

        private byte highCycles;

        public byte HighCycles
        {
            get { return highCycles; }
            set
            {
                highCycles = value;
                OnPropertyChanged();
            }
        }

        private byte lowCycles;

        public byte LowCycles
        {
            get { return lowCycles; }
            set
            {
                lowCycles = value;
                OnPropertyChanged();
            }
        }

        private short repCycles;

        public short RepCycles
        {
            get { return repCycles; }
            set
            {
                repCycles = value;
                OnPropertyChanged();
            }
        }

        private byte ejecChannel;

        public byte EjecChannel
        {
            get { return ejecChannel; }
            set
            {
                ejecChannel = value;
                OnPropertyChanged();
            }
        }

        private byte groupChannel;

        public byte GroupChannel
        {
            get { return groupChannel; }
            set
            {
                groupChannel = value;
                OnPropertyChanged();
            }
        }

        private byte enabled;

        public byte Enabled
        {
            get { return enabled; }
            set
            {
                enabled = value;
                OnPropertyChanged();
            }
        }

        private short frequency;

        public short Frequency
        {
            get { return frequency; }
            set
            {
                frequency = value;
                OnPropertyChanged();
            }
        }

        #endregion Properties
    }

    public class CCD
    {
        public delegate void SendCommandHandler(TxData txData);

        public event SendCommandHandler SendCommand_OnRequested = delegate { };

        public byte HWLine { get; set; }
        public byte BoardID { get; set; }
        public byte LastBoard { get; set; }

        public LedConfigData LedConfig;
        public SyncBufferData SyncBuffer;
        public HMIReturnPacketData HMIReturnPacket;
        public EjectionPacketData EjectionPacket;
        public OscilloscopeConfigData OscilloscopeConfig;
        public SDRAMConfigData SDRAMConfig;
        public ADConfigData ADConfig;
        public WhiteBalanceData WhiteBalance;
        public EjectionSimData EjectionSim;

        public CCD(byte hwLine, byte boardID, byte lastBoard)
        {
            HWLine = hwLine;
            BoardID = boardID;
            LastBoard = lastBoard;

            LedConfig = new LedConfigData();
            LedConfig.PropertyChanged += CCDData_PropertyChanged;

            SyncBuffer = new SyncBufferData(BoardID);
            SyncBuffer.PropertyChanged += CCDData_PropertyChanged;

            HMIReturnPacket = new HMIReturnPacketData(BoardID, LastBoard);
            HMIReturnPacket.PropertyChanged += CCDData_PropertyChanged;

            EjectionPacket = new EjectionPacketData(BoardID, LastBoard);
            EjectionPacket.PropertyChanged += CCDData_PropertyChanged;

            OscilloscopeConfig = new OscilloscopeConfigData();
            OscilloscopeConfig.PropertyChanged += CCDData_PropertyChanged;

            SDRAMConfig = new SDRAMConfigData();
            SDRAMConfig.PropertyChanged += CCDData_PropertyChanged;

            ADConfig = new ADConfigData();
            ADConfig.PropertyChanged += CCDData_PropertyChanged;

            WhiteBalance = new WhiteBalanceData();
            WhiteBalance.PropertyChanged += CCDData_PropertyChanged;

            EjectionSim = new EjectionSimData();
            EjectionSim.PropertyChanged += CCDData_PropertyChanged;
        }

        private void CCDData_PropertyChanged(TxData txData)
        {
            txData.Data[1] = HWLine;
            txData.Data[2] = BoardID;

            SendCommand_OnRequested(txData);
        }
    }
}
