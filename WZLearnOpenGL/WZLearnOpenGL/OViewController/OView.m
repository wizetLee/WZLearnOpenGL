//
//  OView.m
//  WZLearnOpenGL
//
//  Created by 李炜钊 on 2017/10/15.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "OView.h"
#import <GLKit/GLKit.h>
#import "GLProgram.h"

@interface OView()
@property (nonatomic, weak) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *context;

//整体
@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;

///个别
@property (nonatomic, strong) GLProgram *program0;
@property (nonatomic, assign) GLuint buffer0;
@property (nonatomic, assign) GLuint dataBuffer0;
@property (nonatomic, assign) GLuint texture0;


@end

@implementation OView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    [self setupLayer];
    [self setupContext];
    [self viewPort];
    
    [self setupProgram0];

}
- (void)setupLayer {
    [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    self.eaglLayer.opaque = true;
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithBool:false], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}
- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
}
- (void)viewPort {
    //视图放大倍数
    CGFloat scale = [UIScreen mainScreen].scale;
    //设置视口
    glViewport(0.0
               , 0.0
               , self.frame.size.width * scale
               , self.frame.size.height * scale);
}

- (void)setupProgram0 {
    
}





@end
