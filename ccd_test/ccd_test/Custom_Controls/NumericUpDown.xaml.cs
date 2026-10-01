using ccd_test.Windows;
using System;
using System.ComponentModel;
using System.Diagnostics;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Input;

namespace ccd_test
{
    public delegate void ValueChangedEventHandler(object sender, ValueChangedEventArgs e);

    /// <summary>   Interaction logic for NumericUpDown.xaml. </summary>
    public partial class NumericUpDown : UserControl
    {
        #region Event Handlers

        public event ValueChangedEventHandler OnChangeStopped;

        public event ValueChangedEventHandler OnValueChanged;

        #endregion

        #region Properties

        public static readonly DependencyProperty UDDelayProperty =
            DependencyProperty.Register("Delay", typeof(int), typeof(NumericUpDown), new UIPropertyMetadata(500));

        [Bindable(true)]
        public int Delay
        {
            get { return (int)GetValue(UDDelayProperty); }
            set { SetValue(UDDelayProperty, value); }
        }

        public static readonly DependencyProperty IntervalProperty =
            DependencyProperty.Register("Interval", typeof(int), typeof(NumericUpDown), new UIPropertyMetadata(100));

        [Bindable(true)]
        public int Interval
        {
            get { return (int)GetValue(IntervalProperty); }
            set { SetValue(IntervalProperty, value); }
        }

        public static readonly DependencyProperty IncrementProperty =
            DependencyProperty.Register("Increment", typeof(int), typeof(NumericUpDown), new UIPropertyMetadata(1));

        [Bindable(true)]
        public int Increment
        {
            get { return (int)GetValue(IncrementProperty); }
            set { SetValue(IncrementProperty, value); }
        }

        public static readonly DependencyProperty ValueProperty =
            DependencyProperty.Register("Value", typeof(int), typeof(NumericUpDown), new UIPropertyMetadata(1));

        [Bindable(true)]
        public int Value
        {
            get { return (int)GetValue(ValueProperty); }
            set
            {
                if (value >= Minimum && value <= Maximum)
                {
                    prevValue = (int)GetValue(ValueProperty);
                    SetValue(ValueProperty, value);
                    brdMain.BorderThickness = new Thickness(0.0);
                }
            }
        }

        public static readonly DependencyProperty MinimumProperty =
            DependencyProperty.Register("Minimum", typeof(int), typeof(NumericUpDown), new UIPropertyMetadata(0));

        [Bindable(true)]
        public int Minimum
        {
            get { return (int)GetValue(MinimumProperty); }
            set
            {
                SetValue(MinimumProperty, value);
                SetEnabledConditions();

                if (Value < Minimum)
                {
                    brdMain.BorderThickness = new Thickness(2.0);
                }
            }
        }

        public static readonly DependencyProperty MaximumProperty =
            DependencyProperty.Register("Maximum", typeof(int), typeof(NumericUpDown), new UIPropertyMetadata(100));

        [Bindable(true)]
        public int Maximum
        {
            get { return (int)GetValue(MaximumProperty); }
            set
            {
                SetValue(MaximumProperty, value);
                SetEnabledConditions();

                if (Value > Maximum)
                {
                    brdMain.BorderThickness = new Thickness(2.0);
                }
            }
        }

        /// <summary>   Whether the value should reverse when it reaches the maximum or minimum. </summary>
        public static readonly DependencyProperty AutoReverseProperty =
            DependencyProperty.Register("AutoReverse", typeof(bool), typeof(NumericUpDown), new UIPropertyMetadata(false));

        /// <summary>   Whether the value reverse when it reaches the maximum or minimum. </summary>
        ///
        /// <value> True if AutoReverse, false if not. </value>
        [Bindable(true)]
        public bool AutoReverse
        {
            get { return (bool)GetValue(AutoReverseProperty); }
            set { SetValue(AutoReverseProperty, value); }
        }

        public static readonly DependencyProperty CustomUnitProperty =
            DependencyProperty.Register("CustomUnit", typeof(string), typeof(NumericUpDown), new UIPropertyMetadata(""));

        [Bindable(true)]
        public string CustomUnit
        {
            get { return (string)GetValue(CustomUnitProperty); }
            set { SetValue(CustomUnitProperty, value); }
        }

        public static readonly DependencyProperty OutlineIfOutOfRangeProperty =
            DependencyProperty.Register("OutlineIfOutOfRange", typeof(bool), typeof(NumericUpDown), new UIPropertyMetadata(false));

        [Bindable(true)]
        public bool OutlineIfOutOfRange
        {
            get { return (bool)GetValue(OutlineIfOutOfRangeProperty); }
            set { SetValue(OutlineIfOutOfRangeProperty, value); }
        }

        #endregion

        #region Local Fields/Variables

        private int prevValue = 0;

        private NumericKeyboard wndNumericKeyboard;

        #endregion

        #region Constructors

        public NumericUpDown()
        {
            InitializeComponent();

            // Register IsEnabledChanged event handler, as when we are disabled we must close any windows/popups we opened.
            this.IsEnabledChanged += NumericUpDown_IsEnabledChanged;

            // Initialize UI.
            InitializeUIEvents();

            // Set previous value the same as our current initial value.
            prevValue = Value;
        }

        #endregion

        #region Others

        private void InitializeUIEvents()
        {
            btUp.Click += RepeatButtonUp_Click;
            btDown.Click += RepeatButtonDown_Click;
        }

