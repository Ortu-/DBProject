//====================================================
// Underwater
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   float time:Time;

//--------------
// tweaks
//--------------
   float Amount=0.5f;
   float4 Scale={1.0f,1.0f,0.5f,0.5f};
   float4 Speed={-0.1,0.1,0.1,-0.1};

//--------------
// Textures
//--------------
   texture WaterDistortTexture <string Name=""; >; 
   sampler WaterDistortSampler=sampler_state 
      {
	Texture=<WaterDistortTexture>;
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
 	float4 Tex:TEXCOORD0;
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=IN.Pos; 
 	OUT.Tex.xy=((float2(IN.Pos.x,-IN.Pos.y)+1.0)*0.5);
 	OUT.Tex=float4(OUT.Tex.xy,OUT.Tex.xy)*Scale+(time*Speed);
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS(OutPut IN) : COLOR
     {
	return float4(0.5f+((tex2D(WaterDistortSampler,IN.Tex.xy).xy+tex2D(WaterDistortSampler,IN.Tex.zw).xy)-1)*Amount,0,1);	
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
	zwriteenable=false;
        ColorWriteEnable=7;
      }
      }