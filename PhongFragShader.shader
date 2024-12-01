Shader "Unlit/PhongFragShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _IterateTimes ("Iteration times", Range(1,20)) = 5
    }
    SubShader
    {
        Tags
        {
            "LightMode" = "ForwardBase"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD0;
                float3 normal : NORMAL;
            };

            float4 _MainColor;
            float4 _SpecularColor;
            int _IterateTimes;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 reflectDir = reflect(-lightDir, i.normal);

                fixed4 color = UNITY_LIGHTMODEL_AMBIENT
                    + _MainColor * _LightColor0 * (.5f * dot(lightDir, viewDir) + .5f)
                    + _SpecularColor * _LightColor0 * pow(max(0, dot(reflectDir, viewDir)), _IterateTimes);

                return color;
            }
            ENDCG
        }
    }
}