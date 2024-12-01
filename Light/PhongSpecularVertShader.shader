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
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //这里是因为当作方向光处理了，不然要减去自己的坐标
                float3 normal = UnityObjectToWorldNormal(v.normal);

                //需要注意的是，反射必须是由一个入射光线得到一个反射方向，这里的lightDir是从物体指向光源，需要反向
                float3 reflectDir = reflect(-lightDir, normal); //反射方向


                float3 viewDir = normalize(WorldSpaceViewDir(v.vertex)); //视角方向

                // float3 worldPos = mul(UNITY_MATRIX_M,v.vertex);
                // float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                o.color = _MainColor * _LightColor0 * pow(max(0, dot(reflectDir, viewDir)), _IterateTimes);
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