//
//  Tools.h
//  StockChart
//
//  Created by zhao on 16/8/3.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <UIKit/UIKit.h>

typedef void(^PostRequestSuccessBlock)(id response);
typedef void(^PostRequestFailureBlock)(NSError *error);

typedef NS_ENUM(NSUInteger, ChartLineType)
{
    ChartLineTypeKLine = 0,/**< K线图*/
    ChartLineTypeBrokenLine,/**< 分时图*/
};

@interface Tools : NSObject


+ (void)postRequestWithUrl:(NSString *)url parameter:(NSDictionary *)parameter success:(PostRequestSuccessBlock)success failure:(PostRequestFailureBlock)failure;

+ (UILabel *)createLabelWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor;

@end
