// glsl.heroku.come#12869.0

#define POINTS 10.0
#define RADIUS 100.0
#define BRIGHTNESS 0.95
#define COLOR vec3(0.7, 0.9, 1.2)
#define SMOOTHNESS 2.5

#define LAG_A 2.325
#define LAG_B 3.825
#define LAG_C 8.825

vec2 getPoint(float n) {
	float t = iGlobalTime * 0.1;
	//vec2 center = iResolution.xy / 2.0;
	vec2 center = gl_FragCoord.xy / 2.0;
	vec2 p = (
		  vec2(100.0, 0.0) * sin(t *  2.5 + n * LAG_A)
		+ vec2(0.0, 100.0) * sin(t * -1.5 + n * LAG_B)
		+ vec2(20.0, 50.0) * cos(t * 0.05 + n * LAG_C)
		+ vec2(50.0, 10.0) * sin(t * 0.15 + n)
	);
	return center + p;
}

void main() {
	/*vec2 position = iZoom * gl_FragCoord.xy;
	position.x -= iRenderXY.x;
	position.y -= iRenderXY.y;*/
	vec2 uv = iZoom * gl_FragCoord.xy;
	//vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy - 0.5);
	uv.x *= float(iResolution.x )/ float(iResolution.y);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
	float b = 0.0;
	
	for (float i = 0.0; i < POINTS; i += 1.0) {
		vec2 p = getPoint(i);
		float d = 1.0 - clamp(distance(p, uv) / RADIUS, 0.0, 1.0);
		b += pow(d, SMOOTHNESS);
	}
	
	vec3 c = b + (
		  (sin(b * 30.0) - 1.0) * vec3(0.1, 0.4, 0.15)
		+ (cos(b * 10.0) + 1.0) * vec3(0.8, 0.5, 0.25)
	);
	
	gl_FragColor = vec4(c * BRIGHTNESS * COLOR, 1.0);
}


