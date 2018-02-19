Shader "Custom/customretroglitch" {
	Properties {
		[Header(General)]
		_Color("Color", Color) = (1,1,1,1)
		
		[Header(Textures)]
		_MainTex ("Color Spritesheet", 2D) = "white" {}
		_NormalTex ("Normals Spritesheet", 2D) = "white" {}

		[Header(Spritesheet)]
		_Columns("Columns (int)", int) = 3
		_Rows("Rows (int)", int) = 3
		_FrameNumber ("Frame Number (int)", int) = 0
		_TotalFrames ("Total Number of Frames (int)", int) = 9
		//_FrameScale ("Frame Scale (for testing)", float) = 1
		_Cutoff ("Alpha Cutoff", Range(0,1)) = 1
		_AnimationSpeed ("Animation Speed", float) = 0

        _MainTex("Base", 2D) = "white" {}
        _Color("Color", Color) = (0.5, 0.5, 0.5, 1)
        _GeoRes("Geometric Resolution", Float) = 40

		// Glitch
		_GlitchSpeed ("Glitch Speed", Range(0, 50)) = 1.0
		_GlitchIntensity ("Glitch Intensity", Float) = 0
	}
	SubShader {

		Pass
        {
            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature _GLITCH_ON

            struct v2f
            {
                float4 position : SV_POSITION;
                float3 texcoord : TEXCOORD;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _GeoRes;


			int _Columns;
			int _Rows;
			int _FrameNumber;
			int _TotalFrames;

			// glitches
			float _GlitchIntensity;
			float _GlitchSpeed;

			
			float _AnimationSpeed;

            v2f vert(appdata_base v)
            {
				// added
				_FrameNumber += frac(_Time[0] * _AnimationSpeed) * _TotalFrames;
				float frame = clamp(_FrameNumber, 0, _TotalFrames);
				float2 offPerFrame = float2((1 / (float)_Columns), (1 / (float)_Rows));
				
                v2f o;

				
				// Glitches
				#if _GLITCH_ON
					v.vertex.x += _GlitchIntensity * (step(0.5, sin(_Time.y * 2.0 + v.vertex.y * 1.0)) * step(0.99, sin(_Time.y*_GlitchSpeed * 0.5)));
				#endif

                float4 wp = mul(UNITY_MATRIX_MV, v.vertex);
                wp.xyz = floor(wp.xyz * _GeoRes) / _GeoRes;

                float4 sp = mul(UNITY_MATRIX_P, wp);
                o.position = sp;

                float2 uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				// added
				uv.x = (uv.x / _Columns);
				uv.y = (uv.y / _Rows);

				// added
				float2 currentSprite = float2(0,  1 - offPerFrame.y);
				currentSprite.x += frame * offPerFrame.x;
				float rowIndex;
				float mod = modf(frame / (float)_Columns, rowIndex);
				currentSprite.y -= rowIndex * offPerFrame.y;
				currentSprite.x -= rowIndex * _Columns * offPerFrame.x;
				// expirement
				float2 spriteUV = (uv + currentSprite);
				fixed4 c = tex2D(_MainTex, spriteUV) * _Color;
				






                o.texcoord = float3(uv * sp.w, sp.w);
				

				


                return o;
            }




            fixed4 frag(v2f i) : SV_Target
            {

				// added
				_FrameNumber += frac(_Time[0] * _AnimationSpeed) * _TotalFrames;
				float frame = clamp(_FrameNumber, 0, _TotalFrames);
				float2 offPerFrame = float2((1 / (float)_Columns), (1 / (float)_Rows));

                float2 uv = i.texcoord.xy / i.texcoord.z;

				// added
				uv.x = (uv.x / _Columns);
				uv.y = (uv.y / _Rows);

				// added
				float2 currentSprite = float2(0,  1 - offPerFrame.y);
				currentSprite.x += frame * offPerFrame.x;
				float rowIndex;
				float mod = modf(frame / (float)_Columns, rowIndex);
				currentSprite.y -= rowIndex * offPerFrame.y;
				currentSprite.x -= rowIndex * _Columns * offPerFrame.x;
				// expirement
				float2 spriteUV = (uv + currentSprite);
				//fixed4 c = tex2D(_MainTex, spriteUV) * _Color;
				
				return tex2D(_MainTex, spriteUV) * _Color;

                //return tex2D(_MainTex, uv) * _Color * 2;
            }

            ENDCG
        }
	}
	FallBack "Transparent/Cutout/Diffuse"
}
