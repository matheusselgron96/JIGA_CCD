using ccd_test.Models;
using ccd_test.Windows;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Shapes;

namespace ccd_test
{
    /// <summary>   Interaction logic for UC_Ocil.xaml. </summary>
    public partial class OsciloscopeGraphic : UserControl
    {
        #region Properties

        public OscilloscopeConfig CurrentConfig { get; set; }

        /// <summary>   If steps Lines are 0, will divide the grid equally by the number in lines grid. </summary>
        ///
        /// <value> The lines grid. </value>
        public int LinesGrid { get; set; }

        /// <summary>   If steps Columns are 0, will divide the grid equally by the number in lines grid. </summary>
        ///
        /// <value> The columns grid. </value>
        public int ColumnsGrid { get; set; }

        public int StepsLines { get; set; }

        public int StepsColumns { get; set; }

        public int MaxHorizontal { get; set; }

        public int MaxVertical { get; set; }

        public int MinHorizontal { get; set; }

        public int MinVertical { get; set; }

        public static readonly DependencyProperty LineOneColorProperty =
            DependencyProperty.Register("LineOneColor", typeof(Brush), typeof(OsciloscopeGraphic), new UIPropertyMetadata(Brushes.Red));

        [Bindable(true)]
        public Brush LineOneColor
        {
            get { return (Brush)GetValue(LineOneColorProperty); }
            set { SetValue(LineOneColorProperty, value); }
        }

        public static readonly DependencyProperty LineTwoColorProperty =
            DependencyProperty.Register("LineTwoColor", typeof(Brush), typeof(OsciloscopeGraphic), new UIPropertyMetadata(Brushes.Green));

        [Bindable(true)]
        public Brush LineTwoColor
        {
            get { return (Brush)GetValue(LineTwoColorProperty); }
            set { SetValue(LineTwoColorProperty, value); }
        }

        public static readonly DependencyProperty LineThreeColorProperty =
            DependencyProperty.Register("LineThreeColor", typeof(Brush), typeof(OsciloscopeGraphic), new UIPropertyMetadata(Brushes.Blue));

        [Bindable(true)]
        public Brush LineThreeColor
        {
            get { return (Brush)GetValue(LineThreeColorProperty); }
            set { SetValue(LineThreeColorProperty, value); }
        }

        public static readonly DependencyProperty LineOneTitleProperty =
            DependencyProperty.Register("LineOneTitle", typeof(string), typeof(OsciloscopeGraphic), new UIPropertyMetadata("R"));

        [Bindable(true)]
        public string LineOneTitle
        {
            get { return (string)GetValue(LineOneTitleProperty); }
            set { SetValue(LineOneTitleProperty, value); }
        }

        public static readonly DependencyProperty LineTwoTitleProperty =
            DependencyProperty.Register("LineTwoTitle", typeof(string), typeof(OsciloscopeGraphic), new UIPropertyMetadata("G"));

        [Bindable(true)]
        public string LineTwoTitle
        {
            get { return (string)GetValue(LineTwoTitleProperty); }
            set { SetValue(LineTwoTitleProperty, value); }
        }

        public static readonly DependencyProperty LineThreeTitleProperty =
            DependencyProperty.Register("LineThreeTitle", typeof(string), typeof(OsciloscopeGraphic), new UIPropertyMetadata("B"));

        [Bindable(true)]
        public string LineThreeTitle
        {
            get { return (string)GetValue(LineThreeTitleProperty); }
            set { SetValue(LineThreeTitleProperty, value); }
        }

        #endregion Properties

        #region Local Fields/Variables

        private bool initialized = false;

        private int size
        {
            get { return (Math.Abs(this.MaxHorizontal - this.MinHorizontal) + 1); }
        }

        private VisualCollection visuals;

        private List<int> lsGraphOne = new List<int>(256);
        private List<int> lsGraphTwo = new List<int>(256);
        private List<int> lsGraphThree = new List<int>(256);

        #endregion Local Fields/Variables

