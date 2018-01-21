// http://nvidia.fullviewmedia.com/gtc2014/S4550.html
// https://www.shadertoy.com/view/4slSR4

float map( in vec3 p )
{
	// add repetition
	vec3 q = mod( p + 2.0, 4.0) - 2.0;
	//sphere
	float d1;
	if (iRepeat==1)
	{
		d1 = length( q ) - 1.0;
	}
	else
	{
		// no repeat 
		d1 = length( p ) - 1.0;
	}
	
	// deform the sphere
	d1 += 0.1 * sin( 10.0 * p.x + iGlobalTime );
	//d1 += 0.1 * sin( 10.0 * p.x ) * sin( 10.0 * p.y + iGlobalTime ) * sin( 10.0 * p.z );

	// add a floor (plane)
	float d2 = p.y + 1.0;
	// no blending
	//return min( d1, d2 );	
	// blending
	float k = 0.20;
	float h = clamp( 0.5 + 0.5 * ( d1 - d2 ) / k, 0.0, 1.0 );
	return mix( d1, d2, h ) - k*h*(1.0-h);	
}
vec3 calcNormal( in vec3 pos )
{
    vec3 e = vec3(0.0001,0.0,0.0);
    vec3 nor;
	// compute gradient
    nor.x = map(pos+e.xyy) - map(pos-e.xyy);
    nor.y = map(pos+e.yxy) - map(pos-e.yxy);
    nor.z = map(pos+e.yyx) - map(pos-e.yyx);
    return normalize(nor);
}

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec2 p = -1.0 + 2.0 * uv;
	// fix aspect ratio
	p.x *= iResolution.x/iResolution.y;
	
	// ro is where the camera is, the ray comes from here
	vec3 ro = vec3( 0.0, 0.0, 2.0 );
	// rd is the ray direction, look down
	vec3 rd = normalize( vec3( p, - 1.0 ) );
	
	vec3 col = vec3( 0.0 );
	
	float tmax = 20.0;
	float h = 1.0;
	float t = 0.0;

	for( int i=0; i<iSteps; i++ )
	{
		if ( h < 0.0001 || t>tmax ) break;
		h = map( ro + t*rd );
		t += h;
	}
	vec3 lig = vec3( 0.5773 );
	if ( t < tmax )
	{
		// create position for normal
		vec3 pos = ro + t*rd;
		// normal
		vec3 nor = calcNormal( pos );
		// white : col = vec3( 1.0 );
		// light on x, y or z axis: col *= nor.y;

		col = iBackgroundColor * clamp( dot( nor, lig ), 0.0, 1.0 );
		// add blue ambient light from top nor.y
		col += iColor * clamp( nor.y, 0.0, 1.0 );
		// add constant lighting to fill the bottom of the sphere
		col += 0.1;
		// fog
		col *= exp( -0.1 * t );
	}
	gl_FragColor = vec4(col,1.0);
}
