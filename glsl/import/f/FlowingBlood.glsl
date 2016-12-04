// https://www.shadertoy.com/view/4sfSRn
vec4 fBm(vec2 p) {
	return texture2D(iChannel0, p)*0.5 + texture2D(iChannel0, p*vec2(2.0))*0.25 + texture2D(iChannel0, p*vec2(4.0))*0.125 + texture2D(iChannel0, p*vec2(8.0))*0.0625;
}


void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	gl_FragColor = fBm((uv.xy*vec2(0.5)*uv.x) + vec2(iGlobalTime*0.01, 0.0)) + vec4(0.53, 0.02, 0.02, 0.0);

}

	