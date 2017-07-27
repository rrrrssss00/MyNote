打开文件夹C:\Users\[user]\AppData\Local\Google\Chrome\User Data\Default，找到History文件，拷贝出来
使用SQLite打开，找到其中的downloads和downloads_url_chains表，在第一表中可以找到下载记录（含名称），在第二个表中可以找到下载的URL


#########################################################################
下面这种方法只能导出有限数量的记录，因为Chrome的下载列表是动态更新的，在有限的列表项里，动态更新项的内容
#########################################################################
使用Ctrl+J打开下载记录页面，向下拉，直接加载完所有需要导出的记录 
按F12打开开发者工具，在控制台出输入以下代码

ditems = document.querySelector("downloads-manager").shadowRoot.querySelector("iron-list").querySelectorAll("downloads-item");

var div = document.createElement('div');

[].forEach.call(ditems, function (el) {
var br = document.createElement('br');
var hr = document.createElement('hr');
div.appendChild(el.shadowRoot.querySelector("#name"));
div.appendChild(el.shadowRoot.querySelector("#url"));
div.appendChild(br)
div.appendChild(hr)

});
document.body.innerHTML=""
document.body.appendChild(div);
document.head.style.innerHTML=""


然后按Ctrl+S导出页面，在源代码中即可查看所有下载记录，也可以直接下载
