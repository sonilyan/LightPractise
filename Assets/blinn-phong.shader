// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/blinn-phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightColor ("LightColor", Color) = (1,1,1,1)
        _Shininess ("Shininess", Range(0,4)) = 0.5
        _Ks ("Ks", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            fixed4 _LightColor;
            half _Shininess;
            half _Ks;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed3 L = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 V = normalize(_WorldSpaceCameraPos.xyz-i.vertex.xyz);
                
                fixed3 H = normalize(L + V); 
                
                float specularLight = pow(max(dot(H, i.normal), 0), _Shininess);
                
                float diffuse = max(0,dot(i.normal,L));
                
                float4 specular = _Ks * _LightColor * specularLight;//Ks：物体对于反射光线的衰减系数 
                
                fixed4 color = diffuse + specular;
                return color;
            }
            ENDCG
        }
    }
}
