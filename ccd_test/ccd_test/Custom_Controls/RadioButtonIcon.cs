//using ccd_test.Custom_Controls;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace ccd_test
{
    internal class RadioButtonIcon : RadioButton
    {
        public static readonly DependencyProperty IconGeometryProperty =
            DependencyProperty.Register("IconGeometry", typeof(Geometry), typeof(RadioButtonIcon),
                new PropertyMetadata(default(Geometry)));

        public Geometry IconGeometry
        {
            get { return (Geometry)GetValue(IconGeometryProperty); }
            set { SetValue(IconGeometryProperty, value); }
        }

        public static readonly DependencyProperty IconColorProperty =
            DependencyProperty.Register("IconColor", typeof(SolidColorBrush), typeof(RadioButtonIcon),
                new PropertyMetadata(default(SolidColorBrush)));

        public SolidColorBrush IconColor
        {
            get { return (SolidColorBrush)GetValue(IconColorProperty); }
            set { SetValue(IconColorProperty, value); }
        }

        public static readonly DependencyProperty ImageMarginProperty =
            DependencyProperty.Register("ImageMargin", typeof(double), typeof(RadioButtonIcon),
                new PropertyMetadata(default(double)));

        public double ImageMargin
        {
            get { return (double)GetValue(ImageMarginProperty); }
            set { SetValue(ImageMarginProperty, value); }
        }

        static RadioButtonIcon()
        {
            DefaultStyleKeyProperty.OverrideMetadata(typeof(RadioButtonIcon), new FrameworkPropertyMetadata(typeof(RadioButtonIcon)));
        }

        public override void OnApplyTemplate()
        {
            base.OnApplyTemplate();
        }

        public RadioButtonIcon() { }
    }
}
