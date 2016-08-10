//
//  FrameView.m
//  StockChart
//
//  Created by zhao on 16/8/2.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import "FrameView.h"
#import "ChartLineView.h"
#import "KLineModel.h"
#import "BrokenLineModel.h"
#import <MJExtension.h>

#define SELF_WIDTH self.frame.size.width
#define SELF_HEIGHT self.frame.size.height

#define FRAME_WIDTH self.frameworkView.frame.size.width
#define FRAME_HEIGHT self.frameworkView.frame.size.height

@interface FrameView ()

@property (nonatomic, strong) NSArray *kDataArray; /**< K线图数据*/
@property (nonatomic, strong) NSArray *bDataArray; /**< 分时图数据*/

@property (nonatomic, strong) UIView *frameworkView;/**< 画轴线、Label的框架视图*/
@property (nonatomic, strong) UIView *longPressLine;/**< 长按后弹出的线*/
@property (nonatomic, strong) UIView *detailView;/**< 长按后显示的具体信息*/

@property (nonatomic, strong) UIView *priceLine; /**< 实时价格线*/
@property (nonatomic, strong) UILabel *priceLabel;/**< 显示实时价格的Label*/

@property (nonatomic, assign) CGFloat maxPrice;/**< 最大价格*/
@property (nonatomic, assign) CGFloat minPrice;/**< 最低价格*/
@property (nonatomic, strong) NSMutableArray *xyViewArr;/**< 装xy轴线子视图*/
@property (nonatomic, strong) NSMutableArray *chartViewArr;/**< 装图表子视图*/

@property (nonatomic, strong) UILabel *timeLabel; /**< 时间Label*/
@property (nonatomic, strong) UILabel *openLabel; /**< 开仓价Label*/
@property (nonatomic, strong) UILabel *closeLabel; /**< 平仓价Label*/
@property (nonatomic, strong) UILabel *heightLabel; /**< 高价Label*/
@property (nonatomic, strong) UILabel *lowLabel; /**< 低价Label*/

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView; /**< 网络加载指示器-菊花*/

@property (nonatomic, assign) BOOL isNeedDraw;

@end

@implementation FrameView

- (instancetype)initWithFrame:(CGRect)frame
{
    if([super initWithFrame:frame])
    {
        self.lineType = ChartLineTypeKLine;//默认显示K线图
        self.KLineWidth = 1.0;
        self.brokenLineWidth = 1.0;
        self.xyLineColor = [UIColor lightGrayColor];
        self.xyLineWidth = 1.0;
        
        [self addSubview:self.frameworkView];
        [self createLineButton];
    }
    return self;
}

- (void)startDrawFramework
{
    [self.frameworkView insertSubview:self.indicatorView atIndex:2];
    [self.indicatorView startAnimating];
    
    if(self.lineType == ChartLineTypeKLine)
    {
        [self getKLineNetworkData];//获取K线图的网络数据
    }
    else if (self.lineType == ChartLineTypeBrokenLine)
    {
        [self getBrokenLineNetworkData];//获取折线图的网络数据
    }
}

#pragma mark -- 创建区分图表的button
/**
 *  创建button 用于选择当前图表是K线图或是分时图
 */
- (void)createLineButton
{
    UIButton *lineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    lineButton.frame = CGRectMake(FRAME_WIDTH - 37, FRAME_HEIGHT - 31, 30, 26);
    [lineButton setImage:[UIImage imageNamed:@"candleChart"] forState:UIControlStateNormal];
    [lineButton addTarget:self action:@selector(touchLineButton:) forControlEvents:UIControlEventTouchUpInside];
    lineButton.selected = NO;
    lineButton.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:0.1];
    lineButton.layer.cornerRadius = 3;
    
    [self.frameworkView addSubview:lineButton];
}

- (void)touchLineButton:(UIButton *)btn
{
    self.isNeedDraw = NO;
    self.lineType = !btn.selected;//顺序别颠倒了
    btn.selected = !btn.selected;
    
    [btn setImage:[UIImage imageNamed:@"lineChart"] forState:UIControlStateSelected];
    [self startDrawFramework];
}

#pragma mark -- 网络数据
/** 
 * 获取K线图的网络数据 并画K线图
 */
