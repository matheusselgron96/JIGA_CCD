using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WIZnetCOM
{
    public enum TxDataFlags
    {
        IsRequest = 0,
        IsBroadcast,
    }

    public class TxData
    {
        public byte[] Data { get; set; }
        public bool Prioritize { get; set; }
        public bool NotifyOnSend { get; set; }
        public string NotifyIdentifier { get; set; }

        public bool isRequest;

        public bool IsRequest
        {
            get { return isRequest; }
            set
            {
                isRequest = value;
                Data[0] |= (byte)(1 << Convert.ToByte(TxDataFlags.IsRequest));
            }
        }

        public bool ccdBroadcast;

        public bool CcdBroadcast
        {
            get {  return ccdBroadcast; }
            set
            {
                ccdBroadcast = value;
                Data[0] |= (byte)(1 << Convert.ToByte(TxDataFlags.IsBroadcast));
            }
        }

        public TxData()
        {
            Data = new byte[34];
        }
    }
}
