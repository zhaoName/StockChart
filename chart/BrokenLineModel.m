//
//  BrokenLineModel.m
//  StockChart
//
//  Created by zhao on 16/8/3.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import "BrokenLineModel.h"
#import <MJExtension.h>

@implementation BrokenLineModel


- (NSArray *)data
{
    //return [BrokenLineDataModel mj_objectArrayWithKeyValuesArray:_data];
    //这数据真坑爹
    NSMutableArray *array = [[NSMutableArray alloc] init];
    //NSLog(@"brokrn:%lu", _data.count);
    for(int i=0; i<_data.count; i++)
    {
        BrokenLineDataModel *dataModel = [[BrokenLineDataModel alloc] init];
        NSDictionary *dataDict = _data[i];
        
        dataModel.number = [self convertTime:dataDict[@"number"]];
        dataModel.value = dataDict[@"value"];
        
        [array addObject:dataModel ];
    }
    return array;
}

- (NSString *)convertTime:(NSNumber *)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(time.doubleValue/1000 -8*3600)];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"HH:mm"];
    //NSLog(@"brokenTime:%@", [formatter stringFromDate:date]);
    return [formatter stringFromDate:date];
}

@end


@implementation BrokenLineDataModel



@end