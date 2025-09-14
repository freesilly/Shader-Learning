Shader "Custom/Chapter 7/MaskTexture"
{
    properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _BumpMap ("Bump Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        _SpecularMask ("Specular Mask", 2D) = "white" {}
        _SpecularScale ("Specular Scale", Float) = 1.0
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            fixed _BumpScale;
            sampler2D _SpecularMask;
            fixed _SpecularScale;
            float4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 _vertex : POSITION;
                float3 _normal : NORMAL;
                float4 _texcoord : TEXCOORD0;
                float4 _tangent : TANGENT;
            };

            struct v2f
            {
                float4 _pos : SV_POSITION;
                float2 _uv : TEXCOORD0;
                float3 _lightDir : TEXCOORD1;
                float3 _viewDir : TEXCOORD2;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o._pos = UnityObjectToClipPos(v._vertex);
                o._uv = TRANSFORM_TEX(v._texcoord, _MainTex);

                float3 binormal = cross(v._normal, v._tangent.xyz) * v._tangent.w;
                float3x3 rotation = float3x3(v._tangent.xyz, binormal, v._normal);

                o._lightDir = mul(rotation, ObjSpaceLightDir(v._vertex)).xyz;
                o._viewDir = mul(rotation, ObjSpaceViewDir(v._vertex)).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 tangentLightDir = normalize(i._lightDir);
                fixed3 tangentViewDir = normalize(i._viewDir);

                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i._uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                float3 albedo = tex2D(_MainTex, i._uv).rgb * _Color.rgb;
                
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                float3 diffuse = _LightColor0.rgb * albedo * saturate((dot(tangentNormal, tangentLightDir)));

                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

                fixed specularMask = tex2D(_SpecularMask, i._uv).r * _SpecularScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss) *specularMask;

                return fixed4(specular + ambient +diffuse, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
