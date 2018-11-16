// https://www.shadertoy.com/view/XdfGDn

//-----------------------------------------------------------------------------
// Maths utils
//-----------------------------------------------------------------------------
mat3 CCmat = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );
float CChash( float n )
{
    return fract(sin(n)*43758.5453);
}

float CCnoise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( CChash(n+  0.0), CChash(n+  1.0),f.x),
                        mix( CChash(n+ 57.0), CChash(n+ 58.0),f.x),f.y),
                    mix(mix( CChash(n+113.0), CChash(n+114.0),f.x),
                        mix( CChash(n+170.0), CChash(n+171.0),f.x),f.y),f.z);
    return res*2.0-1.0;
}

float CCfbm( vec3 p )
{
    float f;
    f  = 0.5000*CCnoise( p ); p = CCmat*p*2.02;
    f += 0.2500*CCnoise( p ); p = CCmat*p*2.03;
    f += 0.1250*CCnoise( p );
    return f;
}

vec2 CCnoise2(vec2 p)
{
	return 
		vec2(
			CCnoise(vec3(p, 1.9+sin(iTime*0.8)*1.3)), 
			CCnoise(vec3(p, -1.2+sin(iTime*1.2)*1.0)));
}

vec2 CCnoise2(vec2 p, float fudge)
{
	return 
		vec2(
			CCnoise(vec3(p, fudge+sin(iTime*0.8)*1.3)), 
			CCnoise(vec3(p, -fudge+sin(iTime*1.2)*1.0)));
}


float CCtriangleWave(float value)
{
	float hval = value*0.5;
	return 2.0*abs(2.0*(hval-floor(hval+0.5)))-1.0;
}

vec4 CCtriangleWave(vec4 col)
{
	return 
		vec4(
			CCtriangleWave(col.x),
			CCtriangleWave(col.y),
			CCtriangleWave(col.z),
			CCtriangleWave(col.w));
}

// Mattias' drawing functions ( http://sociart.net/ )
// Terminals
vec4 CCsimplex_color(vec2 p) 
{
	const float offset=12.0;
	const float CCzoom = 2.45;
	float x = p.x*CCzoom;
	float y = p.y*CCzoom;
	vec4 col= vec4(
		CCfbm(vec3(x,y, offset)),
		CCfbm(vec3(x,y, offset*1.25)),
		CCfbm(vec3(x,y, offset*2.33)),
		CCfbm(vec3(x,y, offset*3.66)));
	
	return (col-0.5)*1.5;
}

vec4 CCbw_noise(vec2 p, float off) 
{
	p *= 1.5;
	float val = 
		(CCnoise(vec3(p.x*2.2+(off*0.6+0.23)*0.22, p.y*2.2, 1.4+off*0.22))*0.66+
		CCnoise(vec3(p.x*3.2, p.y*3.2+(off*1.2-0.3)*0.36, 4.3+(off*1.1+1.5*0.12)))*0.33)*2.0;
	
	return vec4(val);
}

float CCridged( vec3 p )
{
   	float f = abs(CCnoise(p));				  
	f += abs(0.5000*CCnoise( p )); p = CCmat*p*2.02;
	f += abs(0.2500*CCnoise( p )); p = CCmat*p*2.03;
	f += abs(0.1250*CCnoise( p ));
	return f;
}

vec4 CCridged_color(vec2 p)
{
	const float offset=0.2;
	float x = p.x*2.5;
	float y = p.y*2.5;
	vec4 col= vec4(
		1.0-CCridged(vec3(x,y, offset)),
		1.0-CCridged(vec3(x,y, offset*2.0)),
		1.0-CCridged(vec3(x,y, offset*3.0)),
		1.0-CCridged(vec3(x,y, offset*4.0)));
	
	return col-0.55;
}

vec4 CCridged_bw(vec2 p)
{
	const float offset=0.2;
	float x = p.x*2.5;
	float y = p.y*2.5;
	float f= 1.0-CCridged(vec3(x,y, offset));
	vec4 col= vec4(f);
	
	return col-0.35;
}

vec4 CCridged_bw(vec2 p, float off)
{
	const float offset=0.2;
	float x = p.x*2.5;
	float y = p.y*2.5;
	float f= 1.0-CCridged(vec3(x,y, offset*off));
	vec4 col= vec4(f);
	
	return col-0.35;
}

vec4 CCx_y_ang_dist(vec2 p)
{
	float CCang = atan(p.y, p.x);
	return CCtriangleWave(vec4(p.x*p.x+p.y*p.y, p.x, p.y, CCang));
}

vec2 CCzoom2(vec2 a, vec4 b)
{
	return vec2(a.x*b.x, a.y*b.y);
}

// Functions
vec4 CCdist(vec2 pos)
{
	float d = CCtriangleWave(length(pos));	
	return vec4(d, d, d, d);
}

vec4 CCrol(vec4 col)
{
	return
		vec4(col.w, col.x, col.y, col.z);
}

vec4 CCror(vec4 col)
{
	return
		vec4(col.y, col.z, col.w, col.x);
}

const float CCpi=3.14159;
const float CCpiDiv=1.0/CCpi;
const float CCpi2 = 2.0*CCpi;
vec4 CCang(vec2 pos)
{
	float angle = atan(pos.y, pos.x)*CCpiDiv;
	float val = CCtriangleWave(angle);
	return vec4(val, val, val, val);
}

vec4 CCadd(vec4 a, vec4 b)
{
	return CCtriangleWave(a+b);
}

vec4 CCsub(vec4 a, vec4 b)
{
	return a-b;
}

vec4 CCmul(vec4 a, vec4 b)
{
	return CCtriangleWave(a*b);
}

