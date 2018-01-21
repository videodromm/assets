// https://www.shadertoy.com/view/MssSDl#
vec3 EdgeColor = vec3(0.7);
//float NumTiles = 40.0;  
float Threshhold = 0.15;

vec2 fmod(vec2 a, vec2 b)
{
  vec2 c = fract(abs(a / b)) * abs(b);
  return abs(c);
}

void main(void)
{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    float size = 1.0 / iRatio;

    vec2 Pbase = uv - fmod(uv, vec2(size));
    vec2 PCenter = Pbase + vec2(size / 2.0);
    vec2 st = (uv - Pbase) / size;
    vec4 c1 = vec4(0);
    vec4 c2 = vec4(0);
    vec4 invOff = vec4((1.0 - EdgeColor), 1.0);

    if (st.x > st.y)
    {
        c1 = invOff; 
    }

    float threshholdB = 1.0 - Threshhold;

    if (st.x > threshholdB) 
    { 
        c2 = c1; 
    }

    if (st.y > threshholdB) 
    { 
        c2 = c1; 
    }

    vec4 cBottom = c2;
    c1 = vec4(0);
    c2 = vec4(0);
    
    if (st.x > st.y)
    { 
        c1 = invOff; 
    }

    if (st.x < Threshhold) 
    { 
        c2 = c1;
    }
    
    if (st.y < Threshhold) 
    { 
        c2 = c1; 
    }

    vec4 cTop = c2;
    vec4 tileColor = texture2D(iChannel0, PCenter);
    gl_FragColor = tileColor + cTop - cBottom;
}