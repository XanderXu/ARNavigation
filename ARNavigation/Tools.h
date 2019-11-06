//
//  Tools.h
//  ARNavigation
//
//  Created by CoderXu on 2019/10/23.
//  Copyright © 2019 XanderXu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
NS_ASSUME_NONNULL_BEGIN

@interface Tools : NSObject
// 创建一个长度为 count 的数组，用来存放BMKMapPoint结构体。返回数组地址
+(BMKMapPoint *)creatMapPoints:(NSUInteger)count;
@end

NS_ASSUME_NONNULL_END
