struct VS_QUAD
{
    
    float4 Position : SV_Position;
    float2 canvasXY : TEXCOORD0;
};

struct Ray
{
    
    float3 Origin;
    float3 Direction;
    
};

static float4 Eye = float4(0, 0, 15, 1); //eye position
static float nearPlane = 1.0;
static float farPlane = 1000.0;
static float4 LightColor = float4(1, 1, 1, 1);
static float3 LightPos = float3(0, 10, 0);
static float4 backgroundColor = float4(0.1, 0.2, 0.3, 1);


float4 RayTracing(Ray ray)
{
    
    return (float4) 0.f;
    
}


float4 main(VS_QUAD input) : SV_TARGET
{
	
    Ray eyeray;
    
    eyeray.Origin = Eye.xyz;
    float dist2Imageplane = 5.f;
    float3 viewDir = float3(input.canvasXY, -dist2Imageplane);
    viewDir = normalize(viewDir);
    
    eyeray.Direction = viewDir;
    
    return RayTracing(eyeray);

}