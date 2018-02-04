//====================================================
// Project Volumetric Clouds
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
   float3 CloudColor;
   float3 LightColor;
   float3 FogColor;

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
   texture RenderTexture <string Name = " ";>;
   sampler RenderSampler=sampler_state 
      {
	Texture=<RenderTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
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
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=mul(IN.Pos,WorldVP); 
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	return OUT;
     }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {	
	float2 proj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
	float3 Cloud=tex2D(RenderSampler,proj);
	float Alpha=Cloud.x*saturate((tex2D(DepthSampler,proj).y-IN.Proj.w)*0.001f);
	return float4(lerp(FogColor*Alpha,(CloudColor*Alpha)+(Cloud.y*LightColor),Cloud.z),Alpha);
     }
  float4 PS_Blocker(OutPut IN) : COLOR
     {	
	float2 proj=((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy;
	float cloud=tex2D(RenderSampler,proj).x*saturate((tex2D(DepthSampler,proj).y-IN.Proj.w)*0.001f);
	return float4(0.5*cloud,0.5*cloud,0,cloud);	
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
	cullmode=0;
	AlphaBlendEnable=TRUE;
	SrcBlend=ONE;
	DestBlend=INVSRCALPHA;
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }
    technique Blocker
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS_Blocker(); 
	cullmode=0;
	AlphaBlendEnable=TRUE;
	SrcBlend=ONE;
	DestBlend=INVSRCALPHA;
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }