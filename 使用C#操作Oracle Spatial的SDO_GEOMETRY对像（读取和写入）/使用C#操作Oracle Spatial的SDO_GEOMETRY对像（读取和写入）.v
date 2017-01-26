首先，这个需要使用ODAC，也就是Oracle.DataAccess.dll，新出的托管Oracle.ManagedDataAccess.dll不支持Object Type，无法使用
地址：http://www.oracle.com/technetwork/topics/dotnet/utilsoft-086879.html

代码见附件，大致思路是：
先根据SDO_GEOMETRY对象的内容，在C#中构建一个对应的类，然后在读取和写入时使用OracleParameter来操作这个类的对象，达到读取和写入数据库SDO_GEOMETRY对象的目的

类名为SdoGeometry，主要代码如下（其中还用到了自定义的SdoPoint，OracleArrayTypeFactory和OracleCustomTypeBase类，其代码见附件的相应文件）
[OracleCustomTypeMappingAttribute("MDSYS.SDO_GEOMETRY")]
  public class SdoGeometry : OracleCustomTypeBase<SdoGeometry>
  {
    private enum OracleObjectColumns { SDO_GTYPE, SDO_SRID, SDO_POINT, SDO_ELEM_INFO, SDO_ORDINATES }
    private decimal? sdo_Gtype;
    [OracleObjectMappingAttribute(0)]
    public decimal? Sdo_Gtype
    {
      get { return sdo_Gtype; }
      set { sdo_Gtype = value; }
    }
    private decimal? sdo_Srid;
    [OracleObjectMappingAttribute(1)]
    public decimal? Sdo_Srid
    {
      get { return sdo_Srid; }
      set { sdo_Srid = value; }
    }
    private SdoPoint point;
    [OracleObjectMappingAttribute(2)]
    public SdoPoint Point
    {
      get { return point; }
      set { point = value; }
    }
    private decimal[] elemArray;
    [OracleObjectMappingAttribute(3)]
    public decimal[] ElemArray
    {
      get { return elemArray; }
      set { elemArray = value; }
    }
    private decimal[] ordinatesArray;
    [OracleObjectMappingAttribute(4)]
    public decimal[] OrdinatesArray
    {
      get { return ordinatesArray; }
      set { ordinatesArray = value; }
    }
    [OracleCustomTypeMappingAttribute("MDSYS.SDO_ELEM_INFO_ARRAY")]
    public class ElemArrayFactory : OracleArrayTypeFactoryBase<decimal> {}
    [OracleCustomTypeMappingAttribute("MDSYS.SDO_ORDINATE_ARRAY")]
    public class OrdinatesArrayFactory : OracleArrayTypeFactoryBase<decimal> {}
    public override void MapFromCustomObject()
    {
      SetValue((int)OracleObjectColumns.SDO_GTYPE, Sdo_Gtype);
      SetValue((int)OracleObjectColumns.SDO_SRID, Sdo_Srid);
      SetValue((int)OracleObjectColumns.SDO_POINT, Point);
      SetValue((int)OracleObjectColumns.SDO_ELEM_INFO, ElemArray);
      SetValue((int)OracleObjectColumns.SDO_ORDINATES, OrdinatesArray);
    }
    public override void MapToCustomObject()
    {
      Sdo_Gtype = GetValue<decimal?>((int)OracleObjectColumns.SDO_GTYPE);
      Sdo_Srid = GetValue<decimal?>((int)OracleObjectColumns.SDO_SRID);
      Point = GetValue<SdoPoint>((int)OracleObjectColumns.SDO_POINT);
      ElemArray = GetValue<decimal[]>((int)OracleObjectColumns.SDO_ELEM_INFO);
      OrdinatesArray = GetValue<decimal[]>((int)OracleObjectColumns.SDO_ORDINATES);
    }
  }

从数据库里读取的代码为（表中只有两列，id列为number类型,geo列为SDO_GEOMTRY类型）：
         OracleCommand cmd = new OracleCommand()
         cmd.Connection = con; 
          cmd.CommandType = CommandType.Text;
         cmd.CommandText = " select id,geo from geoinfo ";
          using (OracleDataReader readerGeoInfo = cmd.ExecuteReader())
          {
            while (readerGeoInfo.Read())
            {
              GeoInfo geoInfo = new GeoInfo();
              if (!readerGeoInfo.IsDBNull(0))
              {
                geoInfo.Id = readerGeoInfo.GetDecimal(0);
              }
              if (!readerGeoInfo.IsDBNull(1))
              {
                geoInfo.Geo = (SdoGeometry)readerGeoInfo.GetValue(1); 
              }
              geoInfoList.Add(geoInfo);
            }
            readerGeoInfo.Close();
          }

插入的代码为：
         cmd.CommandText = " insert into geoinfo values (geoinfo_seq.nextval,:param) ";
          cmd.Parameters.Clear();
          OracleParameter oracleParameterGeo = new OracleParameter();
          oracleParameterGeo.OracleDbType = OracleDbType.Object;
          oracleParameterGeo.UdtTypeName = "MDSYS.SDO_GEOMETRY";
          cmd.Parameters.Add(oracleParameterGeo);
          //creating point
          SdoGeometry geoPoint = new SdoGeometry();
          geoPoint.Sdo_Gtype = 2001; 
          geoPoint.Point = new SdoPoint();
          geoPoint.Point.X = 200;
          geoPoint.Point.Y = 400;
          oracleParameterGeo.Value = geoPoint;
          //insert point in table geoinfo
          cmd.ExecuteNonQuery();
          //creating polygon
          SdoGeometry geoPolygon = new SdoGeometry();
          geoPolygon.Sdo_Gtype = 2003;
          geoPolygon.ElemArray = new decimal[] { 1, 1003, 1 };
          geoPolygon.OrdinatesArray = new decimal[] { 3, 3, 3, 10, 10, 10, 10, 3, 3, 3 };
          oracleParameterGeo.Value = geoPolygon; 
          //insert polygon into table geoinfo 
          cmd.ExecuteNonQuery();

在实际使用中，使用DataAdapter的Fill方法将Select  *的查询结果放到DataTable中时，如果已经定义了SdoGeometry的类，查询结果会自动地将DataTable的那列认为是SdoGeometry，非常方便 ，例如 

 OracleDataAdapter mAdp = new OracleDataAdapter("select * from geoinfo", con);
 DataTable mDst = new DataTable();
 mAdp.Fill(mDst);

此时mDst的第二列数据类型即为SdoGeometry              



