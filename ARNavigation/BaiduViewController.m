//
//  BaiduViewController.m
//  ARNavigation
//
//  Created by CoderXu on 2019/10/18.
//  Copyright © 2019 XanderXu. All rights reserved.
//

#import "BaiduViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BMKLocationKit/BMKLocationComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import "Tools.h"



//复用annotationView的指定唯一标识
static NSString *annotationViewIdentifier = @"com.Baidu.BMKWalkingRouteSearch";
@interface BaiduViewController () <ARSCNViewDelegate,BMKLocationManagerDelegate,BMKMapViewDelegate, BMKRouteSearchDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (nonatomic, strong) SCNNode *targetNode;
@property (nonatomic, strong) SCNNode *guideNode;
@property (nonatomic, strong) BMKLocationManager *locationManager;
@property (nonatomic, strong) BMKMapView *mapView; //当前界面的mapView
@property (nonatomic, strong) BMKRouteSearch *walkingRouteSearch;
@property (nonatomic, strong) BMKUserLocation *userLocation;
@property (nonatomic, assign) BMKMapPoint *polylinePoints;
@property (nonatomic, assign) NSInteger pointCount;
@end

    
@implementation BaiduViewController
#pragma mark - Lazy loading
- (BMKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 500, self.view.frame.size.width, self.view.frame.size.height - 500)];
        
        //设置mapView的代理
        _mapView.delegate = self;
    }
    return _mapView;
}
- (BMKUserLocation *)userLocation {
    if (!_userLocation) {
        //初始化BMKUserLocation类的实例
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}
- (BMKLocationManager*)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[BMKLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.allowsBackgroundLocationUpdates = NO;
        _locationManager.locationTimeout = 10;
        
    }
    return _locationManager;
}
- (void)dealloc {
    NSLog(@"dealloc--baidu");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //将mapView添加到当前视图中
    [self.view addSubview:self.mapView];
    [[[CLLocationManager alloc] init] requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
    // Set the view's delegate
    self.sceneView.delegate = self;
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    // Create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // Set the scene to the view
    self.sceneView.scene = scene;
    self.targetNode = [scene.rootNode childNodeWithName:@"ship" recursively:YES];
    self.guideNode = [SCNNode node];
    [scene.rootNode addChildNode:self.guideNode];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //当mapView即将被显示的时候调用，恢复之前存储的mapView状态
    [_mapView viewWillAppear];
    
    // Create a session configuration
    AROrientationTrackingConfiguration *configuration = [AROrientationTrackingConfiguration new];
    configuration.worldAlignment = ARWorldAlignmentGravityAndHeading;
    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //当mapView即将被隐藏的时候调用，存储当前mapView的状态
    [_mapView viewWillDisappear];
    
    // Pause the view's session
    [self.sceneView.session pause];
}
- (IBAction)switchRoute:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self setupDefaultData];
    } else {
        [self setupDefaultData2];
    }
}
#pragma mark - Search Data
- (void)setupDefaultData {
    //初始化请求参数类BMKWalkingRoutePlanOption的实例
    BMKWalkingRoutePlanOption *walkingRoutePlanOption = [[BMKWalkingRoutePlanOption alloc] init];
    //实例化线路检索节点信息类对象
    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    //起点所在城市
    start.cityName = @"北京市";
    start.name = @"中航";
    //起点名称
    start.pt = self.userLocation.location.coordinate;
    //实例化线路检索节点信息类对象
    BMKPlanNode *end = [[BMKPlanNode alloc] init];
    //终点所在城市
    end.cityName = @"北京市";
    //终点名称
    end.name = @"天安门";
    //检索的起点，可通过关键字、坐标两种方式指定。cityName和cityID同时指定时，优先使用cityID
    walkingRoutePlanOption.from = start;
    //检索的终点，可通过关键字、坐标两种方式指定。cityName和cityID同时指定时，优先使用cityID
    walkingRoutePlanOption.to = end;
    [self searchData:walkingRoutePlanOption];
}
- (void)setupDefaultData2 {
    //初始化请求参数类BMKWalkingRoutePlanOption的实例
    BMKWalkingRoutePlanOption *walkingRoutePlanOption = [[BMKWalkingRoutePlanOption alloc] init];
    //实例化线路检索节点信息类对象
    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    //起点所在城市
    start.cityName = @"北京市";
    start.name = @"我的位置";
    //起点名称
    start.pt = self.userLocation.location.coordinate;
    //实例化线路检索节点信息类对象
    BMKPlanNode *end = [[BMKPlanNode alloc] init];
    //终点所在城市
    end.cityName = @"北京市";
    //终点名称
    end.name = @"广场";
    end.pt = CLLocationCoordinate2DMake(39.985668250592745, 116.5231768100081);
    //检索的起点，可通过关键字、坐标两种方式指定。cityName和cityID同时指定时，优先使用cityID
    walkingRoutePlanOption.from = start;
    //检索的终点，可通过关键字、坐标两种方式指定。cityName和cityID同时指定时，优先使用cityID
    walkingRoutePlanOption.to = end;
    [self searchData:walkingRoutePlanOption];
}
- (void)searchData:(BMKWalkingRoutePlanOption *)option {
    //初始化BMKRouteSearch实例
    _walkingRouteSearch = [[BMKRouteSearch alloc]init];
    //设置步行路径规划的代理
    _walkingRouteSearch.delegate = self;
    //初始化BMKPlanNode实例，检索起点
    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    //起点名称
    start.name = option.from.name;
    //起点所在城市，注：cityName和cityID同时指定时，优先使用cityID
    start.cityName = option.from.cityName;
    //起点所在城市ID，注：cityName和cityID同时指定时，优先使用cityID
    if ((option.from.cityName.length > 0 && option.from.cityID != 0) || (option.from.cityName.length == 0 && option.from.cityID != 0))  {
        start.cityID = option.from.cityID;
    }
    //起点坐标
    start.pt = option.from.pt;
    //初始化BMKPlanNode实例，检索终点
    BMKPlanNode* end = [[BMKPlanNode alloc] init];
    //终点名称
    end.name = option.to.name;
    //终点所在城市，注：cityName和cityID同时指定时，优先使用cityID
    end.cityName = option.to.cityName;
    //终点所在城市，注：cityName和cityID同时指定时，优先使用cityID
    if ((option.to.cityName.length > 0 && option.to.cityID != 0) || (option.to.cityName.length == 0 && option.to.cityID != 0))  {
        end.cityID = option.to.cityID;
    }
    //终点坐标
    end.pt = option.to.pt;
    //初始化请求参数类BMKWalkingRoutePlanOption的实例
    BMKWalkingRoutePlanOption *walkingRoutePlanOption = [[BMKWalkingRoutePlanOption alloc] init];
    //检索的起点，可通过关键字、坐标两种方式指定。cityName和cityID同时指定时，优先使用cityID
    walkingRoutePlanOption.from = start;
    //检索的终点，可通过关键字、坐标两种方式指定。cityName和cityID同时指定时，优先使用cityID
    walkingRoutePlanOption.to = end;
    /**
     发起步行路线检索请求，异步函数，返回结果在BMKRouteSearchDelegate的onGetWalkingRouteResult中
     */
    BOOL flag = [_walkingRouteSearch walkingSearch:walkingRoutePlanOption];
    if (flag) {
        NSLog(@"步行检索成功");
    } else{
        NSLog(@"步行检索失败");
    }
}
#pragma mark - BMKLocationManagerDelegate
/**
 @brief 当定位发生错误时，会调用代理的此方法
 @param manager 定位 BMKLocationManager 类
 @param error 返回的错误，参考 CLError
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"定位失败");
}

/**
 @brief 该方法为BMKLocationManager提供设备朝向的回调方法
 @param manager 提供该定位结果的BMKLocationManager类的实例
 @param heading 设备的朝向结果
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    if (!heading) {
        return;
    }
//    NSLog(@"用户方向更新");
    
    [_mapView updateLocationData:self.userLocation];
    self.userLocation.heading = heading;
    
}

/**
 @brief 连续定位回调函数
 @param manager 定位 BMKLocationManager 类
 @param location 定位结果，参考BMKLocation
 @param error 错误信息。
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (!location) {
        return;
    }
    //第一次定位
    if (self.userLocation.location.coordinate.latitude == 0 && self.userLocation.location.coordinate.longitude == 0) {
        self.userLocation.location = location.location;
        [self setupDefaultData];
        
    }else {
        self.userLocation.location = location.location;
    }
    //实现该方法，否则定位图标不出现
    [_mapView updateLocationData:self.userLocation];
    
    
    NSLog(@"定位更新---%@",location);
    
    [self updateTargetNodePositionAndGuideLine];
    
}
#pragma mark - BMKRouteSearchDelegate
/**
 返回步行路线检索结果

 @param searcher 检索对象
 @param result 检索结果，类型为BMKWalkingRouteResult
 @param error 错误码，@see BMKSearchErrorCode
 */
