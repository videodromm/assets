// https://www.shadertoy.com/view/ldsSWs
// Derivative work of:
//   Deform - relief tunnel by inigo quilez - iq/2013 
//   License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//   https://www.shadertoy.com/view/4sXGRn

void main(void)
{
    //vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy;
    vec2 p = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
    p.x *= float(iResolution.x )/ float(iResolution.y);
	p.x -= iRenderXY.x;
	p.y -= iRenderXY.y;
    vec2 uv;
    
    float f0 = texture2D( iChannel0, vec2( 0.025, 0.25 ) ).x;
	float f1 = texture2D( iChannel0, vec2( 0.20, 0.25 ) ).x;
	float f2 = texture2D( iChannel0, vec2( 0.60, 0.25 ) ).x;
	float f3 = texture2D( iChannel0, vec2( 0.85, 0.25 ) ).x;
    
    float ints = length(vec4(f0, f1, f2, f3)) * 1.25;
    
    float r = sqrt( dot(p,p) ) * (1.0 + f0 - f2);
	
    float a = atan(p.y,p.x) 
        + 0.75*sin(0.5 / r + iTime) * (0.7 + 0.6 * f2)
        - 1.75*cos(0.25 / r + iTime / 1.7) * (0.9 + 0.2 * f3);
	
	float h = (0.5 + 0.5*cos(9.0*a));

	float s = smoothstep(0.8,0.2,h);

    uv.x = iTime * 2.0 - ints * 0.25 + 1.0/( r + .1*s);
    uv.y = 3.0*a/3.1416;

    float colorShift = ((ints-r) * 55.0 + iChannelTime[1] + 200.0) * (0.02 + 0.02 * ints);
    vec3 col = texture2D(iChannel0,uv).xyz;
	col *= 1.0 + 0.4 * ints;
    col.zx = mix(col.yz, col.xy, sin(colorShift));
    
    float ao = smoothstep(0.0,0.3,h)-smoothstep(0.5,1.0,h);
    col *= 1.0-0.6*ao*r;
	col = col / r +  .05 / r / r;
    
    gl_FragColor = vec4(col,1.0);
}

