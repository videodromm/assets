/*
{
	"title" : "simplecolor",
	"value" : 1,
	"url" : "http://www.batchass.fr/"
} 
*/
// center: -1. + 2. * 
uniform vec3  iResolution;  // viewport resolution (in pixels)
uniform vec3  iColor;
uniform float iGlobalTime;
uniform sampler2D	iChannel0;
uniform sampler2D	iChannel1;
uniform sampler2D	iChannel2;
uniform vec3 spectrum;
out vec4 oColor; 

void main(void)	
{
	vec2 uv =  gl_FragCoord.xy / iResolution.xy;
	

    uv.x += 0.0000004 * tan(iGlobalTime + uv.y );
	
	float col = sin(uv.x*iGlobalTime);
    //float col = abs(sin(iGlobalTime + uv.x * 20.0));

   	oColor = vec4(vec3( col ),1.0);
}
