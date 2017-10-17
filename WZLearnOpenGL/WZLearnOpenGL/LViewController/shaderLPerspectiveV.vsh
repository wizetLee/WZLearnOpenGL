attribute vec4 position;
attribute vec2 textureCoordinate;

uniform mat4 transform;//传入的仿射变换

varying lowp vec2 varyTextCoord;

void main(void) {
    varyTextCoord = textureCoordinate;
    //矩阵相乘
    gl_Position = transform * position;//向量组position经过矩阵transform所描述的变换，变成了向量gl_Position。
}

