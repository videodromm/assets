// https://www.shadertoy.com/view/ldXSRs
const float rad = 0.25;
const vec2 mid = vec2(0.5);
const ivec2 reps = ivec2(8, 8);
//const 
float angle = 10.0;
//const 
float RADIANS = angle * 0.0174532;
// rotation matrix
mat2 rot = mat2(vec2(cos(RADIANS), -sin(RADIANS)), vec2(sin(RADIANS), cos(RADIANS)));


void main(void){
	vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
	uv.y *= float(iResolution.y )/ float(iResolution.x);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
	// q is just an offset - .5
	vec2 q = uv;
	
	
	//=====================
	// wave
	//=====================
	
	// creates a repeating 0-1 range
	vec2 repeat = vec2(fract(q.x * float(reps.x)), fract(q.y * float(reps.y)) );	
	
	// holds the color
	vec3 col = vec3(1.0, 1.0, 1.0);
	
	vec2 distFromMid = repeat - mid;
	
	// drawing circles based on distance from center of each cell
	float dist = length(distFromMid);
	// aliased method
	//float circ = dist < rad ? 1.0 : 0.0;
	// anti-aliased
	float sharpness = 50.;
	float circ = rad * sharpness - dist * sharpness;
	// for black on white, subtract rad from dist
	
	col *= vec3(circ);
	gl_FragColor = vec4(col,1.0);
}
