Shader "Custom/NormalMapWorldSpace"
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
                float4 _TtoW0 : TEXCOORD1;
                float4 _TtoW1 : TEXCOORD2;
                float4 _TtoW2 : TEXCOORD3;
                //TtoW0，TtoW1，TtoW2依次存储了从切线空间到世界空间的变换矩阵的每一行
            };

            v2f vert(a2v v)
            {
                v2f o;
                o._pos = UnityObjectToClipPos(v._vertex);


                //xy 分扯存储了_MainTex 的纹理坐标 zw 分量存 BumpMap纹理坐标
                o._uv.xy = v._texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o._uv.zw = v._texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw; //法线纹理的采样坐标

                //计算世界坐标下的顶点坐标，顶点切线，副切线和法线的矢量表示
                float3 WorldPos = mul(unity_ObjectToWorld, v._vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v._normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v._tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v._tangent.w;

                /*
                把它们按列摆放得到从切线空间到世界空间的变换矩阵。我们把该矩阵每一行分别存储 TtoWO
                TtoW1 TtoW2 中，并把世界空间下的顶点位置的 xyz 分量分别存储在了这些变量的分量中，
                */
                o._TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, WorldPos.x);
                o._TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, WorldPos.y);
                o._TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, WorldPos.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                float3 worldPos = float3(i._TtoW0.w, i._TtoW1.w, i._TtoW2.w);
                fixed3 lightDir =normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i._uv.zw)); // bump 就是世界坐标下的法线纹理
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
                bump = normalize(half3(dot(i._TtoW0.xyz, bump), dot(i._TtoW1.xyz, bump), dot(i._TtoW2.xyz, bump)));//将切线空间的法线向量转换到世界空间

                fixed3 albedo = tex2D(_MainTex, i._uv.xy).rgb * _Color.rgb;

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, lightDir));

                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }
    FallBack "Specular"
}
