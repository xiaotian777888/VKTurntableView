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

@property (nonatomic, strong) NSString *remark;
@property (nonatomic, assign) int index;
@property(assign,nonatomic) int displayIndex;
@property (nonatomic, strong) NSString *imageName;
@property(assign,nonatomic) int num;

//@property(assign,nonatomic) BOOL isAnimating;//是否是当前正在转的
@end

@interface VKTurntableView : UIView

@property (strong,nonatomic) UIImageView * bg;
@property (strong,nonatomic) UIColor* textFontColor;
@property (strong,nonatomic) NSDictionary *attributes;
@property (assign,nonatomic) CGSize imageSize;
@property (strong,nonatomic) NSArray * panBgColors;
@property(assign,nonatomic)  CGFloat circleWidth;
@property(assign,nonatomic) CGFloat textPadding;

@property (nonatomic, strong) NSArray<DWTurntableViewModel *> *luckyItemArray;

//displayIndex 数组下标
- (void)turntableRotateToDisplayIndex:(NSInteger)displayIndex;

@property(copy,nonatomic) void(^lunckyAnimationDidStopBlock)(BOOL flag);
@end
