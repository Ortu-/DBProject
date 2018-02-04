//====================================================
// Water
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

#define EnableReflection 1
#define EnableDetailMap 1
#define EnableSpecular 1
#define EnableChromaticAberration 1

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
   float3 WaterIndex1[25];
   float4 WaterIndex2[50];
   float2 WaterIndex3[15];
   float4 WaterIndex4[15];
   float3 WaterSize;
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
	MagFilter=Linear;
	MinFilter=Point;
	MipFilter=None;
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
 	float2 Tex1:TEXCOORD0;
 	float2 Tex2:TEXCOORD1;
 	float2 Index1:TEXCOORD2;
   	float2 Index2:TEXCOORD3;
 	float2 Index3:TEXCOORD4;
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
    	float ViewDis:COLOR0;
     };
   struct In_UnderWater
     {
        float4 Pos:POSITION;
 	float2 Tex1:TEXCOORD0;
 	float2 Tex2:TEXCOORD1;
 	float2 Index1:TEXCOORD2;
   	float2 Index2:TEXCOORD3;
 	float2 Index3:TEXCOORD4;
     };
   struct Out_UnderWater
     {
 	float4 Pos:POSITION;
	float4 Tex1:TEXCOORD0; 
 	float4 Tex2:TEXCOORD1; 
    	float4 Proj:TEXCOORD2;
    	float ViewDis:COLOR0;
     };

