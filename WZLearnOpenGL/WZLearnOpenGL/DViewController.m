//
//  DViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 6/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "DViewController.h"

@interface DViewController ()
{
    GLKView *glView;
    GLuint bufferID;
    GLKBaseEffect *baseEffect;
    GLKTextureInfo *info1;
    GLKTextureInfo *info2;
}
@end

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
    
} SceneVertex;

///两个三角形 形成一个矩形
static SceneVertex vertices[] = {
    {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // first triangle
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    
    {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // second triangle
    {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};


@implementation DViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    glView = (GLKView *)self.view;
    glView.delegate = (id<GLKViewDelegate>)self;
    glView.context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glView.context];
    baseEffect = [[GLKBaseEffect alloc] init];
    baseEffect.useConstantColor = GL_TRUE;
    baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    glClearColor(0, 0, 0, 1);
    
    //配置动作
    glGenBuffers(1, &bufferID);
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    //配置数据
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    //图片纹理信息获取
    info1 = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"leaves2.gif"].CGImage options:nil error:NULL];
    info2 = [GLKTextureLoader textureWithCGImage:[UIImage imageNamed:@"beetle.png"].CGImage options:nil error:NULL];
#warning 有BUG 就是使用了下面这个key 图片数据的方向就会改变，感觉每次都相反 应该是缓存清楚的原因
    @{GLKTextureLoaderOriginBottomLeft : [NSNumber numberWithBool:YES]};//
    /*
     option 字典可以改为
     [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithBool:YES],
     GLKTextureLoaderOriginBottomLeft, nil]
     
     GLKTextureLoaderOriginBottomLeft
     命令GLKit 的 GLKTextureLoader类垂直翻转图像数据，以抵消图像的原点和OpenGL ES标准原点之间的差异  上面的bug预计是因为没有删掉buffer数据导致的！
     */
    
    glEnable(GL_BLEND);//开启缓和模式
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);//设置混合模式
    /**
     glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 此配置与iOS CoreGraohics 的“正常混合模式”产生相同的结果
     */
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    //开启顶点 - 》 顶点设置
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition
                          , 3, GL_FLOAT, GL_FALSE
                          , sizeof(SceneVertex)
                          , NULL + offsetof(SceneVertex, positionCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0
                          , 2, GL_FLOAT, GL_FALSE
                          , sizeof(SceneVertex)
                          , NULL + offsetof(SceneVertex, textureCoords));
    
    
    //通过多次读写像素颜色渲染缓存来创建一个最终的渲染像素的过程叫做多通道渲染
    //此处经过了两次的运算  使用多重纹理的模式就只需要一次运算
    
    //读纹理
    baseEffect.texture2d0.name = info1.name;
    baseEffect.texture2d0.target = info1.target;
   
//    glBindTexture(baseEffect.texture2d0.target, baseEffect.texture2d0.name);
//    glTexParameteri(baseEffect.texture2d0.target, GL_TEXTURE_WRAP_S, GL_REPEAT);
    
    [baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertices) / sizeof(SceneVertex));
    
    //读纹理
    baseEffect.texture2d0.name = info2.name;
    baseEffect.texture2d0.target = info2.target;
  
//    glBindTexture(baseEffect.texture2d0.target, baseEffect.texture2d0.name);
//    glTexParameteri(baseEffect.texture2d0.target, GL_TEXTURE_WRAP_S, GL_REPEAT);
    
    [baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, sizeof(vertices) / sizeof(SceneVertex));
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
