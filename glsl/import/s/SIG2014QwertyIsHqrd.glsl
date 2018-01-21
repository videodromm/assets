// https://www.shadertoy.com/view/4dsSDl
float myNoise(vec2 p)
{
	float f = texture2D(iChannel0,p * .1).x*.7;
	f += texture2D(iChannel0,(p + vec2(.2635 * iGlobalTime *.25 ,.4579 * iGlobalTime * .25)) * .2).y * .5;
	f += texture2D(iChannel0,(p - vec2(.2364 * iGlobalTime *.225,.7891 * iGlobalTime *.225)) * .4).x * .25;
	f += texture2D(iChannel0,(p + vec2(.9484 * iGlobalTime *.111,.3591 * iGlobalTime *.014)) * .6).z * .225;
	return f;
}
//------------------------------------------------------------------------
// Camera
//
// Move the camera. In this case it's using time and the mouse position
// to orbitate the camera around the origin of the world (0,0,0), where
// the yellow sphere is.
//------------------------------------------------------------------------
void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
    float an = 0.*iGlobalTime + 10.0*mouseX;
	camPos = vec3(3.5*sin(an),1.0,3.5*cos(an));
    camTar = vec3(0.0,0.0,0.0);
}


//------------------------------------------------------------------------
// Background 
//
// The background color. In this case it's just a black color.
//------------------------------------------------------------------------
vec3 doBackground( void )
{
    
	vec2 uv = gl_FragCoord.xy / iResolution.xy ;
	
	float sp2 = texture2D( iChannel1, vec2( 0.75, 0.0 ) ).r;
	
	uv += vec2(myNoise(uv )*.225);
    return vec3( step(myNoise(uv),min(max(.5 / .5 + sin(sp2* 3.14)*.25,.2),.85))* 0.01 );
}
    
//------------------------------------------------------------------------
// Modelling 
//
// Defines the shapes (a sphere in this case) through a distance field, in
// this case it's a sphere of radius 1.
//------------------------------------------------------------------------
float doModel( vec3 p )
{
    vec3 c = vec3(3.);
    p.x += sin(p.z*.1);p.y += cos(p.z*.1);
    p = mod(p,c)-0.5*c;
    
	vec2 uv = gl_FragCoord.xy / iResolution.xy ;
    
    float sp2 = texture2D( iChannel1, vec2( 0.025, 0.0 ) ).r;
    float time = iGlobalTime + p.z;
    vec3 a = vec3((sin(time + (uv.y+sp2) * 5.)-.5)*.25,(cos(time + (uv.x+sp2) *3.)-.5)*.25,myNoise(uv)-.5) ;
    vec3 b = vec3(0.);
    float r = .5 ;
    vec3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

//------------------------------------------------------------------------
// Material 
//
// Defines the material (colors, shading, pattern, texturing) of the model
// at every point based on its position and normal. In this case, it simply
// returns a constant yellow color.
//------------------------------------------------------------------------
vec3 doMaterial( in vec3 pos, in vec3 nor )
{
    
    return vec3(myNoise(vec2(dot(pos,nor))),0.07,0.01);
}

//------------------------------------------------------------------------
// Lighting
//------------------------------------------------------------------------
float calcSoftshadow( in vec3 ro, in vec3 rd );

vec3 doLighting( in vec3 pos, in vec3 nor, in vec3 rd, in float dis, in vec3 mal )
{
    vec3 lin = vec3(0.0);

    // key light
    //-----------------------------
    vec3  lig = normalize(vec3(1.0,0.7,0.9));
    float dif = max(dot(nor,lig),0.0);
    float sha = 0.0; if( dif>0.01 ) sha=calcSoftshadow( pos+0.01*nor, lig );
    lin += dif*vec3(4.00,4.00,4.00)*sha;

    // ambient light
    //-----------------------------
    lin += vec3(0.50,0.50,0.50);

    
    // surface-light interacion
    //-----------------------------
    vec3 col = mal*lin;

    
    // fog    
    //-----------------------------
	col *= exp(-0.01*dis*dis);

    return col;
}

float calcIntersection( in vec3 ro, in vec3 rd )
{
	const float maxd = 20.0;           // max trace distance
	const float precis = 0.001;        // precission of the intersection
    float h = precis*2.0;
    float t = 0.0;
	float res = -1.0;
    for( int i=0; i<90; i++ )          // max number of raymarching iterations is 90
    {
        if( h<precis||t>maxd ) break;
	    h = doModel( ro+rd*t );
        t += h;
    }

    if( t<maxd ) res = t;
    return res;
}

vec3 calcNormal( in vec3 pos )
{
    const float eps = 0.002;             // precision of the normal computation

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*doModel( pos + v1*eps ) + 
					  v2*doModel( pos + v2*eps ) + 
					  v3*doModel( pos + v3*eps ) + 
					  v4*doModel( pos + v4*eps ) );
}

float calcSoftshadow( in vec3 ro, in vec3 rd )
{
    float res = 1.0;
    float t = 0.0005;                 // selfintersection avoidance distance
	float h = 1.0;
    for( int i=0; i<40; i++ )         // 40 is the max numnber of raymarching steps
    {
        h = doModel(ro + rd*t);
        res = min( res, 64.0*h/t );   // 64 is the hardness of the shadows
		t += clamp( h, 0.02, 2.0 );   // limit the max and min stepping distances
    }
    return clamp(res,0.0,1.0);
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

void main( void )
{
	vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
	uv.x *= float(iResolution.x )/ float(iResolution.y);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;

    vec2 m = iMouse.xy/iResolution.xy;

    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
    
    // camera movement
    vec3 ro, ta;
    doCamera( ro, ta, iGlobalTime, m.x );

    // camera matrix
    mat3 camMat = calcLookAtMatrix( ro, ta, 0.0 );  // 0.0 is the camera roll
    
	// create view ray
	vec3 rd = normalize( camMat * vec3(uv.xy,2.0) ); // 2.0 is the lens length

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------

	vec3 col = doBackground();

	// raymarch
    float t = calcIntersection( ro, rd );
    if( t>-0.5 )
    {
        // geometry
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal(pos);

        // materials
        vec3 mal = doMaterial( pos, nor );

        col = doLighting( pos, nor, rd, t, mal );
	}

	//-----------------------------------------------------
	// postprocessing
    //-----------------------------------------------------
    // gamma
	col = pow( clamp(col,0.0,1.0), vec3(0.4545) );
	   
    gl_FragColor = vec4( col, 1.0 );
}
