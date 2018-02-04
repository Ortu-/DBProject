//====================================================
// Diffuse Alpha
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
   float LightFactor=0.5;
   float3 AmbientColor;
   float3 LightColor;
   float3 LightDirection;
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
   texture BaseTexture <string Name="";>;	
   sampler BaseSampler=sampler_state 
      {
 	texture=<BaseTexture>;
      };

//--------------
// structs 
//--------------
   struct InPut
     {
        float4 Pos:POSITION;
 	float2 Tex:TEXCOORD;
	float3 Normal:NORMAL;
     };
   struct OutPut
     {
 	float4 Pos:POSITION;
   	float2 Tex:TEXCOORD0;
	float4 Proj:TEXCOORD1;
	float4 Light1:COLOR0;
	float3 Light2:COLOR1;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
 	OUT.Tex=IN.Tex;
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	float3 WPos=mul(IN.Pos,World);
	float ViewVecL=length(WPos-ViewInv[3].xyz);
	float3 FogDist=saturate(float3(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	OUT.Light1.w=1-saturate((FogDist.z*FogDist.y)+FogDist.x);
	float3 NormalVec=normalize(mul(IN.Normal,World));
	float3 LightVec=WPos-LightPosition1;
	float Attenuation=1-saturate(length(LightVec)/LightPosition1.w);
	LightVec=normalize(LightVec);
	float3 LightNormal=saturate(dot(LightVec,LightNormal1)+LightNormal1.w);
	float3 LightCol=LightNormal*Attenuation*LightColor1;
	float3 Light1=LightCol;
	float3 Light2=LightCol*dot(LightVec,NormalVec);
	LightVec=WPos-LightPosition2;
	Attenuation=1-saturate(length(LightVec)/LightPosition2.w);
	LightVec=normalize(LightVec);
	LightNormal=saturate(dot(LightVec,LightNormal2)+LightNormal2.w);
	LightCol=LightNormal*Attenuation*LightColor2;
	Light1 +=LightCol;
	Light2 +=LightCol*dot(LightVec,NormalVec);
	LightVec=WPos-LightPosition3;
	Attenuation=1-saturate(length(LightVec)/LightPosition3.w);
	LightVec=normalize(LightVec);
	LightNormal=saturate(dot(LightVec,LightNormal3)+LightNormal3.w);
	LightCol=LightNormal*Attenuation*LightColor3;
	Light1 +=LightCol;
	Light2 +=LightCol*dot(LightVec,NormalVec);
	LightVec=WPos-LightPosition4;
	Attenuation=1-saturate(length(LightVec)/LightPosition4.w);
	LightVec=normalize(LightVec);
	LightNormal=saturate(dot(LightVec,LightNormal4)+LightNormal4.w);
	LightCol=LightNormal*Attenuation*LightColor4;
	Light1 +=LightCol;
	Light2 +=LightCol*dot(LightVec,NormalVec);
	LightVec=WPos-LightPosition5;
	Attenuation=1-saturate(length(LightVec)/LightPosition5.w);
	LightVec=normalize(LightVec);
	LightNormal=saturate(dot(LightVec,LightNormal5)+LightNormal5.w);
	LightCol=LightNormal*Attenuation*LightColor5;
	Light1 +=LightCol;
	Light2 +=LightCol*dot(LightVec,NormalVec);
	OUT.Light1.xyz=AmbientColor+Light1+LightColor;
	OUT.Light2=AmbientColor+Light2+(LightColor*dot(-LightDirection,NormalVec));
	return OUT;
     }   

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
	clip(tex2D(DepthSampler,((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy).y-IN.Proj.w);
	float4 Diffuse=tex2D(BaseSampler,IN.Tex);
	return float4(Diffuse*lerp(IN.Light1.xyz,IN.Light2,Diffuse.w*LightFactor),Diffuse.w*IN.Light1.w);
     }
   float4 PS_Blocker(OutPut IN) : COLOR
     {
	clip(tex2D(DepthSampler,((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy).y-IN.Proj.w);
	return float4(0.5f,0.5f,0,tex2D(BaseSampler,IN.Tex).w*IN.Light1.w);
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
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }