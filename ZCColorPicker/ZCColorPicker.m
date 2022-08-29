//
//  ZCColorPicker.m
//  ZCColorPicker
//
//  Created by zhoujianhui on 2022/8/29.
//

#import "ZCColorPicker.h"

@interface ZCColorPicker ()
///选择气泡
@property(nonatomic, strong) CAShapeLayer *bubbleLayer;
///中间显色区域
@property(nonatomic, strong) CAShapeLayer *colorLayer;
///灯泡
@property(nonatomic, strong) UIImageView *bulbImgView;
///白色外圈
@property(nonatomic, strong) UIView *bgCircleView;
///气泡大小
@property(nonatomic) CGFloat bubbleWidth;
///上次旋转的角度
@property(nonatomic, assign) CGFloat preAngle;
///色调
@property(nonatomic) CGFloat hue;
///饱和度
@property(nonatomic) CGFloat saturation;

@end


@implementation ZCColorPicker

- (instancetype)initWithFrame:(CGRect)frame bubble:(CGFloat)bubbleWidth {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        CGFloat width = frame.size.width;
        
        self.bubbleLayer = [CAShapeLayer layer];
        self.bubbleLayer.frame = CGRectMake(bubbleWidth*3, bubbleWidth*3, bubbleWidth, bubbleWidth);
        self.bubbleLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.bubbleLayer.lineWidth = 2.f;
        self.bubbleLayer.fillColor = [UIColor redColor].CGColor;
        self.bubbleLayer.backgroundColor = [UIColor clearColor].CGColor;
        CGPathRef bubblePath = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, bubbleWidth, bubbleWidth), 0);
        self.bubbleLayer.shadowOffset = CGSizeMake(0, 4);
        self.bubbleLayer.shadowColor = UIColor.blackColor.CGColor;
        self.bubbleLayer.shadowOpacity = 0.5;
        self.bubbleLayer.path = bubblePath;
        CGPathRelease(bubblePath);
        
        self.colorLayer = [CAShapeLayer layer];
        self.colorLayer.strokeColor = [UIColor blackColor].CGColor;
        self.colorLayer.lineWidth = 8.f;
        self.colorLayer.fillColor = [UIColor redColor].CGColor;
        self.colorLayer.frame = CGRectMake((width-bubbleWidth*3)/2, (width-bubbleWidth*3)/2, bubbleWidth*3, bubbleWidth*3);
        CGPathRef colorPath = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, bubbleWidth*3, bubbleWidth*3), 0);
        self.colorLayer.path = colorPath;
        CGPathRelease(colorPath);
        
        self.bgCircleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        self.bgCircleView.layer.cornerRadius = 105;
        self.bgCircleView.layer.masksToBounds = YES;
        self.bgCircleView.layer.borderWidth = 5;
        self.bgCircleView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.bgCircleView.backgroundColor = [UIColor clearColor];
        
        self.bulbImgView = [[UIImageView alloc] initWithFrame:CGRectMake((width-bubbleWidth*2)/2, (width-bubbleWidth*2)/2, bubbleWidth*2, bubbleWidth*2)];
        self.bulbImgView.image = [UIImage imageNamed:@"bulb_icon"];
        
        [self addSubview:self.bgCircleView];
        [self.layer addSublayer:self.colorLayer];
        [self.layer addSublayer:self.bubbleLayer];
        [self addSubview:self.bulbImgView];
        
        self.bubbleWidth = bubbleWidth;
    }
    return self;
}

///选中的颜色
- (UIColor *)selectedColor {
    return [UIColor colorWithHue:_hue saturation:_saturation brightness:1 alpha:1];
}

- (void)changeColor:(UIColor *)color {
    if (!color) {
        return;
    }
    CGFloat h,s,b;
    if ([color getHue:&h saturation:&s brightness:&b alpha:NULL]) {
        _hue = h;
        _saturation = s;
        [self configBubbleAnimated:YES isFirst:NO];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self configBubbleAnimated:NO isFirst:YES];
}

- (void)configBubbleAnimated:(BOOL)animated isFirst:(BOOL)isFirst {
    CGPoint center = CGPointMake(floorf(self.bounds.size.width / 2.f), floorf(self.bounds.size.height / 2.f));
    CGFloat radius = floorf(self.bounds.size.width / 2.f);
    
    [CATransaction begin];
    if (!animated) {
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    }
    
    CGFloat angle = 2 * M_PI * (1 - _hue);
    CGFloat saturationRadius = radius * _saturation;
    CGFloat x = center.x + saturationRadius * cosf(angle) > self.frame.size.width ? self.frame.size.width : center.x + saturationRadius * cosf(angle);
    CGFloat y = center.y + saturationRadius * sinf(angle) > self.frame.size.width ? self.frame.size.width : center.y + saturationRadius * sinf(angle) ;
    CGPoint point = CGPointMake(x, y);
    if (self.hue == 0 && self.saturation == 0) {
        self.bubbleLayer.position = CGPointMake(point.x+80, point.y);
        self.bubbleLayer.fillColor = [UIColor redColor].CGColor;
        self.colorLayer.fillColor = [UIColor redColor].CGColor;
    } else {
        self.bubbleLayer.position = CGPointMake(point.x, point.y);
        self.bubbleLayer.fillColor = [UIColor colorWithHue:_hue saturation:_saturation brightness:1 alpha:1].CGColor;
        self.colorLayer.fillColor = [UIColor colorWithHue:_hue saturation:_saturation brightness:1 alpha:1].CGColor;
    }
    [CATransaction commit];
    
    self.preAngle = angle;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self sendActionForColorAtPoint:[touch locationInView:self] update:NO];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self sendActionForColorAtPoint:[touch locationInView:self] update:NO];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    [self sendActionForColorAtPoint:[touch locationInView:self] update:YES];
}

