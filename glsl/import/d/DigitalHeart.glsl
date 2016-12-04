// https://www.shadertoy.com/view/Mds3Wn
float DigitalHeartNoise(float t) {
	return fract(sin(t)*4397.33);
}

vec3 DigitalHeartRotate(vec3 p) {
	float angle = iGlobalTime / 3.;
	return vec3(p.x*cos(angle) + p.z*sin(angle), p.y, p.x*sin(angle) - p.z*cos(angle));
}

float DigitalHeartField(vec3 p) {
	float d = 0.;
	p = abs(DigitalHeartRotate(p));
	for (int i = 0; i < 7; ++i) {
		d = max(d, exp(-float(i) / 7.) * (length(max(p - .4, vec3(0.))) - .2));
		p = abs(2.*fract(p) - 1.) + .1;
	}
	return d;
}

void main() {
	vec2 uv = 2. * gl_FragCoord.xy / iResolution.xy - 1.;
	uv *= iResolution.xy / max(iResolution.x, iResolution.y);
	vec3 ro = vec3(0., 0., 2.7);
	vec3 rd = normalize(vec3(uv.x, -uv.y, -1.5));
	float dSum = 0.;
	float dMax = 0.;
	
	float variance = mix(3., 1., pow(.5 + .5*sin(iGlobalTime), 8.));
	variance -= .05 * log(1.e-6 + DigitalHeartNoise(iGlobalTime));
	
	for (int i = 0; i < iSteps; ++i) {
		float d = DigitalHeartField(ro);
		float weight = 1. + .2 * (exp(-10. * abs(2.*fract(abs(4.*ro.y)) - 1.)));
		float value = exp(-variance * abs(d)) * weight;
		dSum += value;
		dMax = max(dMax, value);
		ro += (d / 8.) * rd;
	}
	
	float t = max(dSum / 32., dMax) * mix(.92, 1., DigitalHeartNoise(uv.x + DigitalHeartNoise(uv.y + iGlobalTime)));
	gl_FragColor = vec4(t * vec3(t*t*1.3, t*1.3, 1.), 1.);
}