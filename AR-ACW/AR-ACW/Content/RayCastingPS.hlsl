// Per-pixel color data passed through the pixel shader.
struct PixelShaderInput
{
    float4 pos : SV_POSITION;
    float2 canvasXY : TEXCOORD0;
};

struct Ray
{
    
    float3 Origin;
    float3 Direction;
    float2 UV;
    
};

struct Sphere
{
    
    float3 Centre;
    float Radius;
    float4 Color;
    
};

struct Cube
{
    
    float3 Centre;
    float3 Rotatation;
    float3 HalfWidth;
    float4 Color;
    
};

#define IDENTITY_MATRIX float4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)

static float4 Eye = float4(0, 0, 5, 1); //eye position
static float nearPlane = 1.0;
static float farPlane = 1000.0;
static float4 LightColor = float4(1, 1, 1, 1);
static float3 LightPos = float3(10, 10, 10);
static float4 backGroundColor = float4(0.36, 0.57, 0.91, 1.0);
static float2 iRes = float2(1200, 900);

static Sphere spherelist[2] =
{
    float3(1, 1, 1), 1, float4(1, 1, 1, 1), 
    float3(1, 1, 1), 1, float4(1, 1, 1, 1) 
    
};

static Cube cube =
{
  
    float3(-1.5, -1, -5), float3(0.0, 1, 0.0), float3(0.5, 0.5, 0.5), float4(0, 1, 0, 1)
    
};

float4x4 rotationAxisAngle(float3 v, float angle)
{
    float s = sin(angle);
    float c = cos(angle);
    float ic = 1.0 - c;

    return float4x4(    v.x * v.x * ic + c,         v.y * v.x * ic - s * v.z,    v.z * v.x * ic + s * v.y,   0.0,
                        v.x * v.y * ic + s * v.z,   v.y * v.y * ic + c,          v.z * v.y * ic - s * v.x,   0.0,
                        v.x * v.z * ic - s * v.y,   v.y * v.z * ic + s * v.x,    v.z * v.z * ic + c,         0.0,
			            0.0,                        0.0,                         0.0,                        1.0);
    
}


float SphereIntersectRay(Sphere s, Ray ray, out bool hit)
{
    
    float t;
    float3 C = s.Centre - ray.Origin; //Hypotenuse
    float A = dot(C, ray.Direction);
    float B = dot(C, C) - A * A;
    
    //float radius = sqrt(s.radius);
    float radius = sqrt(s.Radius);
    
    
    if (B > radius * radius)
    {
        hit = false;
        t = farPlane;
        
    }
    else
    {
        
        float dist = sqrt(radius * radius - B);
        t = A - dist;
        if (t < 0.0f) //max lenght of ray?
        {
            
            hit = false;
            
        }
        else
        {
            
            hit = true;
            
            
        }
        
    }
    
    return t;
    
}

