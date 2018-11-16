// https://www.shadertoy.com/view/XdsXDl
//------------------------------------------------------------------------
// Camera
//
// Move the camera. In this case it's using time and the mouse position
// to orbitate the camera around the origin of the world (0,0,0), where
// the yellow sphere is.
//------------------------------------------------------------------------
void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
    float an = 0.3*iTime;
	camPos = vec3(3.5*an,cos(5.*an),0.);
    
   // camPos = vec3(an/50., cos(an), 0.);
   // camPos = vec3(10., 0., 0.);
    camTar = camPos + vec3(0., 0.,-iTime);
}


//------------------------------------------------------------------------
// Background 
//
// The background color. In this case it's just a black color.
//------------------------------------------------------------------------
vec3 doBackground( void )
{
    return vec3(0.0, 0.0, 0.0);
}

//------------------------------------------------------------------------
// Modelling 
//
// Defines the shapes (a sphere in this case) through a distance field, in
// this case it's a sphere of radius 1.
//------------------------------------------------------------------------

float doSpheres(vec3 p, float r)
{
    vec3 q = mod(p, 2.0) - 1.0;
    return length(q) - r;
}
                
float doCrazyCube(vec3 pp)
{
    vec3 p = vec3( pp.x * cos(-iTime) + pp.y * sin(-iTime),
                    -pp.x * sin(-iTime) + pp.y * cos(-iTime),
                     pp.z);
                  
   // p = mod (p, vec3(0., 0., 4.)) - vec3(0., 0., 2.);
    
    float v = abs(p.x) - 1.0;
    if (abs(p.y) - 1.0 > v)
        v = abs(p.y) - 1.0;
    if (abs(p.z) - 0.5> v)
        v = abs(p.z) - 0.5;
    return v;
}
        
float doModel( vec3 p )
{
	return min(doSpheres(p, sin(p.x*1.2 + iTime + p.y)/2.0 + 0.5), doCrazyCube(p));
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
    vec3 objSpace = mod(pos, 2.0) - 1.0;
    
    float redVal = abs(objSpace.x);
    float greenVal = abs(objSpace.y);
    float blueVal = abs(objSpace.z);
    
    
    return vec3(redVal, greenVal, blueVal);
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
	    h = doModel( ro+rd*t);
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
    doCamera(ro, ta, iTime, m.x );

    // camera matrix
    mat3 camMat = calcLookAtMatrix( ro, ta, iTime/5.);  // 0.0 is the camera roll
    
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
