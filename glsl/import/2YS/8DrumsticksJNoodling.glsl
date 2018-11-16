//https://www.shadertoy.com/view/lsSXDG
// Adapted from 'Tileable Water Caustic' by Dave_Hoskins
// -J.

// -----------------------------------------------------------------------
// Water turbulence effect by joltz0r 2013-07-04, improved 2013-07-07
// Altered
// -----------------------------------------------------------------------

// Redefine below to see the tiling...
//#define SEE_TILING

#define TAU 6.28318530718
#define MAX_ITER 5

void main( void ) 
{
  float time = iTime * .5+23.0;
    // uv should be the 0-1 uv of texture...
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
    
#ifdef SEE_TILING
  vec2 p = mod(uv*TAU*2.0, TAU)-250.0;
#else
    vec2 p = mod(uv*TAU, TAU)-250.0;
#endif
  vec2 i = vec2(p);
    vec2 i2 = vec2(p);
  float c = 1.0;
    float c2 = 1.0;
  float inten = .005;

  for (int n = 0; n < MAX_ITER; n++) 
  {
    float t = time * (1.0 - (3.5 / float(n+1)));
        float t2 = time * (1.0 - (3.5 / float(MAX_ITER+n+1)));
        
    i = p + vec2(cos(t - i.x) + sin(t + i.y), sin(t - i.y) + cos(t + i.x));
    c += 1.0/length(vec2(p.x / (sin(i.x+t)/inten),p.y / (cos(i.y+t)/inten)));
        
    i2 = p + vec2(cos(t2 - i2.x) + sin(t2 + i2.y), sin(t2 - i2.y) + cos(t2 + i2.x));
    c2 += 1.0/length(vec2(p.x / (sin(i2.x+t2)/inten),p.y / (cos(i2.y+t2)/inten)));
  }
  c /= float(MAX_ITER);
  c = 1.17-pow(c, 1.4);
    c2 /= float(MAX_ITER);
    c2 = 1.17-pow(c2, 1.4);
  vec3 colour = vec3(pow(abs(c), 8.0));
    colour *= vec3(sin(time*1.9), sin(time*1.5), sin(time*1.1));
    vec3 col2 = vec3(pow(abs(c2), 8.0)) * vec3(cos(time));
    vec3 space = vec3(0.4 + 0.1*uv.y + 0.1*uv.x, 0.6 - 0.2*uv.y, 0.4 + 0.2*uv.x);
  gl_FragColor = vec4(clamp(colour + col2 + space, 0.0, 1.0), 1.0);
}