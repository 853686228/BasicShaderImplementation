Shader "Unlit/LambertVertShader"
{
    Properties
    {
        //材质颜色
        _MainMaterialColor ("Main Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags
        {
            //前向渲染，主要处理不透明物体的光照渲染
            "LightMode" = "ForwardBase"
        }


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work


            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                fixed3 color : SV_Target0;
                float4 vertex : SV_POSITION;
            };

            float4 _MainMaterialColor;

            v2f vert(appdata v)
            {
                v2f o;
                //已经定义好的变量
                //_LightColor0 光照颜色
                //_WorldSpaceLightPos0 光源方向
                //UNITY_LIGHTMODEL_AMBIENT 环境光颜色常量
                float3 normalInWorld = UnityObjectToWorldNormal(v.normal);
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                half4 color = _LightColor0 * _MainMaterialColor * max(0, dot(normalInWorld, lightDir));//这里可以自己处理下alpha通道
                //half3 color = _LightColor0.rbg * _MainMaterialColor.rbg * max(0,dot(normalInWorld,lightDir)) ;

                //vert的转换必须进行！
                float4 pos = UnityObjectToClipPos(v.vertex);

                o.color = color + UNITY_LIGHTMODEL_AMBIENT; //加上兰伯特环境光颜色，让阴影处不全黑，更接近真实效果
                o.vertex = pos;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //把计算好的颜色传递出去，return即可
                return fixed4(i.color.rgb, 1);
            }
            ENDCG
        }
    }
}