
attribute vec4 position;
attribute vec2 textureCoordinate;

uniform mat4 rotateMatrix;//旋转矩阵
uniform float scale;//缩放比例

//X轴 Y轴的平移偏移量
uniform float xOffset;
uniform float yOffset;

varying lowp vec2 varyTextCoord;


void main() {
    varyTextCoord = textureCoordinate;
    
    ///scale normal 为 1
    mat4 scaleMatrix = mat4(scale, 0, 0, 0,
                             0, scale, 0, 0,
                             0, 0, 1, 0,
                             0, 0, 0, 1);
    /*同时修改Sx Sy Sz
      Sx
         Sy
             Sz
     */
    
//    mat4 displacementMatrix = mat4(1, 0, 0, 0,
//                                   0, 1, 0, 0,
//                                   0, 0, 1, 0,
//                                   0.0, 0.0, 0.0, 1);
//    /*同时修改Sx Sy Sz
//         _
//         _
//         Sx Sy Sz
//     */
    
    vec4 tempPosition = rotateMatrix * position * scaleMatrix;
    ///计算偏移量
    tempPosition.x =  tempPosition.x + xOffset;
    tempPosition.y =  tempPosition.y - yOffset;//Y为相反方向
    
    ///尴尬的是目前只能原地地旋转
    
    gl_Position = tempPosition;//矩阵相乘
}