float4x4 inverse(float4x4 m)
{
    float n11 = m[0][0], n12 = m[1][0], n13 = m[2][0], n14 = m[3][0];
    float n21 = m[0][1], n22 = m[1][1], n23 = m[2][1], n24 = m[3][1];
    float n31 = m[0][2], n32 = m[1][2], n33 = m[2][2], n34 = m[3][2];
    float n41 = m[0][3], n42 = m[1][3], n43 = m[2][3], n44 = m[3][3];

    float t11 = n23 * n34 * n42 - n24 * n33 * n42 + n24 * n32 * n43 - n22 * n34 * n43 - n23 * n32 * n44 + n22 * n33 * n44;
    float t12 = n14 * n33 * n42 - n13 * n34 * n42 - n14 * n32 * n43 + n12 * n34 * n43 + n13 * n32 * n44 - n12 * n33 * n44;
    float t13 = n13 * n24 * n42 - n14 * n23 * n42 + n14 * n22 * n43 - n12 * n24 * n43 - n13 * n22 * n44 + n12 * n23 * n44;
    float t14 = n14 * n23 * n32 - n13 * n24 * n32 - n14 * n22 * n33 + n12 * n24 * n33 + n13 * n22 * n34 - n12 * n23 * n34;

    float det = n11 * t11 + n21 * t12 + n31 * t13 + n41 * t14;
    float idet = 1.0f / det;

    float4x4 ret;

    ret[0][0] = t11 * idet;
    ret[0][1] = (n24 * n33 * n41 - n23 * n34 * n41 - n24 * n31 * n43 + n21 * n34 * n43 + n23 * n31 * n44 - n21 * n33 * n44) * idet;
    ret[0][2] = (n22 * n34 * n41 - n24 * n32 * n41 + n24 * n31 * n42 - n21 * n34 * n42 - n22 * n31 * n44 + n21 * n32 * n44) * idet;
    ret[0][3] = (n23 * n32 * n41 - n22 * n33 * n41 - n23 * n31 * n42 + n21 * n33 * n42 + n22 * n31 * n43 - n21 * n32 * n43) * idet;

    ret[1][0] = t12 * idet;
    ret[1][1] = (n13 * n34 * n41 - n14 * n33 * n41 + n14 * n31 * n43 - n11 * n34 * n43 - n13 * n31 * n44 + n11 * n33 * n44) * idet;
    ret[1][2] = (n14 * n32 * n41 - n12 * n34 * n41 - n14 * n31 * n42 + n11 * n34 * n42 + n12 * n31 * n44 - n11 * n32 * n44) * idet;
    ret[1][3] = (n12 * n33 * n41 - n13 * n32 * n41 + n13 * n31 * n42 - n11 * n33 * n42 - n12 * n31 * n43 + n11 * n32 * n43) * idet;

    ret[2][0] = t13 * idet;
    ret[2][1] = (n14 * n23 * n41 - n13 * n24 * n41 - n14 * n21 * n43 + n11 * n24 * n43 + n13 * n21 * n44 - n11 * n23 * n44) * idet;
    ret[2][2] = (n12 * n24 * n41 - n14 * n22 * n41 + n14 * n21 * n42 - n11 * n24 * n42 - n12 * n21 * n44 + n11 * n22 * n44) * idet;
    ret[2][3] = (n13 * n22 * n41 - n12 * n23 * n41 - n13 * n21 * n42 + n11 * n23 * n42 + n12 * n21 * n43 - n11 * n22 * n43) * idet;

    ret[3][0] = t14 * idet;
    ret[3][1] = (n13 * n24 * n31 - n14 * n23 * n31 + n14 * n21 * n33 - n11 * n24 * n33 - n13 * n21 * n34 + n11 * n23 * n34) * idet;
    ret[3][2] = (n14 * n22 * n31 - n12 * n24 * n31 - n14 * n21 * n32 + n11 * n24 * n32 + n12 * n21 * n34 - n11 * n22 * n34) * idet;
    ret[3][3] = (n12 * n23 * n31 - n13 * n22 * n31 + n13 * n21 * n32 - n11 * n23 * n32 - n12 * n21 * n33 + n11 * n22 * n33) * idet;

    return ret;
}

float4x4 translate(float3 pos)
{
    return float4x4( 1.0, 0.0, 0.0, 0.0,
				     0.0, 1.0, 0.0, 0.0,
				     0.0, 0.0, 1.0, 0.0,
				     pos.x, pos.y, pos.z, 1.0);
}

//http://iquilezles.org/www/articles/boxfunctions/boxfunctions.htm
//https://www.math.unl.edu/~gledder1/Math208/DirectionalSlope.pdf
float4 iBox(Ray ray, in float4x4 txx, in float4x4 txi, in float3 rad)
{
    // convert from ray to box space
   
    float3 rdd = mul(float4(ray.Direction, 0.0f), txx).xyz;
    //float3 rdd = ray.Direction;
    float3 roo = mul(float4(ray.Origin, 1.0f), txx).xyz;
    //float3 roo = ray.Origin;

	// ray-box intersection in box space
    float3 m = 1.0 / rdd;
    float3 n = m * roo;
    float3 k = abs(m) * rad;
	
    float3 t1 = -n - k;
    float3 t2 = -n + k;
    
    
    float tN = max(max(t1.x, t1.y), t1.z);
    float tF = min(min(t2.x, t2.y), t2.z);
    
    
    if (tN > tF || tF < 0.0)
        return (float4) -1.0;

    float3 nor = -sign(rdd) * step(t1.yzx, t1.xyz) * step(t1.zxy, t1.xyz);

    // convert to ray space
	
    nor = mul(float4(nor, 0.0), txi).xyz;

    return float4(tN, nor);
}

