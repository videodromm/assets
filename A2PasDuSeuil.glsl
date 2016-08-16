//for audio input

// in shadertoy.inc out vec4 fragColor;
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
	float col = sin(uv.x*iGlobalTime);

   	vec4 tex = texture(iChannel0, uv);
   	fragColor = vec4(vec3( col ),1.0);
}
