
// https://www.shadertoy.com/view/MsfSz4

void main(void)
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy*16.0;
	//vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
	vec2 p = uv - 7.3;
	
	float r = length(p);
	float a = atan(p.x, p.y);
	
	//vec4 tex = texture2D( iChannel0, -p + iTime/30.0);//+0.7 );
	//vec4 tex = texture2D( iChannel0, -p.xy+0.1 );
	//vec4 tex = texture2D( iChannel0, vec2( r, a ) );
	//vec4 tex = texture2D( iChannel0, vec2( 1.0/ r + iTime, a + iTime/3.0 ) );
	//vec4 tex = texture2D( iChannel0, vec2( 1.0/ r + iTime + sound.x, a ) );
	//sound
	vec4 sound = texture2D( iChannel0, vec2( 0.01, 0.25 ));
	//vec4 tex = texture2D( iChannel0, vec2( 1.0/ r  + sound.x, a ) );
	vec4 tex = texture2D( iChannel0, vec2( 1.0/ r  + sound.x, a ) );
	
	vec3 c = tex.xyz * r;//vec3(r, 0.0,0.0);
	//vec3 c = vec3(r, 0.0,0.0);
	//vec3 c = vec3(0.5, 0.0,0.2);
	
	
	gl_FragColor = vec4(c,1.0);
}
