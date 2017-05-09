附件为破解的Aspose.Imaging的Dll，以及破解方法

读取及导出方式如下
 public Form1()
        {
            InitializeComponent();
            LicenseHelper.ModifyInMemory.ActivateMemoryPatching();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            Aspose.Imaging.License aa = new Aspose.Imaging.License();
            bool aaisLic = aa.IsLicensed;
            //Aspose.Imaging.Image image = Aspose.Imaging.Image.Load(@"C:\wyz\WorkSpace\jpd\TestPsdRead\SampleData\aaa.psd");
            Aspose.Imaging.Image image = Aspose.Imaging.Image.Load(@"C:\wyz\WorkSpace\jpd\TestPsdRead\SampleData\江西mosaic.psb");
            var psdImage = (Aspose.Imaging.FileFormats.Psd.PsdImage)image;
            var pngOptions = new Aspose.Imaging.ImageOptions.PngOptions();
            pngOptions.ColorType = Aspose.Imaging.FileFormats.Png.PngColorType.TruecolorWithAlpha;

            for (int i = 0; i < psdImage.Layers.Length; i++)
            {
                psdImage.Layers[i].Save(@"C:\wyz\WorkSpace\jpd\TestPsdRead\SampleData\layer-" + i + ".png", pngOptions);
            }
        }

