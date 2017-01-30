ARCGIS拓扑检查步骤
2010-04-21 15:23
ARCGIS拓扑检查步骤

启动ArcCatlalog;
任意选择一个本地目录，"右键"->"新建"->"创建个人personal GeoDatabase";
选择刚才创建的GeoDatabase，"右键"->"新建"->"数据集dataset";设置数据集的坐标系统，如果不能确定就选择你要进行分析的数据的坐标系统;
选择刚才创建的数据集,"右键"->"导入要素类inport --feature class single",导入你要进行拓扑分析的数据;
选择刚才创建的数据集,"右键"->"新建"->"拓扑"，创建拓扑,根据提示创建拓扑，添加拓扑处理规则；
进行拓扑分析。
最后在arcmap中打开由拓扑规则产生的文件，利用topolopy工具条中错误记录信息进行修改
将数据集导入ARCMAP中，点击edit按钮进行编辑。
打开eidt下拉菜单，选择more editing tools－－topology出现拓扑编辑工具栏。
选择要拓扑的数据，点击打开error inspector按钮。
在error inspector对话框中点击search now，找出所有拓扑的错误。
对线状错误进行Mark as Exception。
对polygon错误逐个检查，首先选择错误的小班，点击右键选择zoom to，然后点击merge，选择合适的图班进行merge处理，这样不会丢失小班信息。
zhangtao 发表于 2009-5-27 21:03
【第一部分】

在arcgis中有关topolopy操作，，有两个地方，一个是在arccatalog中，一个是在arcmap中。通常我们将在arccatalog中建立拓扑称为建立拓扑规则，而在arcmap中建立拓扑称为拓扑处理。

arccatalog中所提供的创建拓扑规则，主要是用于进行拓扑错误的检查，其中部分规则可以在溶限内对数据进行一些修改调整。建立好拓扑规则后，就可以在arcmap中打开些拓扑规则，根据错误提示进行修改。

arcmap中的topolopy工具条主要功能有对线拓扑（删除重复线、相交线断点等，topolopy中的planarize lines）、根据线拓扑生成面（topolopy中的construct features）、拓扑编辑（如共享边编辑等）、拓扑错误显示（用于显示在arccatalog中创建的拓扑规则错误，topolopy中的error inspector），拓扑错误重新验证（也即刷新错误记录）。

[第二部分]

在arccatalog中创建拓扑规则的具体步骤？

要在arccatalog中创建拓扑规则，必须保证数据为geodatabase格式，且满足要进行拓扑规则检查的要素类在同一要素集下。

因此，首先创建一个新的geodatabase，然后在其下创建一个要素集，然后要创建要素类或将其它数据作为要素类导入到该要素集下。

进入到该要素集下，在窗口右边空白处单击右键，在弹出的右键菜单中有new->topolopy，然后按提示操作，添加一些规则，就完成拓扑规则的检查。

最后在arcmap中打开由拓扑规则产生的文件，利用topolopy工具条中错误记录信息进行修改。

[第三部分]

有关geodatabase的topology规则

多边形topology

1.must not overlay：单要素类，多边形要素相互不能重叠

2.must not have gaps：单要素类，连续连接的多边形区域中间不能有空白区（非数据区）

3.contains point：多边形＋点，多边形要素类的每个要素的边界以内必须包含点层中至少一个点

4.boundary must be covered by：多边形＋线，多边形层的边界与线层重叠（线层可以有非重叠的更多要素）

5.must be covered by feature class of：多边形＋多边形，第一个多边形层必须被第二个完全覆盖（省与全国的关系）

6.must be covered by：多边形＋多边形，第一个多边形层必须把第二个完全覆盖（全国与省的关系）

7.must not overlay with：多边形＋多边形，两个多边形层的多边形不能存在一对相互覆盖的要素

8.must cover each other：多边形＋多边形，两个多边形的要素必须完全重叠

9.area boundary must be covered by boundary of：多边形＋多边形，第一个多边形的各要素必须为第二个的一个或几个多边形完全覆盖

10.must be properly inside polygons：点＋多边形，点层的要素必须全部在多边形内

11.must be covered by boundary of：点＋多边形，点必须在多边形的边界上

线topology

1.must not have dangle：线，不能有悬挂节点

2.must not have pseudo-node：线，不能有伪节点

3.must not overlay：线，不能有线重合（不同要素间）

4.must not self overlay：线，一个要素不能自覆盖

5.must not intersect：线，不能有线交叉（不同要素间）

6.must not self intersect：线，不能有线自交叉

7.must not intersect or touch interrior：线，不能有相交和重叠

8.must be single part：线，一个线要素只能由一个path组成

9.must not covered with：线＋线，两层线不能重叠

10.must be covered by feature class of：线＋线，两层线完全重叠

11.endpoint must be covered by：线＋点，线层中的终点必须和点层的部分（或全部）点重合

12.must be covered by boundary of：线＋多边形，线被多边形边界重叠

13.must be covered by endpoint of：点＋线，点被线终点完全重合

14.point must be covered by line：点＋线，点都在线上

[第四部分]

Geodatabase组织结构。

Geodatabases中，将地理数据组织成为数据对象（data objects）。这些数据对象存储于要素类（feature class）、对象类（object class）或要素集（feature datasets）中。

对象类（object class）用于存储非空间信息。

要素类（feature class）则存储了空间信息及其相应的属性信息，在同一个要素类中，空间要素的几何形状必须一致，比如必须都是点、线或者面。简言之，要素类是同类要素的集合。

要素集（feature dataset）用于存放具有同一空间参考（spatial reference）的要素类。存放了简单要素的要素类可以存放于要素集中，也可以作为单个要素类直接存放在Geodatabase的目录下。直接存放在Geodatabase目录下的要素类也称为独立要素类（standalone feature）。存储拓扑关系的要素类必须存放到要素集中，使用要素集的目的是确保这些要素类具有统一的空间参考，以利于维护拓扑。Geodatabase支持要素类之间的逻辑完整性，体现为对复杂网络（complex networks）、拓扑规则和关联类等的支持。下面描述Geodatabase中的数据对象（data objects）。

要素类（Feature class）

要素类，可称为点、线或面类型要素的集合，同时，地图的文本信息也可用注记（annotation）要素类存储。非独立要素类，也就是相关联的要素类（如参与拓扑规则或者几何网络的要素类），以要素集的形式管理到一起。

栅格数据集（Raster data set）

以栅格表的形式管理的单或多波段栅格数据。

表（Tables）

描述非空间信息的表。

关联类（Relationships）

关联类是一种机制：从一个表（要素类）中选择记录以后，可以在相关联的表（要素类）中可以获取到相应记录。

域（Domains）

列有效值的一个列表（或范围）。

子类（Subtypes）

将要素类中的要素进行了逻辑分组，每一个分组便是一个子类。每一个这样的都有其完整性规则和GIS行为（如高速公路，是道路要素的一个子集）。

空间关系（Spatial relationships）

在拓扑工具（topologies）或几何网络（Geometric network）中定义。拓扑规则可以指定要素类中的要素之间有何种空间关系，如地块之间不能重叠(overlap)，或者多个不同要素类中的要素之间的空间关系，比如国家首都（点要素）必须位于该国家疆土（面要素）上。

元数据（Metadata）数据库中的每个元素的描述文档。

