//====================================================
// Sky
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
   matrix ProjMat={0.5,0,0,0.5,0,-0.5,0,0.5,0,0,0.5,0.5,0,0,0,1};
   float time:Time;

//--------------
// tweaks
//--------------
   float4 ViewSize;
   float CameraRange;
   float3 SkyColor1;
   float3 SkyColor2;
   float3 SunColor;
   matrix SunProjMatrix;
   float3 PlanetColor;
   matrix PlanetProjMatrix;
   matrix SkyAngle;
   float3 LightDirection;
   float3 LightPosition;
   float4 FogRange;
   float3 FogColor1;
   float3 FogColor2;
   float2 Overcast;
   float2 CloudDensity;
   float2 CloudScale;
   float2 CloudSpeed;
   float3 CloudColor;
   float3 LightColor;

//--------------
// Textures
//--------------
   texture SkyCubeMapTexture <string Name="";>;
   sampler SkyCubeMapSampler=sampler_state 
      {
	texture=<SkyCubeMapTexture>;
      };
   texture DepthTexture <string Name = "";>;
   sampler DepthSampler=sampler_state 
      {
	Texture=<DepthTexture>;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture NoiseTexture <string Name="";>;
   sampler NoiseSampler=sampler_state 
      {
 	texture=<NoiseTexture>;
      };
   texture SunTexture <string Name = "";>;	
   sampler SunSampler=sampler_state 
      {
 	texture=<SunTexture>;
	AddressU=Border;
	AddressV=Border;
	AddressW=Border;
      };
   texture PlanetTexture <string Name = "";>;	
   sampler PlanetSampler=sampler_state 
      {
 	texture=<PlanetTexture>;
	AddressU=Border;
	AddressV=Border;
	AddressW=Border;
      };
   texture CloudTexture <string Name=""; >;
   sampler CloudSampler=sampler_state 
      {
	Texture=<CloudTexture>;
      };
   texture CloudNoiseTexture <string Name = "";>;
   sampler CloudNoiseSampler=sampler_state 
      {
 	texture=<CloudNoiseTexture>;
      };

//--------------
// structs 
//--------------
   struct In_SkyBox
     {
        float4 Pos:POSITION;
     };
   struct Out_SkyBox
     {
 	float4 Pos:POSITION; 
	float4 Proj:TEXCOORD0;
	float3 View:TEXCOORD1;
     };
   struct In_Sky
     {
        float4 Pos:POSITION;
 	float2 Tex:TEXCOORD;
     };
   struct Out_Sky
     {
 	float4 Pos:POSITION; 
  	float4 Tex:TEXCOORD0;
	float4 Proj:TEXCOORD1;
  	float4 SunProj:TEXCOORD2; 
   	float4 PlanetProj:TEXCOORD3; 
	float3 View:TEXCOORD4;
	float3 WPos:TEXCOORD5;
	float3 ViewPos:TEXCOORD6;
	float3 LightVec:TEXCOORD7;
	float3 Normal:COLOR0;
     };

//--------------
// vertex shader
//--------------
   Out_SkyBox VS_SkyBox(In_SkyBox IN) 
     {
 	Out_SkyBox OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	OUT.View=mul(IN.Pos,SkyAngle);
	return OUT;
     }
   Out_Sky VS_Sky(In_Sky IN) 
     {
 	Out_Sky OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
 	OUT.Tex=float4(IN.Tex*20,IN.Tex*200);
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	OUT.Normal=-normalize(IN.Pos);
	OUT.SunProj=mul(ProjMat,mul(float4(mul(IN.Pos,World)-ViewInv[3].xyz,1),SunProjMatrix));
	OUT.PlanetProj=mul(ProjMat,mul(float4(mul(IN.Pos,World)-ViewInv[3].xyz,1),PlanetProjMatrix));
	OUT.View=mul(IN.Pos,SkyAngle);
	OUT.WPos=mul(IN.Pos,World);
	OUT.ViewPos=OUT.WPos-ViewInv[3].xyz;
	OUT.LightVec=mul(IN.Pos,World)-LightPosition;
	return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS_SkyBox(Out_SkyBox IN) : COLOR
     {
	clip((tex2D(DepthSampler,((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy).y+CameraRange)-IN.Proj.w);
	return float4(texCUBE(SkyCubeMapSampler,IN.View).xyz,1);
     }
   float4 PS_Sky(Out_Sky IN) : COLOR
     {
	clip((saturate(IN.WPos.y)-0.1f));
	clip((tex2D(DepthSampler,((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy).y+CameraRange)-IN.Proj.w);
	float AvgSkyColor=1-saturate(dot(SkyColor1,1));
	float Noise=lerp(tex2D(NoiseSampler,IN.Tex.xy),tex2D(NoiseSampler,IN.Tex.zw),1-AvgSkyColor)-0.5f;
	float3 Atmosphere=lerp(SkyColor2,SkyColor1,(Noise*0.25f)+(dot(IN.Normal,LightDirection)+1)/2);
	float Horizon=lerp(saturate(exp((IN.Normal.y+Overcast.x)*(Noise+2.5f))),saturate(exp(IN.Normal.y*(Noise+2.5f))),Overcast.y);
	float2 CloudUV=(IN.ViewPos.xz/IN.ViewPos.y);
	CloudUV=(CloudUV/CloudScale)+(time*CloudSpeed)+(tex2D(CloudNoiseSampler,CloudUV*2.5f)*0.005f);
	float Clouds=pow(tex2D(CloudSampler,CloudUV),CloudDensity.x)*saturate(-(IN.Normal.y+0.05f)*2);
	float CloudsLit=Clouds*(1-pow(tex2D(CloudSampler,CloudUV+(-LightDirection.xz*0.01f)),CloudDensity.x));
	float PowHorizon=1-pow(Horizon,32);
	float4 Planet=tex2Dproj(PlanetSampler,IN.PlanetProj)*saturate(IN.PlanetProj.z)*PowHorizon;
	Planet.w=1-Planet.w;
	float4 Sun=tex2Dproj(SunSampler,IN.SunProj)*saturate(IN.SunProj.z)*PowHorizon*Planet.w;
	Sun.w=1-Sun.w;
	float3 SkyCube=texCUBE(SkyCubeMapSampler,IN.View)*AvgSkyColor*Planet.w;
	float LightVec=saturate(length(IN.LightVec)/(FogRange.x*2));
	Atmosphere=lerp(((Atmosphere+SkyCube)*Sun.w),lerp(FogColor2,FogColor1,LightVec),Horizon);
	return float4(lerp(Atmosphere+(Sun*SunColor)+(Planet*PlanetColor*AvgSkyColor),CloudColor+CloudsLit*LightColor,Clouds*CloudDensity.y),1);
     }
   float4 PS_SkyBoxSolid(Out_SkyBox IN) : COLOR
     {
	return float4(texCUBE(SkyCubeMapSampler,IN.View).xyz,1);
     }
   float4 PS_SkySolid(Out_Sky IN) : COLOR
     {
	clip((saturate(IN.WPos.y)-0.1f));
	float AvgSkyColor=1-saturate(dot(SkyColor1,0.8f));
	float3 Atmosphere=lerp(SkyColor2,SkyColor1,(dot(IN.Normal,LightDirection)+1)/2);
	float Horizon=lerp(saturate(exp((IN.Normal.y+Overcast.x)*2.5f)),saturate(exp(IN.Normal.y*2.5f)),Overcast.y);
	float PowHorizon=1-pow(Horizon,32);
	float4 Planet=tex2Dproj(PlanetSampler,IN.PlanetProj)*saturate(IN.PlanetProj.z)*PowHorizon;
	Planet.w=1-Planet.w;
	float4 Sun=tex2Dproj(SunSampler,IN.SunProj)*saturate(IN.SunProj.z)*PowHorizon*Planet.w;
	Sun.w=1-Sun.w;
	float3 SkyCube=texCUBE(SkyCubeMapSampler,IN.View)*AvgSkyColor*Planet.w;
	float LightVec=saturate(length(IN.LightVec)/(FogRange.x*2));
	Atmosphere=lerp(((Atmosphere+SkyCube)*Sun.w),lerp(FogColor2,FogColor1,LightVec),Horizon);
	return float4(Atmosphere+(Sun*SunColor)+(Planet*PlanetColor*AvgSkyColor),1);
     }

//--------------
// techniques   
//--------------
   technique SkyBox
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS_SkyBox();
 	pixelShader  = compile ps_3_0 PS_SkyBox();
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
   technique Sky
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS_Sky();
 	pixelShader  = compile ps_3_0 PS_Sky();
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
   technique SkyBoxSolid
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS_SkyBox();
 	pixelShader  = compile ps_3_0 PS_SkyBoxSolid();
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
   technique SkySolid
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS_Sky();
 	pixelShader  = compile ps_3_0 PS_SkySolid();
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }