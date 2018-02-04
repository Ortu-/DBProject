//====================================================
// Lens Flare
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix ViewProj:ViewProjection;
   matrix ViewInv:ViewInverse;
   matrix View:View;

//--------------
// tweaks
//--------------
   float4 ViewSize;
   float3 LensFlarePosition[100];
   float3 LensFlareColor[100];
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
	AddressU=Border;
	AddressV=Border;
	AddressW=Border;
      };
   texture BlockerTexture <string Name = "";>;
   sampler BlockerSampler=sampler_state 
      {
	Texture=<BlockerTexture>;
	MagFilter=Point;
	MinFilter=Point;
	MipFilter=Point;
	AddressU=Border;
	AddressV=Border;
	AddressW=Border;
      };
   texture LensFlareTexture <string Name = "";>;	
   sampler LensFlareSampler=sampler_state 
      {
 	Texture=<LensFlareTexture>;
      };

//--------------
// structs 
//--------------
   struct InPut
     {
	float4 Scale:POSITION; 
     	float3 Color:NORMAL;
 	float2 UV:TEXCOORD0; 
        float2 Index:TEXCOORD1;
        float2 Offset:TEXCOORD2;
        float2 Falloff:TEXCOORD3;
        float2 ViewFade:TEXCOORD4;
        float2 Atlas:TEXCOORD5;
     };
   struct OutPut
     {
	float4 OPos:POSITION;
 	float2 Tex:TEXCOORD0;
        float2 Proj:TEXCOORD1;
	float4 Color:COLOR0;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	float3 VPos=LensFlarePosition[IN.Index.x];
	float3 VColor=LensFlareColor[IN.Index.x];
	float4 Proj=mul(float4(VPos,1),ViewProj);
	Proj.xy=((float2(Proj.x*0.5+0.5*Proj.w,0.5*Proj.w-Proj.y*0.5)/Proj.w)*ViewSize.zw)+ViewSize.xy;
	float Occlude=saturate(tex2Dlod(DepthSampler,float4(Proj.xy,0,0)).y-Proj.z);
	float3 ViewVec=VPos-ViewInv[3].xyz;
	float ViewVecL=length(ViewVec);
	float3 FogDist=saturate(float3(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),exp(-((VPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	float Fog=1-saturate((FogDist.z*FogDist.y)+FogDist.x)*saturate(IN.Falloff.x);
	float Falloff=1-pow(saturate(ViewVecL/IN.Falloff.x),2)*saturate(IN.Falloff.x);
	float3 ViewNor=-mul(normalize(ViewVec),View);
	float ViewDir=saturate((dot(ViewNor,float3(0,0,-1))-0.55f)*2);
	OUT.Color.xyz=IN.Color*VColor*(1-(ViewDir*IN.ViewFade.x))*lerp(1,ViewDir-dot((IN.UV-0.5f)*IN.ViewFade.y,-ViewNor.xy)*ViewDir,saturate(IN.ViewFade.y))*Falloff*Fog*Occlude;
	OUT.Color.w=IN.Falloff.y*saturate(dot(OUT.Color.xyz,1));
  	float DSin,DCos,DSin2;
    	sincos((ViewNor.x-ViewNor.y)*IN.Index.y,DSin,DCos);
	float ViewSize=lerp(ViewDir,(1.0f/IN.Scale.z)+(1-ViewDir),saturate(IN.Scale.z))*abs(IN.Scale.z);
	ViewNor *=ViewVecL*IN.Offset.x;
	ViewVec=(VPos+mul(float3(ViewNor.xy,0),ViewInv))-ViewInv[3].xyz;
	float Zshift=length(ViewVec);
	Zshift=(Zshift-(max(Zshift-IN.Offset.y,0)*saturate(IN.Offset.y)))*ViewSize*ceil(Occlude);
	OUT.OPos=mul(float4(VPos+mul(float3((mul(IN.UV-0.5,float2x2(DCos,-DSin,DSin,DCos))*IN.Scale.xy*Zshift)+ViewNor.xy,0),ViewInv),1),ViewProj);
	OUT.Tex=(IN.UV/4)+IN.Atlas;
	OUT.Proj=Proj.xy;
	return OUT;
     }
   OutPut VS_Blocker(InPut IN) 
     {
 	OutPut OUT;
	float3 VPos=LensFlarePosition[IN.Index.x];
	float4 Proj=mul(float4(VPos,1),ViewProj);
	Proj.xy=((float2(Proj.x*0.5+0.5*Proj.w,0.5*Proj.w-Proj.y*0.5)/Proj.w)*ViewSize.zw)+ViewSize.xy;
	float Occlude=saturate(tex2Dlod(DepthSampler,float4(Proj.xy,0,0)).y-Proj.z);
	float3 ViewVec=VPos-ViewInv[3].xyz;
	float Zshift=length(ViewVec)*0.015f*Occlude;
	OUT.OPos=mul(float4(VPos+mul(float3((IN.UV-0.5)*Zshift,0),ViewInv),1),ViewProj);
	OUT.Tex=0;
	OUT.Proj=0;
	OUT.Color=0;
	return OUT;
     }

//--------------
// pixel shader
//--------------
    float4 PS(OutPut IN)  : COLOR
     {
	float4 LensFlare=tex2D(LensFlareSampler,IN.Tex)*(tex2D(BlockerSampler,IN.Proj).z*2);
	return float4((LensFlare.xyz*IN.Color.xyz)+(LensFlare.w*IN.Color.w),1);
     }
    float4 PS_Blocker(OutPut IN)  : COLOR
     {
	return float4(0,0,0.5,0);
     }

//--------------
// techniques   
//--------------
   technique Diffuse
      {
 	pass p0
      {		
	vertexShader= compile vs_3_0 VS();
 	pixelShader = compile ps_3_0 PS();
	AlphaBlendEnable=true;
	SrcBlend=srcalpha;
 	DestBlend=one;
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
   technique Blocker
      {
 	pass p0
      {		
	vertexShader= compile vs_3_0 VS_Blocker();
 	pixelShader = compile ps_3_0 PS_Blocker();
	AlphaBlendEnable=false;
	zwriteenable=true;
        ColorWriteEnable=4;
      }
      }