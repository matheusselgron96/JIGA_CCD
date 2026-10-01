using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace WIZnetCOM.LogSystem
{
    /// <summary>
    /// A Logging class implementing the Singleton pattern and an internal Queue to be flushed perdiodically.
    /// </summary>
    public class LogWriter
    {
        #region Properties

        /// <summary>
        /// The maximum amount of logs/messages that should be kept in queue before flushing to the actual log file.
        /// </summary>
        ///
        /// <value> The size of the queue. </value>
        public static uint QueueSize { get; set; }

        /// <summary>
        /// The maximum time in seconds that a log should be kept in queue before flushing to the actual log file.
        /// </summary>
        ///
        /// <value> The maximum log age in seconds. </value>
        public static uint MaxLogAgeInSeconds { get; set; }

        /// <summary>   The directory that the logs are kept and saved. </summary>
        ///
        /// <value> The log dir. </value>
        public static string LogDir { get; set; }

        /// <summary>   Guarantee that at least this amount of log files will be saved regardless of its date. </summary>
        ///
        /// <value> The keep minimum log files. </value>
        public static int KeepMinimumLogFiles { get; set; }

        /// <summary>   Any log older than this limit wil be deleted - Unless inside KeepMinimumLogFiles. </summary>
        ///
        /// <value> The keep log files days old. </value>
        public static int KeepLogFilesDaysOld { get; set; }

        /// <summary>   When the log has been flushed for the first time. </summary>
        ///
        /// <value> The first flushed. </value>
        public static DateTime FirstFlushed { get; private set; }

        /// <summary>   When the last log flush has occurred. </summary>
        ///
        /// <value> The last flushed. </value>
        public static DateTime LastFlushed { get; private set; }

        /// <summary>
        /// Whether the WriteToLog should actually write to a physical log file or only kept in system Debug. This is TRUE by
        /// default.
        /// </summary>
        ///
        /// <value> True if write to physical file, false if not. </value>
        public static bool WriteToPhysicalFile { get; set; }

        /// <summary>   Gets or sets the maximum time to log all message types (in seconds). </summary>
        ///
        /// <value> The determined time in seconds. </value>
        public static uint MaxTimeToLogAll { get; set; }

        #endregion

        #region Fields / Local Variables

        private static readonly LogWriter instance = new LogWriter();
        private static object syncRoot = new object();

        private static readonly Queue<Log> logQueue = new Queue<Log>();

        private static readonly string logFileName = "WIZnet Log.txt";

        private static bool hasInitialized = false;

        #endregion

        #region Constructors

        // Explicit static constructor to tell C# compiler not to mark type as beforefieldinit.
        static LogWriter()
        {
        }

        /// <summary>   Private constructor to prevent instance creation. </summary>
        private LogWriter()
        {
            // We will keep the last 60 log files (Includes all .txt files in the LogDir).
            KeepMinimumLogFiles = 90;

            // We wiil keep log files that are within the last 30 days.
            KeepLogFilesDaysOld = 30;

            // We will keep no more than 20 messages at the queue (then we flush). Default value.
            QueueSize = 20;

            // We will keep messages for no longer than 10 seconds (then we flush). Default value.
            MaxLogAgeInSeconds = 10;

            // 10 minutes. - RELEASE VERSION.
            MaxTimeToLogAll = 600;
            //MaxTimeToLogAll = 18000; // 300 minutes(5h) - ONLY FOR TESTING PURPOSES INSIDE THE COMPANY.

            LogDir = "D:\\Logs\\";

            LastFlushed = DateTime.Now;

            FirstFlushed = DateTime.Now;

            WriteToPhysicalFile = true;
        }

        #endregion

        /// <summary>   An LogWriter instance that exposes a single instance. </summary>
        ///
        /// <value> The instance. </value>
        public static LogWriter Instance
        {
            get
            {
                return instance;
            }
        }

        #region Public Methods

        /// <summary>   The single instance method that writes to the log file. </summary>
        ///
        /// <param name="message">  The message to write to the log. </param>
        /// <param name="priority"> (Optional) The priority. </param>
        public void WriteToLog(string message, EMessagePriority priority = EMessagePriority.Trace)
        {
            // Lock the queue while writing to prevent contention for the log file.
            lock (logQueue)
            {
                // Send it to the Debug Output as well.
                System.Diagnostics.Debug.WriteLine(string.Format("{0} (MS: {1} - Priority: {2})",
                                                                 message,
                                                                 DateTime.Now.ToString("mm.ss.ffff"),
                                                                 priority.ToString()));

                if (WriteToPhysicalFile && (priority > EMessagePriority.Trace || DoWriteTraceMessages()))
                {
                    if (!hasInitialized || LastFlushed.Day != DateTime.Now.Day)
                    {
                        // Delete old logs if they exist.
                        DeleteOldLogs();
                    }

                    if (!hasInitialized)
                    {
                        // Flag as initialized.
                        hasInitialized = true;

                        // First time logging, mark the initialization point on the log.
                        Log initialLog = new Log(
                            string.Format("-------------------- WIZnet Communication Initialized ({0}) --------------------",
                                          System.Reflection.Assembly.GetExecutingAssembly().GetName().Version.ToString()),
                                EMessagePriority.Info);

                        // Enqueue as the first log to be written.
                        logQueue.Enqueue(initialLog);
                    }

                    // Create and Push to the Queue a new Log entry containing the passed message.
                    logQueue.Enqueue(new Log(message, priority));

                    // If we have reached the Queue Size then flush the Queue.
                    if (logQueue.Count >= QueueSize || DoPeriodicFlush() || priority == EMessagePriority.Error)
                    {
                        FlushLog();

                        LastFlushed = DateTime.Now;
                    }
                }
            }
        }

        #endregion

        #region Private / Local Methods

        private bool DoPeriodicFlush()
        {
            TimeSpan logAge = DateTime.Now - LastFlushed;

            return (logAge.TotalSeconds >= MaxLogAgeInSeconds);
        }

        /// <summary>   Flushes the Queue to the physical log file. </summary>
        private void FlushLog()
        {
            while (logQueue.Count > 0)
            {
                Log entry = logQueue.Dequeue();
                string logPath = LogDir + entry.LogDate + "_" + logFileName;

                if (CreateDirIfInexistent())
                {
                    // This could be optimised to prevent opening and closing the file for each write.
                    using (FileStream fs = File.Open(logPath, FileMode.Append, FileAccess.Write, FileShare.Read))
                    {
                        using (StreamWriter log = new StreamWriter(fs))
                        {
                            log.WriteLine($"{entry.LogTime}|{entry.Message}");
                        }
                    }
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("LogDir does not exist. " + logPath);
                }
            }
        }

        /// <summary>   Check whether the Log Directory exists, if not create the dir. IF it does exists, do nothing. </summary>
        ///
        /// <returns>   True if it succeeds, false if it fails. </returns>
        private bool CreateDirIfInexistent()
        {
            // If Directory does not exist.
            if (!Directory.Exists(LogDir))
            {
                try
                {
                    // Check if at least the Drive (PathRoot) exists.
                    if (Directory.Exists(Path.GetPathRoot(LogDir)))
                    {
                        DirectoryInfo temp = Directory.CreateDirectory(LogDir);

                        if (temp == null)
                            return false;
                    }
                    // If not, return false immediately.
                    else
                    {
                        return false;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error trying to create LogDir");
                    return false;
                }
            }

            return true;
        }

        /// <summary>
        /// Delete any and all logs older than a determined amount of days. If the Log Directory does not exist, simply
        /// return.
        /// </summary>
        private void DeleteOldLogs()
        {
            // Check if the dir exists, if not there is nothing to delete (RETURN).
            if (!Directory.Exists(LogDir))
                return;

            List<string> lsFiles = Directory.GetFiles(LogDir, "*.txt", SearchOption.TopDirectoryOnly).ToList();
            // Logs are kept yyyy-mm-dd. So a sort will make sure they are arranged from older to newer.
            lsFiles.Sort();

            int deletedLogs = 0;

            foreach (string fileName in lsFiles)
            {
                // Make sure the amount of lastlogs to keep is respected, even if logs are older than "keepDaysOld", the
                // "keepLastLongs" amount is respected.
                //
                // A log may be 1000 days old, but if the amount of logs is lower than the keepLastLogs amount then it will be
                // kept.
                if ((deletedLogs + KeepMinimumLogFiles) >= lsFiles.Count)
                    break;

                try
                {
                    string fileDate = Path.GetFileName(fileName).Split(new char[] { '_' }, StringSplitOptions.RemoveEmptyEntries)[0];

                    string fileYear = fileDate.Split(new char[] { '-' }, StringSplitOptions.RemoveEmptyEntries)[0];
                    string fileMonth = fileDate.Split(new char[] { '-' }, StringSplitOptions.RemoveEmptyEntries)[1];
                    string fileDay = fileDate.Split(new char[] { '-' }, StringSplitOptions.RemoveEmptyEntries)[2];
                    DateTime logFileDate = new DateTime(int.Parse(fileYear), int.Parse(fileMonth), int.Parse(fileDay));

                    TimeSpan logDayAge = LastFlushed - logFileDate;

                    // If log exists and is older than the specified amount, delete.
                    if (File.Exists(fileName) && (logDayAge.TotalDays > KeepLogFilesDaysOld))
                    {
                        File.Delete(fileName);
                        deletedLogs++;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error trying to delete older logs");
                }
            }
        }

        private bool DoWriteTraceMessages()
        {
            TimeSpan logAge = DateTime.Now - FirstFlushed;

            return (logAge.TotalSeconds <= MaxTimeToLogAll);
        }

        #endregion
    }
}