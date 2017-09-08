//
//  EViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 8/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "EViewController.h"

@interface EViewController ()
{
    GLKBaseEffect *baseEffect;
    GLuint bufferID;
    GLKView *glView;
}
@end



typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
}
SceneVetex;

static SceneVetex vertices[] = {
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // first triangle
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // second triangle
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};

//static SceneVetex vertices2[] = {
//    {{-1.0f/2, -0.67f/2, 0.0f}, {0.0f, 0.0f}},  // first triangle
//    {{ 1.0f/2, -0.67f/2, 0.0f}, {1.0f/2, 0.0f}},
//    {{-1.0f/2,  0.67f/2, 0.0f}, {0.0f, 1.0f/2}},
//    {{ 1.0f/2, -0.67f/2, 0.0f}, {1.0f/2, 0.0f}},  // second triangle
//    {{-1.0f/2,  0.67f/2, 0.0f}, {0.0f, 1.0f/2}},
//    {{ 1.0f/2,  0.67f/2, 0.0f}, {1.0f/2, 1.0f/2}},
//};


@implementation EViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    glView = (GLKView *)self.view;
    glView.delegate = (id<GLKViewDelegate>)self;
    glView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glView.context];
    
    baseEffect = [[GLKBaseEffect alloc] init];
    baseEffect.useConstantColor = GL_TRUE;
    baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    glClearColor(0, 0, 0, 1);
    
    glGenBuffers(1, &bufferID);
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    glBufferData(GL_ARRAY_BUFFER
                 , sizeof(vertices)
                 , vertices
                 , GL_STATIC_DRAW);
    
    GLKTextureInfo *info1 = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"leaves2.gif"].CGImage options:nil error:NULL];
    GLKTextureInfo *info2 = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"beetle.png"].CGImage options:nil error:NULL];
    
    //确认单一通道可以结合多少个纹理
    GLint iUnits;
    glGetIntegerv(GL_MAX_TEXTURE_SIZE, &iUnits);
    
    baseEffect.texture2d0.target = info1.target;
    baseEffect.texture2d0.name = info1.name;

    baseEffect.texture2d1.target = info2.target;
    baseEffect.texture2d1.name = info2.name;
    baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;//使用一个与glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)类型的方程式来混合第二个与第一个纹理
    
    //组合组配置选项
//    GLKEffectPropertyTexture
    /*
     envMode 用于配置混合模式
         GLKTextureEnvModeReplace,
         GLKTextureEnvModeModulate,   默认mode 几乎总是产生最好的结果的模式、让所有的为灯光和其他效果计算出来的颜色和一个纹理取样的颜色相混合
         GLKTextureEnvModeDecal 使用一个与glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)类型的方程式来混合第二个与第一个纹理
     */
    
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition
                          , 3
                          , GL_FLOAT
                          , GL_FALSE
                          , sizeof(SceneVetex)
                          , NULL + offsetof(SceneVetex, positionCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0
                          , 2, GL_FLOAT
                          , GL_FALSE
                          , sizeof(SceneVetex)
                          , NULL + offsetof(SceneVetex, textureCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord1);
    glVertexAttribPointer(GLKVertexAttribTexCoord1
                          , 2, GL_FLOAT
                          , GL_FALSE
                          , sizeof(SceneVetex)
                          , NULL + offsetof(SceneVetex, textureCoords));
    
    
//    let ptr = UnsafePointer<GLfloat>([vertexData.v1.position.x])
    
    [baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertices) / sizeof(SceneVetex));
    
}



@end
