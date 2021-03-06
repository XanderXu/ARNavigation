# BaiduMapKit

百度地图 iOS SDK(官方)

--------------------------------------------------------------------------------------

iOS 地图 SDK v5.0.0是适用于iOS系统移动设备的矢量地图开发包

--------------------------------------------------------------------------------------

地图SDK功能介绍（全功能开发包）：

地图：提供地图展示和地图操作功能；

POI检索：支持周边检索、区域检索和城市内兴趣点检索；

地理编码：提供经纬度和地址信息相互转化的功能接口；

线路规划：支持公交、驾车、步行三种方式的线路规划；

覆盖物图层：支持在地图上添加覆盖物（标注、几何图形、热力图、地形图图层等），展示更丰富的LBS信息；

定位：获取当前位置信息，并在地图上展示（支持普通、跟随、罗盘三种模式）；

离线地图：使用离线地图可节省用户流量，提供更好的地图展示效果；

调启百度地图：利用SDK接口，直接在本地打开百度地图客户端或WebApp，实现地图功能；

周边雷达：利用周边雷达功能，开发者可在App内低成本、快速实现查找周边使用相同App的用户位置的功能；

LBS云检索：支持查询存储在LBS云内的自有数据；

特色功能：提供短串分享、Place详情检索、热力图等特色功能，帮助开发者搭建功能更加强大的应用；


--------------------------------------------------------------------------------------
 
 
 【 温 馨 提 示 】
 【 注 意 】
 1、自v3.2.0起，百度地图iOS SDK全面支持HTTPS，需要广大开发者导入第三方openssl静态库：libssl.a和libcrypto.a（存放于thirdlib目录下）
 添加方法：在 TARGETS->Build Phases-> Link Binary With Libaries中点击“+”按钮，在弹出的窗口中点击“Add Other”按钮，选择libssl.a和libcrypto.a添加到工程中 。
 
 2、支持CocoaPods导入
 pod setup //更新CocoPods的本地库
 pod search BaiduMapKit  //查看最新地图SDK
 
 v5.0.0版本：
 
【注意事项】

 1.新引入系统库libz.tbd。
 
 2.Overlay线宽变细，lineWidth统一为画笔宽度。
 
 3.步骑行导航适配App Store关于新的后台定位的审核机制，有后台定位需求的开发者请通过doRequestAlwaysAuthorization代理方法调用后台定位API：[locationManager requestAlwaysAuthorization]。

 【新 增】
 
 1.个性化地图支持多地图多样式，新增加载在线个性化样式接口。
 
 2.新增Polygon、Circle镂空绘制功能，镂空区域支持polygon(多边形)和circle(圆)图形。
 
 3.新增Polyline拐角样式，支持平角、尖角和圆角。
 
 4.新增Polyline头尾样式，支持普通头和圆形头。
 
 5.新增Overlay虚线样式，支持方块样式和圆点样式。
 
 6.新增OpenGL映射矩阵(getProjectionMatrix)和视图矩阵(getViewMatrix)接口，用于3D绘制场景。
 
 7.新增地理矩形区域面积、多边形面积计算工具。
 
 8.新增坐标方向计算工具。
 
 9.逆地理编码服务返回poi类型字段(tag，如：”美食;中餐厅“)
 
 【优 化】
 
 1.优化地图进入/移出室内图时调用的接口。
 
 2.优化手势操作造成的地图区域的变化回调原因不准确的问题。
 
 3.优化地图等级level设置，标准地图可设置范围为4-21，室内图开启时可设置的最大值为22。
 
 【修 复】
 
 1.修复BMKMapView与UIScrollView手势响应冲突的问题。
 
 2.修复BMKAnnotationView的selected属性默认设置为YES不起作用的问题。
 
 3.修复当前定位点图标在旋转地图后部分被精度圈遮挡的问题。
 
 4.修复自定义热力图频繁切换切换造成crash的问题。
 
 5.修复骑行导航返回时间信息有误的问题。
 
 6.修复其他已知问题。
 
------------------------------------------------------------------------------------------------
