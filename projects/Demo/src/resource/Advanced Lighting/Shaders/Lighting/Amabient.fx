//====================================================
// Amabient
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix ViewInv:ViewInverse; 
   matrix ProjInv;

//--------------
// tweaks
//--------------
   float4 ViewSize;
   float3 AmbientColor;
   float4 FogRange;
   float3 FogColor1;
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
 	float2 Tex:TEXCOORD0;
	float3 VPos:TEXCOORD1;
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
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS_Ambient(OutPut IN) : COLOR
     {
	float ViewVecL=tex2D(PositionSampler,IN.Tex).x;
	float3 ViewVec=normalize(IN.VPos)*ViewVecL;
	float3 WPos=ViewInv[3].xyz+ViewVec;
	float4 Geometry=tex2D(GeometrySampler,IN.Tex);
	float4 Diffuse=floor(Geometry/65025);
	Diffuse *=0.00394f;
	float3 AmbientLight=AmbientColor*tex2D(SSAOSampler,IN.Tex).www;
	float3 FogDist=saturate(float3(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	float4 Fog=float4(lerp(HeightFogColor.xyz,FogColor1,FogDist.x),saturate((FogDist.z*FogDist.y)+FogDist.x));
	return float4(lerp(lerp(Diffuse*AmbientLight,Diffuse,floor(Diffuse.w)),Fog,Fog.w),1);
     }
  float4 PS_AmbientCube(OutPut IN) : COLOR
     {
	float ViewVecL=tex2D(PositionSampler,IN.Tex).x;
	float3 ViewVec=normalize(IN.VPos)*ViewVecL;
	float3 WPos=ViewInv[3].xyz+ViewVec;
	float4 Geometry=tex2D(GeometrySampler,IN.Tex);
	float4 Diffuse=floor(Geometry/65025);
	float4 Normals=floor((Geometry/255)-(Diffuse*255));
	Diffuse *=0.00394f;
	Normals *=0.00394f;
	Normals.xyz=normalize(Normals.xyz*2-1);
	float3 AmbientLight=(texCUBE(AmbientMapSampler,reflect(ViewVec,Normals))+0.25f)*AmbientColor*tex2D(SSAOSampler,IN.Tex).www;
	float3 FogDist=saturate(float3(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	float4 Fog=float4(lerp(HeightFogColor.xyz,FogColor1,FogDist.x),saturate((FogDist.z*FogDist.y)+FogDist.x));
	return float4(lerp(lerp(Diffuse*AmbientLight,Diffuse,floor(Diffuse.w)),Fog,Fog.w),1);
     }

//--------------
// techniques   
//--------------
   technique Ambient
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS();
 	pixelShader  = compile ps_3_0 PS_Ambient();
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
   technique AmbientCube
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS();
 	pixelShader  = compile ps_3_0 PS_AmbientCube();
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }