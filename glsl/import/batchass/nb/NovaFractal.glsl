// https://www.shadertoy.com/view/Xsl3DM
void main( void ) {
	vec2 p = gl_FragCoord.xy / iResolution.xy * 2.0 - 1.0;
	p.x *= iResolution.x / iResolution.y;
	vec2 c = p;
	float iter = 0.0;
	vec4 color = vec4(0.0);
	for (int i = 0; i < 40; i++) {
		vec4 g = texture2D(iChannel0, c);
		color += g;
		float phi = atan(c.y, c.x) + iTime*0.01*iter;
		float r = dot(c,c);
		if (r < 16.0) {
    		c.x = ((cos(2.0*phi))/r) + p.x;
    		c.y = (-sin(2.0*phi)/r) + p.y;
		
    		iter++;
		}
	}
	gl_FragColor = vec4(color / 40.0 + max(0.75 - iter / 40.0, 0.0));
}