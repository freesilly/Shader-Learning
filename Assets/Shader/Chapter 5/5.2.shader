Shader "Custom/5.2"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _Color;

            struct a2v{ // 应用阶段传递给顶点着色器的输入结构体
                float4 _vertex : POSITION; // 顶点坐标（模型空间）
                float3 _normal :NORMAL; // 法线（模型空间）
                float4 _texcoord: TEXCOORD0; // 纹理坐标（第一套，编号为0）
            };

            struct v2f{ // 顶点着色器输出的结构体
                float4 _pos : SV_POSITION; // 裁剪空间中的顶点坐标
                fixed3 _color : COLOR0; // 颜色
            };

            v2f vert(a2v v) // 顶点着色器
            {
                v2f o;
                o._pos = UnityObjectToClipPos( v._vertex);
                o._color = v._normal *0.5 + fixed3(0.5,0.5,0.5);
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET // 片元着色器
            {
                fixed3 c = i._color;
                c *= _Color.rgb;
                return fixed4(c, 1.0);
            }

            ENDCG
        }
    }
}
