//====================================================
// Fog Z Volume with caustics
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
   float time:Time;

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
   matrix CausticProjMatrix;

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
   texture CausticsTexture <string Name = "";>;
   sampler CausticsSampler=sampler_state 
    {
     	texture=<CausticsTexture>;
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
  	float3 WPos:TEXCOORD0;
	float4 Proj:TEXCOORD1;
	float3 VPos:TEXCOORD2;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
	OUT.WPos=mul(IN.Pos,World)-ViewInv[3].xyz;
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
	float3 LViewVec=lerp(ViewVec,IN.VPos,LerpFac);
	float ViewVecL=length(LViewVec);
	float FogDist=1-saturate(exp(-(ViewVecL/AreaFogRange.x)*7.5f));
	float3 FogVec=WPos-AreaFogPosition;
	float FogFall=dot(FogVec,AreaFogDirection)+1;
	float DeepFog=saturate((AreaFogRange.z-FogFall)/AreaFogRange.z)*(1-(saturate(ViewVecL/AreaFogRange.x)*AreaFogRange.w));
	float FogMask=tex2D(MaskSampler,mul(float4(FogVec,1),AreaFogProjMatrix).xy*0.5f+0.5f);
	FogMask *=saturate(FogFall/AreaFogRange.y)*(1-saturate(FogFall-AreaFogZScale));
	float AreaFog=lerp(FogMask,AreaFogIntencity,LerpFac)*FogDist;
	clip(AreaFog-0.0001f);
	float2 CausticUV=mul(float4(LViewVec+ViewInv[3].xyz,1),CausticProjMatrix);
	float2 CausticDistort=tex2D(CausticsSampler,CausticUV-(time*0.1f)).xy*0.1f;
	float Caustic=tex2D(CausticsSampler,CausticUV+(time*0.1f)+CausticDistort).z*saturate(1-AreaFog);
	return float4(lerp(AreaFogColor.xyz,AreaFogColor2,DeepFog)+Caustic,AreaFog*AreaFogColor.w);
     }
  float4 PS_Blocker(OutPut IN) : COLOR
     {
	float2 Depth=tex2D(PositionSampler,((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy);
	float3 WPos=ViewInv[3].xyz+normalize(IN.VPos)*Depth.x;
	float3 ViewVec=WPos-ViewInv[3].xyz;
	float LerpFac=ceil(saturate(Depth.y-IN.Proj.w));
	float3 LViewVec=lerp(ViewVec,IN.VPos,LerpFac);
	float ViewVecL=length(LViewVec);
	float FogDist=1-saturate(exp(-(ViewVecL/AreaFogRange.x)*7.5f));
	float3 FogVec=WPos-AreaFogPosition;
	float FogFall=dot(FogVec,AreaFogDirection)+1;
	float FogMask=tex2D(MaskSampler,mul(float4(FogVec,1),AreaFogProjMatrix).xy*0.5f+0.5f);
	FogMask *=saturate(FogFall/AreaFogRange.y)*(1-saturate(FogFall-AreaFogZScale));
	float AreaFog=lerp(FogMask,AreaFogIntencity,LerpFac)*FogDist;
	clip(AreaFog-0.0001f);
	return float4(0.5f,0.5f,0,AreaFog*AreaFogColor.w);
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