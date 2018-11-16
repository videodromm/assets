// https://www.shadertoy.com/view/Md2GWD
#define BPM 128.0

const float 
	_density = .1,
	_detail = .01,
	_rayon = 1.;
float 
	time = iTime*0.2,
	_lowFreq = texture2D(iChannel0, vec2(0.1,0.4)).x/10.0,
	_split, //(cos(time*50.)+1.)*.2,
	_c3 = cos(time*3.0),
	_s3 = cos(time*3.0);
vec3 
	_nLight = -normalize(vec3(-10.1,-5.5,5.5)),
	_vDelta = vec3(0.0,_detail,0.0),
	_vplasm = vec3(_s3,_c3, _c3+_s3),
	_cplasm = vec3(2.,10.,1.) + _vplasm;


// - 3D plasma ------------------------------------
vec4 plasma(vec3 p) {
	float 
		t = time*(2.+(1.-_lowFreq)*.2),
		c = .7*((sin(.2*dot(p, _vplasm)*10.02+t)+1.) +
		        (cos(length(p -_cplasm)*10.)+1.)),
		r = (cos(c*3.14+t)+1.)/2.,
		g = (sin(c*3.14+t)+1.)/2.,
		b = (sin(t)+1.)/2.;
    return vec4(r, g, b, clamp(exp(r)-exp(b*g),0.,1.));
}

// -- START of ray marching stuff -----------------

float scene(in vec3 p) {
	return min(
		max(_split+p.y, length(p+vec3(0,_split,0))-_rayon),
		max(_split-p.y, length(p-vec3(0,_split,0))-_rayon));
	
}

float softshadow(in vec3 ro, in vec3 rd, in float mint, in float k )
{
    float res = 1.0, t = mint;
    for( int i=0; i<8; i++ )
    {
        float h = scene(ro + rd*t);
		h = max( h, 0.0 );
        res = min( res, k*h/t );
        t += clamp( h, 0.01, 0.5 );
    }
    return clamp(res,0.0,1.0);
}

float light(in vec3 p, in vec3 dir, in vec3 n) {
	vec3 
		r = reflect(_nLight,n);
	float 
		sh = .9,//softshadow(p,-_nLight,1.,20.),
		diff = .3*max(0.,dot(_nLight,-n)),
		spec = .99*max(0.,dot(_nLight,-r));
	return 
		diff*sh +
		pow(spec,10.)*.1*sh +
		.2*max(0.,dot(normalize(dir),-n));	
}

vec3 normal(in vec3 p) {
	return normalize(vec3(
			scene(p+_vDelta.yxx)-scene(p-_vDelta.yxx),
			scene(p+_vDelta.xyx)-scene(p-_vDelta.xyx),
			scene(p+_vDelta.xxy)-scene(p-_vDelta.xxy)));
}

float raymarch(in vec3 from, in vec3 dir)
{
	vec3 p;
	float col, d=1.0, totdist=0.;
	for (int i=0; i<iSteps; i++) {
		p = from + totdist*dir;
		if (d<_detail/4.) {
			return light(p, dir, normal(p)); 
		}
		d = scene(p);
		totdist += d;
	}
	return 0.;
}

// -- END of ray marching stuff -----------------

vec3 rotateX(vec3 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    return vec3(p.x, ca*p.y - sa*p.z, sa*p.y + ca*p.z);
}

vec3 rotateY(vec3 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    return vec3(ca*p.x + sa*p.z, p.y, -sa*p.x + ca*p.z);
}

void main(void)
{	
	vec2 uv = (-1. + iZoom * 2.*gl_FragCoord.xy / iResolution.xy); 
	// BPM by iq ---------------------------------------------
	float h = fract( 0.25 + 0.5*iTime*BPM/60.0 );
	float f = 1.0-smoothstep( 0.0, 1.0, h );
	f *= smoothstep( 4.5, 4.51, iTime );
	// -------------------------------------------------------
	
	_split = f/4.+1.2*_lowFreq;
	
	vec3 
		ro = vec3(0.,0.,-2.),
	 	rd = normalize(vec3(uv, 1.)),
	 	c0 = vec3(0., _split, 0.),
	 	c1 = vec3(0., -_split, 0.);
	
	vec2 mouse = iMouse.xy / iResolution.xy;
	float 
		rotx = -1.1-(mouse.y-.5)*9.,
		roty = 1.14+(mouse.x-.5)*9.;
    ro = rotateY(rotateX(ro, rotx), roty);	
    rd = rotateY(rotateX(rd, rotx), roty);

	//-----------------------------------
	vec3 p = ro+rd;
	vec4 c, cSum,
		 back = plasma(vec3(p.x,0,p.z));
	back.w = .03;
	back.xy *= .6;
	back.z = 1.;
	
	// Volume ray tracing
	for (int i=0; i<iSteps; i++) {
		if (p.y>_split &&  length(p-c0)<_rayon) {
			c = plasma(p-vec3(0.,_split,0.));
		} else if (p.y<-_split && length(p-c1)<_rayon) {
			c = plasma(p-vec3(0.,-_split,0.));
		} else {
			c = back;
		}
		c.a *= _density;
		c.rgb *= c.a; // pre-multiply alpha
		cSum += c*(1. - cSum.a);	
		if (cSum.a > .99) break; // exit early if opaque
		p += _detail*rd; 
	}
	
	// Add ray marching to give a structure to the ball
	gl_FragColor = cSum + raymarch(ro, rd);
}

