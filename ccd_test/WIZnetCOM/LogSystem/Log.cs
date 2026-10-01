using System;

namespace WIZnetCOM.LogSystem
{
    /// <summary>   A Log class to store the message and the Date and Time the log entry was created. </summary>
    public class Log
    {
        #region Properties

        /// <summary>   Gets or sets the message. </summary>
        ///
        /// <value> The message. </value>
        public string Message { get; set; }

        /// <summary>   Gets or sets the priority. </summary>
        ///
        /// <value> The priority. </value>
        public EMessagePriority Priority { get; set; }

        /// <summary>   Gets or sets the log time. </summary>
        ///
        /// <value> The log time. </value>
        public string LogTime { get; set; }

        /// <summary>   Gets or sets the log date. </summary>
        ///
        /// <value> The log date. </value>
        public string LogDate { get; set; }

        #endregion

        /// <summary>   Constructor. </summary>
        ///
        /// <param name="message">          The message. </param>
        /// <param name="messagePriority">  The message priority. </param>
        public Log(string message, EMessagePriority messagePriority)
        {
            Message = message;
            Priority = messagePriority;
            LogDate = DateTime.Now.ToString("yyyy-MM-dd");
            LogTime = DateTime.Now.ToString("HH:mm:ss.fff");
        }

        /// <summary>   Returns a string that represents the current object. </summary>
        ///
        /// <returns>   A string that represents the current object. </returns>
        public override string ToString()
        {
            return string.Format("{0}|{1}", LogTime, Message);
        }
    }
}