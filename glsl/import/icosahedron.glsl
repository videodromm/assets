// https://www.shadertoy.com/view/ldS3Rh

// Tracer code by Ben Weston - 2013
// Geometry, colouring and and animation by Wouter van Nifterick 2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const float pi2 = 6.28318530717958647692;

const float epsilon = .003;
const float normalPrecision = .1;
const float shadowOffset = .2;
const int traceDepth = 50; // takes time
const float drawDistance = 150.0;
const float stepScale = .9;

const vec3 CamPos = vec3(0,20.0,-20.0);
const vec3 CamLook = vec3(0,0,0);

const vec3 lightDir = vec3(0,1,1);
const vec3 fillLightDir = vec3(0,0,-1);
const vec3 lightColour = vec3(1,.8,.6);
const vec3 fillLightColour = vec3(.05,.15,.25);
	

float Isosurface( vec3 at )
{
  float res=.6;
  float n=(1.0+sqrt(5.0))*0.49;
	
  at /= 2.5;
  if(length(at) < 5.9)  
  {
	 float t =    
	   res =2.0 - 
		   (cos(at.x + n * at.y) + 
			cos(at.x - n * at.y) + 
			cos(at.y + n * at.z) + 
			cos(at.y - n * at.z) + 
			cos(at.z + n * at.x) + 
			cos(at.z - n * at.x)) ;
  }	
  return res;
}

vec3 Shading( vec3 pos, vec3 norm, float shadow, vec3 rd )
{
	vec3 albedo = vec3(.4);

	//vec3 l = shadow*lightColour*max(0.0,dot(norm,lightDir));
	//vec3 fl = fillLightColour*(dot(norm,fillLightDir)*.5+.5);
	
	vec3 l = shadow*iColor*max(0.0,dot(norm,lightDir));
	vec3 fl = iBackgroundColor*(dot(norm,fillLightDir)*.5+.5);
	vec3 view = normalize(-rd);
	vec3 h = normalize(view+lightDir);
	float specular = pow(max(0.0,dot(h,norm)),200.0);
	vec3 res =  albedo*(l+fl) + shadow*specular*22.0*lightColour*0.1;
	return res;
}


float Trace( vec3 ro, vec3 rd )
{
	float t = 0.0;
	float dist = 1.0;
	for ( int i=0; i < traceDepth; i++ )
	{
		if ( abs(dist) < epsilon || t > drawDistance || t < 0.0 )
			continue;
		dist = Isosurface( ro+rd*t );
		t = t+dist*stepScale;
	}
	
	return t;
}

// get normal
vec3 GetNormal( vec3 pos )
{
	const vec2 delta = vec2(normalPrecision, 0);
	vec3 n;
	n.x = Isosurface( pos + delta.xyy ) - Isosurface( pos - delta.xyy );
	n.y = Isosurface( pos + delta.yxy ) - Isosurface( pos - delta.yxy );
	n.z = Isosurface( pos + delta.yyx ) - Isosurface( pos - delta.yyx );
	return normalize(n);
}				

// camera function by TekF
// compute ray from camera parameters
vec3 GetRay( vec3 dir, float zoom, vec2 uv )
{
	uv = uv - .5;
	uv.x *= iResolution.x/iResolution.y;
	
	dir = zoom*normalize(dir);
	vec3 right = normalize(cross(vec3(0,1,0),dir));
	vec3 up = normalize(cross(dir,right));
	
	return dir + right*uv.x + up*uv.y;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;

	vec3 camPos = CamPos;
	vec3 camLook = CamLook;
	
	vec2 camRot = .5*pi2*(iMouse.xy-iResolution.xy*.5)/iResolution.x;
	camRot += iGlobalTime*0.5;
	camRot.y = 0.0;

	camPos.yz = cos(camRot.y)*camPos.yz* (0.5+sin (iGlobalTime)*0.2) + sin(camRot.y)*camPos.zy*vec2(1,-1);
	camPos.xz = cos(camRot.x)*camPos.xz + sin(camRot.x)*camPos.zx*vec2(1,-1);

	vec3 rd, ro = camPos;
	rd = GetRay( camLook-camPos, 1.0, uv );
	
	float t = Trace(ro,rd);

	vec3 result = vec3(0);
	if ( t > 0.0 && t < drawDistance )
	{
		vec3 pos = ro+t*rd;
			
		vec3 norm = GetNormal(pos);

		// shadow test
		float shadow = 0.0;
		if ( Trace( pos+lightDir*shadowOffset, lightDir ) < drawDistance )
			shadow = 0.15;
		
		result = Shading( pos, norm, shadow, rd )*6.0;
		
		// fog
		result = mix ( vec3(.6+sin(1.0+iGlobalTime)*0.6,.9+cos(iGlobalTime)*0.2,1.1+sin(iGlobalTime)*0.1), result, exp(-t*t*.0005) )*2.0-0.5;
		result -= distance(vec2(0),pos.xy)*0.03;
	}	

	gl_FragColor = vec4( result, 1.0 );
}