- (void)onGetWalkingRouteResult:(BMKRouteSearch *)searcher result:(BMKWalkingRouteResult *)result errorCode:(BMKSearchErrorCode)error {
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        //+polylineWithPoints: count:坐标点的个数
        __block NSUInteger pointCount = 0;
        //获取所有步行路线中第一条路线
        BMKWalkingRouteLine *routeline = (BMKWalkingRouteLine *)result.routes.firstObject;
        //遍历步行路线中的所有路段
        [routeline.steps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //获取步行路线中的每条路段
            BMKWalkingStep *step = routeline.steps[idx];
            //统计路段所经过的地理坐标集合内点的个数
            pointCount += step.pointsCount;
        }];
        //+polylineWithPoints: count:指定的直角坐标点数组
        BMKMapPoint *points = [Tools creatMapPoints:pointCount];
        __block NSUInteger j = 0;
        //遍历步行路线中的所有路段
        [routeline.steps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //获取步行路线中的每条路段
            BMKWalkingStep *step = routeline.steps[idx];
            //遍历路段所经过的地理坐标集合
            for (NSUInteger i = 0; i < step.pointsCount; i ++) {
                //将每条路段所经过的地理坐标点赋值给points
                points[j].x = step.points[i].x;
                points[j].y = step.points[i].y;
                j ++;
            }
        }];
        self.polylinePoints = points;
        self.pointCount = pointCount;
        //根据指定直角坐标点生成一段折线
        BMKPolyline *polyline = [BMKPolyline polylineWithPoints:self.polylinePoints count: self.pointCount];
        /**
         向地图View添加Overlay，需要实现BMKMapViewDelegate的-mapView:viewForOverlay:方法
         来生成标注对应的View
         
         @param overlay 要添加的overlay
         */
        [self.mapView addOverlay:polyline];
        
        [self updateTargetNodePositionAndGuideLine];
        self.mapView.zoomLevel = 19;
    }
}

