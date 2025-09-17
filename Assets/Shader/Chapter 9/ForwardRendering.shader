Shader "Custom/Chapter 9/ForwardRendering"
{
        Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
        _Specular("Specular",Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma multi_compile_fwdbase

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 _vertex : POSITION;
                float3 _normal : NORMAL;
            };

            struct v2f
            {
                float4 _pos : SV_POSITION;
                float3 _worldNormal : TEXCOORD0;
                float3 _worldPos : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o._pos = UnityObjectToClipPos(v._vertex);

                o._worldNormal = UnityObjectToWorldNormal(v._normal);
                o._worldPos = mul(unity_ObjectToWorld,v._vertex).xyz;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET 
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(i._worldNormal);
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i._worldPos.xyz);//因为在顶点着色器中计算过了worldpos，这里直接使用
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // specular = lightcolor * specularcolor * max(0，dot(reflectDir,viewDir))^gloss
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                fixed3 color = ambient + diffuse + specular;

                fixed atten = 1.0;
                return fixed4(color * atten,1.0);
            }

            ENDCG
        }

        Pass
        {
            Tags {"LightMode" = "ForwardAdd"}

            Blend One One

            CGPROGRAM

            #pragma multi_compile_fwdadd

            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                LIGHTING_COORDS(2,3)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;

                TRANSFER_VERTEX_TO_FRAGMENT(o);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET 
            {
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(i.worldNormal);
                // 判断光源类型
                #ifdef USING_DIRECTIONAL_LIGHT
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                #else
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
                #endif

                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);//因为在顶点着色器中计算过了worldpos，这里直接使用
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                // specular = lightcolor * specularcolor * max(0，dot(reflectDir,viewDir))^gloss
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                fixed3 color = ambient + diffuse + specular;

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                return fixed4(color * atten, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
