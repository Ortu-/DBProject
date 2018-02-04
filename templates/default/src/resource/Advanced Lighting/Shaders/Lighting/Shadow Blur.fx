//====================================================
// Shadow Blur
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// tweaks
//--------------
   float2 BlurOffset;

//--------------
// Textures
//--------------
   texture DepthTexture <string Name = " ";>;
   sampler DepthSampler=sampler_state 
      {
	Texture=<DepthTexture>;
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
 	float2 Tex:TEXCOORD0;
	float4 Tex1:TEXCOORD1;
	float4 Tex2:TEXCOORD2;
	float4 Tex3:TEXCOORD3;
	float4 Tex4:TEXCOORD4;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=IN.Pos; 
 	OUT.Tex=((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5);
	OUT.Tex1.xy=OUT.Tex+float2(-BlurOffset.x,0);
	OUT.Tex1.zw=OUT.Tex+float2(BlurOffset.x,0);
	OUT.Tex2.xy=OUT.Tex+float2(0,-BlurOffset.y);
	OUT.Tex2.zw=OUT.Tex+float2(0,BlurOffset.y);
	OUT.Tex3.xy=OUT.Tex+float2(-BlurOffset.x,-BlurOffset.y);
	OUT.Tex3.zw=OUT.Tex+float2(BlurOffset.x,BlurOffset.y);
	OUT.Tex4.xy=OUT.Tex+float2(BlurOffset.x,-BlurOffset.y);
	OUT.Tex4.zw=OUT.Tex+float2(-BlurOffset.x,BlurOffset.y);
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS_Vsm(OutPut IN) : COLOR
     {
 	float2 Depth=tex2D(DepthSampler,IN.Tex)
 	            +tex2D(DepthSampler,IN.Tex1.xy)
 	            +tex2D(DepthSampler,IN.Tex1.zw)
 	            +tex2D(DepthSampler,IN.Tex2.xy)
 	            +tex2D(DepthSampler,IN.Tex2.zw)
 	            +tex2D(DepthSampler,IN.Tex3.xy)
 	            +tex2D(DepthSampler,IN.Tex3.zw)
 	            +tex2D(DepthSampler,IN.Tex4.xy)
 	            +tex2D(DepthSampler,IN.Tex4.zw);
	return float4(Depth/9,0,0);
     }
  float4 PS_VsmBa(OutPut IN) : COLOR
     {
 	float2 Depth=tex2D(DepthSampler,IN.Tex).zw
 	            +tex2D(DepthSampler,IN.Tex1.xy).zw
 	            +tex2D(DepthSampler,IN.Tex1.zw).zw
 	            +tex2D(DepthSampler,IN.Tex2.xy).zw
 	            +tex2D(DepthSampler,IN.Tex2.zw).zw
 	            +tex2D(DepthSampler,IN.Tex3.xy).zw
 	            +tex2D(DepthSampler,IN.Tex3.zw).zw
 	            +tex2D(DepthSampler,IN.Tex4.xy).zw
 	            +tex2D(DepthSampler,IN.Tex4.zw).zw;
	return float4(0,0,Depth/9);
     }
  float4 PS_Evsm(OutPut IN) : COLOR
     {
 	float4 Depth=tex2D(DepthSampler,IN.Tex)
 	            +tex2D(DepthSampler,IN.Tex1.xy)
 	            +tex2D(DepthSampler,IN.Tex1.zw)
 	            +tex2D(DepthSampler,IN.Tex2.xy)
 	            +tex2D(DepthSampler,IN.Tex2.zw)
 	            +tex2D(DepthSampler,IN.Tex3.xy)
 	            +tex2D(DepthSampler,IN.Tex3.zw)
 	            +tex2D(DepthSampler,IN.Tex4.xy)
 	            +tex2D(DepthSampler,IN.Tex4.zw);
	return Depth/9;
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
        ColorWriteEnable=3;
      }
      }
    technique VsmBa
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS_VsmBa();
	zwriteenable=false;
	zenable=false;
        ColorWriteEnable=12;
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