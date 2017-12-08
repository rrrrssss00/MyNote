import arcpy
import sys
import os


inputFeature = arcpy.GetParameterAsText(0)
outputFeature = arcpy.GetParameterAsText(1)
outputPathAndName = os.path.split(outputFeature)

arcpy.FeatureClassToFeatureClass_conversion(inputFeature,outputPathAndName[0],outputPathAndName[1])

arealist = []
for row in arcpy.SearchCursor(outputFeature):
    tmpname = row.getValue("NAME")
    tmparea = row.getValue("shape").area
    print tmpname
    arealist.append(tmparea)
    #arcpy.AddMessage(tmpname + str(tmparea))

countBeforDel = arealist.__len__()
arcpy.AddMessage("FeatureCount: "+str(countBeforDel))

diCount = countBeforDel/5
arcpy.AddMessage("DivCount: "+ str(diCount))

arealist.sort()
diArea = arealist[diCount-1]
arcpy.AddMessage("DivArea: "+str(diArea))

curCursor = arcpy.UpdateCursor(outputFeature)
for row in curCursor:
    tmpname = row.getValue("NAME")
    tmparea = row.getValue("shape").area
    if(tmparea <= diArea):
        curCursor.deleteRow(row)
        #arcpy.AddMessage("del: "+tmpname)