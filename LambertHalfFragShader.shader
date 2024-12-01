Shader "Unlit/LamberHalfFragShader"
{
    Properties
    {
        _MainColor ("Main Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "LightMode"="ForwardBase"
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
                //世界空间下的法线
                float3 normal : NORMAL;
                //裁剪空间下的坐标
                float4 vertex : SV_POSITION;
            };

            float4 _MainColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                fixed4 color = _MainColor * _LightColor0 * (dot(lightDir, i.normal) * .5 + .5) +
                    UNITY_LIGHTMODEL_AMBIENT;
                return color;
            }
            ENDCG
        }
    }
}