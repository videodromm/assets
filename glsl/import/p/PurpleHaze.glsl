// https://www.shadertoy.com/view/XdSGWy#

//Purple haze! All in my torus. 
//Lately rays don't just trace one surface. 
//Unstable root solver, don't know why. 
//Scuse me while I rip POVRay.  
//Dow dow dow, widdly widdly squee!

vec3 hsv2rgb(vec3 c);
vec3 rgb2hsv(vec3 c);
void MakeViewRay(out vec3 eye, out vec3 ray);
vec4 Sort(vec4 n);
void quartic_descartes(float a, float b, float c, float d, inout vec4 rts);
vec4 RayTorus(vec3 A, vec3 B, float R, float r);
float noise( in vec3 x );
vec2 noise2( in vec3 x );

float sdTorus( vec3 p, vec2 t );

#define pi 3.1415927



vec3 RotY(vec3 p, float t) {
	float c = cos(t); float s = sin(t);
	return vec3(p.x*c+p.z*s,
				p.y,
				-p.x*s+p.z*c);
}

vec3 RotZ(vec3 p, float t) {
	float c = cos(t); float s = sin(t);
	return vec3(p.x*c+p.y*s,
				-p.x*s+p.y*c,
				p.z);
}

vec4 quat_rotation( float half_angr, vec3 unitVec )
{
    float s, c;
    s = sin( half_angr );
    c = cos( half_angr );
    return vec4( unitVec*s, c );
}

vec3 quat_times_vec(vec4 q, vec3 v)
{
	//http://molecularmusings.wordpress.com/2013/05/24/a-faster-quaternion-vector-multiplication/
	vec3 t = 2. * cross(q.xyz, v);
	return v + q.w * t + cross(q.xyz, t);
}

float R =(1.+sin(iGlobalTime*0.7))*1.2;
float r=.75;


#define RATE	7.			

float DensityFalloff(vec3 p)
{	
	float sdf = max(-sdTorus( p, vec2(R,r)),0.);
	float falloff = sdf/r;
//	falloff*=falloff;
//	falloff*=falloff;
	
	return falloff;
}

vec3 animate(vec3 p)
{
	p=RotZ(p, iGlobalTime*0.5);	//spin on main axis

#if 1	
	vec3 q = vec3(normalize(p.xy),0.);	//vec to main ring
	vec3 ax = vec3(-q.y,q.x,0.);		//perpendicular axis of rotation
	q.xy *= R;							//point on main ring
	vec3 loc = p-q;						//offset along little ring
	vec4 quat_rot = quat_rotation( iGlobalTime, ax );
	loc = quat_times_vec(quat_rot, loc);
	p = q + loc;	
#endif
	
	return p;
}

vec2 density(vec3 p)
{
	float falloff =	DensityFalloff(p);
	
	p = animate(p);

	float	d = noise( p*RATE);
	d *= noise( p*(RATE*1.17) )-0.3;// * 0.5;
	d *= noise( p*(RATE*4.03) )-0.2;// * 0.25;				
	d *= noise( p*(RATE*8.11) )-0.1;// * 0.125;
	
	
	float dd = 4.*d*falloff;
	float c = noise( p*RATE*0.3);
	return vec2(dd, c);
}

vec3 lightDir = normalize(vec3(-.25,1,1));


