// https://www.shadertoy.com/view/ldlXRS
//Noise animation - Electric
//by nimitz (stormoid.com) (twitter: @stormoid)

//The domain is displaced by two fbm calls one for each axis.
//Turbulent fbm (aka ridged) is used for better effect.

#define time iGlobalTime*0.15
#define tau 6.2831853

mat2 makem2(in float theta){float c = cos(theta);float s = sin(theta);return mat2(c,-s,s,c);}
float noise( in vec2 x ){return texture2D(iChannel0, x*.01).x;}

mat2 m2 = mat2( 0.80,  0.60, -0.60,  0.80 );
float fbm( in vec2 p )
{	
	float z=2.;
	float rz = 0.;
	vec2 bp = p;
	for (float i= 1.;i < 6.;i++ )
	{
		rz+= abs((noise(p)-0.5)*2.)/z;
		z = z*2.;
		p = p*2.;
	}
	return rz;
}

float circ(vec2 p) 
{
	float r = length(p);
	r = log(sqrt(r));
	return abs(mod(r*4.,tau)-3.14)*3.+.2;

}

void main(void)
{
	//setup system
	vec2 uv = iZoom * (gl_FragCoord.xy / iResolution.xy-0.5);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
	uv.x *= iResolution.x/iResolution.y;
	uv*=4.;
	
	//get two rotated fbm calls and displace the domain
	vec2 p2 = uv*.7;
	vec2 basis = vec2(fbm(p2-time*1.6),fbm(p2+time*1.7));
	basis = (basis-.5)*.2;
	uv += basis;
	
	//coloring
	float rz = fbm(uv*makem2(time*0.2));
	
	//rings
	uv /= exp(mod(time*10.,3.14159));
	rz *= pow(abs((0.1-circ(uv))),.9);
	
	//final color
	vec3 col = vec3(.2,0.1,0.4)/rz;
	col=pow(abs(col),vec3(.99));
	gl_FragColor = vec4(col,1.);
}
