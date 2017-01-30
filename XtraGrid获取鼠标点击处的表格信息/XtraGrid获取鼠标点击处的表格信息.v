鼠标事件里(要能够获取到鼠标位置的事件,MouseDown/UP等)
 
GridHitInfo gridHI = gridView1.CalcHitInfo(e.Location);
 
从这个gridHI中,可以获取到点击位置的rowindex,列信息,文本,以及该点是否是表头,是否是单元格,是否是....
 
