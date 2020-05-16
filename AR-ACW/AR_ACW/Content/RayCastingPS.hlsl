// Per-pixel color data passed through the pixel shader.
cbuffer ModelViewProjectionConstantBuffer : register(b0)
{
    matrix model;
    matrix view;
    matrix projection;
    float time;
};

struct PixelShaderInput
{
    float4 pos : SV_POSITION;
    float2 canvasXY : TEXCOORD0;
};

struct Ray
{
    
    float3 Origin;
    float3 Direction;
    
};

struct Object
{
    
    float3 Centre;
    float3 Rotatation;
    float3 HalfWidth;
    float4 Color;
    float Kd, Ks, Kr, shininess;
    
};


//struct Sphere
//{
    
//    float3 Centre;
//    float Radius;
//    float4 Color;
    
//};

//struct Cube
//{
    
//    float3 Centre;
//    float3 Rotatation;
//    float3 HalfWidth;
//    float4 Color;
    
//};

#define IDENTITY_MATRIX float4x4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)

static float4 Eye = float4(0, 4, 15, 1); //eye position
static float nearPlane = 1.0;
static float farPlane = 1000.0;
static float4 LightColor = float4(1, 1, 1, 1);
static float3 LightPos = float3(0, 10, 0);
static float4 backGroundColor = float4(0.1, 0.2, 0.3, 1.0);
static float shininess = 40;
static float RMshininess = 20;
static float Epsilon = 0.0001f;
static float start = 0.f;
static float end = 1000.f;
static float3 K_a = float3(0.2, 0.2, 0.2);
static float3 K_d = float3(0.85, 0.85, 0.85);
static float3 K_s = float3(1.0, 1.0, 1.0);
static float EPSILON = 0.0001;

