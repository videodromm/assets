// https://www.shadertoy.com/view/ldj3Wh
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Intersecting quadratic Bezier segments in 3D. Used Microsoft's paper as pointed out 
// by tayholliday in https://www.shadertoy.com/view/XsX3zf. Since 3D quadratic Bezier 
// segments are planar, the 2D version can be used to compute the distance to 3D curves.
	
//-----------------------------------------------------------------------------------

float QuadraticBezier3DHash1( float n ) { return fract(sin(n)*43758.5453123); }
vec3  QuadraticBezier3DHash3( float n ) { return fract(sin(vec3(n,n+17.3,n+23.7))*43758.5453123); }

vec3 QuadraticBezier3DNoise3( in float x )
{
    float p = floor(x);
    float f = fract(x);
    f = f*f*(3.0-2.0*f);
    return mix( QuadraticBezier3DHash3(p+0.0), QuadraticBezier3DHash3(p+1.0), f );
}
float QuadraticBezier3DDet( vec2 a, vec2 b ) { return a.x*b.y-b.x*a.y; }
vec3 QuadraticBezier3DGetClosest( vec2 b0, vec2 b1, vec2 b2 ) 
{
	
  float a =     QuadraticBezier3DDet(b0,b2);
  float b = 2.0*QuadraticBezier3DDet(b1,b0);
  float d = 2.0*QuadraticBezier3DDet(b2,b1);
  float f = b*d - a*a;
  vec2  d21 = b2-b1;
  vec2  d10 = b1-b0;
  vec2  d20 = b2-b0;
  vec2  gf = 2.0*(b*d21+d*d10+a*d20); gf = vec2(gf.y,-gf.x);
  vec2  pp = -f*gf/dot(gf,gf);
  vec2  d0p = b0-pp;
  float ap = QuadraticBezier3DDet(d0p,d20);
  float bp = 2.0*QuadraticBezier3DDet(d10,d0p);
  float t = clamp( (ap+bp)/(2.0*a+b+d), 0.0 ,1.0 );
  return vec3( mix(mix(b0,b1,t), mix(b1,b2,t),t), t );
}

vec2 QuadraticBezier3DSdBezier( vec3 a, vec3 b, vec3 c, vec3 p )
{
	vec3 w = normalize( cross( c-b, a-b ) );
	vec3 u = normalize( c-b );
	vec3 v = normalize( cross( w, u ) );

	vec2 a2 = vec2( dot(a-b,u), dot(a-b,v) );
	vec2 b2 = vec2( 0.0 );
	vec2 c2 = vec2( dot(c-b,u), dot(c-b,v) );
	vec3 p3 = vec3( dot(p-b,u), dot(p-b,v), dot(p-b,w) );

	vec3 cp = QuadraticBezier3DGetClosest( a2-p3.xy, b2-p3.xy, c2-p3.xy );

	return vec2( sqrt(dot(cp.xy,cp.xy)+p3.z*p3.z), cp.z );
}
vec3 QuadraticBezier3DMap( in vec3 p )
{
    vec3 res = vec3( p.y+1.0, 0.025*length(p.xz)*1.0 + 0.01*atan(p.z,p.x), 0.0 );
		
	//vec3 tmp = vec3( sdMonster( p ), 1.0 );

	//if( tmp.x<res.x ) res=tmp;

	return res;
}

vec3 QuadraticBezier3DIntersect( in vec3 ro, in vec3 rd )
{
	const float maxd = 20.0;
	const float precis = 0.001;
    float h = precis*3.0;
    float t = 0.0;
    float m = 0.0;
	float l = 0.0;
    for( int i=0; i<iSteps; i++ )
    {
        if( h>precis && t<maxd )
		{
        t += 0.5*h;
	    vec3 res = QuadraticBezier3DMap( ro+rd*t );
        h = res.x;
		l = res.y;
        m = res.z;			
		}
    }

    if( t>maxd ) m=-1.0;
    return vec3( t, l, m );
}

vec3 QuadraticBezier3DCalcNormal( in vec3 pos )
{
    vec3 eps = vec3(0.002,0.0,0.0);

	return normalize( vec3(
           QuadraticBezier3DMap(pos+eps.xyy).x - QuadraticBezier3DMap(pos-eps.xyy).x,
           QuadraticBezier3DMap(pos+eps.yxy).x - QuadraticBezier3DMap(pos-eps.yxy).x,
           QuadraticBezier3DMap(pos+eps.yyx).x - QuadraticBezier3DMap(pos-eps.yyx).x ) );
}

