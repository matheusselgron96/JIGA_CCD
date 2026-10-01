namespace ccd_test.App_Code
{
    /// <summary>   Values that represent EDisableCondition. </summary>
    public enum EDisableCondition
    {
        /// <summary>   An enum constant representing the alarm air option. </summary>
        Alarm_Air,

        /// <summary>   An enum constant representing the alarm itv failure option. </summary>
        Alarm_ITVFailure,

        /// <summary>   An enum constant representing the alarm cleaning automation sensor option. </summary>
        Alarm_WiperAutomationSensor,

        /// <summary>   An enum constant representing the ejectors test running option. </summary>
        EjectorsTestRunning,

        Alarm_DrvledNotConnected,

        Alarm_CeNotConnected,

        Alarm_CcdFrontNotConnected,

        Alarm_CcdRearNotConnected,

        Alarm_CcdIrNotConnected,
    }
}