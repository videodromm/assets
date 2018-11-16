uniform vec3  iResolution;  // viewport resolution (in pixels)
uniform vec3  iColor;
uniform float iTime;
uniform sampler2D	iChannel0;
uniform sampler2D	iChannel1;
uniform vec3 spectrum;

void main(void) {
	vec2 uv = abs(-1. + 2. * gl_FragCoord.xy / iResolution.xy);
	uv += sin(spectrum.x*10.0+iTime);
	uv.x = abs(uv.x - spectrum.x * 2.0);
	float radius = length(uv);
	float angle = atan(uv.y,uv.x);
	
    float col = .0;
    col += abs(1.5/ uv.x) * spectrum.x * .3;
    col += sin( uv.y * 10. * spectrum.y * angle * spectrum.z * 100.);
    col += 0.3 * cos(.3 * uv.y * spectrum.x * radius * 120.);
	//col = 1.0 -col;
   	gl_FragColor = (1.2 - radius) * vec4(vec3( col ),1.0);
}
