 OracleCommand cmd = new OracleCommand(@"SELECT a.geometry.get_wkb(), a.blname FROM dkmt.pol_bundesland a WHERE ((a.blname = '12.Bundesland'))", conn);       
            //OracleCommand cmd = new OracleCommand(@"SELECT a.geometry.get_wkt(), a.blname FROM dkmt.pol_bundesland a WHERE ((a.blname = '12.Bundesland'))", conn);       
        conn.Open();           
        byte[] wkb = (byte[])cmd.ExecuteScalar();
        //string wkt = (string)cmd.ExecuteScalar();
 
 
 
        OracleCommand cmdGeom = new OracleCommand(@"insert into dkmt.pol_bundesland values (sdo_geometry(:geom,31297),'14.Bundesland',14)", conn);
        OracleParameter p1 = new OracleParameter(":geom",OracleDbType.Blob);
            p1.Value = wkb;
            cmdGeom.Parameters.Add(p1);

来源： <http://nettopologysuite.googlecode.com/svn/branches/v2.0/NetTopologySuite.Samples.Shapefiles/blob/queries.txt>
  

其中31297是SDO_SRID（也就是坐标系编号）的值，可以通过 select a.geometry.SDO_SRID from ....得到

