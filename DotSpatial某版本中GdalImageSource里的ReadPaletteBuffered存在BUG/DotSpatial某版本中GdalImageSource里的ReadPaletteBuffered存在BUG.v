1：
int width = numColumns;
 int height = numRows;
行列号写反了，上面是正确的写法

2：
Array.Copy(colorTable[r[col + row * width]], 0, vals, (row * width + col) * bpp, 4);

 (row * width + col) * bpp少加个括号

