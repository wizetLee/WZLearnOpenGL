//
//  BViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 5/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "BViewController.h"

@interface BViewController ()
{
    GLenum mode;
}
@property (nonatomic, weak) GLKView *glView;
@property (nonatomic, strong) GLKBaseEffect * baseEffect;

@property (nonatomic, assign) GLuint bufferName;



@end


@implementation BViewController

typedef struct {
    GLKVector3 positionCoords;//位置坐标
    GLKVector2 textureCoords;//纹理坐标 定义了几何图形的每个顶点的纹理映射

} SceneVertex;

static const SceneVertex vertices[] = {
    //s   t   r               u  v
//    {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}}, // lower left corner
    {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}}, // lower right corner
    {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}}, // upper left corner
    {{0.5f,  0.5f, 0.0f},  {0.0f, 1.0f}},
};


- (void)viewDidLoad {
    [super viewDidLoad];
    mode = GL_TRIANGLES;
    _glView = (GLKView *)self.view;
    _glView.delegate = (id<GLKViewDelegate>)self;
    _glView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_glView.context];
    
    _baseEffect = [[GLKBaseEffect alloc] init];
    _baseEffect.useConstantColor = GL_TRUE;
    _baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    
    glClearColor(0.15, 0.99, 0.5, 1);
    
    glGenBuffers(1, &_bufferName);
    glBindBuffer(GL_ARRAY_BUFFER, _bufferName);
    glBufferData(GL_ARRAY_BUFFER
                 , sizeof(vertices)
                 , vertices
                 , GL_STATIC_DRAW);
    
    CGImageRef imaegRef = [UIImage imageNamed:@"leaves.gif"].CGImage;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imaegRef options:nil error:NULL];
  
     //    GL_TEXTURE_MIN_FILTER
     //    GL_LINEAR_MIPMAP_LINEAR
     
     /*
     <GLKTextureInfo: 0x17005cda0>
     name=1,
     target=GL_TEXTURE_2D,
     width=256,
     height=256,
     alphaState=GLKTextureInfoAlphaStateNonPremultiplied,
     textureOrigin=GLKTextureInfoOriginTopLeft,  //
     containsMipmaps=0
     */
    //GLKTextureInfo 封装了刚创建的纹理缓存相关的信息，包括尺寸和是否包含MIP贴图等
    
    //设置texture2d0属性使用一个新的纹理缓存
    _baseEffect.texture2d0.name = textureInfo.name;
    _baseEffect.texture2d0.target = textureInfo.target;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.baseEffect prepareToDraw];
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    glVertexAttribPointer(GLKVertexAttribPosition
                          , 3 //数据的字节数
                          , GL_FLOAT
                          , GL_FALSE
                          , sizeof(SceneVertex)
                          , NULL + offsetof(SceneVertex, positionCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0
                          , 2
                          , GL_FLOAT
                          , GL_FALSE
                          , sizeof(SceneVertex)
                          , NULL + offsetof(SceneVertex, textureCoords));
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 3);
    /*
     #define GL_POINTS                                        0x0000
     #define GL_LINES                                         0x0001
     #define GL_LINE_LOOP                                     0x0002
     #define GL_LINE_STRIP                                    0x0003
     #define GL_TRIANGLES                                     0x0004
     #define GL_TRIANGLE_STRIP                                0x0005
     #define GL_TRIANGLE_FAN
     */
}


@end
