Oracle 段(segment)区(extent)块(block)

从今天开始，第二次开始阅读oracle文档的b10743，《conceps》；不知道能不能给我新的收获。这本被oracle公司的大师级的人物 Michele Cyran等牛人所写，真是一本不错的书籍。可叹英文不太好，但努力，总会有收获的。还是从他的数据架构来说吧！
        
            （一）Data blocks ，Extents，Segment
    这就是他们之间的逻辑结构。
    先看Data blocks（也叫逻辑块，oracle块，页）吧，oracle存储数据都是在这些数据块中，一个数据块是磁盘上数据库物理空间一系列物理字节的组成。
    比Data blocks更高一层的逻辑数据块空间是extent，一个extent是由一系列临近的存储信息的数据块组成。
    最高一层的逻辑结构是segment，一个segment是同一表空间extents的一个集合。每一个segment有不同的数据结构。如每一个表的数据就存储在自己的data segment，每一个索引存储在自己的索引段，如果表或者索引是
是分区存储的，那么每一个分区都存储在他们各自的segment中。一个segment和他所有的extent都是在一个表空间中，并且一个segment可以跨越几个数据文件。。
    对于数据库来说，data block是oracle数据库中分配和私用的最小存储单元。但这仅仅对数据库来说，在物理层次，操作系统层次，所有的数据仍旧是按字节存储的。每一个操 作系统都有自己的块尺寸（block size），在oracle数据库中，数据块的大小都有参数db_block_size在创建数据库的时候来确定，他的数值应该是操作系统块尺寸的整数 倍。
    数据块都有这么几部分组成，块头部分，表目录，行目录，空闲空间，数据这几部分组成。块头主要包含两部分信息：块头地址和segment的类型，是数据表 还是索引；表目录主要包含块中有多少行数据。行目录主要包含每一行的物理地址。数据就很明显了，就是这个块包含的数据。这里边最奇妙的就是这个空闲空间， 它主要目的就是为varchar这个数据类型准备的，有两个阈值参数pctfree,pctused来控制此数据快移向那一个链表,这两个参数的设定主要 目的是为了避免行连接与行迁移，具体的又够一篇文章了，以后再写，^_^。
    在来说extent这个由一系列连续的data blocks组成。每当在数据库中创建一个表，那么分配给表的data segment分配一个包含若干数据库的初始的extent，虽然还没有插进去数据，但初始的extent已经做好了插入数据的准备。如果初始的 extent中的数据块已经满了，或者没有空间插入数据，那么他将会增量扩展。当然这只是对于串行执行的情况，对于并发就不合适了。一些存储参数控制着 oracle如何为每个段分配可用空间。当你使用create table创建一个表的时候，存储参数会将决定分配多少的可用空间或者限制此表最多可包含多少个extents，如果在创建表的时候没有定义这些参数，那 么将采用表空间定义的默认的存储参数。对于插入和删除都很频繁的表，DBA可以通过这个语句来收回无用的extent ，aler table table_name deallocate unused;

    下面来说segment，每一个segment都是一个表空间下有一系列extent组成的逻辑存储结构。如：当数据库用户创建一个表，那么oracle 将分配一个或多个extent来组成表的数据段，创建一个索引，oracle也会纷纷extent给索引数据。一般可以分为data segment，index segment，temporary segment。
    当你创建一个非分区并且非聚焦表的时候，或者一个分区表的一个分区，多个表合用的一个聚簇，都将是一个oracle将处理数据的单个data segment。
    而一个index segment ，对于非分区索引，就是create index创建的索引就会分配一个segment来处理数据；分区索引则对每一个分区分配一个segment来处理数据。
    当一个进程查询的时候，oracle常常需要一个临时的工作区存放sql的解析和执行的中间状态，oracle自动分配的磁盘空间temporary segment。特别当内存的排序区不足时，oracle将会分配一个temporary segment。有时候，下面一些语句有时候需要用到temporary segment：
    create index ....
    select    .... order by ;
    select distinct ....
    select ...... group by 
    select ...... union 
    select ...... intersect
    select ...... minus
    还有就是对一个子查询来说也会用到temporary segment。如果一个查询包含distinct 子句，一个order by ，一个group by，那么就需要两个temporary segment。当创建一个临时表或索引，oracle也会分配一些temporary segment。
    对于temporary segment，oracle只是在一个用户的会话（session）中分配，但sql语句执行结束或者会话断开，将释放所有的temporary segment。分配这些temporary segment的磁盘空间都是在临时表空间，如果没有定义临时表空间，那么默认的临时表空间将是system表空间。对于DBA来说，由于分配和释放这些 temporary segment将非常频繁，所以至少要定义一个temporary segment，这样可以避免system表空间的碎片。对于临时表来说，如果多个会话公用一个临时表，那么知道所有的会话全部结束，那才会释放这个临时 表分配的temporary segment。
   一个说明：在这篇文章中，好多单词我觉得很难去翻译，我也查了英汉词典，对于extent和segment在汉语中都是区和段的意思，在英文中虽然有一些差异，但在汉语中一个词足以说明他的意思，s所以我决定还是不翻译，直接引用，各位达人请勿见笑。^_^

来源： <http://hi.baidu.com/bystander1983/item/7766d150452af1938d12ed3d>
 

