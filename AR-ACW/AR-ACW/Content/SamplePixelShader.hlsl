// Per-pixel color data passed through the pixel shader.
cbuffer ModelViewProjectionConstantBuffer : register(b0)
{
    matrix model;
    matrix view;
    matrix projection;
    //float time;
};


struct PixelShaderInput
{
    float4 pos : SV_POSITION;
    float3 color : COLOR0;
    float2 uv : texcolor0;
};



// A pass-through function for the (interpolated) color data.
float4 main(PixelShaderInput input) : SV_TARGET
{
    
    if (length(input.uv) > .10f)
        return float4(input.color, 1.0f);
    
    return (float4) 0.f;

}