static Object objects[3] =
{
    
    float3(-3, 2.5, -8), float3(0.0, 0.0, 0.0), float3(0.5, 0.5, 0.5), float4(1, 0, 0, 1), 0.3, 0.5, 0.7, shininess, 
    float3(-5, 2.25, -8), float3(0.0, 0.0, 0.0), float3(0.25, 0.25, 0.25), float4(0, 1, 0, 1), 0.5, 0.7, 0.4, shininess,
    float3(-4, 1, -8), float3(0.0, 1.0, 0.0), float3(1.5, 0.5, 1.5), float4(0.9, 0.9, 0.9, 1), 0.5, 0.3, 0.3, shininess,
    
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

float4 SphereIntersectRay(Object s, Ray ray)
{
    
    float4 t;
    float3 C = s.Centre - ray.Origin; //Hypotenuse
    float A = dot(C, ray.Direction);
    float B = dot(C, C) - A * A;
    float radius = sqrt(s.HalfWidth.x);

    if (B > radius * radius)
    {
        
        t = (float4) -1.0;
        
    }
    else
    {
        
        float dist = sqrt(radius * radius - B);
        t.x = A - dist;
        if (t.x < 0.0f) 
        {
            
           
            t = (float4) -1.0;
        }
        else
        {
            
            t.yzw = normalize((ray.Origin + ray.Direction * t.x) - s.Centre);
        }
        
    }
    
    return t;
    
}



//http://iquilezles.org/www/articles/boxfunctions/boxfunctions.htm
//https://www.math.unl.edu/~gledder1/Math208/DirectionalSlope.pdf
float4 iBox(Ray ray, in float4x4 txx, in float4x4 txi, in float3 rad)
{
    // convert from ray to box space
   
    float3 rdd = mul(float4(ray.Direction, 0.0f), txx).xyz;
    float3 roo = mul(float4(ray.Origin, 1.0f), txx).xyz;

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
float checkers(in float2 p)
{
    
    float chess = floor(p.x) + floor(p.y);
    chess = frac(chess * 0.5);
    
    chess *= 2.f;
    return chess;
    
}

float checkersGrad(in float2 uv, in float2 ddx, in float2 ddy)
{
    
    float2 w = max(abs(ddx), abs(ddy)) + 0.04;
    float2 i = (frac(uv + 0.5 * w) - frac(uv - 0.5 * w)) / w;
    return 0.5 - 0.5 * i.x * i.y;
    
}


float3 NearestHit(Ray ray, out int hitobj, out bool anyhit, out float3 normal, in float4x4 txi, in float4x4 txx)
{
   
    float mint = farPlane;
    hitobj = -1;
    anyhit = false;
    
    float4 t;
    
    
    for (uint i = 0; i < 3; i++)
    {
       
        
        if (i == 2)
            t = iBox(ray, txx, txi, float3(objects[i].HalfWidth));
        else
            t = SphereIntersectRay(objects[i], ray);
            
      
        if (t.x > 0.0 && t.x < mint)
        {
            
            hitobj = i;
            mint = t.x;
            normal = t.yzw;
            anyhit = true;
            
        }
        
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
    float4 diff = objects[hitobj].Color * objects[hitobj].Kd;
    float4 spec = objects[hitobj].Color * objects[hitobj].Ks;
    
    Ray shadowray;
    shadowray.Direction = lightDir;
    shadowray.Origin = hitPos + lightDir * 0.005;
    int shadowHit;
    bool anyhit;
    float4x4 rot = rotationAxisAngle(objects[2].Rotatation, 0.0);
    float4x4 tra = translate(objects[2].Centre);
    float4x4 txi = mul(rot, tra);
    float4x4 txx = inverse(txi);
    float3 normal1;
    
    float3 i = NearestHit(shadowray, shadowHit, anyhit, normal1, txi, txx);
    
    float4 light = LightColor * lightIntensity * Phong(normal, lightDir, viewDir, objects[hitobj].shininess, diff, spec);
    
    if(anyhit && shadowHit != hitobj)
        light *= 0.6;
    
    return light;
    
}

float4 RayTracing(Ray ray, float4 color)
{
    
    int hitobj;
    bool hit = false;
    float3 n;
    float4 c = (float4) 0.f;
    float lightintensity = 1.0f;
    float3 normal;
    bool anyhit = false;
    
    float4x4 rot = rotationAxisAngle(objects[2].Rotatation, 0.0);
    float4x4 tra = translate(objects[2].Centre);
    float4x4 txi = mul(rot, tra);
    float4x4 txx = inverse(txi);
    
    //float i = farPlane;
    
    float3 i = NearestHit(ray, hitobj, hit, normal, txi, txx); 
    
    for (uint depth = 1; depth < 4; depth++)
    {
        
        if (hit)
        {
            anyhit = true;
              
            c += Shade(i, normal, ray.Direction, hitobj, lightintensity);
            
            if (hitobj == 2)
            {
                   float3 nor = mul(float4(normal, 0.0), txx).xyz;
                   float2 xer = float2(0.f, 0.f);
        
                   if (abs(nor.x) == 1)
                       xer = i.yz;
        
                   if (abs(nor.y) == 1)
                       xer = i.xz;
        
                   if (abs(nor.z) == 1)
                       xer = i.xy;
                   c *= checkers(xer * 5.0);
               
            }
            
            lightintensity *= objects[hitobj].Kr;
            ray.Origin = i;
            ray.Direction = reflect(ray.Direction, normal);
            i = NearestHit(ray, hitobj, hit, normal, txi, txx);
                
        
            
            
        }
        else
        {
        
            c += backGroundColor / depth/ depth;
        
        }
        
    }
    
    if (!anyhit)
        return color;
    
    
    return c;
}


/**
 * Signed distance function for a sphere centered at the origin with radius 1.0;
 */
float3 hash3(in float2 p)
{
    float3 q = float3(dot(p, float2(127.1, 311.7)),
				   dot(p, float2(269.5, 183.3)),
				   dot(p, float2(419.2, 371.9)));
    return frac(sin(q) * 43758.5453);

}

//then the code for our new generalized super pattern could be like this:

float noise(in float2 x, float u, float v)
{
    float2 p = floor(x);
    float2 f = frac(x);

    float k = 1.0 + 63.0 * pow(1.0 - v, 4.0);
    float va = 0.0;
    float wt = 0.0;
    [unroll(5)]
    for (int j = -2; j <= 2; j++)
        [unroll(5)]
        for (int i = -2; i <= 2; i++)
        {
            float2 g = float2(float(i), float(j));
            float3 o = hash3(p + g) * float3(u, u, 1.0);
            float2 r = g - f + o.xy;
            float d = dot(r, r);
            float w = pow(1.0 - smoothstep(0.0, 1.414, sqrt(d)), k);
            va += w * o.z;
            wt += w;
        }

    return va / wt;
}

float smin(float a, float b, float k)
{
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return lerp(b, a, h) - k * h * (1.0 - h);
}

float ssub(float a, float b, float k)
{
    float h = clamp(0.5 - 0.5 * (b + a) / k, 0.0, 1.0);
    return lerp(b, -a, h) - k * h * (1.0 - h);
}

float sint(float a, float b, float k)
{
    float h = clamp(0.5 - 0.5 * (b - a) / k, 0.0, 1.0);
    return lerp(b, a, h) + k * h * (1.0 - h);
}

float3x3 rotateY(float angle)
{
    float c = cos(angle), s = sin(angle);
    return float3x3(c, 0, s, 0, 1, 0, -s, 0, c);
}

float sdCappedCylinder(float3 p, float h, float r)
{
    float2 d = abs(float2(length(p.xz), p.y)) - float2(r, h);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}
float sdTorus(float3 p, float2 t)
{
    float2 q = float2(length(p.xz) - t.x, p.y);
    return length(q) - t.y;
}
float sdRoundBox(float3 p, float3 b, float r)
{
    float3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

float sdBox(float3 p, float3 b)
{
    float3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdSphere(float3 p, float r)
{
    return length(p) - r;
}
float sdYPlane(float3 p, float y)
{
    
    return p.y + noise(float2(p.x, p.z) , 1.0, 1.0)  - y;
}

float3 opRepLim(in float3 p, in float s, in float3 lima, in float3 limb)
{
    return p - s * clamp(round(p / s), lima, limb);
}

float3 opRep(in float3 p, in float s)
{
    return p - s * round(float3(0.f, 0.f, p.z) / s);
}

#define mod(x, y) (x - y * floor(x / y))

float sceneSDF(float3 samplePoint)
{
    
    float t = 1000000.f;
    samplePoint.z += 4.0;
    samplePoint.y -= 3.5;
    float3 p = samplePoint;
    p.x -= 1.5f;
    //Columns
    p = opRepLim(p, 2.0f, float3(0.0f, 0.f, -4.f), float3(0.f, 0.f, 4.f));
    float3x3 ry = rotateY(6. * p.y);
    t = smin(t, sdTorus(p + float3(0.0, -0.65, 0.0), float2(0.1, 0.02)), 0.007);
    t = smin(t, sdTorus(p + float3(0.0, 0.65, 0.0), float2(0.1, 0.02)), 0.007);
    t = smin(t, sdRoundBox(p + float3(0.0, -0.68, 0.0), float3(0.13, 0.01, 0.13), 0.01), 0.007);
    t = smin(t, sdRoundBox(p + float3(0.0, 0.71, 0.0), float3(0.13, 0.04, 0.13), 0.01), 0.009);
    p = mul(p, ry);
    p.x -= 0.025;
    p.z -= 0.025;
    t = smin(t, sdCappedCylinder(p, 0.65, 0.05), 0.005);
    p.x += 0.05;
    t = smin(t, sdCappedCylinder(p, 0.65, 0.05), 0.005);
    p.z += 0.05;
    t = smin(t, sdCappedCylinder(p, 0.65, 0.05), 0.005);
    p.x -= 0.05;
    t = smin(t, sdCappedCylinder(p, 0.65, 0.05), 0.005);
    //Plane
    t = min(t, sdYPlane(samplePoint, -1.f));
    //Infinite Shapes
    float3 iS = opRep(samplePoint, 1.0f);
    t = min(t, sdTorus(iS + float3(-2.f, 0.f, 0.f), float2(0.2, 0.04)));
    t = min(t, sdSphere(iS + float3(-3.f, 0.f,0.f), 0.1f));
    //Implicit geometric object 1
    float3 obj = samplePoint - float3(-1.0, 2.0, 0.0);
    float t1 = sdRoundBox(obj, (float3) 0.3, 0.01);
    t1 = sint(t1, sdSphere(obj, 0.43), 0.002);
    float pSin = sin(time * 0.5) * 0.45;
    float mSin = sin(-time * 0.5) * 0.45;
    t1 = smin(t1, sdSphere(obj + (float3) pSin, 0.18), 0.2);
    t1 = smin(t1, sdSphere(obj + (float3) mSin, 0.18), 0.2);
    t1 = smin(t1, sdSphere(obj + float3(-mSin, mSin, mSin), 0.18), 0.2);
    t1 = smin(t1, sdSphere(obj + float3(-pSin, pSin, pSin), 0.18), 0.2);
    //Implicit geometric object 2
    obj.x += 2.f;
    float d = sdRoundBox(obj, float3(1.0, 1.0, 1.0), 0.0);

    float s = 1.0 + sin(time);
    [unroll(3)]
    for (int m = 0; m < 3; m++)
    {
        float3 a = mod(obj * s, 2.0) - 1.0;
        s *= 3.0;
        float3 r = abs(1.0 - 3.0 * abs(a));
    
        float da = max(r.x, r.y);
        float db = max(r.y, r.z);
        float dc = max(r.z, r.x);
        float c = (min(da, min(db, dc)) - 1.0) / s;
    
        d = max(d, c);
    }
    t1 = min(t1, d);
    
    return min(t, t1);
    
}

float3 estimateNormal(float3 p)
{
    return normalize(float3(
        sceneSDF(float3(p.x + EPSILON, p.y, p.z)) - sceneSDF(float3(p.x - EPSILON, p.y, p.z)),
        sceneSDF(float3(p.x, p.y + EPSILON, p.z)) - sceneSDF(float3(p.x, p.y - EPSILON, p.z)),
        sceneSDF(float3(p.x, p.y, p.z + EPSILON)) - sceneSDF(float3(p.x, p.y, p.z - EPSILON))
    ));
}

float3 phongContribForLight(float3 k_d, float3 k_s, float alpha, float3 p, float3 eye,
                          float3 lightPos, float3 lightIntensity)
{
    float3 N = estimateNormal(p);
    float3 L = normalize(lightPos - p);
    float3 V = normalize(eye - p);
    float3 R = normalize(reflect(-L, N));
    
    float dotLN = clamp(dot(L, N), 0.0001, 1.0);
    float dotRV = dot(R, V);
    
    if (dotLN < 0.0)
    {
        // Light not visible from this point on the surface
        return float3(0.0, 0.0, 0.0);
    }
    
    if (dotRV < 0.0)
    {
        // Light reflection in opposite direction as viewer, apply only diffuse
        // component
        return lightIntensity * (k_d * dotLN);
    }
    return lightIntensity * (k_d * dotLN + k_s * pow(dotRV, alpha));
}

float4 phongIllumination(float3 k_a, float3 k_d, float3 k_s, float alpha, float3 p, float3 eye)
{
    const float3 ambientLight = 0.5 * float3(1.0, 1.0, 1.0);
    float3 color = ambientLight * k_a;
    
    
    float3 light1Intensity = float3(0.4, 0.4, 0.4);
    
    color += phongContribForLight(k_d, k_s, alpha, p, eye,
                                  LightPos - float3(-2.0, 0.0, -10.f),
                                  light1Intensity);

    return float4(color, 1.f);
}

float RayMarching(Ray ray)
{
    
    float depth = start;
    
    for (uint i = 0; i < 255; i++)
    {
        
        float dist = sceneSDF(ray.Origin + ray.Direction * depth);
        if (dist < Epsilon)
            return depth;
        depth += dist;
        if (depth >= end)
            return end;
        
        
    }
    
    return end;
    
}


float4 main(PixelShaderInput input) : SV_TARGET
{
    
    Ray ray;
    
    ray.Origin = Eye.xyz;
    float dist2Imageplane = 5.f;
    float3 viewDir = float3(input.canvasXY, -dist2Imageplane);
    
    ray.Direction = normalize(viewDir);
      
    float4 color = backGroundColor;
    
    //float4 color = (float4) 0.f; //RayTracing(ray);
    float dist = RayMarching(ray);
    if (dist <= end - Epsilon)    
        color = phongIllumination(K_a, K_d, K_s, RMshininess, ray.Origin + dist * ray.Direction, Eye.xyz);;
    
    color = RayTracing(ray, color);
    
   
    
   
    
    return color;
}
