//for audio input

//out vec4 fragColor;
void main(void)	
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy * iZoom;
	// flip horizontally
	if (iFlipH)
	{
		uv.x = 1.0 - uv.x;
	}
	// flip vertically
	if (iFlipV)
	{
		uv.y = 1.0 - uv.y;
	}
   	vec4 tex = texture2D(iChannel0, uv);
   	gl_FragColor = vec4(vec3( tex.r, tex.g, tex.b ),1.0);
}
