import sys
import os
import cx_Oracle
import ogr
import getopt
import CreateTable
from time import clock

#读取指定的矢量图层，并将其导入到Oracle数据库的指定表中（逐行导入版本）
def importShp(importFileName:str,tableNameToImport:str):
    # region 连接数据库
    os.environ['NLS_LANG'] = 'SIMPLIFIED CHINESE_CHINA.UTF8'
    con = None  # type:cx_Oracle.Connection
    try:
        con = cx_Oracle.connect("zy02cdb/zy02cdb@10.0.2.13/agrs")
    except Exception as ex:
        if (len(ex.args) > 0):
            print("数据库连接失败" + ex.args[0].message)
        return
    # endregion

    # region 打开shp文件
    # 输入文件是否存在，是否为shp文件
    if (os.path.isfile(importFileName) == False):
        print(importFileName + "：文件不存在")
    if (importFileName.endswith(".shp") == False):
        print("输入文件名的格式不正确")
        return

    # 表是否已经存在
    cur = con.cursor()
    cur.execute('select table_name from user_tables where table_name=:tabname', tabname=tableNameToImport.upper())
    if (cur.fetchone() == None):
        print(tableNameToImport + " 表不存在，无法导入")
        return

    lyr = None
    try:
        ds = ogr.Open(importFileName, 0)  # type:ogr.DataSource
        lyr = ds.GetLayer(0) # type: ogr.Layer
    except Exception as ex:
        print("矢量打开失败:" + ex.args[0].message)
        return

    # endregion

    #region 读取矢量图层中的每一个要素，逐个导入、
    featureCount = lyr.GetFeatureCount()
    fieldCount = lyr.GetLayerDefn().GetFieldCount()
    #region 先读取字段名称列表
    fieldNameStr = "("
    fieldValStr = "("
    for i in range(0,fieldCount):
        tmpField = lyr.GetLayerDefn().GetFieldDefn(i)  #type:ogr.FieldDefn
        tmpFieldName = tmpField.GetName()
        fieldNameStr += tmpFieldName+","
        fieldValStr += ":"+str(i+1)+","
    fieldNameStr += "SHAPE)"
    fieldValStr += "sdo_geometry(:"+str(fieldCount+1)+",4610))"
    #endregion

    for i in range(0,featureCount):
        tmpfea = lyr.GetFeature(i)                                      #type:ogr.Feature
        tmpValLst=[]
        for j in range(0,fieldCount):
            tmpValLst.append(tmpfea.GetFieldAsString(j))
        tmpGeo = tmpfea.GetGeometryRef()                                #type:ogr.Geometry
        wkt = tmpGeo.ExportToWkt()

        wktvar = cur.var(cx_Oracle.CLOB)
        wktvar.setvalue(0,wkt)
        tmpValLst.append(wktvar)


        cur.execute("insert into "+tableNameToImport+ " "+fieldNameStr+"values"+fieldValStr,tmpValLst)

    con.commit()
    #endregion

    cur.close()

#主函数
def __main():
    # region 读取输入参数
    importFilename = ''
    tableNameToImport = ''
    try:
        opts, argss = getopt.getopt(sys.argv[1:], "i:o:")
    except getopt.GetoptError as ex:
        print("参数错误，请重新输入")
        sys.exit()

    for opt, arg in opts:
        if (opt == "-i"):
            importFilename = arg
        elif (opt == "-o"):
            tableNameToImport = arg
        else:
            aa = 1
    # endregion

    startTime = clock()
    #print(startTime)
    importShp(importFilename, tableNameToImport)
    endTime = clock()
    #print(endTime)

    print((endTime - startTime))

#直接调用时
if(__name__ == "__main__"):
   __main()

