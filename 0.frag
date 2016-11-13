/*0.frag*/
#version 150
// shadertoy specific
uniform vec3      	iResolution; 			// viewport resolution (in pixels)
uniform float     	iGlobalTime; 			// shader playback time (in seconds)
uniform sampler2D 	iChannel0; 				// input channel 0

out vec4 fragColor;
//for audio input
void main(void)	
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
   	vec4 tex = texture(iChannel0, uv);
   	fragColor = vec4(tex.r, tex.g, tex.b, 1.0);
}
