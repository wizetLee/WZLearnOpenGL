varying lowp vec2 varyTextCoord;

uniform sampler2D texture;

void main()
{
    gl_FragColor = texture2D(texture, varyTextCoord);//左右颠倒
//    gl_FragColor = texture2D(texture0, 1 - varyTextCoord);//上下颠倒
}
