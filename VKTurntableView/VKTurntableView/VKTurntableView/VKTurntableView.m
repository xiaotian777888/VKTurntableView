//
//  VKTurntableView.m
//  VKOOY
//
//  Created by vkooy on 2018/5/21.
//  Copyright © 2017年. All rights reserved.
//

#import "VKTurntableView.h"
#import "UIImage+CGImageRef.h"
@import CoreGraphics;

@implementation DWTurntableViewModel

-(NSString *)description
{
    return [NSString stringWithFormat:@"title=%@ , displayIndex=%d , index=%d",self.remark,self.displayIndex,self.index];
}

@end

@interface VKTurntableView ()<CAAnimationDelegate>{
    CGFloat _textFontSize;
    NSDictionary *_attributes;
//    NSMutableParagraphStyle * _paragraphStyle;

    CGSize _imageSize;
    //相间颜色
    NSArray * _panBgColors;
    UIColor *_circleBgColor;//外环 bgColor
    UIColor *_dotColor;
    UIColor *_dotShinningColor;
    CGFloat _circleWidth;
    NSInteger _numberOfDot;//default is 18 dots
    CGFloat _dotSize; // default is 10.0
    CGFloat _textPadding;
}

@property (strong, nonatomic) NSMutableArray *dotLayers;//count = 18
@property (strong, nonatomic) NSMutableArray *imageLayers;
@property (strong, nonatomic) NSOperationQueue *imageRenderQueue;
@property (nonatomic, assign) CGFloat startValue;//default = 0

@end

static CGPoint pointAroundCircumference(CGPoint center, CGFloat radius, CGFloat theta);

@implementation VKTurntableView

- (void)dealloc{
    [_imageRenderQueue cancelAllOperations];
    _imageRenderQueue = nil;
    
    [_imageLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_imageLayers removeAllObjects];
    
    [_dotLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_dotLayers removeAllObjects];
}

#pragma mark - Init Methods

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultSetups];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetups];
    }
    return self;
}

#pragma mark - Preparations

// 这些可当做属性设置 也可以 IB_DESIGNABLE 这里就没做了
- (void)defaultSetups{
    self.backgroundColor = [UIColor clearColor];
    
    _dotLayers = [NSMutableArray arrayWithCapacity:18];
    _textFontSize = 12.0;
    _textPadding = 5.0;
    _attributes = @{
                        NSForegroundColorAttributeName:UIColor.whiteColor,
                        NSFontAttributeName:[UIFont boldSystemFontOfSize:10]
                    };
    
//    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    _paragraphStyle = paragraphStyle;
//    //行间距
//    paragraphStyle.lineSpacing = 10.0;
//    //段落间距
////    paragraphStyle.paragraphSpacing = 20.0;
//    //    paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
//    //    paragraphStyle.firstLineHeadIndent = 10.0;
//    //    paragraphStyle.headIndent = 50.0;
//    //    paragraphStyle.tailIndent = 200.0;

    _imageSize = CGSizeMake(35, 35);
    _circleWidth = 30.f;
    _numberOfDot = 18;
    _dotSize = 8.0;
    _panBgColors = @[[UIColor colorWithRed:249 / 255.0 green:105 / 255.0 blue:108 / 255.0 alpha:1.0],[UIColor colorWithRed:247 / 255.0 green:131 / 255.0 blue:131 / 255.0 alpha:1.0]
    ];
    _circleBgColor = [UIColor colorWithRed:251 / 255.0 green:94 / 255.0 blue:97 / 255.0 alpha:1.0];
    _dotShinningColor = [UIColor colorWithRed:42 / 255.0 green:253 / 255.0 blue:47 / 255.0 alpha:1.0];
    _dotColor = [UIColor whiteColor];
}

#pragma mark - Getter & Setter

- (NSOperationQueue *)imageRenderQueue{
    if (!_imageRenderQueue) {
        _imageRenderQueue = [[NSOperationQueue alloc] init];
        _imageRenderQueue.name = @"DwyaneWadeImageRenderQ";
    }
    return _imageRenderQueue;
}

- (void)setLuckyItemArray:(NSArray<DWTurntableViewModel *> *)luckyItemArray{
    
    _luckyItemArray = luckyItemArray;
    
    _numberOfDot = _luckyItemArray.count * 2;
    
    [self setNeedsDisplay];
}

#pragma mark - Public Methods

- (void)turntableRotateToDisplayIndex:(NSInteger)displayIndex
{
    CGFloat count = self.luckyItemArray.count;
    CGFloat angel = (360 / count);
    CGFloat angle4Rotate = angel * (displayIndex+1);// 以 π*3/2 为终点, 加多一圈以防反转, 默认顺时针
    angle4Rotate = angle4Rotate+90-angel*0.5; //自定义文字和奖品模式
//    angle4Rotate = angle4Rotate+angel;//背景图片自带文字和奖品模式
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
    [self startRotationWithEndValue:radians round:3];
}
- (void)startRotationWithEndValue:(CGFloat)endValue round:(NSInteger)round{
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue = @(_startValue);
    animation.toValue = @(endValue);// default is 6 * M_PI
    animation.duration = 3.0;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    [self.layer addAnimation:animation forKey:@"rotation"];
    _startValue = round ? (endValue - 2*M_PI*round) : 0;//记录上次的结果位置当作下次的开始位置
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"VKLunckyAnimationDidStopNotication" object:nil];
    if (self.lunckyAnimationDidStopBlock) {
        self.lunckyAnimationDidStopBlock(flag);
    }
}

