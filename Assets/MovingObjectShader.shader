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
        _ballSize ("Ballsize", Range(0, 3)) = 3
        _minBallSize("Min ballsize", Range(0.5 , 150)) = 60

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
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

                //range -1->1
                float4 pos_clip = UnityObjectToClipPos(IN.vertex);
                // calculate the deviation and the delta
                float deltax = abs(pos_clip.x)*_ballSize + _minBallSize;
                float deltay = abs(pos_clip.y)*_ballSize + _minBallSize;
                // create position
                OUT.position = UnityObjectToClipPos(IN.vertex* float4(deltax, deltay, 2, 1.0)/4);


                // get vertex normal in world space
                half3 worldNormal = normalize(mul(IN.normal, (float3x3)unity_WorldToObject));
                // dot product between normal and light direction for
                // standard diffuse lighting
                half nl = max(0, dot(worldNormal, normalize(_WorldSpaceLightPos0.xyz)));
                // factor in the light color
                OUT.col = nl * _LightColor0;

                return OUT;
            }

            fixed4 frag (v2f input) : COLOR
            {       
                // calculate boundaries of the camera
                int x_min = _PlaneX_min;
                int y_min = _PlaneY_min;
                int x_max = _ScreenParams.x - _PlaneX_max;
                int y_max = _ScreenParams.y - _PlaneY_max;
                // scale the position between 0 and 1
                float pos_x = (input.position.x - x_min)/(x_max - x_min);
                float pos_y = (input.position.y - y_min)/(y_max -y_min);
                // calculate vertex color
                fixed4 col = float4(0,0,0,1);
                col.rgb.x = 1-pos_y + _r;
                col.rgb.y = pos_x + _g;
                col.rgb.z = min(pos_y, (1-pos_x)/1.5) + _b; // change the ratio to x:y = 1:1
                // add color with calcultated defuse lightcolor
                col = col * input.col;
                return col;
            }
            ENDCG
        }
    }
}
