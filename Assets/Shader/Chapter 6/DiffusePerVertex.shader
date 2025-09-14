Shader "Custom/Chapter 6/DiffusePerVertex"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;

            struct a2v
            {
                float4 _vertex : POSITION;
                float3 _normal : NORMAL;
            };

            struct v2f
            {
                float4 _pos : SV_POSITION;
                fixed3 _color : COLOR;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o._pos = UnityObjectToClipPos(v._vertex);// 将顶点坐标从模型空间转换为裁剪空间

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; // 环境光
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v._normal)); // 将法线从模型空间转换为世界空间
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz); // 世界空间中的光照方向
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
                o._color = ambient + diffuse;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                return fixed4(i._color,1.0);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
