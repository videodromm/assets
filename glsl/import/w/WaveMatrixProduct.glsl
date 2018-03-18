// https://www.shadertoy.com/view/4dfSRS
// Iain Melvin 2014

// comment these to get the basic effect:

void main(void)
{
	vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy;
    float a = 1.0;

    // reflect
	if (iBlendmode<2)
	{
		uv=abs(2.0*(uv-0.5));
	}
	// radial	
	if (iBlendmode<1)
	{
		float theta = 1.0*(1.0/(3.14159/2.0))*atan(uv.x,uv.y);
	    float r = length(uv);
		a=1.0-r;//vignette
	    uv = vec2(theta,r);	
	}   
		
	vec4 t1 = texture2D(iChannel0, vec2(uv[0],0.761) )-0.5;
    vec4 t2 = texture2D(iChannel0, vec2(uv[1],0.761) )-0.5;
   	float y = t1[0]*t2[0]*a*20.5;
	gl_FragColor = vec4( sin(y*3.141*2.5), sin(y*3.141*2.0),sin(y*3.141*1.0),1.0);
}