- (void)getKLineNetworkData
{
    NSInteger kCount = FRAME_WIDTH / (self.KLineWidth + 2);
    //只请求1分钟的历史K线图
    NSDictionary *parameter = @{@"count":@(kCount), @"symbolID":@"10001", @"type":@"1"};
    
    [Tools postRequestWithUrl:@"http://demo.iemans.com/Handling/Get_History_Data_Line.ashx" parameter:parameter success:^(id response) {
        
        KLineModel *model = [KLineModel mj_objectWithKeyValues:response];
        if([model.status isEqualToString:@"200"]){
            self.kDataArray = model.data;
            NSLog(@"kline:%lu %lu", self.kDataArray.count, model.data.count);
            [self dealLineData];//处理K线图数据
            self.isNeedDraw = YES;
        }
        else{
            NSLog(@"KLine 网络异常");
        }
        
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
    } failure:^(NSError *error) {
        
        NSLog(@"KLineError:%@", error);
    }];
}
/**
 *  获取折线图的网络数据 并画分时图
 */
- (void)getBrokenLineNetworkData
{
    NSInteger bCount = FRAME_WIDTH / self.brokenLineWidth;
    NSDictionary *parameter = @{@"count":@(bCount), @"symbolID":@"10001"};
    [Tools postRequestWithUrl:@"http://demo.iemans.com/Handling/Get_History_Data.ashx" parameter:parameter success:^(id response) {
        
        BrokenLineModel *model = [BrokenLineModel mj_objectWithKeyValues:response];
        if([model.status isEqualToString:@"200"]){
            self.bDataArray = model.data;
            NSLog(@"bline:%lu %lu", self.bDataArray.count, model.data.count);
            [self dealLineData];
            self.isNeedDraw = YES;
        }
        else{
            NSLog(@"BrokenLine 网络异常");
        }
        
        [self.indicatorView stopAnimating];
        [self.indicatorView removeFromSuperview];
    } failure:^(NSError *error) {
        NSLog(@"BLineError:%@", error);
    }];
}

#pragma mark -- 画K线图 或分时图的框架
/**
 *  处理K线图或分时图数据
 */
- (void)dealLineData
{
    self.maxPrice = 0.0;
    self.minPrice = MAXFLOAT;
    //获取K线图价格的最大值和最小值
    if(self.lineType == ChartLineTypeKLine)
    {
        for(KLineDataModel *kDataModel in self.kDataArray)
        {
            //NSLog(@"%@", kDataModel.time);
            if(kDataModel.heightPrice.floatValue > self.maxPrice)
            {
                self.maxPrice = kDataModel.heightPrice.floatValue;
            }
            if(kDataModel.lowPrice.floatValue < self.minPrice)
            {
                self.minPrice = kDataModel.lowPrice.floatValue;
            }
        }
    }
    //获取分时图价格的最大值和最小值
    else if (self.lineType == ChartLineTypeBrokenLine)
    {
        for(BrokenLineDataModel *bDataModel in self.bDataArray)
        {
            //NSLog(@"%@ %@", bDataModel.value, bDataModel.number);
            if(bDataModel.value.floatValue > self.maxPrice)
            {
                self.maxPrice = bDataModel.value.floatValue;
            }
            if(bDataModel.value.floatValue < self.minPrice)
            {
                self.minPrice = bDataModel.value.floatValue;
            }
        }
    }
    
    //回到主线程 更新界面
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self drawFrameworkView];
    });
}

