//for texture

// in shadertoy.inc out vec4 fragColor;
void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
   	vec4 tex = texture(iChannel1, uv);
   	fragColor = vec4(vec3( tex.r, tex.g, tex.b ),1.0);
}