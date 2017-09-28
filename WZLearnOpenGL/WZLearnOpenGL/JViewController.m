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
    
    
    ///绘制命令  以draw开头
    //
    
    
    /**
     mode :  GL_TRIANGLES等
     count ： 定义一系列的几何图元
     type :    GL_UNSIGNED_   INT/ BTYE/SHORT
     indices  ： 定义了索引数据开始的位置
     */
    
    /***
     mode指定绘制图元的类型，它应该是下列值之一，GL_POINTS, GL_LINE_STRIP, GL_LINE_LOOP, GL_LINES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, GL_TRIANGLES, GL_QUAD_STRIP, GL_QUADS, and GL_POLYGON.
     count为绘制图元的数量乘上一个图元的顶点数。
     type为索引值的类型，只能是下列值之一：GL_UNSIGNED_BYTE, GL_UNSIGNED_SHORT, or GL_UNSIGNED_INT。
     indices：指向索引存贮位置的指针。
     **/
//    glDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid *indices   )//使用了元素数组缓存中的索引数据来索引各个顶点属性数组
    
    /*
         从当前启用的顶点属性数组中读取顶点的信息，并使用他们来构建mode指定的图元类型。
     
     */
}


@end
