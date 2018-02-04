//====================================================
// Bloom Gaussian Horizontal
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// tweaks
//--------------
   float4 ViewSize;
   float2 ViewVec;

//--------------
// Textures
//--------------
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
 	float2 Tex:TEXCOORD0;
 	float4 Tex1:TEXCOORD1;
	float4 Tex2:TEXCOORD2;
	float4 Tex3:TEXCOORD3;
	float4 Tex4:TEXCOORD4;
	float4 Tex5:TEXCOORD5;
	float4 Tex6:TEXCOORD6;
	float4 Tex7:TEXCOORD7;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=IN.Pos; 
 	OUT.Tex=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)*ViewSize.zw)+ViewSize.xy;
 	OUT.Tex1.xy=OUT.Tex+float2(ViewVec.x,0)*2;
 	OUT.Tex1.zw=OUT.Tex+float2(ViewVec.x*2,0)*2;
 	OUT.Tex2.xy=OUT.Tex+float2(ViewVec.x*3,0)*2;
 	OUT.Tex2.zw=OUT.Tex+float2(ViewVec.x*4,0)*2;
 	OUT.Tex3.xy=OUT.Tex+float2(ViewVec.x*5,0)*2;
 	OUT.Tex3.zw=OUT.Tex+float2(ViewVec.x*6,0)*2;
 	OUT.Tex4.xy=OUT.Tex+float2(ViewVec.x*7,0)*2;
 	OUT.Tex4.zw=OUT.Tex-float2(ViewVec.x,0)*2;
 	OUT.Tex5.xy=OUT.Tex-float2(ViewVec.x*2,0)*2;
 	OUT.Tex5.zw=OUT.Tex-float2(ViewVec.x*3,0)*2;
 	OUT.Tex6.xy=OUT.Tex-float2(ViewVec.x*4,0)*2;
 	OUT.Tex6.zw=OUT.Tex-float2(ViewVec.x*5,0)*2;
 	OUT.Tex7.xy=OUT.Tex-float2(ViewVec.x*6,0)*2;
 	OUT.Tex7.zw=OUT.Tex-float2(ViewVec.x*7,0)*2;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS_High(OutPut IN) : COLOR
     {
 	float3 FrameRender=tex2D(RenderSampler,IN.Tex)*0.125f
 	            +tex2D(RenderSampler,IN.Tex1.xy)*0.109375f
 	            +tex2D(RenderSampler,IN.Tex1.zw)*0.09375f
 	            +tex2D(RenderSampler,IN.Tex2.xy)*0.078125f
 	            +tex2D(RenderSampler,IN.Tex2.zw)*0.0625f
 	            +tex2D(RenderSampler,IN.Tex3.xy)*0.046875f
 	            +tex2D(RenderSampler,IN.Tex3.zw)*0.03125f
 	            +tex2D(RenderSampler,IN.Tex4.xy)*0.015625f
 	            +tex2D(RenderSampler,IN.Tex4.zw)*0.109375f
 	            +tex2D(RenderSampler,IN.Tex5.xy)*0.09375f
 	            +tex2D(RenderSampler,IN.Tex5.zw)*0.078125f
 	            +tex2D(RenderSampler,IN.Tex6.xy)*0.0625f
 	            +tex2D(RenderSampler,IN.Tex6.zw)*0.046875f
 	            +tex2D(RenderSampler,IN.Tex7.xy)*0.03125f
 	            +tex2D(RenderSampler,IN.Tex7.zw)*0.015625f;
	return float4(FrameRender,0);	
     }
  float4 PS_Low(OutPut IN) : COLOR
     {
 	float3 FrameRender=tex2D(RenderSampler,IN.Tex)*0.2f
 	            +tex2D(RenderSampler,IN.Tex1.xy)*0.16f
 	            +tex2D(RenderSampler,IN.Tex1.zw)*0.12f
 	            +tex2D(RenderSampler,IN.Tex2.xy)*0.08f
 	            +tex2D(RenderSampler,IN.Tex2.zw)*0.04f
 	            +tex2D(RenderSampler,IN.Tex4.zw)*0.16f
 	            +tex2D(RenderSampler,IN.Tex5.xy)*0.12f
 	            +tex2D(RenderSampler,IN.Tex5.zw)*0.08f
 	            +tex2D(RenderSampler,IN.Tex6.xy)*0.04f;
	return float4(FrameRender,0);	
     }

//--------------
// techniques   
//--------------
    technique BloomH
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS_High(); 
	zwriteenable=false;
	zenable=false;
      }
      }
    technique BloomVLow
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS_Low();
	zwriteenable=false;
	zenable=false;
      }
      }
