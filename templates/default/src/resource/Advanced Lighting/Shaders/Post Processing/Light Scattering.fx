//====================================================
// Light Scattering
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix ViewProjection:ViewProjection;

//--------------
// tweaks
//--------------
   float4 ViewSize;
   float2 ViewVec;
   float3 LightDirection;
   //float Density=0.55f;
   //float Decay=0.99f;
   float Density=0.85f;
   float Decay=0.975f;
   
//--------------
// Textures
//--------------
   texture RenderTexture <string Name = " ";>;
   sampler RenderSampler=sampler_state 
      {
	Texture=<RenderTexture>;
	AddressU=Border;
	AddressV=Border;
	AddressW=Border;
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
	OUT.Tex.zw=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5));
	OUT.Tex1.xy=OUT.Tex.xy+float2(-ViewVec.x,0)*4.5f;//*2.5;
	OUT.Tex1.zw=OUT.Tex.xy+float2(ViewVec.x,0)*4.5f;//*2.5;
	OUT.Tex2.xy=OUT.Tex.xy+float2(0,-ViewVec.y)*4.5f;//*2.5;
	OUT.Tex2.zw=OUT.Tex.xy+float2(0,ViewVec.y)*4.5f;//*2.5;
	OUT.Tex3.xy=OUT.Tex.xy+float2(-ViewVec.x,-ViewVec.y)*4.5f;//*2.5;
	OUT.Tex3.zw=OUT.Tex.xy+float2(ViewVec.x,ViewVec.y)*4.5f;//*2.5;
	OUT.Tex4.xy=OUT.Tex.xy+float2(ViewVec.x,-ViewVec.y)*4.5f;//*2.5;
	OUT.Tex4.zw=OUT.Tex.xy+float2(-ViewVec.x,ViewVec.y)*4.5f;//*2.5;
	return OUT;
    }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
	return tex2D(RenderSampler,IN.Tex);
     }
   float4 PS_SSAO(OutPut IN) : COLOR
     {
 	float SSAO=tex2D(RenderSampler,IN.Tex).w
 	          +tex2D(RenderSampler,IN.Tex1.xy).w
 	          +tex2D(RenderSampler,IN.Tex1.zw).w
 	          +tex2D(RenderSampler,IN.Tex2.xy).w
 	          +tex2D(RenderSampler,IN.Tex2.zw).w
 	          +tex2D(RenderSampler,IN.Tex3.xy).w
 	          +tex2D(RenderSampler,IN.Tex3.zw).w
 	          +tex2D(RenderSampler,IN.Tex4.xy).w
 	          +tex2D(RenderSampler,IN.Tex4.zw).w;
	SSAO /=9;
	return float4(tex2D(RenderSampler,IN.Tex).xy,0,1-SSAO);
     }
   float4 PS_LightScattering(OutPut IN) : COLOR
     {
	float4 ScreenToLight=mul(-LightDirection,ViewProjection);
	float2 DeltaTex=((((ScreenToLight.xy/ScreenToLight.z)*float2(0.5f,-0.5f))+float2(0.5f,0.5f))-IN.Tex.zw);
	DeltaTex *=Density;
	float2 NewUv=IN.Tex.zw;
	float Scatter=0;
	float FallOff=1.0;
	DeltaTex /=40;
	for (int i=0; i < 40; i++)
	 {		
	  NewUv +=DeltaTex;
	  Scatter +=tex2D(RenderSampler,(NewUv*ViewSize.zw)+ViewSize.xy).z*FallOff;
	  FallOff *=Decay;
	 }
	Scatter /=40;
	return float4(tex2D(RenderSampler,IN.Tex).xy,Scatter,0);
     }
   float4 PS_SSAOLightScattering(OutPut IN) : COLOR
     {
 	float SSAO=tex2D(RenderSampler,IN.Tex).w
 	          +tex2D(RenderSampler,IN.Tex1.xy).w
 	          +tex2D(RenderSampler,IN.Tex1.zw).w
 	          +tex2D(RenderSampler,IN.Tex2.xy).w
 	          +tex2D(RenderSampler,IN.Tex2.zw).w
 	          +tex2D(RenderSampler,IN.Tex3.xy).w
 	          +tex2D(RenderSampler,IN.Tex3.zw).w
 	          +tex2D(RenderSampler,IN.Tex4.xy).w
 	          +tex2D(RenderSampler,IN.Tex4.zw).w;
	SSAO /=9;
	float4 ScreenToLight=mul(-LightDirection,ViewProjection);
	float2 DeltaTex=((((ScreenToLight.xy/ScreenToLight.z)*float2(0.5f,-0.5f))+float2(0.5f,0.5f))-IN.Tex.zw);
	DeltaTex *=Density;
	float2 NewUv=IN.Tex.zw;
	float Scatter=0;
	float FallOff=1.0;
	DeltaTex /=40;
	for (int i=0; i < 40; i++)
	 {		
	  NewUv +=DeltaTex;
	  Scatter +=tex2D(RenderSampler,(NewUv*ViewSize.zw)+ViewSize.xy).z*FallOff;
	  FallOff *=Decay;
	 }
	Scatter /=40;
	return float4(tex2D(RenderSampler,IN.Tex).xy,Scatter,1-SSAO);
     }

//--------------
// techniques   
//--------------
    technique Distortion
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS();
	zwriteenable=false;
	zenable=false;
      }
      }
    technique SSAO
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS_SSAO();
	zwriteenable=false;
	zenable=false;
      }
      }
    technique LightScattering
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS_LightScattering();
	zwriteenable=false;
	zenable=false;
      }
      }
    technique SSAOLightScattering
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS_SSAOLightScattering();
	zwriteenable=false;
	zenable=false;
      }
      }