#pragma mark - Draw Method

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if (_luckyItemArray && _luckyItemArray.count) {
     
        [_imageLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [_imageLayers removeAllObjects];
        
        NSInteger count = _luckyItemArray.count;
        CGPoint center = CGPointMake(rect.size.width / 2.0, rect.size.height / 2.0);
        CGFloat degree = 360.0 / count;
        /*
        //draw cicle
        UIBezierPath *outerPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                 radius:center.x
                                                             startAngle:0
                                                               endAngle:M_PI * 2
                                                              clockwise:YES];
        UIBezierPath *innerPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                 radius:center.x - _circleWidth
                                                             startAngle:0
                                                               endAngle:M_PI * 2
                                                              clockwise:YES];
        [outerPath appendPath:innerPath];
        [_circleBgColor setFill];
        [outerPath fill];
        
        //draw dots 画点
        [self drawDotOnCircle];
        */
        for (int i = 0; i < count; i++) {
        
            DWTurntableViewModel *obj = [_luckyItemArray objectAtIndex:i];
            
            UIBezierPath *fanPath = [UIBezierPath bezierPath];//reference path
            [fanPath moveToPoint:center];
            
            [fanPath addArcWithCenter:center
                            radius:center.x - _circleWidth
                        startAngle:VKDegress2Radians(i * degree)
                          endAngle:VKDegress2Radians((i + 1) * degree)
                         clockwise:YES];
            [fanPath closePath];
            int colorIndex = i%_panBgColors.count;
            UIColor * color = _panBgColors[colorIndex];
            [color setFill];
            [fanPath fill];
           
            //text 文字
            NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc] initWithString:obj.remark attributes:_attributes];
//            [attributeString addAttribute:NSParagraphStyleAttributeName
//                                         value:_paragraphStyle
//                                         range:NSMakeRange(0, obj.title.length)];
            [self drawStringOnLayer:self.layer withAttributedText:attributeString.copy atAngle:VKDegress2Radians((i + 0.5) * degree) withRadius:center.x - _circleWidth - _textFontSize - _textPadding];
            
            //image 图片
            CALayer *imageLayer = [CALayer layer];
            NSBlockOperation *operaton = [NSBlockOperation blockOperationWithBlock:^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    UIImage *image = [UIImage imageNamed:obj.imageName];
                    CGImageRef imageRef = [image newCGImageRenderedInBitmapContext];
                    
                    imageLayer.contents = (__bridge id)imageRef;
                }];
            }];
            [self.imageRenderQueue addOperation:operaton];
            // VKOOY
            CGPoint imageLayerPos = pointAroundCircumference(center, (center.x - _circleWidth) / 2.0+10, VKDegress2Radians((i + 0.5) * degree));
            imageLayer.frame = CGRectMake(0, 0, _imageSize.width, _imageSize.height);
            imageLayer.position = imageLayerPos;
            imageLayer.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, VKDegress2Radians((i + 0.5) * degree) + M_PI_2);
//            imageLayer.cornerRadius = 3.0;
//            imageLayer.masksToBounds = YES;
            
            [self.layer addSublayer:imageLayer];
            [self.imageLayers addObject:imageLayer];
        }
    }
}

- (void)drawDotOnCircle{
    
    [_dotLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_dotLayers makeObjectsPerformSelector:@selector(removeAllAnimations)];
    [_dotLayers removeAllObjects];
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
    CGFloat dotRadians = M_PI*2 / _numberOfDot;
    
    CABasicAnimation *shinningAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    
    for (int i = 0; i < _numberOfDot; i++) {
        
        CAShapeLayer *dotLayer = [CAShapeLayer layer];
        dotLayer.frame = CGRectMake(0, 0, _dotSize, _dotSize);
        dotLayer.cornerRadius = _dotSize / 2.0;
        dotLayer.position = pointAroundCircumference(center, center.x - _circleWidth / 2.0, i * dotRadians);
        dotLayer.backgroundColor = (i % 2) ? _dotColor.CGColor : _dotShinningColor.CGColor;
        
        [_dotLayers addObject:dotLayer];
        [self.layer addSublayer:dotLayer];
        
        shinningAnimation.fromValue = (id)(dotLayer.backgroundColor);
        shinningAnimation.toValue = (id)((i % 2) ? _dotShinningColor.CGColor : _dotColor.CGColor);
        shinningAnimation.duration = 0.25f;
        shinningAnimation.repeatCount = 1000;
        shinningAnimation.autoreverses = YES;
        
        [dotLayer addAnimation:shinningAnimation forKey:@"backgroundColor"];
    }
}

