////正常的绘制

attribute vec3 position;//顶点
attribute vec2 textureCoordinate;

varying lowp vec2 varyTextureCoordinate;

void main() {
    ///期间需要计算从外部传进来的值
    varyTextureCoordinate = textureCoordinate;
    gl_Position = vec4(position, 1);
    
}
