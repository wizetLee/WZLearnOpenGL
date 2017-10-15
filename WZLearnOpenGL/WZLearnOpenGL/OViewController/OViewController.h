//
//  OViewController.h
//  WZLearnOpenGL
//
//  Created by 李炜钊 on 2017/10/15.
//  Copyright © 2017年 wizet. All rights reserved.
//

#import <GLKit/GLKit.h>
@class AGLKVertexAttribArrayBuffer;

///使用GLK的灯光技巧
@interface OViewController : GLKViewController
@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (strong, nonatomic) GLKBaseEffect *extraEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *vertexBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer *extraBuffer;

@property (nonatomic) GLfloat
centerVertexHeight;
@property (nonatomic) BOOL
shouldUseFaceNormals;
@property (nonatomic) BOOL
shouldDrawNormals;

- (void)takeShouldUseFaceNormalsFrom:(UISwitch *)sender;
- (void)takeShouldDrawNormalsFrom:(UISwitch *)sender;
- (void)takeCenterVertexHeightFrom:(UISlider *)sender;
@end
