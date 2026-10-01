using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace ccd_test.Models
{
    public class OscilloscopeConfig : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        public void OnPropertyChanged([CallerMemberName] string propertyName = null)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        public bool ShowR { get; set; }
        public bool ShowG { get; set; }
        public bool ShowB { get; set; }

        public OscilloscopeConfig()
        {
            ShowR = true;
            ShowG = true;
            ShowB = true;
        }
    }
}