        private void SetEnabledConditions()
        {
            if (Value >= Maximum && btUp.IsEnabled)
                btUp.IsEnabled = false;
            else if (Value < Maximum && !btUp.IsEnabled)
                btUp.IsEnabled = true;

            if (Value <= Minimum && btDown.IsEnabled)
                btDown.IsEnabled = false;
            else if (Value > Minimum && !btDown.IsEnabled)
                btDown.IsEnabled = true;
        }

        protected void FireChangeStopped(ValueChangedEventArgs e)
        {
            OnChangeStopped?.Invoke(this, e);
        }

        protected void FireValueChanged(ValueChangedEventArgs e)
        {
            OnValueChanged?.Invoke(this, e);
        }

        #endregion

        #region Window/UC Events

        private void NumericUpDown_IsEnabledChanged(object sender, DependencyPropertyChangedEventArgs e)
        {
            if (wndNumericKeyboard != null && wndNumericKeyboard.IsVisible)
            {
                Debug.WriteLine("NumericUpDown keyboard popup was closed due to its IsEnabled property has been setted to FALSE (disabled).");
                wndNumericKeyboard.Close();
            }
        }

        private void UserControl_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            TextCustomUnit.FontSize = this.FontSize / 2;

            try
            {
                btUp.FontSize = (this.FontSize / 6) + (gdMain.ActualHeight / 6) + (gdMain.ActualWidth / 6);
            }
            catch
            {
                btUp.FontSize = 1;
            }

            try
            {
                btDown.FontSize = (this.FontSize / 6) + (gdMain.ActualHeight / 6) + (gdMain.ActualWidth / 6);
            }
            catch
            {
                btDown.FontSize = 1;
            }
        }

        private void ChangeStopped()
        {
            ValueChangedEventArgs args = new ValueChangedEventArgs(prevValue, Value);
            FireChangeStopped(args);
        }

        #endregion

        #region Interface Event Handling

        private void lbValue_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            wndNumericKeyboard = new NumericKeyboard(Value.ToString())
            {
                // Set texts accordingly to language.
                Title = "Teclado",
                TextClear = "Limpar",
                TextDisplayPassword = "Mostrar senha",
                TextConfirm = "Confirmar",
                TextCancel = "Cancelar",

                // Set keyboard limits accordingly to our current ones.
                MinimumValue = Minimum,
                MaximumValue = Maximum,
                MultiplyOf = Increment,

                // Set owner to our current paret window.
                Owner = Window.GetWindow(this)
            };

            wndNumericKeyboard.ShowDialog();
            // Check if user has confirmed and has a valid typed value.
            if (wndNumericKeyboard.WindowResult == App_Code.EWindowResult.Ok && int.TryParse(wndNumericKeyboard.Value, out int typedValue))
            {
                UpdateValueWithNotification(typedValue);
            }
        }

        private void RepeatButtonUp_Click(object sender, RoutedEventArgs e)
        {
            if (AutoReverse && (Value + Increment) > Maximum)
                Value = Minimum;
            else
                Value += Increment;

            //ValueChangedEventArgs args = new ValueChangedEventArgs(prevValue, Value);
            //FireValueChanged(args);
        }

        private void RepeatButtonDown_Click(object sender, RoutedEventArgs e)
        {
            if (AutoReverse && (Value - Increment) < Minimum)
                Value = Maximum;
            else
                Value -= Increment;

            //ValueChangedEventArgs args = new ValueChangedEventArgs(prevValue, Value);
            //FireValueChanged(args);
        }

        private void Up_PreviewMouseUp(object sender, MouseButtonEventArgs e)
        {
            ChangeStopped();
        }

        private void Down_PreviewMouseUp(object sender, MouseButtonEventArgs e)
        {
            ChangeStopped();
        }

        private void lbValue_TargetUpdated(object sender, DataTransferEventArgs e)
        {
            // IF we are NOT in Auto Reverse mode, then we will block Up and Down buttons in the UI indicating that the max
            // value has been reached. 
            if (!AutoReverse)
            {
                if (Value >= Maximum && btUp.IsEnabled)
                {
                    btUp.IsEnabled = false;
                    ChangeStopped();
                }
                else if (Value < Maximum && !btUp.IsEnabled)
                    btUp.IsEnabled = true;

                if (Value <= Minimum && btDown.IsEnabled)
                {
                    btDown.IsEnabled = false;
                    ChangeStopped();
                }
                else if (Value > Minimum && !btDown.IsEnabled)
                    btDown.IsEnabled = true;
            }

            // Notify that the value has changed.
            FireValueChanged(new ValueChangedEventArgs(prevValue, Value));
        }

        #endregion

        #region Public Methods

        /// <summary>   Updates the NumericUpDown Value and notifies/calls the OnChangeStopped event. </summary>
        ///
        /// <param name="p_newValue">   The new value. </param>
        public void UpdateValueWithNotification(int? p_newValue)
        {
            if (p_newValue != null)
            {
                ValueChangedEventArgs e = new ValueChangedEventArgs(Value, (int)p_newValue);
                Value = (int)p_newValue;
                FireChangeStopped(e);
            }
            else
            {
                FireChangeStopped(new ValueChangedEventArgs(Value, Value));
            }
        }

        #endregion
    }

    #region Nested Types

    public class ValueChangedEventArgs : EventArgs
    {
        private int newVal;

        public int NewValue
        {
            get { return newVal; }
        }

        private int previousValue;

        public int PreviousValue
        {
            get { return previousValue; }
        }

        public ValueChangedEventArgs(int p_previousValue, int p_newValue)
        {
            newVal = p_newValue;
            previousValue = p_previousValue;
        }
    }

    #endregion
}