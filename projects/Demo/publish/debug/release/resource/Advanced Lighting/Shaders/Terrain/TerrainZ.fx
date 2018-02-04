//====================================================
// Terrain
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix ViewProj:ViewProjection;
   matrix ViewInv:ViewInverse;
   matrix ViewMat:View;
   matrix OrthoProj;
   matrix PreviousVP;

//--------------
// tweaks
//--------------
   float3 TerrainIndex1[25];
   float4 TerrainIndex2[50];
   float2 TerrainIndex3[15];
   float4 TerrainIndex4[15];
   float4 TerrainSize;
   float4 TerrainTileSize;
   float TerrainHeight;
   float4 TileUVScale;
   float3 TextureSize;
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
   texture TerrainTexture <string Name = "";>;
   sampler TerrainSampler=sampler_state
      {
 	Texture=<TerrainTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
      };
   texture BlendMapTexture <string Name = "";>;
   sampler BlendMapSampler=sampler_state
      {
 	Texture=<BlendMapTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
      };
   texture ColorMapTexture <string Name = "";>;
   sampler ColorMapSampler=sampler_state
      {
 	Texture=<ColorMapTexture>;
      };
   texture Atlas1Texture <string Name = "";>;
   sampler Atlas1Sampler=sampler_state
      {
 	Texture=<Atlas1Texture>;
     	ADDRESSU=Clamp;
      };
   texture Atlas2Texture <string Name = "";>;
   sampler Atlas2Sampler=sampler_state
      {
 	Texture=<Atlas2Texture>;
     	ADDRESSU=Clamp;
      };
   texture Atlas3Texture <string Name = "";>;
   sampler Atlas3Sampler=sampler_state
      {
 	Texture=<Atlas3Texture>;
     	ADDRESSU=Clamp;
      };
   texture Atlas4Texture <string Name = "";>;
   sampler Atlas4Sampler=sampler_state
      {
 	Texture=<Atlas4Texture>;
     	ADDRESSU=Clamp;
      };