/** 画框架*/
- (void)drawFrameworkView
{
    //这里不能用self.subviews 否则不走ChartLineView的drawRect:方法 why？？？
    for(UIView *view in self.xyViewArr)
    {
        if([view isKindOfClass:[UILabel class]])
        {
            [view removeFromSuperview];
        }
        if([view isKindOfClass:[ChartLineView class]])
        {
            [view removeFromSuperview];
        }
    }
    [self.xyViewArr removeAllObjects];
    
    ChartLineView *lineView = [[ChartLineView alloc] initWithFrame:CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT+1)];
    lineView.backgroundColor = [UIColor clearColor];
    
    lineView.xPoints = [NSMutableArray array];
    lineView.yPoints = [NSMutableArray array];
    lineView.xyLineColor = self.xyLineColor;
    lineView.xyLineWidth = self.xyLineWidth;
    [self.frameworkView insertSubview:lineView atIndex:0];
    [self.xyViewArr addObject:lineView];
    
    //画X轴 和Y轴上的坐标点(Label)
    float xInterval = FRAME_HEIGHT / 7.0; //X轴的间距
    CGFloat priceInterval = (self.maxPrice - self.minPrice) / 7.0; //价格间隔
    //NSLog(@"价格：%f %f %f", self.maxPrice, self.minPrice, priceInterval);
    for(int i=0; i<8; i++)
    {
        NSMutableArray *xArr = [NSMutableArray array];
        [xArr addObject:[NSValue valueWithCGPoint:CGPointMake(0, xInterval*i)]];//起点
        [xArr addObject:[NSValue valueWithCGPoint:CGPointMake(FRAME_WIDTH, xInterval*i)]];//终点
        [lineView.xPoints addObject:xArr];
        
        //Y轴上的Label
        UILabel *yLabel = [Tools createLabelWithFrame:CGRectMake(0, 0, 55, 21) text:[NSString stringWithFormat:@"%.5f",self.maxPrice - priceInterval*i] font:[UIFont systemFontOfSize:14] textColor:[UIColor lightGrayColor]];
        //center的x值 是框架的宽度加上自身宽度的一半
        yLabel.center = CGPointMake(FRAME_WIDTH+27+2, xInterval*i);
        
        [self addSubview:yLabel];
        [self.xyViewArr addObject:yLabel];
    }
    
    //画Y轴 和X轴上的坐标点(Label)
    float yInterval = FRAME_WIDTH / 10.0; //Y轴间距
    
    for(int i=0; i<11; i++)
    {
        NSMutableArray *yArr = [NSMutableArray array];
        [yArr addObject:[NSValue valueWithCGPoint:CGPointMake(yInterval*i, 0)]];//起点
        [yArr addObject:[NSValue valueWithCGPoint:CGPointMake( yInterval*i, FRAME_HEIGHT)]];//终点
        
        [lineView.yPoints addObject:yArr];
        
        //X轴上的Label
        if(i%2 == 0)
        {
            UILabel *xLabel = [Tools createLabelWithFrame:CGRectMake(0, 0, 40, 21) text:nil font:[UIFont systemFontOfSize:14] textColor:[UIColor lightGrayColor]];
            xLabel.center = CGPointMake(yInterval*i+5, FRAME_HEIGHT+10+5);
            if(self.lineType == ChartLineTypeKLine)
            {
                NSInteger count = FRAME_WIDTH/(self.KLineWidth+2); //时间间隔
                KLineDataModel *kDataModel = self.kDataArray[(count-1)*i/10];//时间的个数 分5份作为X轴的坐标
                xLabel.text = kDataModel.time;
            }
            else if (self.lineType == ChartLineTypeBrokenLine)
            {
                NSInteger count = FRAME_WIDTH/self.brokenLineWidth; //时间间隔
                BrokenLineDataModel *bDataModel = self.bDataArray[(count-1)*i/10];//时间的个数 分5份作为X轴的坐标
                xLabel.text = bDataModel.number;
            }
            
            [self addSubview:xLabel];
            [self.xyViewArr addObject:xLabel];
        }
    }
    
    //删除上次创建的图表
    for (UIView *view in self.chartViewArr)
    {
        if([view isKindOfClass:[ChartLineView class]])
        {
            [view removeFromSuperview];
        }
    }
    [self.chartViewArr removeAllObjects];
    
    if(self.lineType == ChartLineTypeKLine){
        [self drawKLine];//画K线图
    }
    else if(self.lineType == ChartLineTypeBrokenLine){
        [self drawBrokenLine];//画分时图
    }
}

#pragma mark -- 画K线图

/** 画K线*/
- (void)drawKLine
{
    ChartLineView *kChartView = [[ChartLineView alloc] initWithFrame:self.frameworkView.bounds];
    [self.frameworkView insertSubview:kChartView atIndex:1];
    [self.chartViewArr addObject:kChartView];
    
    kChartView.backgroundColor = [UIColor clearColor];
    kChartView.lineType = ChartLineTypeKLine;
    kChartView.kLinePoints = [self convertKLineCoordinateToActualCoordinate];
    kChartView.KLineWidth = self.KLineWidth;
}

