//====================================================
// Normal Mapping
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix World:World;
   matrix WorldVP:WorldViewProjection; 
   matrix WorldIT:WorldInverseTranspose;
   matrix WorldV:WorldView; 
   matrix ViewInv:ViewInverse;
   matrix PreviousVP;
   matrix OrthoProj;
 
//--------------
// tweaks
//--------------
   float4 PreviousWorldx1[50];
   float4 PreviousWorldx2[50];
   float4 PreviousWorldx3[50];
   float4 PreviousWorldx4[50];
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
   texture BaseTexture <string Name="";>;	
   sampler BaseSampler=sampler_state 
      {
 	texture=<BaseTexture>;
  	MagFilter=anisotropic;
	MinFilter=anisotropic;
	MipFilter=anisotropic;
        MaxAnisotropy=3;
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
 	float2 Tex:TEXCOORD0;
	float3 Normal:NORMAL;
     };
   struct OutPut
     {
	float4 Pos:POSITION; 
   	float2 Tex:TEXCOORD0; 
   	float3 Normals:TEXCOORD1;
	float ClipY:TEXCOORD2;
	float4 Fog:COLOR0;
     };
   struct In_Geometry
     {
 	float4 Pos:POSITION;
 	float2 Tex:TEXCOORD0;
	float Index:TEXCOORD1;
	float3 Normal:NORMAL;
     };
   struct Out_Geometry
     {
	float4 Pos:POSITION; 
   	float2 Tex:TEXCOORD0; 
 	float3 WNormal:TEXCOORD1; 
     };
   struct In_WPosition
     {
 	float4 Pos:POSITION;
	float Index:TEXCOORD1; 
     };
   struct Out_WPosition
     {
 	float4 Pos:POSITION; 
 	float4 ViewPos:TEXCOORD0;
    	float4 CurrentPos:TEXCOORD1;
    	float4 PreviousPos:TEXCOORD2;
     };
   struct In_Depth
     {
 	float4 Pos:POSITION; 
     };
   struct Out_Depth
     {
 	float4 Pos:POSITION; 
 	float4 Depth:TEXCOORD0; 
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
 	OUT.Tex=IN.Tex;
	OUT.Normals=normalize(mul(IN.Normal,World));
	float3 WPos=mul(IN.Pos,World);
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
	OUT.Pos=mul(IN.Pos,WorldVP);
 	OUT.Tex=IN.Tex;
	OUT.WNormal=normalize(mul(IN.Normal,World));
	return OUT;
     }
   Out_WPosition VS_WPosition(In_WPosition IN) 
     {
 	Out_WPosition OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
	OUT.ViewPos=float4(mul(IN.Pos,WorldV).xyz,OUT.Pos.z);
 	OUT.CurrentPos=OUT.Pos;
	float4x4 PreviousWorld={PreviousWorldx1[IN.Index],PreviousWorldx2[IN.Index],PreviousWorldx3[IN.Index],PreviousWorldx4[IN.Index]};
	OUT.PreviousPos=mul(mul(IN.Pos,PreviousWorld),PreviousVP);
	return OUT;
     }
   Out_Depth VS_DepthMap(In_Depth IN)
     {
        Out_Depth OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
	OUT.Depth=float4(ShadowPosition-mul(IN.Pos,World),0);
        return OUT;
     }
   Out_Depth VS_DepthMapDirectional(In_Depth IN)
     {
        Out_Depth OUT;
	OUT.Pos=mul(mul(IN.Pos,World),OrthoProj);
	OUT.Depth=float4(mul(IN.Pos,World)-ShadowPosition,0);
        return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
	clip(IN.ClipY);
   	float3 Diffuse=tex2D(BaseSampler,IN.Tex);
	return float4(lerp(Diffuse*(saturate(dot(-LightDirection,IN.Normals)*LightColor)+AmbientColor),IN.Fog,IN.Fog.w),1);
     }
   float4 PackColor(in float4 iColor1,in float4 iColor2,in float4 iColor3)
     {
	iColor1=floor(iColor1*254);
	iColor2=floor(iColor2*254);
	iColor3=floor(iColor3*254);
	return float4((iColor1.x*65025)+(iColor2.x*255)+iColor3.x,
	 	      (iColor1.y*65025)+(iColor2.y*255)+iColor3.y,
		      (iColor1.z*65025)+(iColor2.z*255)+iColor3.z,
		      (iColor1.w*65025)+(iColor2.w*255)+iColor3.w);
     }
   float4 PS_Geometry(Out_Geometry IN) : COLOR
     {
   	float3 Diffuse=tex2D(BaseSampler,IN.Tex);
	float3 Normals=0.5f+IN.WNormal*0.5f;
 	float3 Specular=tex2D(SpecularSampler,IN.Tex);
	return PackColor(float4(Diffuse,Specular.y),float4(Normals,Specular.x),tex2D(SubSurfaceSampler,IN.Tex));
     }
   float4 PS_GeometryDetail(Out_Geometry IN) : COLOR
     {
	float4 Detail=tex2D(DetailSampler,IN.Tex*DetailScale);
   	float3 Diffuse=saturate((tex2D(BaseSampler,IN.Tex)+Detail.www)-0.5f);
	float3 Normals=0.5f+IN.WNormal*0.5f;
 	float3 Specular=tex2D(SpecularSampler,IN.Tex);
	return PackColor(float4(Diffuse,Specular.y),float4(Normals,Specular.x),tex2D(SubSurfaceSampler,IN.Tex));
     }
   float4 PS_WPosition(Out_WPosition IN) : COLOR
     {
	float2 Velocity=(IN.CurrentPos/IN.CurrentPos.w)-(IN.PreviousPos/IN.PreviousPos.w);
	return float4(length(IN.ViewPos.xyz),IN.ViewPos.w,Velocity);
     }
   float4 PS_DepthMapVsm(Out_Depth IN) : COLOR
     {
	float Depth=saturate(length(IN.Depth.xyz/LightRange));
        return float4(Depth,Depth*Depth,0,0);
     }
   float4 PS_DepthMapEvsm(Out_Depth IN) : COLOR
     {
	float Depth=saturate(length(IN.Depth.xyz/LightRange));
	float2 DepthPN=float2(Depth+ShadowBias.x,1-Depth+ShadowBias.y);
	float2 DepthExp=exp(DepthPN*7-3.5f);
        return float4(DepthExp.x,DepthExp.y,DepthExp.x*DepthExp.x,DepthExp.y*DepthExp.y);
     }
   float4 PS_DepthMapDirectionalVsm(Out_Depth IN) : COLOR
     {
	float Depth=saturate(dot(IN.Depth.xyz,LightDirection)/LightRange)+ShadowBias.x;
        return float4(Depth,Depth*Depth,0,0);
     }
   float4 PS_DepthMapDirectionalVsmBa(Out_Depth IN) : COLOR
     {
	float Depth=saturate(dot(IN.Depth.xyz,LightDirection)/LightRange)+ShadowBias.x;
        return float4(0,0,Depth,Depth*Depth);
     }
   float4 PS_DepthMapDirectionalEvsm(Out_Depth IN) : COLOR
     {
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
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS(); 
      }
      }
   technique Geometry
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS_Geometry(); 
 	pixelShader  = compile ps_3_0 PS_Geometry(); 
      }
      }
   technique GeometryDetail
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS_Geometry(); 
 	pixelShader  = compile ps_3_0 PS_GeometryDetail(); 
      }
      }
   technique WPosition
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS_WPosition(); 
 	pixelShader  = compile ps_3_0 PS_WPosition(); 
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
        ColorWriteEnable=3;
      }
      }
    technique DepthMapDirectionalVsmBa
      {
 	pass p1
      {		
 	VertexShader = compile vs_3_0 VS_DepthMapDirectional(); 
 	PixelShader  = compile ps_3_0 PS_DepthMapDirectionalVsmBa();
        ColorWriteEnable=12;
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