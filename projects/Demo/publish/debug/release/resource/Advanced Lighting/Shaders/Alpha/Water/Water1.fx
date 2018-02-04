//====================================================
// Water
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

#define EnableReflection 1
#define EnableSpecular 1

//--------------
// un-tweaks
//--------------
   matrix ViewProj:ViewProjection;
   matrix ViewInv:ViewInverse;
   float time:Time;

//--------------
// tweaks
//--------------
   float4 ViewSize;
   float4 WaterTileSize;
   float4 WaterHeight;
   float2 WaterScale={2.5,3.5};
   float4 WaterSpeed={-0.02f,-0.02f,-0.03f,0.02f};
   float WaterBump=0.075f;
   float2 DetailScale={40,60};
   float4 DetailSpeed={-0.04f,-0.04f,0.008f,-0.006f};
   float DetailBump=0.22f;
   float3x3 TBN={float3(1,0,0),float3(0,0,1),float3(0,1,0)};
   float3 WaterColor;
   float4 WaterFogColor;
   float3 ReflectColor;
   float3 LightPosition;
   float3 SpecularColor;
   float SpecularPow=150.0f;
   float4 FogRange;
   float3 FogColor1;
   float3 FogColor2;
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
   texture WaterTexture <string Name=""; >; 
   sampler WaterSampler=sampler_state 
     {
	Texture=<WaterTexture>;
     };
   texture WaterHTexture <string Name=""; >; 
   sampler WaterHSampler=sampler_state 
     {
	Texture=<WaterHTexture>;
     };
   texture DetailTexture <string Name=""; >; 
   sampler DetailSampler=sampler_state 
     {
	Texture=<DetailTexture>;
     };
   texture RefractTexture <string Name=""; >;	
   sampler RefractSampler=sampler_state
     {
	Texture=<RefractTexture>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
     };
   texture ReflectTexture <string Name=""; >;	
   sampler ReflectSampler=sampler_state
     {
	Texture=<ReflectTexture>;
   	ADDRESSU=CLAMP;
   	ADDRESSV=CLAMP;
   	ADDRESSW=CLAMP;
     };

//--------------
// structs 
//--------------
   struct In_AboveWater
     {
        float4 Pos:POSITION;
 	float Index:TEXCOORD0;
     };
   struct Out_AboveWater
     {
 	float4 Pos:POSITION;
	float4 Tex1:TEXCOORD0; 
 	float4 Tex2:TEXCOORD1; 
    	float4 Proj:TEXCOORD2;
    	float4 ReflProj:TEXCOORD3;
	float3 WPos:TEXCOORD4;
	float3 ViewPos:TEXCOORD5;
	float3 ViewVec:TEXCOORD6;
	float3 LightVec:TEXCOORD7;
     };
   struct In_UnderWater
     {
        float4 Pos:POSITION;
 	float Index:TEXCOORD0;
     };
   struct Out_UnderWater
     {
 	float4 Pos:POSITION;
	float4 Tex1:TEXCOORD0; 
 	float4 Tex2:TEXCOORD1; 
    	float4 Proj:TEXCOORD2;
     };

