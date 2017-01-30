DevExpress XtraGrid的功能实在强大，刚使用的时候看到一大片属性设置，分不清东南西北，参照demo和使用中的一些经验，记录一下使用方法。现在数据库访问都使用ORM技术了，对于DataSouce绑定以下是以IList为说明对象。
 
控件基本定义 DevExpress.XtraGrid.GridControl gridControl1;
 
1、 数据绑定（IList）
 
DevExpress.XtraGrid.Views.Grid.GridView gridView1;
 
IList<MyClass> list = new BindingList<MyClass>();
 
//初始list
 
list.Add(A);
 
list.Add(B);
 
………..
 
gridControl1.DataSource = list;
 
2、 在Grid上编辑数据
 
修改属性gridView1.OptionsView.NewItemRowPosition，设为Top或Bottom可以在Grid上添加数据。
 
（在 demo中原文：a record object must be inherited from the IEditableObject class if you need the ability to cancel newly added records via the grid）
 
译：如果你需要通过gird取消新建的记录，你的记录对象必须实现IEditableObject
 
（注：在测试中，感觉不需要继承IEditableObject，在grid编辑后也能实现取消。demo通过实现IEditableObject的 BeginEdit、CancelEdit方法，数据编辑后恢复特定数据。不使用grid直接修改数据，可以考虑这种恢复原数据的方法。）
 
3、 修改列（Column）格式
 
DevExpress.XtraGrid.Columns.GridColumn col = gridView1.Columns[0];
 
数据对齐方式 col.AppearanceCell.TextOptions.HAlignment， 默认值Default，可选值Default/Near/Center/Far。
 
说明：以下情况是基于从左到右的文字排列；若是从右到左，用法相反。
 
Default：数据默认的对齐方式
 
Near：左对齐
 
Center：居中对齐
 
Far：右对齐
 
列标题 col.Caption
 
对应绑定数据的属性 col.FieldName
 
排列顺序 col.VisibleIndex
 
格式化显示数据
 
Col.DisplayFormat.FormatType
 
Col.DisplayFormat.Format
 
Col.DisplayFormat.FormatString
 
