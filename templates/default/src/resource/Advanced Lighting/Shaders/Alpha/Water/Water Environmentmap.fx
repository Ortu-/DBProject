//====================================================
// Water
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

#define ChromaticAberration 1

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
   float3 EnvBoxPos;
   float3 EnvBoxMin;
   float3 EnvBoxMax;
   float2 WaterScale={2,2};
   float4 Speed={-0.04f,-0.1f,0.04f,-0.1f};
   float EdgeSoftness=5;
   float3 AmbientColor;
   float3 LightColor;
   float3 LightColor1;
   float4 LightPosition1;
   float4 LightNormal1;
   float3 LightColor2;
   float4 LightPosition2;
   float4 LightNormal2;
   float3 LightColor3;
   float4 LightPosition3;
   float4 LightNormal3;
   float3 LightColor4;
   float4 LightPosition4;
   float4 LightNormal4;
   float3 LightColor5;
   float4 LightPosition5;
   float4 LightNormal5;
   float4 FogRange;
   float3 HeightFog;
   float4 HeightFogColor;

//--------------
// Textures
//--------------
   texture DepthTexture <string Name = "";>;
   sampler DepthSampler=sampler_state 
      {
	Texture=<DepthTexture>;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture CubeMapTexture <string Name="";>;
   sampler CubeMapSampler:register(s1)=sampler_state 
      {
	texture=<CubeMapTexture>;
      };
   texture RefractTexture <string Name=""; >;	
   sampler RefractSampler=sampler_state
     {
	Texture=<RefractTexture>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
     };
   texture WaterbumpTexture <string Name=""; >; 
   sampler2D WaterbumpSampler=sampler_state 
     {
	Texture = <WaterbumpTexture>;
     };

//--------------
// structs 
//--------------
   struct InPut
     {
 	float4 Pos:POSITION;
 	float2 Tex:TEXCOORD;
	float3 Normal:NORMAL;
 	float3 Tangent:TANGENT;
 	float3 Binormal:BINORMAL;
     };
   struct OutPut
     {
 	float4 Pos:POSITION;
   	float4 Tex:TEXCOORD0;
        float4 Proj:TEXCOORD1;
    	float3 WPos:TEXCOORD2;
   	float3 ViewPos:TEXCOORD3;
  	float3 tbnRow1:TEXCOORD4;
  	float3 tbnRow2:TEXCOORD5;
  	float3 tbnRow3:TEXCOORD6;
 	float3 ViewVec:TEXCOORD7;
 	float Fog:COLOR0;
	float3 Light:COLOR1;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN)
     {
 	OutPut OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
	OUT.Tex.xy=(IN.Tex*WaterScale+(time*Speed.xy));
	OUT.Tex.zw=(IN.Tex*WaterScale*2+(time*Speed.zw));
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	float3 WPos=mul(IN.Pos,World);
	OUT.WPos=WPos;
 	float3 ViewVec=WPos-ViewInv[3].xyz;
 	OUT.ViewPos=ViewVec;
	float3x3 TBN={IN.Tangent,IN.Binormal,IN.Normal};
	TBN=transpose(mul(TBN,World));
	OUT.tbnRow1=TBN[0];
	OUT.tbnRow2=TBN[1];
	OUT.tbnRow3=TBN[2];
 	OUT.ViewVec=mul(ViewVec,TBN);
	float ViewVecL=length(ViewVec);
	float3 FogDist=saturate(float3(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	OUT.Fog=1-saturate((FogDist.z*FogDist.y)+FogDist.x);
	float3 LightVec=WPos-LightPosition1;
	float3 LightNormal=saturate(dot(normalize(LightVec),LightNormal1)+LightNormal1.w);
	float Attenuation=1-saturate(length(LightVec)/LightPosition1.w);
	float3 Light=LightNormal*Attenuation*LightColor1;
	LightVec=WPos-LightPosition2;
	LightNormal=saturate(dot(normalize(LightVec),LightNormal2)+LightNormal2.w);
	Attenuation=1-saturate(length(LightVec)/LightPosition2.w);
	Light +=LightNormal*Attenuation*LightColor2;
	LightVec=WPos-LightPosition3;
	LightNormal=saturate(dot(normalize(LightVec),LightNormal3)+LightNormal3.w);
	Attenuation=1-saturate(length(LightVec)/LightPosition3.w);
	Light +=LightNormal*Attenuation*LightColor3;
	LightVec=WPos-LightPosition4;
	LightNormal=saturate(dot(normalize(LightVec),LightNormal4)+LightNormal4.w);
	Attenuation=1-saturate(length(LightVec)/LightPosition4.w);
	Light +=LightNormal*Attenuation*LightColor4;
	LightVec=WPos-LightPosition5;
	LightNormal=saturate(dot(normalize(LightVec),LightNormal5)+LightNormal5.w);
	Attenuation=1-saturate(length(LightVec)/LightPosition5.w);
	Light +=LightNormal*Attenuation*LightColor5;
	OUT.Light=AmbientColor+LightColor+Light;
        return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS_AboveWater(OutPut IN) : COLOR 
     {
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
        float Depth=tex2D(DepthSampler,ViewProj).y-IN.Proj.w;
	clip(Depth);
	float3 NormalMap=tex2D(WaterbumpSampler,IN.Tex.xy)+tex2D(WaterbumpSampler,IN.Tex.zw)-1;
	float3 View=normalize(IN.ViewVec);
	float Fresnel=pow(1-saturate(dot(NormalMap,View)),2.5);
	float3x3 WorldNorm={IN.tbnRow1,IN.tbnRow2,IN.tbnRow3};
	float3 LookUp=reflect(IN.ViewPos,mul(WorldNorm,NormalMap));
	float3 NLookUp=normalize(LookUp);
	float3 EnvBoxMinMax=(lerp(EnvBoxMin,EnvBoxMax,ceil(NLookUp))-IN.WPos)/NLookUp;
	LookUp=(IN.WPos+NLookUp*min(min(EnvBoxMinMax.x,EnvBoxMinMax.y),EnvBoxMinMax.z))-EnvBoxPos;
	float3 Reflection=texCUBE(CubeMapSampler,LookUp);
	NormalMap *=0.25f;
        NormalMap.xy *=saturate(tex2D(DepthSampler,ViewProj+NormalMap.xy).y-IN.Proj.w);
	#if ChromaticAberration== 1
	 float3 Refraction;
	 Refraction.x=tex2D(RefractSampler,ViewProj+(NormalMap.xy*1.1f)).x;
	 Refraction.y=tex2D(RefractSampler,ViewProj+NormalMap.xy).y;
	 Refraction.z=tex2D(RefractSampler,ViewProj+(NormalMap.xy/1.1f)).z;
	#else
	 float3 Refraction=tex2D(RefractSampler,ViewProj+NormalMap.xy);
	#endif
        return float4(lerp(Refraction,Reflection*IN.Light,Fresnel),(Depth*0.05f)*IN.Fog);
     }
   float4 PS_UnderWater(OutPut IN) : COLOR 
     {
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
        float Depth=tex2D(DepthSampler,ViewProj).y-IN.Proj.w;
	clip(Depth);
	float3 NormalMap=tex2D(WaterbumpSampler,IN.Tex.xy)+tex2D(WaterbumpSampler,IN.Tex.zw)-1;
	NormalMap *=0.1f;
        NormalMap.xy *=saturate(tex2D(DepthSampler,ViewProj+NormalMap.xy).y-IN.Proj.w);
	#if ChromaticAberration== 1
	 float3 Refraction;
	 Refraction.x=tex2D(RefractSampler,ViewProj+(NormalMap.xy*1.2f)).x;
	 Refraction.y=tex2D(RefractSampler,ViewProj+NormalMap.xy).y;
	 Refraction.z=tex2D(RefractSampler,ViewProj+(NormalMap.xy/1.2f)).z;
	#else
	 float3 Refraction=tex2D(RefractSampler,ViewProj+NormalMap.xy);
	#endif
        return float4(Refraction,(Depth*0.05f)*IN.Fog);
     }

//--------------
// techniques   
//--------------
   technique AboveWater
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS_AboveWater();
	SrcBlend=srcalpha;
        ColorWriteEnable=7;
	CullMode=ccw;
      }
      }
   technique UnderWater
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS_UnderWater();
	SrcBlend=srcalpha;
        ColorWriteEnable=7;
	CullMode=cw;
      }
      }