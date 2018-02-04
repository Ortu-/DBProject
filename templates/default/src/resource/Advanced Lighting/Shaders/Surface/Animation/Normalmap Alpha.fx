//====================================================
// Normal Mapping
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection; 
   matrix World:World;    
   matrix Worldit:WorldInverseTranspose;
   matrix ViewInv:ViewInverse; 
   matrix OrthoProj;
   matrix PreviousVP;
   matrix boneMatrix[50]:BoneMatrixPalette;

//--------------
// tweaks
//--------------
   float DetailScale=5;
   float DetailBump=0.3f;
   float3 AmbientColor;
   float3 LightColor;
   float3 LightDirection;
   float3 LightPosition;
   float LightRange;
   float3 ShadowPosition;
   float2 ShadowBias;
   float4 FogRange;
   float3 FogColor1;
   float3 FogColor2;
   float3 HeightFog;
   float4 HeightFogColor;
   float ClipHeight;

//--------------
// Textures
//--------------
   texture DepthTexture <string Name = "";>;
   sampler DepthSampler=sampler_state 
      {
	Texture=<DepthTexture>;
	MagFilter=Point;
	MinFilter=Point;
	MipFilter=Point;
      };
   texture BaseTexture <string Name="";>;	
   sampler BaseSampler=sampler_state 
      {
 	texture=<BaseTexture>;
  	MagFilter=anisotropic;
	MinFilter=anisotropic;
	MipFilter=anisotropic;
        MaxAnisotropy=3;
      };
   texture NormalTexture <string Name="";>;	
   sampler NormalSampler=sampler_state 
      {
 	texture=<NormalTexture>;
      };
   texture SpecularTexture <string Name="";>;
   sampler SpecularSampler=sampler_state 
      {
	texture=<SpecularTexture>;
      };
   texture DetailTexture <string Name="";>;
   sampler DetailSampler=sampler_state 
      {
 	texture=<DetailTexture>;
      };
   texture SubSurfaceTexture <string Name="";>;
   sampler SubSurfaceSampler=sampler_state 
      {
	texture=<SubSurfaceTexture>;
      };	  

