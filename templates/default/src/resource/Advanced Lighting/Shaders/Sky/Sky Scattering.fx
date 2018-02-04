//====================================================
// Sky for light scattering
//====================================================
// By EVOLVED
// www.evolved-software.com
//====================================================

//--------------
// un-tweaks
//--------------
   matrix WorldVP:WorldViewProjection;
   matrix World:World;
   matrix ViewInv:ViewInverse;
   matrix ProjMat={0.5,0,0,0.5,0,-0.5,0,0.5,0,0,0.5,0.5,0,0,0,1};
   float time:Time;

//--------------
// tweaks
//--------------
   float4 ViewSize;
   float CameraRange;
   float3 LightDirection;
   float2 Overcast;
   float2 CloudDensity;
   float2 CloudScale;
   float2 CloudSpeed;

//--------------
// Textures
//--------------
   texture DepthTexture <string Name = "";>;
   sampler DepthSampler=sampler_state 
      {
	Texture=<DepthTexture>;
	MagFilter=None;
	MinFilter=None;
	MipFilter=None;
      };
   texture CloudTexture <string Name=""; >;
   sampler CloudSampler=sampler_state 
      {
	Texture=<CloudTexture>;
      };

//--------------
// structs 
//--------------
   struct In_Sky
     {
        float4 Pos:POSITION;
     };
   struct Out_Sky
     {
 	float4 Pos:POSITION; 
	float4 Proj:TEXCOORD1;
	float3 Normal:TEXCOORD2;
	float3 WPos:TEXCOORD3;
	float3 ViewPos:TEXCOORD4;
     };

//--------------
// vertex shader
//--------------
   Out_Sky VS_Sky(In_Sky IN) 
     {
 	Out_Sky OUT;
	OUT.Pos=mul(IN.Pos,WorldVP);
	OUT.Proj=float4(OUT.Pos.x*0.5+0.5*OUT.Pos.w,0.5*OUT.Pos.w-OUT.Pos.y*0.5,OUT.Pos.w,OUT.Pos.z);
	OUT.Normal=-IN.Pos;
	OUT.WPos=mul(IN.Pos,World);
	OUT.ViewPos=OUT.WPos-ViewInv[3].xyz;
	return OUT;
     }

//--------------
// pixel shader
//--------------
   float4 PS_Sky(Out_Sky IN) : COLOR
     {
	IN.Normal=normalize(IN.Normal);
	clip((tex2D(DepthSampler,((IN.Proj.xy/IN.Proj.z)*ViewSize.zw)+ViewSize.xy).y+CameraRange)-IN.Proj.w);
	clip((saturate(IN.WPos.y)-0.1f));
	float2 CloudUV=(IN.ViewPos.xz/IN.ViewPos.y);
	CloudUV=(CloudUV/CloudScale)+(time*CloudSpeed);
	float Clouds=pow(tex2D(CloudSampler,CloudUV),CloudDensity.x)*saturate(-(IN.Normal.y+0.05f)*2);
	float Horizon=lerp(saturate(exp((IN.Normal.y+Overcast.x)*2.5f)),saturate(exp(IN.Normal.y*2.5f)),Overcast.y);
	float Sun=pow(dot(IN.Normal,LightDirection),128);
	return float4(0,0,lerp((0.1f+Sun*0.75f)*(1-pow(Horizon,32)),0,Clouds*CloudDensity.y),0);
     }

//--------------
// techniques   
//--------------
   technique Sky
      {
 	pass p1
      {	
 	vertexShader = compile vs_3_0 VS_Sky();
 	pixelShader  = compile ps_3_0 PS_Sky();
        ColorWriteEnable=4;
      }
      }