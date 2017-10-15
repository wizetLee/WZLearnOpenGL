//
//  GLKContext.h
//  
//

#import <GLKit/GLKit.h>

@interface AGLKContext : EAGLContext
{
   GLKVector4 clearColor;//{0 0 0 0 }
}

@property (nonatomic, assign, readwrite) 
   GLKVector4 clearColor;

- (void)clear:(GLbitfield)mask;//告诉OpenGL ES去设置在上下文的帧缓存中的每个像素颜色为clearColor元素值的方法
- (void)enable:(GLenum)capability;//数据类型

- (void)disable:(GLenum)capability;
- (void)setBlendSourceFunction:(GLenum)sfactor 
   destinationFunction:(GLenum)dfactor;
   
@end
