第一步：让所有窗体都从DevExpress.XtraEditors.XtraForm继承。
　　第二步：添加两个引用：
　　DevExpress.BonusSkins.v8.1
　　DevExpress.OfficeSkins.v8.1
　　第三步：在软件的入口Program类的main函数的第一行代码前加上：
DevExpress.UserSkins.BonusSkins.Register();
DevExpress.UserSkins.OfficeSkins.Register();
DevExpress.Skins.SkinManager.EnableFormSkins();
Application.EnableVisualStyles();
Application.SetCompatibleTextRenderingDefault(false);
Application.Run(new FormMain());
　　第四步：每个窗口放个DefaultLookAndFeel控件，
　　第五步：软件往往有个设置皮肤的地方，这个地方往往是需要枚举出所有皮肤的，把皮肤全部枚举出来放到一个ComboBoxEdit中，代码如下：
foreach (DevExpress.Skins.SkinContainer skin in DevExpress.Skins.SkinManager.Default.Skins)
cmbAppStyle.Properties.Items.Add(skin.SkinName);
　　第六步：设置皮肤，怎样设置皮肤呢，只需设置每个窗口的DefaultLookAndFeel即可，代码如下：
　　this.defaultLookAndFeel1.LookAndFeel.SkinName = cmbAppStyle.EditValue.ToString();
　　
