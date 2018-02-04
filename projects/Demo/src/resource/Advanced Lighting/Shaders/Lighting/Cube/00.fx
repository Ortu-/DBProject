//====================================================
// Cube Light
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
   float3 LightPosition;
   float3 LightColor;
   float LightRange;
   float3x3 LightAngle;
   float AttenuationPower;
   float4 FogRange;
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
   texture BlendMaskTexture <string Name = "";>; 
   texture DepthMapXTexture <string Name = "";>; 
   texture DepthMapYTexture <string Name = "";>; 
   texture DepthMapZTexture <string Name = "";>; 
   texture CubeLightTexture <string Name = "";>; 
   sampler CubeLightSampler=sampler_state
      {
	Texture=<CubeLightTexture>;
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
   float4 PS_Point(OutPut IN)  : COLOR
     {	
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
	float ViewVecL=tex2D(PositionSampler,ViewProj).x;
	float3 ViewVec=normalize(IN.VPos)*ViewVecL;
	float3 WPos=ViewInv[3].xyz+ViewVec;
	float3 LightVec=WPos-LightPosition;
	float Attenuation=1-pow(length(LightVec/LightRange),AttenuationPower);
	clip(1-Attenuation);
	float3 Cubelight=texCUBE(CubeLightSampler,mul(LightAngle,LightVec));
	if(Attenuation<1)
	 {
	  float4 Geometry=tex2Dlod(GeometrySampler,float4(ViewProj,0,0));
	  float4 Diffuse=floor(Geometry/65025);
	  float4 Normals=floor((Geometry/255)-(Diffuse*255));
	  Diffuse *=0.00394f;
	  Normals *=0.00394f;
	  Normals.xyz=normalize(Normals.xyz*2-1);
	  float3 FogDist=saturate(float3(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	  float Fog=1-saturate((FogDist.z*FogDist.y)+FogDist.x);
	  LightVec=normalize(-LightVec);
	  float Normal=saturate(dot(Normals,LightVec));
  	  return float4(Diffuse*Cubelight*Normal*LightColor*Attenuation*Fog,1);
         }
	else discard;
     }

//--------------
// techniques   
//--------------
   technique Point
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS_Point();
	AlphaBlendEnable=True;
 	SrcBlend=One;
 	DestBlend=One;
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }