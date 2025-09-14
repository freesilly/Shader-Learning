Shader "Custom/Chapter 7/RampTexture"
{
    properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _RampTex ("Ramp Tex", 2D) = "white" {}
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 _vertex : POSITION;
                float3 _normal : NORMAL;
                float4 _texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 _pos : SV_POSITION;
                float3 _worldNormal : TEXCOORD0;
                float3 _worldPos : TEXCOORD1;
                float2 _uv : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o._pos = UnityObjectToClipPos(v._vertex);
                o._worldNormal = UnityObjectToWorldNormal(v._normal);
                o._worldPos = mul(unity_ObjectToWorld, v._vertex).xyz;
                o._uv = TRANSFORM_TEX(v._texcoord, _RampTex);//将uv坐标从模型空间转换到纹理空间
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 worldNormal = normalize(i._worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i._worldPos));

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb;

                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i._worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
