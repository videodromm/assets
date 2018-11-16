// https://www.shadertoy.com/view/4dX3Rn

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
vec3 col=vec3(0.);
void mainLeft(void)
{
    vec2 p = (2.0*gl_FragCoord.xy-iResolution.xy)/iResolution.y;

    float a = atan(p.x,p.y);
    float r = length(p)*(0.8+0.2*sin(0.3*iTime));

    float w = cos(2.0*iTime+-r*2.0);
    float h = 0.5+0.5*cos(12.0*a-w*7.0+r*8.0+ 0.7*iTime);
    float d = 0.25+0.75*pow(h,1.0*r)*(0.7+0.3*w);

    float f = sqrt(1.0-r/d)*r*2.5;
    f *= 1.25+0.25*cos((12.0*a-w*7.0+r*8.0)/2.0);
    f *= 1.0 - 0.35*(0.5+0.5*sin(r*30.0))*(0.5+0.5*cos(12.0*a-w*7.0+r*8.0));
	
	col = vec3( f,
					 f-h*0.5+r*.2 + 0.35*h*(1.0-r),
                     f-h*r + 0.1*h*(1.0-r) );
	col = clamp( col, 0.0, 1.0 );
	
	vec3 bcol = mix( 0.5*vec3(0.8,0.9,1.0), vec3(1.0), 0.5+0.5*p.y );
	col = mix( col, bcol, smoothstep(-0.3,0.6,r-d) );
    //gl_FragColor = vec4( col, 1.0 );
}
void mainMiddle()
{
	
}
void mainRight()
{
	
}
void main(void)
{
	vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy; 
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;

	if(uv.x<0.9999)
	{
		mainLeft();
	}
	else
	{
		if(uv.x<0.99996)
		{
			mainMiddle();
		} 	
			else
			{
				mainRight();
			}			
	}

	vec4 outputcolor = vec4( col, 1.0 );

	gl_FragColor = outputcolor;		
}