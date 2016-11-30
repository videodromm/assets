void main() {
	vec2 uv = 2 * (gl_FragCoord.xy / iResolution.xy - vec2(0.5));

	float radius = length(uv);
	float angle = atan(uv.y,uv.x);
	
    float col = .0;
    col += 1.5*sin(iGlobalTime + 13.0 * angle + uv.y * 20);
    col += cos(.9 * uv.x * angle * 60.0 + radius * 5.0 -iGlobalTime * 2.);
	//col = 1.0 -col;
   	fragColor = (1.2 - radius) * vec4(vec3( col ),1.0);
}
