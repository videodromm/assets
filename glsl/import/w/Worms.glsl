// https://www.shadertoy.com/view/XsjXR1
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const float maxdist = 32.0;

float hash( vec2 p )
{
	float h = 1.0+dot(p,vec2(127.1,311.7));
    return fract(sin(h)*43758.5453123);
}

vec2 sincos( float x )
{
    return vec2( sin(x), cos(x) );
}

vec2 sdSegment( vec3 p, in vec3 a, in vec3 b )
{
    vec3 pa = p - a;
	vec3 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return vec2( length( pa - ba*h ), h );
}

vec3 opU( vec3 d1, vec3 d2 ){ return (d1.x<d2.x) ? d1 : d2;}

vec3 map( vec3 p )
{
    vec2 id = floor( (p.xz+1.0)/2.0);
    p.xz = mod( p.xz+1.0, 2.0 ) - 1.0;
    
    float ph = hash(id+113.1);
    float ve = hash(id);
    ve *= 2.0;
    
    p += 0.5*vec3(sin(ve*iTime+(p.y+ph)*0.53), 0.0, 
                  cos(ve*iTime+(p.y+ph)*0.32) );

    vec3 p1 = p; p1.xz += 0.15*sincos(p.y-ve*iTime*ve+0.0);
    vec3 p2 = p; p2.xz += 0.15*sincos(p.y-ve*iTime*ve+2.0);
    vec3 p3 = p; p3.xz += 0.15*sincos(p.y-ve*iTime*ve+4.0);
    
    vec2 h1 = sdSegment(p1, vec3(0.0,-50.0, 0.0), vec3(0.0, 50.0, 0.0) );
    vec2 h2 = sdSegment(p2, vec3(0.0,-50.0, 0.0), vec3(0.0, 50.0, 0.0) );
    vec2 h3 = sdSegment(p3, vec3(0.0,-50.0, 0.0), vec3(0.0, 50.0, 0.0) );
    
    return opU( opU( vec3(h1.x-0.15*(0.8+0.2*sin(200.0*h1.y)), 0.0, h1.y), 
                     vec3(h2.x-0.15*(0.8+0.2*sin(200.0*h2.y)), 1.0, h2.y) ), 
                     vec3(h3.x-0.15*(0.8+0.2*sin(200.0*h3.y)), 2.0, h3.y) );
}

vec3 intersect( in vec3 ro, in vec3 rd )
{
    vec3 res = vec3(-1.0);
	const float precis = 0.001;
    float t = 0.0;
    for( int i=0; i<iSteps; i++ )
    {
	    vec3 h = map(ro + t*rd);
        res = vec3( t, h.yz );
        if( h.x<precis || t>maxdist ) break;
        h.x = min( h.x, 0.5 );
        t += h.x*0.5;
    }
	return res;
}

//-------------------------------------------------------

vec3 calcNormal( in vec3 pos )
{
    const float eps = 0.005;

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*map( pos + v1*eps ).x + 
					  v2*map( pos + v2*eps ).x + 
					  v3*map( pos + v3*eps ).x + 
					  v4*map( pos + v4*eps ).x );
}

float calcOcc( in vec3 pos, in vec3 nor )
{
    const float h = 0.1;
	float ao = 0.0;
    for( int i=0; i<4; i++ )
    {
        
        vec3 dir = sin( float(i)*vec3(1.0,7.13,13.71)+vec3(0.0,2.0,4.0) );
        dir *= sign( dot(dir,nor) );
            
        float d = map( pos + h*dir ).x;
        ao += (h-d);
    }
    return clamp( 1.0 - 0.7*ao, 0.0, 1.0 );
}

//-------------------------------------------------------

void main( void )
{	
	vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy-0.5);
	uv.x *= float(iResolution.x )/ float(iResolution.y);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;

	vec2 p = uv;//(-iResolution.xy+2.0*gl_FragCoord.xy)/iResolution.y;
    
	vec3 ro = 0.6*vec3(1.0,4.0,2.0);
	vec3 ta = 0.5*vec3(0.0,0.0,0.0);
    
    vec3 ww = normalize( ta - ro);
    vec3 uu = normalize( cross( vec3(0.0,1.0,0.0), ww ) );
    vec3 vv = normalize( cross(ww,uu) );
    vec3 rd = normalize( p.x*uu + p.y*vv + 3.0*ww );
	
    vec3 col = vec3(0.0);
    
    vec3 res = intersect(ro,rd);
	float t = res.x;
    if( t < maxdist )
    {
        
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );

        float occ = calcOcc( pos, nor );

        vec2  id = floor( (pos.xz+1.0)/2.0);
        float fid = hash( id );
        float ve = hash(id);
        
        col = 0.5 + 0.5*cos( res.y*0.4 + fid*30.0 + vec3(0.0,4.4,4.0) );
        col *= 0.5 + 1.5*nor.y;
        col += 1.0*clamp(1.0+dot(rd,nor),0.0,1.0);
        col *= 0.2 + 0.8*texture2D( iChannel0, vec2( 50.0*res.z - 1.0*ve*iTime,0.5) ).xyz;
        col *= 2.0;
        col *= occ;

        float fl = mod( ve*1.0*iTime + fid*7.0 + res.y*13.0, 4.0 )/4.0;
        float gl = 1.0-smoothstep(0.02,0.04,abs(res.z-fl));
        col *= 1.0 + 1.5*gl;
        
        col *= exp( -0.1*t );
    }
    
    col = pow( col, vec3(0.5,1.5-iColor.g,1.5-iColor.b) );
    
    vec2 q = iZoom * gl_FragCoord.xy/iResolution.xy;//gl_FragCoord.xy/iResolution.xy;
    col *= pow(16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.1);
    
	gl_FragColor = vec4( col, 1.0 );
}

