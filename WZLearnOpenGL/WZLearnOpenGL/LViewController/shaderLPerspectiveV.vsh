attribute vec4 position;
attribute vec2 textureCoordinate;

uniform mat4 transform;//传入的仿射变换

varying lowp vec2 varyTextCoord;

void main(void) {
    varyTextCoord = textureCoordinate;
    ///矩阵相乘
    gl_Position = transform * position;////这个顺序也有讲究！！！！！！！！！！！！！！！！！我擦。。
}

