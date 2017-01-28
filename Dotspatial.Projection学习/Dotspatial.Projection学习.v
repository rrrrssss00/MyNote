据文档说明：DotSpatial.Projection 是另一个开源项目Proj4的C#实现

坐标转换的流程，参考文档最后Reproject类中ReprojectPoints函数的流程

接口及类说明：
	IProjRandomizable：将对应对象的各种属性设置为一个值域范围内的随机值
		Randomize:传入一个Random类型的对象，作为随机值的生成依据

	IProjMatchable：比较两个对象是否一致，
		Matches：比较函数，如果一致，则返回True，不一致返回False，并返回不一致部分的列表

	IProjDescriptor:继承IProjMatchable,IProjRandomizeble
		CopyProperties：将传入对象的属性拷贝到当前对象

	ProjCopyBase:继承了IClonable接口，主要实现复制操作
		Clone:提制自身，得到一个新的对象
		DistinctNames：从输入的PropertyInfo列表中，移除Name重复的项，返回列表
		OnCopy：在Clone里被调用，手动实现深拷贝
	
	ProjDescriptor：继续了ProjCopyBase类和IProjDescriptor接口
		CopyProperties：IProjDescriptor的CopyProperties函数，将传入对象的值或属性拷贝给当前对象
		Matches：IProjMatchable接口的Matches函数，判断传入的对象与当前对像是否一致，如果一致则返回True,不一致则返回False,并返回不一致部分的列表
		Randomize：将对象所有属性都设为其值域内的随机值
		OnCopyProperties:在CopyProperties中被调用，实际的拷贝对象代码
		OnMatch：在Matches里被调用，实际的判断一致代码
		OnRandomize:在Randomize里被调用，实际的随机化代码
		Match：在OnMatch里被调用，判断两个子对象是否一致
	
	IEsriString：用来转化为Esri格式Proj代码或读取Esri格式Proj代码的接口
		ToEsriString：将自身代表的坐标系信息转化为Esri格式的Proj代码
		ParseEsriString：解析传入的Esri格式的代码，将解析的结果（坐标系信息）赋给自身
	
	AuxiliarySphereType：Enum值，辅助球体的描述方式
		SemimajorAxis：用长半轴或半径
		SemiminorAxis：用短半轴或半径
		Authalic：用等体积半径
		AuthalicWithConvertedLatitudes：用等体积半径，并将地理纬度转换为等体积的纬度
		NotSpecified：没有指定，那么这个属性值可以不用在ProjString里体现
	
	LinearUnit：距离单位
		_meters：1单位相当于多少米
		_name：名称
		ToEsriString：以“UNIT["name",meter]”格式输出为ESRI的String
		ParseEsriString:从ESRI的String中读取距离单位信息，赋给_meter和_name
		ReadCode:读取预先设置的代码，将对应的值赋给_meter和_name(这些值是与GDAL对应的)
	
	AngularUnit:角度单位，继承了ProjDescriptor和IEsriString
		_name:名称
		_radians:1单位相当于多少弧度
		ParseEsriString：同LinearUnit
		ToEsriString：同LinearUnit


	Proj4Ellipsoid:枚举值，包含了在Proj4库中使用的一些标准的椭球体
		对于没有在枚举中的椭球，可以用Custom表示，并通过长轴和扁率来描述
	
	Spheroid：椭球体，继承了ProjDescriptor和IEsriString，默认为WGS-84
		_equatorialRadius：赤道半径
		_polarRadius：极半径
		_code:代码
		_name:名称
		_proj4Names:用于保存Proj4Ellipsoid里的椭球体及对应的别名
		InverseFlattening:逆扁率（赤道半径除以赤道半径减极半径）
		AddNames:将Proj4Ellipsoid中的项加到_proj4Names里去，并添加一个别名
		AssignKnownEllipsoid：传入Proj4Ellipsoid的枚举值，将当前赋为对应的椭球参数
		Spheroid：构造函数，不带参数的话默认为WGS84，还可以通过长短轴，半径，ID等方式调用
		ReadSedrisCode：传入两字符长度的的椭球简称，初始化基准面
		FlatteningFactor：扁率
		Eccentricity：偏心率 Math.Sqrt(2 * f - f * f);f为扁率
		IsOblate：椭球是否是椭的（反之为正球形）
		ToEsriString：以SPHEROID["name"，赤道半径，逆扁率]的格式输出为ESRI的string
		ParseEsriString：从ESRI的String中读取基准面信息
	
	DatumType：枚举值，表示某个基准面（Datum）与WGS84之间的关系
		Unknown:无法描述
		Param3:可以通过三个参数转换到WGS84基准面
		Param7：可以通过七个参数转换到WGS84基准面
		GridShift:无法通过严密的数据模型进行基准面转换，需要用到Grid Shift（按我的理解，应该是指多个已经点的坐标对应关系，通过这些点进行拟合或插值，完成坐标转换）
		WGS84:已经是WGS84的基准面了
	
	Proj4Datum：枚举值，包含了Proj4库中定义的一些标准的基准面

	Datum：基准面，继承了ProjDescriptor和IEsriString接口（这个类，如果需要进行有效的转换，需要知道_toWgs84这个数组（三参数或七参数）或GridShift，这个类有两种初始化方法，一种是使用Proj4格式进行初始化，通过设置Proj4DatumName，见该属性的Set部分，这里有一些在代码里预定义好的Datum参数，有赋值的那些即可以实现与WGS84间的转换，没有赋值的好像没有处理，第二种是使用ESRIString进行初始化，初始化时查询datums.xml文件，其中有部分预先设置好的Datum，如果有的话，使用这里面的值进行初始化和转换，另外一些Datum可能是因为没有获取到值，直接保存成WGS84（但实际上不是WGS84，只是为了程序运行，认为它是，结果是错误的，比如Beijing54对应的Datum），奇怪的是，这两种方式里，部分Datum对应的参数还是不一样的。。。）
		SEC_TO_RAD:秒与弧度之间的换算关系
		_datumtype:DatumType枚举值，描述本基准面与WGS84间的转换关系
		_description:描述
		_nadGrids:GridShift的值
		_name:名称
		_spheroid:椭球体
		_toWgs84:到WGS84基准的转换参数，如果已经是WGS84了，为0，0，0，若是Param3，则为三个转换参数，若是Param7，则为7个转换参数
		Proj4DatumName：Proj4的标准名称，可以通过该名称来初始化，设置该值时，如果设置的目标是已知的基准面，那么也会将对应的转换参数赋上
		ToProj4String：按Proj4的格式输出基准面
		Matches：与传入的基准面是否相同（似乎有点问题，如果当前基准面的DatumType是WGS84的话，直接返回True，不太合逻辑）
		ToEsriString：以DATUM["NAME",椭球ESRIString]的格式输出
		ParseEsriString：读取ESRI格式的String，这里注意，读取后，程序还会寻找datums.xml文件，按读取到的name找到对应的转换参数并赋给相应值（能找到的话）
		InitializeToWgs84：初始化到WGS84基准的转换参数（三个或七个参数）

	Proj4Meridian：枚举值，列举了Proj4库中一些标准的子午线（对应的地名？）

	Meridian：子午线，继承了ProjDescriptor以及IEsriString接口
		_code:代码，8901-8913的标准代码，与Proj4Meridian对应
		_longitude:经度
		_name:名称
		Meridian：构造函数，默认为Greenwich，可以通过经度&名称，Proj4Meridian标准代码等方式来初始化
		ReadCode：读取传入的参数，将对应的Proj4Meridian赋给当前子午线
		AssignMeridian：传入Proj4Meridian，将对应的经度和代码赋给当前子午线
		FindNameByValue：传入经度值，将对应的名称和代码赋给当前子午线
		pm：经度或城市名称
		ToEsriString：以PRIMEM["name",经度]的格式输出
		ParseEsriString：读取ESRI格式的String
		ToProj4String：按Proj4的格式输出子午线

        GeographicInfo:地理坐标，继承了ProjDescriptor以及IEsriString接口
                _datum:基准面
                _meridian:子午线
                _unit:角度单位（AngularUnit类型）
                _name:名称
                ToEsriString：以GEOGCS["name",DatumEsriString,MeridianEsriString,AngularUnitEsriString]的格式输出
                ParseEsriString:读取ESRI格式的字符串，初始化datum,meridian,unit
                ToProj4String:按Proj4的格式输出地理坐标系信息，包括子午线和基准面的信息

      ProjectionInfo：投影坐标信息，继承了ProjDescriptor以及IEsriString接口
 		_longitudeOf1st:第一条经线的经度
		_longitudeOf2nd:第二条经线的经度
		_scaleFactor:缩放比例
		LongitudeOfCenterAlias：中央经线的别名？
		LatitudeOfOriginAlias：起点纬线的别名？（保存从WKT/ESRIString里读取的名称）
		FalseEastingAlias：假东别名
		FalseNorthingAlias：假北别名
		Authority：标准名，例如EPSG，通过“标准名+ID”能查询到对应的标准投影坐标信息名，例如AUTHORITY["EPSG", "32650"]指的是该投影坐标系WGS 84 / UTM zone 50N
		CentralMeridian：中央子午线？
		EspgCode：代码，与Authority一起使用
		FalseEsting：假东值
		FalseNorthing：假北值
		Geoc：？是否为经纬度？（与IsLatLon 以及 IsGeocentric相似？）
		GeographicInfo：对应的地理坐标信息
		IsGeocentric：是否为地心纬度（与通常使用的大地纬度相对应）
		IsLatLon：该投影是否为经纬度
		IsSouth：是否为南半球的投影坐标系
		IsValid：当前的投影坐标系是否已经定义了（尤其是指Transform是否已经赋值，保证在转换时不要出错）
		LatitudeOfOrigin：起点纬线的纬度值（起点纬线是指投影坐标中Y坐标为0的纬线）
		M：干嘛用的。。。
		Name：坐标系名称
		NoDefs：布尔值，表示是否使用了proj_def.dat文件（对应Proj4的"no_defs"参数）
		Over：布尔值，是否超出范围？
		ScaleFactor：缩放比例
		StandardParallel1&StandardParallel2：标准纬线1&标准纬线2，圆锥或圆柱投影中与椭球相交的纬线，切圆锥&切圆柱投影中，有一条标准纬线，割圆锥&割圆柱投影中，有两条标准纬线，在标准纬线上，投影无变形
		Transform：将地理坐标转换为投影坐标的变换关系（在TryParseEsriString与ParseProj4String中初始化）
		Unit：长度单位
		W：干嘛用的。。。
		Zone：带号（如果需要用到的话）
		alpha:方位角，用于斜轴墨卡托
		bns:干嘛用的。。。
		czech:
		guam:
		h
		lat_ts:
		lon_1:可能指的是标准纬线1
		lon_2:可能指的是标准纬线2
		lonc:
		mGeneral:
		n:
		no_rot:
		no_uoff:
		rot_conv:
		to_meter:距离单位到米的转换值
		Lam1：用弧度表示的标准纬线1（如果不为空的话）
		Lam2：用弧度表示的标准纬线2（如果不为空的话）
		Phi1:同Lam1
		Phi2：同Lam2
		Lam0：用弧度表示的中央子午线，如果设置该值的话，中央子午线也相应设置
		Phi0：用弧度表示的起点纬度，如果设置该值的话，起点纬度也相应设置
		ToEsriString：按指定格式输出为EsriString
		TryParseEsriString&ParseEsriString：读取EsriString格式的WKT，给当前投影坐标系的相关属性赋值
		FromEsriString：静态，读取EsriString格式的Wkt，得到一个ProjectionInfo
		GetParameter：从EsriString中读某参数取值，该值对应的参数名称与传入参数相同
		FromEpsgCode&ReadAuthorityCode：静态函数，通过传入的EPSG代码来初始化一个ProjectionInfo（实际上是先通过代码得到Proj4格式的String，再通过调用ParseProj4String函数解析该String，得到ProjectionInfo，
		FromProj4String（静态）&ParseProj4String：解析Proj4格式的String，生成一个ProjectionInfo
		Open：静态函数，通过打开一个已有的Prj文档，生成一个ProjectionInfo
		SaveAx：将当前的ProjectionInfo保存为一个prj文件
		Equals：判断与另一个ProjectionInfo是否相等，通过判断两个ProjectionInfo生成的EsriString相等，或Proj4String相等
		GetUnitText：获取距离&角度单位的名称（含单复数，例如Foot&Feet，Yard&Yards。。。。）
		ToProj4String：将当前ProjectionInfo转为Proj4格式的String
		Append：在ToProj4String里调用的子函数，将信息以+xx=yy的格式添加到字符串最后面

	AuthorityCodeHandler：将预定义的Epsg代码与对应的Proj4String从AuthorityCodeToProj4.ds文件（压缩文档）中读取出来，保存到字典中，可供查询（包括两个字典，一个是默认字典，是从AuthorityCodeToProj4.ds文件中读取的，另一个是额外的，从DLL目录下的AdditionalProjections.proj4文件中读取的）
		ReadDefault：从默认文件中读取
		ReadCustom：从自定义文件中读取
		Add：将读取的信息添加到字典中
	
	CoordinateSystemCategory：父类，投影坐标系的集合，子类在继承该类时，将多个ProjectionInfo作为类的属性（Field），即可通过属性名将其提取出来
		CoordinateSystemCategory：构造函数，读取所有投影坐标系的名称，保存到Names列表中
		GetProjection：通过ProjectionInfo的名称，将其提取出来
		Names：当前集合下所有ProjectionInfo的名称列表
		ToArray：以数组的格式输出当前集合下的所有ProjectionInfo

        GeoGraphicSystems：类中包含了GeoGraphicCategories文件夹下所有的Categories，每个Category都是相关联的一系列已经名称和参数的ProjectionInfo，这个文件夹下的ProjectionInfo都是地理坐标系，使用经纬度表示，使用Proj4String初始化
		GetCategory：根据传入的名称获取Category
		Names:所有Catetories的名称列表
	
	ProjectedSystems：类似GeoGraphicSystems，对应的是ProjectedCategories文件夹，所有ProjectionInfo都是投影坐标系，同样使用Proj4String初始化 
		GetCategory：根据传入的名称获取Category
		Names:所有Catetories的名称列表
	
	KownCoordnateSsytems：将GeoGraphicSystems以及ProjectedSystems放到一个类里，即包含了所有内置的已经参数及名称的坐标系

	InitializeExternalGrids：到与DLL同路径下的GeogTransformGrids文件夹中，去找外部的GridShift文件，并将其读取出来，生成NadTable对象，加入到字典中
	
	ProjectionException：本DLL中包含的各类Exception，可以用整形的Code来初始化，每一个Code对应了一类Exception（类似Ora-&&&&），这些Exception对应的Message在ProjectionMessages.resx资源文件里

	InvalidEsriFormatException：读取EsriString出现错误（一般是指没有GEOGCS属性时）返回的Exception 
		
	PhiLam:经纬度
		Lambda：经度
		Phi：纬度
	
	GridShiftTableFormat：枚举值，GridShift文件的格式
		DAT:ntv1的DAT格式
		GSB:ntv2及其它的GSB格式
		LLA：
		LOS：NGS的LOS格式，一般都有对应的LAS文件

	NadTable：（可序列化的）是一个gridshift文件的入口,gridshift文件包括多种格式，见GridShiftTableFormat
		DEG_TO_RAD：度到弧度的转换系数
		USecToRad：微秒（1e-6)到弧度的转换系数
		_cellSize:一个最小单元的经纬度变化量
		_cvs:矩阵转换系统
		_dataOffset:文件头的偏移值
		_fileIsEmbedded:是否为内置文件
		_filled:
		_format:lla文件的格式
		_gridFilePath:文件路径（外部文件的情况下）
		_lowerLeft:左下角的经纬度
		_name:名称
		_numLambdas:lambda（经度）方向上的坐标数量
		_numPhis:Phi（纬度）方向上的坐标数量
		_subGrids:子Table的列表
		_manifestResourceString：GridShift文件的路径（DLL内置文件的情况下）
		NadTable：构造函数，给_fileIsEmbedded,文件路径（内置或外部文件）,_dataOffset赋值
		ReadHeader：读取头文件（本类里为空，在子类中实现）
		FillData：读取信息（本类里为空，在子类中实现）
		FromSourceName：静态函数，根据输入的文件路径，读取并生成对应的NatTable（实际上是根据文件扩展名，生成子类的对象）
		ReadDouble：从传入的流中读取一个Double值
		GetDouble：将一个Byte数组转换为一个Double值
		GetStream:根据GridShift的文件路径，打开并返回一个Stream

	NadTables：用于描述NadTable集合的类
		_tables:字典，名称与NadTable的对应字典
		NadTables:构造函数，将DLL中内置的GridShift文件都读取出来，生成NadTable对象，加入到字典中

	GridShift:
		HUGE_VAL:Double类型的最大值，避免溢出
		MAX_TRY:9
		TOL：1E-12
		_shift:NadTables的对象，保存转换的数组
                Apply:根据NadTable作坐标转换，一次可以转换一组坐标，使用Inverse参数控制是正算还是反算
                Convert：子函数，将一个经纬度坐标按传入的NadTable转成新坐标，使用Inverse参数控制是正算还是反算
                NadInterpolate：依据NadTable插值
	
	AnalyticModes:？？枚举值，表示分析的方法？还是分析使用的参数
		IsAnalXlYl:使用经度分析？
		IsAnalXpYp:使用纬度分析？
		IsANalHk：？？
		IsAnalConv：？？
	
	Factors：？？运算需要用到的一些参数？
		A:最大比例误差？
		B：最小比例误差？
		Code:AnalyticModes的对象
		Conv：收敛？
		H:经线方向的比例
		K：平行方向的比例
		Omega：角度变形
		S:面积变形因子
		Thetap：？？
		Xl：X经度的收敛因子？
		Xp:X纬度的收敛因子？
		Yl：Y经度的收敛因子？
		Yp：Y纬度的收敛因子？
	
	ITransform:接口，功能为在一个投影坐标系下实现经纬度和投影坐标互转
		Init：输入ProjectInfo，初始化Tranform
		Forward：从经纬度(lp)计算投影坐标(xy)
		Inverse:从投影坐标(xy)计算经纬度(lp)
		Special:
		Name:名称（ESRI wkt名称）
		Proj4Name：在Proj4库下的名称
		Proj4Aliases：在Proj4库下的别称，这个不会用于写Proj4String，但在读取时可能会用到
	
	Transform：实现了ITransform接口，是一个通用类，其它相似类的基类
		HAFL_PI：二分之PI
		FORT_PI：四分之PI
		TWO_PI：二PI
		EPS10:1E-10
		IS_ANAL_HK、IS_ANAL_CONV、IS_ANAL_XL_YL、IS_ANAL_XP_YP：与AnalyticModes类似的整形标识
		RAD_TO_DEG：1弧度对应多少角度
		DEG_TO_RAD：1角度对应多少弧度
		LAMBDA：整型，经度值在大地坐标数组中的序号
		PHI：整型，纬度值在大地坐标数组中的序号
		X：整型，X坐标在投影坐标数组中的序号
		Y：整型，Y坐标在投影坐标数组中的序号
		R:整型，实部在复数数组中的序号
		I：整型，虚部在复数数组中的序号
		A:主轴，椭球的赤道半径
		Ra：1/a
		OneEs:1-Es
		ROneEs:1/OneEs
		E:偏心率
		IsElliptical：布尔值，椭球是否为两极略扁的椭球
		Es：偏心率的平方
		Phi0：中央纬度
		Lam0：中央经度
		X0：假东
		Y0：假北
		K0：比例因子
		ToMeter:单位到米的缩放量
		FromMeter：从米到本单位的缩放量
		B:椭球的极半径
		Modes:枚举值，南极点，北极点，赤道，斜轴
		Init:函数，从传入的ProjectInfo中，读取并赋Es,Lam0,Phi0,X0,Y0,K0,A,B,E,Ra,OneEs,ROneEs,ToMeter,FromMeter,IsElliptical等值，最后调用虚函数OnInit，该函数由各子类具体实现
		Forward：调用了虚函数OnForward，该函数由各子类具体实现，并处理了一下最后输出的结果
		Inverse：同Forward函数
		Special:调用了虚函数OnSpecial，该函数由各子类具体实现
		FromKnownTransform：传入一个预定义好的Transform的枚举值，根据该枚举值生成对应的Tranform对象
		Name、Proj4Name、Prj4Aliases：同接口定义

	KnownTransform：枚举值，列举了所有预定义好的Transform

	TransformManager：
		TransformManager：构造函数，将所有预定义好的Tranform都加入到列表_transforms中
		_transforms:预定义好的所有Transform列表
		DefaultTransformManager：单例程模式，保证只有一个对象
		GetProj4：根据给出的Proj4名称（查找ITransform的Proj4Name和Proj4Aliases），返回对应的Transform
		GetProjection：根据给出的EsriName，查找ITransform的Name属性，返回对应的Transform
	
	Proj:一些在坐标转换及运算中常用的静态函数
		ONE_TOL：即1，但包含一个1E-14的允许误差
		ATOL：1E-50
		R：0
		I:1
		Aasin：即arcsin,带ONE_TOL的允许误差
		Aacos：即arccos,带ONE_TOL的允许误差
		Asqrt：平方根，如果传入值小于0，则返回0
		Aatan2：两参数商的反正切，如果一个数过小（小于ATOL），则返回0
		Hypot：根号x平方加y平方，即勾股求斜边
		Adjlon：将一个弧度值转到其等价的-PI到PI之间的值
		Authset：？？从等积纬度算纬度
		AuthLat：？？计算等积纬度
		Enfn:从Meridional distance中获取En参数
		Mlfn:计算Meridional distance
		InvMlfn：从Meridian distance反算角度距离
		Qsfn:？？
		Tsfn:？？
		Msfn：？？
		Phi2:？？
		Zpoly1：？？
		Zpolyd1：？？
	
	MeridionalDistance：子午线距离的计算相关函数和值（子午线距离：给出椭球下某个纬度，该纬线上任意一点沿过该点的经线方向到赤道的表面距离）
		GetEn：传入偏心率平方，得到计算子午线距离的一些中间参数
		MeridionalLength：计算子午线距离，传入的参数分别为纬度，纬度的Sin值，纬度的Cos值，通过GetEn函数得到的参数
		AngularDistance：给出子午线距离，反算所在的纬度，传入的参数为子午线距离，偏心率的平方，通过GetEn函数得到的参数

	GeocentricGeodetic：地心坐标到大地坐标的转换（大地坐标为经度，纬度，大地高，地心坐标系为X,Y,Z）
                GeodeticToGeocentric：大地坐标向地心坐标转换
                GeocentricToGeodetic：地心坐标向大地坐标转换

	IDatumTransform：基准面转换接口
                Transform函数：参数为：源基准面，目标基准面，三维坐标列表（XY一般为经纬度），开始序号及点数

	DatumTransform：基准面转换类，实现了IDatumTranform接口，但实际上在Reproject.cs好像基本没有用到（Reproject.cs里面做基准面转换好像基本都是用的该类里的DatumTransform函数）
                _aiDts：IDatumTransformStage的列表，表示该转换需要用到多少个步骤，按该步骤完成整个转换
                Transform：实现IDatumTransform接口的对应函数，实现基准面转换，两种情况，如果基准面转换需要用到的是Gridshift模式，那么直接使用经纬度，查Gridshift表，完成转换（转换完成也是经纬度），如果使用三参数或七参数，那么需要先将源坐标（大地经纬度）转到源基准的地心坐标系，再将该地心坐标系转到WGS84，再将WGS84转到目标坐标系的地心坐标，再将该地心坐标转到目标坐标系的大地经纬度
                ApplyParameterizedTransform：三参数或七参数转换的函数

	IDatumTransformStage：变换步骤，一次基准面转换可能会涉及多个步骤，比如，先从54转到WGS84，再从WGS84转到NAD27，因为Proj里记录基准面的转换关系时，记录的都是该坐标与WGS84之间的转换关系。
                FromDatum：源基准面的描述信息
                ToDatum：目标基准面的描述信息
                Method：TransformMethod，转换的方法 
                DeltaX，DeltaY，DeltaZ：原点偏移
                RotateX，RotateY，RotateZ：三个轴向旋转
                DeltaScale：缩放比例
                GridShiftTable：Table的名称
                ApplyTableInverse：如果是True，GridTable使用时，必须与FromDatum&ToDatum定义的转换方向相反
                FromSpheroid：源基准面对应的椭球
                ToSpheroid：目标基准面对应的椭球

	DatumTransformStage：貌似和IDataumTransformStage差不多

	TransformMethod：枚举值，基准面转换的方法
                Gridshift：查表
                Param3：三参数转换
                Param7：七参数转换

        IReproject：坐标系转换接口，没有用到
          
        Reproject：坐标转换类
                EPS：在投影坐标与经纬度转换时用到的限差
                ReprojectAffine：转换变换参数，这里的变换参数是表示影像的六参数，本函数将这六个参数由源坐标系转到目标坐标系
                ReprojectPoints：对点列的坐标系转换，参数包括：点列的XY坐标，点列的Z坐标，源投影，源投影Z值单位与米之间的换算关系，目标投影，目标投影Z值单位与米之间的换算关系，IDatumTranform接口，待转换的起始点，待转换点数。其中某些参数可以为空，比如两个Z值换算关系为空时默认为0，IDatumTransform接口为空时，就不使用该接口提供的基准面转换函数，而使用本类自己的转换函数DatumTransform。
                 大致流程为：输入的是源投影下的投影坐标，如果源投影下是地心坐标（这个很少，基本没有用到，本DLL中也没有给出定义投影为地心坐标的方法，这个地方也有一定的问题，如果是大地坐标，那么转出的大地坐标为经纬度，到下一步再投影转经纬度时可能会出错），转到大地坐标；将投影转到经纬度；如果需要的话，做基准面转换（基准面转换是从源经纬度到目标投影对应的经纬度，具体流程可以参考DatumTransform类中的流程，本类中的基准面转换函数有两种可能，如果定义了IDatumTransform接口，那么就用该接口提供的方法，如果为空，那么用本类自己的转换参数，其流程是差不多的）；转换到目标投影的投影坐标；如果目标投影是地心坐标，那么再转到地心坐标（同上，基本没用）
                ConvertToProjected：经纬度转投影坐标，基本上是用目标投影ProjectInfo里的Transform函数
                DatumTransform：基准面转换，基本与DatumTransform类中的Transform函数流程相同
                ConvertToLatLon：投影坐标转经纬度，同样，基本上用投影ProjectInfo里的Inverse函数
                PjGeocentricToWgs84，PjGeocentricFromWgs84：三参数或七参数模型的情况下，地心坐标转到WGS84基准下的地心坐标，以及WGS84基准下地心坐标转到目标投影地心坐标的函数




		

