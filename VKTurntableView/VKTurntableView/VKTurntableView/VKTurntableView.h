//
//  VKTurntableView.h
//  VKOOY
//
//  Created by vkooy on 2018/5/21.
//  Copyright © 2017年. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VKDegress2Radians(degrees) ((M_PI * degrees) / 180)
//   - 1.25
@interface DWTurntableViewModel : NSObject

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageName;

@end

@interface VKTurntableView : UIView

@property (strong,nonatomic) UIColor* textFontColor;
@property (strong,nonatomic) NSDictionary *attributes;
@property (assign,nonatomic) CGSize imageSize;
@property (strong,nonatomic) NSArray * panBgColors;
@property(assign,nonatomic)  CGFloat circleWidth;
@property(assign,nonatomic) CGFloat textPadding;

@property (nonatomic, strong) NSArray<DWTurntableViewModel *> *luckyItemArray;

// random prize 随机
- (void)startRotationWithEndValue:(CGFloat)endValue;

// specific prize 指定中奖
- (void)startRotationWithEndValue:(CGFloat)endValue round:(NSInteger)round;

@property(copy,nonatomic) void(^lunckyAnimationDidStopBlock)(BOOL flag);
@end
