// https://www.shadertoy.com/view/MsSXWz
// srtuss, 2014

float mdf3(float n, vec3 p, vec3 fl)
{
    float rrr = sin(4262.16996 * n);
	if(fract(1153.5 * rrr) > 0.5)
        p.xy = p.yx;
    if(fract(142.6 * rrr) > 0.5)
        p.yz = p.zy;
    
    
    vec3 ss = vec3(0.0, 0.0, 0.5);
    
    vec3 q = abs(p - ss) - ss;
    
    float v;
    v = max(max(q.x, q.y), q.z);
    
    return v;
}

float maze3(vec3 p)
{
    vec3 fr = fract(p);
	vec3 fl = floor(p);
    
#ifndef UNROLLED
    float n = fl.x + fl.y * 2.0 + fl.z * 4.0;
    float v = 1e38;
    for(int i = 0; i <= 1; i ++)
    {
        for(int j = 0; j <= 1; j ++)
        {
            for(int k = 0; k <= 1; k ++)
            {
                vec3 cc = vec3(k, j, i);
                
                v = min(v, mdf3(n, fr - cc, fl + cc));
                n += 1.0;
            }
        }
    }
#else
    v = mdf3(n, fr, fl); n += 1.0;
    v = min(v, mdf3(n, fr - vec3(1., 0., 0.), fl + vec3(1., 0., 0.))); n += 1.0;
    v = min(v, mdf3(n, fr - vec3(0., 1., 0.), fl + vec3(0., 1., 0.))); n += 1.0;
    v = min(v, mdf3(n, fr - vec3(1., 1., 0.), fl + vec3(1., 1., 0.))); n += 1.0;
    v = min(v, mdf3(n, fr - vec3(0., 0., 1.), fl + vec3(0., 0., 1.))); n += 1.0;
    v = min(v, mdf3(n, fr - vec3(1., 0., 1.), fl + vec3(1., 0., 1.))); n += 1.0;
    v = min(v, mdf3(n, fr - vec3(0., 1., 1.), fl + vec3(0., 1., 1.))); n += 1.0;
    v = min(v, mdf3(n, fr - vec3(1., 1., 1.), fl + vec3(1., 1., 1.)));
#endif
    
    return v;
}

#define ITS 8

vec2 circuit(vec3 p)
{
	p = mod(p, 2.0) - 1.0;
	float w = 1e38;
	vec3 cut = vec3(1.0, 0.0, 0.0);
	vec3 e1 = vec3(-1.0);
	vec3 e2 = vec3(1.0);
	float rnd = 0.23;
	float pos, plane, cur;
	float fact = 0.7;
	float j = 0.0;
	for(int i = 0; i < ITS; i ++)
	{
		pos = mix(dot(e1, cut), dot(e2, cut), (rnd - 0.5) * fact + 0.5);
		plane = dot(p, cut) - pos;
		if(plane > 0.0)
		{
			e1 = mix(e1, vec3(pos), cut);
			rnd = fract(rnd * 9827.5719);
			cut = cut.yzx;
		}
		else
		{
			e2 = mix(e2, vec3(pos), cut);
			rnd = fract(rnd * 15827.5719);
			cut = cut.zxy;
		}
		j += step(rnd, 0.2);
		w = min(w, abs(plane));
	}
	return vec2(j / float(ITS - 1), w);
}


vec2 rotate(vec2 k,float t)
{
	return vec2(cos(t) * k.x - sin(t) * k.y, sin(t) * k.x + cos(t) * k.y);
}

vec3 tri(vec3 p, float s)
{
    return abs(fract(p / s) * 2.0 - 1.0) * 0.5 * s;
}
    
float scene(vec3 p)
{
    float sc = 3.0;
    vec3 q = abs(p);
    float wnd = max(max(q.x, q.y), q.z) - 1.1;
    float v = maze3(p * sc) / sc - 0.05;
    float ll = length(p.yz - 0.5);
    v = max(v, -ll + 0.5);
    ll = length(vec2(mod(p.x, 4.0) - 2.0, p.y) - 0.5);
    v = max(v, -ll + 0.35);
    sc = 3.0 * 5.0;
    float w = min(v, maze3(p * sc) / sc - 0.027);
    v = min(v, max(v - 0.03, w));
    sc = 3.0 * 0.5;
    w = min(v, maze3(p * sc - 0.5) / sc - 0.05);
    v = min(v, max(v - 0.3, w));
    return v;
}

vec3 normal(vec3 p)
{
    vec2 h = vec2(0.003, 0.0);
    return normalize(vec3(scene(p + h.xyy) - scene(p - h.xyy), scene(p + h.yxy) - scene(p - h.yxy), scene(p + h.yyx) - scene(p - h.yyx)));
}

float amb_occ(vec3 p)
{
	float acc = 0.0;

	float h = 0.01;
	acc += scene(p + vec3(-h, -h, -h));
	acc += scene(p + vec3(-h, -h, +h));
	acc += scene(p + vec3(-h, +h, -h));
	acc += scene(p + vec3(-h, +h, +h));
	acc += scene(p + vec3(+h, -h, -h));
	acc += scene(p + vec3(+h, -h, +h));
	acc += scene(p + vec3(+h, +h, -h));
	acc += scene(p + vec3(+h ,+h, +h));
	return acc * 0.5 / h;
}

void main(void)
{

	//vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
	vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
	uv.x *= float(iResolution.x )/ float(iResolution.y);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;

	/*vec2 uv = gl_FragCoord.xy / iResolution.xy;
    uv = 2.0 * uv - 1.0;
    uv.x *= iResolution.x / iResolution.y;*/
    
    vec3 ro = vec3(0.5, 0.5, 0.5);
    vec3 rd = normalize(vec3(uv, 1.0));
    
    float pn = iGlobalTime * 0.3 + sin(iGlobalTime * 0.3) * 0.5;
    rd.xz = rotate(rd.xz, pn);
    float tl = iGlobalTime * 0.1 + sin(iGlobalTime * 0.1) * 0.12;
    rd.xy = rotate(rd.xy, tl);
    ro.x += iGlobalTime * 0.2;

    
    float d = 0.0;
    vec3 r;
    for(int i = 0; i < 35; i ++)
    {
        r = ro + rd * d;
        d += scene(r);
    }
    
    r = ro + rd * d;
    vec3 col = vec3(0.);
    if(d < 4.0)
    {
        vec3 ref = reflect(rd, normal(r));
        col = vec3(1.0);
        col *= smoothstep(-4.0, 4.0, amb_occ(r)) * 0.5 + 0.6;
        vec3 rr = r;
        float sc = 3.5;
        col += exp(max((-maze3(rr * sc) + 0.4) / sc, 0.0) * -100.0) * 0.5;
        sc = 14.0;
        float di = circuit(r).y;
        col += smoothstep(0.001, 0.0, di - 0.001) * 0.3 + exp(di * -30.0) * 0.3 * (sin(r.z * 10.0 + iGlobalTime * -4.0) + 1.0);
        //col += textureCube(iChannel0, ref).x * 0.3;
        col = col * exp(d * -1.5);
    }
    
    float ll = length(uv);
    col *= exp(ll * ll * -0.3);
    col = pow(col, vec3(1.0, 0.5, 0.8) * 4.0) * 3.5;
    col = pow(col, vec3(1.0 / 2.2));
	gl_FragColor = vec4(col, 1.0);
}

