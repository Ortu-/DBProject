//====================================================
// Shadow Blur and Combine
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// tweaks
//--------------
   float2 ViewSize;

//--------------
// Textures
//--------------
   texture StaticDepthTexture <string Name = " ";>;
   sampler StaticDepthSampler=sampler_state 
      {
	Texture=<StaticDepthTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
  	MagFilter=none;
	MinFilter=none;
	MipFilter=none;
      };
   texture DynamicDepthTexture <string Name = " ";>;
   sampler DynamicDepthSampler=sampler_state 
      {
	Texture=<DynamicDepthTexture>;
     	ADDRESSU=Clamp;
        ADDRESSV=Clamp;
        ADDRESSW=Clamp;
 	MagFilter=none;
	MinFilter=none;
	MipFilter=none;
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
 	float2 Tex:TEXCOORD0;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=(IN.Pos/float4(2,1,1,1))-float4(0.5f,0,0,0); 
 	OUT.Tex=((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)+ViewSize;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS_Vsm(OutPut IN) : COLOR
     {
	float2 DepthD=tex2D(DynamicDepthSampler,IN.Tex);
	float2 DepthS=tex2D(StaticDepthSampler,IN.Tex);
	return float4(lerp(DepthS,DepthD,saturate((DepthS.x-DepthD.x)*255)),0,0);
     }
  float4 PS_Evsm(OutPut IN) : COLOR
     {
	float4 DepthD=tex2D(DynamicDepthSampler,IN.Tex);
	float4 DepthS=tex2D(StaticDepthSampler,IN.Tex);
  	return lerp(DepthS,DepthD,saturate((DepthS.x-DepthD.x)*255));
     }

//--------------
// techniques   
//--------------
    technique Vsm
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS_Vsm();
	zwriteenable=false;
	zenable=false;
      }
      }
    technique Evsm
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS_Evsm();
	zwriteenable=false;
	zenable=false;
      }
      }