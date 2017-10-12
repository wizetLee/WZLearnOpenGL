//
//  LView.h
//  WZLearnOpenGL
//
//  Created by admin on 30/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLProgram.h"

@interface LView : UIView

@property (nonatomic, weak) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *context;

//整体
@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;

///个别
@property (nonatomic, strong) GLProgram *program0;
@property (nonatomic, assign) GLuint buffer0;
@property (nonatomic, assign) GLuint dataBuffer0;
@property (nonatomic, assign) GLuint texture0;

@end
