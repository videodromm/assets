
void main() {
  	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec4 tex = texture(iChannel0, uv);
	 
	fragColor = vec4(tex.r, 0.3, tex.b, 1.0) ;
}
