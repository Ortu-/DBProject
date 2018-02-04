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
   texture InTexture <string Name = "";>;
   sampler InSampler=sampler_state
      {
	Texture=<InTexture>;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
	AddressU=Border;
	AddressV=Border;
	AddressW=Border;
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
 	OUT.Tex=((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5)+ViewSize;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {
	return tex2D(InSampler,IN.Tex).xyzw;
     }

//--------------
// techniques   
//--------------
   technique TextureUpdate
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS();
 	pixelShader  = compile ps_3_0 PS();
	zwriteenable=false;
      }
      }