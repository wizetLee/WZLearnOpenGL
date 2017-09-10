//
//  HViewController.m
//  WZLearnOpenGL
//
//  Created by 李炜钊 on 2017/9/10.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "HViewController.h"

// MARK: - 数据

typedef struct {
    GLKVector3 postition;
    GLKVector3 normal;
} SceneVertex;

typedef struct {
    SceneVertex vertices[3];
} SceneTriangle;


#define NORMLA_FACES (8)

//顶点数据的位置
static const SceneVertex vertexA =
{{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexB =
{{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexC =
{{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexD =
{{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexE =
{{ 0.0,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexF =
{{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexG =
{{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexH =
{{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexI =
{{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

//函数

///3位 单位法向量
GLKVector3 SceneVector3UnitNormal(GLKVector3 vectorA, GLKVector3 vectorB) {
    return GLKVector3CrossProduct(vectorA, vectorB);
}

//内联函数   求矢量积
//GLKVector3CrossProduct(GLKVector3 vectorLeft, GLKVector3 vectorRight )
//GLKVector3 GLKVector3CrossProduct(GLKVector3 vectorA, GLKVector3 vectorB ) {
//    GLKVector3 result = {
//        vectorA.y * vectorB.z - vectorA.z * vectorB.y,
//        vectorA.z * vectorB.x - vectorA.x * vectorB.z,
//        vectorA.x * vectorB.y - vectorA.y * vectorB.x,
//    };
//    return result;
//}

//求向量的长度 FLT_EPSILON 是一个非常小的在浮点数学计算的过程中不会被舍入为0的正数
GLfloat SceneVector3Length (const GLKVector3 vector ) {
    GLfloat length = 0.0;
    GLfloat lengthSquared = vector.x * vector.x + vector.y * vector.y + vector.z * vector.z;
    if (FLT_EPSILON < lengthSquared) {// 确保lengthSquared不太接近于0以防止在不经意间计算了0的平方根
        length = sqrtf(lengthSquared);
    }
    return length;
}

//用于缩放矢量为一个单位向量
GLKVector3 SceneVector3Nromalize(GLKVector3 vector) {
    const GLfloat length = SceneVector3Length(vector);
    float oneOverLength = 0.0;
    if (FLT_EPSILON < length) {
        oneOverLength = 1.0 / length;
    }
    
    GLKVector3 result = {
        vector.x * oneOverLength,
        vector.y * oneOverLength,
        vector.z * oneOverLength,
    };
    return result;
}

@interface HViewController ()
{
    GLKBaseEffect *baseEffect;
    GLuint bufferID;
    GLKView *glkView;
    GLKBaseEffect * extraEffect;
    
    
    SceneTriangle triangles[8];
}

@end

@implementation HViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //返回一个与矢量方向相同但是大小等于1.0的单位向量
//    GLKVector3Normalize(GLKVector3 vector)
    glkView = (GLKView *)self.view;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
    
    baseEffect = [[GLKBaseEffect alloc] init];
    
    //每个灯光 至少又一个位置 一个环境颜色 一个漫反射颜色和一个镜面反射颜色
    baseEffect.light0.enabled = GL_TRUE;
    //配置漫反射颜色
    baseEffect.light0.diffuseColor = GLKVector4Make(0.7, 0.7, 0.7, 1.0);//中等灰色
    baseEffect.light0.position = GLKVector4Make(1.0, 1.0, 0.5, 0.0);
  
    extraEffect = [[GLKBaseEffect alloc] init];
    extraEffect.useConstantColor = GL_TRUE;
    extraEffect.constantColor = GLKVector4Make(0, 1, 0, 1);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    
    /**
     [quote]#define FLT_EPSILON                1.19209290E-07F
     #define LDBL_EPSILON                1.084202172485504E-19[/quote]
     
     这两个宏定义可用来作为float、 long double趋0最小的判断值。即：
     #include <float.h>;
     double a, b;
     if( abs(a-b) < FLT_EPSILON)
     */
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
