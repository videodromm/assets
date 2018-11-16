// https://www.shadertoy.com/view/MdsSDM
void main(void)
{
	vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy;
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
	float rurka = sin(uv.x*32.0-tan(uv.y*4.0+sin(iTime+uv.x*6.0-sin(iTime)*4.0)-2.0)*12.0+iTime*10.0);
	float shadey = -abs(tan(uv.y*4.0+sin(iTime+uv.x*6.0-sin(iTime)*4.0)-0.5));
	
	float komplet = rurka-cos(uv.x*125.0+iTime*32.0);
	float ouch = clamp((shadey+3.0)/3.0,0.0,1.0)*2.0;

	gl_FragColor = vec4(komplet-ouch,abs(komplet*0.5)-ouch,0.1-komplet*1.0-ouch,komplet);
}
