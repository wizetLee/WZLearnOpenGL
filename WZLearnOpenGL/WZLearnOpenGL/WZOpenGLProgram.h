//
//  WZOpenGLProgram.h
//  WZLearnOpenGL
//
//  Created by admin on 18/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

/* TextureParameterName */
typedef NS_ENUM(NSUInteger, WZTextureParameterName) {
    WZTextureParameterName_GL_TEXTURE_MAG_FILTER = GL_TEXTURE_MAG_FILTER,
    WZTextureParameterName_GL_TEXTURE_MIN_FILTER = GL_TEXTURE_MIN_FILTER,
    WZTextureParameterName_GL_TEXTURE_WRAP_S = GL_TEXTURE_WRAP_S,
    WZTextureParameterName_GL_TEXTURE_WRAP_T = GL_TEXTURE_WRAP_T,
};

@interface WZOpenGLProgram : NSObject
{
    GLuint program;
}


///infoLogStr 为空时， 表示编译成功
void complierShader(GLuint *shader, GLenum type, NSString *shaderString, void (^result)(NSString *infoLogStr));
///infoLogStr 为空时， 表示链接成功
+ (void)link:(GLuint *)program result:(void (^)(NSString *infoLogStr))result;



@end
