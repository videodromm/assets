uniform vec3  iResolution;  // viewport resolution (in pixels)
uniform vec3  iColor;
uniform float iTime;
uniform sampler2D	iChannel0;
uniform sampler2D	iChannel1;
uniform vec3 spectrum;

void main(void) {
	vec2 uv = -1. + 2. * gl_FragCoord.xy / iResolution.xy;

	
	uv.x += 0.3*sin(iTime);
	uv.y += 1.0 *cos(iTime);

	float radius = length(uv);
	float angle = atan(uv.y,uv.x);

    uv.x += spectrum.y * 0.0000004 * tan(iTime + uv.y );
	vec4 t0 = texture2D(iChannel0, uv);
	vec4 t1 = texture2D(iChannel1, uv);
	
    float col = abs(sin(radius + angle*10 +iTime+uv.y*26));
	col = 1.0 -col;
   	gl_FragColor = vec4(vec3( col ),1.0);
}
