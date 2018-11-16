uniform vec3      	iResolution; 			// viewport resolution (in pixels)
uniform float     	iTime; 			// shader playback time (in seconds)
uniform vec4      	iMouse; 				// mouse pixel coords. xy: current (if MLB down), zw: click
uniform sampler2D 	iChannel0; 				// input channel 0

out vec4 fragColor;
vec2  fragCoord = gl_FragCoord.xy; // keep the 2 spaces between vec2 and fragCoord
void main() {
	vec2 uv = 2 * (gl_FragCoord.xy / iResolution.xy - vec2(0.5));

	float radius = length(uv);
	float angle = atan(uv.y,uv.x);
	
    float col = .0;
    col += 1.5*sin(iTime + 13.0 * angle + uv.y * 20);
    col += cos(.9 * uv.x * angle * 60.0 + radius * 5.0 -iTime * 2.);
	//col = 1.0 -col;
   	fragColor = (1.2 - radius) * vec4(vec3( col ),1.0);
}
