//
//  KView.m
//  WZLearnOpenGL
//
//  Created by admin on 27/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "KView.h"

@interface KView()

@property (nonatomic, strong) NSTimer *timer;


@end

@implementation KView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(renderLoop) userInfo:nil repeats:true];
    
    
}

- (void)renderLoop {
    //变更坐标啊
}

@end
