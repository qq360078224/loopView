//
//  XQLoopView.h
//  三个View轮播
//
//  Created by 都市蚂蚁 on 2017/1/9.
//  Copyright © 2017年 com.dingqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XQLoopView : UIView

/// click action
@property (nonatomic, copy) void (^clickAction) (NSInteger curIndex) ;
/// data source
@property (nonatomic, copy) NSArray *imageURLStrings;
// index
@property (nonatomic, assign) NSInteger curIndex;
/// scroll duration 设置了时间,就会启动定时器,不设置就不会
@property (nonatomic, assign) NSTimeInterval scrollDuration;
@end
