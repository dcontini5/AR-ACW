// A constant buffer that stores the three basic column-major matrices for composing geometry.
cbuffer ModelViewProjectionConstantBuffer : register(b0)
{
    matrix model;
    matrix view;
    matrix projection;
};

// Per-vertex data used as input to the vertex shader.
struct VertexShaderInput
{
	float3 pos : POSITION;
	float3 color : COLOR0;
};

// Per-pixel color data passed through the pixel shader.
struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float2 canvasXY : TEXCOORD0;
};

// Simple shader to do vertex processing on the GPU.
PixelShaderInput main(VertexShaderInput input)
{
	PixelShaderInput output;
    output.pos = float4(sign(input.pos.xy), 0.f, 1.f);

    float aspectRatio = projection._m11 / projection._m00;
    
    output.canvasXY = sign(input.pos.xy) * float2(aspectRatio, 1.0f);
    
	// Pass the color through without modification.
    //output.color = float3(0.36, 0.57, 0.91);
    //output.color = float3(1, 0, 0.0);

	return output;
}