- (void)updateTargetNodePositionAndGuideLine {
    if (self.pointCount > 0 && !(self.userLocation.location.coordinate.latitude == 0 && self.userLocation.location.coordinate.longitude == 0)) {
        BMKMapPoint userPoint = BMKMapPointForCoordinate(self.userLocation.location.coordinate);
        // 百度地图上每一点，对应的真实距离，和纬度有关
        double metersPerMapPoint =  BMKMetersPerMapPointAtLatitude(self.userLocation.location.coordinate.latitude);
        
        // 更新 AR 中的终点
        double targetDisplayX = 0,targetDisplayY = 0;//AR显示终点的位置
        double targetDistance = BMKMetersBetweenMapPoints(userPoint, self.polylinePoints[self.pointCount - 1]);//终点的距离
        if (targetDistance > 20) {//超过了 20 米，放在 20 米处
            targetDisplayX = 20.0 / targetDistance * (self.polylinePoints[self.pointCount - 1].x - userPoint.x) * metersPerMapPoint;
            targetDisplayY = 20.0 / targetDistance * (self.polylinePoints[self.pointCount - 1].y - userPoint.y) * metersPerMapPoint;
        } else {
            targetDisplayX = (self.polylinePoints[self.pointCount - 1].x - userPoint.x) * metersPerMapPoint;//东西方向实际距离
            targetDisplayY = (self.polylinePoints[self.pointCount - 1].y - userPoint.y) * metersPerMapPoint;//南北方向实际距离
        }
         // 终点的显示位置
        self.targetNode.simdPosition = simd_make_float3(targetDisplayX, 0, targetDisplayY);
         // 终点的朝向，始终指向(0,0,0)点，即手机处
        [self.targetNode simdLookAt:simd_make_float3(0)];
        
        
        // 更新最近的 6 个点
        NSInteger displayCount = self.pointCount > 5 ? 6 : self.pointCount;//可能少于 6 个，以实际为准
        
        int tmp = 0;//记录已经跨过/绕过的点。用户绕过2，3，4 个点也能正常导航。一次绕过 6 个点则认为偏航，需重新规划路线
        for (int i = 1; i <= displayCount; i++) {
            double distance = BMKMetersBetweenMapPoints(userPoint, self.polylinePoints[i]);
            if (distance < 20 && self.pointCount > 1) {//走到最近 6 个点附近时，跨越太靠近的点，如果只剩最后一个点不再跨越
                tmp = i;
            }
        }
        self.pointCount -= tmp;//跨过太近的若干个点
        self.polylinePoints += tmp;//跨过太近的若干个点
        
        //刷新地图polyline路线显示
        [self.mapView removeOverlays:self.mapView.overlays];
        //根据指定直角坐标点生成一段折线
        BMKPolyline *polyline = [BMKPolyline polylineWithPoints:self.polylinePoints count: self.pointCount];
        [self.mapView addOverlay:polyline];
        //再画一根，从自己位置到最近的点
//        BMKMapPoint *pointsMe = [Tools creatMapPoints:2];
//        pointsMe[0] = userPoint;
//        pointsMe[1] = self.polylinePoints[0];
//        BMKPolyline *polylineMe = [BMKPolyline polylineWithPoints:pointsMe count:2];
//        [self.mapView addOverlay:polylineMe];
        self.mapView.zoomLevel = 19;
        
        // 删除旧AR箭头（和测试用的 6 个轨迹点）
        NSArray *childNodes = self.guideNode.childNodes.copy;
        SCNNode *arrowNode;
        if (childNodes.count) {
            for (SCNNode *node in childNodes) {
                [node removeFromParentNode];
                if ([node.name isEqualToString:@"arrow"]) {
                    arrowNode = node;//重用旧的箭头
                }
            }
        } else if (!arrowNode){
            // Create a new scene
            SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/arrow.dae"];
            arrowNode = [scene.rootNode childNodeWithName:@"arrow" recursively:YES];
            arrowNode.name = @"arrow";
        }
        
        // 为最近的 6 个点添加 AR 箭头
        BMKMapPoint *closeSix = self.polylinePoints;// 下一次显示的，附近的 6 个点
        displayCount = self.pointCount > 5 ? 6 : self.pointCount;//可能少于 6 个，以实际为准
        
        // 第一次起点，在手机下方 1 米处
        simd_float3 beginPosition = simd_make_float3(0,-1, 0);
        for (int i = 0; i < displayCount; i++) {//6个最近点之间连线
            float displayX = (closeSix[i].x - userPoint.x) * metersPerMapPoint * 0.1;//AR 中缩小 10 倍显示
            float displayY = (closeSix[i].y - userPoint.y) * metersPerMapPoint * 0.1;//AR 中缩小 10 倍显示
            simd_float3 endPosition = simd_make_float3(displayX,-1,displayY);//终点
            
            float displayDistance = simd_fast_distance(beginPosition,endPosition);
            for (int j = 1; j < displayDistance * 2; j++) {//0.5米放一个
                SCNNode *cloneNode = [arrowNode clone];
                // 对 x,z 进行插值
                float x = 0.5 * j / displayDistance * (endPosition.x - beginPosition.x) + beginPosition.x;
                float z = 0.5 * j / displayDistance * (endPosition.z - beginPosition.z) + beginPosition.z;
                
                // 每个箭头的位置
                cloneNode.simdPosition = simd_make_float3(x, -1, z);
                [cloneNode simdLookAt:endPosition];//箭头指向终点方向
                [self.guideNode addChildNode:cloneNode];
            }
            
            // 测试用，显示轨迹点
            SCNNode *tempNode = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:0.1 height:0.1 length:0.1 chamferRadius:0]];
            [self.guideNode addChildNode:tempNode];
            tempNode.simdPosition = endPosition;
            tempNode.geometry.materials.firstObject.diffuse.contents = [UIColor redColor];
            
            beginPosition = endPosition;//将这个终点做为新的起点，开启下一轮循环添加箭头
        }
        
        
    }
}
//根据polyline设置地图范围
- (void)mapViewFitPolyline:(BMKPolyline *)polyline withMapView:(BMKMapView *)mapView {
    double leftTop_x, leftTop_y, rightBottom_x, rightBottom_y;
    if (polyline.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyline.points[0];
    leftTop_x = pt.x;
    leftTop_y = pt.y;
    //左上方的点lefttop坐标（leftTop_x，leftTop_y）
    rightBottom_x = pt.x;
    rightBottom_y = pt.y;
    //右底部的点rightbottom坐标（rightBottom_x，rightBottom_y）
    for (int i = 1; i < polyline.pointCount; i++) {
        BMKMapPoint point = polyline.points[i];
        if (point.x < leftTop_x) {
            leftTop_x = point.x;
        }
        if (point.x > rightBottom_x) {
            rightBottom_x = point.x;
        }
        if (point.y < leftTop_y) {
            leftTop_y = point.y;
        }
        if (point.y > rightBottom_y) {
            rightBottom_y = point.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(leftTop_x , leftTop_y);
    rect.size = BMKMapSizeMake(rightBottom_x - leftTop_x, rightBottom_y - leftTop_y);
    UIEdgeInsets padding = UIEdgeInsetsMake(20, 10, 20, 10);
    [mapView fitVisibleMapRect:rect edgePadding:padding withAnimated:YES];
}
#pragma mark - BMKMapViewDelegate
/**
 根据anntation生成对应的annotationView
 
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        /**
         根据指定标识查找一个可被复用的标注，用此方法来代替新创建一个标注，返回可被复用的标注
         */
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
        if (!annotationView) {
            /**
             初始化并返回一个annotationView
             
             @param annotation 关联的annotation对象
             @param reuseIdentifier 如果要重用view，传入一个字符串，否则设为nil，建议重用view
             @return 初始化成功则返回annotationView，否则返回nil
             */
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier];
            NSBundle *bundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mapapi.bundle"]];
            NSString *file = [[bundle resourcePath] stringByAppendingPathComponent:@"images/icon_nav_bus"];
            //annotationView显示的图片，默认是大头针
            annotationView.image = [UIImage imageWithContentsOfFile:file];
        }
        return annotationView;
    }
    return nil;
}

/**
 根据overlay生成对应的BMKOverlayView
 
 @param mapView 地图View
 @param overlay 指定的overlay
 @return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        //初始化一个overlay并返回相应的BMKPolylineView的实例
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        //设置polylineView的画笔颜色
        polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:1];
        //设置polylineView的线宽度
        polylineView.lineWidth = 4.0;
        return polylineView;
    }
    return nil;
}
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated reason:(BMKRegionChangeReason)reason {
    if (reason == BMKRegionChangeReasonEvent) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (mapView.userTrackingMode != BMKUserTrackingModeFollowWithHeading) {
                mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;
                
            }
            
        });
    }
}
#pragma mark - ARSCNViewDelegate

/*
// Override to create and configure nodes for anchors added to the view's session.
- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    SCNNode *node = [SCNNode new];
 
    // Add geometry to the node...
 
    return node;
}
*/

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

@end
