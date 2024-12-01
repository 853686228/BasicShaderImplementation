Shader "Unlit/PhongFragShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,1,1,1)
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
                float3 normal : NORMAL;
                float4 worldPos : TEXCOORD0;
            };

            float4 _MainColor;
            int _IterateTimes;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(UNITY_MATRIX_M,v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 reflectDir = reflect(-lightDir, i.normal);

                float4 color = _MainColor * _LightColor0 * pow(max(0,dot(reflectDir,viewDir)),_IterateTimes);
                
                return color;
            }
            ENDCG
        }
    }
}