using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ccd_test.Util
{
    public class Averager
    {
        public double Average { get; set; }

        int size = 0;
        int sum = 0;

        public Queue<int> Values = new Queue<int>();

        public Averager(int size)
        {
            this.size = size;
        }

        public void AddValue(int value)
        {
            if (Values.Count >= size)
            {
                int last = Values.Dequeue();
                sum -= last;
            }

            sum += value;
            Values.Enqueue(value);

            Average = (double)sum / (double)Values.Count;
        }

        void Reset()
        {
            Values.Clear();
            sum = 0;
            Average = 0;

            for (int i = 0; i < size; i++)
            {
                Values.Enqueue(0);
            }
        }
    }
}