//http://iquilezles.org/www/articles/checkerfiltering/checkerfiltering.htm
// checkers, in smooth xor form
float checkers(in float3 p)
{
    
    float2 s = sign(frac(p * 0.5) - 0.5);
    return 0.5 - 0.5 * s.x * s.y;
    
}

float checkersGrad(in float2 uv, in float2 ddx, in float2 ddy)
{
    
    float2 w = max(abs(ddx), abs(ddy)) + 0.01;
    float2 i = (frac(uv + 0.5 * w) - frac(uv - 0.5 * w)) / w;
    return 0.5 - 0.5 * i.x * i.y;
    
}


float3 NearestHit(Ray ray, out int hitobj, out bool anyhit, out float3 normal)
{
    
    //normal = float3(0, 0, 0);
    //float4x4 txi = (float4x4)1.0f;
    float4x4 rot = rotationAxisAngle(cube.Rotatation, 0.0);
    float4x4 tra = translate(cube.Centre);
    float4x4 txi = mul(rot, tra);
    float4x4 txx = inverse(txi);
    
    float mint = farPlane;
    hitobj = -1;
    anyhit = false;
    float4 t = iBox(ray, txx, txi, float3(cube.HalfWidth));
    
    if (t.x > 0.0 && t.x < mint)
    {
            
        mint = t.x;
        normal = t.yzw;
        anyhit = true;
        
    }
    
    return ray.Origin + ray.Direction * mint;
    
}

float4 Phong(float3 normal, float3 lightDir, float3 viewDir, float shininess, float4 diffuseColor, float4 specularColor)
{
    
    float NdotL = dot(normal, lightDir);
    float diff = saturate(NdotL);
    float3 reflectL = reflect(lightDir, normal);
    
    float spec = pow(saturate(dot(viewDir, reflectL)), shininess) * (NdotL > 0.0f);
    return diff * diffuseColor + spec * specularColor;
    
}

float4 Shade(float3 hitPos, float3 normal, float3 viewDir, int hitobj, float lightIntensity)
{
    float3 lightDir = normalize(LightPos - hitPos);
    float4 diff = cube.Color;
    float4 spec = cube.Color;
    
    return LightColor * lightIntensity * Phong(normal, lightDir, viewDir, cube.Color.w, diff, spec);
    
}



float4 RayTracing(Ray ray)
{
    
    int hitobj;
    bool hit = false;
    float3 n;
    float4 c = (float4) 0.f;
    float lightintensity = 1.0f;
    float3 normal;
    
    
    float3 i = NearestHit(ray, hitobj, hit, normal); 
    
    if (hit)
    {
        
        
        float2 px = (2.0 * (ray.UV + float2(1.0, 0.0)) - iRes.xy) / iRes.y;
        float2 py = (2.0 * (ray.UV + float2(0.0, 1.0)) - iRes.xy) / iRes.y;
        float3 rdx = Eye.xyz * normalize(float3(px, 2.5));
        float3 rdy = Eye.xyz * normalize(float3(py, 2.5));
        
        c += Shade(i, normal, ray.Direction, 1, 1);
        c *= checkers(i*5.0);
        //c *= checkersGrad(i.xz * 5.0, rdx.xz * 5.0, rdy.xz * 5.0);
        
    }
    else
    {
        
        c = backGroundColor;
        
    }
    
    
    //[unroll(10)]
  //  for (uint depth = 1; depth < 3; depth++)
  //  {
  //      
  //      if (hit)
  //      {
  //          
  //          // n = getnormal;
  //          //c = shade;
  //          c = (flaot4) 1.0f;
  //          
  //      }
  //      
  //      
  //  }
    
    return c;
}


float4 main(PixelShaderInput input) : SV_TARGET
{
    
    Ray ray;
    
    ray.UV = input.canvasXY;
    ray.Origin = Eye.xyz;
    float dist2Imageplane = 5.f;
    float3 viewDir = float3(input.canvasXY, -dist2Imageplane);
    //viewDir = float3(0, 0, -dist2Imageplane);
    
    ray.Direction = normalize(viewDir);
    
    
    
    return RayTracing(ray);
}
