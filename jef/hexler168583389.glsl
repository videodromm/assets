uniform vec3  iResolution;  // viewport resolution (in pixels)
uniform vec3  iColor;
uniform float iGlobalTime;
uniform sampler2D	iChannel0;
uniform sampler2D	iChannel1;
uniform vec3 spectrum;

void main(void) {
	vec2 uv = abs(-1. + 2. * gl_FragCoord.xy / iResolution.xy);

	float radius = length(uv);
	float angle = atan(uv.y,uv.x);

    //uv.x += spectrum.y * 0.0000004 * tan(iGlobalTime + uv.y );
	//vec4 t0 = texture2D(iChannel0, uv);
	//vec4 t1 = texture2D(iChannel1, uv);
	
    float col = .0;
    col += 1.5*sin(iGlobalTime + 13.0 * angle + uv.y * 20);
    col += cos(.9 * uv.x * angle * 60.0 + radius * 5.0 -iGlobalTime * 2.);
	//col = 1.0 -col;
   	gl_FragColor = (1.2 - radius) * vec4(vec3( col ),1.0);
}