        public OsciloscopeGraphic()
        {
            InitializeComponent();
            visuals = new VisualCollection(this);
            this.MaxHorizontal = 255;
            this.MinHorizontal = 0;
            this.MaxVertical = 100;
            this.MinVertical = -100;
            this.LinesGrid = 0;
            this.ColumnsGrid = 0;

            this.StepsColumns = 10;
            this.StepsLines = 10;
        }

        #region Private Local/Methods

        private Dictionary<int, Line> offSetLines = new Dictionary<int, Line>(2);
        Line centerLine = new Line();

        private Line CreateVerticalLine()
        {
            Line lm = new Line();
            lm.Stroke = Brushes.Black;
            lm.StrokeThickness = 3;
            lm.StrokeDashArray = new DoubleCollection() { 1, 2 };
            //lm.SetValue(RenderOptions.EdgeModeProperty, EdgeMode.Aliased);

            return lm;
        }

        private void SetVerticalLine(double xL1, double xL2, Grid grid, Canvas chart, int lineId)
        {
            Line ln1 = CreateVerticalLine();
            Line ln2 = CreateVerticalLine();

            // Get canvas absolute position.
            var getPos = chart.TransformToVisual(grid);
            Point XYpos = getPos.Transform(new Point(0, 0));
            double initialPositionX = (XYpos.X + 1);
            double initialPositionY = (XYpos.Y + 1);

            ln1.X1 = initialPositionX + xL1;
            ln1.X2 = initialPositionX + xL1;
            ln1.Y1 = initialPositionY;
            ln1.Y2 = chart.ActualHeight;

            ln2.X1 = initialPositionX + xL2;
            ln2.X2 = initialPositionX + xL2;
            ln2.Y1 = initialPositionY;
            ln2.Y2 = chart.ActualHeight;

            if (offSetLines.ContainsKey(lineId))
            {
                if (lineId == 1)
                {
                    grid.Children.Remove(offSetLines[lineId]);
                    grid.Children.Add(ln1);
                    offSetLines[lineId] = ln1;
                }
                else if (lineId == 2)
                {
                    grid.Children.Remove(offSetLines[lineId]);
                    grid.Children.Add(ln2);
                    offSetLines[lineId] = ln2;
                }
            }
            else
            {
                if (lineId == 1)
                {
                    grid.Children.Add(ln1);
                    offSetLines[lineId] = ln1;
                }
                else if (lineId == 2)
                {
                    grid.Children.Add(ln2);
                    offSetLines[lineId] = ln2;
                }
            }
        }

        private void DrawCenterLine(Grid grid, Canvas chart)
        {
            Line ln = CreateVerticalLine();

            // Get canvas absolute position.
            var getPos = chart.TransformToVisual(grid);
            Point XYpos = getPos.Transform(new Point(0, 0));
            double initialPositionX = (XYpos.X + 1);
            double initialPositionY = (XYpos.Y + 1);

            // Not working -\(-_-)/- maybe is because of the chart width
            //ln.X1 = initialPositionX + ((this.MaxHorizontal+1) / 2) ;
            //ln.X2 = initialPositionX + ((this.MaxHorizontal+1) / 2);

            ln.X1 = initialPositionX + chart.ActualWidth / 2;
            ln.X2 = initialPositionX + chart.ActualWidth / 2;
            ln.Y1 = initialPositionY;
            //ln.Y2 = 229;
            ln.Y2 = chart.ActualHeight;

            grid.Children.Remove(centerLine);
            centerLine = ln;
            grid.Children.Add(centerLine);

        }

        private Line CreateGridLine()
        {
            Line ln = new Line();
            ln.Stroke = Brushes.Black;
            ln.StrokeThickness = 1;
            ln.Opacity = 0.1;
            ln.SetValue(RenderOptions.EdgeModeProperty, EdgeMode.Aliased);

            return ln;
        }

