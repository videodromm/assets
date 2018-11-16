// https://www.shadertoy.com/view/4slSRj
void main(void)
{
	float d = pow(dot( gl_FragCoord.xy, iResolution.xy ), 0.52);

	 d =  d * 0.5;
	
	float x = sin(6.0+0.1*d + iTime*-6.0) * 10.0;
	
	gl_FragColor = vec4( x, x, x, 1 );
}

