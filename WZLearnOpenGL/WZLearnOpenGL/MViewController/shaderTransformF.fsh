varying lowp vec2 varyTextCoord;
varying lowp vec2 varyOtherPostion;

uniform sampler2D texture1;

void main()
{
//    lowp vec4 text = texture2D(texture1, 1.0 - varyTextCoord);///1.0
    lowp vec4 text = texture2D(texture1, varyTextCoord);//
//    text.a = 1.0;//改了背景颜色alphe
    gl_FragColor = text;
    //    gl_FragColor = (1.0 - text.a) * gl_lastFragData[0] + text * text.a;
}
