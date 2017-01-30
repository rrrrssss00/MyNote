Geodatabase的版本
一、作用：版本（Versioning）能够使多个用户同时编辑一个Geodatabase，并看到相同图层或表的不同版本。
 
二、原理
不论一个Geodatabase有多少个版本，数据库中只保存一套表和图层，当连接一个多用户的Geodatabase时，通常需要选择要连接哪一个Version
 
大致原理为：
1、每一个表或图层都有一个原始表（Original Table），当注册为版本后，数据库中，在Table_registry表中会新
生成一条记录，说明了该表注册的ID以及版本，然后在数据库中新建两个变化表（Delta Table）A表以及D表，表名为：A/D+注册ID
（例如在SDE.Table_registry表中注册ID为56，那么表名为A56以及D56），当用户向表中插入记录或修改记录时，该操作对应的信息
会记录在A表中，当用户从表中删除记录时，该操作对应的信息会记录在D表中。
2、图层在SDE中有三种状态：
a:未注册（not registered as versioned）
b:注册为不修改原始表的版本（Registered As Visioned without the option to move edits to base）
c:注册为修改原始表的版本（registered as visioned with the option to move edits to base）
这三种状态的区别为(转载)：
a是最原始的状态，能够实现复杂数据类型，包括拓扑和几何网络的编辑与更新。因为Default版本是数据库中最关键的，需要经常更新，因此需要对Default版本定期备份。
b能够实现的操作包括Undo和Redo操作、长事务编辑、为设计和工程使用命名版本、使用Geodatabase归档、使用数据库复制。
不能做的事：创建拓扑、从拓扑中添加或删除要素、添加和删除拓扑规则、创建几何网络、从几何网络中添加或删除要素类。
c不能够做的事：编辑参与拓扑和几何网络的要素类、数据库归档、数据库复制
 
而且如果用户在注册为版本时选的是b状态(不打勾，也即SDE默认的方式)所有简单要素编辑（例如属性表之类）的记录都会存到
变化表（Delta Table)中，而不会修改原始表
如果用户在注册为版本时选的是c状态，那么所有简单要素编辑的记录会先保存到变化表中，在结束编辑或保存编辑后，都会将
变化表中的记录删除，并更新原始表中的相应内容。
 
注：上文中提到的所有编辑操作均指的是通过AO对表或图层进行的操作（即ArcMap或ArcCatalog）
 
三、相关操作
1、如果修改了某些（注册为不修改原始表的版本）表，这些修改内容均保存在变化表中，如果想将这些内容更新到原始表中，
方法为：Compress Database,该命令从Catalog中，右键工具条->Customize->Commands->Geodatabase Tools->Compress Database
 
2、要修改某个表的注册状态，在ArcToolbox中Data Manager Tools中Version目录下有相关的注册为版本，以及解注册等工具
 
注：在解注册工具中，提供了两个选项，一个是Keep any edits，这个选项没发现有什么用，因为在解注册后，相应的A表和D表就会被
删除，也不知道它Keep到哪去了，不过如果选了这个选项的话，A表和D表有内容的情况下，解注册会报错，
另一个选项是Compress all edits in the Default version into the base table，选了这个选项会将A表及D表中的修改记录
更新到原始表中，然后再进行解注册
