using ccd_test.App_Code;
using System;
using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;

namespace ccd_test.Windows
{
    /// <summary>   Interaction logic for NumericKeyboard.xaml. </summary>
    public partial class NumericKeyboard : Window
    {
        #region Properties

        #region Text Properties

        public static readonly DependencyProperty TextClearProperty =
            DependencyProperty.Register("TextClear", typeof(string), typeof(NumericKeyboard), new UIPropertyMetadata("Clear"));

        [Bindable(true)]
        public string TextClear
        {
            get { return (string)GetValue(TextClearProperty); }
            set { SetValue(TextClearProperty, value); }
        }

        public static readonly DependencyProperty TextConfirmProperty =
            DependencyProperty.Register("TextConfirm", typeof(string), typeof(NumericKeyboard), new UIPropertyMetadata("Confirm"));

        [Bindable(true)]
        public string TextConfirm
        {
            get { return (string)GetValue(TextConfirmProperty); }
            set { SetValue(TextConfirmProperty, value); }
        }

        public static readonly DependencyProperty TextCancelProperty =
            DependencyProperty.Register("TextCancel", typeof(string), typeof(NumericKeyboard), new UIPropertyMetadata("Cancel"));

        [Bindable(true)]
        public string TextCancel
        {
            get { return (string)GetValue(TextCancelProperty); }
            set { SetValue(TextCancelProperty, value); }
        }

        public static readonly DependencyProperty TextDisplayPasswordProperty =
            DependencyProperty.Register("TextDisplayPassword", typeof(string), typeof(NumericKeyboard), new UIPropertyMetadata("Display Password?"));

        [Bindable(true)]
        public string TextDisplayPassword
        {
            get { return (string)GetValue(TextDisplayPasswordProperty); }
            set { SetValue(TextDisplayPasswordProperty, value); }
        }

        #endregion

        public static readonly DependencyProperty MaxLengthProperty =
            DependencyProperty.Register("MaxLength", typeof(int), typeof(NumericKeyboard), new UIPropertyMetadata(6));

        /// <summary>   Gets or sets the maximum length allowed. This value should be between 1 and 12. Default is 6. </summary>
        ///
        /// <exception cref="ArgumentOutOfRangeException">  Thrown when <see cref="MaxLength"/> is outside the required range
        ///                                                 of 1 and 12. </exception>
        ///
        /// <value> The length of the maximum. </value>
        [Bindable(true)]
        public int MaxLength
        {
            get { return (int)GetValue(MaxLengthProperty); }
            set
            {
                if (MaxLength >= 1 && MaxLength <= 12)
                {
                    SetValue(MaxLengthProperty, value);
                }
                else
                {
                    throw new ArgumentOutOfRangeException("MaxLength can only be between 1 and 12.");
                }
            }
        }

        /// <summary>   Gets or sets the value that has been typed by the user. </summary>
        ///
        /// <value> The value. </value>
        public string Value { get => _value; protected set { _value = value; ValueChanged(); } }

        private string _value;

        /// <summary>
        /// Gets or sets the minimum value allowed. If null the <see cref="Value"/> won't check for any minimum restriction.
        /// </summary>
        ///
        /// <value> The minimum value. </value>
        public int? MinimumValue { get; set; }

        /// <summary>
        /// Gets or sets the maximum value allowed. If null the <see cref="Value"/> won't check for any maximum restriction.
        /// </summary>
        ///
        /// <remarks>   <see cref="MaxLength"/> will firstly be respected before even checking for a MaximumValue. </remarks>
        ///
        /// <value> The maximum value. </value>
        public int? MaximumValue { get; set; }

        /// <summary>
        /// Gets or sets the multiply of that the <see cref="Value"/> must be. If null it won't check for any specific
        /// multiply of value.
        /// </summary>
        ///
        /// <value> The multiply of. </value>
        public int? MultiplyOf { get; set; }

        /// <summary>   Gets or sets the window result. </summary>
        ///
        /// <value> The window result. </value>
        public EWindowResult WindowResult { get; protected set; }

        private bool resetValueOnFirstClick = false;

        #endregion

        #region Constructors

        /// <summary>   Default constructor, it will have a empty string in <see cref="Value"/>. </summary>
        public NumericKeyboard()
            : this(string.Empty)
        {
        }

        /// <summary>   Constructor allowing to set an initial value and/or password mode. </summary>
        ///
        /// <param name="p_value">      The initial value that will be shown/typed in the textbox control. </param>
        public NumericKeyboard(string p_value)
        {
            InitializeComponent();

            // Set default owner.
            Owner = GlobalData.MainWindowOwner;

            // Set argument values to local properties.
            Value = p_value;

            // Update text controls accordingly. (PasswordBox does not allow Binding, that is why we are setting manually here)
            tboxValue.Text = Value;

            resetValueOnFirstClick = true;
        }

        #endregion

        #region UI Events

        private void btMinus_Click(object sender, RoutedEventArgs e)
        {
            ApplyMinus();
        }

        protected void btNumber_Click(object sender, RoutedEventArgs e)
        {
            InsertValue(sender as Button);
        }

        protected void btClear_Click(object sender, RoutedEventArgs e)
        {
            Value = string.Empty;
            tboxValue.Text = Value;
        }

