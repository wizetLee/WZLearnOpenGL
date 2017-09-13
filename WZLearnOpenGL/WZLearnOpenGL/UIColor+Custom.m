//
//  UIColor+Custom.m
//  WZLearnOpenGL
//
//  Created by admin on 12/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "UIColor+Custom.h"

@implementation UIColor (Custom)
+ (UIColor *)wz_colorWithHexString:(NSString *)str {
    return [self colorWithHexString:str];
}

+ (UIColor *)colorWithHexString:(NSString *)str {
    return [UIColor yellowColor];
}

@end
