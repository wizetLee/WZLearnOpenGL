
varying lowp vec2 varyTextureCoord;//传递了过来

uniform sampler2D colocMap;


void main() {
    gl_FragColor = texture2D(colocMap, varyTextureCoord);
}
