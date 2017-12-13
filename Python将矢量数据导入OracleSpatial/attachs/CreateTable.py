import sys
import os
import cx_Oracle
import ogr
import getopt

#根据指定矢量图层的字段设置，创建对应的数据库表
def createTable(inputFilename:str,tableNameToCreate:str):
    #region 连接数据库
    os.environ['NLS_LANG'] = 'SIMPLIFIED CHINESE_CHINA.UTF8'
    con = None  #type:cx_Oracle.Connection
    try:
        con = cx_Oracle.connect("zy02cdb/zy02cdb@10.0.2.13/agrs")
    except Exception as ex:
        if(len(ex.args)>0):
            print("数据库连接失败"+ex.args[0].message)
        #print("数据库连接失败："+ex.args)
        #sys.exit()
        return
    #endregion

    #region 读取shp文件
    #输入文件是否存在，是否为shp文件
    if(os.path.isfile(inputFilename) == False):
        print(inputFilename+"：文件不存在")
    if(inputFilename.endswith(".shp") == False):
        print("输入文件名的格式不正确")
        #sys.exit()
        return

    #表是否已经存在
    cur = con.cursor()
    cur.execute('select table_name from user_tables where table_name=:tabname',tabname=tableNameToCreate.upper())
    if(cur.fetchone() != None):
        print(tableNameToCreate+" 表已经存在，无法创建")
        #sys.exit()
        return

    lyr= None  #type:ogr.Layer
    try:
        ds = ogr.Open(inputFilename,0) #type:ogr.DataSource
        lyr = ds.GetLayer(0)
    except Exception as ex:
        print("矢量打开失败:"+ex.args[0].message)
        return
    #endregion

    #region 按照图层的字段，拼接出创建表的SQL语句
    createTableSql = "create table " + tableNameToCreate + " ("
    #逐个字段拼接字符串
    fieldCount = lyr.GetLayerDefn().GetFieldCount()
    for i in range(0, fieldCount):
        tmpfield = lyr.GetLayerDefn().GetFieldDefn(i)  #type:ogr.FieldDefn
        tmpName = tmpfield.GetName()  #字段名
        tmpTypeName = tmpfield.GetTypeName() #字段类型，String,Real,Integer
        tmpWidth = tmpfield.GetWidth()      #字段长度
        tmpPrecesion = tmpfield.GetPrecision()  #字段精度，仅对于Real有效
    
	if(tmpTypeName == "String"):
  	    createTableSql += tmpName+" VARCHAR2("+str(tmpWidth)+"),"
	elif(tmpTypeName == "Real"):
	    createTableSql += tmpName+" number("+str(tmpWidth)+","+str(tmpPrecesion)+"),"
	elif(tmpTypeName == "Integer"):
	    createTableSql += tmpName+" integer,"
	else:
	    raise Exception("意外的数据类型:"+tmpName)
	    
    #createTableSql = createTableSql[0:len(createTableSql)-1]+")"
    createTableSql += "shape MDSYS.SDO_GEOMETRY)"
    print("sql:\t"+createTableSql)
    lyr = None
    #endregion
    
    #创建表
    try:
        cur.execute(createTableSql)
        con.commit()
        print("创建表 "+tableNameToCreate+" 完成")
    except Exception as ex:
        print("创建表失败："+ex[0].message)
        #sys.exit()
        return

#主函数
def __main():
    # region 读取输入参数
    inputFilename = ''
    tableNameToCreate = ''
    try:
        opts, argss = getopt.getopt(sys.argv[1:], "i:o:")
    except getopt.GetoptError as ex:
        print("参数错误，请重新输入")
        sys.exit()

    for opt, arg in opts:
        if (opt == "-i"):
            inputFilename = arg
        elif (opt == "-o"):
            tableNameToCreate = arg
        else:
            aa = 1
    # endregion

    createTable(inputFilename, tableNameToCreate)

#直接调用时
if(__name__ == "__main__"):
   __main()
