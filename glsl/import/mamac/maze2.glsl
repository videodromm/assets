// https://www.shadertoy.com/view/4sSXWR
float t = iGlobalTime;
float rnd(float x) { return fract(1000.*sin(345.2345*x)); }
float id(float x, float y) { return floor(x)+100.*floor(y); }

float maze(vec2 uv) {
    float n = id(uv.x,uv.y);  uv = fract(uv);
    return 1.-smoothstep(.1,.15,((rnd(n)>.5)?uv.x:uv.y));
}
void main(void)
{
  vec2 uv = gl_FragCoord.xy / iResolution.y;
	
    uv = (uv + vec2(1.8*cos(.2*t)+.6*sin(.4*t),sin(.3*t)+.4*cos(.4*t)) ) * (1.2-cos(.5*t));
    float a = 3.*(cos(.05*t)-.5*cos(1.-.1*t)), C=cos(a), S=sin(a); uv*=mat2(C,-S,S,C);

    float v = 0., w=1., s=0.; uv *= 2.;
    for(int i=0; i<3; i++) { 
        uv *= 4.;  
        v+= w*maze(uv); s+= w; 
        w *= .3;
    }
	fragColor = vec4(1.-v/s); //gl_FragColor
}

  
