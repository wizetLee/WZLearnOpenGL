//
//  CViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 6/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "CViewController.h"
//使用到的数据

typedef struct {
    GLKVector3 positionCoords;
    GLKVector2 textureCoords;
} SceneVertex;

static SceneVertex vertices[] = {
    {{-0.5, -0.5 , 0.0}, {0.0, 0.0}  },
    {{0.5, -0.5 , 0.0}, {1.0, 0.0}  },
    {{-0.5, 0.5 , 0.0}, {0.0, 1.0}  },
};


static const SceneVertex defaultVertices[] = {
    {{-0.5, -0.5 , 0.0}, {0.0, 0.0}  },
    {{0.5, -0.5 , 0.0}, {1.0, 0.0}  },
    {{-0.5, 0.5 , 0.0}, {0.0, 1.0}  },
};

//平移的量
static GLKVector3 movementVectors[3] = {
//    {-0.02, -0.01, 0.0},
//    {0.01, -0.005, 0.0},
//    {-0.01, 0.01, 0.0},
    {0, 0.01, 0.00},
    {0, 0, 0.00},
    {0, 0, 0.00},
};


@interface CViewController ()
{
    GLuint bufferID;
    GLKBaseEffect *baseEffect;
    GLKView *glView;
    GLfloat sCoordinateOffset;
}

@end

@implementation CViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置刷新帧的速率
    self.preferredFramesPerSecond = 60;
    glView = (GLKView *)self.view;
    glView.delegate = (id<GLKViewDelegate>)self;
    glView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glView.context];
    
    
    baseEffect = [[GLKBaseEffect alloc] init];
    baseEffect.useConstantColor = GL_TRUE;
    baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1);//为啥不是黑色就是红色?
    glClearColor(0, 0, 0, 1);
    
    
    glGenBuffers(1, &bufferID);
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(defaultVertices)
                 , defaultVertices
                 , GL_STATIC_DRAW);//buffer 的使用方式
    
    CGImageRef imageRef = [UIImage imageNamed:@"grid"].CGImage;
    GLKTextureInfo *info = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    
    baseEffect.texture2d0.name = info.name;
    baseEffect.texture2d0.target = info.target;
    self.delegate = (id<GLKViewControllerDelegate>)self;
    
    
}

#pragma mark - 在哪里触发的？  一个内部的函数？ self.preferredFramesPerSecond触发
- (void)update {
    //修改对应的参数
    

    for(int i = 0; i < 3; i++) {
        //更改X
        vertices[i].positionCoords.x += movementVectors[i].x;
        if(vertices[i].positionCoords.x >= 1.0f ||
           vertices[i].positionCoords.x <= -1.0f)
        {
            //翻转平移的量
            movementVectors[i].x = -movementVectors[i].x;
        }
        //更改Y
        vertices[i].positionCoords.y += movementVectors[i].y;
        if(vertices[i].positionCoords.y >= 1.0f ||
           vertices[i].positionCoords.y <= -1.0f)
        {
            //翻转平移的量
            movementVectors[i].y = -movementVectors[i].y;
        }
        //更改Z
        vertices[i].positionCoords.z += movementVectors[i].z;
        if(vertices[i].positionCoords.z >= 1.0f ||
           vertices[i].positionCoords.z <= -1.0f)
        {
            //翻转平移的量
            movementVectors[i].z = -movementVectors[i].z;
        }
        NSLog(@"x = %f, y = %f, z = %f", movementVectors[i].x, movementVectors[i].y, movementVectors[i].z);
    }
  

    glBindTexture(baseEffect.texture2d0.target, baseEffect.texture2d0.name);
    
    //当图片过小的时候
//    glTexParameteri(baseEffect.texture2d0.target
//                    , GL_TEXTURE_WRAP_T
//                    , GL_REPEAT);//GL_CLAMP_TO_EDGE
    
    //控制这个平铺的模式
    glTexParameteri(baseEffect.texture2d0.target
                    , GL_TEXTURE_WRAP_S
                    , GL_REPEAT);//GL_CLAMP_TO_EDGE
    
    
    //控制取片元纹素的模式
    glTexParameteri(baseEffect.texture2d0.target
                    , GL_TEXTURE_MAG_FILTER
                    , GL_NEAREST);//GL_NEAREST
    
    //获取最新的数据
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);
    glBufferData(GL_ARRAY_BUFFER
                 , sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller {
    NSLog(@"111");
}

#pragma mark - delegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [baseEffect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //开启顶点
    glVertexAttribPointer(GLKVertexAttribPosition
                          , 3
                          , GL_FLOAT
                          , GL_FALSE
                          , sizeof(SceneVertex)
                          , NULL + offsetof(SceneVertex, positionCoords));
    
    //开启缓存
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0
                          , 2
                          , GL_FLOAT, GL_FALSE
                          , sizeof(SceneVertex)
                          , NULL + offsetof(SceneVertex
                                            , textureCoords));
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
}


@end
