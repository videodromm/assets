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

//out vec4 oColor; 

void main(void)	
{
	vec2 uv =  gl_FragCoord.xy / iResolution.xy;
	
	//uv.x = 1.0 - uv.x;
	//uv.y = 1.0 - uv.y;

	vec4 t0 = texture2D(iChannel0, uv);
	vec4 t1 = texture2D(iChannel1, uv);
	float col = sin(uv.x*iGlobalTime);
    //uv.x += spectrum.y * 4.4 * tan(time + uv.y );
    //float col = abs(sin(time + uv.x * 20.0));
    //gl_FragColor = vec4(col,0,col,1.0);
   	gl_FragColor = vec4(vec3( col ),1.0);
}
