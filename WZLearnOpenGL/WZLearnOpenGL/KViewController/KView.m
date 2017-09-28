//
//  KView.m
//  WZLearnOpenGL
//
//  Created by admin on 27/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "KView.h"
#import "GLESUtils.h"
#import "GLESMath.h"
#import <GLKit/GLKit.h>
#import "WZOpenGLProgram.h"

@interface KView()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLuint frameBufferID;
@property (nonatomic, assign) GLuint renderBufferID;

@property (nonatomic, assign) GLuint program;

@property (nonatomic, assign) GLuint vertices;//顶点

@end

@implementation KView

///layer类型更换
+ (Class)layerClass {
    return  [CAEAGLLayer class];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}

- (void)createViews {
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(renderLoop) userInfo:nil repeats:true];
    
    self.eaglLayer = (CAEAGLLayer *)self.layer;
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    self.eaglLayer.opaque = true;
    self.eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:false], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];
    
    if (glIsRenderbuffer(_renderBufferID)) {
        glDeleteRenderbuffers(1, &_renderBufferID);
        
        _renderBufferID = 0;
    }
    
    if (glIsFramebuffer(_frameBufferID)) {
        glDeleteFramebuffers(1, &_frameBufferID);
        _frameBufferID = 0;
    }
    
    glGenRenderbuffers(1, &_renderBufferID);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBufferID);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
    
    glGenFramebuffers(1,  &_frameBufferID);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferID);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBufferID);
    
    [self render];
}

- (void)render {
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    CGFloat scale = UIScreen.mainScreen.scale;
    glViewport(0.0, 0.0, UIScreen.mainScreen.bounds.size.width * scale, UIScreen.mainScreen.bounds.size.height * scale);
    
   
    
    if (glIsProgram(_program)) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    _program = glCreateProgram();
    GLuint vShader = glCreateShader(GL_VERTEX_SHADER);
    GLuint fShader = glCreateShader(GL_FRAGMENT_SHADER);
    
    NSString *vertexShader = [[NSBundle mainBundle] pathForResource:@"shaderv2" ofType:@"vsh"];
    NSString *fragmentShader = [[NSBundle mainBundle] pathForResource:@"shaderf2" ofType:@"fsh"];
    
    complierShader(&vShader, GL_VERTEX_SHADER, vertexShader, ^(NSString *infoLogStr) {
        if (infoLogStr) {
            NSLog(@"vShader : %@", infoLogStr);
        }
    });
    
    complierShader(&fShader, GL_FRAGMENT_SHADER, fragmentShader, ^(NSString *infoLogStr) {
        if (infoLogStr) {
            NSLog(@"fShader : %@", infoLogStr);
        }
    });
    
    glAttachShader(_program, vShader);
    glAttachShader(_program, fShader);
    glDeleteShader(vShader);
    glDeleteShader(fShader);
    
    [WZOpenGLProgram link:&_program result:^(NSString *infoLogStr) {
        if (infoLogStr) {
            NSLog(@"_program : %@", infoLogStr);
        }
    }];
    
    glUseProgram(_program);
    
    ////一个四棱锥的索引
    GLuint indices[] = {
        0, 3, 2,
        0, 1, 3,
        0, 2, 4,
        0, 4, 1,
        2, 3, 4,
        1, 4, 3,
    };
    
    if (glIsBuffer(_vertices)) {
        glDeleteBuffers(1, &_vertices);
        _vertices = 0;
    }
    
    GLfloat attrArr[] =
    {
        -0.5, 0.5, 0.0,      0.0, 1.0, 1.0, //左上
        0.5, 0.5, 0.0,       0.0, 1.0, 1.0, //右上
        -0.5, -0.5, 0.0,     1.0, 1.0, 1.0, //左下
        0.5, -0.5, 0.0,      1.0, 1.0, 1.0, //右下
        0.0, 0.0, 1.0,      0.0, 1.0, 0.0, //顶点
    };
    
    glGenBuffers(1, &_vertices);
    glBindBuffer(GL_ARRAY_BUFFER, _vertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(attrArr), attrArr, GL_DYNAMIC_DRAW);
    
    
    
    
    
}

- (void)renderLoop {
    //变更坐标啊
}

@end
