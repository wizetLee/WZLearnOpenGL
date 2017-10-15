//
//  LViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 30/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "LViewController.h"
#import "LView.h"
#import <GLKit/GLKit.h>

@interface LViewController ()

@property (nonatomic, strong) LView *aview;

@end

@implementation LViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    self.automaticallyAdjustsScrollViewInsets = false;

    
    _aview = [[LView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_aview];
    
//
//    [self viewPort];
//
//    ///空间分配在设置之后
//    GLfloat vertices[30] =
//    {
//        0.5, -0.5, 0,     1, 0,
//        -0.5, 0.5, 0,     0, 1,
//        -0.5, -0.5, 0,    0, 0,
//        0.5, 0.5, 0,      1, 1,
//        -0.5, 0.5, 0,     0, 1,
//        0.5, -0.5, 0,     1, 0,
//    };
    
    
}

- (void)dealloc {
    [_aview stop];
}

- (void)destroyFrameBuffer:(GLuint *)frameBufferHandle {
    glDeleteFramebuffers(1, frameBufferHandle);
    *frameBufferHandle = 0;
}
- (void)destroyRenderBuffer:(GLuint *)renderBufferHandle {
    glDeleteRenderbuffers(1, renderBufferHandle);
    *renderBufferHandle = 0;
}

- (void)setupFrameBuffer:(GLuint *)frameBufferHandle {
    glGenFramebuffers(1, frameBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, *frameBufferHandle);
}

- (void)setupRenderBuffer:(GLuint *)renderBufferHandle {
    glGenRenderbuffers(1, renderBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, *renderBufferHandle);
}

////设置完上下文 即可配置ViewPoint
- (void)viewPort {
    //视图放大倍数
    CGFloat scale = [UIScreen mainScreen].scale;
    //设置视口
//    glViewport(self.view.frame.origin.x * scale
//               , self.view.frame.origin.y * scale
//               , self.view.frame.size.width * scale
//               , self.view.frame.size.height * scale);
    glViewport(0.0
               , 0.0
               , self.view.frame.size.width * scale
               , self.view.frame.size.height * scale);
}


@end