//--------------
// structs 
//--------------
   struct InPut
     {
        float4 Pos:POSITION;
 	float2 Tex1:TEXCOORD0;
 	float2 Tex2:TEXCOORD1;
 	float2 Index1:TEXCOORD2;
  	float2 Index2:TEXCOORD3;
 	float2 Index3:TEXCOORD4;
     };
   struct OutPut
     {
 	float4 Pos:POSITION;
	float2 TexUV:TEXCOORD0;
	float2 Tex:TEXCOORD1;
	float ClipY:TEXCOORD2;
	float4 Fog:COLOR0;
     };
   struct In_Geometry
     {
        float4 Pos:POSITION;
 	float2 Tex1:TEXCOORD0;
 	float2 Tex2:TEXCOORD1;
 	float2 Index1:TEXCOORD2;
  	float2 Index2:TEXCOORD3;
 	float2 Index3:TEXCOORD4;
     };
   struct Out_Geometry
     {
 	float4 Pos:POSITION;
	float2 Tex:TEXCOORD0;
	float3 TexU:TEXCOORD1;
	float3 TexV:TEXCOORD2;
	float4 TexUV:TEXCOORD3;
     };
   struct In_WPosition
     {
        float4 Pos:POSITION;
 	float2 Tex1:TEXCOORD0;
 	float2 Tex2:TEXCOORD1;
 	float2 Index1:TEXCOORD2;
  	float2 Index2:TEXCOORD3;
 	float2 Index3:TEXCOORD4;
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
 	float2 Tex1:TEXCOORD0;
 	float2 Tex2:TEXCOORD1;
 	float2 Index1:TEXCOORD2;
  	float2 Index2:TEXCOORD3;
 	float2 Index3:TEXCOORD4;
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
	float ClampUvOffset=saturate(TerrainIndex2[IN.Index1.y].y+(TerrainIndex4[IN.Index2.x].x+TerrainIndex4[IN.Index2.y].y));
	float FlipUvOffset=saturate(TerrainIndex2[IN.Index1.y].x-(TerrainIndex4[IN.Index2.x].z+TerrainIndex4[IN.Index2.y].w));
	float MaxUvOffset=abs(IN.Tex1.y)*TerrainIndex2[IN.Index1.y].z*abs(IN.Tex1.x);
	float2 UvOffset1=float2(-1*MaxUvOffset,0)+(float2(lerp(IN.Tex1.x,-IN.Tex1.x,FlipUvOffset),IN.Tex1.y)*ClampUvOffset);
	float2 UvOffset2=float2(1*MaxUvOffset,0)+(float2(lerp(IN.Tex2.x,-IN.Tex2.x,FlipUvOffset),IN.Tex2.y)*ClampUvOffset);
	float3 NewPos=(IN.Pos.xyz*TerrainSize.z)+TerrainIndex1[IN.Index1.x].xyz;
	NewPos.x=NewPos.x+(abs(UvOffset2.x*TerrainIndex2[IN.Index1.y].w)*(TerrainIndex3[IN.Index3.x].y*TerrainSize.w));
	float2 NewUv=(NewPos.xz/TerrainTileSize.xy)+TerrainTileSize.zw;
	float2 Height0=tex2Dlod(TerrainSampler,float4(NewUv,0,0)).zw;
	float2 Height1=tex2Dlod(TerrainSampler,float4(NewUv+((UvOffset1*TerrainIndex3[IN.Index3.x].y)/TerrainSize.xy),0,0)).zw;
	float2 Height2=tex2Dlod(TerrainSampler,float4(NewUv+((UvOffset2*TerrainIndex3[IN.Index3.x].y)/TerrainSize.xy),0,0)).zw;
	float2 LerpHeight=TerrainIndex3[IN.Index3.x].x*(1-TerrainIndex2[IN.Index1.y].w);
	NewPos.y=lerp((Height0.x*255)+Height0.y,lerp((Height1.x*255)+Height1.y,(Height2.x*255)+Height2.y,0.5),LerpHeight)*(TerrainHeight/255);
	OUT.Pos=mul(float4(NewPos,1),ViewProj);
	OUT.TexUV=NewUv*TerrainSize.xy*TileUVScale.xy;
	OUT.Tex=NewUv;
	OUT.ClipY=NewPos.y-ClipHeight;
	float ViewVecL=length(NewPos-ViewInv[3].xyz);
	float3 LightVec=NewPos-LightPosition;
	float4 FogDist=saturate(float4(pow(ViewVecL.xx/FogRange.xy,FogRange.zw),length(LightVec)/(FogRange.x*2),exp(-((NewPos.y-HeightFog.x)/HeightFog.y)*HeightFog.z)*HeightFogColor.w));
	OUT.Fog=float4(lerp(HeightFogColor.xyz,lerp(FogColor2,FogColor1,FogDist.z),FogDist.x),saturate((FogDist.w*FogDist.y)+FogDist.x));
	return OUT;
     }
   Out_Geometry VS_Geometry(In_Geometry IN) 
     {
 	Out_Geometry OUT;
	float ClampUvOffset=saturate(TerrainIndex2[IN.Index1.y].y+(TerrainIndex4[IN.Index2.x].x+TerrainIndex4[IN.Index2.y].y));
	float FlipUvOffset=saturate(TerrainIndex2[IN.Index1.y].x-(TerrainIndex4[IN.Index2.x].z+TerrainIndex4[IN.Index2.y].w));
	float MaxUvOffset=abs(IN.Tex1.y)*TerrainIndex2[IN.Index1.y].z*abs(IN.Tex1.x);
	float2 UvOffset1=float2(-1*MaxUvOffset,0)+(float2(lerp(IN.Tex1.x,-IN.Tex1.x,FlipUvOffset),IN.Tex1.y)*ClampUvOffset);
	float2 UvOffset2=float2(1*MaxUvOffset,0)+(float2(lerp(IN.Tex2.x,-IN.Tex2.x,FlipUvOffset),IN.Tex2.y)*ClampUvOffset);
	float3 NewPos=(IN.Pos.xyz*TerrainSize.z)+TerrainIndex1[IN.Index1.x].xyz;
	NewPos.x=NewPos.x+(abs(UvOffset2.x*TerrainIndex2[IN.Index1.y].w)*(TerrainIndex3[IN.Index3.x].y*TerrainSize.w));
	float2 NewUv=(NewPos.xz/TerrainTileSize.xy)+TerrainTileSize.zw;
	float2 Height0=tex2Dlod(TerrainSampler,float4(NewUv,0,0)).zw;
	float2 Height1=tex2Dlod(TerrainSampler,float4(NewUv+((UvOffset1*TerrainIndex3[IN.Index3.x].y)/TerrainSize.xy),0,0)).zw;
	float2 Height2=tex2Dlod(TerrainSampler,float4(NewUv+((UvOffset2*TerrainIndex3[IN.Index3.x].y)/TerrainSize.xy),0,0)).zw;
	float2 LerpHeight=TerrainIndex3[IN.Index3.x].x*(1-TerrainIndex2[IN.Index1.y].w);
	NewPos.y=lerp((Height0.x*255)+Height0.y,lerp((Height1.x*255)+Height1.y,(Height2.x*255)+Height2.y,0.5),LerpHeight)*(TerrainHeight/255);
	OUT.Pos=mul(float4(NewPos,1),ViewProj);
	OUT.Tex=NewUv;
	float2 NewUvX=(NewPos.zy/TerrainTileSize.xy)+TerrainTileSize.zw;
	float2 NewUvZ=(NewPos.xy/TerrainTileSize.xy)+TerrainTileSize.zw;
	OUT.TexU=float3(NewUv.x,-NewUvX.x,NewUvZ.x)*TerrainSize.xxx*float3(TileUVScale.x,TileUVScale.zz);
	OUT.TexV=-float3(NewUv.y,NewUvX.y,NewUvZ.y)*TerrainSize.yyy*float3(TileUVScale.y,TileUVScale.ww);
	OUT.TexUV.xy=float2(OUT.TexU.x,OUT.TexV.x);
	OUT.TexUV=float4(OUT.TexUV.xy*TextureSize.x,OUT.TexUV.xy*TextureSize.y);
	return OUT;
     }
   Out_WPosition VS_WPosition(In_WPosition IN) 
     {
 	Out_WPosition OUT;
	float ClampUvOffset=saturate(TerrainIndex2[IN.Index1.y].y+(TerrainIndex4[IN.Index2.x].x+TerrainIndex4[IN.Index2.y].y));
	float FlipUvOffset=saturate(TerrainIndex2[IN.Index1.y].x-(TerrainIndex4[IN.Index2.x].z+TerrainIndex4[IN.Index2.y].w));
	float MaxUvOffset=abs(IN.Tex1.y)*TerrainIndex2[IN.Index1.y].z*abs(IN.Tex1.x);
	float2 UvOffset1=float2(-1*MaxUvOffset,0)+(float2(lerp(IN.Tex1.x,-IN.Tex1.x,FlipUvOffset),IN.Tex1.y)*ClampUvOffset);
	float2 UvOffset2=float2(1*MaxUvOffset,0)+(float2(lerp(IN.Tex2.x,-IN.Tex2.x,FlipUvOffset),IN.Tex2.y)*ClampUvOffset);
	float3 NewPos=(IN.Pos.xyz*TerrainSize.z)+TerrainIndex1[IN.Index1.x].xyz;
	NewPos.x=NewPos.x+(abs(UvOffset2.x*TerrainIndex2[IN.Index1.y].w)*(TerrainIndex3[IN.Index3.x].y*TerrainSize.w));
	float2 NewUv=(NewPos.xz/TerrainTileSize.xy)+TerrainTileSize.zw;
	float2 Height0=tex2Dlod(TerrainSampler,float4(NewUv,0,0)).zw;
	float2 Height1=tex2Dlod(TerrainSampler,float4(NewUv+((UvOffset1*TerrainIndex3[IN.Index3.x].y)/TerrainSize.xy),0,0)).zw;
	float2 Height2=tex2Dlod(TerrainSampler,float4(NewUv+((UvOffset2*TerrainIndex3[IN.Index3.x].y)/TerrainSize.xy),0,0)).zw;
	float2 LerpHeight=TerrainIndex3[IN.Index3.x].x*(1-TerrainIndex2[IN.Index1.y].w);
	NewPos.y=lerp((Height0.x*255)+Height0.y,lerp((Height1.x*255)+Height1.y,(Height2.x*255)+Height2.y,0.5),LerpHeight)*(TerrainHeight/255);
	OUT.Pos=mul(float4(NewPos,1),ViewProj);
	OUT.ViewPos=float4(mul(float4(NewPos,1),ViewMat).xyz,OUT.Pos.z);
 	OUT.CurrentPos=OUT.Pos;
	OUT.PreviousPos=mul(float4(NewPos,1),PreviousVP);
	return OUT;
     }
   Out_Depth VS_DepthMap(In_Depth IN)
     {
        Out_Depth OUT;
	float ClampUvOffset=saturate(TerrainIndex2[IN.Index1.y].y+(TerrainIndex4[IN.Index2.x].x+TerrainIndex4[IN.Index2.y].y));
	float FlipUvOffset=saturate(TerrainIndex2[IN.Index1.y].x-(TerrainIndex4[IN.Index2.x].z+TerrainIndex4[IN.Index2.y].w));
	float MaxUvOffset=abs(IN.Tex1.y)*TerrainIndex2[IN.Index1.y].z*abs(IN.Tex1.x);
	float2 UvOffset1=float2(-1*MaxUvOffset,0)+(float2(lerp(IN.Tex1.x,-IN.Tex1.x,FlipUvOffset),IN.Tex1.y)*ClampUvOffset);
	float2 UvOffset2=float2(1*MaxUvOffset,0)+(float2(lerp(IN.Tex2.x,-IN.Tex2.x,FlipUvOffset),IN.Tex2.y)*ClampUvOffset);
	float3 NewPos=(IN.Pos.xyz*TerrainSize.z)+TerrainIndex1[IN.Index1.x].xyz;
	NewPos.x=NewPos.x+(abs(UvOffset2.x*TerrainIndex2[IN.Index1.y].w)*(TerrainIndex3[IN.Index3.x].y*TerrainSize.w));
	float2 NewUv=(NewPos.xz/TerrainTileSize.xy)+TerrainTileSize.zw;
	float2 Height0=tex2Dlod(TerrainSampler,float4(NewUv,0,0)).zw;
	float2 Height1=tex2Dlod(TerrainSampler,float4(NewUv+((UvOffset1*TerrainIndex3[IN.Index3.x].y)/TerrainSize.xy),0,0)).zw;
	float2 Height2=tex2Dlod(TerrainSampler,float4(NewUv+((UvOffset2*TerrainIndex3[IN.Index3.x].y)/TerrainSize.xy),0,0)).zw;
	float2 LerpHeight=TerrainIndex3[IN.Index3.x].x*(1-TerrainIndex2[IN.Index1.y].w);
	NewPos.y=lerp((Height0.x*255)+Height0.y,lerp((Height1.x*255)+Height1.y,(Height2.x*255)+Height2.y,0.5),LerpHeight)*(TerrainHeight/255);
	OUT.Pos=mul(float4(NewPos,1),ViewProj);
	OUT.Depth=float4(ShadowPosition-NewPos,0);
        return OUT;
     }
   Out_Depth VS_DepthMapDirectional(In_Depth IN)
     {
        Out_Depth OUT;
	float ClampUvOffset=saturate(TerrainIndex2[IN.Index1.y].y+(TerrainIndex4[IN.Index2.x].x+TerrainIndex4[IN.Index2.y].y));
	float FlipUvOffset=saturate(TerrainIndex2[IN.Index1.y].x-(TerrainIndex4[IN.Index2.x].z+TerrainIndex4[IN.Index2.y].w));
	float MaxUvOffset=abs(IN.Tex1.y)*TerrainIndex2[IN.Index1.y].z*abs(IN.Tex1.x);
	float2 UvOffset1=float2(-1*MaxUvOffset,0)+(float2(lerp(IN.Tex1.x,-IN.Tex1.x,FlipUvOffset),IN.Tex1.y)*ClampUvOffset);
	float2 UvOffset2=float2(1*MaxUvOffset,0)+(float2(lerp(IN.Tex2.x,-IN.Tex2.x,FlipUvOffset),IN.Tex2.y)*ClampUvOffset);
	float3 NewPos=(IN.Pos.xyz*TerrainSize.z)+TerrainIndex1[IN.Index1.x].xyz;
	NewPos.x=NewPos.x+(abs(UvOffset2.x*TerrainIndex2[IN.Index1.y].w)*(TerrainIndex3[IN.Index3.x].y*TerrainSize.w));
	float2 NewUv=(NewPos.xz/TerrainTileSize.xy)+TerrainTileSize.zw;
	float2 Height0=tex2Dlod(TerrainSampler,float4(NewUv,0,0)).zw;
	float2 Height1=tex2Dlod(TerrainSampler,float4(NewUv+((UvOffset1*TerrainIndex3[IN.Index3.x].y)/TerrainSize.xy),0,0)).zw;
	float2 Height2=tex2Dlod(TerrainSampler,float4(NewUv+((UvOffset2*TerrainIndex3[IN.Index3.x].y)/TerrainSize.xy),0,0)).zw;
	float2 LerpHeight=TerrainIndex3[IN.Index3.x].x*(1-TerrainIndex2[IN.Index1.y].w);
	NewPos.y=lerp((Height0.x*255)+Height0.y,lerp((Height1.x*255)+Height1.y,(Height2.x*255)+Height2.y,0.5),LerpHeight)*(TerrainHeight/255);
	OUT.Pos=mul(float4(NewPos,1),OrthoProj);
	OUT.Depth=float4(float4(NewPos,1)-ShadowPosition,0);
        return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
	clip(IN.ClipY);
	float4 NormalXZ=tex2D(TerrainSampler,IN.Tex);
	NormalXZ.w=(NormalXZ.z*255)+NormalXZ.w;
	NormalXZ.z=(1-NormalXZ.x)*2-1;
	NormalXZ.xy=NormalXZ.xy*2-1;
	float4 Vertical=float4(abs(NormalXZ.xy),abs(NormalXZ.y+NormalXZ.z),abs(NormalXZ.x+NormalXZ.y));
	Vertical.z=dot(Vertical,1);
	float4 BlendMap1=tex2D(BlendMapSampler,IN.Tex);
	float4 BlendMap2=saturate(float4(1-dot(BlendMap1,1).x,27-NormalXZ.w,(Vertical.z-1.5f)*2,(Vertical.z-2.2f)*2));
	BlendMap2.y *=1-BlendMap2.w;
	BlendMap2.z *=1-(BlendMap2.y+BlendMap2.w);
	BlendMap2.x *=1-(BlendMap2.y+BlendMap2.z+BlendMap2.w);
	BlendMap1 *=1-(BlendMap2.y+BlendMap2.z+BlendMap2.w);
	float3 Normals=float3(NormalXZ.x,1-(Vertical.x+Vertical.y)*0.5,NormalXZ.y);
	IN.TexUV.x=((frac(IN.TexUV.x)*0.5f)*0.9f);
	float3 Diffuse=tex2D(Atlas1Sampler,IN.TexUV)*BlendMap1.x
		      +tex2D(Atlas2Sampler,IN.TexUV)*BlendMap1.z
		      +tex2D(Atlas3Sampler,IN.TexUV)*BlendMap2.x
		      +tex2D(Atlas4Sampler,IN.TexUV)*BlendMap2.z;
	IN.TexUV.x=1-IN.TexUV.x;
	Diffuse +=tex2D(Atlas1Sampler,IN.TexUV)*BlendMap1.y
		 +tex2D(Atlas2Sampler,IN.TexUV)*BlendMap1.w
		 +tex2D(Atlas3Sampler,IN.TexUV)*BlendMap2.y
		 +tex2D(Atlas4Sampler,IN.TexUV)*BlendMap2.w;
	return float4(lerp(Diffuse*(saturate(dot(-LightDirection,Normals)*LightColor)+AmbientColor),IN.Fog,IN.Fog.w),1);
     }
   float4 PackColor(in float3 iColor1,in float4 iColor2)
     {
	iColor1=floor(iColor1*254);
	iColor2=floor(iColor2*254);
	return float4((iColor1.x*65025)+(iColor2.x*255),
	 	      (iColor1.y*65025)+(iColor2.y*255),
		      (iColor1.z*65025)+(iColor2.z*255),
		      8323200+(iColor2.w*255));
     }
   float4 PS_Geometry(Out_Geometry IN) : COLOR
     {
    	float4 Dx=ddx(IN.TexUV);
    	float4 Dy=ddy(IN.TexUV);
	float4 Dxy=float4(dot(Dx.xy,Dx.xy).x,dot(Dx.zw,Dx.zw).x,dot(Dy.xy,Dy.xy).x,dot(Dy.zw,Dy.zw).x);
    	float2 MipLevel=saturate((0.5f*log2(max(Dxy.xy,Dxy.zw)))*0.125f);
	float SeemsFix=(1-(pow(MipLevel,16)*0.5f))*TextureSize.z;
	MipLevel *=8;
	IN.TexU=(frac(IN.TexU)*0.5f)*SeemsFix;
	float4 NormalXZ=tex2D(TerrainSampler,IN.Tex);
	NormalXZ.w=(NormalXZ.z*255)+NormalXZ.w;
	NormalXZ.z=(1-NormalXZ.x)*2-1;
	NormalXZ.xy=NormalXZ.xy*2-1;
	float4 Vertical=float4(abs(NormalXZ.xy),abs(NormalXZ.y+NormalXZ.z),abs(NormalXZ.x+NormalXZ.y));
	Vertical.z=dot(Vertical,1);
	float4 BlendMap1=tex2D(BlendMapSampler,IN.Tex);
	float4 BlendMap2=saturate(float4(1-dot(BlendMap1,1).x,27-NormalXZ.w,(Vertical.z-1.5f)*2,(Vertical.z-2.2f)*2));
	BlendMap2.y *=1-BlendMap2.w;
	BlendMap2.z *=1-(BlendMap2.y+BlendMap2.w);
	BlendMap2.x *=1-(BlendMap2.y+BlendMap2.z+BlendMap2.w);
	BlendMap1 *=1-(BlendMap2.y+BlendMap2.z+BlendMap2.w);
	float3 Normals=float3(NormalXZ.x,1-(Vertical.x+Vertical.y)*0.5,NormalXZ.y);
        Vertical.xy=Vertical.xy/(Vertical.x+Vertical.y);
	float4 ColorMap=tex2D(ColorMapSampler,IN.Tex);
	float BlendMap=dot(BlendMap1,1)+BlendMap2.x;
	float3 Diffuse;
	if(BlendMap>0.99f)
	 {
	  Diffuse=tex2Dlod(Atlas1Sampler,float4(IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap1.x
       	         +tex2Dlod(Atlas1Sampler,float4(1-IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap1.y
                 +tex2Dlod(Atlas2Sampler,float4(IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap1.z
                 +tex2Dlod(Atlas2Sampler,float4(1-IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap1.w
                 +tex2Dlod(Atlas3Sampler,float4(IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap2.x;
	 }
	else
	 {
	  if(BlendMap>0.01f)
	   {
	    Diffuse=tex2Dlod(Atlas1Sampler,float4(IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap1.x
       	      	   +tex2Dlod(Atlas1Sampler,float4(1-IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap1.y
                   +tex2Dlod(Atlas2Sampler,float4(IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap1.z
                   +tex2Dlod(Atlas2Sampler,float4(1-IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap1.w
                   +tex2Dlod(Atlas3Sampler,float4(IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap2.x;
	   }
	    Diffuse +=tex2Dlod(Atlas3Sampler,float4(1-IN.TexU.x,IN.TexV.x,0,MipLevel.x))*BlendMap2.y
       	      	    +(tex2Dlod(Atlas4Sampler,float4(IN.TexU.y,IN.TexV.y,0,MipLevel.y))*BlendMap2.z*Vertical.x)
       	      	    +(tex2Dlod(Atlas4Sampler,float4(IN.TexU.z,IN.TexV.z,0,MipLevel.y))*BlendMap2.z*Vertical.y)
       	      	    +(tex2Dlod(Atlas4Sampler,float4(1-IN.TexU.y,IN.TexV.y,0,MipLevel.y))*BlendMap2.w*Vertical.x)
       	      	    +(tex2Dlod(Atlas4Sampler,float4(1-IN.TexU.z,IN.TexV.z,0,MipLevel.y))*BlendMap2.w*Vertical.y);
	 }
	return PackColor(saturate((Diffuse+ColorMap)-0.5f),float4(saturate(0.5+Normals*0.5),ColorMap.w));
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