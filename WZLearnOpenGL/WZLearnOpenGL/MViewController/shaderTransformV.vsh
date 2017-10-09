
attribute vec4 position;
attribute vec2 textureCoordinate;

uniform mat4 rotateMatrix;//旋转矩阵
uniform vec2 anchorPoint;//锚点 像position一样的坐标系
uniform float whRate;//宽高比

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
//    vec4 tempPosition = rotateMatrix * position * scaleMatrix;//结果
//    ///计算偏移量
//    tempPosition.x =  tempPosition.x + xOffset;
//    tempPosition.y =  tempPosition.y - yOffset;//Y为相反方向
  
    
    ///尴尬的是目前只能原地地旋转

//印象中的旋转
    vec4 rotatedPosition = position;
    rotatedPosition.x = rotatedPosition.x - anchorPoint.x;
    rotatedPosition.y = (rotatedPosition.y  - anchorPoint.y) / whRate;
    
    rotatedPosition = rotateMatrix * rotatedPosition;//经过了旋转变换
    
    rotatedPosition.x = rotatedPosition.x + anchorPoint.x;//然后再恢复原来的位置
    rotatedPosition.y = rotatedPosition.y * whRate + anchorPoint.y;
//    gl_Position = rotatedPosition;
//缩放
    vec4 scaledPosition = rotatedPosition * scaleMatrix;
//偏移
    vec4 offsetPosition = scaledPosition;
    offsetPosition.x =  offsetPosition.x + xOffset;
    offsetPosition.y =  offsetPosition.y + yOffset;//Y为相反方向
  
    
    gl_Position = offsetPosition;
    
//    gl_Position = tempPosition;//矩阵相乘
}