        protected void btConfirm_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = true;

            WindowResult = EWindowResult.Ok;

            this.Close();
        }

        protected void btCancel_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;

            WindowResult = EWindowResult.Cancel;

            this.Close();
        }

        #endregion

        #region Private/Local Methods

        private bool InsertValue(Button sender)
        {
            if (sender != null)
            {
                if (resetValueOnFirstClick == true)
                {
                    resetValueOnFirstClick = false;
                    _value = "";
                }

                // Check if length hasn't been reached yet.
                if (Value.Length < CurrentValueMaxLength())
                {
                    string newValue = string.Empty;

                    // If we currently have 0, then replace it with the new digit (same way a calculator does).
                    if (Value == "0")
                        newValue = sender.Content.ToString();
                    else
                        newValue = Value + sender.Content.ToString();

                    // If a 0 has been inserted, we need to make sure it isn't an useless 0 (only first zero is allowed as it will be
                    // replaced IF necessary).
                    if (sender.Content.ToString() == "0" && (Value == "0" || Value == "-"))
                    {
                        return false;
                    }
                    // Check if maximum number still is respected.
                    else if (!MaximumValue.HasValue || long.Parse(newValue) <= MaximumValue)
                    {
                        Value = newValue;
                        tboxValue.Text = Value;

                        return true;
                    }
                }
            }

            return false;
        }

        /// <summary>   Value changed will update UI accordingly. </summary>
        private void ValueChanged()
        {
            if (long.TryParse(Value, out long longValue))
            {
                // Can only confirm if new value is within minimum and maximum value range (if specified).
                // And if the new value is multiply of (if specified).
                btConfirm.IsEnabled = ((!MinimumValue.HasValue || longValue >= MinimumValue) &&
                                      (!MaximumValue.HasValue || longValue <= MaximumValue) &&
                                      (!MultiplyOf.HasValue || longValue % MultiplyOf == 0));
            }
            else
            {
                btConfirm.IsEnabled = false;
            }

            UpdateAvailableUIStates();
        }

        private void UpdateAvailableUIStates()
        {
            bool canType = (Value.Length < CurrentValueMaxLength());
            gdNumbers.IsEnabled = canType;
        }

        private void ApplyMinus()
        {
            // If we already have a number there, then we will convert it to negative
            if (long.TryParse(Value, out long longValue))
            {
                // Invert value.
                longValue = longValue * (-1);

                // Check minimum boundary.
                if (MinimumValue.HasValue && longValue < MinimumValue.Value)
                    longValue = MinimumValue.Value;

                // Check maximum boundary.
                if (MaximumValue.HasValue && longValue > MaximumValue.Value)
                    longValue = MaximumValue.Value;

                Value = longValue.ToString();
                tboxValue.Text = Value;
            }
            else if (Value == string.Empty)
            {
                Value = "-";
                tboxValue.Text = Value;
            }
        }

        private int CurrentValueMaxLength()
        {
            // Start with default MaxLength (specially useful when in password mode).
            int currentMaxLength = MaxLength;

            // If we are dealing with a numeric value we will check it properly.
            if (long.TryParse(Value, out long longValue))
            {
                // If it is a positive value then check its maximum length if available.
                if (longValue >= 0)
                {
                    if (MaximumValue.HasValue)
                        currentMaxLength = MaximumValue.Value.ToString().Length;
                }
                // If it is a negative value then check its minimum length if available.
                else
                {
                    if (MinimumValue.HasValue)
                        currentMaxLength = MinimumValue.Value.ToString().Length;
                }
            }

            return currentMaxLength;
        }

        #endregion

        #region Window Events

        protected override void OnDeactivated(EventArgs e)
        {
            try
            {
                base.OnDeactivated(e);
                Close();
            }
            catch (Exception) { }
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            // If a minimum and maximum value has been set.
            if (MinimumValue.HasValue && MaximumValue.HasValue)
            {
                tblockMinValue.Text = MinimumValue.Value.ToString();
                tblockMaxValue.Text = MaximumValue.Value.ToString();
                lbDisplayMinMax.Visibility = Visibility.Visible;
            }
            else
            {
                lbDisplayMinMax.Visibility = Visibility.Collapsed;
            }

            // If MultiplyOf has been set and is greater than 1 (multiply of 1 accepts anything).
            if (MultiplyOf.HasValue && MultiplyOf.Value > 1)
            {
                tblockMultipleOf.Text = MultiplyOf.Value.ToString();
                lbDisplayMultipleOf.Visibility = Visibility.Visible;
            }
            else
            {
                lbDisplayMultipleOf.Visibility = Visibility.Collapsed;
            }

            // If has a minimum value and it is negative then minus button must be available/visible.
            if (MinimumValue.HasValue && MinimumValue < 0)
            {
                btMinus.Visibility = Visibility.Visible;
            }
            else
            {
                btMinus.Visibility = Visibility.Collapsed;
            }
        }

        private void Window_MouseDown(object sender, System.Windows.Input.MouseButtonEventArgs e)
        {
            if (e.ChangedButton == MouseButton.Left)
                this.DragMove();
        }

        #endregion
    }
}