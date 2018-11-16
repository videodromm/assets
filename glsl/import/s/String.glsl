// https://www.shadertoy.com/view/4sXGR8
//rotate
vec3 _rot(vec3 d, float rot) {
	mat3 M = mat3(
	  cos(rot),  sin(rot), 0,
	  sin(rot), -cos(rot), 0,
	  0,       0,      1);
	d = (M * d).zxy;
	return (M * d).xzy;
}

//torus
float torus(vec3 p) {
	float  R    = 0.7;
	float  rr   = 0.05;
	vec3   d    = abs(mod(p, 4.0)) - 2.0;
	d           = _rot(d.yxz, 2.2*iTime + p.z);
	float    g  = length(d.xy) - R * R;
	g = (g * g) + (d.z * d.z);
	return sqrt(g) - rr;
}

//rm map
float map(vec3 p) {
	float ktt   = iTime;
	float time  = ktt * 3.3 + sin(0.3 * ktt + sin(ktt * 0.5) + p.z * 0.43);
	int   ctime = int(iChannelTime[0]);
	vec3  tp    = p;
	vec3  up    = p;
	
	if(ctime >= 4*2) {
		p.x        += sin(p.z  * 0.5 + time);
		p.y        += cos(p.z  * 0.4 + time);
		p.z        -= sin(p.x  * 0.7 + time);
	}
	if(ctime >= 48) {
		up         += 0.7;
		up.x       += sin(up.z * 0.20) * 1.5;
		up.x       += cos(up.z * 4.00) * 0.2;
		up.y       -= cos(up.z * 0.15) * 1.0;
		up.y       += cos(up.z * 5.00) * 0.3;
	}
	
	//prim
	float c0   = length(     abs(mod(p,        8.0) ) - 4.0) - 3.8;
	float c1   = length(     abs(mod(p.xy,     1.0) ) - 0.5) - 0.5;
	float c2   = length(     abs(mod(p.xy+0.3,10.0) ) - 5.0) - 5.2;
	float c3   = length(     abs(mod(p.xy,     5.0) ) - 2.5) - 2.5*0.2;
	float c4   = length(     abs(mod(up.xy,    4.0) ) - 2.0) - 0.1;
	float k    = 2.7 - dot(abs(p), vec3(0.0, 1.0, 0.0));
	//k = max(-c0, k);
	if(ctime >= 12 )	k = max(-c1, k);
	if(ctime >= 16)	k = max(-c2, k);
	if(ctime >= 4*5)	k = max(-c3, k);
	if(ctime >= 4*0)	k = max(-c1, k);
	if(ctime >= 4*8)	k = min( c4, k);
	if(ctime >= 24 )	k = min(torus(tp + 0.3), k);
	return k;
}

//get normal
vec3 rnorm(vec3 ip) {
  float iit    = map(ip);
  vec3  h      = vec3(0.01, 0, 0);
  return normalize(vec3(
    iit - map(ip + h.xyy),
    iit - map(ip + h.yxy),
    iit - map(ip + h.yyx)));
}

void main(void) {
	//float time   = float(int(iChannelTime[0]));
	float time   = iChannelTime[0];
	
	//direction
	vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
	uv.x *= float(iResolution.x )/ float(iResolution.y);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;//	vec2  uv     = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy;
	vec3  dir    = normalize(vec3(uv * vec2(1.0, 0.75), 1.0)).yzx;
	
	//rotate
	dir          = _rot(dir.xyz, time * 0.1);
	dir          = _rot(dir.yzx, time * 0.03);
	
	//position
	vec3  pos    = vec3(time * 2.0, 0.0, time * 2.0);
	vec3  I      = pos;
	float t      = 0.0;
	
	//ray marching
	for(int i = 0 ; i < 64; i++) {
		I  = pos + dir * t;
		float h = map(I) * 0.75;
		
		//uchikiri
		if(h < 0.001) break;
		t += h;
	}
	
	//diff
	vec3  N      = rnorm(pos + dir * t);
	float D      = max(dot(pow(N, vec3(8.0)),
						   normalize(vec3(-0.5,  0.7, 1.0))), sin(iTime/16.0)*0.5);
	
	//fog-ppoino.
	float fog    = length(I - pos) * 0.03;
	
	//screen-ppoino.
	float Scr    = 1.0 - dot(uv, uv) * 0.5;
	gl_FragColor = vec4(
		0.2 * dir +
		0.7 * D   * mix(vec3(1, 2, 3), vec3(4, 2, 1), D) +
		fog, 1.0) * Scr;
}

