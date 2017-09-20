
/*layout (location = 1)  手动指定location*/ attribute vec4 position;                    //外部
attribute vec2 textCoordinate;              //外部
uniform mat4 rotateMatrix;              //外部传进来的

varying lowp vec2 varyTextureCoord;             //传递给片元着色器


void main() {
    varyTextureCoord = textCoordinate;
    vec4 vPos = position;
    vPos = vPos * rotateMatrix;//矩阵相乘 --->
    gl_Position = vPos;// 将输入的顶点位置转移到顶点着色器指定的输出位置gl_Position中
}
