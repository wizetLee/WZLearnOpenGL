
varying lowp vec2 varyTextCoord;
varying lowp vec2 varyOtherPostion;

uniform sampler2D texture;

void main()
{
    lowp vec4 text = texture2D(texture, varyTextCoord);
    gl_FragColor = text;
}
