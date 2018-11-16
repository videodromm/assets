// https://www.shadertoy.com/view/ls2GDR
vec2 rot(vec2 p, float r)
{
	return vec2(
		cos(r) * p.x - sin(r) * p.y,
		sin(r) * p.x + cos(r) * p.y);
}

float siso(vec3 p)
{
	float h = iTime * 1.5 + sin(iTime * 1.3) * 0.3;
	float k = 0.05;
	vec2  m = vec2(6, 5);
	vec2  b = vec2(1, 0.5);
	for(int i = 0 ; i < 3; i++)
	{
		p.xz += vec2(
			cos(p.y * m.x + h * b.x),
			sin(p.y * m.y + h * b.x)) * k;
		k *= 13.0 + sin(h);
		m = -m.yx * 0.125;
		b = -b.yx * 1.07;
		h *= 1.5;
	}
	return length(mod(p.xz, 60.0) - 30.0) - 3.0;
}

float iso(vec3 p)
{
	return min(siso(p.zxy + 15.0), min(siso(-p.xzy), siso(-p + 15.0)));
}

void main( void ) {
	float h = iTime;

	vec2 uv  = -1.0 + 2.0 * ( gl_FragCoord.xy / iResolution.xy );
	vec3 pos = vec3(0, 0, h*30.0);
	vec3 dir = normalize(vec3(uv * vec2(iResolution.x / iResolution.y, -1.0), 1.0));

	dir.yz = rot(dir.yz, h * 0.1 + iMouse.y * 0.01);
	dir.xy = rot(dir.xy, h * 0.1 + iMouse.x * 0.01);

	float t = 0.0;

	for(int i = 0 ; i < iSteps; i++)
		t += iso(dir * t + pos) * 0.9;

	vec3 ip  = t * dir + pos;

	vec3 col = vec3(t * 0.0005 + abs(iso(ip + 0.05)) ) * vec3(5, 2, 1);

	col = sqrt(col + dir * 0.2);
	gl_FragColor = vec4(col * (1.0 - pow(dot(uv*uv, uv*uv), 4.0)), 1.0);

}
