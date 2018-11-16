// https://www.shadertoy.com/view/4d2SRm
#define WHY_WONT_THESE_COMMENTED_LINES_LET_ME_CHANGE_THEM

// srtuss, 2013
// please don't try to read or understand the code. it's something i threw together quickly.

#define SCANLINES
#define LENS_DISTORT
//#define RED_VERSION


#define pi2 6.283185307179586476925286766559

vec2 rotate(vec2 p, float a)
{
	return vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
}

float tri(float x, float s)
{
    return abs(fract(x / s) * 2.0 - 1.0) * s * 0.5;
}

float tri(float x, float s, out float id)
{
    x /= s;
    id = floor(x);
    return abs(fract(x) * 2.0 - 1.0) * 0.5 * s;
}

#define ITER 10

vec2 circuit(vec2 p)
{
	p = fract(p);
	float r = 0.123;
	float v = 0.0, g = 0.0;
	float test = 0.0;
	r = fract(r * 9184.928);
	float cp, d;
	
	d = p.x;
	g += pow(clamp(1.0 - abs(d), 0.0, 1.0), 160.0);
	d = p.y;
	g += pow(clamp(1.0 - abs(d), 0.0, 1.0), 160.0);
	d = p.x - 1.0;
	g += pow(clamp(1.0 - abs(d), 0.0, 1.0), 160.0);
	d = p.y - 1.0;
	g += pow(clamp(1.0 - abs(d), 0.0, 1.0), 160.0);
	
	for(int i = 0; i < ITER; i ++)
	{
		cp = 0.5 + (r - 0.5) * 0.9;
		d = p.x - cp;
		g += pow(clamp(1.0 - abs(d), 0.0, 1.0), 160.0);
		if(d > 0.0)
		{
			r = fract(r * 4829.013);
			p.x = (p.x - cp) / (1.0 - cp);
			v += 1.0;
			test = r;
		}
		else
		{
			r = fract(r * 1239.528);
			p.x = p.x / cp;
			test = r;
		}
		p = p.yx;
	}
	v /= float(ITER);
	return vec2(v, g);
}

float df(vec2 p, vec2 pol)
{
    float rp = 0.25;
    float v = abs(fract(pol.y / rp) * 2.0 - 1.0) * rp;
    float id = floor(pol.y / rp);
    v -= 0.2;
    float pa = 0.3 + id + iTime * sin(id * 97354.6874);
    rp = 0.4;
    pa = abs(fract(pol.x / rp) * 2.0 - 1.0) * rp;
    float w = dot(p, vec2(sin(pa), cos(pa)));
    w = max(w, dot(p, vec2(sin(pa + 2.0), cos(pa + 2.0))));
    v = max(v, w);
    return v;
}

float hash(float x)
{
    return fract(cos(x * 73935.289367) * 396.87);
}

