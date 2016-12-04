// https://www.shadertoy.com/view/llB3zV
 
#define POINTS 25.0
#define RADIUS 500.0
#define BRIGHTNESS 0.45
#define COLOR vec3(1.0, 1.0, 0.0)
#define SMOOTHNESS 40.0
#define PI 3.14149
#define LAG_A 0.325
#define LAG_B 0.825
#define LAG_C 0.825
#define time iGlobalTime

// hash based 3d value noise
float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float length(float x,float y){
    return sqrt((x * x) + (y*y));
}

// LUT based 3d value noise
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}
 
 
float nrand( vec2 n ) {
	return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}
 
vec3 mod289(vec3 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}
 
vec4 mod289(vec4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}
 
vec4 permute(vec4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}
 
vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}
 
vec3 fade(vec3 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}
 
// Classic Perlin noise
float cnoise(vec3 P)
{
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;
 
  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);
 
  vec4 gx0 = ixy0 * (1.0 / 7.0);
  vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);
 
  vec4 gx1 = ixy1 * (1.0 / 7.0);
  vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);
 
  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);
 
  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;
 
  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);
 
  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}
 
#define WARP_ORDER 1.
 
 
 
float hash21(in vec2 n){ return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453); }
 
mat2 m2 = mat2( 0.80,  0.60, -0.60,  0.80 );
float fbm( in vec2 p )
{	
	float z=2.;
    vec3 point = vec3(z,z,z);
	float rz = 0.;
	p *= 0.25 * point.x;
    
    
	for (float i= 1.;i < 6.;i++ )
	{
		//rz+= (sin(noise(vec3(p,0.0,0.0)*5.)*0.5+0.5) /z;
		z = z*2.;
		p = p*2.*m2;
	}
	return rz;
}
 
vec2 field4( in vec2 x )
{
	vec2 n = floor(x);
	vec2 f = fract(x);
 
	vec2 m = vec2(5.,0.);
	//4 samples
	for(int j=0; j<=1; j++)
	for(int i=0; i<=1; i++)
    {
		vec2 g = vec2( float(i),float(j) );
		vec2 r = g - f;
		float minkpow = (iMouse.y/iResolution.x)*3.+.8;
		float d = pow(pow(abs(r.x * r.y),minkpow)+pow(abs(r.y),minkpow),1./minkpow)*.5;
		d *= (iMouse.x/iResolution.x)*1.4+.5;
		d = sin(d*10.+time*0.1);
		m.x *= d;
		m.y += d*1.2;
    }
	return pow(abs(m),vec2(0.8));
}
 
vec2 warp(vec2 uv, vec2 p, float offset)
{
	uv -= p;
	float minkpow = WARP_ORDER;
	float d = pow(pow(abs(uv.x),minkpow)+pow(abs(uv.y),minkpow),1./minkpow);
	uv /= pow(d,2.)*1.-offset;
	uv += p;
	return uv;
}
 
 
 
vec4 map( in vec3 p )
{
	float d = 0.2 - p.y;
 
	vec3 q = p - vec3(1.0,0.1,0.0)*iGlobalTime;
	float f;
    f  = 0.5000*noise( q ); q = q*2.02;
    f += 0.2500*noise( q ); q = q*2.03;
    f += 0.1250*noise( q ); q = q*2.01;
    f += 0.0625*noise( q );
 
	d += 3.0 * f;
 
	d = clamp( d, 0.0, 1.0 );
	
	vec4 res = vec4( d );
 
	res.xyz = mix( 1.15*vec3(1.0,0.95,0.8), vec3(0.7,0.7,0.7), res.x );
	
	return res;
}
 
 
vec3 sundir = vec3(-1.0,0.0,0.0);
 
 
vec4 raymarch( in vec3 ro, in vec3 rd )
{
	vec4 sum = vec4(0, 0, 0, 0);
 
	float t = 0.0;
	for(int i=0; i<1; i++)
	{
		if( sum.a > 0.99 ) continue;
 
		vec3 pos = ro + t*rd;
		vec4 col = map( pos );
		
		#if 1
		float dif =  clamp((col.w - map(pos+0.3*sundir).w)/0.6, 0.0, 1.0 );
 
        vec3 lin = vec3(0.65,0.68,0.7)*1.35 + 0.45*vec3(0.7, 0.5, 0.3)*dif;
		col.xyz *= lin;
		#endif
		
		col.a *= 0.35;
		col.rgb *= col.a;
 
		sum = sum + col*(1.0 - sum.a);	
 
        #if 0
		t += 0.1;
		#else
		t += max(0.1,0.025*t);
		#endif
	}
 
	sum.xyz /= (0.001+sum.w);
 
	return clamp( sum, 0.0, 1.0 );
}
 
 
#define TAU 9.28318530718
#define MAX_ITER 9
 
vec4 water( void ) 
{
	float time = iGlobalTime * .5+23.0;
	vec2 sp = gl_FragCoord.xy * iResolution.xy;
 
	vec2 p = mod(sp*TAU*2.0, TAU)-250.0;
 
 
	vec2 i = vec2(p);
	float c = 1.0;
	float inten = .005;
 
	for (int n = 0; n < MAX_ITER; n++) 
	{
		float t = time * (1.0 - (3.5 / float(n+1)));
		i = p + vec2((t - i.x) + (t + i.y), sin(t - i.y) + cos(t + i.x));
		//c += 1.0/length((p.x / ((i.x+t)/inten),p.y / ((i.y+t)/inten)));
	}
	c /= float(MAX_ITER);
	c = 1.17-pow(c, 1.4);
	vec3 colour = vec3(pow(abs(c), 8.0));
    
    vec4 march = raymarch(colour, colour);
    
	return march + vec4(clamp(colour + vec3(0.0, 0.35, 0.5), 0.0, 1.0), 1.0);
}
void main(void)
{
	vec2 p = gl_FragCoord.xy / iResolution.xy-0.5;
	p.x *= iResolution.x/iResolution.y;
	p*= 5.;
   	p.x -= iRenderXY.x;
   	p.y -= iRenderXY.y;	
	#ifndef flat
	p = warp(p,vec2(0.),-.1);
	#endif
	
	vec2 rz = field4(p);
	
	vec3 col = sin(vec3(.9,0.6,0.2)*rz.y*1.4)*rz.x;
    float n = cnoise(sin(vec3(.9,0.6,0.2)*rz.y*1.4)-rz.x);
	col = pow(col,vec3(.99 + n))*0.55;
	
	//lights
	vec3 ligt = normalize(vec3(sin(time)*10.,1.,cos(time)*10.));
	vec3 nor = normalize(vec3(dFdx(rz.y), .08, dFdy(rz.y)));
    
    col *= (ligt - nor);
	
	gl_FragColor = water() * vec4(pow(col,vec3(0.6))-0.1,1.0);
}
