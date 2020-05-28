Shader "MovingObjectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _PlaneX_min ("Plane bound width min", Range(0, 400)) = 20
        _PlaneX_max ("Plane bound width max", Range(0, 400)) = 20
        _PlaneY_min ("Plane bound height min", Range(0, 200)) = 20
        _PlaneY_max ("Plane bound height max", Range(0, 200)) = 20
        _r ("red", Range(-1, 1)) = 0
        _g ("green", Range(-1, 1)) = 0
        _b ("blue", Range(-1, 1)) = 0
        _ballSize ("Ballsize", Range(0, 50)) = 30
        _minBallSize("Min ballsize", Range(0.5 , 3)) = 2

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 col : COLOR;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            int _PlaneX_min;
            int _PlaneX_max;
            int _PlaneY_min;
            int _PlaneY_max;
            int _ballSize;
            float _minBallSize;
            float _r;
            float _g;
            float _b;


            v2f vert (appdata IN)
            {
                v2f OUT;
                float4 position_in_world_space = mul(unity_ObjectToWorld, IN.vertex);
                float deltax = abs(position_in_world_space.x + _ScreenParams.x/10)/_ballSize + _minBallSize;
                float deltay = abs(position_in_world_space.y + _ScreenParams.y/10)/_ballSize + _minBallSize;
                OUT.position = UnityObjectToClipPos(IN.vertex* float4(deltax, deltay, 1, 1.0));

                // get vertex normal in world space
                half3 worldNormal = UnityObjectToWorldNormal(IN.normal);
                // dot product between normal and light direction for
                // standard diffuse (Lambert) lighting
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                // factor in the light color
                OUT.col = nl * _LightColor0;

                OUT.uv = IN.uv;
                return OUT;
            }

            fixed4 frag (v2f input) : COLOR
            {       
                // calculate boundaries of the camera
                int x_min = _PlaneX_min;
                int y_min = _PlaneY_min;
                int x_max = _ScreenParams.x - _PlaneX_max;
                int y_max = _ScreenParams.y - _PlaneY_max;

                fixed4 col = float4(0,0,0,1);
                col.rgb.x = 1-(input.position.y - y_min)/(y_max -y_min) + _r;
                col.rgb.y = (input.position.x - x_min)/(x_max - x_min) + _g;
                col.rgb.z = min((input.position.y - y_min)/(y_max - y_min), (1-(input.position.x*2 - x_min)/(x_max - x_min))) + _b;

                col = col * input.col;
                return col;
            }
            ENDCG
        }
    }
}
