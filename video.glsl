// texture1.frag for input texture 0
void main(void)	
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy * iZoom;
	// flip horizontally
	/*if (iFlipH)
	{
		uv.x = 1.0 - uv.x;
	}
	// flip vertically
	if (iFlipV)
	{
		uv.y = 1.0 - uv.y;
	}*/
   	vec4 tex = texture(iChannel0, uv);
   	fragColor = vec4(tex.r, tex.g, tex.b, 1.0);
}
