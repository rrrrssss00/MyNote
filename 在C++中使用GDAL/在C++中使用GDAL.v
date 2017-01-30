1：新建一个CLR的窗体程序
2：在项目-属性中，
        VC++目录里，添加源码的ogr,port,gcore等目录作为“包含目录”，添加源码目录为库目录（也有可能是   链接器--常规  里的附加库目录）
        再在   链接器--输入  里的附加依赖项里添加gdal_i.lib
3:在项目-属性中
        常规   里，公共语言运行时支持，改为   公共语言运行时支持(/clr)   ，否则可能会报错  error C3389:__declspec(dllexport) 不能与 /clr:pure 或 /clr:safe 一起使用   
4：#include "gdal.h"; #include "gdal_priv.h";    
        注意这些引用需要放在namespace 外面，否则会报错
5：将gdalxxx.dll和proj.dll/geos_c.dll等DLL拷贝到Debug/Release目录下
