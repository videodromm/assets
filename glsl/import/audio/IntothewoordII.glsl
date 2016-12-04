// https://www.shadertoy.com/view/lssXRB
// Created by vincent francois - cyanux/2014
// Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License (CC BY-NC-ND 3.0)
//
// vfrancois.pro at hotmail.fr
//
// tks tekf, vgs, iq :)

// 3d function support. See https://www.shadertoy.com/view/4slSzB for main idea

// Varying this value!
#define D 10.0 // distance from object

#if 1
#define FX abs(cos(mod(iGlobalTime, 1.0) * t * 32.0)) * 0.1
#else
#define FX 0.0
#endif
// Following is a dirty code

#define T iGlobalTime
//float BASS = texture2D(iChannel1, vec2(0.002, 0.0)).y;

float BASS = texture2D(iChannel0, vec2(0.002, 0.0)).y;

vec3 rX(vec3 v, float t) {
	float COS = cos(t);
	float SIN = sin(t);
	return vec3(v.x,SIN*v.z+COS*v.y,COS*v.z-SIN*v.y);
}
vec3 rY(const vec3 v, const float t) {
	float COS = cos(t);
	float SIN = sin(t);
	return vec3(COS*v.x-SIN*v.z, v.y, SIN*v.x+COS*v.z);
}
float sdTruncatedOctahedron(vec3 p, float r) {
	return
		max(
		abs(p.x) +
		abs(p.y) + 
		abs(p.z) - (r+r+r),
		max(abs(p.x) - r, 0.0) - 0.5 * r +
		max(abs(p.y) - r,0.0) - 0.5 * r +
		max(abs(p.z) - r,0.0)
		);
}
float fn(vec3 A, vec3 B, vec3 U, float t, float f) {
	vec3 a = B - A;
	vec3 n = vec3(0.0, 1.0, 0.0);
	vec3 i = n * f * 0.5 + a * t + A;
	return 0.2 * (length(i-U) - 0.3- FX); // AA trick
}
bool is_dCM = false;
float scene(vec3 p) {
	p = rX(p, iGlobalTime);
	float dCM = -sdTruncatedOctahedron(p, 16.0);
	float t = dot(vec3(1.0, 0.0, 0.0), p - vec3(-0.5,0.0,0.0));
	float dO = fn(vec3(-0.5,0.0,0.0),vec3(0.5,0.0,0.0),p,t,4.0 * BASS * sin(T + t * 0.5) * 2.0 * sin(T + t * 2.));
	if(dCM < dO) {
		is_dCM = true;
		return dCM;
	}
		return dO;
}
vec2 M = 8.0 * (iMouse.xy / iResolution.xy - 0.5);
vec3 ro = -rY(rX(vec3(0.0, 0.0, D) , M.y), M.x);
vec4 render(vec2 uv)
{
	vec3 rd = normalize(rY(rX(vec3(uv, 1.0), M.y), M.x));	
	vec3 g;
	float d;
	for(float n = 0.0; n < 256.0; n++) {
		d = scene(ro);
		if(d < 0.03) {
			g.x = scene(ro + vec3(0.001, 0.0, 0.0));
			g.y = scene(ro + vec3(0.0, 0.001, 0.0));
			g.z = scene(ro + vec3(0.0, 0.0, 0.001));
			break;
		}
		else
			ro += rd * d * 0.5;
	}	
	/*if(is_dCM == true) {
		return texture2D(iChannel0, ro.xy);
		//return vec4(iBackgroundColor, 1.0);
		//return vec4(iBR, iBG, iBB, 1.0);
	}*/
	
	vec3 n = normalize(g-d);
	rd = normalize(rd);
	
	return
		mix(
			mix(
				texture2D(iChannel0, reflect(rd + 0.1, n).xy),
				texture2D(iChannel0, reflect(rd, n).xy),
				0.5),
				mix(
					texture2D(iChannel0, reflect(rd - 0.1, n).xy),
					texture2D(iChannel0, ro.xy),
					0.1),
			0.5);
}

void main(void) {
	vec2 ar = vec2(iResolution.x/iResolution.y, 1.0);
	vec2 uv = iZoom * ar * (gl_FragCoord.xy / iResolution.xy - 0.5);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
	
	/*gl_FragColor = mix( mix( mix( render(uv),render(uv + 0.1),0.5), render(uv - 0.1),0.5), texture2D(iChannel0, gl_FragCoord.xy/iResolution.xy), 0.1);
	gl_FragColor = mix( mix( render(uv),render(uv + 0.1),0.5), render(uv - 0.1),0.5), texture2D(iChannel0, gl_FragCoord.xy/iResolution.xy);*/
	gl_FragColor = render(uv);
			
}