        private Line CreateHorizontalGridLine(Point start, double length)
        {
            Line ln = CreateGridLine();
            // It has the same value because the line will be a vertical line.
            ln.X1 = start.X;
            ln.X2 = start.X + length;
            ln.Y1 = start.Y;
            ln.Y2 = start.Y;

            return ln;
        }

        private Line CreateHorizontalScaleLine(Point start)
        {
            Line l = CreateScaleLine();
            l.X1 = start.X;
            l.X2 = start.X - 5;
            l.Y1 = start.Y;
            l.Y2 = start.Y;

            return l;
        }

        private Line CreateScaleLine()
        {
            Line l = new Line();
            l.Stroke = Brushes.Black;
            l.SetValue(RenderOptions.EdgeModeProperty, EdgeMode.Aliased);

            return l;
        }

        private Line CreateVerticalGridLine(Point start, double length)
        {
            Line ln = CreateGridLine();

            // It has the same value because the line will be a vertical line.
            ln.X1 = start.X;
            ln.X2 = start.X;
            ln.Y1 = start.Y;
            ln.Y2 = start.Y + length;

            return ln;
        }

        private Line CreateVerticalScaleLine(Point start)
        {
            Line l = CreateScaleLine();
            l.X1 = start.X;
            l.X2 = start.X;
            l.Y1 = start.Y;
            l.Y2 = start.Y + 5;

            return l;
        }

        private void DrawGrid(Grid grid, Canvas chart)
        {
            gdChartArea.Children.Clear();
            gdChartArea.Children.Add(cnvChart);
            gdChartArea.Children.Add(brdChart);
            gdMainGraph.Children.Clear();
            gdMainGraph.Children.Add(gdChartArea);

            bool makeBySteps = true;
            if ((this.StepsColumns == 0) || (this.StepsLines == 0))
            {
                makeBySteps = false;

                if ((this.LinesGrid == 0) || (this.ColumnsGrid == 0))
                    throw new DivideByZeroException();
            }

            // Get canvas absolute position.
            var getPos = chart.TransformToVisual(grid);
            Point XYpos = getPos.Transform(new Point(0, 0));

            // Draw the lines.
            double actualWidth = (chart.ActualWidth == 0) ? chart.Width : chart.ActualWidth;
            double initialPosition = (XYpos.X + 1);
            double length = this.MaxHorizontal - this.MinHorizontal + 1;
            double stepLegend = (makeBySteps) ? this.StepsColumns : length / Convert.ToDouble(this.ColumnsGrid);
            int counter = (makeBySteps) ? ((int)length) / this.StepsColumns : this.ColumnsGrid;
            double step = (makeBySteps) ? (actualWidth / length) * this.StepsColumns : (actualWidth / this.ColumnsGrid);
            length = Math.Abs(length);
            double remainder = 0d;

            for (int i = 0; i <= counter; i++)
            {
                // Vertical gridlines.
                double steps = i * step;
                Point start = new Point(initialPosition + steps, XYpos.Y);
                Line lineVerticalGrid = CreateVerticalGridLine(start, chart.ActualHeight);

                // Don't add lines touching the sides
                if (i > 0 && i < counter)
                {
                    grid.Children.Add(lineVerticalGrid);
                }

                // Bottom labels.
                Label lbBottom = new Label();
                lbBottom.Width = 35;
                lbBottom.Height = 20;
                lbBottom.Padding = new Thickness(0);
                lbBottom.HorizontalContentAlignment = HorizontalAlignment.Center;
                lbBottom.ClipToBounds = false;

                // This garantes that it will consider the reminder of divisions.
                double numero = this.MinHorizontal + (i * stepLegend);
                remainder += numero - Math.Round(numero);
                numero = Math.Round(numero);

                if (remainder > 1)
                {
                    remainder -= 1;
                    numero += 1;
                }
                else if (remainder < -1)
                {
                    remainder += 1;
                    numero -= 1;
                }

                lbBottom.Content = numero;
                gdMainGraph.Children.Add(lbBottom);

                lbBottom.HorizontalAlignment = HorizontalAlignment.Left;
                lbBottom.VerticalAlignment = VerticalAlignment.Top;
                int xOffset = i == counter ? 5 : 22;
                lbBottom.Margin = new Thickness((XYpos.X + xOffset) + steps, XYpos.Y + chart.ActualHeight + 10, 0, 0);
            }

            initialPosition = XYpos.Y;
            double actualHeight = (chart.ActualHeight == 0) ? chart.Height : chart.ActualHeight;
            length = this.MaxVertical - this.MinVertical + 1;
            stepLegend = (makeBySteps) ? this.StepsLines : length / Convert.ToDouble(this.LinesGrid);
            counter = (makeBySteps) ? ((int)length) / this.StepsLines : this.LinesGrid;
            step = (makeBySteps) ? (actualHeight / length) * this.StepsLines : (actualHeight / this.LinesGrid);
            //initialPosition = (makeBySteps) ? initialPosition + ((actualHeight / length) * (length % this.StepsLines)) : initialPosition;
            length = Math.Abs(length);
            remainder = 0d;

            for (int i = 1; i <= counter; i++)
            {
                double steps = i * step;
                Point start = new Point(XYpos.X, actualHeight + initialPosition - steps);
                //SystemLogger.Report($"Horizontal Line Y - {start.Y}");
                // Horizontal gridlines.
                if (i < counter)
                {
                    Line lm = CreateHorizontalGridLine(start, actualWidth);
                    grid.Children.Add(lm);
                }

                // Side labels.
                Label lb = new Label();
                lb.Width = 30;
                lb.Height = 20;
                lb.HorizontalContentAlignment = System.Windows.HorizontalAlignment.Right;
                lb.Padding = new Thickness(0);
                lb.VerticalContentAlignment = VerticalAlignment.Center;
                lb.ClipToBounds = false;
                // This garantes that it will consider the reminder of divisions.
                double numero = this.MinVertical + (i * stepLegend);
                remainder += numero - Math.Round(numero);
                numero = Math.Round(numero);

                if (remainder > 1)
                {
                    remainder -= 1;
                    numero += 1;
                }
                else if (remainder < -1)
                {
                    remainder += 1;
                    numero -= 1;
                }

                lb.Content = numero;
                lb.HorizontalAlignment = HorizontalAlignment.Left;
                lb.VerticalAlignment = VerticalAlignment.Top;
                lb.Margin = new Thickness(XYpos.X - 37, start.Y - 12, 0, 0);
                grid.Children.Add(lb);
            }
        }

