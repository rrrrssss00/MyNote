在OpenTK里的代码:

注意:,保存时,需要在SwapBuffer前保存,之后保存为全黑图像

private void myControl1_Paint(object sender, PaintEventArgs e)
        {
            if (!loaded) // Play nice
                return;
            
            GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit);
            GL.MatrixMode(MatrixMode.Modelview);
            GL.LoadIdentity();
            GL.Color3(Color.Yellow);
            GL.Begin(BeginMode.Triangles);
            GL.Vertex2(10, 20);
            GL.Vertex2(100, 20);
            GL.Vertex2(100, 50);
            GL.End();
            
            //myControl1.SwapBuffers();
            if (needScr)
            {
                needScr = false;
                Bitmap bm = new Bitmap(myControl1.ClientSize.Width, myControl1.ClientSize.Height);

                System.Drawing.Imaging.BitmapData data =
                    bm.LockBits(myControl1.ClientRectangle, System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format24bppRgb);
                GL.ReadPixels(0, 0, myControl1.ClientSize.Width, myControl1.ClientSize.Height, PixelFormat.Bgr, PixelType.UnsignedByte, data.Scan0);
                GL.Finish();
                bm.UnlockBits(data);
                bm.RotateFlip(RotateFlipType.RotateNoneFlipY);
                bm.Save(Application.StartupPath + "\\aa.bmp");
            }
           
            GraphicsContext.CurrentContext.SwapBuffers();
        }

 private void button1_Click(object sender, EventArgs e)
        {
            needScr = true;
            myControl1.Invalidate();
}
