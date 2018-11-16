// https://www.shadertoy.com/view/4dXSzB

void main(void)
{
	vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
	vec3 raintex = texture2D(iChannel1,vec2(uv.x*2.0,uv.y*0.1+iTime*0.125)).rgb/8.0;
	vec2 where = (uv.xy-raintex.xy);
	vec3 texchur1 = texture2D(iChannel2,vec2(where.x,where.y)).rgb;
	
	gl_FragColor = vec4(texchur1,1.0);
}

