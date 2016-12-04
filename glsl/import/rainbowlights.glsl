// https://www.shadertoy.com/view/ldf3W8


float bump(float x) {
	return abs(x) > 1.0 ? 0.0 : 1.0 - x * x;
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy / iResolution.xy);
	
	float c = 3.0;
	vec3 color = vec3(1.0);
	color.x = bump(c * (uv.x - 0.75));
	color.y = bump(c * (uv.x - 0.5));
	color.z = bump(c * (uv.x - 0.25));
	
	uv.y -= 0.5;
	
	float line = abs(0.01 / uv.y);
	vec4 soundWave =  texture2D(iChannel0, uv * 0.3);
	
	color *= line * (uv.x + soundWave.y * 1.5 * iRatio);
	
	
	gl_FragColor = vec4(color, 0.0);
}