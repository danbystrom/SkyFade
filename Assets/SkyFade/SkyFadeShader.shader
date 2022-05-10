Shader "Hidden/SkyFadeShader" {
    Properties{
        _Screen("Screen", 2D) = "white" {}
        _Skybox("Skybox", 2D) = "white" {}
    }

    SubShader{
        Pass {
        CGPROGRAM
        #pragma vertex vert_img
        #pragma fragment frag
        #include "UnityCG.cginc"

        uniform sampler2D _Screen;
        sampler2D _Skybox;

        uniform float _DistanceThreshold;

        uniform sampler2D _CameraDepthTexture;

        float4 frag(v2f_img i) : COLOR
        {
            float4 objColor = tex2D(_Screen, i.uv);
            float depth = tex2D(_CameraDepthTexture, i.uv).r;
            if (depth > _DistanceThreshold)
                return objColor;

            float4 skyColor = tex2D(_Skybox, i.uv);
            float blend = depth / _DistanceThreshold;
            return lerp(skyColor, objColor, blend);
        }

        ENDCG
        }
    }

}