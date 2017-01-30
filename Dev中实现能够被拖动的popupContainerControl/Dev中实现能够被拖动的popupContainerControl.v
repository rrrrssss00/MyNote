 
        bool dragging = false;
        Point mouseOff;
        private void popupContainerControl1_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Right)
            {
                mouseOff = new Point(e.X, e.Y); //得到变量的值
                dragging = true;                  //点击左键按下时标注为true;
            }
        }
 
        private void popupContainerControl1_MouseUp(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Right)
            {
                dragging = false;                  //点击左键按下时标注为true;
            }
        }
 
        private void popupContainerControl1_MouseMove(object sender, MouseEventArgs e)
        {
            if (dragging)
            {
                Point mouseSet = new Point(e.X, e.Y);
 
                Point newLoc = new Point(popupContainerControl1.Location.X + mouseSet.X - mouseOff.X,
                        popupContainerControl1.Location.Y + mouseSet.Y - mouseOff.Y);
                popupContainerControl1.Location = newLoc;               
            }
        }
