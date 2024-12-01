Shader "Unlit/PhongVertShader"
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
                float4 color : COLOR;
            };

            float4 _MainColor;
            int _IterateTimes;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 worldPos = mul(UNITY_MATRIX_M, v.vertex);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                float3 reflectDir = reflect(-lightDir, normal);

                o.color = UNITY_LIGHTMODEL_AMBIENT + _MainColor * _LightColor0 * (.5 * dot(lightDir, normal) + .5)
                    + _MainColor * _LightColor0 * pow(max(0, dot(viewDir, reflectDir)), _IterateTimes);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}