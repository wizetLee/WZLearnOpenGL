
attribute vec4 position;
attribute vec2 textureCoordinate;

varying lowp vec2 varyTextCoord;
uniform vec2 touchPoint;

void main() {
    varyTextCoord = textureCoordinate;
    
    gl_Position = position;
}