        public void DrawOffsetLines(double xL1, double xL2, int lineId)
        {
            this.SetVerticalLine(xL1, xL2, gdChartArea, cnvChart, lineId);
        }

        public void DrawGrid()
        {
            this.DrawGrid(gdChartArea, cnvChart);
        }

        public void DrawGraphCenterLine()
        {
            this.DrawCenterLine(gdChartArea, cnvChart);
        }

        private void DrawLine(List<int> p_values, SolidColorBrush color)
        {
            double stepHorizontal = cnvChart.ActualWidth / ((this.MaxHorizontal - this.MinHorizontal) + 1);
            double stepVertical = cnvChart.ActualHeight / ((this.MaxVertical - this.MinVertical) + 1);

            Polyline pl = new Polyline();

            for (int i = 0; i < p_values.Count; i++)
            {
                int val = p_values[i];
                double x = (stepHorizontal * i);
                double y = cnvChart.ActualHeight - ((val - this.MinVertical) * stepVertical);
                pl.Points.Add(new Point(x, y));
            }

            pl.StrokeThickness = 1;
            pl.Stroke = color;

            pl.Height = cnvChart.ActualHeight;
            pl.Width = cnvChart.ActualWidth;
            cnvChart.Children.Add(pl);
        }

        private void DrawFirstLine(List<int> p_values)
        {
            DrawLine(p_values, (SolidColorBrush)LineOneColor);
        }

