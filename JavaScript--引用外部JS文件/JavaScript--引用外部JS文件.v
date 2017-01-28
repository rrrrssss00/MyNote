<!DOCTYPE html>
<html><body>
<h1>我的 Web 页面</h1>

<p id="demo">一个段落。</p>


<button type="button" onclick="myFunction()">点击这里</button>

<p><b>注释：</b>myFunction 保存在名为 "myScript.js" 的外部文件中。</p>
<script src="../js/myScript.js"></script>

</body>
</html>

外部JS文件：
function myFunction()
{
document.getElementById("demo").innerHTML="我的第一个 JavaScript 函数";
}

