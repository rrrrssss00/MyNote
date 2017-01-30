使用默认的EventHandler时,可以不用自己声明委托delegate,直接将EventHandler作为委托使用即可,用法如下:
 public partial class Form2 : Form
    {
        public event EventHandler tmpEvent;
        public Form2()
        {
            InitializeComponent();
        }
        private void button1_Click(object sender, EventArgs e)
        {
            tmpEvent("testMsg", null);
        }
        private void Form2_Load(object sender, EventArgs e)
        {
            tmpEvent += new EventHandler(tmpEvent_Function);
        }
        private void tmpEvent_Function(object sender, EventArgs ex)
        {
            MessageBox.Show(sender.ToString());
        }
    }
 
该EventHandler还支持泛型,可对事件处理函数的参数(即函数传入的第二个参数)进行限制,用法如下:
 public partial class Form1 : Form
    {
        public event EventHandler<MyEventArgs> tmpEvent;
        public Form1()
        {
            InitializeComponent();
        }
        private void Form1_Load(object sender, EventArgs e)
        {
            tmpEvent += new EventHandler<MyEventArgs>(tmpEvent_Function);
        }
        private void button1_Click(object sender, EventArgs e)
        {
            MyEventArgs tmpEa = new MyEventArgs();
            tmpEa.msg = "msgPart2";
            tmpEvent("msgPart1", tmpEa);
        }
        private void tmpEvent_Function(object sender, MyEventArgs ex)
        {            
            MessageBox.Show(sender.ToString() + "\t" + ex.msg);
        }
    }
    public class MyEventArgs : EventArgs
    {
        public string msg = "";
    }