- (void)addAnimation2DotLayer{
    
    for (int i = 0; i < _numberOfDot; i++) {
        CAShapeLayer *dotLayer = [_dotLayers objectAtIndex:i];
        [dotLayer removeAllAnimations];
        
        CABasicAnimation *shinningAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        shinningAnimation.fromValue = (id)(dotLayer.backgroundColor);
        shinningAnimation.toValue = (id)((i % 2) ? _dotShinningColor.CGColor : _dotColor.CGColor);
        shinningAnimation.duration = 0.25f;
        shinningAnimation.repeatCount = 1000;
        shinningAnimation.autoreverses = YES;
        
        [dotLayer addAnimation:shinningAnimation forKey:@"backgroundColor"];
    }
}

// draw fan shaped text(sector text) 画扇形字
- (void)drawCurvedStringOnLayer:(CALayer *)layer
             withAttributedText:(NSAttributedString *)text
                        atAngle:(float)angle
                     withRadius:(float)radius {
    
//    CGSize textSize = CGRectIntegral([text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
//                                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
//                                                        context:nil]).size;
    CGSize textSize = text.size;
//    CGRect rect = CGRectMake(layer.frame.size.width/2 - textSize.width/2,
//                             layer.frame.size.height/2 - textSize.height/2, textSize.width, textSize.height);
//    [self drawTextOnLayer:layer withText:text frame:rect bgColor:nil opacity:1.f];
    
    CGFloat perimeter = 2 * M_PI * radius;
    CGFloat textAngle = (textSize.width / perimeter * 2 * M_PI);
    
    CGFloat textRotation = 0;
    CGFloat textDirection = 0;
//    if (angle > VKDegress2Radians(10) && angle < VKDegress2Radians(170)) {// 反向 使文字 可读
//        //bottom string
//        textRotation = 0.5 * M_PI ;
//        textDirection = - 2 * M_PI;
//        angle += textAngle / 2;
//    } else {
        //top string
        textRotation = 1.5 * M_PI ;
        textDirection = 2 * M_PI;
        angle -= textAngle / 2;
//    }
    

    for (int c = 0; c < text.length; c++) {
        NSRange range = {c, 1};
        NSAttributedString* letter = [text attributedSubstringFromRange:range];
        CGSize charSize = CGRectIntegral([letter boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, textSize.height)
                                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                              context:nil]).size;
        CGFloat letterAngle = ((charSize.width / perimeter) * textDirection );
        CGFloat x = radius * cos(angle + (letterAngle/2));
        CGFloat y = radius * sin(angle + (letterAngle/2));
        CATextLayer *singleChar = [self drawTextOnLayer:layer
                                               withText:letter
                                                  frame:CGRectMake(layer.frame.size.width/2 - charSize.width/2 + x,
                                                                   layer.frame.size.height/2 - charSize.height/2 + y,
                                                                   charSize.width, charSize.height)
                                                bgColor:nil
                                                opacity:1];
        singleChar.transform = CATransform3DMakeAffineTransform( CGAffineTransformMakeRotation(angle - textRotation) );
        angle += letterAngle;
    }
}

- (void)drawStringOnLayer:(CALayer *)layer
             withAttributedText:(NSAttributedString *)text
                        atAngle:(float)angle
                     withRadius:(float)radius {
    
    CGSize textSize = CGRectIntegral([text boundingRectWithSize:CGSizeMake(80, 25)
                                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                        context:nil]).size;
//    CGSize textSize = CGSizeMake(80, 25);
//    CGFloat perimeter = 2 * M_PI * radius;
    textSize.height +=1;//高度刚好显示不出第二行，要加1
    CGFloat textRotation = 0;
    CGFloat textDirection = 0;
    textRotation = 1.5 * M_PI ;
    textDirection = 2 * M_PI;
    
    CGFloat x = radius * cos(angle);
    CGFloat y = radius * sin(angle);
    CATextLayer * textLayer = [self drawTextOnLayer:layer
                  withText:text
                     frame:CGRectMake(layer.frame.size.width/2 - textSize.width/2+x,
                                      layer.frame.size.height/2 - textSize.height/2+y,
                                      textSize.width, textSize.height)
                   bgColor:nil
                   opacity:1];

    textLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransformMakeRotation(angle - textRotation));
}


- (CATextLayer *)drawTextOnLayer:(CALayer *)layer
                        withText:(NSAttributedString *)text
                           frame:(CGRect)frame
                         bgColor:(UIColor *)bgColor
                         opacity:(CGFloat)opacity {
    
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    [textLayer setFrame:frame];
    [textLayer setString:text];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setBackgroundColor:bgColor.CGColor];
    [textLayer setContentsScale:[UIScreen mainScreen].scale];
    [textLayer setOpacity:opacity];
    [textLayer setWrapped:YES];
    [layer addSublayer:textLayer];
    return textLayer;
}

@end

// center point on circle 在圆上的点
static CGPoint pointAroundCircumference(CGPoint center, CGFloat radius, CGFloat theta){
    CGPoint point = CGPointZero;
    point.x = center.x + radius * cos(theta);
    point.y = center.y + radius * sin(theta);
    return point;
}
