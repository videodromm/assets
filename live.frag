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
	
	//uv.x = 1.0 - uv.x;
	//uv.y = 1.0 - uv.y;

    uv.x += spectrum.y * 0.0000004 * tan(iGlobalTime + uv.y );
	vec4 t0 = texture(iChannel0, uv);
	vec4 t1 = texture(iChannel1, uv);
	vec4 t2 = texture(iChannel2, uv);
	float col = sin(uv.x*iGlobalTime);
    //float col = abs(sin(time + uv.x * 20.0));

   	oColor = vec4(vec3( col ),1.0);
}
