//
//  ViewController.m
//  ZCColorPicker
//
//  Created by zhoujianhui on 2022/8/29.
//

#import "ViewController.h"
#import "ZCColorPicker.h""

#define WEAKSELF(self)  __weak typeof(self) weakSelf = (self);
#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
@interface ViewController ()

@property(nonatomic, strong) ZCColorPicker *picker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WEAKSELF(self)
    self.picker = [[ZCColorPicker alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - 210)/2, 120, 210, 210) bubble:20];
    self.picker.complention = ^(UIColor *color, BOOL update) {
        
        weakSelf.view.backgroundColor = color;
    };
    [self.view addSubview:self.picker];
    self.view.backgroundColor = [UIColor redColor];
    
    [self.picker changeColor:[UIColor greenColor]];
}


@end
