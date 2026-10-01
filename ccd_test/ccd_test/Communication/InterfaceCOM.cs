namespace ccd_test.Communication
{
    public sealed class InterfaceCOM
    {
        /// <summary>
        /// An instance of the WIZnetCOM Communication. This instance is unique and once it is open it locks the COM Port to itself.
        /// This should never be manually used anywhere else in the system.
        /// </summary>
        public static WIZnetCOM.WIZnetCOM COMInstance { get; private set; }

        /// <summary>   Instatiante Communication properties - Static constructor. </summary>
        static InterfaceCOM()
        {
            // Initialize members, etc. here.
            COMInstance = new WIZnetCOM.WIZnetCOM();
        }
    }
}
