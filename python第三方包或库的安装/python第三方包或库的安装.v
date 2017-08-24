一般有三种方式
1.如果有在线环境，可通过pypi来安装，先通过pip search 'name'来查找，再通过pip install 'name'来安装
2.如果安装的是Anoconda也可以通过Anoconda自带的conda命令来安装，使用方式参考conda命令行
3.如果没有在线环境，则可下载离线安装包，一般有两种形式，在pypi的网站上下载的*.whl文件，可以使用pip install xxxx.whl安装
                       如果是压缩包形式，则看里边有没有setup.py，如果有的话，一般使用python setup.py install命令来安装
