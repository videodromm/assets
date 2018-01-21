// https://www.shadertoy.com/view/XdBGRV
vec2 SpiralOnWaterRotate(vec2 p, float a)
{
  return p*cos(a)+vec2(p.y,-p.x)*sin(a);
}

vec3 SpiralOnWaterHSV(float h, float s, float v)
{
  return mix(vec3(1.0),clamp((abs(fract(h+vec3(3.0, 2.0, 1.0)/3.0)*6.0-3.0)-1.0), 0.0, 1.0),s)*v;
}

float SpiralOnWaterShape(vec2 p)
{
	float r = length(p);
	float a = atan(p.y, p.x);
	return r-1.0+0.5*sin(3.0*a+2.0*r*r);	
}

float SpiralOnWaterCol(vec2 p)
{	
	// http://www.iquilezles.org/www/articles/distance/distance.htm
	vec2 h = vec2(0.05, 0.0);
	vec2 g = vec2(SpiralOnWaterShape(p+h.xy)-SpiralOnWaterShape(p-h.xy),SpiralOnWaterShape(p+h.yx)-SpiralOnWaterShape(p-h.yx))/(2.0*h.x);
    float d = abs(SpiralOnWaterShape(p))/length(g);
    return 0.12/d;
}

void main(void)
{
	vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy; 
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
	vec2 p = uv*2.0-1.0;
	p.x *= iResolution.x/iResolution.y;
    p*=2.;
    p.y*=3.;
	p += vec2(1.0,.6);
	float t = iGlobalTime*2.;
    vec3 c = vec3(0.0);
    c+= min(0.05,0.08*SpiralOnWaterCol((SpiralOnWaterRotate(p+vec2(-3.,-1.2), t*1.2))*1.5));
	p = SpiralOnWaterRotate(p, -iGlobalTime*0.3);
    vec3 cc = SpiralOnWaterHSV(fract(0.1*iGlobalTime),1.,1.);
    c+= SpiralOnWaterCol((SpiralOnWaterRotate(p+vec2(-0.7,0.5), t))*4.0)*cc;
    c+= SpiralOnWaterCol((SpiralOnWaterRotate(p+vec2(0.5,-0.5), t))*3.0)*cc;
    c+= SpiralOnWaterCol((SpiralOnWaterRotate(p+vec2(0.5,1.8), t))*5.0)*cc;
	gl_FragColor = vec4(c,1.0);
}      



