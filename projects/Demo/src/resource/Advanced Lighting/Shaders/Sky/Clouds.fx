//====================================================
// Volumetric Clouds
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix ViewProj:ViewProjection;
   matrix ViewInv:ViewInverse; 
   float time:Time;

//--------------
// tweaks
//--------------
   float2 CloudScale[35];
   float3 CloudPosition;
   float2 CloudHeight;
   float2 CloudUvScale;
   float2 NoiseUvScale;
   float2 CloudSpeed;
   float2 NoiseSpeed;
   float4 CloudDensity;
   float2 CloudExp;
   float2 CloudFalloff;
   float3 LightDir1;
   float3 LightDir2;

//--------------
// Textures
//--------------
   texture CloudTexture <string Name = "";>;	
   sampler CloudSampler=sampler_state 
      {
 	texture=<CloudTexture>;
      };
   texture CloudNoiseTexture <string Name = "";>;	
   sampler CloudNoiseSampler=sampler_state 
      {
 	texture=<CloudNoiseTexture>;
      };

//--------------
// structs 
//--------------
   struct InPut
     {
 	float4 Pos:POSITION;
 	float2 PolySize:TEXCOORD0;
 	float2 Index:TEXCOORD1;
     };
   struct OutPut
     {
	float4 Pos:POSITION;
 	float4 Tex1:TEXCOORD0;
 	float4 Tex2:TEXCOORD1;
	float2 Tex3:TEXCOORD2;
	float4 CloudLayert:TEXCOORD3;
	float4 CloudLayerb:TEXCOORD4;
	float4 LightLayert:TEXCOORD5; 
	float4 LightLayerb:TEXCOORD6;
	float4 BlendVec:TEXCOORD7;
	float ViewLight:COLOR0;
	float Fog:COLOR1;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	float2 CloudSize=CloudScale[IN.Index.x];	
	float3 NewPos=(IN.Pos.xyz*CloudSize.x)+CloudPosition;
	if(NewPos.y<CloudHeight.x-(CloudHeight.y*0.5f)) NewPos.y=CloudHeight.x-(CloudHeight.y*0.5f);
	if(NewPos.y>CloudHeight.x+(CloudHeight.y*5.5)) NewPos.y=CloudHeight.x+(CloudHeight.y*5.5);
	if(((IN.PolySize.x+IN.PolySize.y)*CloudSize.x)+CloudPosition.y<CloudHeight.x-(CloudHeight.y*0.5f)) NewPos.xyz=-99999999;
	if(((IN.PolySize.x-IN.PolySize.y)*CloudSize.x)+CloudPosition.y>CloudHeight.x+(CloudHeight.y*5.5)) NewPos.xyz=-99999999;
	float2 CloudUv=(NewPos.xz/CloudUvScale)+(time*CloudSpeed);
	OUT.Tex1=float4(CloudUv,CloudUv+(0.058f*CloudDensity.w*-LightDir1.xz));
	OUT.Tex2=(float4(NewPos.xy,NewPos.zy)/NoiseUvScale.xyxy)+CloudSize.yyyy-(time*NoiseSpeed.xyxy);
	OUT.Tex3=(NewPos.xz/NoiseUvScale)+CloudSize.y+(time*NoiseSpeed);
	NewPos.y -=CloudHeight.x;
	OUT.CloudLayert.x=(NewPos.y)/CloudHeight.y;
	OUT.CloudLayert.y=(NewPos.y-CloudHeight.y)/CloudHeight.y;
	OUT.CloudLayert.z=(NewPos.y-(CloudHeight.y*2))/CloudHeight.y;
	OUT.CloudLayert.w=(NewPos.y-(CloudHeight.y*3))/CloudHeight.y;
	OUT.CloudLayerb.x=1-((NewPos.y-CloudHeight.y)/CloudHeight.y);
	OUT.CloudLayerb.y=1-((NewPos.y-(CloudHeight.y*2))/CloudHeight.y);
	OUT.CloudLayerb.z=1-((NewPos.y-(CloudHeight.y*3))/CloudHeight.y);
	OUT.CloudLayerb.w=1-((NewPos.y-(CloudHeight.y*4))/CloudHeight.y);
	float CloudShift=CloudHeight.y*CloudDensity.w*-LightDir1.y;
	NewPos.y +=CloudShift;
	OUT.LightLayert.x=(NewPos.y)/CloudHeight.y;
	OUT.LightLayert.y=(NewPos.y-CloudHeight.y)/CloudHeight.y;
	OUT.LightLayert.z=(NewPos.y-(CloudHeight.y*2))/CloudHeight.y;
	OUT.LightLayert.w=(NewPos.y-(CloudHeight.y*3))/CloudHeight.y;
	OUT.LightLayerb.x=1-((NewPos.y-CloudHeight.y)/CloudHeight.y);
	OUT.LightLayerb.y=1-((NewPos.y-(CloudHeight.y*2))/CloudHeight.y);
	OUT.LightLayerb.z=1-((NewPos.y-(CloudHeight.y*3))/CloudHeight.y);
	OUT.LightLayerb.w=1-((NewPos.y-(CloudHeight.y*4))/CloudHeight.y);
	NewPos.y -=CloudShift;
	OUT.BlendVec.z=NewPos.y/(CloudHeight.y*4);
	NewPos.y +=CloudHeight.x;
	float3 ViewVec=NewPos.xyz-ViewInv[3].xyz;
	NewPos.y -=length(ViewVec.xz)/(CloudFalloff/2000);
	OUT.Pos=mul(float4(NewPos,1),ViewProj);
	float3 ViewVecN=normalize(ViewVec);
	OUT.ViewLight=pow(saturate(dot(-LightDir2,ViewVecN)),2);
	OUT.BlendVec.xy=abs(ViewVecN.xy);
	OUT.BlendVec.x -=abs(ViewVecN.z*0.25f)+abs(ViewVecN.y*0.25f);
	OUT.BlendVec.y -=abs(ViewVecN.x*0.25f)+abs(ViewVecN.z*0.25f);
	OUT.BlendVec.xy=1-saturate(exp(-OUT.BlendVec.xy*2.5f));
	float ViewVecL=length(ViewVec);
	OUT.BlendVec.w=1-pow(saturate(ViewVecL/CloudFalloff.x),4);
	OUT.BlendVec.w *=saturate(ViewVecL/CloudFalloff.y);
	OUT.BlendVec.w *=CloudDensity.x;
	OUT.Fog=1-saturate(ViewVecL/(CloudFalloff.x*0.8f));
	return OUT;
     }