区别：FormatType/FormatString 使用当前系统的语言区域设置，Format使用特定的[url=ms-help://MS.VSCC.v80/MS.VSIPCC.v80 /DevExpress.NETv8.2/DevExpress.XtraData/DevExpressUtilsFormatInfo_FormatTypetopic.htm##]System.IFormatProvider[/url]设置。
（原文注释：Use the FormatType and [url=ms-help://MS.VSCC.v80/MS.VSIPCC.v80/DevExpress.NETv8.2/DevExpress.XtraData/DevExpressUtilsFormatInfo_FormatStringtopic.htm]FormatString[/url] properties to format values based on the current language and regional settings (culture). FormatType specifies the type of values to be formatted. [url=ms-help://MS.VSCC.v80/MS.VSIPCC.v80/DevExpress.NETv8.2/DevExpress.XtraData/DevExpressUtilsFormatInfo_FormatStringtopic.htm]FormatString[/url] specifies a format pattern appropriate for the current FormatType value. You can refer to the Standard Numeric Format Strings and Date and Time Format Strings topics in MSDN for information on format specifiers.
 
Setting the FormatType property changes the format provider used when formatting values by the [url=ms-help://MS.VSCC.v80/MS.VSIPCC.v80/DevExpress.NETv8.2/DevExpress.XtraData/DevExpressUtilsFormatInfo_GetDisplayTexttopic.htm]GetDisplayText[/url] function. Format providers supply information such as the character to use as the decimal point when formatting numeric strings and the separation character to use when formatting a [url=ms-help://MS.VSCC.v80/MS.VSIPCC.v80/DevExpress.NETv8.2/DevExpress.XtraData/DevExpressUtilsFormatInfo_FormatTypetopic.htm##]System.DateTime[/url] object. The [url=ms-help://MS.VSCC.v80/MS.VSIPCC.v80/DevExpress.NETv8.2/DevExpress.XtraData/DevExpressUtilsFormatInfo_Formattopic.htm]Format[/url] property specifies the format provider to use.
 
You can change the [url=ms-help://MS.VSCC.v80/MS.VSIPCC.v80/DevExpress.NETv8.2/DevExpress.XtraData/DevExpressUtilsFormatInfo_Formattopic.htm]Format[/url] property explicitly by assigning a [url=ms-help://MS.VSCC.v80/MS.VSIPCC.v80/DevExpress.NETv8.2/DevExpress.XtraData/DevExpressUtilsFormatInfo_FormatTypetopic.htm##]System.IFormatProvider[/url] object. This can be useful if you wish to format values according to a specific culture (not the current one). In this case, you also need to set the FormatType property to [url=ms-help://MS.VSCC.v80/MS.VSIPCC.v80/DevExpress.NETv8.2/DevExpress.XtraData/DevExpressUtilsFormatTypeEnumtopic.htm]FormatType.Custom[/url].）
 
4、 使用Grid内置导航栏
 
gridControl1.UseEmbeddedNativgator=True
 
设定内置导航栏按钮其他属性 gridControl1.EmbeddedNavigator
 
5、 GridView内置方式编辑数据
 
禁止编辑数据 gridView1.OptionsBehavior.Editable = False，默认是True 可编辑。
 
Gridview内置数据编辑器显示方式 gridView1.OptionsBehavior.EditorShowMode，可选值Default/ MouseDown/MouseUp/ Click。
 
说明：
 
Default 多选Cell相当于Click，单选Cell相当于MouseDown
 
MouseDown 在单元格内按下鼠标键时打开内置编辑器
 
MouseUp 在单元格内释放鼠标键时打开内置编辑器
 
Click 在不是编辑状态，但获得焦点的单元格中点击时打开编辑器。点击非焦点单元格时，首先会切换焦点，再点击时才打开编辑器
 
6、 设定GrideView单元格的内置编辑器
 
在Run Designer的Columns选中需要变更编辑方式的Column，在ColumnEdit 属性的下拉菜单中选择编辑数据使用的控件。
 
例1：Person表的CountryID字段的值来自Country表，使用下拉列表显示CountryName编辑
 
修改CountryIDColumn.ColumnEdit值，选new->LookupEdit，默认命名为 repositoryItemLookUpEdit1。展开ColumnEdit属性，将DisplayMember 设为CountryName，DropDownRows是下拉列表的行数，ValueMember设为CountryID。
 
代码中添加：
 
//init data
 
repositoryItemLookUpEdit1.DataSource = ds.Tables[Country];
 
例2：字段Age是整型，需要使用SpinEdit编辑
 
修改AgeColumn.ColumnEdit值，选new->SpinEdit。展开ColumnEdit属性，修改MaxValue、MinValue设定最大、最小值。运行时Age的取值只能在MaxValue至MinValue之间选值。s
 
7、 GridView调节行高显示大文本
 
默认情况下gridview已单行方式显示，过长的文本只能显示开头部分，鼠标停留在单元格上方有ToolTip显示所有文本。在文本单元格的右边两个按钮供切换显示上下行。若需要在单元格变更行高显示所有文本。使用
 
gridView1.OptionsView.RowAutoHeight = True;
 
gridView1.LayoutChanged();
 
也可以通过事件判断文本内容改变行高
 
private void gridView1_CalcRowHeight(object sender,DevExpress.XtraGrid.Views.Grid.RowHeightEventArgs e)
 
{
 
if(e.RowHandle >= 0)
 
e.RowHeight = (int)gridView1.GetDataRow(e.RowHandle)["RowHeight"];
 
}
 
8、 数据导出
 
XtraGrid支持Html、Xml、Txt、Xsl导出，对应的导出器是ExportHtmlProvider、ExportXmlProvider、ExportTxtProvider、ExportXslProvider
 
例：使用html格式导出数据
 
……
 
IExportProvider provider = new ExprotHtmlProvider(filename);
 
ExportTo(provider);
 
……
 
private void ExportTo(IExportProvider provider) {
 
            Cursor currentCursor = Cursor.Current;
 
            Cursor.Current = Cursors.WaitCursor;
 
            this.FindForm().Refresh();
 
            BaseExportLink link = gridView1.CreateExportLink(provider);
 
            (link as GridViewExportLink).ExpandAll = false;
 
            link.Progress += new DevExpress.XtraGrid.Export.ProgressEventHandler(Export_Progress);//进度条事件
 
            link.ExportTo(true);
 
            provider.Dispose();
 
            link.Progress -= new DevExpress.XtraGrid.Export.ProgressEventHandler(Export_Progress);
 
            Cursor.Current = currentCursor;
 
 
}
 
9、 焦点单元格显示方式
 
GrideView默认的焦点单元格显示方式是整行选中，焦点单元格高亮。可以调整以下属性进行修改
 
gridView1.FocusRectStyle ：焦点绘画方式 默认DrawFocusRectStyle.CellFocus（单元格）/ DrawFocusRectStyle.RowFocus（行）/ DrawFocusRectStyle.None（不绘画）
 
bool gridView1.OptionsSelection.EnableAppearanceFocusedCell ：是否焦点显示选中的单元格
 
bool gridView1.OptionsSelection.EnableAppearanceFocusedRow ：是否焦点显示选中的行
 
bool gridView1.OptionsSelection.InvertSelection ：是否反显示
 
bool gridView1.OptionsSelection.MultiSelect：是否使用多选
 
 
10、
显示非数据源的数据
 
可以在GrideView上增加数据源没有的列，如合计、日期、序号或其他数据源等。
 
方法一：实现CustomColumnDisplayText事件（只能用于显示）
 
以下例子在bandedGridColumn1上显示 FirstName+LastName
 
bandedGridColumn1.OptionsColumn.AllowEdit = false;
 
private void bandedGridView1_CustomColumnDisplayText(object sender, DevExpress.XtraGrid.Views.Base.CustomColumnDisplayTextEventArgs e)
 
  {
 
     if(e.Column.Equals(bandedGridColumn1))
 
{
 
         DataRow row = bandedGridView1.GetDataRow(e.RowHandle);
 
         e.DisplayText = string.Format("{0} {1}", row["FirstName"], row["LastName"]);
 
     }
 
}
 
方法二： 设定列的UnboundType，并实现CustomUnboundColumnData事件（可修改值）
 
以下例子演示DateTime/Int/String 绑定到数据列上显示。当修改 GrideView上的值时，将修改同步到原数组中。
 
bandedGridColumn4.UnboundType = DevExpress.Data.UnboundColumnType.DateTime;
 
bandedGridColumn5.UnboundType = DevExpress.Data.UnboundColumnType.Integer;
 
bandedGridColumn6.UnboundType = DevExpress.Data.UnboundColumnType.String;
 
private void bandedGridView1_CustomUnboundColumnData(object sender, DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs e) {
 
              if(array == null) return;
 
              if(e.ListSourceRowIndex >= array.Count) return;
 
              Record rec = array[e.ListSourceRowIndex] as Record;
 
              if(rec == null) return;
 
              switch(e.Column.UnboundType) {
 
                   case UnboundColumnType.DateTime:
 
                       if(e.IsGetData)
 
                            e.Value = rec.Date;
 
                       else rec.Date = (DateTime)e.Value;
 
                       break;
 
                   case UnboundColumnType.Integer:
 
                       if(e.IsGetData)
 
                            e.Value = rec.Count;
 
                       else rec.Count = (Int32)e.Value;
 
                       break;
 
                   case UnboundColumnType.String:
 
                       if(e.IsGetData)
 
                            e.Value = rec.Comment;
 
                       else rec.Comment = e.Value.ToString();
 
                       break;
 
              }
 
         }
