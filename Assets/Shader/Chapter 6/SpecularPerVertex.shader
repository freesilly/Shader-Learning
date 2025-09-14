Shader "Custom/Chapter 6/SpecularPerVertex"
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
                fixed3 _color : COLOR;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o._pos = UnityObjectToClipPos(v._vertex);

                //计算漫反射部分和之前的相同
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 worldNormal = normalize(UnityObjectToWorldNormal(v._normal));
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

                //计算镜面反射部分
                fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));// 计算反射方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,v._vertex).xyz);// 计算观察方向
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);

                o._color = ambient + diffuse + specular;
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
