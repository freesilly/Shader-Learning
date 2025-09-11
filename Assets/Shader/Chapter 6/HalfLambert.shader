Shader "Custom/HalfLambert"
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
                float3 _worldNormal : TEXCOORD0;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o._pos = UnityObjectToClipPos(v._vertex);

                o._worldNormal = UnityObjectToWorldNormal(v._normal);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET //和逐顶点光照的区别是，这里是在片元着色器中计算光照
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(i._worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 halfLambert = dot(worldNormal,worldLightDir) * 0.5 + 0.5; // Half Lambert光照模型
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * halfLambert;
                fixed3 color = ambient + diffuse;
                return fixed4(color,1.0);
            }

            ENDCG
        }
    }
    
    FallBack "Diffuse"
}
