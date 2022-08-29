//
//  ZCColorPicker.h
//  ZCColorPicker
//
//  Created by zhoujianhui on 2022/8/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ChooseColorComplention)(UIColor *color, BOOL update);

NS_ASSUME_NONNULL_BEGIN

@interface ZCColorPicker : UIControl

///选中颜色
@property(nonatomic, readonly) UIColor *selectedColor;

@property (nonatomic, copy) ChooseColorComplention complention;

- (instancetype)initWithFrame:(CGRect)frame bubble:(CGFloat)bubbleWidth;

- (void)changeColor:(UIColor *)color;


@end

NS_ASSUME_NONNULL_END
