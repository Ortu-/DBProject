//====================================================
// Point Light
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
   float AttenuationPower;
   float SpecularPower;
   float2 ShadowSize;
   float4 ShadowOffset;
   float3 ShadowPosition;
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
   sampler BlendMaskSampler=sampler_state
      {
	Texture=<BlendMaskTexture>;
	MagFilter=Linear;
	MinFilter=Point;
	MipFilter=None;
      };
   texture DepthMap1Texture <string Name = "";>; 
   sampler DepthMap1Sampler=sampler_state
      {
	Texture=<DepthMap1Texture>;
     	ADDRESSU=CLAMP;
        ADDRESSV=CLAMP;
        ADDRESSW=CLAMP;
      };
   texture DepthMap2Texture <string Name = "";>; 
   sampler DepthMap2Sampler=sampler_state
      {
	Texture=<DepthMap2Texture>;
     	ADDRESSU=CLAMP;
        ADDRESSV=CLAMP;
        ADDRESSW=CLAMP;
      };
   texture DepthMap3Texture <string Name = "";>; 
   sampler DepthMap3Sampler=sampler_state
      {
	Texture=<DepthMap3Texture>;
     	ADDRESSU=CLAMP;
        ADDRESSV=CLAMP;
        ADDRESSW=CLAMP;
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
	float3 ViewVec=normalize(IN.VPos)*tex2D(PositionSampler,ViewProj).x;
	float3 WPos=ViewInv[3].xyz+ViewVec;
	float3 LightVec=WPos-LightPosition;
	float Attenuation=1-pow(length(LightVec/LightRange),AttenuationPower);
	clip(1-Attenuation);
	if(Attenuation>0)
	 {
	  float4 Geometry=tex2Dlod(GeometrySampler,float4(ViewProj,0,0));
	  float4 Diffuse=floor(Geometry/65025);
	  float4 Normals=floor((Geometry/255)-(Diffuse*255));
	  Diffuse *=0.00394f;
	  Normals *=0.00394f;
	  Normals.xyz=normalize(Normals.xyz*2-1);
	  float ViewVecL=length(ViewVec);
	  float3 FogDist=saturate(float3(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	  float Fog=1-saturate((FogDist.z*FogDist.y)+FogDist.x);
	  LightVec=normalize(-LightVec);
  	  ViewVec=normalize(ViewVec);
	  float Normal=saturate(dot(Normals,LightVec));
	  Normal +=pow(saturate(dot(ViewVec,reflect(LightVec,Normals))),Diffuse.w*SpecularPower)*Normals.w*2;
  	  return float4(Diffuse*Normal*LightColor*Attenuation*Fog,1);
         }
	else discard;
     }
   float4 PS_PointVsm(OutPut IN)  : COLOR
     {	
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
	float3 ViewVec=normalize(IN.VPos)*tex2D(PositionSampler,ViewProj).x;
	float3 WPos=ViewInv[3].xyz+ViewVec;
	float3 LightVec=WPos-LightPosition;
	float Attenuation=1-pow(length(LightVec/LightRange),AttenuationPower);
	clip(1-Attenuation);
	float4 BlendMaskP=texCUBE(BlendMaskSampler,LightVec);
	float4 BlendMaskN=texCUBE(BlendMaskSampler,-LightVec);
	if(Attenuation>0)
	 {
	  float3 ShadowVec=WPos-ShadowPosition;
	  float Depth=length(ShadowVec/LightRange);
	  float4 ShadowProj;
	  float2 DepthMapP,DepthMapN;
	  if(BlendMaskP.w>0) 
	   {
	    DepthMapP=tex2Dlod(DepthMap1Sampler,float4((((ShadowVec.zy/ShadowVec.x)*float2(-0.5f,-0.5f)+0.5f)*ShadowSize)+ShadowOffset.xy,0,0))*BlendMaskP.x;
	    DepthMapP +=tex2Dlod(DepthMap1Sampler,float4((((ShadowVec.xz/ShadowVec.y)*float2(0.5f,0.5f)+0.5f)*ShadowSize)+ShadowOffset.zw,0,0))*BlendMaskP.y;
	    DepthMapP +=tex2Dlod(DepthMap2Sampler,float4((((ShadowVec.xy/ShadowVec.z)*float2(0.5f,-0.5f)+0.5f)*ShadowSize)+ShadowOffset.xy,0,0))*BlendMaskP.z;
	   }
	  if(BlendMaskN.w>0) 
           {
	    DepthMapN=tex2Dlod(DepthMap2Sampler,float4((((ShadowVec.zy/ShadowVec.x)*float2(-0.5f,0.5f)+0.5f)*ShadowSize)+ShadowOffset.zw,0,0))*BlendMaskN.x;
	    DepthMapN +=tex2Dlod(DepthMap3Sampler,float4((((ShadowVec.xz/ShadowVec.y)*float2(-0.5f,0.5f)+0.5f)*ShadowSize)+ShadowOffset.xy,0,0))*BlendMaskN.y;
	    DepthMapN +=tex2Dlod(DepthMap3Sampler,float4((((ShadowVec.xy/ShadowVec.z)*float2(0.5f,0.5f)+0.5f)*ShadowSize)+ShadowOffset.zw,0,0))*BlendMaskN.z;
	   }
	  float2 Moments=(DepthMapP*BlendMaskP.w)+(DepthMapN*BlendMaskN.w);
	  float Mue=Moments.x-Depth;
	  float variance=Moments.y-(Moments.x*Moments.x);
	  variance /=variance+Mue*Mue;
	  float ShadowMap=(Depth<Moments.x ? 1:smoothstep(0.2f,1,variance));
	  if(ShadowMap>0)
	   {
	    float4 Geometry=tex2Dlod(GeometrySampler,float4(ViewProj,0,0));
	    float4 Diffuse=floor(Geometry/65025);
	    float4 Normals=floor((Geometry/255)-(Diffuse*255));
	    Diffuse *=0.00394f;
	    Normals *=0.00394f;
	    Normals.xyz=normalize(Normals.xyz*2-1);
	    float ViewVecL=length(ViewVec);
	    float3 FogDist=saturate(float3(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	    float Fog=1-saturate((FogDist.z*FogDist.y)+FogDist.x);
	    LightVec=normalize(-LightVec);
  	    ViewVec=normalize(ViewVec);
  	    float Normal=saturate(dot(Normals,LightVec));
	    Normal +=pow(saturate(dot(ViewVec,reflect(LightVec,Normals))),Diffuse.w*SpecularPower)*Normals.w*2;
  	    return float4(Diffuse*Normal*LightColor*Attenuation*ShadowMap*Fog,1);
           }
	  else discard;
         }
	else discard;
     }
    float4 PS_PointEvsm(OutPut IN)  : COLOR
     {	
	float2 ViewProj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
	float3 ViewVec=normalize(IN.VPos)*tex2D(PositionSampler,ViewProj).x;
	float3 WPos=ViewInv[3].xyz+ViewVec;
	float3 LightVec=WPos-LightPosition;
	float Attenuation=1-pow(length(LightVec/LightRange),AttenuationPower);
	clip(1-Attenuation);
	float4 BlendMaskP=texCUBE(BlendMaskSampler,LightVec);
	float4 BlendMaskN=texCUBE(BlendMaskSampler,-LightVec);
	if(Attenuation>0)
	 {
	  float3 ShadowVec=WPos-ShadowPosition;
	  float Depth=length(ShadowVec/LightRange);
	  float2 DepthExp=exp(float2(Depth,1-Depth)*7-3.5f);
	  float4 DepthMapP,DepthMapN;
	  if(BlendMaskP.w>0) 
	   {
	    DepthMapP=tex2Dlod(DepthMap1Sampler,float4((((ShadowVec.zy/ShadowVec.x)*float2(-0.5f,-0.5f)+0.5f)*ShadowSize)+ShadowOffset.xy,0,0))*BlendMaskP.x;
	    DepthMapP +=tex2Dlod(DepthMap1Sampler,float4((((ShadowVec.xz/ShadowVec.y)*float2(0.5f,0.5f)+0.5f)*ShadowSize)+ShadowOffset.zw,0,0))*BlendMaskP.y;
	    DepthMapP +=tex2Dlod(DepthMap2Sampler,float4((((ShadowVec.xy/ShadowVec.z)*float2(0.5f,-0.5f)+0.5f)*ShadowSize)+ShadowOffset.xy,0,0))*BlendMaskP.z;
	   }
	  if(BlendMaskN.w>0) 
           {
	    DepthMapN=tex2Dlod(DepthMap2Sampler,float4((((ShadowVec.zy/ShadowVec.x)*float2(-0.5f,0.5f)+0.5f)*ShadowSize)+ShadowOffset.zw,0,0))*BlendMaskN.x;
	    DepthMapN +=tex2Dlod(DepthMap3Sampler,float4((((ShadowVec.xz/ShadowVec.y)*float2(-0.5f,0.5f)+0.5f)*ShadowSize)+ShadowOffset.xy,0,0))*BlendMaskN.y;
	    DepthMapN +=tex2Dlod(DepthMap3Sampler,float4((((ShadowVec.xy/ShadowVec.z)*float2(0.5f,0.5f)+0.5f)*ShadowSize)+ShadowOffset.zw,0,0))*BlendMaskN.z;
	   }
	  float4 Moments=(DepthMapP*BlendMaskP.w)+(DepthMapN*BlendMaskN.w);
	  float2 Mue=Moments.xy-DepthExp;
	  float2 variance=Moments.zw-(Moments.xy*Moments.xy);
	  variance /=variance+Mue*Mue;
	  float ShadowMap=smoothstep(0.2f,1,min((DepthExp.x<Moments.x ? 1:variance.x),(DepthExp.y>Moments.y ? 1:variance.y)));
	  if(ShadowMap>0)
	   {
	    float4 Geometry=tex2Dlod(GeometrySampler,float4(ViewProj,0,0));
	    float4 Diffuse=floor(Geometry/65025);
	    float4 Normals=floor((Geometry/255)-(Diffuse*255));
	    Diffuse *=0.00394f;
	    Normals *=0.00394f;
	    Normals.xyz=normalize(Normals.xyz*2-1);
	    float ViewVecL=length(ViewVec);
	    float3 FogDist=saturate(float3(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	    float Fog=1-saturate((FogDist.z*FogDist.y)+FogDist.x);
	    LightVec=normalize(-LightVec);
  	    ViewVec=normalize(ViewVec);
  	    float Normal=saturate(dot(Normals,LightVec));
	    Normal +=pow(saturate(dot(ViewVec,reflect(LightVec,Normals))),Diffuse.w*SpecularPower)*Normals.w*2;
  	    return float4(Diffuse*Normal*LightColor*Attenuation*ShadowMap*Fog,1);
           }
	  else discard;
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
   technique PointVsm
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS_PointVsm();
	AlphaBlendEnable=True;
 	SrcBlend=One;
 	DestBlend=One;
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
   technique PointEvsm
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS_PointEvsm();
	AlphaBlendEnable=True;
 	SrcBlend=One;
 	DestBlend=One;
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }