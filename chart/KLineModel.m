//
//  KLineModel.m
//  StockChart
//
//  Created by zhao on 16/8/3.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import "KLineModel.h"
#import <MJExtension.h>

@implementation KLineModel

- (NSArray *)data
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //NSLog(@"kline:%lu", _data.count);
    for(int i=0; i<_data.count; i++)
    {
        KLineDataModel *dataModel = [[KLineDataModel alloc] init];
        
        NSArray *dataArr = _data[i];
        dataModel.time = [self convertTime:dataArr[0]];
        dataModel.openPrice = [NSString stringWithFormat:@"%@",dataArr[1]];
        dataModel.heightPrice = [NSString stringWithFormat:@"%@",dataArr[2]];
        dataModel.lowPrice = [NSString stringWithFormat:@"%@",dataArr[3]];
        dataModel.closePrice = [NSString stringWithFormat:@"%@",dataArr[4]];
        
        [array addObject:dataModel];
    }
    return array;
}

- (NSString *)convertTime:(NSNumber *)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(time.doubleValue/1000 -8*3600)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"HH:mm"];
    return [formatter stringFromDate:date];
}

@end


@implementation KLineDataModel



@end