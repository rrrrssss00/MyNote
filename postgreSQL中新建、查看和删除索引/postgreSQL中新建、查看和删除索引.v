postgre建索引方法：
单字段索引：
CREATE INDEX index_name ON table_name (field1);
联合索引：
CREATE INDEX index_name ON table_name (field1,field2);


查看索引
select * from pg_indexes where tablename='tbname';      或者     select * from pg_statio_all_indexes where relname='tbname';


删除索引
DROP INDEX index;
index是要删除的索引名
注意 ： 无法删除DBMS为主键约束和唯一约束自动创建的索引
