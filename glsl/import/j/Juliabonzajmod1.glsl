// https://www.shadertoy.com/view/MsXGzr
void main(void)
{
   vec2 uv = iZoom * (gl_FragCoord.xy/iResolution.xy- 0.0);
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;

    vec2 cc = 1.1*vec2( 0.5*cos(0.1*iGlobalTime) - 0.25*cos(0.2*iGlobalTime), 
	                    0.5*sin(0.1*iGlobalTime) - 0.25*sin(0.2*iGlobalTime) );

	vec4 dmin = vec4(1000.0);
    vec2 z = (-1.0 + 1.0*uv)*vec2(0.6,0.3);
    for( int i=0; i<iSteps; i++ )
    {
        z = cc + vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y );
		z += 0.15*sin(float(i));
		dmin=min(dmin, vec4(abs(0.0+z.y + 0.2*sin(z.x)), 
							abs(1.0+z.x + 0.5*sin(z.y)), 
							dot(z,z),
						    length( fract(z)-0.2) ) );
    }
    
    vec3 color = vec3( dmin.w );
	color = mix( color, vec3(0.80,0.40,0.20),     min(1.0,pow(dmin.x*0.25,0.20)) );
    color = mix( color, vec3(0.12,0.70,0.60),     min(1.0,pow(dmin.y*0.50,0.50)) );
	color = mix( color, vec3(0.90,0.40,0.20), 1.0-min(1.0,pow(dmin.z*1.00,0.15) ));

	color = 1.25*color*color;
	
	color *= 0.5 + 0.5*pow(4.0*uv.x*(1.0-uv.y)*uv.y*(1.0-uv.y),0.15);

 gl_FragColor = vec4( color,1.0);
}
