由于以前的项目都是用myeclipse开发的，现在想换成eclipse来开发。但是项目导入到eclipse中发现该项目并不是web项目，也不能部署到tomcat里面去。
       刚在csdn上面看到一段回复，试了一下，果然可以。分享一下！
       1.请首先确保你的eclipse是javaee版本的，或者已经安装看wtp插件 

       2.然后修改eclipse工程下的.project文件： 

          在 <natures> </natures>中加入 
    <nature>org.eclipse.wst.common.project.facet.core.nature</nature>
    <nature>org.eclipse.wst.common.modulecore.ModuleCoreNature</nature>
    <nature>org.eclipse.jem.workbench.JavaEMFNature</nature>
   在 <buildSpec> </buildSpec>中加入
     <buildCommand>
        <name>org.eclipse.wst.common.project.facet.core.builder</name>
        <arguments>
        </arguments>
    </buildCommand>
    <buildCommand>
        <name>org.eclipse.wst.validation.validationbuilder</name>
        <arguments>
        </arguments>
    </buildCommand>
3.刷新项目，项目->右击->Properties->Project Facets->Modify Project，选择Java和Dynamic Web Module 
          配置Context Root 和Content Directory 以及源码路径。

来源： <http://todaydiy.blog.163.com/blog/static/104189687201021035312604/>
 
