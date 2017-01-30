 private void gridView1_ShowFilterPopupListBox(object sender, DevExpress.XtraGrid.Views.Grid.FilterPopupListBoxEventArgs e)
        {           
            e.ComboBox.Items.Clear();
            //e.ComboBox.Items.Add(new DevExpress.XtraGrid.Views.Grid.FilterItem("筛选", new DevExpress.XtraGrid.Columns.ColumnFilterInfo(DevExpress.XtraGrid.Columns.ColumnFilterType.Custom,
               // null, "[" + e.Column.FieldName+ "] LIKE '%lo%'", e.Column.Caption+"包含'lo'")));
            DevExpress.XtraGrid.Views.Grid.FilterItem tmpItem = new DevExpress.XtraGrid.Views.Grid.FilterItem(e.Column.Caption+"筛选", null);
            e.ComboBox.Items.Add(tmpItem);
            e.ComboBox.SelectedIndexChanged += new EventHandler(ComboBox_SelectedIndexChanged);
        }
 
        void ComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            //DevExpress.XtraEditors.Repository.RepositoryItemComboBox tmpBox = (DevExpress.XtraEditors.Repository.RepositoryItemComboBox)sender;
            //if(((ComboBoxEdit)sender).EditValue.ToString() == "筛选") 
            if(((ComboBoxEdit)sender).EditValue is DevExpress.XtraGrid.Views.Grid.FilterItem)
            {
                DevExpress.XtraGrid.Views.Grid.FilterItem filterItem = (DevExpress.XtraGrid.Views.Grid.FilterItem)((ComboBoxEdit)sender).EditValue;
                if (filterItem.Text == "用户筛选")
                {
                    filterItem.Value = new ColumnFilterInfo("[ShippedDate] > [RequiredDate] AND [ShipCountry] = 'USA'")
                }
            }
 
        }
