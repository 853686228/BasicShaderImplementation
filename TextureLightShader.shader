Shader "Unlit/TextureLightShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("MainColor", Color) = (1,1,1,1) //漫反射光颜色
        _SpecularColor("Specular Color" , Color) = (1,1,1,1) //高光颜色
        _SpecularNum("SpecularNum" , Range(0,50)) = 30 //高光幂次


    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "LightMode" = "ForwardBase"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float3 normal: NORMAL;
                float4 vertex : SV_POSITION;
            };

            //texture
            sampler2D _MainTex;
            float4 _MainTex_ST;

            //colors
            fixed4 _MainColor;
            fixed4 _SpecularColor;
            int _SpecularNum;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //1.漫反射颜色与材质颜色 乘法叠加，并参与到环境光、漫反射计算中
                //2.兰伯特光照模型计算时，漫反射材质颜色使用1中叠加的颜色计算
                //3.环境光变量UNITY_LIGHTMODEL_AMBIENT需要和1中叠加颜色进行乘法叠加
                fixed4 albedo = _MainColor * tex2D(_MainTex, i.uv);

                float3 lightDir = normalize(_WorldSpaceLightPos0 - i.worldPos);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 halfDir = normalize(viewDir + lightDir);
                fixed4 col = UNITY_LIGHTMODEL_AMBIENT * albedo //环境光 乘法叠加albedo
                    + _LightColor0 * albedo * (.5f * dot(i.normal, lightDir) + .5f) //漫反射 直接使用albedo参与运算
                    + _LightColor0 * _SpecularColor * pow(max(0, dot(i.normal, halfDir)), _SpecularNum); //高光

                return col;
            }
            ENDCG
        }
    }
}