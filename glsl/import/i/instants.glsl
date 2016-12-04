// https://www.shadertoy.com/view/XsfSz2
#define RING_COUNT 50.0
//#define CONSTRAINED_TO_CIRCLE //as opposed to filling the whole screen
#define AA 1.0
#define AA_SAMPS 64	

const float PI = 3.14159265358979323846264;
//mmalex's random functions
float srand(vec2 a) { return fract(sin(dot(a,vec2(1233.224,1743.335)))); }
vec2 rand(vec2 r) { return fract(3712.65*r+0.61432); }

float easeWithSteps(float t, float steps)
{
	float frac = 1.0 / steps;	
	float eT = mod(t, frac);
	float x = eT / frac;
	return t - eT + frac * x*x*x*(x*(x*6.0 - 15.0) + 10.0); // fancy smoothstep (see wikipeed)
}

float map(float x, float xmin, float xmax, float ymin, float ymax)
{
	// miss u processing
	return clamp(ymin + (x - xmin) / (xmax - xmin) * (ymax - ymin), ymin, ymax);
}

float colorAtCoord(vec2 coord, float t)
{
	float steps = 1. + mod(floor(t), 7.0); // pattern cycling
	t = mod(t, 1.0);
	
	vec2 uv = coord.xy / iResolution.xy;
	vec2 p = uv - vec2(.5,.5);
	p.y *= iResolution.y / iResolution.x;
	
	float angle = atan(p.y, p.x);
	angle = mod( angle + PI * 2.0, PI * 2.0);
	
	float dist = length(p);
	
	float ring = floor(pow(dist*1.5,.5) * RING_COUNT - t); // tweak!
	float ringFrac = ring / RING_COUNT;
	
	float ringTime = map(t, ringFrac * .125, 1.0 - ringFrac * .125, 0.0, 1.0);
	ringTime = easeWithSteps(ringTime, steps); // aand tweak!
	
	float color = 0.0;//vec4 color = vec4(0.0,0.0,0.0,1.0);
	float tAngle =  PI * 2.0 * mod(ringTime * ring*1.0, 1.0);
	//if ( mod(ring, 2.0) == 0.0) tAngle = PI * 2.0 - tAngle;
	tAngle *= mod(ring, 2.0)*2.0 - 1.0;
	float si = sin(tAngle);
	float co = cos(tAngle);
	color = step(0., dot(vec2(-si,co),p)); 
	// if ((angle > tAngle && angle < tAngle + PI) || angle < tAngle - PI)
	// 	color = vec4(1.0,1.0,1.0,1.0);
	#ifdef CONSTRAINED_TO_CIRCLE
	if (dist > .45 * iResolution.y / iResolution.x) color = vec4(1.0,1.0,1.0,1.0);
	else if (dist > .446 * iResolution.y / iResolution.x) color = vec4(0.5,0.5,0.5,1.0);
	#endif
	return color;
}

void main ()
{
	// assume 60fps
	float t = iGlobalTime;
	float c=0.;
	
	// mmalex's AA/blur code.
	vec2 aa=vec2( srand(gl_FragCoord.xy), srand(gl_FragCoord.yx) );
	t+=1.0/60.0/float(AA_SAMPS)*aa.x;	
	
	for (int i=0;i<(AA_SAMPS);i++) {
		aa=rand(aa);
		c+=colorAtCoord(gl_FragCoord.xy+aa, t*.05);
		t+=1.0/60.0/float(AA_SAMPS);
	}	
	c=sqrt(c/float(AA_SAMPS));
	gl_FragColor = vec4(c);
}