//--------------
// pixel shader
//--------------
    float4 PS(OutPut IN)  : COLOR
     {
	float3 CloudNoise=lerp(lerp(tex2D(CloudNoiseSampler,IN.Tex2),tex2D(CloudNoiseSampler,IN.Tex2.zw),IN.BlendVec.x),tex2D(CloudNoiseSampler,IN.Tex3),IN.BlendVec.y)*0.666f;
	float4 CloudLayer=saturate(IN.CloudLayert+CloudNoise.z)*saturate(IN.CloudLayerb+CloudNoise.z);
	float4 LightLayer=saturate(IN.LightLayert+CloudNoise.z)*saturate(IN.LightLayerb+CloudNoise.z);
	CloudNoise *=0.0666f;
	float Cloud=1-exp(-dot(tex2D(CloudSampler,IN.Tex1+CloudNoise.xy),CloudLayer)*(CloudExp.x-(CloudExp.y*IN.BlendVec.z)));
	float Light=pow(1-dot(tex2D(CloudSampler,IN.Tex1.zw+CloudNoise.xy),LightLayer),CloudDensity.z);
	Light +=IN.ViewLight*Light*0.5f;
	Cloud=pow(Cloud,CloudDensity.y)*IN.BlendVec.w;
	return float4(Cloud,(Light*0.5f)*Cloud,IN.Fog*Cloud,Cloud);
     }

//--------------
// techniques   
//--------------
   technique Blend
      {
 	pass p0
      {		
	vertexShader = compile vs_3_0 VS(); 
 	pixelShader  = compile ps_3_0 PS();
	AlphaBlendEnable=TRUE;
	SrcBlend=ONE;
	DestBlend=INVSRCALPHA;
	zwriteenable=false;
      }
      }