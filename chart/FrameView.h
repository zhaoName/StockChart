//
//  FrameView.h
//  StockChart
//
//  Created by zhao on 16/8/2.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tools.h"
#import "SocketModel.h"


@interface FrameView : UIView

@property (nonatomic, assign) ChartLineType lineType; /**< 图表类型 K线图或分时图*/
@property (nonatomic, strong) UIColor *xyLineColor; /**< X轴、Y轴的颜色 默认清灰色*/
@property (nonatomic, assign) CGFloat xyLineWidth; /**< x y轴的宽度*/

@property (nonatomic, assign) CGFloat KLineWidth;/**< K线图的宽度*/
@property (nonatomic, assign) CGFloat brokenLineWidth;/**< 折线图的宽度*/

@property (nonatomic, assign) CGFloat priceFromSocket; /**< 实时价格*/

/**
 *  开始画图表
 */
- (void)startDrawFramework;

/**
 *  实时价格更新 
 */
- (void)updataPriceLineWithPriceFromSocket:(SocketModel *)socketMdoel;

@end
