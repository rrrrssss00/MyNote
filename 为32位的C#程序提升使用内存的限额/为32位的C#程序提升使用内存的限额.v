正常的32位C#程序，一般使用1.4G左右的内存后，就会报内存不足（System.OutOfMemoryException）的错误，可以使用editbin工具将其修改一下（只限在64位系统中运行32位C#程序使用，在32位系统中基本无效）

两种方法，

一种是后处理，在编译完成EXE后，使用editbin.exe工具对exe文件进行处理（会修改exe文件），使其支持更多的内存分配
命令格式为：   editbin /largeaddressaware xxx.exe
详细使用方法可以参考另一篇文章《使用LargeAddressAware压榨额外的用户态内存》

第二种方法是直接在VS里设置，让其编译出来后自动处理
editbin工具中的/largeaddressaware参数是针对链接器的，C#没有链接这一步骤，因此无法像C++一样在链接器中进行设置，C#需要自动完成这一处理，需要在项目属性的“后期生成事件命令行”中，添加以下命令（以VS2010为例，其它版本可能有变更）：

call "$(VS100COMNTOOLS)..\tools\vsvars32.bat"
editbin /largeaddressaware $(TargetPath)

备注1：不同VS版本，命令行可能有变更 
	vs2012:
		call "$(VS110COMNTOOLS)..\tools\vsvars32.bat" 
		editbin /largeaddressaware $(TargetPath)
	vs2013:
		call "$(DevEnvDir)..\tools\vsvars32.bat"
		editbin /largeaddressaware $(TargetPath)
备注2：$(TargetPath) 可能需要用双引号括起来

