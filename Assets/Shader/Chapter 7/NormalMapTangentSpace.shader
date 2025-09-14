Shader "Custom/Chapter 7/NormalMapTangentSpace"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
        _MainTex("Main Tex", 2D) = "white" {}
        _BumpMap("Bump Map", 2D) = "bump" {} //法线纹理
        _BumpScale("Bump Scale", Float) = 1.0// 法线纹理的强度
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 _vertex : POSITION;
                float3 _normal : NORMAL;
                float4 _tangent : TANGENT; //切线方向
                float4 _texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 _pos : SV_POSITION;
                float4 _uv : TEXCOORD0;
                float3 _lightDir : TEXCOORD1; //切线坐标下的光线方向
                float3 _viewDir : TEXCOORD2; //切线坐标下的视角方向
            };

            v2f vert(a2v v)
            {
                v2f o;
                o._pos = UnityObjectToClipPos(v._vertex);


                //xy 分扯存储了_MainTex 的纹理坐标 zw 分量存 BumpMap纹理坐标
                o._uv.xy = v._texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o._uv.zw = v._texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw; //法线纹理的采样坐标

                //计算模型空间坐标到切线坐标的旋转矩阵
                float3 binormal = cross(v._normal, v._tangent.xyz) * v._tangent.w;
                float3x3 rotation = float3x3(v._tangent.xyz, binormal, v._normal);

                o._lightDir = mul(rotation, ObjSpaceLightDir(v._vertex)).xyz; //将模型空间的光照方向转换到切线坐标下
                o._viewDir = mul(rotation, ObjSpaceViewDir(v._vertex)).xyz; //将模型空间的视角方向转换到切线坐标下

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                float3 tangentLightDir = normalize(i._lightDir);
                float3 tangentViewDir = normalize(i._viewDir);

                fixed4 packedNormal = tex2D(_BumpMap, i._uv.zw); //对法线纹理进行采样
                fixed3 tangentNormal;

                tangentNormal = UnpackNormal(packedNormal); //将法线纹理从[0,1]映射到[-1,1]
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy))); //计算法线纹理的Z分量

                fixed3 albedo = tex2D(_MainTex, i._uv.xy).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