vec2 hash2(in vec2 p)
{
	return fract(1965.5786 * vec2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
}

float qd(vec2 p, float id)
{
    return max(abs(p.y) - 0.05 * hash(id), abs(p.x) - 0.13 - hash(id + 11.11) * 0.1);
}

float col(vec2 uv)
{
    vec2 pol = vec2(atan(uv.y, uv.x) / pi2, length(uv));
    float v = df(uv, pol);
    float ts = 0.2;
    float id;
    float tr = tri(uv.y, ts, id);
    v = qd(vec2(uv.x, tr), id);
    float fo = 30.0;
    float br = exp(-fo * qd(vec2(uv.x, tr), id)) + exp(-fo * qd(vec2(uv.x, tr - ts), id + 1.0)) + exp(-fo * qd(vec2(uv.x, tr + ts), id - 1.0));
    v = min(v, length(uv) - 2.0);
    v = smoothstep(0.015, 0.0, v) + br * 0.1;
    vec2 cc = circuit(uv * 0.3);
    v += cc.y * 0.05;
    return v;
}

float stpnse(float x)
{
    float fl = floor(x);
    float ss = 0.1;
    return mix(hash(fl), hash(fl + 1.0), smoothstep(0.5 - ss, 0.5 + ss, fract(x)));
}

float hashX(float x)
{
    return floor(fract(x * 1972.578672) * 4.0);
}

float stpnseX(float x)
{
    float fl = floor(x);
    float ss = 0.1;
    return mix(hashX(fl), hashX(fl + 1.0), smoothstep(0.5 - ss, 0.5 + ss, fract(x)));
}

float pix2(vec2 p, float t)
{
    float tt = t * 0.3;
    p = rotate(p, (stpnseX(tt + 1.0) + stpnseX(tt * 2.0)) * pi2 * 0.25);
    p *= 0.3 + (stpnse(t) + stpnse(t * 2.0) * 0.5) * 0.8;
    p.y += cos(t) * 4.0 + t * 4.0;
    t *= 0.4;
    
    p.x += ((stpnse(t) + stpnse(t * 2.0) * 0.5) - 0.5) * 1.5;
    t += 11.111;
    
    return col(p);
}

float fr2(vec2 p, float h)
{
    vec2 q = abs(vec2(tri(p.x, 0.09), p.y));
    return max(q.x, q.y - h) - 0.002;
}

float fr3(vec2 p, float h)
{
    vec2 q = abs(vec2(tri(p.x * 6.0, 0.09), p.y));
    float v = max(q.x, q.y - h) - 0.002;
    
    float ror = stpnse(iTime) + stpnse(iTime * 2.0) * 0.3;
    
    q = abs(vec2(tri(p.x + ror, 0.5), p.y));
    v = min(v, max(q.x, q.y) - 0.1);
    
    q = abs(vec2(tri(p.x + iTime * 0.1, 0.3), p.y + 0.1));
    v = min(v, max(q.x, q.y) - 0.1);
    
    return v;
}

float fr4(vec2 p, float l, float seed)
{
    vec2 pp = p;
    
    p.x += seed;
    
    float v;
    float w = dot(p, normalize(vec2(1.5, 1.0)));
    w = min(min((tri(w, 0.4444444)), (tri(w, 0.555555)) - 0.02), (tri(w, 0.566666)) - 0.01);
    
    v = max(w, abs(p.y) - 0.09);
    
    
    w = dot(p, normalize(vec2(-1.0, 0.2)));
    w = min(min((tri(w, 0.24251)), (tri(w, 0.36548)) - 0.02), (tri(w, 0.14)) - 0.005);
    
    w = max(w, abs(p.y) - 0.12);
    
    v = min(v, w);
    
    
    w = min(min((tri(p.x, 0.9)), (tri(p.x, 1.2)) - 0.02), (tri(p.x, 2.4)) - 0.09);
    v = max(v, 0.08 - w);
    
    return max(max(v, pp.x - 5.5 * l), -pp.x);
}

float fr5(vec2 p, float t)
{
    float id = floor(t / 3.0) * 10.0;
    t = mod(t, 3.0);
    t *= 5.0;
    
    float v = 1e38;
    float rr = 0.873;
    for(int i = 0; i < 8; i ++)
    {
        float l = t;
        rr = fract(rr * 10472.842);
        v = min(v, fr4(p, min(l, rr + 0.03), id + float(i)));
        t -= 1.0;
        p.y += 0.5;
    }
    return v;
}

float pix(vec2 p)
{
    float ite = 0.0;
    for(int i = 0; i < 10; i ++)
    {
        float tc = 0.05;
        ite += pix2(p, iTime + (hash2(p + float(i)) - 0.5).x * tc);
    }
    float v = ite / 10.0;
    
    float lc = length(p);
    float w = abs(lc - 0.5);
    
    w = min(w, fr2(vec2(p.x, abs(p.y) - 0.95), 0.02));
    vec2 pol = vec2(atan(p.y, p.x) / pi2, lc);
    w = min(w, fr3(pol - vec2(0.0, 0.7), 0.02));
    w = min(w, abs(lc - 0.1));
    w = min(w, fr5((p - vec2(1.0, 0.7)) * 6.0, iTime) / 6.0);
    
    w = min(w, abs(length(p - vec2(-1.4, 0.7)) - 0.04));
    w = min(w, abs(length(p - vec2(-1.2, 0.7)) - 0.04));
    w = min(w, abs(length(p - vec2(-1.0, 0.7)) - 0.04));
    
    vec2 q = p;
    q.x = -abs(q.x);
    q -= vec2(-0.2, 0.0);
    //w = min(w, max(max(length(q) - 0.9, -length(q - vec2(0.25, 0.0)) + 1.0) + 0.03, p.y));
    w = min(w, max(abs(q.y), q.x + 0.8));
    
    if(fract(iTime / 6.0) > 0.7 && sin(iTime * 50.0) > 0.0)
    {
        q = p - vec2(1.3, -0.6);
        q.x = abs(q.x);
        float ww = max(dot(q, normalize(vec2(1.0, -0.2))), abs(q.y - 0.2) - 0.15);
        q.y += 0.05;
        ww = min(ww, length(q) - 0.04);
        w = min(w, abs(ww));
    }
    v += smoothstep(0.01, 0.0, w) * 0.09 + exp(max(0.0, w) * -20.0) * 0.03;
    
#ifdef SCANLINES
    v *= sin(p.y * 300.0) * 0.15 + 0.9;
#endif
    
    return v;
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy/iResolution.xy;
    
    uv = iZoom * 2.0 * uv - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
#ifdef LENS_DISTORT
    float ll = dot(uv, uv);
    uv *= (ll * ll * 0.01 + ll * ll * ll * 0.001 + ll * 0.04) * -0.3 + 1.01;
#endif
    
    uv += (vec2(hash(iTime), hash(iTime - 1.111)) - 0.5) * 0.04;
    
    vec2 ps = (7.0 + 5.0 * sin(iTime)) / iResolution.xy;
    
    vec3 col = vec3(pix(uv - vec2(ps.x, 0.0)), pix(uv + vec2(0.0, ps.y * 0.3)), pix(uv + vec2(ps.x, 0.0)));
    
    
    col *= exp(length(uv) * -2.0) * 3.0;
    
    #ifdef RED_VERSION
    col = pow(col, vec3(0.5, 0.8, 1.0)) * 3.4;
    #else
    col = pow(col, vec3(1.0, 0.8, 0.5) * 0.95) * 4.4;
    #endif
    
    col = pow(col, vec3(1.0 / 2.2));
    
	gl_FragColor = vec4(col, 1.0);
}
/*
	vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
	vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
	uv.x *= float(iResolution.x )/ float(iResolution.y);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
*/
