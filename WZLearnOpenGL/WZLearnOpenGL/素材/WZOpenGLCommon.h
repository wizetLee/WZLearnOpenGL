//
//  WZOpenGLCommon.h
//  WZLearnOpenGL
//
//  Created by admin on 15/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>

//MARK: -  仿写GPUImage 的一个编译判断
BOOL complierShader(GLuint *shader , GLenum type, NSString * shaderString) {
    
    const GLchar *source = shaderString.UTF8String;
    if (!source) {return false;}//字符串
    
    *shader = glCreateShader(type);//顶点或者是片元的
    glShaderSource(*shader
                   , 1
                   , &source
                   , NULL);
    
    glCompileShader(*shader);//开始编译
    
    GLint complierStatus;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &complierStatus);
    
    if (complierStatus != GL_TRUE) {
        GLint infoLogLength;
        glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &infoLogLength);
        
        if (infoLogLength) {
            GLchar *infoLog = malloc(infoLogLength);//分配
            glGetShaderInfoLog(*shader
                               , infoLogLength
                               , &infoLogLength
                               , infoLog);
            printf("编译报错 : %s", infoLog);
            free(infoLog);//释放
        }
    }
    
    return complierStatus == GL_TRUE;
}

// MARK: - dasdad
