// https://www.shadertoy.com/view/MslSRS
const float PI = 3.14159265358979323846264;

void main(void)
{
	vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy - vec2(.5,.5);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
	
	//vec2 coord = uv - vec2(.5,.5);
	//coord.y *= iResolution.y / iResolution.x;
	float angle = atan(uv.y, uv.x);
	float dist = length(uv);
	
	float brightness = .5 + .5 * 
		sin(96.0*angle + 
			sin(iGlobalTime*PI*1.0)*PI*196.0*dist / .707);
	vec4 color = vec4( brightness, brightness, brightness, 1.0);
	gl_FragColor = color;
}
