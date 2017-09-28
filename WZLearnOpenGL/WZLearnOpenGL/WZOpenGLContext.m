//
//  WZOpenGLContext.m
//  WZLearnOpenGL
//
//  Created by admin on 18/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "WZOpenGLContext.h"

@interface WZOpenGLContext()

@property (nonatomic, strong) EAGLContext *context;

@end

@implementation WZOpenGLContext

#pragma mark - Accessor

static WZOpenGLContext *shareInstanceOpenGLContext = nil;

///单例
+ (WZOpenGLContext *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstanceOpenGLContext = [[WZOpenGLContext alloc] init];
    });
    return shareInstanceOpenGLContext;
}

///上下文
- (EAGLContext *)context {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_context) {
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!不支持OpenGL ES 2.0");
        }
        [EAGLContext setCurrentContext:_context];
        ///这个上下文 默认是关闭深度测试的 也就是说会直接使用最新的片元而不会进行数据的比较
        glDisable(GL_DEPTH_TEST);
        ///这个上下文 默认是关闭深度测试的 也就是说会直接使用最新的片元而不会进行数据的比较
        glDisable(GL_DEPTH_TEST);
    }
    return _context;
}



@end
