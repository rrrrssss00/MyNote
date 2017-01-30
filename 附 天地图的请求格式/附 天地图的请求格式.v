可以在http://www.tianditu.cn/guide/index.html里查
 
矢量底图（WEB墨卡托格式）：
http://t0.tianditu.com/vec_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=vec&STYLE=default&TILEMATRIXSET=w&TILEMATRIX=1&TILEROW=0&TILECOL=0&FORMAT=tiles
 
矢量注记：
http://t0.tianditu.com/cva_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cva&STYLE=default&TILEMATRIXSET=w&TILEMATRIX=1&TILEROW=0&TILECOL=0&FORMAT=tiles
 
影像底图（WEB墨卡托格式）
http://t0.tianditu.com/img_w/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=w&TILEMATRIX=1&TILEROW=0&TILECOL=0&FORMAT=tiles
 
影像注记：
http://t0.tianditu.com/cia_w/wmts?
SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cia&STYLE=default&TILEMATRIXSET=w&TILEMATRIX=1&TILEROW=0&TILECOL=0&FORMAT=tiles
 
分辨率计算:
以第一层为例,其坐标界限为-20037508.3427892到20037508.3427892,第一层为2*2的切片,每个切片为256*256,那么意味着20037508.3427892*2=40075016.6855784的距离对应256*2=512个像素,分辨率即为:78271
