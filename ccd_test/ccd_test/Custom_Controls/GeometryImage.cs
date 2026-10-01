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
    class GeometryImage : ContentControl
    {
        public static readonly DependencyProperty IconGeometryProperty =
            DependencyProperty.Register("IconGeometry", typeof(Geometry), typeof(GeometryImage),
                new PropertyMetadata(default(Geometry)));

        public Geometry IconGeometry
        {
            get { return (Geometry)GetValue(IconGeometryProperty); }
            set { SetValue(IconGeometryProperty, value); }
        }

        public static readonly DependencyProperty IconColorProperty =
            DependencyProperty.Register("IconColor", typeof(SolidColorBrush), typeof(GeometryImage),
                new PropertyMetadata(default(SolidColorBrush)));

        public SolidColorBrush IconColor
        {
            get { return (SolidColorBrush)GetValue(IconColorProperty); }
            set { SetValue(IconColorProperty, value); }
        }

        static GeometryImage()
        {
            DefaultStyleKeyProperty.OverrideMetadata(typeof(GeometryImage), new FrameworkPropertyMetadata(typeof(GeometryImage)));
        }

        public override void OnApplyTemplate()
        {
            base.OnApplyTemplate();
        }

        public GeometryImage() { }
    }
}
