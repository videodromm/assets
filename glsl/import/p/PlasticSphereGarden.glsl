// https://www.shadertoy.com/view/MsBGW1
/* "Plastic Sphere Garden" by MasterM/Asenses */

// Constant parameters

#define PI  3.14159265
#define PI2 6.28318531

#define INFINITY  1000.0
#define THRESHOLD 0.01
#define EPSILON   0.0001
#define MAX_STEPS 150

#define L_AMBIENT  vec3(0.1,0.1,0.1)
#define L_DIFFUSE  0.6
#define L_SPECULAR 1.0
#define L_SHADOW   6.0
#define L_FOG      20.0
#define L_FOG_COL  vec3(0.6,0.1,0.1)

#define AO_BASEP  1.5
#define AO_STEPS  5
#define AO_DELTA  0.1

// Utility structures

struct light_t { vec3 pd; vec3 color; float power; };
struct ray_t { vec3 p; vec3 d; };
struct hit_t { vec3 p; vec3 n; vec3 v; vec3 color; float d; };
	
// Time

float T(const float t)
{
	return mod(t, PI2);
}

// Operations
	
vec4 ADD(in vec4 o1, in vec4 o2)
{
	return o1.x<o2.x ? o1 : o2;
}
	
vec3 REPXZ(in vec3 p, in vec2 factor)
{
	vec2 tmp = mod(p.xz, factor) - 0.5*factor;
	return vec3(tmp.x, p.y, tmp.y);
}
	
// Shapes

float sphere(in vec3 p, in vec3 pos, in float radius)
{
	return length(p-pos) - radius;
}

float ground(in vec3 p)
{
	return p.y + 0.3*sin(mod(p.x,PI2))*cos(mod(p.z,PI2));
}

// Scene definition

vec4 scene(in vec3 p)
{
	return ADD(
		vec4(ground(p), 0.97, 0.98, 0.82),
		vec4(sphere(REPXZ(p, vec2(5.0, 5.0)), vec3(0.0, 1.0, 1.2), 1.0), 0.7, 1.0, 0.7)
	);
}

// Rendering code

vec3 normal(in vec3 p, in float dist)
{
	vec3 n;
	n.x = scene(p + vec3(EPSILON, 0.0, 0.0)).x - dist;
	n.y = scene(p + vec3(0.0, EPSILON, 0.0)).x - dist;
	n.z = scene(p + vec3(0.0, 0.0, EPSILON)).x - dist;
	return normalize(n);
}

bool raymarch(in ray_t ray, const float maxt, out hit_t hit)
{
	float t=0.0;
	for(int i=0; i<MAX_STEPS; i++) {
		vec4 result = scene(ray.p);
		if(result.x <= THRESHOLD) {
			hit.p     = ray.p;
			hit.v     = ray.d;
			hit.d     = t + result.x;
			hit.n     = normal(ray.p, result.x);
			hit.color = result.yzw;
			return true;
		}
			
		if((t += result.x) >= maxt)
			break;
		ray.p += result.x * ray.d;	
	}
	return false;
}

bool raymarch(in ray_t ray, const float maxt)
{
	float t=0.0;
	for(int i=0; i<MAX_STEPS; i++) {
		float dist = scene(ray.p).x;
		if(dist <= THRESHOLD)
			return true;
		
		if((t += dist) >= maxt)
			break;
		ray.p += dist * ray.d;
	}
	return false;
}

float computeAO(in hit_t hit)
{
	ray_t ao_ray = ray_t(hit.p, hit.n);
	ao_ray.p += AO_DELTA * ao_ray.d;
	
	float ao = 0.0;
	for(int i=0; i<AO_STEPS; i++) {
		float dist = scene(ao_ray.p).x;
		ao += 1.0/pow(AO_BASEP,float(i)) * (float(i)*AO_DELTA - dist);
		ao_ray.p += AO_DELTA * ao_ray.d;
	}
	return 1.0 - ao;
}

float is_lit(in vec3 P, in vec3 L, const float maxt)
{
	ray_t shadow_ray = ray_t(P, L);
	shadow_ray.p += 0.1 * shadow_ray.d;
	
	float t=0.0, lit=1.0;
	for(int i=0; i<MAX_STEPS; i++) {
		float dist = scene(shadow_ray.p).x;
		if(dist <= THRESHOLD)
			return 0.0;
		
		lit = min(lit, L_SHADOW*dist/t);
		if((t += dist) >= maxt)
			break;
		shadow_ray.p += dist * shadow_ray.d;
	}
	return lit;
}

vec3 shade(in hit_t hit, in vec3 cam)
{
	light_t light0 = light_t(
		vec3(cam.x + 20.0*sin(T(iGlobalTime)), 20, cam.z+20.0+5.0*cos(T(iGlobalTime))),
		 vec3(1,1,1), 450.0);
	
	vec3  color = L_AMBIENT;
	float R     = length(light0.pd - hit.p);
	vec3  L     = (light0.pd - hit.p) / R;
	
	R = light0.power / (R*R);
	
	float dp   = clamp(hit.d, 0.0, INFINITY)/INFINITY;
	float fog  = clamp(exp(-(L_FOG * L_FOG * dp * dp)), 0.0, 1.0);
	float lit  = is_lit(hit.p, L, INFINITY);
	
	if(lit > 0.0) {
		float dotNL = max(0.0, dot(hit.n, L));
		float dotVR = max(0.0, dot(hit.v, reflect(L, hit.n)));
		color += L_DIFFUSE * dotNL * light0.color * hit.color * lit * R;
		color += L_SPECULAR * pow(dotVR, 20.0) * lit * R;
	}
	return mix(color * computeAO(hit), L_FOG_COL, 1.0-fog);
}

// Camera

vec3 lookat(const vec3 forward, const vec3 up)
{
	vec3 _forward = normalize(forward);
	vec3 _right   = cross(_forward, normalize(up));
	vec3 _up      = cross(_right, _forward);
	
	float aspect  = iResolution.x / iResolution.y;
	vec2  uv      = gl_FragCoord.xy / iResolution.xy;
	vec2  pixel   = vec2((uv.x-0.5)*aspect, uv.y-0.5);
	
	return normalize(pixel.x * _right + pixel.y * _up + _forward);
}

// Shader main
	
void main(void)
{
	vec3 color = L_FOG_COL;

	ray_t ray;
	ray.p = vec3(cos(T(iGlobalTime*0.1))*20.0, 6.0, 10.0 * iGlobalTime);
	ray.d = lookat(vec3(0.0, -0.32, 0.68), vec3(0.2*cos(T(0.25*iGlobalTime)), 0.8, 0.0));
	
	hit_t hit;
	if(raymarch(ray, INFINITY, hit))
		color = shade(hit, ray.p);
	
	gl_FragColor = vec4(color, 1.0);
}