//--------------
// structs 
//--------------
   struct InPut
     {
 	float4 Pos:POSITION;
 	float2 Tex:TEXCOORD;
	float3 Normal:NORMAL;
        float4 Blendweight:TEXCOORD1;
        float4 Blendindices:TEXCOORD2; 
     };
   struct OutPut
     {
	float4 Pos:POSITION; 
   	float2 Tex:TEXCOORD0; 
   	float3 Normals:TEXCOORD1;
	float ClipY:TEXCOORD2;
	float4 Proj:TEXCOORD3;
	float4 Fog:COLOR0;
     };
   struct In_Geometry
     {
 	float4 Pos:POSITION;
 	float2 Tex:TEXCOORD;
	float3 Normal:NORMAL;
   	float3 Tangent:TANGENT;
        float4 Blendweight:TEXCOORD1;
        float4 Blendindices:TEXCOORD2; 
     };
   struct Out_Geometry
     {
	float4 Pos:POSITION; 
   	float2 Tex:TEXCOORD0; 
     	float3 TBNx1:TEXCOORD1;
     	float3 TBNx2:TEXCOORD2;
     	float3 TBNx3:TEXCOORD3;
    	float4 CurrentPos:TEXCOORD4; 
    	float4 PreviousPos:TEXCOORD5; 
		float4 Proj:TEXCOORD6;
     };
   struct In_WPosition
     {
 	float4 Pos:POSITION;
 	float2 Tex:TEXCOORD;
        float4 Blendweight:TEXCOORD1;
        float4 Blendindices:TEXCOORD2; 
     };
   struct Out_WPosition
     {
 	float4 Pos:POSITION;
    	float2 Tex:TEXCOORD0;
 	float4 WPosition:TEXCOORD1; 
	float4 Proj:TEXCOORD2;
     };
   struct In_Depth
     {
 	float4 Pos:POSITION;
 	float2 Tex:TEXCOORD;
        float4 Blendweight:TEXCOORD1;
        float4 Blendindices:TEXCOORD2; 
     };
   struct Out_Depth
     {
 	float4 Pos:POSITION; 
   	float2 Tex:TEXCOORD0;
 	float4 Depth:TEXCOORD1; 
	float4 Proj:TEXCOORD2;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
    	float3 NetPos=0,NetNormal=0;
    	for (int i = 0; i < 4; i++)
    	 {
     	  int Index=IN.Blendindices[i];
     	  float3x4 BoneMat=float3x4(boneMatrix[Index][0],boneMatrix[Index][1],boneMatrix[Index][2]);
     	  NetPos +=(mul(BoneMat,IN.Pos)+boneMatrix[Index][3].xyz)*IN.Blendweight[i];
     	  NetNormal +=mul(float3x3(BoneMat[0].xyz,BoneMat[1].xyz,BoneMat[2].xyz),IN.Normal)*IN.Blendweight[i];
    	 }
    	float4 NewPos=float4(NetPos,1);
    	float3 NewNormal=normalize(NetNormal);
	OUT.Pos=mul(NewPos,WorldVP);
 	OUT.Tex=IN.Tex;
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	OUT.Normals=normalize(mul(NetNormal,World));
	float3 WPos=mul(NetPos,World);
	OUT.ClipY=WPos.y-ClipHeight;
	float3 LightVec=WPos-LightPosition;
	float ViewVecL=length(WPos-ViewInv[3].xyz);
	float4 FogDist=saturate(float4(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),length(LightVec)/(FogRange.x*2),exp(-((WPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	OUT.Fog=float4(lerp(HeightFogColor.xyz,lerp(FogColor2,FogColor1,FogDist.z),FogDist.x),saturate((FogDist.w*FogDist.y)+FogDist.x));
	return OUT;
     }
   Out_Geometry VS_Geometry(In_Geometry IN) 
     {
 	Out_Geometry OUT;
    	float3 NetPos=0,NetNormal=0;
    	for (int i = 0; i < 4; i++)
    	 {
     	  int Index=IN.Blendindices[i];
     	  float3x4 BoneMat=float3x4(boneMatrix[Index][0],boneMatrix[Index][1],boneMatrix[Index][2]);
     	  NetPos +=(mul(BoneMat,IN.Pos)+boneMatrix[Index][3].xyz)*IN.Blendweight[i];
     	  NetNormal +=mul(float3x3(BoneMat[0].xyz,BoneMat[1].xyz,BoneMat[2].xyz),IN.Normal)*IN.Blendweight[i];
    	 }
    	float4 NewPos=float4(NetPos,1);
    	float3 NewNormal=normalize(NetNormal);
	OUT.Pos=mul(NewPos,WorldVP);
 	OUT.Tex=IN.Tex;
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	float3x3 TBN={IN.Tangent,cross(NewNormal,IN.Tangent),NewNormal};
	float3x3 wTBN=mul(TBN,Worldit);
	OUT.TBNx1=normalize(wTBN[0]);
	OUT.TBNx2=normalize(wTBN[1]);
	OUT.TBNx3=normalize(wTBN[2]);
 	OUT.CurrentPos=OUT.Pos;
	OUT.PreviousPos=mul(mul(NewPos,World),PreviousVP);
	return OUT;
     }
   Out_WPosition VS_WPosition(In_WPosition IN) 
     {
 	Out_WPosition OUT;
    	float3 NetPos=0;
    	for (int i = 0; i < 4; i++)
    	 {
     	  int Index=IN.Blendindices[i];
     	  float3x4 BoneMat=float3x4(boneMatrix[Index][0], boneMatrix[Index][1], boneMatrix[Index][2]);
     	  NetPos +=(mul(BoneMat,IN.Pos)+boneMatrix[Index][3].xyz)*IN.Blendweight[i];
    	 }
    	float4 NewPos=float4(NetPos,1);
	OUT.Pos=mul(NewPos,WorldVP);
 	OUT.Tex=IN.Tex;
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	OUT.WPosition=float4(mul(NewPos,World)-ViewInv[3].xyz,OUT.Pos.z);
	return OUT;
     }
   Out_Depth VS_DepthMap(In_Depth IN)
     {
        Out_Depth OUT;
    	float3 NetPos=0;
    	for (int i = 0; i < 4; i++)
    	 {
     	  int Index=IN.Blendindices[i];
     	  float3x4 BoneMat=float3x4(boneMatrix[Index][0], boneMatrix[Index][1], boneMatrix[Index][2]);
     	  NetPos +=(mul(BoneMat,IN.Pos)+boneMatrix[Index][3].xyz)*IN.Blendweight[i];
    	 }
    	float4 NewPos=float4(NetPos,1);
	OUT.Pos=mul(NewPos,WorldVP);
 	OUT.Tex=IN.Tex;
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	OUT.Depth=float4(ShadowPosition-mul(NewPos,World),0);
        return OUT;
     }
   Out_Depth VS_DepthMapDirectional(In_Depth IN)
     {
        Out_Depth OUT;
    	float3 NetPos=0;
    	for (int i = 0; i < 4; i++)
    	 {
     	  int Index=IN.Blendindices[i];
     	  float3x4 BoneMat=float3x4(boneMatrix[Index][0], boneMatrix[Index][1], boneMatrix[Index][2]);
     	  NetPos +=(mul(BoneMat,IN.Pos)+boneMatrix[Index][3].xyz)*IN.Blendweight[i];
    	 }
    	float4 NewPos=float4(NetPos,1);
	OUT.Pos=mul(mul(NewPos,World),OrthoProj);
 	OUT.Tex=IN.Tex; 
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	OUT.Depth=float4(mul(NewPos,World)-ShadowPosition,0);
        return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
	//clip(IN.ClipY);
  	clip(tex2D(DepthSampler,(IN.Proj.xy/IN.Proj.z)+ViewSize).w-IN.Proj.w);
	//clip(tex2D(BaseSampler,IN.Tex).w-0.2f);
   	float3 Diffuse=tex2D(BaseSampler,IN.Tex);
	return float4(lerp(Diffuse*(saturate(dot(-LightDirection,IN.Normals)*LightColor)+AmbientColor),IN.Fog,IN.Fog.w),1);
     }
   float4 PackColor(in float4 iColor1,in float4 iColor2,in float4 iColor3,in float2 iColor4)
     {
	iColor1=floor(iColor1*255);
	iColor2=floor(iColor2*255);
	iColor3.x=dot(floor(saturate(iColor3.xz)*8),float2(9,1));
	iColor3.y=dot(floor(saturate(iColor3.yw)*8),float2(9,1));
	iColor4=floor(iColor4*255);
	float oColor1=dot(float3(iColor1.x,iColor2.x,iColor3.x),float3(65536,256,1));
	float oColor2=dot(float3(iColor1.y,iColor2.y,iColor3.y),float3(65536,256,1));
	float oColor3=dot(float3(iColor1.z,iColor2.z,iColor4.x),float3(65536,256,1));
	float oColor4=dot(float3(iColor1.w,iColor2.w,iColor4.y),float3(65536,256,1));
	return float4(oColor1,oColor2,oColor3,oColor4);
     }
   float4 PS_Geometry(Out_Geometry IN) : COLOR
     {
  	clip(tex2D(DepthSampler,(IN.Proj.xy/IN.Proj.z)+ViewSize).w-IN.Proj.w);
	//clip(tex2D(BaseSampler,IN.Tex).w-0.2f);
   	float3 Diffuse=tex2D(BaseSampler,IN.Tex);
	float3 Normalmap=tex2D(NormalSampler,IN.Tex)*2-1;
	float3 Normals=saturate(0.5f+mul(Normalmap,float3x3(IN.TBNx1,IN.TBNx2,IN.TBNx3))*0.5f);
 	float3 Specular=tex2D(SpecularSampler,IN.Tex);
	float4 SubSurface=tex2D(SubSurfaceSampler,IN.Tex);
	float2 Velocity=saturate(0.5f+pow((IN.CurrentPos/IN.CurrentPos.w)-(IN.PreviousPos/IN.PreviousPos.w),1.15f));
	return PackColor(float4(Diffuse,Specular.y),float4(Normals,Specular.x),SubSurface,Velocity);
     }
   float4 PS_GeometryDetail(Out_Geometry IN) : COLOR
     {
  	clip(tex2D(DepthSampler,(IN.Proj.xy/IN.Proj.z)+ViewSize).w-IN.Proj.w);
	//clip(tex2D(BaseSampler,IN.Tex).w-0.2f);
	float4 Detail=tex2D(DetailSampler,IN.Tex*DetailScale);
   	float3 Diffuse=saturate((tex2D(BaseSampler,IN.Tex)+Detail.www)-0.5f);
	float3 Normalmap=(tex2D(NormalSampler,IN.Tex)*2-1)+((Detail.xyz*2-1)*DetailBump);
	float3 Normals=saturate(0.5f+mul(Normalmap,float3x3(IN.TBNx1,IN.TBNx2,IN.TBNx3))*0.5f);
 	float3 Specular=tex2D(SpecularSampler,IN.Tex);
	float4 SubSurface=tex2D(SubSurfaceSampler,IN.Tex);
	float2 Velocity=saturate(0.5f+pow((IN.CurrentPos/IN.CurrentPos.w)-(IN.PreviousPos/IN.PreviousPos.w),1.15f));
	return PackColor(float4(Diffuse,Specular.y),float4(Normals,Specular.x),SubSurface,Velocity);
     }
   float4 PS_WPosition(Out_WPosition IN) : COLOR
     {
  	clip(tex2D(DepthSampler,(IN.Proj.xy/IN.Proj.z)+ViewSize).w-IN.Proj.w);
	//clip(tex2D(BaseSampler,IN.Tex).w-0.2f);
	return IN.WPosition;
     }
   float4 PS_DepthMapVsm(Out_Depth IN) : COLOR
     {
  	clip(tex2D(DepthSampler,(IN.Proj.xy/IN.Proj.z)+ViewSize).w-IN.Proj.w);
	//clip(tex2D(BaseSampler,IN.Tex).w-0.2f);
	float Depth=saturate(length(IN.Depth.xyz/LightRange));
        return float4(Depth,Depth*Depth,0,0);
     }
   float4 PS_DepthMapEvsm(Out_Depth IN) : COLOR
     {
  	clip(tex2D(DepthSampler,(IN.Proj.xy/IN.Proj.z)+ViewSize).w-IN.Proj.w);
	//clip(tex2D(BaseSampler,IN.Tex).w-0.2f);
	float Depth=saturate(length(IN.Depth.xyz/LightRange));
	float2 DepthPN=float2(Depth+ShadowBias.x,1-Depth+ShadowBias.y);
	float2 DepthExp=exp(DepthPN*7-3.5f);
        return float4(DepthExp.x,DepthExp.y,DepthExp.x*DepthExp.x,DepthExp.y*DepthExp.y);
     }
   float4 PS_DepthMapDirectionalVsm(Out_Depth IN) : COLOR
     {
  	clip(tex2D(DepthSampler,(IN.Proj.xy/IN.Proj.z)+ViewSize).w-IN.Proj.w);
	//clip(tex2D(BaseSampler,IN.Tex).w-0.2f);
	float Depth=saturate(dot(IN.Depth.xyz,LightDirection)/LightRange);
        return float4(Depth,Depth*Depth,0,0);
     }
   float4 PS_DepthMapDirectionalVsmBa(Out_Depth IN) : COLOR
     {
  	clip(tex2D(DepthSampler,(IN.Proj.xy/IN.Proj.z)+ViewSize).w-IN.Proj.w);
	//clip(tex2D(BaseSampler,IN.Tex).w-0.2f);
	float Depth=saturate(dot(IN.Depth.xyz,LightDirection)/LightRange);
        return float4(0,0,Depth,Depth*Depth);
     }
   float4 PS_DepthMapDirectionalEvsm(Out_Depth IN) : COLOR
     {
  	clip(tex2D(DepthSampler,(IN.Proj.xy/IN.Proj.z)+ViewSize).w-IN.Proj.w);
	//clip(tex2D(BaseSampler,IN.Tex).w-0.2f);
	float Depth=saturate(dot(IN.Depth.xyz,LightDirection)/LightRange);
	float2 DepthPN=float2(Depth+ShadowBias.x,1-Depth+ShadowBias.y);
	float2 DepthExp=exp(DepthPN*7-3.5f);
        return float4(DepthExp.x,DepthExp.y,DepthExp.x*DepthExp.x,DepthExp.y*DepthExp.y);
     }

//--------------
// techniques   
//--------------
   technique Diffuse
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS(); 
 	PixelShader  = compile ps_3_0 PS(); 
      }
      }
   technique Geometry
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS_Geometry(); 
 	PixelShader  = compile ps_3_0 PS_Geometry(); 	
      }
      }
   technique GeometryDetail
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS_Geometry(); 
 	PixelShader  = compile ps_3_0 PS_GeometryDetail(); 
      }
      }
   technique WPosition
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS_WPosition(); 
 	PixelShader  = compile ps_3_0 PS_WPosition();    
	  }
      }
    technique DepthMapVsm
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS_DepthMap(); 
 	PixelShader  = compile ps_3_0 PS_DepthMapVsm(); 		
      }
      }
    technique DepthMapEvsm
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS_DepthMap(); 
 	PixelShader  = compile ps_3_0 PS_DepthMapEvsm(); 	
      }
      }
    technique DepthMapDirectionalVsm
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS_DepthMapDirectional(); 
 	PixelShader  = compile ps_3_0 PS_DepthMapDirectionalVsm();
        //ColorWriteEnable=3;
		SrcBlend=srcalpha;
		zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
    technique DepthMapDirectionalVsmBa
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS_DepthMapDirectional(); 
 	PixelShader  = compile ps_3_0 PS_DepthMapDirectionalVsmBa();
        //ColorWriteEnable=12;
		SrcBlend=srcalpha;
		zwriteenable=false;
        ColorWriteEnable=7;	  		
      }
      }
    technique DepthMapDirectionalEvsm
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS_DepthMapDirectional(); 
 	PixelShader  = compile ps_3_0 PS_DepthMapDirectionalEvsm(); 	
      }
      }