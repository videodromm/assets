
// https://www.shadertoy.com/view/Mss3Dr
// by nikos papadopoulos, 4rknova / 2013
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define PI  3.14159
#define EPS .001

#define T .03  // Thickness
#define W 2.   // Width
#define A .09  // Amplitude
#define V 1.   // Velocity

void main(void)
{
	vec2 c = gl_FragCoord.xy / iResolution.xy;
	vec4 s = texture2D(iChannel0, c * .5);
	// Paul Houx
	//vec2 c = gl_FragCoord.xy * iResolutionRcp;
	//vec4 s = texture2D(iChannel0, c);

	//vec4 s = vec4(iFreq0, iFreq1, iFreq2, iFreq3);
	c = vec2(0., A*s.y*sin((c.x*W+iGlobalTime*V)* 2.5)) + (c*2.-1.);
	float g = max(abs(s.y/(pow(c.y, 2.1*sin(s.x*PI))))*T,
				  abs(.1/(c.y+EPS)));
	gl_FragColor = vec4(g*g*s.y*.6, g*s.w*.44, g*g*.7, 1.);
}
