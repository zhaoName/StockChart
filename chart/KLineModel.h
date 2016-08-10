//
//  KLineModel.h
//  StockChart
//
//  Created by zhao on 16/8/3.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KLineDataModel;
@interface KLineModel : NSObject

@property (nonatomic, strong) NSString *status; /**< 返回状态*/
@property (nonatomic, strong) NSString *msg; /**< 状态消息*/
@property (nonatomic, strong) NSArray *data; /**< K线图数据*/

@end



@interface KLineDataModel : NSObject

@property (nonatomic, strong) NSString *time; /**< 时间*/
@property (nonatomic, strong) NSString *openPrice; /**< 开盘价*/
@property (nonatomic, strong) NSString *closePrice; /**< 收盘价*/
@property (nonatomic, strong) NSString *heightPrice; /**< 每根K线的最高价*/
@property (nonatomic, strong) NSString *lowPrice; /**< 每根K线的最低价*/

@end