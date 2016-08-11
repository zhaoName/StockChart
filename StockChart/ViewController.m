//
//  ViewController.m
//  StockChart
//
//  Created by zhao on 16/8/2.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import "ViewController.h"
#import "FrameView.h"
#import <GCDAsyncSocket.h>
#import <MJExtension.h>
#import "SocketModel.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) FrameView *frameView;
@property (nonatomic, strong) GCDAsyncSocket *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1];
    
    //画图表
    [self.view addSubview:self.frameView];
    [self.frameView startDrawFramework];
    
    //socket
    [self connectSocket];
}

#pragma mark -- socket
/**
 *  建立socket链接
 */
- (void)connectSocket
{
    NSError *error = nil;
    [self.socket connectToHost:@"121.127.248.176" onPort:3001 error:&error];
}

//链接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(nonnull NSString *)host port:(uint16_t)port
{
    NSLog(@"socket链接成功");
    [self.socket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:100];
}

//读取服务端推送过来的数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if(tag == 100)
    {
        SocketModel *model = [SocketModel mj_objectWithKeyValues:data];
        if([model.key isEqualToString:@"EURUSD"])//欧元/美元
        {
            //NSLog(@"%@ %@ %@", model.key, model.price, model.type);
            [self.frameView updataPriceLineWithPriceFromSocket:model];
        }
        [self.socket readDataToData:[GCDAsyncSocket LFData] withTimeout:-1 tag:100];
    }
}

//socket断开链接后的回调
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"socket断开链接：%@", err);
}

#pragma mark -- getter

- (FrameView *)frameView
{
    if(!_frameView)
    {
        _frameView = [[FrameView alloc] initWithFrame:CGRectMake(15, 64+30, SCREEN_WIDTH - 20, (SCREEN_WIDTH - 20)/7*6)];
        _frameView.backgroundColor = [UIColor clearColor];
        
        _frameView.xyLineColor = [UIColor lightGrayColor];
        _frameView.xyLineWidth = 1.0;
        
        _frameView.KLineWidth = 3.0;
        _frameView.brokenLineWidth = 1.0;
    }
    return _frameView;
}

- (GCDAsyncSocket *)socket
{
    if(!_socket)
    {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}

@end
