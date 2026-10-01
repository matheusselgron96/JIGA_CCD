//using ccd_test.Custom_Controls;
using System;
using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Media;

namespace ccd_test
{
    /// <summary>   Interaction logic for ToggleSwitch.xaml. </summary>
    public partial class ToggleSwitch : ToggleButton
    {
        #region Properties

        public static readonly DependencyProperty CheckedTextProperty =
        DependencyProperty.Register("CheckedText", typeof(string), typeof(ToggleSwitch), new UIPropertyMetadata("Ligado"));

        [Bindable(true)]
        public string CheckedText
        {
            get { return (string)GetValue(CheckedTextProperty); }
            set { SetValue(CheckedTextProperty, value); }
        }

        public static readonly DependencyProperty UncheckedTextProperty =
        DependencyProperty.Register("UncheckedText", typeof(string), typeof(ToggleSwitch), new UIPropertyMetadata("Desligado"));

        [Bindable(true)]
        public string UncheckedText
        {
            get { return (string)GetValue(UncheckedTextProperty); }
            set { SetValue(UncheckedTextProperty, value); }
        }

        public static readonly DependencyProperty CheckedImgProperty =
        DependencyProperty.Register("CheckedImg", typeof(ImageSource), typeof(ToggleSwitch), new UIPropertyMetadata());

        [Bindable(true)]
        public ImageSource CheckedImg
        {
            get { return (ImageSource)GetValue(CheckedImgProperty); }
            set { SetValue(CheckedImgProperty, value); }
        }

        public static readonly DependencyProperty UncheckedImgProperty =
        DependencyProperty.Register("UncheckedImg", typeof(ImageSource), typeof(ToggleSwitch), new UIPropertyMetadata());

        [Bindable(true)]
        public ImageSource UncheckedImg
        {
            get { return (ImageSource)GetValue(UncheckedImgProperty); }
            set { SetValue(UncheckedImgProperty, value); }
        }

        static ToggleSwitch()
        {
            DefaultStyleKeyProperty.OverrideMetadata(typeof(ToggleSwitch), new FrameworkPropertyMetadata(typeof(ToggleSwitch)));
        }

        public override void OnApplyTemplate()
        {
            base.OnApplyTemplate();
        }

        public ToggleSwitch() { }

        #endregion
    }
}