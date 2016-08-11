//
//  BrokenLineModel.h
//  StockChart
//
//  Created by zhao on 16/8/3.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BrokenLineDataModel;
@interface BrokenLineModel : NSObject

@property (nonatomic, strong) NSString *symbol; /**< 报价源*/
@property (nonatomic, strong) NSString *status; /**< 返回状态*/
@property (nonatomic, strong) NSString *msg; /**< 状态消息*/
@property (nonatomic, strong) NSString *t1; /**< 品种别名*/
@property (nonatomic, strong) NSString *t2; /**< 品种别名*/
@property (nonatomic, strong) NSArray *data; /**< 折线图数据*/

@end

/************************************************/

@interface BrokenLineDataModel : NSObject

@property (nonatomic, strong) NSString *number; /**< 每个点时间*/
@property (nonatomic, strong) NSString *value; /**< 每个点价格*/

@end