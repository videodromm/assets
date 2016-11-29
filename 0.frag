/* 0.frag */
out vec4 fragColor;
uniform sampler2D iChannel0;
uniform vec3 iResolution;

void main(void)	
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
   	vec4 tex = texture2D(iChannel0, uv);
   	fragColor = vec4(tex.r, tex.g, tex.b, 1.0);
}

