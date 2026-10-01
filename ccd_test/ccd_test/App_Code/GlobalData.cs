using System;
using System.Collections.Generic;
using System.Linq;

namespace ccd_test
{
    /// <summary>   This thread is NOT thread safe. It should only be used by the UI dispatcher (Main Dispatcher). </summary>
    public static class GlobalData
    {
        #region Events Declaration and Handling

        public delegate void AccessLevelChangedHandler();

        public static event AccessLevelChangedHandler OnAccessLevel_Changed = delegate { };

        public delegate void CurrentLanguageChangedHandler();

        public static event CurrentLanguageChangedHandler OnCurrentLanguage_Changed = delegate { };

        public delegate void DataChangedHandler();

        public static event DataChangedHandler OnCurrentMemory_Changed = delegate { };

        public static event DataChangedHandler OnCurrentSGNSorterConfigComputer_Changed = delegate { };

        public static event DataChangedHandler OnCurrentSGNSorterConfigChutes_Changed = delegate { };

        public static event DataChangedHandler OnCurrentConfig_Changed = delegate { };

        public static event DataChangedHandler OnCurrentChassis_Changed = delegate { };

        public static event DataChangedHandler OnCurrentSettings_Changed = delegate { };

        public static event DataChangedHandler OnCurrentProducts_Changed = delegate { };

        public static event AirSensorChangedHandler OnSensibilidadeAutomatica_Changed = delegate { };

        public delegate void EjectionSwitchChangedHandler();

        public static event EjectionSwitchChangedHandler OnEjectionSwitch_Changed = delegate { };

        public delegate void AirSensorChangedHandler(bool isTurnedOn);

        public static event AirSensorChangedHandler OnAirSensor_Changed = delegate { };

        public delegate void ProductionStateChangedHandler(bool isProductionOn);

        /// <summary>
        /// Event queue for all listeners interested in OnUIProductionState_Changed. This is fired when the Production UI
        /// notifies a production changed state. This may not reflect the actual PCG vibrator state.
        /// </summary>
        public static event ProductionStateChangedHandler OnUIProductionState_Changed = delegate { };

        public static Action<bool> OnRunningWAState_Changed = delegate { };

        #endregion

        #region Properties

        /// <summary>   Gets or sets the main window that owns this item. </summary>
        ///
        /// <value> The main window owner. </value>
        public static System.Windows.Window MainWindowOwner { get; set; }

        /// <summary>   The machine's Chassis number. </summary>
        ///
        /// <value> The chassis. </value>
        public static string CurrentChassis { get; set; }


        /// <summary>   The machine's TeamViewer Access number. </summary>
        ///
        /// <value> The chassis. </value>
        public static string TeamViewerAccessNumber { get; set; }

        /// <summary>
        /// Used to save the current chute being used at a graphic. So all graphics can display the same chute automatically.
        /// </summary>
        ///
        /// <value> The current graphic chute. </value>
        public static int CurrentGraphicChute { get; set; }

        private static HashSet<String> EjectionSwitchLocks = new HashSet<string>();

        public static bool IsWAOn { get; set; }

        private static bool isAirSensorOn;

        private static bool isSensibilidadeAutomaticaOn;

        public static bool IsAirSensorOn
        {
            get { return isAirSensorOn; }
            set { isAirSensorOn = value; OnAirSensor_Changed(value); }
        }

        public static bool IsSensibilidadeAutomaticaOn
        {
            get { return isSensibilidadeAutomaticaOn; }
            set { isSensibilidadeAutomaticaOn = value; OnSensibilidadeAutomatica_Changed(value); }
        }

        private static bool isProductionOn;

        /// <summary>   Gets or sets a value indicating whether any production is supposed to be On (UI setted). </summary>
        ///
        /// <remarks>   This will fire an event automatically <see cref="OnUIProductionState_Changed"/>. </remarks>
        ///
        /// <value> True if any production is on, false if not. </value>
        public static bool IsUIProductionOn
        {
            get { return isProductionOn; }
            set
            {
                if (isProductionOn != value)
                {
                    isProductionOn = value;
                    OnUIProductionState_Changed(value);
                }
            }
        }

        private static bool isRequestingImage;

        public static bool IsRequestingImage
        {
            get { return isRequestingImage; }
            set { isRequestingImage = value; }
        }

        private static int ejectionRateDebouncer;

        public static int EjectionRateDebouncer
        {
            get { return ejectionRateDebouncer; }
            set { ejectionRateDebouncer = value; }
        }

        /// <summary>   This property should only be updated through the UpdateGroups method. </summary>
        ///
        /// <value> The groups. </value>
        public static Dictionary<int, List<int>> Groups { get; private set; }

        /// <summary>   This property should only be updated through the UpdateGroups method. </summary>
        ///
        /// <value> The sensors. </value>
        public static Dictionary<int, List<int>> Sensors { get; private set; }

        /// <summary>   Gets or sets a value indicating whether the software (HMI) is shutdown allowed. </summary>
        ///
        /// <value> True if shutdown allowed, false if not. </value>
        public static bool IsShutdownAllowed { get; set; }

        private static bool isRunningWA;

        public static bool IsRunningWA
        {
            get => isRunningWA;
            set
            {
                isRunningWA = value;
                OnRunningWAState_Changed(isRunningWA);
            }
        }

        #endregion

        /// <summary>   Static constructor. </summary>
        static GlobalData()
        {
            // Default value for chassis.
            CurrentChassis = "0";
            TeamViewerAccessNumber = "0";

            IsAirSensorOn = true;
            IsWAOn = false;
            IsRunningWA = false;
            ejectionRateDebouncer = 250000;
        }
    }
}