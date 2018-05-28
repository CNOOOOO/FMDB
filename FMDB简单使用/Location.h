//
//  Location.h
//  FMDB简单使用
//
//  Created by Mac1 on 2018/5/28.
//  Copyright © 2018年 Mac1. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (nonatomic, copy) NSString *latitude;//纬度
@property (nonatomic, copy) NSString *longitude;//经度
@property (nonatomic, copy) NSString *altitude;//海拔

@end
