
uniform sampler2D texture0;
varying lowp vec2 varyTextureCoordinate;

void main() {
    gl_FragColor = texture2D(texture0, 1.0 - varyTextureCoordinate);
    //该构造函数原型是static function Texture2D (width : int, height : int       \
                                              , format : TextureFormat    \
                                              , mipmap : bool) : Texture2D ;
}
