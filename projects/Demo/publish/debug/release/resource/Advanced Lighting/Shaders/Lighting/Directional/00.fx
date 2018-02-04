//====================================================
// Directional Light
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
   float ShadowSize;
   float3 LightColor;
   float3 LightDirection;
   float3 LightPosition;
   float4 LightRange;
   float4 ShadowRange;
   float3 LightPosition1;
   matrix ShadowProjMatrix1;
   float3 ShadowPosition1; 
   float3 LightPosition2;
   matrix ShadowProjMatrix2;
   float3 ShadowPosition2;
   float3 LightPosition3;
   matrix ShadowProjMatrix3;
   float3 ShadowPosition3;
   float3 LightPosition4;
   matrix ShadowProjMatrix4;
   float3 ShadowPosition4;
   float3 AmbientColor;
   float4 FogRange;
   float3 FogColor1;
   float3 FogColor2;
   float3 HeightFog;
   float4 HeightFogColor;

//--------------
// Textures
//--------------
   texture GeometryTexture <string Name = "";>;
   sampler GeometrySampler=sampler_state 
      {
	Texture=<GeometryTexture>;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture PositionTexture <string Name = "";>;
   sampler PositionSampler=sampler_state 
      {
	Texture=<PositionTexture>;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture AmbientMapTexture <string Name="";>;
   sampler AmbientMapSampler=sampler_state 
      {
	Texture=<AmbientMapTexture>;
      };
   texture DepthMap1Texture <string Name = "";>;	
   sampler DepthMap1Sampler=sampler_state 
      {
 	texture=<DepthMap1Texture>;
     	ADDRESSU=CLAMP;
        ADDRESSV=CLAMP;
        ADDRESSW=CLAMP;
      };
   texture DepthMap2Texture <string Name = "";>;	
   sampler DepthMap2Sampler=sampler_state 
      {
 	texture=<DepthMap2Texture>;
     	ADDRESSU=CLAMP;
        ADDRESSV=CLAMP;
        ADDRESSW=CLAMP;
      };
   texture DepthMap3Texture <string Name = "";>;	
   sampler DepthMap3Sampler=sampler_state 
      {
 	texture=<DepthMap3Texture>;
     	ADDRESSU=CLAMP;
        ADDRESSV=CLAMP;
        ADDRESSW=CLAMP;
      };
   texture SSAOTexture <string Name = "";>;	
   sampler SSAOSampler=sampler_state 
      {
 	texture=<SSAOTexture>;
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
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.w);
	OUT.VPos=mul(IN.Pos,World)-ViewInv[3].xyz;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS_AmbientDirectional(OutPut IN) : COLOR
     {
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
	float ViewVecL=tex2D(PositionSampler,ViewProj).x;
	float3 ViewVec=normalize(IN.VPos)*ViewVecL;
	float3 WPos=ViewInv[3].xyz+ViewVec;
	float4 Geometry=tex2D(GeometrySampler,ViewProj);
	float4 Diffuse=floor(Geometry/65025);
	float4 Normals=floor((Geometry/255)-(Diffuse*255));
	Diffuse *=0.00394f;
	Normals *=0.00394f;
	Normals.xyz=normalize(Normals.xyz*2-1);
	float3 AmbientLight=AmbientColor*tex2D(SSAOSampler,ViewProj).www;
	float3 LightVec=WPos-LightPosition;
	float4 FogDist=saturate(float4(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),length(LightVec)/(FogRange.x*2),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	float4 Fog=float4(lerp(HeightFogColor.xyz,lerp(FogColor2,FogColor1,FogDist.z),FogDist.x),saturate((FogDist.w*FogDist.y)+FogDist.x));
	float Normal=saturate(dot(Normals,-LightDirection));
	return float4(lerp(lerp(Diffuse*((Normal*LightColor)+AmbientLight),Diffuse,floor(Diffuse.w)),Fog,Fog.w),1);
     }
  float4 PS_AmbientCubeDirectional(OutPut IN) : COLOR
     {
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
	float ViewVecL=tex2D(PositionSampler,ViewProj).x;
	float3 ViewVec=normalize(IN.VPos)*ViewVecL;
	float3 WPos=ViewInv[3].xyz+ViewVec;
	float4 Geometry=tex2D(GeometrySampler,ViewProj);
	float4 Diffuse=floor(Geometry/65025);
	float4 Normals=floor((Geometry/255)-(Diffuse*255));
	Diffuse *=0.00394f;
	Normals *=0.00394f;
	Normals.xyz=normalize(Normals.xyz*2-1);
	float3 AmbientLight=(texCUBE(AmbientMapSampler,reflect(ViewVec,Normals))+0.25f)*(AmbientColor*tex2D(SSAOSampler,ViewProj).www);
	float3 LightVec=WPos-LightPosition;
	float4 FogDist=saturate(float4(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),length(LightVec)/(FogRange.x*2),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	float4 Fog=float4(lerp(HeightFogColor.xyz,lerp(FogColor2,FogColor1,FogDist.z),FogDist.x),saturate((FogDist.w*FogDist.y)+FogDist.x));
	float Normal=saturate(dot(Normals,-LightDirection));
	return float4(lerp(lerp(Diffuse*((Normal*LightColor)+AmbientLight),Diffuse,floor(Diffuse.w)),Fog,Fog.w),1);
     }
  float4 PS_AmbientDirectionalShadow(OutPut IN) : COLOR
     {
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
	float ViewVecL=tex2D(PositionSampler,ViewProj).x;
	float3 ViewVec=normalize(IN.VPos)*ViewVecL;
	float3 WPos=ViewInv[3].xyz+ViewVec;
	float4 Geometry=tex2D(GeometrySampler,ViewProj);
	float4 Diffuse=floor(Geometry/65025);
	float4 Normals=floor((Geometry/255)-(Diffuse*255));
	Diffuse *=0.00394f;
	Normals *=0.00394f;
	Normals.xyz=normalize(Normals.xyz*2-1);
	float3 AmbientLight=AmbientColor*tex2D(SSAOSampler,ViewProj).www;
	float3 LightVec=WPos-LightPosition;
	float4 FogDist=saturate(float4(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),length(LightVec)/(FogRange.x*2),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	float4 Fog=float4(lerp(HeightFogColor.xyz,lerp(FogColor2,FogColor1,FogDist.z),FogDist.x),saturate((FogDist.w*FogDist.y)+FogDist.x));
	float4 ShadowSplit=float4(length(WPos-LightPosition1),length(WPos-LightPosition2),length(WPos-LightPosition3),length(WPos-LightPosition4));
	ShadowSplit=saturate((1-ShadowSplit/LightRange)*12);
	float ShadowMap=1-ShadowSplit.w;
	if(ShadowSplit.x>0.01f)
	 {
  	  float2 ShadowProj=mul(float4(WPos,1),ShadowProjMatrix1).xy;
	  float Depth=dot(WPos-ShadowPosition1,LightDirection)/ShadowRange.x;
	  float2 DepthExp=exp(float2(Depth,1-Depth)*7-3.5f);
  	  float4 Moments=tex2Dlod(DepthMap1Sampler,float4(ShadowProj*float2(0.5f,-0.5f)+ShadowSize,0,1));
	  float2 Mue=Moments.xy-DepthExp;
	  float2 variance=(Moments.zw-(Moments.xy*Moments.xy));
          variance /=variance+Mue*Mue;
	  ShadowMap +=smoothstep(0.2f,1,min((DepthExp.x<Moments.x ? 1:variance.x),(DepthExp.y>Moments.y ? 1:variance.y)))*ShadowSplit.x;
	 }
	if(ShadowSplit.y-ShadowSplit.x>0.01f)
	 {
  	  float2 ShadowProj=mul(float4(WPos,1),ShadowProjMatrix2).xy;
	  float Depth=dot(WPos-ShadowPosition2,LightDirection)/ShadowRange.y;
	  float2 DepthExp=exp(float2(Depth,1-Depth)*7-3.5f);
  	  float4 Moments=tex2Dlod(DepthMap2Sampler,float4(ShadowProj*float2(0.5f,-0.5f)+ShadowSize,0,1));
	  float2 Mue=Moments.xy-DepthExp;
	  float2 variance=(Moments.zw-(Moments.xy*Moments.xy));
          variance /=variance+Mue*Mue;
	  ShadowMap +=smoothstep(0.2f,1,min((DepthExp.x<Moments.x ? 1:variance.x),(DepthExp.y>Moments.y ? 1:variance.y)))*(1-ShadowSplit.x)*ShadowSplit.y;
	 }
	if(ShadowSplit.z-ShadowSplit.y>0.01f)
	 {
  	  float2 ShadowProj=mul(float4(WPos,1),ShadowProjMatrix3).xy;
	  float Depth=dot(WPos-ShadowPosition3,LightDirection)/ShadowRange.z;
  	  float2 Moments=tex2Dlod(DepthMap3Sampler,float4(ShadowProj*float2(0.5f,-0.5f)+ShadowSize,0,1));
	  float Mue=Moments.x-Depth;
	  float variance=Moments.y-(Moments.x*Moments.x);
          variance /=variance+Mue*Mue;
	  ShadowMap +=(Depth<Moments.x ? 1:smoothstep(0.2f,1,variance.x))*(1-ShadowSplit.y)*ShadowSplit.z;
	 }
	if(ShadowSplit.w-ShadowSplit.z>0.01f)
	 {
  	  float2 ShadowProj=mul(float4(WPos,1),ShadowProjMatrix4).xy;
	  float Depth=dot(WPos-ShadowPosition4,LightDirection)/ShadowRange.w;
  	  float2 Moments=tex2Dlod(DepthMap3Sampler,float4(ShadowProj*float2(0.5f,-0.5f)+ShadowSize,0,1)).zw;
	  float Mue=Moments.x-Depth;
	  float variance=Moments.y-(Moments.x*Moments.x);
          variance /=variance+Mue*Mue;
	  ShadowMap +=(Depth<Moments.x ? 1:smoothstep(0.2f,1,variance.x))*(1-ShadowSplit.z)*ShadowSplit.w;
	 }
	float Normal=saturate(dot(Normals,-LightDirection));
	float3 Lighting=Normal*LightColor*ShadowMap;
	return float4(lerp(lerp(Diffuse*(Lighting+AmbientLight),Diffuse,floor(Diffuse.w)),Fog,Fog.w),1);
     }
  float4 PS_AmbientCubeDirectionalShadow(OutPut IN) : COLOR
     {
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
	float ViewVecL=tex2D(PositionSampler,ViewProj).x;
	float3 ViewVec=normalize(IN.VPos)*ViewVecL;
	float3 WPos=ViewInv[3].xyz+ViewVec;
	float4 Geometry=tex2D(GeometrySampler,ViewProj);
	float4 Diffuse=floor(Geometry/65025);
	float4 Normals=floor((Geometry/255)-(Diffuse*255));
	Diffuse *=0.00394f;
	Normals *=0.00394f;
	Normals.xyz=normalize(Normals.xyz*2-1);
	float3 AmbientLight=(texCUBE(AmbientMapSampler,reflect(ViewVec,Normals))+0.25f)*(AmbientColor*tex2D(SSAOSampler,ViewProj).www);
	float3 LightVec=WPos-LightPosition;
	float4 FogDist=saturate(float4(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),length(LightVec)/(FogRange.x*2),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	float4 Fog=float4(lerp(HeightFogColor.xyz,lerp(FogColor2,FogColor1,FogDist.z),FogDist.x),saturate((FogDist.w*FogDist.y)+FogDist.x));
	float4 ShadowSplit=float4(length(WPos-LightPosition1),length(WPos-LightPosition2),length(WPos-LightPosition3),length(WPos-LightPosition4));
	ShadowSplit=saturate((1-ShadowSplit/LightRange)*12);
	float ShadowMap=1-ShadowSplit.w;
	if(ShadowSplit.x>0.01f)
	 {
  	  float2 ShadowProj=mul(float4(WPos,1),ShadowProjMatrix1).xy;
	  float Depth=dot(WPos-ShadowPosition1,LightDirection)/ShadowRange.x;
	  float2 DepthExp=exp(float2(Depth,1-Depth)*7-3.5f);
  	  float4 Moments=tex2Dlod(DepthMap1Sampler,float4(ShadowProj*float2(0.5f,-0.5f)+ShadowSize,0,1));
	  float2 Mue=Moments.xy-DepthExp;
	  float2 variance=(Moments.zw-(Moments.xy*Moments.xy));
          variance /=variance+Mue*Mue;
	  ShadowMap +=smoothstep(0.2f,1,min((DepthExp.x<Moments.x ? 1:variance.x),(DepthExp.y>Moments.y ? 1:variance.y)))*ShadowSplit.x;
	 }
	if(ShadowSplit.y-ShadowSplit.x>0.01f)
	 {
  	  float2 ShadowProj=mul(float4(WPos,1),ShadowProjMatrix2).xy;
	  float Depth=dot(WPos-ShadowPosition2,LightDirection)/ShadowRange.y;
	  float2 DepthExp=exp(float2(Depth,1-Depth)*7-3.5f);
  	  float4 Moments=tex2Dlod(DepthMap2Sampler,float4(ShadowProj*float2(0.5f,-0.5f)+ShadowSize,0,1));
	  float2 Mue=Moments.xy-DepthExp;
	  float2 variance=(Moments.zw-(Moments.xy*Moments.xy));
          variance /=variance+Mue*Mue;
	  ShadowMap +=smoothstep(0.2f,1,min((DepthExp.x<Moments.x ? 1:variance.x),(DepthExp.y>Moments.y ? 1:variance.y)))*(1-ShadowSplit.x)*ShadowSplit.y;
	 }
	if(ShadowSplit.z-ShadowSplit.y>0.01f)
	 {
  	  float2 ShadowProj=mul(float4(WPos,1),ShadowProjMatrix3).xy;
	  float Depth=dot(WPos-ShadowPosition3,LightDirection)/ShadowRange.z;
  	  float2 Moments=tex2Dlod(DepthMap3Sampler,float4(ShadowProj*float2(0.5f,-0.5f)+ShadowSize,0,1));
	  float Mue=Moments.x-Depth;
	  float variance=Moments.y-(Moments.x*Moments.x);
          variance /=variance+Mue*Mue;
	  ShadowMap +=(Depth<Moments.x ? 1:smoothstep(0.2f,1,variance.x))*(1-ShadowSplit.y)*ShadowSplit.z;
	 }
	if(ShadowSplit.w-ShadowSplit.z>0.01f)
	 {
  	  float2 ShadowProj=mul(float4(WPos,1),ShadowProjMatrix4).xy;
	  float Depth=dot(WPos-ShadowPosition4,LightDirection)/ShadowRange.w;
  	  float2 Moments=tex2Dlod(DepthMap3Sampler,float4(ShadowProj*float2(0.5f,-0.5f)+ShadowSize,0,1)).zw;
	  float Mue=Moments.x-Depth;
	  float variance=Moments.y-(Moments.x*Moments.x);
          variance /=variance+Mue*Mue;
	  ShadowMap +=(Depth<Moments.x ? 1:smoothstep(0.2f,1,variance.x))*(1-ShadowSplit.z)*ShadowSplit.w;
	 }
	float Normal=saturate(dot(Normals,-LightDirection));
	float3 Lighting=Normal*LightColor*ShadowMap;
	return float4(lerp(lerp(Diffuse*(Lighting+AmbientLight),Diffuse,floor(Diffuse.w)),Fog,Fog.w),1);
     }

//--------------
// techniques   
//--------------
   technique AmbientDirectional
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS_AmbientDirectional();
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
   technique AmbientCubeDirectional
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS_AmbientCubeDirectional();
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
   technique AmbientDirectionalShadow
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS_AmbientDirectionalShadow();
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
   technique AmbientCubeDirectionalShadow
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS();
 	pixelShader  = compile ps_3_0 PS_AmbientCubeDirectionalShadow();
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }