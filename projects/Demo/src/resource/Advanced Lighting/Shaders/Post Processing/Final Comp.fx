//====================================================
// Final Comp
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

#define EnableAA 1
#define EnableBloom 1
#define EnableScatter 1
#define EnableDOF 0
#define EnableMotionBlur 0
#define EnableDistortion 1
#define EnableChromaticAberration 1

//--------------
// tweaks
//--------------
   float4 ViewSize1;
   float4 ViewSize2;
   float4 ViewSize3;
   float2 ViewVec;
   float3 Brightness={1.0f,1.0f,1.0f};
   float3 Sharpen={1.0f,1.0f,1.0f};
   float3 ScatteringColor;
   float Distortion=0.025f;
   float MotionTrails=1.0f;
   float MotionBlur=0.001f;

//--------------
// Textures
//--------------
   texture RenderTexture <string Name = " ";>;
   sampler RenderSampler=sampler_state 
      {
	Texture=<RenderTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
      };
   texture DepthTexture <string Name = "";>;
   sampler DepthSampler=sampler_state 
      {
	Texture=<DepthTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture DistortionTexture <string Name = "";>;
   sampler DistortionSampler=sampler_state 
      {
	Texture=<DistortionTexture>;
     	ADDRESSU=CLAMP;
        ADDRESSV=CLAMP;
        ADDRESSW=CLAMP;
      };
   texture BrightPassTexture <string Name=" ";>;
   sampler BrightPassSampler=sampler_state 
      {
	Texture=<BrightPassTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
      };
   texture BloomTexture <string Name=" ";>;
   sampler BloomSampler=sampler_state 
      {
	Texture=<BloomTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
      };
   texture AdaptedLumTexture <string Name = " ";>;
   sampler AdaptedLumSampler=sampler_state 
      {
	Texture=<AdaptedLumTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
      };
   texture BlurTexture <string Name=" ";>;
   sampler BlurSampler=sampler_state 
      {
	Texture=<BlurTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
      };

//--------------
// structs 
//--------------
   struct InPut
     {
 	float4 Pos:POSITION;
     };
   struct OutPut
     {
	float4 Pos:POSITION; 
 	float2 Tex1:TEXCOORD0;
 	float2 Tex2:TEXCOORD1;
	float2 Tex3:TEXCOORD2;
	float4 Tex4:TEXCOORD3;
	float4 Tex5:TEXCOORD4;
	float4 Tex6:TEXCOORD5;
	float4 Tex7:TEXCOORD6;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=IN.Pos; 
 	OUT.Tex1=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)*ViewSize1.zw)+ViewSize1.xy;
 	OUT.Tex2=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)*ViewSize2.zw)+ViewSize2.xy;
 	OUT.Tex3=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)*ViewSize3.zw)+ViewSize3.xy;
	OUT.Tex4.xy=OUT.Tex1+float2(-ViewVec.x,0)*4;
	OUT.Tex4.zw=OUT.Tex1+float2(ViewVec.x,0)*4;
	OUT.Tex5.xy=OUT.Tex1+float2(0,-ViewVec.y)*4;
	OUT.Tex5.zw=OUT.Tex1+float2(0,ViewVec.y)*4;
	OUT.Tex6.xy=OUT.Tex1+float2(-ViewVec.x,-ViewVec.y)*4;
	OUT.Tex6.zw=OUT.Tex1+float2(ViewVec.x,ViewVec.y)*4;
	OUT.Tex7.xy=OUT.Tex1+float2(ViewVec.x,-ViewVec.y)*4;
	OUT.Tex7.zw=OUT.Tex1+float2(-ViewVec.x,ViewVec.y)*4;
	return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
	float2 Distort=0;
	#if EnableDistortion == 1
	 Distort=((tex2D(DistortionSampler,IN.Tex1)*2-1)+0.00392156862f)*Distortion;
	 Distort *=ceil(abs((tex2D(DistortionSampler,IN.Tex1+(Distort*2))*2-1)+0.00392156862f));
	 #if EnableChromaticAberration == 1
	  float3 FrameRender;
	  FrameRender.x=tex2D(RenderSampler,IN.Tex1+(Distort*1.1f)).x;
	  FrameRender.z=tex2D(RenderSampler,IN.Tex1+(Distort*0.9f)).z;
 	  IN.Tex1 +=Distort;
	  FrameRender.y=tex2D(RenderSampler,IN.Tex1).y;
	 #else
 	  IN.Tex1 +=Distort;
	  float3 FrameRender=tex2D(RenderSampler,IN.Tex1);
	 #endif
	#else
	 float3 FrameRender=tex2D(RenderSampler,IN.Tex1);
	#endif
	float3 Average=tex2D(RenderSampler,IN.Tex1+ViewVec*1.5f)
	            +tex2D(RenderSampler,IN.Tex1-ViewVec*1.5f)
	            +tex2D(RenderSampler,IN.Tex1+float2(-ViewVec.x,ViewVec.y)*1.5f)
	            +tex2D(RenderSampler,IN.Tex1+float2(ViewVec.x,-ViewVec.y)*1.5f);
	FrameRender +=(FrameRender-(Average*0.25f))*Sharpen;
	#if EnableAA == 1
         if(tex2D(BrightPassSampler,IN.Tex2).w>(0.5f+dot(abs(Distort.xy),255).x))
	  {
	   float4 AAp,AAn;
	   AAn.x=tex2Dlod(DepthSampler,float4(IN.Tex6.xy,0,0)).y;
	   AAn.y=tex2Dlod(DepthSampler,float4(IN.Tex6.zw,0,0)).y;
	   AAn.z=tex2Dlod(DepthSampler,float4(IN.Tex7.zw,0,0)).y;
	   AAn.w=tex2Dlod(DepthSampler,float4(IN.Tex7.xy,0,0)).y;
	   AAp.x=tex2Dlod(DepthSampler,float4(IN.Tex5.xy,0,0)).y+AAn.z+AAn.y;
	   AAp.y=tex2Dlod(DepthSampler,float4(IN.Tex5.zw,0,0)).y+AAn.x+AAn.w;
	   AAp.z=tex2Dlod(DepthSampler,float4(IN.Tex4.xy,0,0)).y+AAn.y+AAn.w;
	   AAp.w=tex2Dlod(DepthSampler,float4(IN.Tex4.zw,0,0)).y+AAn.z+AAn.x;
   	   float2 AAVec=normalize(float2(AAp.x-AAp.y,AAp.z-AAp.w))*ViewVec*1.5f;
	   FrameRender +=tex2Dlod(RenderSampler,float4(IN.Tex1+AAVec,0,0))
	               +tex2Dlod(RenderSampler,float4(IN.Tex1-AAVec,0,0))
	               +tex2Dlod(RenderSampler,float4(IN.Tex1+float2(AAVec.x,-AAVec.y),0,0))
	               +tex2Dlod(RenderSampler,float4(IN.Tex1+float2(-AAVec.x,AAVec.y),0,0));
	   FrameRender /=5;
	 };
	#endif
	#if EnableDOF == 1
	  float4 Blur=tex2D(BlurSampler,IN.Tex2+Distort)
	             +tex2D(BlurSampler,IN.Tex6.xy+Distort.xy)
	             +tex2D(BlurSampler,IN.Tex6.zw+Distort.xy)
	             +tex2D(BlurSampler,IN.Tex7.xy+Distort.xy)
	             +tex2D(BlurSampler,IN.Tex7.zw+Distort.xy);
	 Blur /=4.8f;
         FrameRender=lerp(FrameRender,Blur.xyz,Blur.w);
	#else
	 #if EnableMotionBlur == 1
	  float4 Blur=tex2D(BlurSampler,IN.Tex2+Distort)
	             +tex2D(BlurSampler,IN.Tex6.xy+Distort.xy)
	             +tex2D(BlurSampler,IN.Tex6.zw+Distort.xy)
	             +tex2D(BlurSampler,IN.Tex7.xy+Distort.xy)
	             +tex2D(BlurSampler,IN.Tex7.zw+Distort.xy);
	  Blur /=4.8f;
          FrameRender=lerp(FrameRender,Blur.xyz,Blur.w);
	 #endif
	#endif
	#if EnableBloom == 1
	 float3 Bloom=tex2D(BloomSampler,IN.Tex3);
	 Bloom=lerp(Bloom.xyz,FrameRender,0.333f+dot(FrameRender,0.333f)*0.333f)*3;
         FrameRender=lerp(Bloom.xyz,FrameRender*0.3f,0.1f+tex1D(AdaptedLumSampler,0).x*0.8f);
	#endif
	#if EnableScatter == 1
	 FrameRender +=tex2D(DistortionSampler,IN.Tex3).zzz*ScatteringColor;
	#endif
	FrameRender -=saturate(pow(dot(IN.Tex1-0.5f,IN.Tex1-0.5f),3)*0.3f);
	return float4(FrameRender*Brightness,MotionTrails);
     }
   float4 PS_Disable(OutPut IN) : COLOR
     {
	return float4(tex2D(RenderSampler,IN.Tex1).xyz,1);
     }

//--------------
// techniques   
//--------------
    technique FinalComp
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS(); 
 	PixelShader  = compile ps_3_0 PS();
	AlphaBlendEnable=true;
	SrcBlend=SRCALPHA;
	DestBlend=INVSRCALPHA;
	zwriteenable=false;
	zenable=false;
        ColorWriteEnable=7;
      }
      }
    technique Disable
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS(); 
 	PixelShader  = compile ps_3_0 PS_Disable();
	AlphaBlendEnable=true;
	SrcBlend=SRCALPHA;
	DestBlend=INVSRCALPHA;
	zwriteenable=false;
	zenable=false;
        ColorWriteEnable=7;
      }
      }
