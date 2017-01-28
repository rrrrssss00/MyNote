可以将Html里的Button标签绑定一个Javascript函数，但同时Button也会触发页面的提交事件，具体的区分如下：

如果Button的Type为submit,且位于form标签里，才会触发页面提交，在页面提交之前，同样会触发绑定的JavaScript函数

不同时满足这两个条件，都不会触发页面提交，Javascript函数会触发


如果想在Javascript里控制是否提交，可以使用Form的onsubmit事件代替Submit Button的onclick事件，例如 ：
<form name="myForm" action="demo-form.php" onsubmit="return validateForm()" method="post">

Javascript代码为：
<script>
function validateForm()
{
var x=document.forms["myForm"]["fname"].value;
if (x==null || x=="")
  {
  alert("姓必须填写");
  return false;
  }
}
</script>

这时，如果返回值为false时，那么会阻止页面的提交，返回值为正常时页面才会提交
