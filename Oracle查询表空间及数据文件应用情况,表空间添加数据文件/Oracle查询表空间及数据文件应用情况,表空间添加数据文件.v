表空间:
select
a.a1 表空间名称,
c.c2 类型,
c.c3 区管理,
b.b2/1024/1024 表空间大小M,
(b.b2-a.a2)/1024/1024 已使用M,
substr((b.b2-a.a2)/b.b2*100,1,5) 利用率
from
(select tablespace_name a1, sum(nvl(bytes,0)) a2 from dba_free_space group by tablespace_name) a,
(select tablespace_name b1,sum(bytes) b2 from dba_data_files group by tablespace_name) b,
(select tablespace_name c1,contents c2,extent_management c3 from dba_tablespaces) c
where a.a1=b.b1 and c.c1=b.b1;
 
数据文件:
select
b.file_name 物理文件名,
b.tablespace_name 表空间,
b.bytes/1024/1024 大小M,
(b.bytes-sum(nvl(a.bytes,0)))/1024/1024 已使用M,
substr((b.bytes-sum(nvl(a.bytes,0)))/(b.bytes)*100,1,5) 利用率
from dba_free_space a,dba_data_files b
where a.file_id=b.file_id
group by b.tablespace_name,b.file_name,b.bytes
order by b.tablespace_name

表空间添加数据文件：
alter tablespace HYSYS add datafile '+DATA/agrs/datafile/hysys3.dbf' size 5g autoextend on next 1g maxsize unlimited;

(add datafile 后面的文件名可以忽略，数据库会自动添加名称)

查看表空间中空间详细的使用情况
首先，查看哪些Segment占用空间最大：select segement_name,sum(bytes)/1024/1024 from user_extents group by Segment_name
从结果中查找到Segment_name后，查看这些Segment都是什么类型，select * from user_segments，
如果是Table/Index/LOBINDEX，那么就表示这些本身占用了较大的空间
如果是LOBSEGMENT，可以去select * from user_lobs，查看这个Segment对应的是哪个表的哪个字段

