#version 330 core

#define NUM_ELEMENTS 10

#ifdef NUM_ELEMENTS

#elif

#endif

#extension extension_name : <require>

/*
 着色器中的数据类型有两种：
 1、不透明的：采样器、图像、原子计数器
 2、透明的：
 
 */

struct Particle {
    float lifetime;
    vec3 position;
    vec3 velocity;
};
//GLSL是一种强类型语言（Swift也是）
//变量名称不能有!!!连续的!!!!下划线, 因为这是GLSL所保留使用的格式


/**
 uniform变量是外部application程序传递给（vertex和fragment）shader的变量。因此它是application通过
 函数glUniform**（）函数赋值的。在（vertex和fragment）shader程序内部，uniform变量就像是C语言里面
 的常量（const ），它不能被shader程序修改。（shader只能用，不能改）
 如果uniform变量在vertex和fragment两者之间声明方式完全一样，则它可以在vertex和fragment共享使用。
 每种类型的着色器的uniform变量的存储数量是有限制的，如果超过这个限制，将会引起编译时或链接时错误。
 */
 /**
 attribute修饰符用于声明通过OpenGL ES应用程序传递到顶点着色器中的变量值。
 在其它任何非顶点着色器的着色器中声明attribute变量是错误的。在顶点着色器被程序使用之前，attribute变量是只读的。
 attribute变量的值通过OpenGL ES顶点API或者作为顶点数组的一部分被传进顶点着色器。
 它们传递顶点属性值到顶点着色器，并且在每一个运行的顶点着色器中都会改变。
 attribute修饰符只能修饰float, vec2, vec3, vec4,mat2,mat3,mat4。attribute变量不能声明为数组或结构体。
 一般用attribute变量来表示一些顶点的数据，如：顶点坐标，法线，纹理坐标，顶点颜色等。
 */
/**
 varying变量是vertex和fragment shader之间做数据传递用的。一般vertex shader修改varying变量的值，
 然后fragment shader使用该varying变量的值。因此varying变量在vertex和fragment shader二者之间的声
 明必须是一致的。application不能使用此变量。
 */

uniform vec4 baseColor; //只能外部应用赋值，不可在GLSL中修改
attribute vec4 coords; //可传递到片元着色器处  声明的变量名必须一致

void main () {
    

    
    vec3 velocity = vec3(1.0, 1.0, 2.0);
    ivec3 steps = ivec3(veloctiy);//算是强转吧
    
    vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
    vec3 RGB = vec3(color);//截取前三个分量..
    
    vec3 white = vec3(1.0);//(1.0, 1.0, 1.0)
    vec4 translucent = vec4(white, 0.5);
    mat3 m = mat3(4.0);
    /*
        4.0  0.0  0.0
        0.0  4.0  0.0
        0.0  0.0  4.0
    */
    
    mat3 M = mat3(1.0, 2.0, 3.0,   //第一列
                  4.0, 5.0, 6.0,   //第二列
                  7.0, 8.0, 9.0    //第三列
                  );
    
    //等于
    mat3 M2 = mat3(mat2(1.0, 2.0), 3.0,
                   mat2(4.0, 5.0), 6.0,
                   mat2(7.0, 8.0), 9.0,
                   );
    
    /* 结果
     1.0  4.0  7.0
     2.0  5.0  8.0
     3.0  6.0  9.0
     */
    
    
    //MARK: - 如何访问向量和矩阵中的元素？
    //(1)
    float colorR = color.r;//访问四分量的某一个分量名称   r g b a(颜色相关的坐标分量)  x y z w(位置相关的坐标分量)  s t p q(纹理坐标相关的分量)
    //(2)
    float colorR2 = color[0];//通过数组索引访问
    
    
    //swzzile
    vec3 luminance/*亮度*/ = color.rrr;
    
    color = color.abgr;//反转color的每个分量
    
    float accessM21 = M2[2][1];//访问第三列第二个元素

    //结构体
    Particle p = Particle(10.0, vec3(1.0, 2.0, 3.0), vec3(3.0, 2.0, 1.0));
    
    //数组
    float coeff[3] = float[3](2.33, 3.55, 5.55);
    for (int i = 0; i < coeff.length(); i++) {
        coeff[i] = coeff[i] * 2 + i;
    }
    /// .length()  可以用在计算向量的长度 以及矩阵的列数
    //const 常量
    //in    设置这个变量为着色器阶段的输入变量
    //out   设置这个变量为着色器阶段的输出变量
    //uniform (存储限制符，必须为全局变量)  设置这个变量为！！！用户应用程序传输给着色器！！！的数据，它对于给定的图元而言是一个常量
    //buffer    设置应用程序共享的一块可读的内存，这块内存也可作为着色器中的存储缓存（storage buffer）使用
    //shared    设置变量是本地工作组（local work group）中共享的，它只能用于计算着色器当中
    
    const float pi = 3.141529;
    
    
    //如果需要在应用程序中共享一大块缓存给着色器应该使用buffer变量
    //buffer 指定随后的块作为着色器与应用程序共享一块内存缓存
    
    
    
//    mat3x4 3列4行
    
}
