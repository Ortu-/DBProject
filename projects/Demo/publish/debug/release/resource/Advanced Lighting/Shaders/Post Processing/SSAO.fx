//====================================================
// Screen Space Ambient Occlusion
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix ViewProj:ViewProjection; 
   matrix ViewInv:ViewInverse;
   matrix ProjInv;

//--------------
// tweaks
//--------------
   float4 ViewSize;
   float Radius=0.015f;
   float Intencity=2.5f;
   float Scale=0.075f;
   float Bias=0.025f;

//--------------
// Textures
//--------------
   texture GeometryTexture <string Name = "";>;
   sampler GeometrySampler=sampler_state 
      {
	Texture=<GeometryTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture PositionTexture <string Name = "";>;
   sampler PositionSampler=sampler_state 
      {
	Texture=<PositionTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture NoiseTexture <string Name = "";>;
   sampler NoiseSampler=sampler_state 
      {
	Texture=<NoiseTexture>;
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
	float3 VPos:TEXCOORD1;
	float4 VPos1:TEXCOORD2;
	float4 VPos2:TEXCOORD3;
	float4 VPos3:TEXCOORD4;
	float4 VPos4:TEXCOORD5;
	float4 VPos5:TEXCOORD6;
	float4 VPos6:TEXCOORD7;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=IN.Pos;
 	OUT.Tex=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)*ViewSize.zw)+ViewSize.xy;
	OUT.VPos=mul(mul(IN.Pos,ProjInv),ViewInv)-ViewInv[3].xyz;
	OUT.VPos1.xyz=mul(mul(IN.Pos+float4(Radius,-Radius,0,0)*2,ProjInv),ViewInv)-ViewInv[3].xyz;
	OUT.VPos2.xyz=mul(mul(IN.Pos+float4(0,-Radius*1.5f,0,0)*2,ProjInv),ViewInv)-ViewInv[3].xyz;
	OUT.VPos3.xyz=mul(mul(IN.Pos+float4(-Radius,-Radius,0,0)*2,ProjInv),ViewInv)-ViewInv[3].xyz;
	OUT.VPos4.xyz=mul(mul(IN.Pos+float4(Radius,Radius,0,0)*2,ProjInv),ViewInv)-ViewInv[3].xyz;
	OUT.VPos5.xyz=mul(mul(IN.Pos+float4(0,Radius*1.5f,0,0)*2,ProjInv),ViewInv)-ViewInv[3].xyz;
	OUT.VPos6.xyz=mul(mul(IN.Pos+float4(-Radius,Radius,0,0)*2,ProjInv),ViewInv)-ViewInv[3].xyz;
	float3 VPos7=mul(mul(IN.Pos+float4(Radius*1.5f,0,0,0)*2,ProjInv),ViewInv)-ViewInv[3].xyz;
	float3 VPos8=mul(mul(IN.Pos+float4(-Radius*1.5f,0,0,0)*2,ProjInv),ViewInv)-ViewInv[3].xyz;
	OUT.VPos1.w=VPos7.x;
	OUT.VPos2.w=VPos7.y;
	OUT.VPos3.w=VPos7.z;
	OUT.VPos4.w=VPos8.x;
	OUT.VPos5.w=VPos8.y;
	OUT.VPos6.w=VPos8.z;
	return OUT;
    }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
	float3 Geometry=tex2D(GeometrySampler,IN.Tex);
	float3 Diffuse=floor(Geometry/65025);
	float3 Normals=floor((Geometry/255)-(Diffuse*255));
	Normals *=0.00394f;
	Normals=normalize(Normals*2-1);
	float3 WPos=normalize(IN.VPos)*tex2D(PositionSampler,IN.Tex).x;
	float2 Noise=tex2D(NoiseSampler,IN.Tex*18)*2-1;
	float3 Difference=(normalize(IN.VPos1.xyz)*tex2D(PositionSampler,IN.Tex+((Noise+1)*Radius)).x)-WPos;
	float Occulion=max(0.0,dot(Normals,normalize(Difference))-Bias)*(1.0/(1.0+length(Difference)*Scale));
	Difference=(normalize(IN.VPos2.xyz)*tex2D(PositionSampler,IN.Tex+((Noise+float2(0,1.5f))*Radius)).x)-WPos;
	Occulion +=max(0.0,dot(Normals,normalize(Difference))-Bias)*(1.0/(1.0+length(Difference)*Scale));
	Difference=(normalize(IN.VPos3.xyz)*tex2D(PositionSampler,IN.Tex+((Noise+float2(-1,1))*Radius)).x)-WPos;
	Occulion +=max(0.0,dot(Normals,normalize(Difference))-Bias)*(1.0/(1.0+length(Difference)*Scale));
	Difference=(normalize(IN.VPos4.xyz)*tex2D(PositionSampler,IN.Tex+((Noise+float2(1,-1))*Radius)).x)-WPos;
	Occulion +=max(0.0,dot(Normals,normalize(Difference))-Bias)*(1.0/(1.0+length(Difference)*Scale));
	Difference=(normalize(IN.VPos5.xyz)*tex2D(PositionSampler,IN.Tex+((Noise+float2(0,-1.5f))*Radius)).x)-WPos;
	Occulion +=max(0.0,dot(Normals,normalize(Difference))-Bias)*(1.0/(1.0+length(Difference)*Scale));
	Difference=(normalize(IN.VPos6.xyz)*tex2D(PositionSampler,IN.Tex+((Noise-1)*Radius)).x)-WPos;
	Occulion +=max(0.0,dot(Normals,normalize(Difference))-Bias)*(1.0/(1.0+length(Difference)*Scale));
	Difference=(normalize(float3(IN.VPos1.w,IN.VPos2.w,IN.VPos3.w))*tex2D(PositionSampler,IN.Tex+((Noise+float2(1.5f,0))*Radius)).x)-WPos;
	Occulion +=max(0.0,dot(Normals,normalize(Difference))-Bias)*(1.0/(1.0+length(Difference)*Scale));
	Difference=(normalize(float3(IN.VPos4.w,IN.VPos5.w,IN.VPos6.w))*tex2D(PositionSampler,IN.Tex+((Noise+float2(-1.5f,0))*Radius)).x)-WPos;
	Occulion +=max(0.0,dot(Normals,normalize(Difference))-Bias)*(1.0/(1.0+length(Difference)*Scale));
	return float4(0,0,0,(Occulion/8)*Intencity);
     }

//--------------
// techniques   
//--------------
    technique SSAO
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS(); 
 	PixelShader  = compile ps_3_0 PS();
	zwriteenable=false;
	zenable=false;
        ColorWriteEnable=8;	
      }
      }