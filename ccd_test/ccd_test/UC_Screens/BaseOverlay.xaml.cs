using System.Windows;
using System.Windows.Controls;

namespace ccd_test.UC_Screens
{
    /// <summary>
    /// Interaction logic for BaseOverlay.xaml
    /// </summary>
    public partial class BaseOverlay : UserControl
    {
        #region Properties

        public string Message
        {
            get { return (string)GetValue(MessageProperty); }
            set { SetValue(MessageProperty, value); }
        }

        // Using a DependencyProperty as the backing store for Message.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty MessageProperty =
            DependencyProperty.Register("Message", typeof(string), typeof(BaseOverlay), new UIPropertyMetadata("Text"));

        #endregion

        #region Constructors

        public BaseOverlay()
        {
            InitializeComponent();
        }

        #endregion
    }
}