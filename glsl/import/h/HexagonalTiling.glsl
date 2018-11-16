// https://www.shadertoy.com/view/4d2GzV

const float s3 = 1.7320508075688772;
const float i3 = 0.5773502691896258;


const mat2 tri2cart = mat2(1.0, 0.0, -0.5, 0.5*s3);

const mat2 cart2tri = mat2(1.0, 0.0, i3, 2.0*i3);

vec3 L = vec3(i3, -i3, i3);

vec4 pick3(vec4 a, vec4 b, vec4 c, float u) {
	float v = fract(u * 0.3333333333333);
	return mix(mix(a, b, step(0.3, v)), c, step(0.6, v));
}

vec4 closestHexCenters(vec2 p) {
	
	vec2 pi = floor(p);
	vec2 pf = fract(p);

	vec4 nn = pick3(vec4(0.0, 0.0, 2.0,  1.0),
					vec4(1.0, 1.0, 0.0, -1.0),
					vec4(1.0, 0.0, 0.0,  1.0),
					pi.x + pi.y);
	
	return ( mix(nn, nn.yxwz, step(pf.x, pf.y)) +
			 vec4(pi, pi) );
	
}

vec3 perpBisector(vec2 p1, vec2 p2) {
	vec2 p21 = p2-p1;
	vec3 pa = vec3(p1+0.5*p21, 1.0);
	vec3 pb = vec3(pa.x-p21.y, pa.y+p21.x, 1.0);
	vec3 l = cross(pa, pb);
	return l * inversesqrt(dot(l.xy, l.xy));
}

float hash(vec2 pos) {
	return texture2D(iChannel0, fract(pos/511.0)).x;
}


void main(void) {
	
	float scl = (0.03 + 0.02*(1.0+sin(0.31*iTime))) * 200.0 / min(iResolution.x, iResolution.y);
	
	float cx = 2.0 * cos(iTime*0.3) + 1.0 * cos(iTime*0.7+2.0);
	float cy = 4.0 * sin(iTime*0.4) + 0.3 * sin(iTime*1.2+4.0);
	float theta = 0.05*iTime;
		
	vec2 pos = (gl_FragCoord.xy - 0.5*iResolution.xy)*scl + vec2(cx, cy);
	
	float ct = cos(theta);
	float st = sin(theta);
	
	pos = mat2(ct, -st, st, ct) * pos;
	L.xy = mat2(ct, -st, st, ct) * L.xy;
	
	vec4 h = closestHexCenters(cart2tri*pos);
	
	vec2 q1 = tri2cart * h.xy;
	
	float s = step(hash(h.xy), 0.5)*2.0-1.0;
	
	vec2 d1 = pos - q1;
	
	float l = min(min(distance(d1, vec2(-s*1.0, 0.0)), 
					  distance(d1, vec2(s*0.5, 0.5*s3))), 
				      distance(d1, vec2(s*0.5, -0.5*s3)));
	
	
	const float r = 0.5;

	vec4 truchet = vec4(vec3(smoothstep(0.1+scl, 0.1, abs(l-r))), 1.0);
	
	vec2 q2 = tri2cart * h.zw;
	
	vec4 rgb = pick3(vec4(1.0, 0.0, 0.0, 1.0),
					 vec4(0.0, 1.0, 0.0, 1.0),
					 vec4(0.0, 0.0, 1.0, 1.0),
					 h.x);
	
	vec3 line = perpBisector(q1, q2);

	float d = dot(vec3(pos, 1.0), line);

	//vec4 black = vec4(vec3(0.), 1.0);
	vec4 black = vec4(iBackgroundColor, 1.0);
	
	vec2 nxy = mix(0.4*line.xy, vec2(0.0), smoothstep(0.3, 0.3+scl, d));
	
	vec3 N = vec3(nxy, sqrt(1.0-dot(nxy,nxy)));
	float ln = clamp(0.0, 1.0, dot(L, N));
	
	vec4 lite = mix(rgb, vec4(1.0), clamp(0.0, 1.0, 2.0*ln-1.0));
	vec4 dark = mix(black, rgb, clamp(0.0, 1.0, 2.0*ln));
	vec4 lrgb = mix(dark, lite, step(0.5, ln));
	
	vec4 crgb = mix(black, lrgb, smoothstep(0.01, 0.01+scl, d));
	
	float t = fract(0.04*iTime);
	float invb = 4.0;
	
	float k = smoothstep(0.0, 1.0, min(t*invb-0.5*invb+1.0, -t*invb+invb));
		
	gl_FragColor = mix(crgb, truchet, k);
	
}
