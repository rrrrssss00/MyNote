DefaultSymbol及DefaultLabel即为ArcMap里使用UniquValueRenderer时显示的All other values对应的符号以及标签
 
使用时发现,这两个值在设置后,经常会不生效,
 
后发现,如果UseDefaultSymbol为true,那么设置之前需要使UseDefaultSymbol为false，设置完后再置为true即可使这两个值的设置生效
 
此外,在uvr.RemoveAllValues()语句执行完成后,UseDefaultSymbol会被设为false
