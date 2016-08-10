//
//  ChartLineView.m
//  StockChart
//
//  Created by zhao on 16/8/2.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import "ChartLineView.h"

@implementation ChartLineView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(self.xPoints.count && self.yPoints.count)
    {
        [self drawFrameworkView:context];
    }
    else
    {
        if(self.lineType == ChartLineTypeKLine)
        {
            [self drawKLine:context];
        }
        else if (self.lineType == ChartLineTypeBrokenLine)
        {
            [self drawBrokenLine:context];
        }
    }
}

/** 画框架*/
- (void)drawFrameworkView:(CGContextRef)context
{
    CGContextSetAlpha(context, 0.4);//透明度
    CGContextSetLineWidth(context, self.xyLineWidth);//轴线宽
    [self.xyLineColor setStroke];//轴线颜色
    //画X轴
    for(NSArray *xArr in self.xPoints)
    {
        CGPoint startPoint = [xArr[0] CGPointValue];
        CGPoint endPoint = [xArr[1] CGPointValue];
        //NSLog(@"%@ %@", NSStringFromCGPoint(startPoint), NSStringFromCGPoint(endPoint));
        CGContextMoveToPoint(context, startPoint.x, startPoint.y); //起点
        CGContextAddLineToPoint(context, endPoint.x, endPoint.y); //终点
        
        CGContextStrokePath(context); //开始画
    }
    
    //画Y轴
    for(NSArray *yArr in self.yPoints)
    {
        CGPoint point[] = {[yArr[0] CGPointValue], [yArr[1] CGPointValue]};
        CGContextStrokeLineSegments(context, point, 2);
    }
}

/**
 *  画K线
 */
- (void)drawKLine:(CGContextRef)context
{
    if(self.kLinePoints.count == 0) return;
    
    //NSLog(@"klinePoints:%lu", self.kLinePoints.count);
    for(NSArray *points in self.kLinePoints)
    {
        CGPoint openPoint = [points[0] CGPointValue];
        CGPoint closePoint = [points[1] CGPointValue];
        CGPoint heightPoint = [points[2] CGPointValue];
        CGPoint lowPoint = [points[3] CGPointValue];
        
        UIColor *color = [UIColor redColor]; //默认红色 即收盘价高于开盘价
        if(closePoint.y > openPoint.y)
        {
            color = [UIColor greenColor]; //收盘价低于开盘价 是绿色 但是y值越大对应坐标值越小
        }
        
        [color setStroke]; //设置颜色
        //画一条垂线包括上影线 下影线
        CGContextSetLineWidth(context, 1); //线宽
        CGContextMoveToPoint(context, heightPoint.x, heightPoint.y);
        CGContextAddLineToPoint(context, lowPoint.x, lowPoint.y);
        CGContextStrokePath(context);
        
        //画中间的实体线
        CGContextSetLineWidth(context, self.KLineWidth);
        CGContextMoveToPoint(context, openPoint.x, openPoint.y);
        CGContextAddLineToPoint(context, closePoint.x, closePoint.y);
        CGContextStrokePath(context);
    }
}

/**
 *  画分时图
 */
- (void)drawBrokenLine:(CGContextRef)context
{
    if(self.brokenLinePoints.count == 0) return;
    
    //NSLog(@"brokenPoints:%lu", self.brokenLinePoints.count);
    CGContextSetLineWidth(context, self.brokenLineWidth); //线宽
    [[UIColor lightGrayColor] setStroke]; //线的颜色
    for(NSValue *value in self.brokenLinePoints)
    {
        CGPoint point = value.CGPointValue;
        //若是第一次 则当起点
        if([self.brokenLinePoints indexOfObject:value] == 0)
        {
            CGContextMoveToPoint(context, point.x, point.y);
            continue;
        }
        CGContextAddLineToPoint(context, point.x, point.y);
        CGContextStrokePath(context);
        //若不是最后一个坐标 则当下一次画线的起点
        if([self.brokenLinePoints indexOfObject:value] < self.brokenLinePoints.count)
        {
            CGContextMoveToPoint(context, point.x, point.y);
        }
    }
    
    CGPoint points[self.brokenLinePoints.count+2];
    for (int i = 0; i<self.brokenLinePoints.count; i++) {
        points[i] = [self.brokenLinePoints[i] CGPointValue];
    }
    points[self.brokenLinePoints.count] = CGPointMake(self.frame.size.width, self.frame.size.height);
    points[self.brokenLinePoints.count+1] = CGPointMake(0, self.self.frame.size.height);
    
    CGPoint point0 = [[self.brokenLinePoints objectAtIndex:0] CGPointValue];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, point0.x, point0.y);
    CGPathAddLines(path, NULL, points, self.brokenLinePoints.count+2);
    CGPathCloseSubpath(path);
    [self fillColorAtBrokenLine:context path:path]; //填充颜色
}

/**
 *  为分时图填充颜色
 */
- (void)fillColorAtBrokenLine:(CGContextRef)context path:(CGMutablePathRef)path
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat locations[] = {0.5, 1.0};
    NSArray *colors = @[(__bridge id) [UIColor greenColor].CGColor, (__bridge id) [UIColor blueColor].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGRect pathRect = CGPathGetBoundingBox(path);
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextSetAlpha(context, 0.7);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
