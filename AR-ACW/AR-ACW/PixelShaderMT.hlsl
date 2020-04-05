struct VS_QUAD
{
    
    float4 Position : SV_Position;
    float2 canvasXY : TEXCOORD0;
};


float4 main(VS_QUAD input) : SV_TARGET
{
	
    return (float4)1.0f;

}