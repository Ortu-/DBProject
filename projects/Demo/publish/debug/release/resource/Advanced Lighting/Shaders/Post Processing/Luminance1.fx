//====================================================
// Luminance Filter 1
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
  	OUT.Tex=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)*ViewSize.zw)+ViewSize.xy;
	OUT.Tex1.xy=OUT.Tex+float2(-ViewVec.x,0);//*2;
	OUT.Tex1.zw=OUT.Tex+float2(ViewVec.x,0);//*2;
	OUT.Tex2.xy=OUT.Tex+float2(0,-ViewVec.y);//*2;
	OUT.Tex2.zw=OUT.Tex+float2(0,ViewVec.y);//*2;
	OUT.Tex3.xy=OUT.Tex+float2(-ViewVec.x,-ViewVec.y);//*2;
	OUT.Tex3.zw=OUT.Tex+float2(ViewVec.x,ViewVec.y);//*2;
	OUT.Tex4.xy=OUT.Tex+float2(ViewVec.x,-ViewVec.y);//*2;
	OUT.Tex4.zw=OUT.Tex+float2(-ViewVec.x,ViewVec.y);//*2;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {
	float3 LumSum=tex2D(RenderSampler,IN.Tex)
	             +tex2D(RenderSampler,IN.Tex1.xy)
	             +tex2D(RenderSampler,IN.Tex1.zw)
	             +tex2D(RenderSampler,IN.Tex2.xy)
	             +tex2D(RenderSampler,IN.Tex2.zw)
	             +tex2D(RenderSampler,IN.Tex3.xy)
	             +tex2D(RenderSampler,IN.Tex3.zw)
	             +tex2D(RenderSampler,IN.Tex4.xy)
	             +tex2D(RenderSampler,IN.Tex4.zw);
	return float4(0.05f+dot(LumSum/9,float3(0.314f,0.387f,0.299f))/0.98f,0,0,0);				
     }  

//--------------
// techniques   
//--------------
    technique LuminanceSum
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS();
	zwriteenable=false;
	zenable=false;
        ColorWriteEnable=1;
      }
      }
