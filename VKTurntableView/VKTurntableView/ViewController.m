//
//  ViewController.m
//  VKTurntableView
//
//  Created by Work on 2020/4/18.
//  Copyright © 2020 Work. All rights reserved.
//

#import "ViewController.h"
#import "VKTurntableView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

@interface ViewController ()

@property (strong, nonatomic) VKTurntableView *turntable;
@property (strong,nonatomic) UIButton * goBtn;
@property (strong, nonatomic) NSMutableArray <DWTurntableViewModel *>*luckyItemArray;
@property (strong,nonatomic) NSMutableArray * zjList;//转盘结果数组 [{"qzIndex":1,"remark":"18元现金券","num":3}]
@property (strong,nonatomic) DWTurntableViewModel * curItem;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化转盘数据
    [self initItemDataArray];
    [self initTurntableView];
    [self initStartBtn];
}

- (void)initStartBtn {
    CGFloat width = 186/3.f;
    CGFloat height = 312/3.f;
    UIButton *start = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-width)*0.5, (CGRectGetHeight(self.view.frame)-height)*0.5+20, width,height)];
    self.goBtn = start;
//    [start setTitle:@"Start" forState:(UIControlStateNormal)];
    [start setImage:[UIImage imageNamed:@"zp_go"]forState:UIControlStateNormal];
    
    [self.view addSubview:start];
    [start addTarget:self action:@selector(startAction) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)requestZJList
{
    self.zjList = @[].mutableCopy;
    DWTurntableViewModel * item = [[DWTurntableViewModel alloc]init];
    item.index = 0;
    item.remark = @"18元现金券";
    item.num = 1;
    [self.zjList addObject:item];
    
    item = [[DWTurntableViewModel alloc]init];
    item.index = 1;
    item.remark = @"188元现金券";
    item.num = 1;
    [self.zjList addObject:item];
    
    item = [[DWTurntableViewModel alloc]init];
    item.index = 7;
    item.remark = @"苹果手机*1部";
    item.num = 1;
    [self.zjList addObject:item];
    
    DWTurntableViewModel * curItem = self.zjList.firstObject;
    self.curItem = curItem;
}

- (void)startAction {
    self.goBtn.userInteractionEnabled = NO;
    
    //请求转盘结果
    [self requestZJList];
    [self startTurn];
}

//开始转
- (void)startTurn
{
    if (self.curItem) {
        DWTurntableViewModel * item = [self getItemByIndex:self.curItem.index];
        if (item) {
            NSLog(@"奖品应该是：%@",item);
            [self.turntable turntableRotateToDisplayIndex:item.displayIndex];
        }else{
            NSLog(@"没有此奖品");
        }
    }
}
//继续下一次转动
- (void)continueNextTurnIfNeed
{
    NSUInteger curIndex = [self.zjList indexOfObject:self.curItem];
    if (curIndex >= self.zjList.count-1) {
        //最后一个
        self.curItem = nil;
    }else{
        self.curItem = self.zjList[curIndex+1];
    }
    if (self.curItem) {
        [self startTurn];
    }
}

- (DWTurntableViewModel *)getItemByIndex:(int)index
{
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"SELF.index == %d",index];
    NSArray * result = [self.luckyItemArray filteredArrayUsingPredicate:pre];
    DWTurntableViewModel * item = result.firstObject;
    return item;
}

- (void)initResultView {
    
}

- (void)initTurntableView {
    
    CGRect rect =  CGRectMake(20, (SCREEN_HEIGHT - (SCREEN_WIDTH - 20 * 2)) * 0.5, SCREEN_WIDTH - 20 * 2, SCREEN_WIDTH);
    UIImageView * bg = [[UIImageView alloc]initWithFrame:rect];
    bg.image = [UIImage imageNamed:@"zp_bg"];
    bg.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:bg];

    _turntable = [[VKTurntableView alloc] init];
//    _turntable.bg = bg;
    NSDictionary * attributes = @{
                        NSForegroundColorAttributeName:UIColor.whiteColor,
                        NSFontAttributeName:[UIFont boldSystemFontOfSize:10]
                    };
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale == 2) {
        _turntable.circleWidth = 27.f;
    }else{
        _turntable.circleWidth = 31.f;
    }
    _turntable.imageSize = CGSizeMake(35, 35);

    _turntable.attributes = attributes;
    _turntable.panBgColors = @[[UIColor colorWithRed:191/255.0 green:112/255.0 blue:27/255.0 alpha:1],
                               [UIColor colorWithRed:197/255.0 green:145/255.0 blue:44/255.0 alpha:1]];
    @weakify(self);
    [_turntable setLunckyAnimationDidStopBlock:^(BOOL flag) {
        @strongify(self);
        if (self) {
            self.goBtn.userInteractionEnabled = YES;
            NSLog(@"============🌝🌝🌝🌝🌝🌝🌝🌝============:\n%@",self.curItem);
            [self continueNextTurnIfNeed];
        }
    }];
    [self.view addSubview:_turntable];
    _turntable.frame = rect;
    _turntable.luckyItemArray = self.luckyItemArray;
}

- (void)initItemDataArray
{
    _luckyItemArray = [NSMutableArray array];
//zjList:[{"qzIndex":1,"remark":"18元现金券","num":3}]   qzIndex(0 18元现金券,1 188元现金券,2 主播名片*1次,3 入场特效*7天,4  vip发言*7天,5  推广新秀*30天,6  推广至尊*30天,7  苹果手机*1部)
    NSArray * goods = @[@{@"title":@"18元现金券",@"qzIndex":@"0",@"displayIndex":@"7",@"imageName":@"vk_vkooy"},
                        @{@"title":@"188元现金券",@"qzIndex":@"1",@"displayIndex":@"6",@"imageName":@"vk_vkooy"},
                        @{@"title":@"主播名片*1次",@"qzIndex":@"2",@"displayIndex":@"5",@"imageName":@"vk_vkooy"},
                        @{@"title":@"入场特效*7天",@"qzIndex":@"3",@"displayIndex":@"4",@"imageName":@"vk_vkooy"},
                        @{@"title":@"vip发言*7天",@"qzIndex":@"4",@"displayIndex":@"3",@"imageName":@"vk_vkooy"},
                        @{@"title":@"推广至尊*30天",@"qzIndex":@"5",@"displayIndex":@"2",@"imageName":@"vk_vkooy"},
                        @{@"title":@"推广新秀*30天",@"qzIndex":@"6",@"displayIndex":@"1",@"imageName":@"vk_vkooy"},
                        @{@"title":@"苹果手机*1部",@"qzIndex":@"7",@"displayIndex":@"0",@"imageName":@"vk_vkooy"}];
    for (int i = 0; i < goods.count ; i++) {
        DWTurntableViewModel *model = [[DWTurntableViewModel alloc] init];
        if (goods.count > i) {
            NSDictionary * dic = goods[i];
            NSString * title = dic[@"title"];
            NSString * displayIndex = dic[@"displayIndex"];
            NSString * qzIndex = dic[@"qzIndex"];
            NSString * imageName = dic[@"imageName"];
            model.remark = title;
            model.index = qzIndex.intValue;
            model.displayIndex = displayIndex.intValue;
            model.imageName = imageName;
            [_luckyItemArray addObject:model];
        }
    }
    [_luckyItemArray sortUsingComparator:^NSComparisonResult(DWTurntableViewModel *  _Nonnull obj1, DWTurntableViewModel *  _Nonnull obj2) {
        return obj1.displayIndex>obj2.displayIndex;
    }];
}

@end