//--------------
// vertex shader
//--------------
   Out_AboveWater VS_AboveWater(In_AboveWater IN) 
     {
 	Out_AboveWater OUT;
	float3 NewPos=(IN.Pos.xyz*WaterSize.z)+WaterIndex1[IN.Index1.x].xyz;
	float2 NewUv=(NewPos.xz/WaterTileSize.xy);
	OUT.Tex1=float4(NewUv*WaterScale.x,NewUv*WaterScale.y)+(time*WaterSpeed);
	OUT.Tex2=float4(NewUv*DetailScale.x,NewUv*DetailScale.y)+(time*DetailSpeed);
	float MaxUvOffset=abs(IN.Tex1.y)*WaterIndex2[IN.Index1.y].z*abs(IN.Tex1.x);
	float ClampUvOffset=saturate(WaterIndex2[IN.Index1.y].y+(WaterIndex4[IN.Index2.x].x+WaterIndex4[IN.Index2.y].y));
	float FlipUvOffset=saturate(WaterIndex2[IN.Index1.y].x-(WaterIndex4[IN.Index2.x].z+WaterIndex4[IN.Index2.y].w));
	float2 UvOffset1=(float2(-1*MaxUvOffset,0)+(float2(lerp(IN.Tex1.x,-IN.Tex1.x,FlipUvOffset),IN.Tex1.y)*ClampUvOffset)*WaterIndex3[IN.Index3.x].y)/WaterSize.xy;
	float2 UvOffset2=(float2(1*MaxUvOffset,0)+(float2(lerp(IN.Tex2.x,-IN.Tex2.x,FlipUvOffset),IN.Tex2.y)*ClampUvOffset)*WaterIndex3[IN.Index3.x].y)/WaterSize.xy;
	float Height1=tex2Dlod(WaterHSampler,float4(OUT.Tex1.xy+(UvOffset1*WaterScale.x),0,0)).w+tex2Dlod(WaterHSampler,float4(OUT.Tex1.zw+(UvOffset1*WaterScale.y),0,0)).w-1;
	float Height2=tex2Dlod(WaterHSampler,float4(OUT.Tex1.xy+(UvOffset2*WaterScale.x),0,0)).w+tex2Dlod(WaterHSampler,float4(OUT.Tex1.zw+(UvOffset2*WaterScale.y),0,0)).w-1;
	float LerpHeight=saturate(WaterIndex2[IN.Index1.y].w+WaterIndex3[IN.Index3.x].x);
	OUT.ViewDis=1-pow(saturate(length(ViewInv[3].xyz-NewPos.xyz)/WaterHeight.w),2);
	NewPos.y=WaterHeight.x+(lerp(tex2Dlod(WaterHSampler,float4(OUT.Tex1.xy,0,0)).w+tex2Dlod(WaterHSampler,float4(OUT.Tex1.zw,0,0)).w-1,lerp(Height1,Height2,0.5),LerpHeight)*WaterHeight.y*OUT.ViewDis);
	OUT.Pos=mul(float4(NewPos,IN.Pos.w),ViewProj);
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
	float3 NewPos=(IN.Pos.xyz*WaterSize.z)+WaterIndex1[IN.Index1.x].xyz;
	float2 NewUv=(NewPos.xz/WaterTileSize.xy);
	OUT.Tex1=float4(NewUv*WaterScale.x,NewUv*WaterScale.y)+(time*WaterSpeed);
	OUT.Tex2=float4(NewUv*DetailScale.x,NewUv*DetailScale.y)+(time*DetailSpeed);
	float MaxUvOffset=abs(IN.Tex1.y)*WaterIndex2[IN.Index1.y].z*abs(IN.Tex1.x);
	float ClampUvOffset=saturate(WaterIndex2[IN.Index1.y].y+(WaterIndex4[IN.Index2.x].x+WaterIndex4[IN.Index2.y].y));
	float FlipUvOffset=saturate(WaterIndex2[IN.Index1.y].x-(WaterIndex4[IN.Index2.x].z+WaterIndex4[IN.Index2.y].w));
	float2 UvOffset1=(float2(-1*MaxUvOffset,0)+(float2(lerp(IN.Tex1.x,-IN.Tex1.x,FlipUvOffset),IN.Tex1.y)*ClampUvOffset)*WaterIndex3[IN.Index3.x].y)/WaterSize.xy;
	float2 UvOffset2=(float2(1*MaxUvOffset,0)+(float2(lerp(IN.Tex2.x,-IN.Tex2.x,FlipUvOffset),IN.Tex2.y)*ClampUvOffset)*WaterIndex3[IN.Index3.x].y)/WaterSize.xy;
	float Height1=tex2Dlod(WaterSampler,float4(OUT.Tex1.xy+(UvOffset1*WaterScale.x),0,0)).w+tex2Dlod(WaterSampler,float4(OUT.Tex1.zw+(UvOffset1*WaterScale.y),0,0)).w-1;
	float Height2=tex2Dlod(WaterSampler,float4(OUT.Tex1.xy+(UvOffset2*WaterScale.x),0,0)).w+tex2Dlod(WaterSampler,float4(OUT.Tex1.zw+(UvOffset2*WaterScale.y),0,0)).w-1;
	float LerpHeight=saturate(WaterIndex2[IN.Index1.y].w+WaterIndex3[IN.Index3.x].x);
	OUT.ViewDis=1-pow(saturate(length(ViewInv[3].xz-NewPos.xz)/WaterHeight.w),3);
	NewPos.y=WaterHeight.x+(lerp(tex2Dlod(WaterSampler,float4(OUT.Tex1.xy,0,0)).w+tex2Dlod(WaterSampler,float4(OUT.Tex1.zw,0,0)).w-1,lerp(Height1,Height2,0.5),LerpHeight)*WaterHeight.y*OUT.ViewDis);
	OUT.Pos=mul(float4(NewPos,IN.Pos.w),ViewProj);
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
	#if EnableDetailMap== 1
	 NormalMap.xyz=lerp(NormalMap.xyz,tex2D(DetailSampler,IN.Tex2+(NormalMap*0.2f))*2,DetailBump*IN.ViewDis);
	#endif
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
	#if EnableChromaticAberration== 1
	 float3 Refraction;
	 Refraction.x=tex2D(RefractSampler,ViewProj+(NormalMap*1.2f)).x;
	 Refraction.y=tex2D(RefractSampler,ViewProj+NormalMap).y;
	 Refraction.z=tex2D(RefractSampler,ViewProj+(NormalMap/1.2f)).z;
	#else
	 float3 Refraction=tex2D(RefractSampler,ViewProj+NormalMap);
	#endif
	float ViewVecL=length(IN.ViewPos.xyz);
	Refraction=lerp(Refraction,WaterFogColor.xyz,saturate(ViewVecL/WaterFogColor.w));
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
	#if EnableDetailMap== 1
	 NormalMap=lerp(NormalMap,tex2D(DetailSampler,IN.Tex2+(NormalMap*0.2f))*2,DetailBump*IN.ViewDis);
	#endif
	NormalMap=normalize(NormalMap-1);
	NormalMap.xy *=WaterBump;
        NormalMap.xy *=saturate(tex2D(DepthSampler,ViewProj+NormalMap).y-IN.Proj.w);
	#if EnableChromaticAberration== 1
	 float3 Refraction;
	 Refraction.x=tex2D(RefractSampler,ViewProj+(NormalMap*1.1f)).x;
	 Refraction.y=tex2D(RefractSampler,ViewProj+NormalMap).y;
	 Refraction.z=tex2D(RefractSampler,ViewProj+(NormalMap/1.1f)).z;
	#else
	 float3 Refraction=tex2D(RefractSampler,ViewProj+NormalMap);
	#endif
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
