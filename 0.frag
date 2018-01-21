/* 0.frag */


void main(void)	
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
   	vec4 tex = texture(iChannel0, uv);
   	fragColor = vec4(tex.r, tex.g, tex.b, 1.0);
}

