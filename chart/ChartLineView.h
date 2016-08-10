//
//  ChartLineView.h
//  StockChart
//
//  Created by zhao on 16/8/2.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tools.h"

@interface ChartLineView : UIView

@property (nonatomic, assign) ChartLineType lineType;

@property (nonatomic, strong) UIColor *xyLineColor;/**< xy轴的颜色*/
@property (nonatomic, assign) CGFloat xyLineWidth;/**< xy轴的宽度*/

@property (nonatomic, assign) CGFloat KLineWidth;/**< K线图的宽度*/
@property (nonatomic, assign) CGFloat brokenLineWidth;/**< 折线图的宽度*/

@property (nonatomic, strong) NSMutableArray *xPoints;/**< x轴上的点*/
@property (nonatomic, strong) NSMutableArray *yPoints;/**< y轴上的点*/

@property (nonatomic, strong) NSArray *kLinePoints;/**< K线图上的坐标点*/
@property (nonatomic, strong) NSArray *brokenLinePoints;/**< 分时图的坐标点*/

@end
