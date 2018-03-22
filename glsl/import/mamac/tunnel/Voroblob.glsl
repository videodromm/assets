// https://www.shadertoy.com/view/lsGcDz
vec3 cameraTarget = vec3(0.0, 0.0, 0.0);
vec3 upDirection = vec3(0.0, 1.0, 0.0);

const int MAX_ITER = 100; 
const float MAX_DIST = 150.0; 
const float EPSILON = 0.01;
vec3 lightPosition1 = vec3(20.0,10.0,100.0);
vec3 lightPosition2 = vec3(-200.0,100.0,-100.0);

float wang(uint u)
{
    uint seed = (u*1664525u);
    
    seed  = (seed ^ 61u) ^(seed >> 16u);
    seed *= 9u;
    seed  = seed ^(seed >> 4u);
    seed *= uint(0x27d4eb2d);
    seed  = seed ^(seed >> 15u);
    
    float value = float(seed) / (4294967296.0);
    return value;
}

//voronoi seeds
vec3 pointgen(uint i)
{
    vec3 nice;
    nice.x += cos(iGlobalTime+wang(i+3u)*3.14f*2.0f);
    nice.y += sin(iGlobalTime+wang(i)*3.14f*2.0f);
    nice.z += cos(iGlobalTime+wang(i+5u)*3.14f*2.0f);
    return normalize(2.0f*nice);
}

#define MAXPOINTS 32u

float smin( float a, float b, float k )
{
    float res = exp( -k*a ) + exp( -k*b );
    return -log( res )/k;
}

float sphere(vec3 pos, float radius)
{
    return length(pos) - radius;
}

float distfunc(vec3 pos, float ampenv)
{    
    float mainrad = 7.0;
    float val = sphere(pos,mainrad);
    
    for(uint j = 0u; j<MAXPOINTS; j++)
    {
        vec3 vpos = pointgen(j)*ampenv*25.0;
        vpos*=mainrad;  
        val = smin(val,sphere(vpos-pos,0.4),0.9);
    }
    return val;
}
void main(void)
{ 
	vec3 startPoint = vec3(cos(iGlobalTime*0.25)*15.0f, 0.0, sin(iGlobalTime*0.25)*15.0f);
    vec3 cameraDir = normalize(cameraTarget - startPoint);
	vec3 cameraRight = normalize(cross(upDirection, startPoint));
	vec3 cameraUp = cross(cameraDir, cameraRight);
    
    //amplitude envelope
    float audioEnvelope = (texture(iChannel0, vec2(iGlobalTime,0.0))).x;
   	int c =0;
  	for(float k = 0.0; k<0.02; k+=0.001)
    {
    	c++;
    	float val = abs((texture(iChannel2, vec2(iGlobalTime+k,0.0))).x);
    	audioEnvelope+=  val*val;
    }
    
    audioEnvelope = audioEnvelope/float(c);
    
    float totalDist = 0.0;
	vec3 pos = startPoint;
	float dist = EPSILON;
    
  	vec2 uv = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    uv*=0.5; //FOV
    uv.x*= iResolution.x /iResolution.y;
    
    uv*= iResolution.x / iResolution.y;
    
    vec3 rayDir = normalize(cameraRight * uv.x + cameraUp * (uv.y) + cameraDir);
    
    for (int i = 0; i < MAX_ITER; i++)
	{
    
    if (dist < EPSILON || totalDist > MAX_DIST)
        break; 

    	dist = distfunc(pos,audioEnvelope); 
    	totalDist += dist;
    	pos += dist * rayDir; 
	}
    
	if (dist < EPSILON)
	{
    	vec2 eps = vec2(0.0, EPSILON);
                    
		//VORONOI!
    	uint minknn = MAXPOINTS;
   		float minval = 100000.0;
        
        for(uint j = 0u; j<MAXPOINTS; j++)
    	{
        	vec3 vpos = pointgen(j)*audioEnvelope*25.0;
            vpos*=7.0f;
            
        	float len = length(vpos-pos);
        	if(len<minval)
        	{
        	    minval = len;
        	    minknn = j;
        	}
    	}
        
        vec3 normal_voronoi = pointgen(minknn) + cos(minval*3.0)*1.5*audioEnvelope;
        
		vec3 normal = normalize(vec3(
    	distfunc(pos + eps.yxx,audioEnvelope) - distfunc(pos - eps.yxx,audioEnvelope),
   		distfunc(pos + eps.xyx,audioEnvelope) - distfunc(pos - eps.xyx,audioEnvelope),
   		distfunc(pos + eps.xxy,audioEnvelope) - distfunc(pos - eps.xxy,audioEnvelope)));
        
        normal += normal_voronoi;
        
        vec3 lightVec1 = normalize(pos - lightPosition1);
        vec3 lightVec2 = normalize(pos - lightPosition2);
        
   		vec3 diffuse = vec3(0.0); 
        float redLight = max(0.0, dot(-lightVec1, normal))*0.5;
        float blueLight = max(0.0, dot(-lightVec2, normal))*0.5;
        diffuse += vec3(redLight*1.0,0.7*redLight,0.9*redLight);
        diffuse += vec3(blueLight*0.3,blueLight*0.6,blueLight*0.73);
        diffuse += vec3(0.2,0.2,0.2); //ambient
        float specular1 = pow(redLight, 16.0);
        float specular2 = pow(blueLight, 16.0);

		fragColor = vec4(diffuse+specular1+specular2, 1.0);
	}
	else
	{
			fragColor = vec4(0.0);
	}
}
 
