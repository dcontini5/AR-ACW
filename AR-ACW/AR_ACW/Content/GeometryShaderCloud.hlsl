cbuffer ModelViewProjectionConstantBuffer : register(b0)
{
    matrix model;
    matrix view;
    matrix projection;
    float time;
    float3 cBPos;
};


struct GSInput
{
    
    float4 pos : SV_Position;
    float3 color : color0;
    
};

struct GSOutput
{
    float4 pos : SV_POSITION;
    float3 color : color0;
    float2 uv : texcolor0;
};

static const float3 g_position[4] =
{
    
    float3(-1, 1, 0),
    float3(-1, -1, 0),
    float3(1, 1, 0),
    float3(1, -1, 0)
    
};

[maxvertexcount(9)]
void main(
	point GSInput input[1] : SV_POSITION,
	inout TriangleStream< GSOutput > outputStream
)
{
    
    GSOutput output = (GSOutput) 0;
    float4 pos = input[0].pos + float4(cBPos*0.5, 0.f);
    pos.z -= 1.f;
    pos = mul(pos, model);
    pos = mul(pos, view);
    
    float quadSize = 0.3f;
    
    
    output.pos = pos + float4(quadSize * g_position[0], 0.f);
    output.pos = mul(output.pos, projection);
    output.color = input[0].color;
    output.uv = g_position[1].xy;
    
    outputStream.Append(output);
    
    output.pos = pos + float4(quadSize * g_position[1], 0.f);
    output.pos = mul(output.pos, projection);
    output.color = input[0].color;
    output.uv = g_position[0].xy;
    
    outputStream.Append(output);
    
    output.pos = pos + float4(quadSize * g_position[2], 0.f);
    output.pos = mul(output.pos, projection);
    output.color = input[0].color;
    output.uv = g_position[3].xy;
    
    outputStream.Append(output);
    
    outputStream.RestartStrip();
    
    
    output.pos = pos + float4(quadSize * g_position[1], 0.f);
    output.pos = mul(output.pos, projection);
    output.color = input[0].color;
    output.uv = g_position[0].xy;
    
    outputStream.Append(output);
    
    output.pos = pos + float4(quadSize * g_position[2], 0.f);
    output.pos = mul(output.pos, projection);
    output.color = input[0].color;
    output.uv = g_position[3].xy;
    
    outputStream.Append(output);
        
    output.pos = pos + float4(quadSize * g_position[3], 0.f);
    output.pos = mul(output.pos, projection);
    output.color = input[0].color;
    output.uv = g_position[2].xy;
    
    outputStream.Append(output);
    
    outputStream.RestartStrip();
   
}