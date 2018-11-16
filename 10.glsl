#define COLOR vec4(0.0,0.737,0.6,1.0);
void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	// aspect-ratio correction
   	uv.x*=iResolution.x/iResolution.y;

    vec4 noise = texture(iChannel1,uv + iTime / 10.0);   
    vec4 col = texture(iChannel0,uv + noise.xy * 0.01);
   	gl_FragColor = col * 1.5 * COLOR;
}
