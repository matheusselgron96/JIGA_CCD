using System.Collections.Generic;

namespace WIZnetCOM
{
    public class TxPacket
    {
        public List<byte> Data { get; set; }
        public bool NotifyOnSend { get; set; }
        public string NotifyIdentifier { get; set; }

        public TxPacket(TxData txData)
        {
            Data = new List<byte>();

            Add(txData);
        }

        internal void Add(TxData txData)
        {
            Data.Add(0x55);
            Data.Add(0xAA);
            Data.AddRange(txData.Data);

            NotifyOnSend = txData.NotifyOnSend;
            NotifyIdentifier = txData.NotifyIdentifier;
        }
    }
}
