// https://www.shadertoy.com/view/lsGcRD
//----------- gravity_field_3 ---------------

// simplified https://www.shadertoy.com/view/4slSWN

#define POINTS 20  		 // number of stars

#define t iTime

float hash (float i) { return 2.*fract(sin(i*7467.25)*1e5) - 1.; }
//vec2  hash2(float i) { return vec2(hash(i),hash(i-.1)); }
vec4  hash4(float i) { return vec4(hash(i),hash(i-.1),hash(i-.3),hash(i+.1)); }
	

vec2 P (int i)  // position of point[i]
{
  vec4 c = hash4(float(i));
  return vec2( cos(t*c.x-c.z) +0.5*cos(2.765*t*c.y+c.w),
			 ( sin(t*c.y-c.w) +0.5*sin(1.893*t*c.x+c.z)) / 1.5);
}
void main(void)
{	
  vec2 R = iResolution.xy;
  vec2 uv = (2.*fragCoord.xy - R) / R.y;
  vec2 mp = iMouse.xy / R;
    
  float my = 0.5*pow(.5*(1.-cos(0.1*t)),3.0);
  float fMODE = (1.0-cos(3.1415*mp.x))/2.;

  vec2 V = vec2(0.);
  for (int i=1; i<POINTS; i++)
  {	
    vec2 d = P(i) - uv;  // distance point->pixel
	V +=  d / dot(d,d);  // gravity force field
  }
  float c = (length(V)* 1./(9.*float(POINTS)))*(2.+210.*fMODE);
  int MODE = int(3.*mp.x);
  if (MODE==0) fragColor = vec4(.2*c)+smoothstep(.05,.0,abs(c-5.*my))*vec4(1,0,0,0);
  if (MODE==1) fragColor = vec4(.5+.5*sin(2.*c));
  if (MODE==2) fragColor = vec4(sin(c),sin(c/2.),sin(c/4.),1.);
}
