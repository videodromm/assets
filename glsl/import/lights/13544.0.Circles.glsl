// functions begin
// http://glsl.heroku.com/e#13544.0
vec3 Circle13544_color = vec3(0.0);

vec2 Circle13544_center ( vec2 border , vec2 offset , vec2 vel ) {
	vec2 c = offset + vel * iTime;
	c = mod ( c , 2. - 4. * border );
	if ( c.x > 1. - border.x ) c.x = 2. - c.x - 2. * border.x;
	if ( c.x < border.x ) c.x = 2. * border.x - c.x;
	if ( c.y > 1. - border.y ) c.y = 2. - c.y - 2. * border.y;
	if ( c.y < border.y ) c.y = 2. * border.y - c.y;
	return c;
}

void Circle13544_circle ( float r , vec3 col , vec2 offset , vec2 vel ) {
	vel/=2.;
	vec2 pos = iZoom * gl_FragCoord.xy / iResolution.xy;
	pos.x -= iRenderXY.x;
	pos.y -= iRenderXY.y;
	float aspect = iResolution.x / iResolution.y;
	vec2 c = Circle13544_center ( vec2 ( r / aspect , r ) , offset , vel );
	c.x *= aspect;
	float d = distance ( pos , c );
	Circle13544_color += col * ( ( d < r ) ? 0.5 : max ( 0.8 - min ( pow ( d - r , .3 ) , 0.9 ) , -.2 ) );
}
void main(void)
{
	vec3 bkgd = vec3(.2*abs(sin(iRenderXY.x)),.4*abs(sin(iRenderXY.y)),.8*abs(sin(iRenderXY.x-iRenderXY.y)+.4));
	Circle13544_circle ( .03 , vec3 ( 0.7 , 0.2*sin(iTime) , 0.8 ) , vec2 ( .6 ) , vec2 ( .30 , .20 ) );
	Circle13544_circle ( .05 , vec3 ( 0.7 , 0.9 , 0.6*cos(iTime) ) , vec2 ( .6 ) , vec2 ( .30 , .20 ) );
	Circle13544_circle ( .07 , vec3 ( 0.3*sin(iTime) , 0.4 , 0.1 ) , vec2 ( .6 ) , vec2 ( .30 , .20 ) );
	Circle13544_circle ( .10 , vec3 ( 0.2 , 0.5 , cos(iTime+.2) ) , vec2 ( .6 ) , vec2 ( .30 , .20 ) );
	Circle13544_circle ( .20 , vec3 ( 0.1 , 0.3 , sin(iTime+10.)-cos(iTime+20.) ) , vec2 ( .6 ) , vec2 ( .30 , .20 ) );
	Circle13544_circle ( .30 , vec3 ( 0.9 , cos(iTime) , 0.2 ) , vec2 ( .6 ) , vec2 ( .30 , .20 ) );
	Circle13544_circle ( .15 , abs(vec3 ( sin(iTime) , 0.4 , 0.2 )) , vec2 ( .3 ) , vec2 ( .30 , .20 ) );
	Circle13544_color+=bkgd*(abs(sin(iTime/5.))+.3);
	gl_FragColor = vec4(Circle13544_color,1.0);
}

