Shader "Skybox/UngolSky" {
    Properties{
       _Texture1("Texture 1", 2D) = "white" {}
       _Texture2("Texture 2", 2D) = "white" {}
       _BlendZone("Blend Zone", Vector) = (0,0,0,0)
    }

        SubShader{
           Tags { "Queue" = "Background"  }

           Pass {
              ZWrite Off
              Cull Off

              CGPROGRAM
              #pragma vertex vert
              #pragma fragment frag

        // User-specified uniforms
        uniform sampler2D _Texture1;
        uniform sampler2D _Texture2;
        float4 _Texture1_ST;
        float4 _Texture2_ST;

        uniform float2 _BlendZone;

        struct vertexInput {
           float4 vertex : POSITION;
           float3 texcoord : TEXCOORD0;
        };

        struct vertexOutput {
           float4 vertex : SV_POSITION;
           float3 texcoord : TEXCOORD0;
           float2 gurka : TEXCOORD1;
        };

        inline float2 ToRadialCoords(float3 coords, float angleX, float angleY)
        {
            float3 normalizedCoords = normalize(coords);
            float latitude = acos(normalizedCoords.y) + angleX;
            float longitude = atan2(normalizedCoords.z, normalizedCoords.x) + angleY;
            float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / 3.14159265, 1.0 / 3.14159265);
            return float2(0.5, 1.0) - sphereCoords;
        }

        vertexOutput vert(vertexInput input)
        {
           vertexOutput output;
           output.vertex = UnityObjectToClipPos(input.vertex);
           output.texcoord = input.texcoord;
           output.gurka.xy = input.vertex.xy;
           return output;
        }

        fixed4 frag(vertexOutput input) : COLOR
        {
            float2 tc1 = ToRadialCoords(input.texcoord, _Texture1_ST.w, _Texture1_ST.z);
            tc1 = float2(
                _Texture1_ST.x * tc1.x,
                _Texture1_ST.y * tc1.y);
            float2 tc2 = ToRadialCoords(input.texcoord, _Texture2_ST.w, _Texture2_ST.z);
            tc2 = float2(
                _Texture2_ST.x * tc2.x,
                _Texture2_ST.y * tc2.y);

            if (input.gurka.x <= _BlendZone.x)
            {
                return tex2D(_Texture1, tc1);
            }

            if (input.gurka.x >= _BlendZone.y)
                return tex2D(_Texture2, tc2);

            return lerp(
                tex2D(_Texture1, tc1),
                tex2D(_Texture2, tc2),
                (input.gurka.x-_BlendZone.x) / (_BlendZone.y - _BlendZone.x));
        }
        ENDCG
     }
    }
}