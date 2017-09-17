//
//  WZOpenGLDriver.h
//  WZLearnOpenGL
//
//  Created by 李炜钊 on 2017/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface WZOpenGLDriver : NSObject

//MARK: -  仿写GPUImage 的一个编译判断
BOOL complierShader(GLuint *shader , GLenum type, NSString *shaderString);

- (void)configTextureWithImage:(NSString *)imageName textureBufferID:(GLuint *)texBufferID;

@end
