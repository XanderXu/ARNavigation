//
//  Tools.m
//  ARNavigation
//
//  Created by CoderXu on 2019/10/23.
//  Copyright © 2019 XanderXu. All rights reserved.
//

#import "Tools.h"

@implementation Tools
+(BMKMapPoint *)creatMapPoints:(NSUInteger)count {
    BMKMapPoint * points= new BMKMapPoint[count];
    return points;
}
@end