        private void DrawSecondLine(List<int> p_values)
        {
            DrawLine(p_values, (SolidColorBrush)LineTwoColor);
        }

        private void DrawThirdLine(List<int> p_values)
        {
            DrawLine(p_values, (SolidColorBrush)LineThreeColor);
        }

        private List<int> GetRandomValues(int seed)
        {
            int quantidade = this.size;
            List<int> lsValues = new List<int>(quantidade);
            seed = Convert.ToInt32(DateTime.Now.Ticks % int.MaxValue) + seed;
            Random ran = new Random(seed);

            for (int i = 0; i < quantidade; i++)
            {
                int randomValue = ran.Next(this.MinVertical, this.MaxVertical);
                lsValues.Add(randomValue);
            }

            return lsValues;
        }

        private List<int> ValidateAndCorrectValues(List<int> p_values)
        {
            return p_values.ConvertAll(x => (x > MaxVertical) ? MaxVertical : x).  // If it's higher than the setted max value, set it as maximum allowed.
                            ConvertAll(x => (x < MinVertical) ? MinVertical : x);  // If it's lower than the setted min value, set it as the minimum allowed.
        }

        #endregion Private Local/Methods

        #region Public Methods

        public void ClearGraphic()
        {
            this.cnvChart.Children.Clear();
        }

        public void UpdateGraphValues()
        {
            UpdateGraphValues(GetRandomValues(33), GetRandomValues(65), GetRandomValues(24));
        }

        public void UpdateGraphValues(List<int> p_redValues, List<int> p_greenValues, List<int> p_blueValues)
        {
            //Clear current graphic values.
            ClearGraphic();

            if (CurrentConfig.ShowR) DrawFirstLine(ValidateAndCorrectValues(p_redValues));
            if (CurrentConfig.ShowG) DrawSecondLine(ValidateAndCorrectValues(p_greenValues));
            if (CurrentConfig.ShowB) DrawThirdLine(ValidateAndCorrectValues(p_blueValues));
        }

        public void UpdateZoomedGraphValues(List<int> p_redValues, List<int> p_greenValues, List<int> p_blueValues)
        {
            if (CurrentConfig.ShowR) DrawZoomedFirstLine(ValidateAndCorrectValues(p_redValues));
            if (CurrentConfig.ShowG) DrawZoomedSecondLine(ValidateAndCorrectValues(p_greenValues));
            if (CurrentConfig.ShowB) DrawZoomedThirdLine(ValidateAndCorrectValues(p_blueValues));
        }

        public void DisplayConfigButton()
        {
            cnvChart.Children.Add(btConfig);
        }

        private void DrawZoomedThirdLine(List<int> p_values)
        {
            DrawZoomedLine(p_values, (SolidColorBrush)LineThreeColor);
        }

        private void DrawZoomedSecondLine(List<int> p_values)
        {
            DrawZoomedLine(p_values, (SolidColorBrush)LineTwoColor);
        }

        private void DrawZoomedFirstLine(List<int> p_values)
        {
            DrawZoomedLine(p_values, (SolidColorBrush)LineOneColor);
        }

        private void DrawZoomedLine(List<int> p_values, SolidColorBrush color)
        {
            double stepHorizontal = cnvChart.ActualWidth / ((this.MaxHorizontal - this.MinHorizontal) + 1);
            double stepVertical = cnvChart.ActualHeight / ((this.MaxVertical - this.MinVertical) + 1);

            Polyline pl = new Polyline();

            for (int i = 0; i < p_values.Count; i++)
            {
                int val = p_values[i];
                double x = (stepHorizontal * i);
                double y = cnvChart.ActualHeight - ((Math.Clamp(val + 128, 0, 255) - this.MinVertical) * stepVertical);
                pl.Points.Add(new Point(x, y));
            }

            pl.StrokeThickness = 1;
            pl.Stroke = color;

            pl.Height = cnvChart.ActualHeight;
            pl.Width = cnvChart.ActualWidth;
            cnvChart.Children.Add(pl);
        }