/**
 *  K线图坐标转换
 *
 *  @return 转换后的实际坐标数组
 */
- (NSArray *)convertKLineCoordinateToActualCoordinate
{
    NSMutableArray *kArray = [[NSMutableArray alloc] init];
    __block CGFloat x = self.KLineWidth/2;//横坐标
    
    [self.kDataArray enumerateObjectsUsingBlock:^(KLineDataModel *kDataModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableArray *array = [NSMutableArray array];
        //开盘价的纵坐标
        CGFloat yOpen = FRAME_HEIGHT - (kDataModel.openPrice.floatValue - self.minPrice)*FRAME_HEIGHT/(self.maxPrice - self.minPrice);
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x, yOpen)]];
        //收盘价的纵坐标
        CGFloat yClose = FRAME_HEIGHT - (kDataModel.closePrice.floatValue - self.minPrice)*FRAME_HEIGHT/(self.maxPrice - self.minPrice);
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x, yClose)]];
        //高价的纵坐标
        CGFloat yHeight = FRAME_HEIGHT - (kDataModel.heightPrice.floatValue - self.minPrice)*FRAME_HEIGHT/(self.maxPrice - self.minPrice);
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x, yHeight)]];
        //低价的纵坐标
        CGFloat yLow = FRAME_HEIGHT - (kDataModel.lowPrice.floatValue - self.minPrice)*FRAME_HEIGHT/(self.maxPrice - self.minPrice);
        [array addObject:[NSValue valueWithCGPoint:CGPointMake(x, yLow)]];
        
        [kArray addObject:array];
        x += self.KLineWidth + 2;//修改横坐标的值 即下一个K线的横坐标 每根K线的间距为2
    }];
    
    return kArray;
}

#pragma mark -- 画分时图

/** 画分时图*/
- (void)drawBrokenLine
{
    ChartLineView *bChartView = [[ChartLineView alloc] initWithFrame:self.frameworkView.frame];
    [self.frameworkView insertSubview:bChartView atIndex:1];
    [self.chartViewArr addObject:bChartView];
    
    bChartView.backgroundColor = [UIColor clearColor];
    bChartView.brokenLinePoints = [self convertBrokenLineCoordianteToActualCoordinate];
    bChartView.lineType = ChartLineTypeBrokenLine;
    bChartView.brokenLineWidth = self.brokenLineWidth;
}

/**
 *  分时图坐标转换
 *
 *  @return 转换后的坐标数组
 */
- (NSArray *)convertBrokenLineCoordianteToActualCoordinate
{
    NSMutableArray *bArray = [NSMutableArray array];
    __block CGFloat xPoint = 0.0; //横坐标的值
    
    [self.bDataArray enumerateObjectsUsingBlock:^(BrokenLineDataModel *bDataModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat yPoitn = FRAME_HEIGHT - (bDataModel.value.floatValue - self.minPrice)*FRAME_HEIGHT/(self.maxPrice - self.minPrice);
        [bArray addObject:[NSValue valueWithCGPoint:CGPointMake(xPoint, yPoitn)]];
        
        xPoint += self.brokenLineWidth; //改变横坐标的值 即下一个点横坐标的值
    }];
    
    return bArray;
}

#pragma mark -- 处理长按手势 显示具体信息
/**
 *  处理长按手势
 */
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPressGes
{
    if(longPressGes.state == UIGestureRecognizerStateBegan)//长按手势开始
    {
        //长按手势开始点击时 在self.frameworkView上的坐标
        CGPoint pressPoint = [longPressGes locationInView:self.frameworkView];
        [self.frameworkView addSubview:self.longPressLine];
        
        [self setLongPressGestureSubviewsAttribute:pressPoint];
    }
    else if (longPressGes.state == UIGestureRecognizerStateChanged)//长按手势移动
    {
        //长按手势移动时 在self.frameworkView上的坐标
        CGPoint pressPoint = [longPressGes locationInView:self.frameworkView];
        
        [self setLongPressGestureSubviewsAttribute:pressPoint];
    }
    else if (longPressGes.state == UIGestureRecognizerStateEnded)//长按手势结束
    {
        //长安手势结束 移除所有子控件
        [self.longPressLine removeFromSuperview];
        [self.detailView removeFromSuperview];
    }
}

