#define NEW_COMMS

using ImageHelper;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;
using WIZnetCOM.LogSystem;

namespace WIZnetCOM
{

    public class WIZnetData
    {
        WIZnetCOM wiznetCOM;

        List<byte> rxDataBuffer = new List<byte>();

        public event Action<byte[]> OnEjectionRateChanged;

        public List<int> OscilloscopeRed   { get; private set; }
        public List<int> OscilloscopeGreen { get; private set; }
        public List<int> OscilloscopeBlue  { get; private set; }

        public event Action OnOscilloscopeChanged;

        public List<int> ImageLine { get; private set; }
        public int ImageCamera { get; private set; }
        public int ImageWidth { get; private set; }
        public int ImageHeight { get; private set; }
        public int[] ImageRaw { get; private set; }
        public int ImageLineCounter { get; set; }
        public string ImageName { get; set; }
        public string ImagePath { get; set; }

        public float[] WBRCoef { get; set; } = new float[4096];
        public float[] WBGCoef { get; set; } = new float[4096];
        public float[] WBBCoef { get; set; } = new float[4096];

        public event Action<int> OnImageProgressed;
        public event Action OnImageChanged;

        public event Action<byte[]> OnDumpChanged;

        public WIZnetData(WIZnetCOM _wiznetCOM)
        {
            wiznetCOM = _wiznetCOM;

            OscilloscopeRed = new List<int>(new int[4096]);
            OscilloscopeGreen = new List<int>(new int[4096]);
            OscilloscopeBlue = new List<int>(new int[4096]);

            ImageWidth  = 4096;
            ImageHeight = 1600;
            ImageRaw = new int[ImageWidth * ImageHeight];
            ImageLine = new List<int>(new int[4096]);
        }

        public void FillOscilloscope(int packageId, byte[] oscilloscopeSection)
        {
#if NEW_COMMS
            int oscIdx = packageId * 128;

            for (int i = 0; i < 384;)
            {
                OscilloscopeRed[oscIdx] = oscilloscopeSection[i++];
                OscilloscopeGreen[oscIdx] = oscilloscopeSection[i++];
                OscilloscopeBlue[oscIdx] = oscilloscopeSection[i++];

                oscIdx++;
            }

            if (packageId == 31)
#else
            int oscIdx = packageId * 186;

            if (packageId == 22)
            {
                for (int i = 0; i < 12;)
                {
                    OscilloscopeRed[oscIdx] = oscilloscopeSection[i++];
                    OscilloscopeGreen[oscIdx] = oscilloscopeSection[i++];
                    OscilloscopeBlue[oscIdx] = oscilloscopeSection[i++];

                    oscIdx++;
                }
            }
            else
            {
                for (int i = 0; i < 558;)
                {
                    OscilloscopeRed[oscIdx] = oscilloscopeSection[i++];
                    OscilloscopeGreen[oscIdx] = oscilloscopeSection[i++];
                    OscilloscopeBlue[oscIdx] = oscilloscopeSection[i++];

                    oscIdx++;
                }
            }

            if (packageId == 22)
#endif
            {
#if DEBUG || DEBUG_NEWCOMMS
                LogWriter.Instance.WriteToLog($"OscilloscopeRed Size: {OscilloscopeRed.Count}");
                LogWriter.Instance.WriteToLog($"OscilloscopeGreen Size: {OscilloscopeGreen.Count}");
                LogWriter.Instance.WriteToLog($"OscilloscopeBlue Size: {OscilloscopeBlue.Count}");
#endif

                OnOscilloscopeChanged?.Invoke();
            }
        }

        private void FillLine(int packageId, int lineId, byte[] imageSection)
        {
            // Process new line.
            int t1 = ((ImageHeight - (lineId) * 2) - 1) * ImageWidth;
            int t2 = ((ImageHeight - (lineId) * 2) - 2) * ImageWidth;

#if DEBUG || DEBUG_NEWCOMMS
            LogWriter.Instance.WriteToLog($"FillLine lineID: {lineId}");
#endif

#if NEW_COMMS
            int lineIdx = packageId * 128;

            for (int i = 0; i < 384;)
            {
                int color = imageSection[i] << 16 | imageSection[i + 1] << 8 | imageSection[i + 2];

                if (ImageCamera == 3)
                {
                    color = imageSection[i] << 16 | imageSection[i] << 8 | imageSection[i];
                }

                ImageRaw[t1 + lineIdx] = color;
                ImageRaw[t2 + lineIdx] = color;
                lineIdx++;
                i += 3;
            }

            if (packageId == 31)
#else
            int lineIdx = packageId * 186;

            if (packageId == 22)
            {
                for (int i = 0; i < 12; i += 3)
                {
                    int color = imageSection[i] << 16 | imageSection[i + 1] << 8 | imageSection[i + 2];

                    if (ImageCamera == 3)
                    {
                        color = imageSection[i] << 16 | imageSection[i] << 8 | imageSection[i];
                    }

                    ImageRaw[t1 + lineIdx] = color;
                    ImageRaw[t2 + lineIdx] = color;
                    lineIdx++;
                }
            }
            else
            {
                for (int i = 0; i < 558; i += 3)
                {
                    int color = imageSection[i] << 16 | imageSection[i + 1] << 8 | imageSection[i + 2];

                    if (ImageCamera == 3)
                    {
                        color = imageSection[i] << 16 | imageSection[i] << 8 | imageSection[i];
                    }

                    ImageRaw[t1 + lineIdx] = color;
                    ImageRaw[t2 + lineIdx] = color;
                    lineIdx++;
                }
            }

            if (packageId == 22)
#endif
            {
#if DEBUG || DEBUG_NEWCOMMS
                LogWriter.Instance.WriteToLog($"Image Size: {ImageLine.Count}");
#endif

                // Reverse front camera
                if (ImageCamera == 1)
                {
                    ImageLine.Reverse();
                }

                OnImageProgressed(lineId);

                FillImage(lineId);
            }
        }

