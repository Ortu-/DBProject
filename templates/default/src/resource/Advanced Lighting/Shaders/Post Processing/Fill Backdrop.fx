//====================================================
// Fill Backdrop
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// tweaks
//--------------
   float4 ViewSize;

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
	MagFilter=Point;
	MinFilter=Point;
	MipFilter=Point;
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
	OUT.Pos=IN.Pos; 
 	OUT.Tex=(((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)*ViewSize.zw)+ViewSize.xy;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {
	return tex2D(RenderSampler,IN.Tex);	
     }

//--------------
// techniques   
//--------------
    technique FillBackdrop
      {
 	pass p1
      {	
 	VertexShader = compile vs_3_0 VS();
 	PixelShader  = compile ps_3_0 PS(); 
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }