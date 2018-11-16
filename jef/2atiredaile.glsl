// https://www.shadertoy.com/view/XstXz7
#define INF 1e6
#define STEPS 32
#define TIME_SCALE 0.05

#define polar(l,a) (l*vec2(cos(a),sin(a)))
#define saturate(a) clamp(a,0.0,1.0)

vec2 spirograph(float t)
{
    return polar(0.30, t *-0.5) 
         + polar(0.08, t * 4.0)
         + polar(0.03, t *-6.0)
         + polar(0.05, t * 10.0)
         + polar(0.03, t *-26.0);
}

float dfLine(vec2 start, vec2 end, vec2 uv)
{   
    vec2 line = end - start;
    float frac = dot(uv - start,line) / dot(line,line);
    return distance(start + line * clamp(frac, 0.0, 1.0), uv);
}

//Smooth sign
float ssign( float a, float k )
{
    return smoothstep(-k,k,a) * 2.0 - 1.0;
}

bool keyPressed(int key)
{
    return texture2D(iChannel1, vec2(float(key) / 256.0, 0.0)).x == 0.0;
}

void main(void) {
{
    vec2 res = iResolution.xy / iResolution.y;
    vec2 uv = gl_FragCoord.xy / iResolution.y;
    
    bool reset = (iFrame < 5) || !keyPressed(0x20);
    
    float t = iTime * TIME_SCALE;
    float dt = iTimeDelta * TIME_SCALE;
    
    vec4 last = texture2D(iChannel0, uv / res);
    
    float dist = reset ? INF : last.x;
    float spd = reset ? 0.0 : last.y;
    
    uv -= res / 2.0;
    
    for(int i = 0;i < STEPS;i++)
    {
        float lidx = float(i + 0) / float(STEPS);
        float cidx = float(i + 1) / float(STEPS);
        
        vec2 lpos = spirograph(t - lidx * dt);
        vec2 cpos = spirograph(t - cidx * dt);
        
        float dline = dfLine(lpos, cpos, uv);
        
        if(dline < dist)
        {
           float s = length(cpos-lpos) / (dt / float(STEPS));
           
           spd = mix(spd, s, saturate(ssign(dist - dline, 0.08)));
            
           dist = dline; 
        }
    }
    
    gl_FragColor = vec4(dist, spd, 0, 0);
}
