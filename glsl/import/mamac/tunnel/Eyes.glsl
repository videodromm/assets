// https://www.shadertoy.com/view/MdVczD
//wang from https://www.shadertoy.com/view/ldjczd
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

vec2 pointgen(uint i)
{
    return vec2(wang(i), wang(i+10000u));
}

#define MAXPOINTS 512u
void main(void)
{

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord.xy/iResolution.xy;
    uv.y*=(iResolution.y/iResolution.x);
    
    uint minknn = MAXPOINTS;
    float minval = 100000.0;
        
    float parameter1 = 0.2 + (cos(iGlobalTime*0.15)*0.5f) + 0.5f;
    
    uint escape = 16u;
    
    if(iMouse.x>0.0f)
    	escape = uint((iMouse.x/iResolution.x) * 512.0f);
        
    for(uint i = 0u; i<MAXPOINTS; i++)
    {
        vec2 pos = pointgen(i);
        float len = (length(pos-uv)); 
        if(len<minval)
        {
            minval = len;
            minknn = i;
        }   
        
        if(i>escape)
            break;
    }
    
	float nicecos = cos(minval*130.0 + iGlobalTime);
    vec3 col = texture(iChannel0,uv+nicecos*0.15*parameter1).xyz;

    fragColor = vec4(col,1.0);
}
  