/**
 *  添加长按后需要显示的子视图 并设置子视图的属性
 */
- (void)setLongPressGestureSubviewsAttribute:(CGPoint)pressPoint
{
    [self removeAllSubviews:self.detailView];//移除所有子视图
    
    if(self.lineType == ChartLineTypeKLine)
    {
        //详细信息view
        if(pressPoint.x >= FRAME_WIDTH/2){//点击位置在self.frameworkView的右半边 则detailView在左半边
            self.detailView.frame = CGRectMake(0, 5, FRAME_WIDTH/2, 60);
        }
        else{//点击位置在self.frameworkView的左半边 则detailView在有半边
            self.detailView.frame = CGRectMake(FRAME_WIDTH/2, 5, FRAME_WIDTH/2, 60);
        }
        [self.frameworkView addSubview:self.detailView];
        
        CGFloat subviewWidth = self.detailView.frame.size.width/2;
        //时间
        self.timeLabel = [Tools createLabelWithFrame:CGRectMake(subviewWidth - 20, 0, 40, 60/3) text:nil font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor]];
        [self.detailView addSubview:self.timeLabel];
        
        //开仓价
        self.openLabel = [Tools createLabelWithFrame:CGRectMake(0, 60/3, subviewWidth, 60/3) text:nil font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        [self.detailView addSubview:self.openLabel];
        
        //平仓价
        self.closeLabel = [Tools createLabelWithFrame:CGRectMake(0, 60/3*2, subviewWidth, 60/3) text:nil font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        [self.detailView addSubview:self.closeLabel];
        
        //高价
        self.heightLabel = [Tools createLabelWithFrame:CGRectMake(subviewWidth, 60/3, subviewWidth, 60/3) text:nil font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        [self.detailView addSubview:self.heightLabel];
        
        //低价
        self.lowLabel = [Tools createLabelWithFrame:CGRectMake(subviewWidth, 60/3*2, subviewWidth, 60/3) text:nil font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        [self.detailView addSubview:self.lowLabel];
        //展示详情信息
        [self showKLineDetail:pressPoint];
    }
    else if (self.lineType == ChartLineTypeBrokenLine)
    {
        //详细信息view
        if(pressPoint.x >= FRAME_WIDTH/2){ //点击位置在self.frameworkView的右半边 则detailView在左半边
            self.detailView.frame = CGRectMake(0, 5, FRAME_WIDTH/2, 21);
        }
        else{//点击位置在self.frameworkView的左半边 则detailView在有半边
            self.detailView.frame = CGRectMake(FRAME_WIDTH/2, 5, FRAME_WIDTH/2, 21);
        }
        [self.frameworkView addSubview:self.detailView];
        
        CGFloat subviewWidth = self.detailView.frame.size.width/2;
        //时间
        self.timeLabel = [Tools createLabelWithFrame:CGRectMake(10, 0, subviewWidth-10, 21) text:nil font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        [self.detailView addSubview:self.timeLabel];
        
        //价格
        self.openLabel = [Tools createLabelWithFrame:CGRectMake(subviewWidth, 0, subviewWidth, 21) text:nil font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor]];
        [self.detailView addSubview:self.openLabel];
        //展示详情信息
        [self showBrokenLineDetail:pressPoint];
    }
}

/**
 *  给K线图上的详情信息上的子视图 赋值
 */
- (void)showKLineDetail:(CGPoint)kPressPoint
{
    [self.kDataArray enumerateObjectsUsingBlock:^(KLineDataModel *kDataModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(kPressPoint.x < idx*(self.KLineWidth + 2) && kPressPoint.x > (idx-1)*(self.KLineWidth+2))
        {
            //设置弹出线frame
            self.longPressLine.frame = CGRectMake((idx-1)*(self.KLineWidth+2)+1, 0, 1, FRAME_HEIGHT);
            //赋值
            self.timeLabel.text = kDataModel.time;
            self.openLabel.text = [NSString stringWithFormat:@"开盘:%.5f", kDataModel.openPrice.floatValue];
            self.closeLabel.text = [NSString stringWithFormat:@"收盘:%.5f", kDataModel.closePrice.floatValue];
            self.heightLabel.text = [NSString stringWithFormat:@"高价:%.5f", kDataModel.heightPrice.floatValue];
            self.lowLabel.text = [NSString stringWithFormat:@"低价:%.5f", kDataModel.lowPrice.floatValue];
        }
    }];
}
/**
 *  给分时图上的详情信息上的子视图 赋值
 */
- (void)showBrokenLineDetail:(CGPoint)bPressPoint
{
    int idx = bPressPoint.x;
    if(idx < 0 || idx >= FRAME_WIDTH)
    {
        [self.detailView removeFromSuperview]; return;
    }
    //设置弹出线frame
    self.longPressLine.frame = CGRectMake(bPressPoint.x, 0, 1, FRAME_HEIGHT);
    
    BrokenLineDataModel *bDataModel = self.bDataArray[idx];
    self.timeLabel.text = [NSString stringWithFormat:@"时间:%@", bDataModel.number];
    self.openLabel.text = [NSString stringWithFormat:@"价格:%.5f", bDataModel.value.floatValue];
}

#pragma mark -- 实时价格

- (void)updataPriceLineWithPriceFromSocket:(SocketModel *)socketMdoel
{
    //随着实时价格的变动 实时价格线frame也在变动
    CGFloat y = FRAME_HEIGHT - (socketMdoel.price.floatValue - self.minPrice)*FRAME_HEIGHT/(self.maxPrice - self.minPrice);
    self.priceLine.frame = CGRectMake(0, y, FRAME_WIDTH, 1);
    [self addSubview:self.priceLine];
    
    self.priceLabel.center = CGPointMake(FRAME_WIDTH + 27, y);
    self.priceLabel.text = socketMdoel.price;
    [self addSubview:self.priceLabel];
    
    if ([socketMdoel.direc isEqualToString:@"1"]) //高于上一次显红色
    {
        self.priceLabel.backgroundColor = [UIColor redColor];
        self.priceLine.backgroundColor = [UIColor redColor];
    }
    else if ([socketMdoel.direc isEqualToString:@"0"]) //等于上一次显灰色
    {
        self.priceLabel.backgroundColor = [UIColor grayColor];
        self.priceLine.backgroundColor = [UIColor grayColor];
    }
    else if ([socketMdoel.direc isEqualToString:@"-1"])//低于上一次显绿色
    {
        self.priceLabel.backgroundColor = [UIColor greenColor];
        self.priceLine.backgroundColor = [UIColor greenColor];
    }
    
    //若实时价格大于现有价格的最大值 则更新坐标系(框架)
    if(socketMdoel.price.floatValue > self.maxPrice)
    {
        self.maxPrice = socketMdoel.price.floatValue;
        [self updateFrameworkView];
    }
    //若实时价格小于现有价格的最小值 则更新坐标系(框架)
    else if(socketMdoel.price.floatValue < self.minPrice)
    {
        self.minPrice = socketMdoel.price.floatValue;
        [self updateFrameworkView];
    }
    else //否则直接画下一个K线或分时图
    {
        if(self.lineType == ChartLineTypeKLine) //画最新的K线
        {
            [self updateKLine:socketMdoel];
        }
        else if(self.lineType == ChartLineTypeBrokenLine) //画最新的分时图
        {
            [self updateBrokenLine:socketMdoel];
        }
    }
}

/**
 *  更新框架 主要是为了更新y轴
 */
- (void)updateFrameworkView
{
    [self drawFrameworkView];
}

/**
 *  更新K线图
 *
 *  @param sModel 实时K线数据
 */
- (void)updateKLine:(SocketModel *)sModel
{
    static float maxPrice = 0;
    static float minPrice = MAXFLOAT;
    if([sModel.type isEqualToString:@"0"])//开始画
    {
        KLineDataModel *kDataModel = [self.kDataArray lastObject];
        //获取每根K线最大价格和最小价格
        maxPrice = MAX(maxPrice, sModel.price.floatValue);
        minPrice = MIN(minPrice, sModel.price.floatValue);
        
        kDataModel.closePrice = sModel.price;
        kDataModel.heightPrice = [NSString stringWithFormat:@"%f", maxPrice];
        kDataModel.lowPrice = [NSString stringWithFormat:@"%f", minPrice];
        
        ChartLineView *chartView = [self.chartViewArr firstObject];
        chartView.kLinePoints = [self convertKLineCoordinateToActualCoordinate];
        chartView.lineType = ChartLineTypeKLine;
        //为了防止切换图表时 网络数据未加载成功就绘制实时K线 造成图表界面快速闪烁
        if(self.isNeedDraw) [chartView setNeedsDisplay];
    }
    else if([sModel.type isEqualToString:@"2"])
    {
        [self getKLineNetworkData]; //重新请求网络数据 主要是为了更新x轴坐标
    }
}

/**
 *  更新分时图
 *
 *  @param sModel 实时分时图数据
 */
- (void)updateBrokenLine:(SocketModel *)sModel
{
    if([sModel.type isEqualToString:@"0"])//开始画
    {
        BrokenLineDataModel *bDataModel = [self.bDataArray lastObject];
        bDataModel.value = sModel.price;
        
        ChartLineView *chartView = [self.chartViewArr firstObject];
        chartView.brokenLinePoints = [self convertBrokenLineCoordianteToActualCoordinate];
        chartView.lineType = ChartLineTypeBrokenLine;
        //为了防止切换图表时 网络数据未加载成功就绘制实时K线 造成图表界面快速闪烁
        if(self.isNeedDraw) [chartView setNeedsDisplay];
    }
    else if([sModel.type isEqualToString:@"2"]) //重新请求网络数据 主要是为了更新x轴坐标
    {
        [self getBrokenLineNetworkData];
    }
}

#pragma mark -- 移除所有子视图

/**
 *  移除某个视图上的所有子视图
 *
 *  @param view 某个视图
 */
- (void)removeAllSubviews:(UIView *)view
{
    while (view.subviews.count)
    {
        [view.subviews.lastObject removeFromSuperview];
    }
}

#pragma mark -- getter或setter

- (UIView *)frameworkView
{
    if(!_frameworkView)
    {
        _frameworkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SELF_WIDTH - 50, SELF_HEIGHT - 30)];
        _frameworkView.backgroundColor = [UIColor clearColor];
        _frameworkView.userInteractionEnabled = YES;
        
        _frameworkView.layer.borderWidth = 1.0;
        _frameworkView.layer.borderColor = self.xyLineColor.CGColor;
        
        UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        longGes.minimumPressDuration = 0.5;
        [_frameworkView addGestureRecognizer:longGes];
    }
    return _frameworkView;
}

- (UIView *)longPressLine
{
    if(!_longPressLine)
    {
        _longPressLine = [[UIView alloc] initWithFrame:CGRectZero];
        _longPressLine.backgroundColor = [UIColor redColor];
        
    }
    return _longPressLine;
}

- (UIView *)detailView
{
    if(!_detailView)
    {
        _detailView = [[UIView alloc] initWithFrame:CGRectZero];
        _detailView.backgroundColor = [UIColor lightGrayColor];
        _detailView.alpha = 0.8;
        _detailView.layer.cornerRadius = 3;
    }
    return _detailView;
}

- (UIView *)priceLine
{
    if(!_priceLine)
    {
        _priceLine = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _priceLine;
}

- (UILabel *)priceLabel
{
    if(!_priceLabel)
    {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 21)];
        _priceLabel.font = [UIFont systemFontOfSize:12];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.textColor = [UIColor whiteColor];
        _priceLabel.alpha = 0.8;
    }
    return _priceLabel;
}

- (NSArray *)kDataArray
{
    if(!_kDataArray){
        _kDataArray = [NSArray array];
    }
    return _kDataArray;
}

- (NSArray *)bDataArray
{
    if(!_bDataArray){
        _bDataArray = [NSArray array];
    }
    return _bDataArray;
}

- (NSMutableArray *)xyViewArr
{
    if(!_xyViewArr){
        _xyViewArr = [[NSMutableArray alloc] init];
    }
    return _xyViewArr;
}

- (NSMutableArray *)chartViewArr
{
    if(!_chartViewArr){
        _chartViewArr = [NSMutableArray array];
    }
    return _chartViewArr;
}

- (UIActivityIndicatorView *)indicatorView
{
    if(!_indicatorView){
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:self.frameworkView.frame];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    return _indicatorView;
}

@end