        private void FillImage(int lineId)
        {
            // Image completed.
            if (ImageLineCounter == (ImageHeight / 2) - 1)
            {
                ApplyWhiteBalance();

                ImagePath = "";
                
                string cameraStr = "FR";
                if (ImageCamera == 2) cameraStr = "TR";
                if (ImageCamera == 3) cameraStr = "IR";

                ImageName = cameraStr + " - " + DateTime.Now.ToString("dd-MM-yyyy - hh.mm.ss") + ".bmp";
                SaveImage();
                OnImageChanged?.Invoke();
            }

            ImageLineCounter += 1;
        }

        private void ApplyWhiteBalance()
        {
            for (int i = 0; i < ImageHeight; i++)
            {
                for (int j = 0; j < ImageWidth; j++)
                {
                    int idx = (i * ImageWidth) + j;

                    float r = (byte)(ImageRaw[idx] >> 16);
                    float g = (byte)(ImageRaw[idx] >> 8);
                    float b = (byte)(ImageRaw[idx]);

                    r *= WBRCoef[j];
                    g *= WBGCoef[j];
                    b *= WBBCoef[j];

                    r = Math.Clamp(r, 0, 255);
                    g = Math.Clamp(g, 0, 255);
                    b = Math.Clamp(b, 0, 255);

                    ImageRaw[idx] = (byte)r << 16 | (byte)g << 8 | (byte)b;
                }
            }
        }

        public void RefreshImage()
        {
            OnImageChanged?.Invoke();
        }

        public void SetHeight(int newHeight)
        {
            ImageHeight = newHeight;
            ImageRaw = new int[ImageWidth * ImageHeight];
        }

        public void SetWidth(int newWidth)
        {
            ImageWidth = newWidth;
            ImageRaw = new int[ImageWidth * ImageHeight];
        }

        public void SetCamera(int hwLine)
        {
            ImageCamera = hwLine;
        }

        public void SetImage(int[] newImageRaw, int newImageWidth, int newImageHeight, bool saveImage = true)
        {
            ImageHeight = newImageHeight;
            ImageWidth  = newImageWidth;

            ImageRaw = new int[newImageRaw.Length];
            newImageRaw.CopyTo(ImageRaw, 0);

            if (saveImage == true)
            {
                SaveImage();

                // If saving a loaded image, change the path to the save dir.
                ImagePath = Path.Combine(@"D:\\Imagens", ImageName);
            }

            OnImageChanged?.Invoke();
        }

        public void ProcessRxData(List<List<byte>> packets)
        {
            Stopwatch sw = new Stopwatch();
            sw.Start();

#if DEBUG || DEBUG_NEWCOMMS
            LogWriter.Instance.WriteToLog($"Number of Packets: {packets.Count}");
            LogWriter.Instance.WriteToLog($"");
#endif

            rxDataBuffer = new List<byte>();

#if DEBUG || DEBUG_NEWCOMMS
            LogWriter.Instance.WriteToLog($"Packet Interpretation Elapsed Time: {sw.ElapsedMilliseconds}");
#endif
            sw.Restart();

            ProcessPackets(packets);

#if DEBUG || DEBUG_NEWCOMMS
            LogWriter.Instance.WriteToLog($"Packet Processing Elapsed Time: {sw.ElapsedMilliseconds}");
#endif
        }