// Warpers
vec2 CCjulia(vec2 p)
{
	float radius = pow(p.x*p.x+p.y*p.y,0.25);
	float angle = atan(p.y, p.x)*0.5;
	return vec2(radius * cos(angle), radius*sin(angle));
}

vec4 CCsinf(vec4 p)
{
	return vec4(sin(p.x*CCpi2), sin(p.y*CCpi2),sin(p.z*CCpi2),sin(p.w*CCpi2));
}

vec4 CCminf(vec4 a, vec4 b)
{
	return CCtriangleWave(min(a,b));
}

vec4 CCmaxf(vec4 a, vec4 b)
{
	return CCtriangleWave(max(a,b));
}

vec2 CCzoom(vec2 pos, vec4 arg)
{
	float zoomFactor = (arg.x+arg.y+arg.z+arg.w)*0.25;
	return pos * zoomFactor;
}
	
vec2 CCzoomin(vec2 p)
{
	return p*CCpiDiv;
}

vec2 CCzoomout(vec2 p)
{
	return p*CCpi;
}

vec2 CCswirl(vec2 p)
{
	float swirlFactor = 3.0*(sin(iTime+0.22)-1.5);
	float radius = length(p);
	float angle = atan(p.y, p.x);
	float inner = angle-cos(radius*swirlFactor);
	return vec2(radius * cos(inner), radius*sin(inner));
}

vec2 CChorseShoe(vec2 p)
{
	float radius = length(p);
	float angle = 2.0*atan(p.y, p.x);
	return vec2(radius * cos(angle), radius*sin(angle));
}

vec2 CCkaleidoscope(vec2 p)
{
	float zoomFactor = 1.5;
	float repeatFactor = 3.0;
	float radius = CCtriangleWave(length (p)*zoomFactor);
	float angle = atan(p.y, p.x)*repeatFactor;
	return vec2(radius * cos(angle), radius*sin(angle));
}


vec2 CCwrap(vec2 p)
{
	float zoomFactor = 1.5*(sin(iTime+0.36));
	float repeatFactor = 3.0;
	float radius = length(p)*zoomFactor;
	float angle = atan(p.y, p.x)*repeatFactor;
	return vec2(radius * cos(angle), radius*sin(angle));
}

vec2 CCmirror(vec2 p)
{
	return vec2(abs(p.x), p.y);
}
	

vec2 CCarray(vec2 p)
{
	const float zoomOutFactor=1.5;
	return vec2(CCtriangleWave(p.x*zoomOutFactor), CCtriangleWave(p.y*zoomOutFactor));
}

vec2 CCpan_rotate_zoom(vec2 pos, vec4 val)
{
	vec2 CCpan = vec2(val.w, val.x);
	float angle= CCpi*val.y*(sin(iTime+1.2)-1.0);
	float CCzoom = val.z;
	
	float sinAngle = sin(angle);
	float cosAngle = cos(angle);
	
	// Pan
	vec2 next = pos+CCpan;
	// Rotate
	next = 
		vec2(
			cosAngle*next.x-sinAngle*next.y,
			sinAngle*next.x+cosAngle*next.y);
	// Zoom
	next *= 1.0+CCzoom;
	return next;
}

vec4 CCblend(vec4 a, vec4 b, vec4 c)
{
	float CCblend = (a.x + a.y + a.z + a.w + 1.0)*0.5;
	CCblend = clamp(CCblend, 0.0, 1.0);
	return mix(b,c,CCblend);
}
	

vec2 CCrotate(vec2 pos, vec4 rotation)	
{
	float simpleSum = rotation.x + rotation.y + rotation.z + rotation.w;
	float angle = CCpi * simpleSum * 0.25;
	float sinAngle = sin(angle);
	float cosAngle = cos(angle);
	return
		vec2(
			cosAngle * pos.x - sinAngle * pos.y,
			sinAngle * pos.x + cosAngle * pos.y);
}


vec2 CCrotate(vec2 pos, float angle)	
{
	angle = CCpi * angle;
	float sinAngle = sin(angle);
	float cosAngle = cos(angle);
	return
		vec2(
			cosAngle * pos.x - sinAngle * pos.y,
			sinAngle * pos.x + cosAngle * pos.y);
}

vec2 CCpan(vec2 pos, vec4 col)
{
	return pos+col.xy;
}

vec2 rotateAndMove(vec2 pos, float angle)	
{
	angle = CCpi * angle;
	float sinAngle = sin(angle);
	float cosAngle = cos(angle);
	return
		vec2(
			cosAngle * pos.x - sinAngle * pos.y + angle*0.02,
			sinAngle * pos.x + cosAngle * pos.y + angle*0.02);
}

vec4 CCdecolorize(vec4 color, float amount)
{
	float bw = (color.x + color.y + color.z)*0.333;	
	return mix(color, vec4(bw), amount);
}

vec4 CCimageFunction(vec2 pos)
{		
	vec2 origPos = pos;
	
	pos = pos * (1.0 + sin(iTime*0.05+length(origPos))*0.15);

	pos = CCrotate(pos, sin(iTime*0.05));
	pos = pos * 0.8;
	vec2 p = CCarray(CCzoomout(pos));
	vec4 circles = -CCdist(p)+0.3;
	vec4 pattern = abs(CCtriangleWave(CCsimplex_color(CCrotate(pos+iTime*0.005, iTime*0.1))));	
	return CCminf(circles, pattern);
}

// functions end
// https://www.shadertoy.com/view/XdfGDn
void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
    vec2 pos = -1.0 + 2.0*uv;
    pos.x *= iResolution.x/ iResolution.y;	
	vec4 color = CCimageFunction(pos);
	color = (color+1.0)*0.5;
	color = CCror(color);	
	color.w=1.0;
	
  gl_FragColor = color;
}