float QuadraticBezier3DSoftShadow( in vec3 ro, in vec3 rd, float mint, float k )
{
    float res = 1.0;
    float t = mint;
	float h = 1.0;
    for( int i=0; i<iSteps; i++ )
    {
        h = QuadraticBezier3DMap(ro + rd*t).x;
        res = min( res, k*h/t );
		t += clamp( h, 0.02, 2.0 );
    }
    return clamp(res,0.0,1.0);
}

float QuadraticBezier3DCalcAO( in vec3 pos, in vec3 nor )
{
    float totao = 0.0;
    for( int aoi=0; aoi<8; aoi++ )
    {
        float hr = 0.01 + 0.013*float(aoi*aoi);
        vec3 aopos =  nor * hr + pos;
        float dd = QuadraticBezier3DMap( aopos ).x;
        totao += -(dd-hr);
    }
    return 1.0 - clamp( totao*0.75, 0.0, 1.0 );
}


vec3 QuadraticBezier3DLig = normalize(vec3(-0.2,0.6,0.9));

void main( void )
{
	vec2 q = gl_FragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = vec2(0.5);
	if( iMouse.z>0.0 ) m = iMouse.xy/iResolution.xy;


    //-----------------------------------------------------
    // animate
    //-----------------------------------------------------
	
	float ctime = iGlobalTime;

	
    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------

	float an = 2.0 + 0.3*ctime - 12.0*(m.x-0.5);

	vec3 ro = vec3(7.0*sin(an),0.0,7.0*cos(an));
    vec3 ta = vec3(0.0,1.0,0.0);

    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));

	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + 2.5*ww );

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------

	//vec3 col = clamp( vec3(0.95,0.95,1.0) - 0.75*rd.y, 0.0, 1.0 );
	vec3 col = clamp( iBackgroundColor - 0.75*rd.y, 0.0, 1.0 );
	float sun = pow( clamp( dot(rd,QuadraticBezier3DLig), 0.0, 1.0 ), 8.0 );
	col += 0.7*vec3(1.0,0.9,0.8)*pow(sun,4.0);
	vec3 bcol = col;
	
	// raymarch
    vec3 tmat = QuadraticBezier3DIntersect(ro,rd);
    if( tmat.z>-0.5 )
    {
        // geometry
        vec3 pos = ro + tmat.x*rd;
        vec3 nor = QuadraticBezier3DCalcNormal(pos);
		vec3 ref = reflect( rd, nor );

        // materials
		vec3 mate = vec3(0.5);
		mate *= smoothstep( -0.75, 0.75, cos( 200.0*tmat.y ) );
		
		float occ = QuadraticBezier3DCalcAO( pos, nor );
		
		// lighting
        float sky = clamp(nor.y,0.0,1.0);
		float bou = clamp(-nor.y,0.0,1.0);
		float dif = max(dot(nor,QuadraticBezier3DLig),0.0);
        float bac = max(0.3 + 0.7*dot(nor,-QuadraticBezier3DLig),0.0);
		float sha = 0.0; if( dif>0.001 ) sha=QuadraticBezier3DSoftShadow( pos+0.01*nor, QuadraticBezier3DLig, 0.0005, 32.0 );
        float fre = pow( clamp( 1.0 + dot(nor,rd), 0.0, 1.0 ), 5.0 );
        float spe = max( 0.0, pow( clamp( dot(QuadraticBezier3DLig,reflect(rd,nor)), 0.0, 1.0), 8.0 ) );
		
		// lights
		vec3 brdf = vec3(0.0);
		brdf += 2.0*dif*vec3(1.20,1.0,0.60)*sha;
		brdf += 1.0*sky*vec3(0.10,0.15,0.35)*occ;
		brdf += 1.0*bou*vec3(0.30,0.30,0.30)*occ;
		brdf += 1.0*bac*vec3(0.30,0.25,0.20)*occ;
        brdf += 1.0*fre*vec3(1.00,1.00,1.00)*occ;
		//brdf += 1.0*spe*vec3(1.0)*sha*8.0*(0.2+0.8*fre)*occ;
		
		// surface-light interacion
		col = mate.xyz* brdf;
		//col += (1.0-mate.xyz)*1.0*spe*vec3(1.0,0.95,0.9)*sha*2.0*(0.2+0.8*fre)*occ;	
		col += (1.0-mate.xyz)*1.0*spe*iColor*sha*2.0*(0.2+0.8*fre)*occ;
		col = mix( col, bcol, smoothstep(10.0,20.0,tmat.x) );

	}

	col += 0.4*vec3(1.0,0.8,0.7)*sun;

	
	//-----------------------------------------------------
	// postprocessing
    //-----------------------------------------------------
    // gamma
	col = pow( clamp(col,0.0,1.0), vec3(0.45) );

	gl_FragColor = vec4( col, 1.0 );
}
