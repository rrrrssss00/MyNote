Controls.Map 或 Controls.IBasicMap
 
FunctionMode:地图交互工具类型，包括：None,Zoom,Info,Label,Meature，Pan等
ZoomToMaxExtent：
AddLayer()

当添加的图层系统与Map的坐标系统不一致时，Map会进行坐标转换
这时可以通过修改Map.ProjectionModeDefine的值来控制在坐标转换前是否提示
值共有四个：Alway，Never，Prompt，PromptOnce
分别代表：总是提示，从不提示，提示，提示一次


