using ccd_test.App_Code;
using ccd_test.Windows;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace ccd_test.UC_Screens
{
    /// <summary>
    /// This is an Base UserControl, every screen/page/UC from the IHM should inherit from this, as it provides basic and
    /// specific functionality and properties to the IHM.
    /// </summary>
    public class BaseUCScreen : UserControl
    {
        #region Events

        #endregion

        #region Properties

        public static readonly DependencyProperty TitleProperty =
            DependencyProperty.Register("Title", typeof(string), typeof(BaseUCScreen), new UIPropertyMetadata("Título da Tela"));

        /// <summary>   Gets or sets the title. </summary>
        ///
        /// <value> The title. </value>
        [Bindable(true)]
        public string Title
        {
            get { return (string)GetValue(TitleProperty); }
            set { SetValue(TitleProperty, value); }
        }

        /// <summary>   Gets or sets the screen overlay. </summary>
        ///
        /// <value> The screen overlay. </value>
        public BaseOverlay ScreenOverlay { get; set; }

        public Grid ScreenContent { get; set; }

        /// <summary>   Gets or sets a value indicating whether this object has initialized/loaded before. </summary>
        ///
        /// <value> true if this object has initialized, false if not. </value>
        public bool HasInitialized { get; private set; }

        /// <summary>   Gets or sets a value indicating whether this object is loaded, being displayed at the moment. </summary>
        ///
        /// <value> true if this object is loaded, false if not. </value>
        public bool HasLoaded { get; private set; }

        /// <summary>   Gets a value indicating whether the screen is disabled. </summary>
        ///
        /// <value> true if the screen is disabled, false if not. </value>
        public bool IsScreenDisabled { get { return dcDisables.Count > 0; } }

        /// <summary>   Gets a value indicating whether the screen is enabled. </summary>
        ///
        /// <value> true if the screen is enabled, false if not. </value>
        public bool IsScreenEnabled { get { return dcDisables.Count <= 0; } }

        #endregion

        #region Fields

        private SortedDictionary<EDisableCondition, string> dcDisables = new SortedDictionary<EDisableCondition, string>();

        #endregion

        #region Constructors

        public BaseUCScreen()
        {
            // Default Values for properties.
            //this.MaxHeight = 600;
            //this.MaxWidth = 800;

            // Initialize objects.

            // Register Default Events.
            this.Loaded += BaseUCScreen_Loaded;
            this.Unloaded += BaseUCScreen_Unloaded;
        }

        #endregion

        #region Public Methods

        /// <summary>   Enables the screen based on a condition that is no longer active. </summary>
        ///
        /// <param name="id">   The condition identifier. </param>
        public void EnableScreen(EDisableCondition id)
        {
        }

        /// <summary>   Disables the screen based on a condition. </summary>
        ///
        /// <remarks>   The screen cannot be disabled by the same condition. </remarks>
        ///
        /// <param name="id">   The condition identifier. </param>
        /// <param name="msg">  (Optional) the message. </param>
        public void DisableScreen(EDisableCondition id, string msg = "")
        {
        }

        #endregion

        #region Private / Local Methods

        /// <summary>   Returns the Condition message accordingly to the identifier parameter. </summary>
        ///
        /// <param name="id">   The identifier. </param>
        ///
        /// <returns>   A string cotaining the message. </returns>
        private string ConditionMessage(EDisableCondition id)
        {
            return "";
        }

        private void ShowOverlayMessage()
        {
        }

        private void HideOverlayMessage()
        {
            // Check if there is nothing supposed to be shown right now.
            if (dcDisables.Count == 0)
            {
                // Check if there is a overlay defined.
                if (ScreenOverlay != null)
                {
                    ScreenOverlay.Visibility = Visibility.Hidden;
                }

                // Check if there is a content defined and isn't enabled already.
                if (ScreenContent != null && !ScreenContent.IsEnabled)
                {
                    ScreenContent.Opacity = 1;
                    ScreenContent.IsEnabled = true;
                }
            }
        }

        #endregion

        #region User Controls Events

        private void BaseUCScreen_Loaded(object sender, RoutedEventArgs e)
        {
            // Make sure overlay message is being displayed (if any, checked inside).
            ShowOverlayMessage();

            this.HasLoaded = true;
            this.HasInitialized = true;
        }

        private void BaseUCScreen_Unloaded(object sender, RoutedEventArgs e)
        {
            this.HasLoaded = false;
        }

        #endregion
    }
}