//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix ViewProj:ViewProjection;
   matrix World:World;    

//--------------
// tweaks
//--------------
   float3 TerrainSize;
   float4 TerrainTileSize;
   float TerrainHeight;

//--------------
// Textures
//--------------
   texture BaseTexture <string Name="";>;	
   sampler BaseSampler=sampler_state 
      {
 	texture=<BaseTexture>;
	MagFilter=Linear;
	MinFilter=Point;
	MipFilter=None;
      };
   texture TerrainTexture <string Name = "";>;
   sampler TerrainSampler=sampler_state
      {
 	Texture=<TerrainTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
	MagFilter=Linear;
	MinFilter=Point;
	MipFilter=None;
      };

//--------------
// structs 
//--------------
   struct InPut
     {
 	float4 Pos:POSITION;
 	float2 Tex:TEXCOORD;
     };
   struct OutPut
     {
	float4 Pos:POSITION; 
   	float2 Tex1:TEXCOORD0; 
   	float2 Tex2:TEXCOORD1; 
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	float3 WPos=mul(IN.Pos,World);
	float2 NewUv=(WPos.xz/TerrainTileSize.xy)+TerrainTileSize.zw;
	float2 Height=tex2Dlod(TerrainSampler,float4(NewUv,0,0)).zw;
	OUT.Pos=mul(float4(WPos.x,((Height.x*255)+Height.y)*(TerrainHeight/255),WPos.z,1),ViewProj);
  	OUT.Tex1=IN.Tex/2000;
	OUT.Tex2=(0.5+(NewUv*TerrainSize.xy));
	return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS(OutPut IN) : COLOR
     {
   	float2 Diffuse=tex2D(BaseSampler,IN.Tex1);
	return float4((((tex2D(BaseSampler,IN.Tex2).z+tex2D(BaseSampler,IN.Tex2*0.2f).z)*Diffuse.xxx)+Diffuse.yyy)*float3(1,1,1),1);
     }

//--------------
// techniques   
//--------------
   technique Solid
      {
 	pass p1
      {		
 	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS(); 
      }
      }
