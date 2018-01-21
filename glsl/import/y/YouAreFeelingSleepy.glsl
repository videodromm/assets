// https://www.shadertoy.com/view/XsfXR2
#define MSAA 4.0

float hill (float t, float w, float p) {	
	return min (step (t-w/2.0,p), 1.0 - step (t+w/2.0,p));
}

mat2 rotate (float fi) {
	float cfi = cos (fi);
	float sfi = sin (fi);	
	return mat2 (-sfi, cfi, cfi, sfi);	
}

vec4 compute_spiral (vec2 uv, float iTime) {
	float fi = length (uv) * 50.0;
	uv *= rotate (iTime*7.0);
	uv *= rotate (fi);	
	return mix (vec4 (1.0), vec4 (0.0), min (
		step (0.0, uv.x), 
		hill (0.0, fi/25.0, uv.y)));
}
	

void main (void) {
	//float fact =  1.0/min (iResolution.x, iResolution.y);
	float fact =  iRatio/100.0;
	//vec2 uv = (2.0*gl_FragCoord.xy - iResolution.xy) * fact;
   vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
	
	#ifdef MSAA
	vec4 ac = vec4 (0.0);
	for (float y = 0.0; y < MSAA; ++y) {
		for (float x = 0.0; x < MSAA; ++x) {			
			vec2 c =  vec2 (
				(x-MSAA/2.0)*fact/MSAA,
				(y-MSAA/2.0)*fact/MSAA);
			ac += compute_spiral (uv + c, iGlobalTime) / (MSAA*MSAA);
		}
	}	
	gl_FragColor = ac;
	#else 
	gl_FragColor = compute_spiral (uv*1.0, iGlobalTime);		
	#endif	
}
