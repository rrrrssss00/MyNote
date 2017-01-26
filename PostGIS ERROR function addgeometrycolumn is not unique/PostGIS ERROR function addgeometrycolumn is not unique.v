ERROR: function addgeometrycolumn is not unique
遇到42725错误，在新建PostGIS图层中提示addGeometryColumn函数不是唯一的，可能在参数调用上有易混淆的地方：


问题描述：
I am trying to use the following function;
SELECT Assign_vertex_id('ways', 0.00001, 'the_geom', 'gid')
but for some reason it is giving me the following error;
NOTICE:  CREATE TABLE will create implicit sequence "vertices_tmp_id_seq" for serial column "vertices_tmp.id"
CONTEXT:  SQL statement "CREATE TABLE vertices_tmp (id serial)"
PL/pgSQL function "assign_vertex_id" line 15 at EXECUTE statement
ERROR:  function addgeometrycolumn(unknown, unknown, integer, unknown, integer) is not unique
LINE 1: SELECT addGeometryColumn('vertices_tmp', 'the_geom', 4326, '...
               ^
HINT:  Could not choose a best candidate function. You might need to add explicit type casts.
QUERY:  SELECT addGeometryColumn('vertices_tmp', 'the_geom', 4326, 'POINT', 2)
CONTEXT:  PL/pgSQL function "assign_vertex_id" line 24 at EXECUTE statement

********** Error **********

ERROR: function addgeometrycolumn(unknown, unknown, integer, unknown, integer) is not unique
SQL state: 42725
Hint: Could not choose a best candidate function. You might need to add explicit type casts.
Context: PL/pgSQL function "assign_vertex_id" line 24 at EXECUTE statement
Now from what I found it has to be something with old PostGIS signatures around.Infect when I ran The following command;
select proname, proargnames from pg_proc where proname = 'addgeometrycolumn'; 
The result was this;
pg_proc returns 6 rows.

Three rows with column proargnames  returning a blank or (null) value
Can someone help me? Is it something that has to do with old postgis signitures? if so, how can I fix it?
Thanks
On StackOverflow

问题解决方案：
在调用时显式声明参数格式，例如：
SELECT addGeometryColumn(''::text,'foo'::text, 'geom'::text,0::int,'POINT'::text,2::int);
 