        internal void UpdateLeftAmplitudes(int yPos, int rA, int gA, int bA)
        {
            double stepVertical = cnvChart.ActualHeight / ((this.MaxVertical - this.MinVertical) + 1);

            if (CurrentConfig.ShowR)
            {
                Label lbRedAmpl = new Label();
                lbRedAmpl.Content = "R: " + rA.ToString();
                lbRedAmpl.HorizontalAlignment = HorizontalAlignment.Left;
                lbRedAmpl.Margin = new Thickness(100, cnvChart.ActualHeight - (stepVertical * yPos), 0, 0);
                lbRedAmpl.FontWeight = FontWeights.Bold;
                cnvChart.Children.Add(lbRedAmpl);
            }

            if (CurrentConfig.ShowG)
            {
                Label lbGreenAmpl = new Label();
                lbGreenAmpl.Content = "G: " + gA.ToString();
                lbGreenAmpl.HorizontalAlignment = HorizontalAlignment.Left;
                lbGreenAmpl.Margin = new Thickness(150, cnvChart.ActualHeight - (stepVertical * yPos), 0, 0);
                lbGreenAmpl.FontWeight = FontWeights.Bold;
                cnvChart.Children.Add(lbGreenAmpl);
            }

            if (CurrentConfig.ShowB)
            {
                Label lbBlueAmpl = new Label();
                lbBlueAmpl.Content = "B: " + bA.ToString();
                lbBlueAmpl.HorizontalAlignment = HorizontalAlignment.Left;
                lbBlueAmpl.Margin = new Thickness(200, cnvChart.ActualHeight - (stepVertical * yPos), 0, 0);
                lbBlueAmpl.FontWeight = FontWeights.Bold;
                cnvChart.Children.Add(lbBlueAmpl);
            }
        }

        internal void UpdateRightAmplitudes(int yPos, int rA, int gA, int bA)
        {
            double stepVertical = cnvChart.ActualHeight / ((this.MaxVertical - this.MinVertical) + 1);
            
            if (CurrentConfig.ShowR)
            {
                Label lbRedAmpl = new Label();
                lbRedAmpl.Content = "R: " + rA.ToString();
                lbRedAmpl.HorizontalAlignment = HorizontalAlignment.Left;
                lbRedAmpl.Margin = new Thickness(700, cnvChart.ActualHeight - (stepVertical * yPos), 0, 0);
                lbRedAmpl.FontWeight = FontWeights.Bold;
                cnvChart.Children.Add(lbRedAmpl);
            }

            if (CurrentConfig.ShowG)
            {
                Label lbGreenAmpl = new Label();
                lbGreenAmpl.Content = "G: " + gA.ToString();
                lbGreenAmpl.HorizontalAlignment = HorizontalAlignment.Left;
                lbGreenAmpl.Margin = new Thickness(750, cnvChart.ActualHeight - (stepVertical * yPos), 0, 0);
                lbGreenAmpl.FontWeight = FontWeights.Bold;
                cnvChart.Children.Add(lbGreenAmpl);
            }

            if (CurrentConfig.ShowB)
            {
                Label lbBlueAmpl = new Label();
                lbBlueAmpl.Content = "B: " + bA.ToString();
                lbBlueAmpl.HorizontalAlignment = HorizontalAlignment.Left;
                lbBlueAmpl.Margin = new Thickness(800, cnvChart.ActualHeight - (stepVertical * yPos), 0, 0);
                lbBlueAmpl.FontWeight = FontWeights.Bold;
                cnvChart.Children.Add(lbBlueAmpl);
            }
        }

        #endregion Public Methods

        #region Window Events

        private void UserControl_Loaded(object sender, RoutedEventArgs e)
        {
            if (!initialized)
            {
                DrawGrid();
                initialized = true;
            }
        }

        #endregion Window Events

        private void btConfig_Click(object sender, RoutedEventArgs e)
        {
        }
    }
}