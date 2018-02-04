//====================================================
// Fog Z Volume
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection;
   matrix World:World;
   matrix ViewInv:ViewInverse; 

//--------------
// tweaks
//--------------
   float4 ViewSize;
   matrix AreaFogProjMatrix;
   float3 AreaFogPosition;
   float3 AreaFogDirection;
   float AreaFogZScale;
   float AreaFogIntencity;
   float4 AreaFogColor;
   float3 AreaFogColor2;
   float4 AreaFogRange;
   float4 FogRange;

//--------------
// Textures
//--------------
   texture PositionTexture <string Name = "";>;
   sampler PositionSampler=sampler_state 
      {
	Texture=<PositionTexture>;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture MaskTexture <string Name = "";>;
   sampler MaskSampler=sampler_state 
      {
	Texture=<MaskTexture>;
	MagFilter=Point;
	MinFilter=Point;
	MipFilter=None;
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
	float4 Proj:TEXCOORD0;
	float3 VPos:TEXCOORD1;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	OUT.VPos=mul(IN.Pos,World)-ViewInv[3].xyz;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {
	float2 Depth=tex2D(PositionSampler,((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy);
	float3 WPos=ViewInv[3].xyz+normalize(IN.VPos)*Depth.x;
	float3 ViewVec=WPos-ViewInv[3].xyz;
	float LerpFac=ceil(saturate(Depth.y-IN.Proj.w));
	float ViewVecL=length(lerp(ViewVec,IN.VPos,LerpFac));
	float FogDist=1-saturate(exp(-(ViewVecL/AreaFogRange.x)*7.5f));
	float3 FogVec=WPos-AreaFogPosition;
	float FogFall=dot(FogVec,AreaFogDirection)+1;
	float DeepFog=saturate((AreaFogRange.z-FogFall)/AreaFogRange.z)*(1-(saturate(ViewVecL/AreaFogRange.x)*AreaFogRange.w));
	float FogMask=tex2D(MaskSampler,mul(float4(FogVec,1),AreaFogProjMatrix).xy*0.5f+0.5f);
	FogMask *=saturate(FogFall/AreaFogRange.y)*(1-saturate(FogFall-AreaFogZScale));
	float AreaFog=lerp(FogMask,AreaFogIntencity,LerpFac)*FogDist;
	clip(AreaFog-0.0001f);
  	FogDist=1-saturate(pow(ViewVecL/FogRange.x,FogRange.z));
	return float4(lerp(AreaFogColor.xyz,AreaFogColor2,DeepFog),AreaFog*AreaFogColor.w*FogDist);
     }
  float4 PS_Blocker(OutPut IN) : COLOR
     {
	float2 Depth=tex2D(PositionSampler,((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy);
	float3 WPos=ViewInv[3].xyz+normalize(IN.VPos)*Depth.x;
	float3 ViewVec=WPos-ViewInv[3].xyz;
	float LerpFac=ceil(saturate(Depth.y-IN.Proj.w));
	float ViewVecL=length(lerp(ViewVec,IN.VPos,LerpFac));
	float FogDist=1-saturate(exp(-(ViewVecL/AreaFogRange.x)*7.5f));
	float3 FogVec=WPos-AreaFogPosition;
	float FogFall=dot(FogVec,AreaFogDirection)+1;
	float FogMask=tex2D(MaskSampler,mul(float4(FogVec,1),AreaFogProjMatrix).xy*0.5f+0.5f);
	FogMask *=saturate(FogFall/AreaFogRange.y)*(1-saturate(FogFall-AreaFogZScale));
	float AreaFog=lerp(FogMask,AreaFogIntencity,LerpFac)*FogDist;
	clip(AreaFog-0.0001f);
  	FogDist=1-saturate(pow(ViewVecL/FogRange.x,FogRange.z));
	return float4(0.5f,0.5f,0,AreaFog*AreaFogColor.w*FogDist);
     }

//--------------
// techniques   
//--------------
    technique Diffuse
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS();
	SrcBlend=srcalpha;
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
    technique Blocker
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS_Blocker();
	SrcBlend=srcalpha;
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }