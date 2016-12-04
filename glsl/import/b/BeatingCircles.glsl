// https://www.shadertoy.com/view/4d23Ww

const float Pi = 3.14159;
float beat = 0.;

void main(void)
{
	float ct = 10.0 * iGlobalTime * texture2D( iChannel0, vec2(0.25,5.0/100.0) ).x;
	if ((ct > 8.0 && ct < 33.5)
	|| (ct > 38.0 && ct < 88.5)
	|| (ct > 93.0 && ct < 194.5))
		beat = pow(sin(ct*3.1416*3.78+1.9)*0.5+0.5,15.0)*0.1;

	float scale = iResolution.y / 50.0;
	float ring = 20.0;
	float radius = iResolution.x*1.0;
	float gap = scale*.5;
	vec2 pos = iZoom * (gl_FragCoord.xy - iResolution.xy*.5);
	pos.x -= iRenderXY.x;
	pos.y -= iRenderXY.y;	
	float d = length(pos);
	
	// Create the wiggle
	d += beat*2.0*(sin(pos.y*0.25/scale+iGlobalTime*cos(ct))*sin(pos.x*0.25/scale+iGlobalTime*.5*cos(ct)))*scale*5.0;
	
	// Compute the distance to the closest ring
	float v = mod(d + radius/(ring*2.0), radius/ring);
	v = abs(v - radius/(ring*2.0));
	
	v = clamp(v-gap, 0.0, 1.0);
	
	d /= radius;
	vec3 m = fract((d-1.0)*vec3(ring*-.5, -ring, ring*.25)*0.5);
	
	gl_FragColor = vec4(m*v, 1.0);
}
	

	