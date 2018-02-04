//====================================================
// Bright Pass
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

#define EnableBloom 0
#define EnableEdge 1

//--------------
// tweaks
//--------------
   float4 ViewSize;
   float2 ViewVec;
   //float BrightNess=1.1f;
   float BrightNess=1.6f;

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
   texture AdaptedLumTexture <string Name = " ";>;
   sampler AdaptedLumSampler=sampler_state
      {
	Texture=<AdaptedLumTexture>;
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
 	float2 Tex:TEXCOORD0;
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
 	OUT.Tex=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)*ViewSize.zw)+ViewSize.xy;
	OUT.Tex1.xy=OUT.Tex+float2(-ViewVec.x,0)*2.5;
	OUT.Tex1.zw=OUT.Tex+float2(ViewVec.x,0)*2.5;
	OUT.Tex2.xy=OUT.Tex+float2(0,-ViewVec.y)*2.5;
	OUT.Tex2.zw=OUT.Tex+float2(0,ViewVec.y)*2.5;
	OUT.Tex3.xy=OUT.Tex+float2(-ViewVec.x,-ViewVec.y)*2.5;
	OUT.Tex3.zw=OUT.Tex+float2(ViewVec.x,ViewVec.y)*2.5;
	OUT.Tex4.xy=OUT.Tex+float2(ViewVec.x,-ViewVec.y)*2.5;
	OUT.Tex4.zw=OUT.Tex+float2(-ViewVec.x,ViewVec.y)*2.5;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
    {
	float3 BrightPass=0;
	float Edge=0;
	#if EnableBloom == 1
	 BrightPass=tex2D(RenderSampler,IN.Tex)
	           +tex2D(RenderSampler,IN.Tex1.xy)
	           +tex2D(RenderSampler,IN.Tex1.zw)
	           +tex2D(RenderSampler,IN.Tex2.xy)
	           +tex2D(RenderSampler,IN.Tex2.zw)
	           +tex2D(RenderSampler,IN.Tex3.xy)
	           +tex2D(RenderSampler,IN.Tex3.zw)
	           +tex2D(RenderSampler,IN.Tex4.xy)
	           +tex2D(RenderSampler,IN.Tex4.zw);
	 BrightPass /=9;
	 float AdaptedLum=tex2D(AdaptedLumSampler,IN.Tex);
	 BrightPass=clamp((BrightPass-(AdaptedLum*BrightNess)),0,2);
	 BrightPass=BrightPass+(BrightPass*(1-AdaptedLum));
	#endif
	#if EnableEdge ==  1
	 float4 AAp;
	 AAp.x=tex2D(DepthSampler,IN.Tex1.xy).y;
	 AAp.y=tex2D(DepthSampler,IN.Tex1.zw).y;
	 AAp.z=tex2D(DepthSampler,IN.Tex2.xy).y;
	 AAp.w=tex2D(DepthSampler,IN.Tex2.zw).y;
	 Edge=saturate(4.2f-dot(AAp/tex2D(DepthSampler,IN.Tex).y,1));
	 Edge=saturate(((saturate(0.2f-Edge)+saturate(Edge-0.2f))-0.0025f)/0.001f);
	#endif
   	return float4(BrightPass,Edge);
    }

//--------------
// techniques
//--------------
    technique BrightPass
      {
 	pass p1
      {
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS();
	zwriteenable=false;
	zenable=false;
      }
      }
