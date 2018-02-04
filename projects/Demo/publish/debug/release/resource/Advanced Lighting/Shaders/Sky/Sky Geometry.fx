//====================================================
// Sky Geometry
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix World:World;
   matrix WorldVP:WorldViewProjection; 
   matrix WorldIT:WorldInverseTranspose;
   matrix WorldV:WorldView; 
   matrix ViewInv:ViewInverse;
   matrix PreviousVP;
   matrix OrthoProj;

//--------------
// structs 
//--------------
   struct In_WPosition
     {
 	float4 Pos:POSITION; 
     };
   struct Out_WPosition
     {
 	float4 Pos:POSITION; 
 	float4 ViewPos:TEXCOORD0;
    	float4 CurrentPos:TEXCOORD1;
    	float4 PreviousPos:TEXCOORD2;
    	float ClipY:TEXCOORD3;
     };

//--------------
// vertex shader
//--------------
   Out_WPosition VS_WPosition(In_WPosition IN) 
     {
 	Out_WPosition OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
	OUT.ViewPos=float4(mul(IN.Pos,WorldV).xyz,OUT.Pos.z);
 	OUT.CurrentPos=OUT.Pos;
	OUT.PreviousPos=mul(mul(IN.Pos,World),PreviousVP);
	OUT.ClipY=mul(IN.Pos,World).y;
	return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS_WPosition(Out_WPosition IN) : COLOR
     {
	float2 Velocity=(IN.CurrentPos/IN.CurrentPos.w)-(IN.PreviousPos/IN.PreviousPos.w);
	return float4(length(IN.ViewPos.xyz),IN.ViewPos.w,Velocity);
     }
   float4 PS_WPositionClip(Out_WPosition IN) : COLOR
     {
	clip(saturate(IN.ClipY)-0.1f);
	float2 Velocity=(IN.CurrentPos/IN.CurrentPos.w)-(IN.PreviousPos/IN.PreviousPos.w);
	return float4(length(IN.ViewPos.xyz),IN.ViewPos.w,Velocity);
     }

//--------------
// techniques   
//--------------
   technique WPosition
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS_WPosition();
 	pixelShader  = compile ps_3_0 PS_WPosition(); 
      }
      }
   technique WPositionClip
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS_WPosition();
 	pixelShader  = compile ps_3_0 PS_WPositionClip(); 
      }
      }