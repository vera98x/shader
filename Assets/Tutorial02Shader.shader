Shader "Unlit/Tutorial02Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            uniform float4 _LightColor0;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 col : COLOR;
            };

            sampler2D _MainTex;
            fixed4 _Color;

            v2f vert (appdata IN)
            {
                v2f OUT;
                OUT.position = UnityObjectToClipPos(IN.vertex);

                float deltax = abs(OUT.position.x - 35)/30 + 2;
                float deltay = abs(OUT.position.y - 35)/30 + 2;


                float4x4 modelMatrixInverse = unity_WorldToObject;

                float3 normalDirection = normalize(
                    mul(float4(IN.normal, 0,0), unity_WorldToObject).xyz);
                
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

                float3 diffuseReflection = _LightColor0.rgb
                * max(0.0, dot(normalDirection, lightDirection));

                OUT.col  = float4(diffuseReflection, 1.0);

                OUT.position = UnityObjectToClipPos(IN.vertex* float4(deltax, deltay, 2, 1.0));
                OUT.uv = IN.uv;
                return OUT;
            }

            fixed4 frag (v2f input) : COLOR
            {
                fixed4 col = float4(0,0,0,0);
                col.rgb.x = 1-(input.position.y-200)/(310-200);
                col.rgb.y = (input.position.x-228)/(652-228);
                col.rgb.z = (input.position.y-200)/(310-200);

                col = col * input.col;
                return col;
            }
            ENDCG
        }
    }
}
