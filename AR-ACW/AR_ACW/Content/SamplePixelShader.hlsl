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

Texture2D txColor : register(t0);
SamplerState txSampler : register(s0);

// A pass-through function for the (interpolated) color data.
float4 main(PixelShaderInput input) : SV_TARGET
{
    
    float4 color = txColor.Sample(txSampler, input.uv);
    
    if (color.a < 0.0001 || length(color.rgb) < 0.1)
        discard;
    //if (input.uv.y < 0.3)
    //    return float4(1.0, 0.0, 0.0, 1.0);
    //if (input.uv.y < 0.6)
    //    return float4(0.0, 1.0, 0.0, 1.0);
    //return float4(0.0, 0.0, 1.0, 1.0);
    
    return color;
    //return (float4)1.0;

}
