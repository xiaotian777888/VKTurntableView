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
@property (strong, nonatomic) NSMutableArray *luckyItemArray;

@property (assign, nonatomic) NSInteger endId;  //  仅代表停止位置，不代表奖品ID。(更改转盘奖品个数，这个ID不准，自行修改旋转角度)

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initTurntableView];
    
    [self initStartBtn];
    [self initResultView];
}

- (void)initStartBtn {
    CGFloat width = 186/2.f;
    CGFloat height = 312/2.f;
    UIButton *start = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.bounds)-width)*0.5, (CGRectGetHeight(self.view.frame)-height)*0.5+20, width,height)];
    self.goBtn = start;
//    [start setTitle:@"Start" forState:(UIControlStateNormal)];
    [start setImage:[UIImage imageNamed:@"zp_go"]forState:UIControlStateNormal];
    
    [self.view addSubview:start];
    [start addTarget:self action:@selector(startAction) forControlEvents:(UIControlEventTouchUpInside)];
}

- (void)startAction {
    self.goBtn.userInteractionEnabled = NO;
    _endId = arc4random() % _luckyItemArray.count;
    [self turntableRotate:_endId];
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
            [self lunckyAnimationDidStop];
        }
    }];
    [self.view addSubview:_turntable];
    _turntable.frame = rect;
    _luckyItemArray = [NSMutableArray array];
    for (int i = 0; i < 6; i++) {
        DWTurntableViewModel *model = [[DWTurntableViewModel alloc] init];
        model.title = [NSString stringWithFormat:@"魅力新秀荣誉称号%d天",i];
        model.index = i;
        model.imageName = @"vk_vkooy";
        [_luckyItemArray addObject:model];
    }
    
    _turntable.luckyItemArray = _luckyItemArray;
    
    
}


- (void)turntableRotate:(NSInteger)index {
    CGFloat count = _turntable.luckyItemArray.count;
    CGFloat angel = (360 / count);
    CGFloat angle4Rotate = angel * (index+1);// 以 π*3/2 为终点, 加多一圈以防反转, 默认顺时针
    angle4Rotate = angle4Rotate+90-angel*0.5;
    angle4Rotate = 360-angle4Rotate;
    //index为0的起始角度为0 go箭头向上相差270度
    /*
    CGFloat move = (360 / count)*3.5;
    CGFloat angle4Rotate = 270.0 - (360.0 / count) * index + (360.0 / count) / 2;// 以 π*3/2 为终点, 加多一圈以防反转, 默认顺时针
    if (angle4Rotate > 360){
        angle4Rotate -= 360;
    }
     */
    CGFloat radians = VKDegress2Radians(angle4Rotate) + M_PI * 6;
    [_turntable startRotationWithEndValue:radians round:3];
}

- (void)lunckyAnimationDidStop {
    NSLog(@"============🌝🌝🌝🌝🌝🌝🌝🌝============:%ld",_endId);
    
    DWTurntableViewModel *model = _luckyItemArray[_endId];
    
    NSLog(@"============🌝🌝🌝🌝🌝🌝🌝🌝============:%@",model.title);
}





@end
