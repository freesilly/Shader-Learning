Shader "Custom/Chapter 8/AlphaBlendZWrite"
{
    Properties
    {
        _Color("Main Tint", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _AlphaScale ("Alpha Scale", Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

        Pass
        {
            ZWrite On
            ColorMask 0 //设置颜色通道的写掩码，ColorMask设为0时，意味着该 Pass不写入任何颜色通道
        }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _AlphaScale;

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
                o._uv = TRANSFORM_TEX(v._texcoord, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i._worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i._worldPos));

                fixed4 texColor = tex2D(_MainTex, i._uv);

                fixed3 albedo = texColor.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));

                return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
