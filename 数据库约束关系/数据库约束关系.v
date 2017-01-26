数据库之约束关系:
包括5种类型:
1、检查约束：通过在定义数据库表里，在字段级或者是在表级加入的检查约束，使其满足特定的要求。
比如以下的表定义：
CRATE TABLE student(id serial,name varchar(10),scrore integer CHECK (scrore > 0));定义分数不能小于0。
也可以定义表中几个字段之间的关系
2、非空约束：
列不能为空,直接在字段后面加上：NOT NULL。
3、唯一约束：
定义一个唯一约束,但是该列可以包括NULL值,且NULL值不进行唯一关系判断。直接在字段定义后加入UNIQUE即可定义一个唯一约束。
4、主键约束：
其实就是：唯一约束+非空约束。
5、外键约束：
定义表中的某一列A与另一列B（可以是本表或其它表，该列必须是唯一约束的列）有外键约束关系。
A中的值必须为B列中已经出现过的值，以保证数据库中记录的一致性。
当B列中的值删除或修改时，数据库会按照
添加外键约束时，可以指定该约束的删除和修改策略，即：若B列中某个值在A列中有对应的记录，那么当修改或删除这个值时A列中相应记录的处理策略：
SQL92标准中，有这几种策略：
    a:限制Restrict：这种方式不允许对被参考的记录的键值执行更新或删除的操作,在语句执行之前判断和报错
    b:不做操作No action：这种方式不允许对被参考的记录的键值执行更新或删除的操作,在语句执行之后判断和报错：Oracle默认是这种策略，在Oracle中，还能指定是否允许将约束条件检查延迟到该事务处理结束时
    c:置为空Set to null：当参考的数据被更新或者删除，那么所有参考它的外键值被置为空；该策略包括更新和删除两种情况，即DELETE SET TO NULL以及UPDATE SET TO NULL
    d:置为默认值Set to default：当参考的数据被更新或者删除，那么所有参考它的外键值被置为一个默认值；该策略包括更新和删除两种情况，即DELETE SET TO DEFAULT以及UPDATE SET TO DEFAULT
    e:级联Cascade：当参考的数据被更新，则参考它的值同样被更新，当参考的数据被删除，则参考它的子表记录也被删除；该策略包括更新和删除两种情况，即DELETE CASCADE以及UPDATE CASCADE
 
例：
SQL> ALTER TABLE table1 ADD CONSTRAINT foreignConstraint1
2 FOREIGN KEY (column1n1)
3 REFERENCES table2 (column2n1)
4 ON DELETE CASCADE;
 
注：在Oracle中，默认只支持3种约束策略NO ACTION、DELETE SET NULL和DELETE CASCADE    ，其它5种策略只能够通过使用触发器来实现

