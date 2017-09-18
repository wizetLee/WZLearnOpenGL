//
//  WZOpenGLProgram.m
//  WZLearnOpenGL
//
//  Created by admin on 18/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import "WZOpenGLProgram.h"

@implementation WZOpenGLProgram


+ (void)link:(GLuint *)program result:(void (^)(NSString *infoLogStr))result {
    NSString *infoLogStr;
    
    //开始链接
    glLinkProgram(*program);
    GLint linkStatus;
    glGetProgramiv(*program, GL_LINK_STATUS, &linkStatus);
    
    if (linkStatus == GL_FALSE) {
        //链接失败
        GLint infoLogLength;
        glGetProgramiv(*program, GL_INFO_LOG_LENGTH, &infoLogLength);
        
        if (infoLogLength) {
            GLchar *infoLog = malloc(infoLogLength);
            
            glGetProgramInfoLog(*program
                                , infoLogLength
                                , &infoLogLength
                                , infoLog);
            printf("链接出错:%s", infoLog);
            infoLogStr = [NSString stringWithFormat:@"%s", infoLog];
            free(infoLog);
        }
    }
    
    //可以删掉着色器的句柄
    
    
    result(infoLogStr);
}

void complierShader(GLuint *shader, GLenum type, NSString *shaderString, void (^result)(NSString *infoLogStr)) {
    const GLchar *source = shaderString.UTF8String;
    if (!source) {
        result(@"source为空");
        return;
    }//字符串
    NSString *infoLogStr = nil;
    
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
            infoLogStr = [NSString stringWithFormat:@"%s", infoLog];
            free(infoLog);//释放
        }
    }
    //complierStatus == GL_TRUE
    result(infoLogStr);
}

//使得当前程序无效
- (void)validate;
{
    GLint logLength;
    
    glValidateProgram(program);//使当前的程序生效
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        printf("%s", log);
        free(log);
    }	
}

///配置 纹理图片
- (void)configTextureWithImage:(NSString *)imageName textureBufferID:(GLuint *)texBufferID {
    if (!imageName.length) {return;};
    
    CGImageRef imageRef = [UIImage imageNamed:imageName].CGImage;
    
    if(!imageRef) {
        return;
    };
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    /////做判断是否需要图片渲染小一点
    
    GLubyte *spriteData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte))/*RGBA*/;
    //在CGContext上绘制图片
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGContextRef context = CGBitmapContextCreate(spriteData
                                                 , width
                                                 , height
                                                 , 8
                                                 , width * 4
                                                 , colorSpace, kCGImageAlphaPremultipliedLast);//RGBA!
    CGContextDrawImage(context
                       , CGRectMake(0.0, 0.0
                                    , width, height)
                       , imageRef);
    
    glBindTexture(GL_TEXTURE_2D, *texBufferID);
    
    ///GPUImage 是切换成一个枚举
    
    //配置左右上下环绕采样模式
    glTexParameteri(GL_TEXTURE_2D
                    , GL_TEXTURE_MIN_FILTER
                    , GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D
                    , GL_TEXTURE_MAG_FILTER
                    , GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D
                    , GL_TEXTURE_WRAP_S
                    , GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D
                    , GL_TEXTURE_WRAP_T
                    , GL_CLAMP_TO_EDGE);
    
    glTexImage2D(GL_TEXTURE_2D
                 , 0
                 , GL_RGBA
                 , (GLsizei)width
                 , (GLsizei)height
                 , 0
                 , GL_RGBA
                 , GL_UNSIGNED_BYTE
                 , spriteData);
    
    free(spriteData);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    //    CGImageRelease(imageRef);
}


@end
