// functions begin
// https://www.shadertoy.com/view/MdB3Dw
// intersect a MOVING sphere
vec2 AM3DiSphere( in vec3 ro, in vec3 rd, in vec4 sp, in vec3 ve, out vec3 nor )
{
    float t = -1.0;
	float s = 0.0;
	nor = vec3(0.0);
	
	vec3  rc = ro - sp.xyz;
	float A = dot(rc,rd);
	float B = dot(rc,rc) - sp.w*sp.w;
	float C = dot(ve,ve);
	float D = dot(rc,ve);
	float E = dot(rd,ve);
	float aab = A*A - B;
	float eec = E*E - C;
	float aed = A*E - D;
	float k = aed*aed - eec*aab;
		
	if( k>0.0 )
	{
		k = sqrt(k);
		float hb = (aed - k)/eec;
		float ha = (aed + k)/eec;
		
		float ta = max( 0.0, ha );
		float tb = min( 1.0, hb );
		
		if( ta < tb )
		{
            ta = 0.5*(ta+tb);			
            t = -(A-E*ta) - sqrt( (A-E*ta)*(A-E*ta) - (B+C*ta*ta-2.0*D*ta) );
            nor = normalize( (ro+rd*t) - (sp.xyz+ta*ve ) );
            s = 2.0*(tb - ta);
		}
	}

	return vec2(t,s);
}

// intersect a STATIC sphere
float AM3DiSphere( in vec3 ro, in vec3 rd, in vec4 sp, out vec3 nor )
{
    float t = -1.0;
	nor = vec3(0.0);
	
	vec3  rc = ro - sp.xyz;
	float b =  dot(rc,rd);
	float c =  dot(rc,rc) - sp.w*sp.w;
	float k = b*b - c;
	if( k>0.0 )
	{
		t = -b - sqrt(k);
		nor = normalize( (ro+rd*t) - sp.xyz );
	}

	return t;
}

vec3 AM3DGetPos( float time ) { return vec3(     2.5*sin(8.0*time), 0.0,      1.0*cos(8.0*time) ); }
vec3 AM3DGetVelocity( float time ) { return vec3( 8.0*2.5*cos(8.0*time), 0.0, -8.0*1.0*sin(8.0*time) ); }

// functions end
// https://www.shadertoy.com/view/MdB3Dw
void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy;

	vec2 p = -1.0 + 2.0 * uv;
	p.x *= iResolution.x/iResolution.y;	
	p.x -= iRenderXY.x;
	p.y -= iRenderXY.y;

	// camera
	vec3  ro = vec3(0.0,0.0,4.0);
    vec3  rd = normalize( vec3(p.xy,-iZoom) );
	
    // sphere	
	
	// render
	vec3  col = vec3(0.0);

    //---------------------------------------------------	
    // render with analytical motion blur
    //---------------------------------------------------	
	vec3  ce = AM3DGetPos( iTime );
	vec3  ve = AM3DGetVelocity( iTime );
    	
	col = vec3(0.25) + 0.3*rd.y;
	vec3 nor = vec3(0.0);
	vec3 tot = vec3(0.25) + 0.3*rd.y;
    vec2 res = AM3DiSphere( ro, rd, vec4(ce,1.0), ve/24.0, nor );
	float t = res.x;
	if( t>0.0 )
	{
		float dif = clamp( dot(nor,vec3(0.5703)), 0.0, 1.0 );
		float amb = 0.5 + 0.5*nor.y;
		//vec3  lcol = dif*vec3(1.0,0.9,0.3) + amb*vec3(0.1,0.2,0.3);
		vec3  lcol = dif*iBackgroundColor + amb*iColor;
		col = mix( tot, lcol, res.y );
	}
	
	
	col = pow( clamp(col,0.0,1.0), vec3(0.45) );

   gl_FragColor = vec4(col,1.0);
}
