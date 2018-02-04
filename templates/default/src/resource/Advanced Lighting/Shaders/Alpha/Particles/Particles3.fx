//====================================================
// Particles
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix ViewProj:ViewProjection;
   matrix ViewInv:ViewInverse;
   float time:Time;

//--------------
// tweaks
//--------------
   matrix EmitterMat;
   matrix ParticleMat;
   float ZshiftScale;
   float4 ParticlePosition[100];
   float4 ParticleColor[100];
   float4 AlphaMultiplier;
   float4 Intensity;
   float2 AlphaToSurface;
   float2 Rotation;
   float4 Animation;
   float4 Sinw;
   float4 Cosw;
   float4 ViewSize;
   float EdgeSoftness;
   float Blocker;
   float4 FogRange;
   float3 HeightFog;
   float4 HeightFogColor;
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
   texture ParticleTexture <string Name = "";>;	
   sampler ParticleSampler=sampler_state 
      {
 	Texture=<ParticleTexture>;
      };
   texture EmitterTexture <string Name = "";>;	
   sampler EmitterSampler=sampler_state 
      {
 	Texture=<EmitterTexture>;
      };

//--------------
// structs 
//--------------
   struct InPut
     {
 	float2 UV:TEXCOORD0; 
        float2 Index:TEXCOORD1;
        float2 Texture:TEXCOORD2;
     };
   struct OutPut
     {
	float4 Pos:POSITION; 
 	float4 Tex0:TEXCOORD0;
 	float2 Tex1:TEXCOORD1;
	float3 Frame:TEXCOORD2;
	float4 Proj:TEXCOORD3;
 	float4 ParticleColor:COLOR0;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	float4 VPos=ParticlePosition[IN.Index.x];
	float4 VColor=ParticleColor[IN.Index.x];
	float3 View=VPos-ViewInv[3].xyz;
	float Zshift=1+(length(View)*ZshiftScale);
   	float DSin,DCos,DSin2;
	float Angle=(IN.Index.y*Rotation.x)+(time*Rotation.y);
    	sincos(Angle,DSin,DCos);
 	float3 Scale=mul(float3(mul(float2(IN.UV.x-0.5f,(IN.UV.y-0.5f)*IN.Texture.y),float2x2(DCos,-DSin,DSin,DCos))*VPos.w*Zshift,0),lerp(EmitterMat,ParticleMat,IN.Texture.x));
	VPos +=(sin(IN.Index.y*Sinw.w+(time*Cosw.w)))*Sinw*VColor.w;
	VPos +=(cos(IN.Index.y*Sinw.w+(time*Cosw.w)))*Cosw*VColor.w;
	OUT.Pos=mul(float4(VPos+Scale,1),ViewProj);
	float2 UV=float2(IN.UV.x,1-IN.UV.y)/Animation;
	float FrameTime=(VColor.w*Animation.w)*Animation.z;
 	OUT.Tex0.xy=UV+(float2(int(FrameTime),int(FrameTime/Animation.x))/Animation);
	FrameTime +=1;
 	OUT.Tex0.zw=UV+(float2(int(FrameTime),int(FrameTime/Animation.x))/Animation);
	OUT.Tex1=IN.UV;
	OUT.Frame=float3(FrameTime-floor(FrameTime),IN.Texture.x,lerp(AlphaToSurface.x,AlphaToSurface.y,IN.Texture.x));
	float2 Alpha=(1-pow(1-VColor.ww,AlphaMultiplier.xz))*(1-pow(VColor.ww,AlphaMultiplier.yw));
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	float ViewVecL=length(View);
	float3 FogDist=saturate(float3(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),exp(-((VPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	float Fog=1-saturate((FogDist.z*FogDist.y)+FogDist.x);
	float4 Color=float4(VColor.xyz,lerp(Alpha.x,Alpha.y,IN.Texture.x)*Fog);
	float3 WPos=VPos+Scale;
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
	Light +=AmbientColor+LightColor;
	OUT.ParticleColor=lerp(Color*Intensity.xxxy,Color*Intensity.zzzw,IN.Texture.x);
	OUT.ParticleColor.xyz *=Light;
	return OUT;
     }

//--------------
// pixel shader
//--------------
    float4 PS(OutPut IN)  : COLOR
     {
	float4 Particle=lerp(tex2D(EmitterSampler,IN.Tex1.xy),lerp(tex2D(ParticleSampler,IN.Tex0.xy),tex2D(ParticleSampler,IN.Tex0.zw),IN.Frame.x),IN.Frame.y)*IN.ParticleColor;
	Particle.w *=saturate((tex2D(DepthSampler,((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy).y-IN.Proj.w)*EdgeSoftness);
	Particle.xyz=lerp(Particle.xyz+(Particle.www*IN.Frame.z),float3(0.5,0.5,0),Blocker);
	return Particle;
     }

//--------------
// techniques   
//--------------
   technique Particles
      {
 	pass p0
      {		
	vertexShader= compile vs_3_0 VS();
 	pixelShader = compile ps_3_0 PS();
	AlphaBlendEnable=true;
	SrcBlend=SRCALPHA;
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }