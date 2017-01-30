一个程序中需要进行大量的运算,并且需要在运算过程中支持用户一定的交互,为了获得更好的用户体验,使用BackgroundWorker来完成这一功能.
 
基本操作:
bgw.RunWorkerAsync()        :
    开始后台运行执行,
    该函数后将触发bgw.DoWorker事件,需要执行的操作写在DoWorker事件响应函数里,
    该函数也可以加参数,参数从DoWorker事件处理函数的e.Arguement里获取
 
bgw.CancelAsync()                :
    申请后台程序停止,
    注意该函数不能实际停止后台程序,只能将bgw的CancellationPending 值设为true,需要自己在后台运行的程序中判断这一值,进而停止后台程序的运行.
    注意本方法使用前,需要将bgw的WorkerSupportsCancellation 值设为true,否则将不起作用.
 
bgw.ReportProgress()        :
    在后台程序中调用,向主线程传送进度信息,
    可以带一个或两个参数,一个为INT类型的进度(0~100),一个为自定义类型的参数,可以传任意信息.
    调用后,将触发bgw.ProgressChanged事件,可以将界面变化的代码写在该事件响应函数中,之前提到的两个参数均可从bgw.ProgressChanged事件响应函数的参数e中获取,分别为e.ProgressPercentage和e.UserState.    
    注意本方法使用前,需要将bgw的WorkerReportsProgress值设为true,否则将不会触发事件.
 
 
开始后台运行:
            bgw= new BackgroundWorker();
            bgw.WorkerSupportsCancellation = true;
            bgw.WorkerReportsProgress = true;
 
            bgw.DoWork += new DoWorkEventHandler(bgw_DoWork);
            bgw.ProgressChanged += new ProgressChangedEventHandler(bgw_ProgressChanged);
            bgw.RunWorkerCompleted += new RunWorkerCompletedEventHandler(bgw_RunWorkerCompleted);
 
            bgw.RunWorkerAsync();
 
DoWork事件处理函数:
 void bgw_DoWork(object sender, DoWorkEventArgs e)
        {
            StartProgress();
 
        }  
 
WorkerCompleted事件处理函数(该函数在后台处理完成后被触发)
 void bgw_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            MessageBox.Show("处理完成");
        }
 
ProgressChanged事件处理函数,
 void bgw_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            if (e.UserState is int)
            {
                progressBar1.Value = (int)e.ProgressPercentage;
                label2.Text = e.UserState.ToString();
            }
            else if (e.UserState is List<object>)
            {
                List<object> tmp = (List<object>)e.UserState;
                progressBar1.Value = e.ProgressPercentage;
                label2.Text = tmp[0].ToString();
                this.label1.Text = tmp[1].ToString();
                this.listBox1.Items.Insert(0, tmp[2]);
            }
        }
 
 
后台运行的代码
 private void StartProgress()        
{
    //do sth
 
    bgw.ReportProgress(per,paraInt);
}
