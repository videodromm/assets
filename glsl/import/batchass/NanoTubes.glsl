// https://www.shadertoy.com/view/lslGRH
// With tweaks from fernlightning

float NanoRand(vec3 n) {
  n = floor(n);
  return fract(sin((n.x+n.y*1e2+n.z*1e4)*1e-4)*1e5);
}

// .x is distance, .y = colour
vec2 NanoMap( vec3 p ) {
	const float RADIUS = 0.25;

	// cylinder
	vec3 f = fract( p ) - 0.5;
	float d = length( f.xy );
        float cr = NanoRand( p );
	float cd = d - cr*RADIUS;

	// end - calc (NanoRand) radius at more stable pos
	p.z -= 0.5;
	float rr = NanoRand( p );
	float rn = d - rr*RADIUS;
    float rm = abs( fract( p.z ) - 0.5 );  // offset so at end of cylinder
       
	float rd = sqrt( rn*rn + rm*rm ); // end with ring

	return (cd < rd) ?  vec2( cd, cr ) : vec2( rd, rr ); // min
}
void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;

    uv.x = uv.x *2.-1.;
    uv.y = uv.y *2.-1.;

    vec3 camPos = vec3(cos(iGlobalTime*0.3), sin(iGlobalTime*0.3), 3.5);
    vec3 camTarget = vec3(0.0, 0.0, .0);

    vec3 camDir = normalize(camTarget-camPos);
    vec3 camUp  = normalize(vec3(0.0, 1.0, 0.0));
    vec3 camSide = cross(camDir, camUp);
    float focus = 1.8;

    //vec3 rayDir = normalize(camSide*pos.x + camUp*pos.y + camDir*focus);
    vec3 rayDir = normalize(camSide*uv.x + camUp*uv.y + camDir*focus);
    vec3 ray = camPos;
    float m = 0.32;
    vec2 d;
    float total_d = 0.;
    const int MAX_MARCH = 100;
    const float MAX_DISTANCE = 100.0;
    for(int i=0; i<MAX_MARCH; ++i) {
        d = NanoMap(ray-vec3(0.,0.,iGlobalTime/2.));
        total_d += d.x;
        ray += rayDir * d.x;
        m += 1.0;
        if(abs(d.x)<0.01) { break; }
        if(total_d>MAX_DISTANCE) { total_d=MAX_DISTANCE; break; }
    }

    float c = (total_d)*0.0001;
    vec3 result = vec3( 1.0-vec3(c, c, c) - vec3(0.025, 0.025, 0.02)*m*0.8 );

  gl_FragColor = vec4(result*d.y,1.0);
}