vec4 march(vec4 accum, vec3 viewP, vec3 viewD, float tt, float end)
{
	//exponential stepping
	float slices = 300.;
	float Far = 10.;
	
	float sliceStart = log2(tt)*(slices/log2(Far));
	float sliceEnd = log2(end)*(slices/log2(Far));
		
	float sliceRate = 1./ exp2(log2(Far)/slices);
	
	float last_tt = tt;
	
#define STEPS	64	
	if (tt< 1e5)		
	for (int i=0; i<STEPS; i++)
	{				
		float sliceI = sliceStart + float(i);	//advance an exponential step
		tt = exp2(sliceI*(log2(Far)/slices));	//back to linear
	//	tt = min(tt,end);	//no sense sampling past the last intersection ... 

		vec3 p = viewP+tt*viewD;
		
	//	p = animate(p);
		
		vec2 dc = density(p);
		
		vec3 h = hsv2rgb(vec3(dc.y*0.5+0.5,0.7,0.2));

		//lighting
		float inside=1.-DensityFalloff(p);
#if 0	
		//gradient ... too much for chrome/angle/win
		float e = 0.5;
		float dx = density(p + vec3(e,0,0)).x;
		float dy = density(p + vec3(0,e,0)).x;
		float dz = density(p + vec3(0,0,e)).x;
		float d = dc.x;
		vec3 n = -normalize(vec3(dx-d,dy-d,dz-d));

		vec3 n = lightDir;
		h *= max(dot(n,lightDir),0.)+.2*inside;
#endif		
		
#if 1
		//dodgy lighting/gradient		
		float e = 0.5;
		float dl = density(p - lightDir*e).x / e;
		h *= clamp(inside + .4,0.,1.);
		h += (dl- 0.125 )* 0.25 ;
#endif		
		dc.x *= (tt-last_tt)*100.;	//density ought to be proportional to integral over step length?
		last_tt = tt;
		
		vec4 col = vec4(h,dc.x);
//		col = clamp(col,vec4(0),vec4(1));	//screw it, the clipping looks magically sparkly
		col.rgb *= col.a + .025;
		accum = accum + col*(1.0 - accum.a);	

		if (accum.a > 1.) break;
		
		if (sliceI > sliceEnd) break; //out of exponential steps	
	}	
	
	return accum;
}

void main(void)
{
	vec3 viewP, viewD;
	MakeViewRay(viewP, viewD);

	//ground plane
	float floor_height = -3.;
	float floor_intersect_t = (-viewP.y + floor_height) / (viewD.y);
	vec3 p = viewP+viewD*floor_intersect_t;
	vec3 c = texture2D(iChannel0,p.xz*0.1).xyz;
	c = pow(c,vec3(2.2));
#if 1	
	//darken by shadow ray through torus
	vec4 shadow_roots = RayTorus(p, lightDir, R, r);
	float thick=0.;
	for (int i=0; i<4; i+=2)
	{
		if (shadow_roots[i+1]<1e5)
		{
			vec3 sp = p + lightDir * ((shadow_roots[i+1]+shadow_roots[i])*0.5);
			float d = density(sp).x;
			d=sqrt(d);
			d=sqrt(d);
			thick += (shadow_roots[i+1]-shadow_roots[i])*d;
		}
	}
	
	c *= max(1.0-thick*.5,.2);
#endif	

	//ray marching segments of torus intersections
	vec4 roots = RayTorus(viewP, viewD, R, r);

	vec4 accum = vec4(0);
	accum = march(accum,viewP, viewD, roots[0],roots[1]);
	accum = march(accum,viewP, viewD, roots[2],roots[3]);

	//comp over background 
	c = mix( c, accum.xyz, accum.a);

	
	c=pow(c,vec3(1./2.2));
	gl_FragColor = vec4(c,1.0);
}

void MakeViewRay(out vec3 eye, out vec3 ray)
{
	vec2 ooR = 1./iResolution.xy;
    vec2 q = gl_FragCoord.xy * ooR;
    vec2 p =  2.*q -1.;
    p.x *= iResolution.x * ooR.y;
	
    vec3 lookAt = vec3(0.);
	eye = vec3(2.5,3.,-2.5) * 1.5; 	
	eye = RotY(eye,iGlobalTime*.4);
	
    // camera frame
    vec3 fo = normalize(lookAt-eye);
    vec3 ri = normalize(vec3(fo.z, 0., -fo.x ));
    vec3 up = normalize(cross(fo,ri));
     
    float fov = .25;
	
    ray = normalize(fo + fov*p.x*ri + fov*p.y*up);
}

vec4 Sort( vec4 a)
{
	vec4 m = vec4(min(a.xz,a.yw), max(a.xz,a.yw) );
	vec4 r = vec4(min(m.xz,m.yw), max(m.xz,m.yw) ); 
	a = vec4( r.x, min(r.y,r.z),  max(r.y,r.z), r.w );
	return a;
}

