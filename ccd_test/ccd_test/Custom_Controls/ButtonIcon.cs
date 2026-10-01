using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace ccd_test
{
    internal class ButtonIcon : Button
    {
        public static readonly DependencyProperty IconGeometryProperty =
            DependencyProperty.Register("IconGeometry", typeof(Geometry), typeof(ButtonIcon),
                new PropertyMetadata(default(Geometry)));

        public Geometry IconGeometry
        {
            get { return (Geometry)GetValue(IconGeometryProperty); }
            set { SetValue(IconGeometryProperty, value); }
        }

        public static readonly DependencyProperty IconColorProperty =
            DependencyProperty.Register("IconColor", typeof(SolidColorBrush), typeof(ButtonIcon),
                new PropertyMetadata(default(SolidColorBrush)));

        public SolidColorBrush IconColor
        {
            get { return (SolidColorBrush)GetValue(IconColorProperty); }
            set { SetValue(IconColorProperty, value); }
        }

        public static readonly DependencyProperty ImageMarginProperty =
            DependencyProperty.Register("ImageMargin", typeof(double), typeof(ButtonIcon),
                new PropertyMetadata(default(double)));

        public double ImageMargin
        {
            get { return (double)GetValue(ImageMarginProperty); }
            set { SetValue(ImageMarginProperty, value); }
        }

        public static readonly DependencyProperty ImageBackgroundProperty =
            DependencyProperty.Register("ImageBackground", typeof(SolidColorBrush), typeof(ButtonIcon),
                new PropertyMetadata(new SolidColorBrush(System.Windows.Media.Color.FromArgb(0, 0, 0, 0))));

        public SolidColorBrush ImageBackground
        {
            get { return (SolidColorBrush)GetValue(ImageBackgroundProperty); }
            set { SetValue(ImageBackgroundProperty, value); }
        }

        static ButtonIcon()
        {
            DefaultStyleKeyProperty.OverrideMetadata(typeof(ButtonIcon), new FrameworkPropertyMetadata(typeof(ButtonIcon)));
        }

        public override void OnApplyTemplate()
        {
            base.OnApplyTemplate();
        }

        public ButtonIcon() { }
    }
}
