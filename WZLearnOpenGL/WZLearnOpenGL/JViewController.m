//
//  JViewController.m
//  WZLearnOpenGL
//
//  Created by admin on 15/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "JViewController.h"

@interface JViewController ()
{
    GLKView * glkView;
}
@end

@implementation JViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //以一个计时器作为驱动 对数据的进行修改
    glkView = (GLKView *)self.view;
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:glkView.context];
//    GL_POINT_SIZE
//    glLineWidth(GLfloat width)//设置线段的固定宽度

    //数据匹配
    
//    glPolygonOffset(GLfloat factor, GLfloat unit);
//    glFrontFace(GLenum mode);//反转背面
    
//    glVertexAttribPointer(GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid *ptr);
    
}


@end
