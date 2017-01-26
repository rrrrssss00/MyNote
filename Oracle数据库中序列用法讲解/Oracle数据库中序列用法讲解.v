Oracle数据库中序列用法讲解
2008-10-20 09:51 樊斌 IT专家网 字号：T | T

序列(SEQUENCE)是序列号生成器，可以为表中的行自动生成序列号，产生一组等间隔的数值(类型为数字)。其主要的用途是生成表的主键值，可以在插入语句中引用，也可以通过查询检查当前值，或使序列增至下一个值。
AD：
序列(SEQUENCE)是序列号生成器，可以为表中的行自动生成序列号，产生一组等间隔的数值(类型为数字)。其主要的用途是生成表的主键值，可以在插入语句中引用，也可以通过查询检查当前值，或使序列增至下一个值。
创建序列需要CREATE SEQUENCE系统权限。序列的创建语法如下：
CREATE SEQUENCE 序列名
[INCREMENT BY n]
[START WITH n]
[{MAXVALUE/ MINVALUE n|NOMAXVALUE}]
[{CYCLE|NOCYCLE}]
[{CACHE n|NOCACHE}];
INCREMENT BY 用于定义序列的步长，如果省略，则默认为1，如果出现负值，则代表序列的值是按照此步长递减的。
START WITH 定义序列的初始值(即产生的第一个值)，默认为1。
MAXVALUE 定义序列生成器能产生的最大值。选项NOMAXVALUE是默认选项，代表没有最大值定义，这时对于递增序列，系统能够产生的最大值是10的27次方;对于递减序列，最大值是-1。
MINVALUE定义序列生成器能产生的最小值。选项NOMAXVALUE是默认选项，代表没有最小值定义，这时对于递减序列，系统能够产生的最小值是?10的26次方;对于递增序列，最小值是1。
CYCLE和NOCYCLE 表示当序列生成器的值达到限制值后是否循环。CYCLE代表循环，NOCYCLE代表不循环。如果循环，则当递增序列达到最大值时，循环到最小值;对于递 减序列达到最小值时，循环到最大值。如果不循环，达到限制值后，继续产生新值就会发生错误。
CACHE(缓冲)定义存放序列的内存块的大小，默认为20。NOCACHE表示不对序列进行内存缓冲。对序列进行内存缓冲，可以改善序列的性能。
删除序列的语法是：
DROP SEQUENCE 序列名;
其中：
删除序列的人应该是序列的创建者或拥有DROP ANY SEQUENCE系统权限的用户。序列一旦删除就不能被引用了。
序列的某些部分也可以在使用中进行修改，但不能修改SATRT WITH选项。对序列的修改只影响随后产生的序号，已经产生的序号不变。修改序列的语法如下：
创建和删除序列
例1：创建序列：
CREATE SEQUENCE ABC INCREMENT BY 1 START WITH 10 MAXVALUE 9999999 NOCYCLE NOCACHE;
执行结果
序列已创建。
步骤2：删除序列：
DROP SEQUENCE ABC;
执行结果：
序列已丢弃。
说明：以上创建的序列名为ABC，是递增序列，增量为1，初始值为10。该序列不循环，不使用内存。没有定义最小值，默认最小值为1，最大值为9 999 999。
序列的使用
如果已经创建了序列，怎样才能引用序列呢?方法是使用CURRVAL和NEXTVAL来引用序列的值。
在编号的过程中，产生间隙的原因多种多样。如果一个存储过程从一个序列中挑选某个数字，定为本地变量，但是从来不用它，这个数字就丢失了。它将不能 再返回到原序列中，结果就造成数值序列中存在一个间隙。关系型数据库模型中不必担心这一点。但是有时候人们在意这一点，这些人想知道是哪些数字丢失了。
调用NEXTVAL将生成序列中的下一个序列号，调用时要指出序列名，即用以下方式调用:
序列名.NEXTVAL
CURRVAL用于产生序列的当前值，无论调用多少次都不会产生序列的下一个值。如果序列还没有通过调用NEXTVAL产生过序列的下一个值，先引用CURRVAL没有意义。调用CURRVAL的方法同上，要指出序列名，即用以下方式调用:
序列名.CURRVAL.
产生序列的值。
步骤1：产生序列的第一个值：
SELECT ABC.NEXTVAL FROM DUAL;
执行结果：
NEXTVAL
------------------
10
步骤2：产生序列的下一个值：
SELECT ABC.NEXTVAL FROM DUAL;
执行结果：
NEXTVAL
-------------------
11
产生序列的当前值：
SELECT ABC.CURRVAL FROM DUAL;
执行结果：
CURRVAL
--------------------
11
说明：第一次调用NEXTVAL产生序列的初始值，根据定义知道初始值为10。第二次调用产生11，因为序列的步长为1。调用CURRVAL，显示 当前值11，不产生新值。Oracle的解析函数为检查间隙提供了一种要快捷得多的方法。它们使你在使用完整的、面向集合的SQL处理的同时，仍然能够看 到下一个行(LEAD)或者前一行(LAG)的数值。
查看序列
同过数据字典USER_OBJECTS可以查看用户拥有的序列。
通过数据字典USER_SEQUENCES可以查看序列的设置。
例：查看用户的序列：
SELECT SEQUENCE_NAME,MIN_VALUE,MAX_VALUE,INCREMENT_BY,LAST_NUMBER FROM
USER_SEQUENCES;
 
执行结果：
SEQUENCE_NAME MIN_VALUE MAX_VALUE INCREMENT_BY LAST_NUMBER
说明：当前用户拥有两个序列：ABC和BOOKID。

来源： <http://database.51cto.com/art/200810/93620_all.htm>
 

