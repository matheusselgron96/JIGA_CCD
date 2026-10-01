using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls.Primitives;
using System.Windows.Media;

namespace ccd_test
{
    internal class ToggleIcon : ToggleButton
    {
        public static readonly DependencyProperty IconGeometryProperty =
            DependencyProperty.Register("IconGeometry", typeof(Geometry), typeof(ToggleIcon),
                new PropertyMetadata(default(Geometry)));

        public Geometry IconGeometry
        {
            get { return (Geometry)GetValue(IconGeometryProperty); }
            set { SetValue(IconGeometryProperty, value); }
        }

        public static readonly DependencyProperty IconColorProperty =
            DependencyProperty.Register("IconColor", typeof(SolidColorBrush), typeof(ToggleIcon),
                new PropertyMetadata(default(SolidColorBrush)));

        public SolidColorBrush IconColor
        {
            get { return (SolidColorBrush)GetValue(IconColorProperty); }
            set { SetValue(IconColorProperty, value); }
        }

        public static readonly DependencyProperty CheckedIconGeometryProperty =
            DependencyProperty.Register("CheckedIconGeometry", typeof(Geometry), typeof(ToggleIcon),
                new PropertyMetadata(default(Geometry)));

        public Geometry CheckedIconGeometry
        {
            get { return (Geometry)GetValue(CheckedIconGeometryProperty); }
            set { SetValue(CheckedIconGeometryProperty, value); }
        }

        public static readonly DependencyProperty CheckedIconColorProperty =
            DependencyProperty.Register("CheckedIconColor", typeof(SolidColorBrush), typeof(ToggleIcon),
                new PropertyMetadata(default(SolidColorBrush)));

        public SolidColorBrush CheckedIconColor
        {
            get { return (SolidColorBrush)GetValue(CheckedIconColorProperty); }
            set { SetValue(CheckedIconColorProperty, value); }
        }

        public static readonly DependencyProperty ImageMarginProperty =
            DependencyProperty.Register("ImageMargin", typeof(double), typeof(ToggleIcon),
                new PropertyMetadata(default(double)));

        public double ImageMargin
        {
            get { return (double)GetValue(ImageMarginProperty); }
            set { SetValue(ImageMarginProperty, value); }
        }

        public static readonly DependencyProperty ImageBackgroundProperty =
            DependencyProperty.Register("ImageBackground", typeof(SolidColorBrush), typeof(ToggleIcon),
                new PropertyMetadata(default(SolidColorBrush)));

        public SolidColorBrush ImageBackground
        {
            get { return (SolidColorBrush)GetValue(ImageBackgroundProperty); }
            set { SetValue(ImageBackgroundProperty, value); }
        }

        static ToggleIcon()
        {
            DefaultStyleKeyProperty.OverrideMetadata(typeof(ToggleIcon), new FrameworkPropertyMetadata(typeof(ToggleIcon)));
        }

        public override void OnApplyTemplate()
        {
            base.OnApplyTemplate();
        }

        public ToggleIcon() { }
    }
}
