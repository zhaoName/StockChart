//
//  Tools.m
//  StockChart
//
//  Created by zhao on 16/8/3.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import "Tools.h"

@implementation Tools

+ (void)postRequestWithUrl:(NSString *)url parameter:(NSDictionary *)parameter success:(PostRequestSuccessBlock)success failure:(PostRequestFailureBlock)failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"application/json", nil];
    
    [manager POST:url parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
    }];
}

+ (UILabel *)createLabelWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    
    label.text = text;
    label.textColor = textColor;
    label.font = font;
    
    return label;
}

@end