        private void ProcessPackets(List<List<byte>> packets)
        {
            string receivedPackets = "";

            for (int i = 0; i < packets.Count; i++)
            {
                List<byte> packet = packets[i];

                if (packet.Count != 580)
                {
                    LogWriter.Instance.WriteToLog($"ERROR - Wrong number of bytes in packet");
                    break;
                }

                // Packet bytes
                // 0  - Header
                // 1  - Header
                // 2  - Header
                // 3  - Header
                // 4  - TOR
                // 5  - TOR
                // 6  - Package ID
                // 7  - Package ID
                // 8  - Package ID
                // 9  - Package ID
                // 10 - Start Packet
                // 11 - Start Packet
                // 12 - End Packet
                // 13 - End Packet
                // 14 - Line ID | IsAlive
                // 15 - Line ID | IsAlive
                // 16 - Board Id
                // 17 - Board Id
                // 18 - HW Line
                // 19 - HW Line
                // 20 - Data

                byte typeOfReturn = packet[4];
#if NEW_COMMS
                byte packageId = packet[7];
#else
                byte packageId = packet[6];
#endif
                byte[] data = new ArraySegment<byte>(packet.ToArray(), 20, 558).ToArray();

                receivedPackets += packageId + " ";

                // Switch on Type Of Return
                switch (typeOfReturn)
                {
                    // Ejection Rate
                    case 3:
                        OnEjectionRateChanged?.Invoke(packet.ToArray());
                        break;

                    // Oscilloscope
                    case 4:
                        FillOscilloscope(packageId - 1, data);
                        break;

                    // Dump
                    case 5:
                        ProcessReturningData(packet);
                        break;

                    // Dump
                    case 6:
                        short lineId = (short)(packet[14] << 8 | packet[15]);
                        FillLine(packageId - 1, lineId, data);
                        break;

                    default:
                        LogWriter.Instance.WriteToLog($"Invalid Return Type");
                        break;
                }
            }

#if DEBUG || DEBUG_NEWCOMMS
            LogWriter.Instance.WriteToLog($"Packets Received - {receivedPackets}");
#endif
        }

        private void ProcessReturningData(List<byte> packet)
        {
            int boardId = packet[16];
            int hwLine  = packet[19];
            int cmd     = packet[21];

            OnDumpChanged?.Invoke(packet.ToArray());
        }

        private void SaveImage()
        {
            if (!Directory.Exists(Path.Combine("D:", "Imagens")))
            {
                Directory.CreateDirectory(Path.Combine("D:", "Imagens"));
            }

            using (MemoryStream memory = new MemoryStream())
            {
                string path = Path.Combine("D:/Imagens", ImageName);
                Bitmap imgToSave = ImgHelper.VectorToBitmap(ImageRaw, ImageWidth, ImageHeight, false);

                using (FileStream fs = new FileStream(path, FileMode.Create, FileAccess.ReadWrite))
                {
                    Bitmap newImage = new Bitmap(imgToSave);
                    newImage.Save(memory, ImageFormat.Bmp);
                    byte[] bytes = memory.ToArray();
                    fs.Write(bytes, 0, bytes.Length);
                }
            }
        }

        #region Testing

        public void SetFakeEjectionRate(byte[] packet)
        {
            OnEjectionRateChanged?.Invoke(packet.ToArray());
        }

        public void GenerateFakeOscilloscope(int rGain = 0, int gGain = 0, int bGain = 0)
        {
#if NEW_COMMS
            int numberOfPackets = 32;
            int packetSize = 384;
#else
            int numberOfPackets = 23;
            int packetSize = 558;
#endif

            Random rnd = new Random();

            int maxR = rnd.Next(-1, 1);
            int maxG = rnd.Next(-3, 3);
            int maxB = rnd.Next(-5, 5);

            // Generate all packets.
            for (int i = 0; i < numberOfPackets; i++)
            {
                byte[] packet = new byte[packetSize];

                for (int j = 0; j < packetSize;)
                {
                    packet[j++] = (byte)rnd.Next(1 + rGain, 7 + maxR + rGain);
                    packet[j++] = (byte)rnd.Next(23 + gGain, 30 + maxG + gGain);
                    packet[j++] = (byte)rnd.Next(45 + bGain, 68 + maxB + bGain);
                }

                FillOscilloscope(i, packet);
            }
        }

        public void GenerateFakeImage()
        {
#if NEW_COMMS
            int numberOfPackets = 32;
            int packetSize = 384;
#else
            int numberOfPackets = 23;
            int packetSize = 558;
#endif

            Random rnd = new Random();

            int maxR = rnd.Next(-1, 1);
            int maxG = rnd.Next(-3, 3);
            int maxB = rnd.Next(-5, 5);

            for (int i = 0; i < ImageHeight / 2; i++)
            {
                // Generate all packets.
                for (int j = 0; j < numberOfPackets; j++)
                {
                    byte[] packet = new byte[packetSize];

                    for (int k = 0; k < packetSize;)
                    {
                        packet[k++] = (byte)rnd.Next(1, 7 + maxR);
                        packet[k++] = (byte)rnd.Next(23, 30 + maxG);
                        packet[k++] = (byte)rnd.Next(120, 140 + maxB);
                    }

                    FillLine(j, i, packet);
                }
            }
        }

        #endregion Testing
    }
}