- (void)sendActionForColorAtPoint:(CGPoint)point update:(BOOL)update {
    CGPoint center = CGPointMake(floorf(self.bounds.size.width/2.0f), floorf(self.bounds.size.height/2.0f));
    CGFloat radius = floorf(self.bounds.size.width/2.0f);
    
    CGFloat dx = point.x - center.x;
    CGFloat dy = point.y - center.y;
    
    ///通过三角函数计算点击半径
    CGFloat touchRadius = sqrtf(powf(dx, 2)+powf(dy, 2));
    if (touchRadius > radius) {
        _saturation = 1.f;
    } else {
        if (touchRadius <= _bubbleWidth*2.0) {
            _saturation = 0.3;
        } else {
            _saturation = touchRadius / radius;
        }
    }
    CGFloat angleRad = atan2f(dx, dy);
    CGFloat angleDeg = (angleRad * (180.0f/M_PI) - 90);
    if (angleDeg < 0.f) {
        angleDeg += 360.f;
    }
    _hue = angleDeg / 360.0f;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self configBubbleAnimated:NO isFirst:NO];
    if (self.complention) {
        self.complention(self.selectedColor, update);
    }
}

#pragma mark - 绘制颜色图片及保存到本地
- (NSString *)pathForSize:(CGSize)size {
    NSString *filename = [NSString stringWithFormat:@"SZColorPickerImage_%d_%d@%dx", (int)(size.width), (int)(size.height), (int)[UIScreen mainScreen].scale];
    filename = [filename stringByAppendingPathExtension:@"png"];
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cacheDirectory stringByAppendingPathComponent:filename];
}

- (void)saveBackgroundImageForSize:(CGSize)size {
    if ([[[NSFileManager alloc] init] fileExistsAtPath:[self pathForSize:size]]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self drawBackgroundInContext:context withSize:size];
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        NSData *pngImage = UIImagePNGRepresentation(backgroundImage);
        [pngImage writeToFile:[self pathForSize:size] atomically:YES];
        UIGraphicsEndImageContext();
    });
}

- (void)drawBackgroundInContext:(CGContextRef)context withSize:(CGSize)size {
    CGPoint center = CGPointMake(floorf((size.width)/2.0f), floorf((size.height)/2.0f));
    CGFloat radius = floorf((size.width)/2.0f);           // draw a bit outside of our bouds. we will clip that back to our bounds.
    // this avoids artifacts at the edge
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextClip(context);
    
    NSInteger numberOfSegments = 3600;
    for (CGFloat i = 0; i < numberOfSegments; i++) {
        UIColor *color = [UIColor colorWithHue:1-i/(float)numberOfSegments saturation:1 brightness:1 alpha:1];
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        
        CGFloat segmentAngle = 2*M_PI / (float)numberOfSegments;
        CGPoint start = center;
        CGPoint end = CGPointMake(center.x + radius * cosf(i * segmentAngle), center.y + radius * sinf(i * segmentAngle));
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, 0, start.x, start.y);
        
        CGFloat offsetFromMid = 0.5f*(M_PI/180);
        CGPoint end1 = CGPointMake(center.x + radius * cosf(i * segmentAngle-offsetFromMid), center.y + radius * sinf(i * segmentAngle-offsetFromMid));
        CGPoint end2 = CGPointMake(center.x + radius * cosf(i * segmentAngle+offsetFromMid), center.y + radius * sinf(i * segmentAngle+offsetFromMid));
        CGPathAddLineToPoint(path, 0, start.x, start.y);
        CGPathAddLineToPoint(path, 0, end.x, end.y);
        CGPathAddLineToPoint(path, 0, end1.x, end1.y);
        CGPathAddLineToPoint(path, 0, end2.x, end2.y);
        
        CGContextSaveGState(context);
        CGContextAddPath(context, path);
        
        CGPathRelease(path);
        CGContextClip(context);
        
        NSArray *colors = @[(__bridge id)[UIColor colorWithWhite:1 alpha:1].CGColor, (__bridge id)color.CGColor];
        CGGradientRef gradient = CGGradientCreateWithColors(rgbColorSpace, (__bridge CFArrayRef)colors, NULL);
        CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation|kCGGradientDrawsAfterEndLocation);
        CGGradientRelease(gradient);
        CGContextRestoreGState(context);
    }
    CGColorSpaceRelease(rgbColorSpace);
    
    CGContextRestoreGState(context);
    
    CGContextSetStrokeColorWithColor(context, UIColor.clearColor.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextStrokeEllipseInRect(context, CGRectMake(0, 0, size.width, size.height));
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage *image = [UIImage imageWithContentsOfFile:[self pathForSize:self.bounds.size]];
    if (!image) {
        [self saveBackgroundImageForSize:self.bounds.size];
        image = [UIImage imageWithContentsOfFile:[self pathForSize:self.bounds.size]];
    }
    if (image) {
        [image drawInRect:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height)];
    } else {
        [self drawBackgroundInContext:context withSize:self.bounds.size];
    }
}

@end
