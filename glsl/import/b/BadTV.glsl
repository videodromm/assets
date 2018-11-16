// https://www.shadertoy.com/view/lsf3z4

float BadTVResoRand(in float a, in float b) { return fract((cos(dot(vec2(a,b) ,vec2(12.9898,78.233))) * 43758.5453)); }
// https://www.shadertoy.com/view/lsf3z4
void main(void)
{
 	vec2 BadTVReso = iResolution.xy;

	vec2 pos = iZoom * gl_FragCoord.xy / iResolution.xy;
   pos.x -= iRenderXY.x;
   pos.y -= iRenderXY.y;
	
	vec3 oricol = texture2D(iChannel0, vec2(pos.x,pos.y)).xyz;
    vec3 col;

    col.r = texture2D(iChannel0, vec2(pos.x+0.015*sin(0.02*iTime),pos.y)).x;
    col.g = texture2D(iChannel0, vec2(pos.x+0.000				,pos.y)).y;
    col.b = texture2D(iChannel0, vec2(pos.x-0.015*sin(0.02*iTime),pos.y)).z;	
	
	float c = 1.;
	//c += sin(pos.x * 20.01);
	
	c += 2. * sin(iTime * 4. + pos.y * 1000.);
	c += 1. * sin(iTime * 1. + pos.y * 800.);
	c += 20. * sin(iTime * 10. + pos.y * 9000.);
	
	c += 1. * cos(iTime * 1. + pos.x * 1.);
	
	//vignetting
	c *= sin(pos.x*3.15);
	c *= sin(pos.y*3.);
	c *= .9;
	
	pos += iTime;
	
	float r = BadTVResoRand(pos.x, 	pos.y);
	float g = BadTVResoRand(pos.x * 9., 	pos.y * 9.);
	float b = BadTVResoRand(pos.x * 3., 	pos.y * 3.);
	
  gl_FragColor = vec4(col.x * r*c*.35, col.y * b*c*.95, col.z * g*c*.35,1.0);
}