//--------------
// vertex shader
//--------------
   Out_AboveWater VS_AboveWater(In_AboveWater IN) 
     {
 	Out_AboveWater OUT;
	float3 NewPos;
	NewPos.xz=(IN.Pos.xz*lerp(WaterHeight.z,WaterHeight.w/51.8f,IN.Index))+ViewInv[3].xz;
	NewPos.y=WaterHeight.x;
	float2 NewUv=(NewPos.xz/WaterTileSize.xy);
	OUT.Tex1=float4(NewUv*WaterScale.x,NewUv*WaterScale.y)+(time*WaterSpeed);
	OUT.Tex2=float4(NewUv*DetailScale.x,NewUv*DetailScale.y)+(time*DetailSpeed);
	OUT.Pos=mul(float4(NewPos,1),ViewProj);
 	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
  	OUT.ReflProj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w+OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.w);
 	OUT.ReflProj.y=OUT.ReflProj.y-1.0f;
	OUT.WPos=NewPos;
	float3 ViewVec=ViewInv[3].xyz-NewPos;
	OUT.ViewPos=ViewVec;
	OUT.ViewVec=mul(ViewVec,TBN);
	float3 LightPos=LightPosition-NewPos;
	OUT.LightVec=mul(LightPos,TBN);
	return OUT;
     }
   Out_UnderWater VS_UnderWater(In_UnderWater IN) 
     {
 	Out_UnderWater OUT;
	float3 NewPos;
	NewPos.xz=(IN.Pos.xz*lerp(WaterHeight.z,WaterHeight.w,IN.Index))+ViewInv[3].xz;
	NewPos.y=WaterHeight.x;
	float2 NewUv=(NewPos.xz/WaterTileSize.xy);
	OUT.Tex1=float4(NewUv*WaterScale.x,NewUv*WaterScale.y)+(time*WaterSpeed);
	OUT.Tex2=float4(NewUv*DetailScale.x,NewUv*DetailScale.y)+(time*DetailSpeed);
	OUT.Pos=mul(float4(NewPos,1),ViewProj);
 	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS_AboveWater(Out_AboveWater IN) : COLOR
     {
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
        float Depth=tex2D(DepthSampler,ViewProj).y-IN.Proj.w;
	clip(Depth);
	float4 NormalMap=tex2D(WaterSampler,IN.Tex1.xy)+tex2D(WaterSampler,IN.Tex1.zw);
	float Foam=tex2D(DetailSampler,IN.Tex2.zw+(NormalMap*0.2f)).w*((1-saturate(Depth*0.01f))+pow(NormalMap.w*0.5,8));
	NormalMap.xyz=normalize(NormalMap.xyz-1);
	float3 LightVec=normalize(IN.LightVec);
	float Light=1-dot(NormalMap,LightVec);
	float3 View=normalize(IN.ViewVec);
	#if EnableReflection== 1
	 float Fresnel=saturate(exp(-dot(NormalMap,View)*7));
  	#endif
	#if EnableSpecular== 1
	 float Specular=pow(saturate(dot(-View,reflect(LightVec,NormalMap.xyz))),SpecularPow);
  	#endif
	NormalMap.xy *=WaterBump;
	#if EnableReflection== 1
	 float3 Reflection=tex2D(ReflectSampler,(IN.ReflProj.xy/IN.ReflProj.z)+NormalMap)*ReflectColor;
  	#endif
        NormalMap.xy *=saturate(tex2D(DepthSampler,ViewProj+NormalMap).y-IN.Proj.w)*saturate(Depth*0.0025f);
	float ViewVecL=length(IN.ViewPos);
	float3 Refraction=lerp(tex2D(RefractSampler,ViewProj+NormalMap),WaterFogColor.xyz,saturate(ViewVecL/WaterFogColor.w));
	Refraction=lerp(Refraction,WaterColor,(NormalMap.w*0.333f)*Light);
	LightVec=IN.WPos-LightPosition;
	float4 FogDist=saturate(float4(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),length(LightVec)/(FogRange.x*2),exp(-((IN.WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	float4 Fog=float4(lerp(HeightFogColor.xyz,lerp(FogColor2,FogColor1,FogDist.z),FogDist.x),saturate((FogDist.w*FogDist.y)+FogDist.x));
	#if EnableReflection== 1
	 float3 Water=lerp(Refraction,Reflection,Fresnel);
	#else
	 float3 Water=Refraction;
	#endif
	#if EnableSpecular== 1
	 Water +=(Specular*SpecularColor);
	#endif
	return float4(lerp(Water+Foam,Fog.xyz,Fog.w),Depth*0.1f);
     }
   float4 PS_UnderWater(Out_UnderWater IN) : COLOR
     {
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
        float Depth=tex2D(DepthSampler,ViewProj).y-IN.Proj.w;
	clip(Depth);
	float3 NormalMap=tex2D(WaterSampler,IN.Tex1.xy)+tex2D(WaterSampler,IN.Tex1.zw);
	NormalMap=normalize(NormalMap-1);
	NormalMap.xy *=WaterBump;
        NormalMap.xy *=saturate(tex2D(DepthSampler,ViewProj+NormalMap).y-IN.Proj.w);
	float3 Refraction=tex2D(RefractSampler,ViewProj+NormalMap);
	return float4(Refraction,Depth*0.04f);
     }

//--------------
// techniques   
//--------------
   technique AboveWater
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS_AboveWater(); 
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
 	vertexShader = compile vs_3_0 VS_UnderWater(); 
 	pixelShader  = compile ps_3_0 PS_UnderWater();
	SrcBlend=srcalpha;
        ColorWriteEnable=7;
	CullMode=cw;
      }
      }
