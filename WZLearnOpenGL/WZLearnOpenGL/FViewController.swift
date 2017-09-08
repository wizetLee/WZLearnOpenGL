//
//  FViewController.swift
//  WZLearnOpenGL
//
//  Created by admin on 8/9/17.
//  Copyright © 2017年 wizet. All rights reserved.
//

import UIKit
import GLKit


struct SceneVertex {
   var  positionCoords : GLKVector3
   var textureCoords :GLKVector2
}

///两个三角形 形成一个矩形
var vertices : [SceneVertex] = [
    SceneVertex(positionCoords: GLKVector3Make(-1.0, -0.67, 0.0), textureCoords: GLKVector2Make(0.0, 0.0)),
    SceneVertex(positionCoords: GLKVector3Make(1.0, -0.67, 0.0), textureCoords: GLKVector2Make(1.0, 0.0)),
    SceneVertex(positionCoords: GLKVector3Make(-1.0, 0.67, 0.0), textureCoords: GLKVector2Make(0.0, 1.0)),
    
    SceneVertex(positionCoords: GLKVector3Make(1.0, -0.67, 0.0), textureCoords: GLKVector2Make(1.0, 0.0)),
    SceneVertex(positionCoords: GLKVector3Make(-1.0, 0.67, 0.0), textureCoords: GLKVector2Make(0.0, 1.0)),
    SceneVertex(positionCoords: GLKVector3Make(1.0, 0.67, 0.0), textureCoords: GLKVector2Make(1.0, 1.0)),
];

class FViewController: GLKViewController {
    let baseEffect : GLKBaseEffect = GLKBaseEffect()
    var glKView : GLKView? = nil
    var bufferID : GLuint = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.yellow
        glKView = self.view as? GLKView
        glKView?.context = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        EAGLContext.setCurrent(glKView?.context)
        
        baseEffect.useConstantColor = GLboolean(GL_TRUE)//还要强转🤣 不直接兼容C就是蛋疼
        baseEffect.constantColor = GLKVector4Make(1, 1, 1, 1)
        
        glClearColor(0.5, 0, 0.5, 1);
        
        glGenBuffers(GLsizei(1), &bufferID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), bufferID)
//        UnsafeRawPointer
        // demo 3-6 简直爆炸
        // MARK: - 非常蹩脚的方法计算大小.........
        glBufferData(GLenum(GL_ARRAY_BUFFER)
            , GLsizeiptr(MemoryLayout.size(ofValue: vertices[0]) * vertices.count)
            , vertices, GLenum(GL_STATIC_DRAW))
        
        let info2 : GLKTextureInfo = try! GLKTextureLoader.texture(with: (UIImage.init(named: "beetle.png")?.cgImage)! , options: nil);
        let info1 : GLKTextureInfo = try! GLKTextureLoader.texture(with: (UIImage.init(named: "leaves2.gif")?.cgImage)! , options: nil);
        
        baseEffect.texture2d0.target = GLKTextureTarget(rawValue: info1.target)!
        baseEffect.texture2d0.name = info1.name
        baseEffect.texture2d1.target = GLKTextureTarget(rawValue: info2.target)!
        baseEffect.texture2d1.name = info2.name
        baseEffect.texture2d1.envMode = .decal
    }

    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
       
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
       
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue)
            , 3
            , GLenum(GL_FLOAT)
            , GLboolean(GL_FALSE)
            , GLsizei(MemoryLayout.size(ofValue: vertices[0]))  //GLsizei(MemoryLayout.size(ofValue: vertices[0]))
            , nil)
        
       
        func BUFFER_OFFSET(n: Int) -> UnsafePointer<Void> {
            let ptr: UnsafePointer<Void>? = nil
            return ptr! + n
        }
        
//        withUnsafePointer(to: &vertices[0].textureCoords) { (ptr)  in
//            glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 4, UInt32(GL_FLOAT), UInt8(GL_FALSE), GLsizei(MemoryLayout.size(ofValue: vertices[0]))
//                , ptr)
//        }
     
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue)
            , 2
            , GLenum(GL_FLOAT)
            , GLboolean(GL_FALSE)
            , GLsizei(MemoryLayout.size(ofValue: vertices[0]))
            , nil)//偏移量没写好
        
        
//        withUnsafePointer(to: &vertices[0].textureCoords) { (ptr)  in
//            glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue)
//                , 2
//                , GLenum(GL_FLOAT)
//                , GLboolean(GL_FALSE), GLsizei(MemoryLayout.size(ofValue: vertices[0]))
//                , ptr)
//        }

//        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord1.rawValue))
//        withUnsafePointer(to:nil) { (ptr)  in
//            glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord1.rawValue)
//                , 2
//                , GLenum(GL_FLOAT)
//                , GLboolean(GL_FALSE), GLsizei(MemoryLayout.size(ofValue: vertices[0]))
//                , ptr)
//        }
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord1.rawValue)
            , 2
            , GLenum(GL_FLOAT)
            , GLboolean(GL_FALSE)
            , GLsizei(MemoryLayout.size(ofValue: vertices[0]))
            , nil)
     
        baseEffect.prepareToDraw()
        glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(vertices.count))
    }

    
    func saySomething() {
        print("说了什么！❓")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
