之前在C#中使用OracleCommand中一般使用这种方式：
 
    comm.CommandText = "insert into " + sTab + " (" + sKeyField + "," + sBlobField + ") values(" + sKeyValue + ",?)";
                comm.Parameters.Add("m", OracleDbType.Blob, blob.Length).Value = blob;
                try
                {
                    return comm.ExecuteNonQuery();
                }
                catch (Exception)
                {
                    return 0;
                }
 
这段代码被如果被多次调用，那么只有第一次的赋值生效，即：comm.Parameters中以m为名称的参数，值永远是第一次赋的blob，
这时需要在Parameters.Add之前加入这样的语句
 
if(comm.Parameters.Contains("m"))
    comm.Parameters.RemoveAt("m"m);

