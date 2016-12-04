// https://www.shadertoy.com/view/4ssGzX

float circle(vec2 uv, float diameter, float speed)
{
	float angle = iGlobalTime*speed;
	uv*= mat2(  sin(angle), cos(angle),
				cos(angle),-sin(angle));
	
	//float pixelate = 0.3;// 0.03-cos(iGlobalTime*0.1)*0.025;
	float pixelate =  0.03-cos(iGlobalTime*0.1)*0.025;
	pixelate -= mod(pixelate,0.001);
	uv -= mod(uv,pixelate)-pixelate*0.5;
	return 1.0-smoothstep(0.005,0.01+pixelate,abs(length(uv)-diameter));
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy-iResolution.xy/2.0) / min(iResolution.x,iResolution.y);
	
	gl_FragColor = vec4(circle(uv, 0.4, 1.0),
						circle(uv, 0.4, -1.0),
						circle(uv, 0.4, -0.5),
						1.0);
}