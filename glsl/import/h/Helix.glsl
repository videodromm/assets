// https://www.shadertoy.com/view/MsjGRV

float de(vec3 p)
{
	return length(
		p-vec3(
	 		sin(atan(p.x, p.y)),
			sin(atan(p.y, p.x)),
			0.08*acos(sin(atan(p.x, p.y)))*p.y/abs(p.y)
		)
	);
}

float map(vec3 p)
{
	float d = 1.0;
	vec3 pp = vec3(0.0, 0.0, -1.25);
	for (int i = 0; i < 5; i++)
	{
		d = min(d, de(p+pp));
		pp.z += 0.5;
	}
	return d-0.15;
}

vec3 calcNormal(vec3 p)
{
	vec3 eps = vec3(0.0001,0.0,0.0);
	vec3 nor = vec3(
		map(p+eps.xyy)-map(p-eps.xyy),
		map(p+eps.yxy)-map(p-eps.yxy),
		map(p+eps.yyx)-map(p-eps.yyx));
	return normalize(nor);    
}

vec3 render(vec3 ro, vec3 rd)
{
	vec3 col = vec3(0.8, 1.0, 0.5);
	float t = 0.0, d;
	vec3 p = ro;
	for(int i=0; i<64; ++i)
	{
		d = map(p);
		t += d;
		p = ro+t*rd;
	}
	if(abs(d) < 0.001)
	{
		vec3 nor = calcNormal(p);
		float c = dot(normalize(vec3(1.0)),nor);
		return c*col;
	}else{
		return iBackgroundColor;
	}
}

vec4 quaternion(vec3 p, float a)
{
	return vec4(p*sin(a/2.0), cos(a/2.0));
}

vec3 qtransform(vec4 q, vec3 p)
{
	return p+2.0*cross(cross(p, q.xyz)-q.w*p, q.xyz);
}

void main(void)
{
	vec2 p = (gl_FragCoord.xy*2.0-iResolution.xy)/iResolution.y;
	vec3 rd = normalize(vec3(p, -1.8));
	vec3 ro = vec3(0.0, 0.0, 5.0);
	vec4 q = quaternion(normalize(vec3(1.0)), iTime);
	rd = qtransform(q, rd);
	ro = qtransform(q, ro);
    gl_FragColor=vec4(render(ro, rd), 1.0);
}
