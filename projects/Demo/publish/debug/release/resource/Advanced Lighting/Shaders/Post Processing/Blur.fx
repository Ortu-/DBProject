//====================================================
// Blur DOF / PixelBlur
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

#define EnableDOF 1
#define EnableMotionBlur 0

//--------------
// tweaks
//--------------
   float4 ViewSize;
   float2 ViewVec;
   float DOFNearFocus=10.0f;
   float DOFFarFocus=20000.0f;
   float2 Aperture={1,5};
   float BlurOffset=3.0f;
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
      };
   texture BrightPassTexture <string Name=" ";>;
   sampler BrightPassSampler=sampler_state 
      {
	Texture=<BrightPassTexture>;
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
 	float4 Tex:TEXCOORD0;
	float4 Tex1:TEXCOORD1;
 	float4 Tex2:TEXCOORD2;
 	float4 Tex3:TEXCOORD3;
 	float4 Tex4:TEXCOORD4;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=IN.Pos; 
 	OUT.Tex.xy=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)*ViewSize.zw)+ViewSize.xy;
 	OUT.Tex.zw=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)*ViewSize.zw)+(ViewSize.xy*2);
	OUT.Tex1.xy=OUT.Tex.xy+float2(-ViewVec.x,0)*BlurOffset;
	OUT.Tex1.zw=OUT.Tex.xy+float2(ViewVec.x,0)*BlurOffset;
	OUT.Tex2.xy=OUT.Tex.xy+float2(0,-ViewVec.y)*BlurOffset;
	OUT.Tex2.zw=OUT.Tex.xy+float2(0,ViewVec.y)*BlurOffset;
	OUT.Tex3.xy=OUT.Tex.xy+float2(-ViewVec.x,-ViewVec.y)*BlurOffset;
	OUT.Tex3.zw=OUT.Tex.xy+float2(ViewVec.x,ViewVec.y)*BlurOffset;
	OUT.Tex4.xy=OUT.Tex.xy+float2(ViewVec.x,-ViewVec.y)*BlurOffset;
	OUT.Tex4.zw=OUT.Tex.xy+float2(-ViewVec.x,ViewVec.y)*BlurOffset;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {
	float3 FrameRender=tex2D(RenderSampler,IN.Tex);
	float Focus=0;
	float MotionBlurAbs=0;
	float3 Blur=0;
	float3 DepthMotionVec=tex2D(DepthSampler,IN.Tex).yzw;
	#if EnableDOF == 1
    	 Focus=1-pow(saturate(DepthMotionVec.x/DOFNearFocus),Aperture.x)+pow(DepthMotionVec.x/DOFFarFocus,Aperture.y);
	 if(tex2D(BrightPassSampler,IN.Tex).w>0.1f)
	  {
	   Blur=FrameRender;
	   float4 Depthf;
	   Depthf.x=tex2Dlod(DepthSampler,float4(IN.Tex1.xy,0,0)).y;
	   Depthf.y=tex2Dlod(DepthSampler,float4(IN.Tex1.zw,0,0)).y;
	   Depthf.z=tex2Dlod(DepthSampler,float4(IN.Tex2.xy,0,0)).y;
	   Depthf.w=tex2Dlod(DepthSampler,float4(IN.Tex2.zw,0,0)).y;
           Depthf=saturate((1-pow(saturate(Depthf/DOFNearFocus),Aperture.x))+pow(Depthf/DOFFarFocus,Aperture.y));
	   Blur +=lerp(FrameRender,tex2Dlod(RenderSampler,float4(IN.Tex1.xy,0,0)),Depthf.x)
	        +lerp(FrameRender,tex2Dlod(RenderSampler,float4(IN.Tex1.zw,0,0)),Depthf.y)
	        +lerp(FrameRender,tex2Dlod(RenderSampler,float4(IN.Tex2.xy,0,0)),Depthf.z)
	        +lerp(FrameRender,tex2Dlod(RenderSampler,float4(IN.Tex2.zw,0,0)),Depthf.w);
	   Depthf.x=tex2Dlod(DepthSampler,float4(IN.Tex3.xy,0,0)).y;
	   Depthf.y=tex2Dlod(DepthSampler,float4(IN.Tex3.zw,0,0)).y;
	   Depthf.z=tex2Dlod(DepthSampler,float4(IN.Tex4.xy,0,0)).y;
	   Depthf.w=tex2Dlod(DepthSampler,float4(IN.Tex4.zw,0,0)).y;
           Depthf=saturate((1-pow(saturate(Depthf/DOFNearFocus),Aperture.x))+pow(Depthf/DOFFarFocus,Aperture.y));
	   Blur +=lerp(FrameRender,tex2Dlod(RenderSampler,float4(IN.Tex3.xy,0,0)),Depthf.x)
	        +lerp(FrameRender,tex2Dlod(RenderSampler,float4(IN.Tex3.zw,0,0)),Depthf.y)
	        +lerp(FrameRender,tex2Dlod(RenderSampler,float4(IN.Tex4.xy,0,0)),Depthf.z)
	        +lerp(FrameRender,tex2Dlod(RenderSampler,float4(IN.Tex4.zw,0,0)),Depthf.w);
	   Blur /=9;
	  }
	 else
	  {
	   Blur=FrameRender
	       +tex2Dlod(RenderSampler,float4(IN.Tex1.xy,0,0))
	       +tex2Dlod(RenderSampler,float4(IN.Tex1.zw,0,0))
	       +tex2Dlod(RenderSampler,float4(IN.Tex2.xy,0,0))
	       +tex2Dlod(RenderSampler,float4(IN.Tex2.zw,0,0))
	       +tex2Dlod(RenderSampler,float4(IN.Tex3.xy,0,0))
	       +tex2Dlod(RenderSampler,float4(IN.Tex3.zw,0,0))
	       +tex2Dlod(RenderSampler,float4(IN.Tex4.xy,0,0))
	       +tex2Dlod(RenderSampler,float4(IN.Tex4.zw,0,0));
	   Blur /=9;
	  };
	#endif 
	#if EnableMotionBlur == 1
	 MotionBlurAbs=abs(dot(DepthMotionVec.yz,MotionBlur*64));
	 DepthMotionVec.yz *=MotionBlur;
	 FrameRender +=tex2D(RenderSampler,IN.Tex.zw+DepthMotionVec.yz)
		      +tex2D(RenderSampler,IN.Tex.zw+DepthMotionVec.yz*2)
		      +tex2D(RenderSampler,IN.Tex.zw+DepthMotionVec.yz*3)
		      +tex2D(RenderSampler,IN.Tex.zw+DepthMotionVec.yz*4)
		      +tex2D(RenderSampler,IN.Tex.zw-DepthMotionVec.yz)
		      +tex2D(RenderSampler,IN.Tex.zw-DepthMotionVec.yz*2)
		      +tex2D(RenderSampler,IN.Tex.zw-DepthMotionVec.yz*3)
		      +tex2D(RenderSampler,IN.Tex.zw-DepthMotionVec.yz*4);
         FrameRender /=9;
	 #if EnableDOF == 1
	  FrameRender=lerp(Blur,FrameRender,saturate(MotionBlurAbs));
	 #endif 
	#else
	  FrameRender=Blur;
	#endif
	return float4(FrameRender,saturate(MotionBlurAbs+Focus));
     }

//--------------
// techniques   
//--------------
    technique Blur
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS();
	zwriteenable=false;
	zenable=false;
      }
      }
