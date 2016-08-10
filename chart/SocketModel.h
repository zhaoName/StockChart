//
//  SocketModel.h
//  StockChart
//
//  Created by zhao on 16/8/9.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketModel : NSObject

@property (nonatomic, strong) NSString *price; /**< 实时价格*/
@property (nonatomic, strong) NSString *direc; /**< 控制实时价格线的颜色 1:绿色 0:灰色 -1:红色*/
@property (nonatomic, strong) NSString *time; /**< 时间*/
@property (nonatomic, strong) NSString *type; /**< 控制画K线的进度 0:开始画 1:结束画 2:画线一根K线*/
@property (nonatomic, strong) NSString *key; /**< 品种*/

@end