//watch out, unstable on "small" R, r, certain planes and slight breezes!! :(
//http://research.microsoft.com/en-us/um/people/awf/graphics/ray-torus.html
vec4 RayTorus(vec3 A, vec3 B, float R, float r)
{
	//B assumed normalized
	
	float aa = dot(A,A);
	float ab = dot(A,B);
		
	// Set up quartic in t:
	//
	//  4     3     2
	// t + A t + B t + C t + D = 0
	//
	
	float R2 = R*R;
	float K = aa - r*r - R2;
	K *= 0.5;
	float qA = ab;
	float qB = ab*ab + K + R2*B.z*B.z;
	float qC = K*ab + R2*A.z*B.z;
	float qD = K*K +  R2*(A.z*A.z - r*r);

    // 4t^3 + 3At^2 + 2Bt + C
	//12t^2 + 6At   + 2B
	
	vec4 roots = vec4(1e10);
	quartic_descartes(qA,qB,qC,qD, roots);
	
	for (int i=0; i<4; i++)
	{
		if (roots[i] < 0.) 
			roots[i] = 1e10;	
	}
	
	roots = Sort(roots);
		
	return roots;
}


//https://github.com/POV-Ray/povray/blob/3.7-stable/source/backend/math/polysolv.cpp#L808

#define DBL float 

#define SMALL_ENOUGH 1.0e-3

float solve_cubic(float a1, float a2, float a3)
{
	DBL Q, R, Q3, R2, sQ, d, an, theta;
	DBL A2;
	
	A2 = a1 * a1;

	Q = (A2 - 3.0 * a2) * (1./ 9.0);

	/* Modified to save some multiplications and to avoid a floating point
	   exception that occured with DJGPP and full optimization. [DB 8/94] */

	R = (a1 * (A2 - 4.5 * a2) + 13.5 * a3) * (1./ 27.0);

	Q3 = Q * Q * Q;

	R2 = R * R;

	d = Q3 - R2;

	an = a1 * (1./3.);

	if (d >= 0.0)
	{
		/* Three real roots. */ //but only use the first!

		d = R * inversesqrt(Q3);

		theta = acos(d) * (1. / 3.0);

		sQ = -2.0 * sqrt(Q);

		return sQ * cos(theta) - an;
	}

	sQ = pow(sqrt(R2 - Q3) + abs(R), 1.0 / 3.0);

	DBL t = sQ + Q / sQ;
	
	t = R < 0. ? t : -t;
	return t - an;
}

void quartic_descartes(float c1, float c2, float c3, float c4, inout vec4 results)
{
	DBL c12, z, p, q, q1, q2, r, d1, d2;
	
	/* Compute the cubic resolvant */

	c12 = c1 * c1;
	p =  -6. * c12 + 4.*c2;
	q =  c12 * c1 - c1 * c2 + c3;
	q *= 8.;
	r = -3. * c12 * c12 + c12 *4.*c2 - c1 * 8.*c3 + 4.*c4;
				
	float cubic_a1 = -0.5 * p;
	float cubic_a2 = -r;
	float cubic_a3 = 0.5 * r * p - 0.125 * q * q;

	z = solve_cubic(cubic_a1, cubic_a2, cubic_a3);

	d1 = 2.0 * z - p;

	if (d1 < 0.0)
	{
		if (d1 > -SMALL_ENOUGH)
		{
			d1 = 0.0;
		}
		else
		{
			return;
		}
	}

	if (d1 < SMALL_ENOUGH)
	{
		d2 = z * z - r;

		if (d2 < 0.0)
		{
			return;
		}

		d2 = sqrt(d2);
	}
	else
	{
		d1 = sqrt(d1);
		d2 = 0.5 * q * (1./ d1);
	}

	/* Set up useful values for the quadratic factors */

	q1 = d1 * d1;
	q2 = -c1;

	/* Solve the first quadratic */

	p = q1 - 4.0 * (z - d2);

	if (p > 0.)
	{
		p = sqrt(p);
		results[0] = -0.5 * (d1 + p) + q2;
		results[1] = -0.5 * (d1 - p) + q2;
	}

	/* Solve the second quadratic */

	p = q1 - 4.0 * (z + d2);

	if (p > 0.)
	{
		p = sqrt(p);
		results[2] = 0.5 * (d1 + p) + q2;
		results[3] = 0.5 * (d1 - p) + q2;
	}
}


//iq
float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xy)-t.x,p.z);
  return length(q)-t.y;
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel1, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z ); //*2.-1.;
}

vec2 noise2( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec4 rg = texture2D( iChannel1, (uv+ 0.5)/256.0, -100.0 ).yxwz;
	return mix( rg.xz, rg.yw, f.z ); //*2.-1.;
}

//http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}



