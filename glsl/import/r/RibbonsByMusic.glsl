// https://www.shadertoy.com/view/lds3zr

//-----------------------------------------------------------------------------
// Utils
//-----------------------------------------------------------------------------
float RibbonsBMt = iTime*.5;

vec3 RibbonsBMRotateY(vec3 v, float x)
{
    return vec3(
        cos(x)*v.x - sin(x)*v.z,
        v.y,
        sin(x)*v.x + cos(x)*v.z
    );
}

vec3 RibbonsBMRotateX(vec3 v, float x)
{
    return vec3(
        v.x,
        v.y*cos(x) - v.z*sin(x),
        v.y*sin(x) + v.z*cos(x)
    );
}

vec3 RibbonsBMRotateZ(vec3 v, float x)
{
    return vec3(
        v.x*cos(x) - v.y*sin(x),
        v.x*sin(x) + v.y*cos(x),
        v.z
    );
}
//-----------------------------------------------------------------------------
// Scene/Objects
//-----------------------------------------------------------------------------
float RibbonsBMBox(vec3 p, vec3 pos, vec3 size)
{
	return max(max(abs(p.x-pos.x)-size.x,abs(p.y-pos.y)-size.y),abs(p.z-pos.z)-size.z);
}


float RibbonsBM1(vec3 p)
{
	return RibbonsBMBox(p,vec3(cos(p.z)*.5,sin(p.z+p.x)*.5,.0),vec3(.02,0.02,3.5+RibbonsBMt));
}
float RibbonsBM2(vec3 p)
{
	return RibbonsBMBox(p,vec3(cos(p.z+1.5+p.x)*.6,sin(p.z+1.)*.3,.0),vec3(.02,0.02,3.+RibbonsBMt));
}
float RibbonsBM3(vec3 p)
{
	return RibbonsBMBox(p,vec3(sin(p.z+p.y)*.4,cos(p.z+p.x)*.5,.0),vec3(.02,0.02,4.+RibbonsBMt));
}
float RibbonsBM4(vec3 p)
{
	return RibbonsBMBox(p,vec3(sin(p.z+1.5+p.x)*.5,cos(p.z+1.5)*.6,.0),vec3(.02,0.02,2.+RibbonsBMt));
}
float RibbonsBMScene(vec3 p)
{
	float d = .5-abs(p.y);
	d = min(d, RibbonsBM1(p) );
	d = min(d, RibbonsBM2(p) );
	d = min(d, RibbonsBM3(p) );
	d = min(d, RibbonsBM4(p) );
	
	return d;
}

//-----------------------------------------------------------------------------
// Raymarching tools
//-----------------------------------------------------------------------------
//RibbonsBMRaymarche by distance field
vec3 RibbonsBMRaymarche(vec3 org, vec3 dir, int step)
{
	float d=0.0;
	vec3 p=org;
	
	for(int i=0; i<iSteps; i++)
	{
		d = RibbonsBMScene(p);
		p += d * dir;
	}
	
	return p;
}
//get Normal
vec3 RibbonsBMGetN(vec3 p)
{
	vec3 eps = vec3(0.01,0.0,0.0);
	return normalize(vec3(
		RibbonsBMScene(p+eps.xyy)-RibbonsBMScene(p-eps.xyy),
		RibbonsBMScene(p+eps.yxy)-RibbonsBMScene(p-eps.yxy),
		RibbonsBMScene(p+eps.yyx)-RibbonsBMScene(p-eps.yyx)
	));
}

//Ambiant Occlusion
float RibbonsBMAO(vec3 p, vec3 n)
{
	float dlt = 0.1;
	float oc = 0.0, d = 1.0;
	for(int i = 0; i<6; i++)
	{
		oc += (float(i) * dlt - RibbonsBMScene(p + n * float(i) * dlt)) / d;
		d *= 2.0;
	}
	return clamp(1.0 - oc, 0.0, 1.0);
}

//-----------------------------------------------------------------------------
// Main Loops
//-----------------------------------------------------------------------------
void main()
{
	vec4 color = vec4(0.0);
	float bass = texture2D( iChannel0, vec2(20./256.,0.25) ).x*.75+texture2D( iChannel0, vec2(50./256.,0.25) ).x*.25;
	vec2 v = -1.0 + 2.0 * iZoom * gl_FragCoord.xy / iResolution.xy;
	v.x *= iResolution.x/iResolution.y;
	v.x -= iRenderXY.x;
	v.y -= iRenderXY.y;
	
	vec3 org = vec3(texture2D( iChannel0, vec2(1./256.,0.25) ).x*.2+1.,+0.3+bass*.05,RibbonsBMt+5.);
	vec3 dir = normalize(vec3(v.x,-v.y,2.));
	dir = RibbonsBMRotateX(dir,.15);
	dir = RibbonsBMRotateY(dir,2.8);
	
	
	vec3 p = RibbonsBMRaymarche(org,dir,48);
	vec3 n = RibbonsBMGetN(p);
	
	
    color = vec4( max( dot(n.xy*-1.,normalize(p.xy-vec2(.0,-.1))),.0)*.01 );
	color += vec4(1.0,0.3,0.0,1.0)/(RibbonsBM1(p-n*.01)*20.+.75)*pow(bass,2.)*3.;
	color += vec4(0.5,0.3,0.7,1.0)/(RibbonsBM2(p-n*.01)*20.+.75)*pow(texture2D( iChannel0, vec2(64./256.,0.25) ).x,2.)*2.;
	color += vec4(0.0,0.5,1.0,1.0)/(RibbonsBM3(p-n*.01)*20.+.75)*pow(texture2D( iChannel0, vec2(128./256.,0.25) ).x,2.)*5.;
	color += vec4(0.0,1.0,0.2,1.0)/(RibbonsBM4(p-n*.01)*20.+.75)*pow(texture2D( iChannel0, vec2(200./256.,0.25) ).x,2.)*5.;
	color *= RibbonsBMAO(p,n);
	color = mix(color,vec4(0.),vec4((min(distance(org,p)*.05,1.0))));
	
	
	gl_FragColor = color;

}