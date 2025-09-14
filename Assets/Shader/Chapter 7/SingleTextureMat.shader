Shader "Custom/Chapter 7/SingleTextureMat"
{
    Properties
    {
        _Color("Color Tint", Color) = (1,1,1,1)
        _MainTex("Main Tex", 2D) = "white" {}
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
            float4 _MainTex_ST; //纹理的属性，表示纹理的缩放和平移
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
                o._worldPos = mul(unity_ObjectToWorld, v._vertex);
                o._uv = v._texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw; //纹理的采样坐标
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                fixed3 worldNormal = normalize(i._worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

                fixed3 albedo = tex2D(_MainTex, i._uv).rgb * _Color.rgb; //材质的反射率

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo; //对于带材质的环境光要乘以材质的反射率

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));

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
