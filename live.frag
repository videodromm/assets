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

out vec4 oColor; 
void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
	vec4 t0 = texture2D(iChannel0, uv);
	vec4 t1 = texture2D(iChannel1, uv);
	oColor = vec4(t0.x, t1.y, cos(iGlobalTime), 1.0); 
}
