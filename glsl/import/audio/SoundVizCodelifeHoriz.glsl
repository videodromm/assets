// https://www.shadertoy.com/view/lsl3zr
void main(void)
{
	//vec2 uv = iZoom * (gl_FragCoord.xy / iResolution.xy);
	vec2 uv = (2.0*iZoom * gl_FragCoord.xy/iResolution.xy) - 1.0;
    
	vec2 spec = 1.0*texture2D( iChannel0, vec2(0.25,5.0/100.0) ).yy;
	
    float col = 0.0;
    uv.y += sin(iTime * 6.0 + uv.x*1.5)*spec.x;
    col += abs(0.8/uv.y) * spec.x;
	
	gl_FragColor = vec4( col, col, col, 1.0);
}


