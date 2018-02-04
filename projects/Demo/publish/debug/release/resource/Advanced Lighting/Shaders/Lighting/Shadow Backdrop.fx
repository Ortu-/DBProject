//====================================================
// Shadow Fill Backdrop
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

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
     };

//--------------
// vertex shader
//--------------
   OutPut VS(InPut IN) 
     {
 	OutPut OUT;
	OUT.Pos=IN.Pos;
	return OUT;
    }

//--------------
// pixel shader
//--------------
  float4 PS_Vsm(OutPut IN) : COLOR
     {
	return float4(1,2,0,0);
     }
  float4 PS_VsmBa(OutPut IN) : COLOR
     {
	return float4(0,0,1,2);
     }
  float4 PS_Evsm(OutPut IN) : COLOR
     {
	float2 DepthExp=exp(float2(3.5f,-3.5f));
	return float4(DepthExp.x,DepthExp.y,DepthExp.x*DepthExp.x,DepthExp.y*DepthExp.y);
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
      }
      }