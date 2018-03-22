// https://www.youtube.com/watch?v=y8aL4Cnb9m4
float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
	vec2 uv = p.xy + f.xy*f.xy*(3.0-2.0*f.xy);
	return texture2D( iChannel0, (uv+118.4)/256.0, -100.0 ).x;
}
mat2 m = mat2(0.8,0.6,-0.6,0.8);// to rotate the octaves
// fractional brownian motion
float fbm( vec2 p)
{
	float f = 0.0;
	// octaves
	f += 0.5000*noise( p ); p*=m*2.02; // 0.500 = frequency
	f += 0.2500*noise( p ); p*=m*2.03; //
	f += 0.1250*noise( p ); p*=m*2.01; //
	f += 0.0625*noise( p ); p*=m*2.04; 
	f /= 0.9375;
	return f;
}
void main(void)
{
	vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy;
	// transform from 0 1 to -1 1
	vec2 p = -1.0 + uv * 2.0; 
	// fix aspect ratio
	p.x *= iResolution.x/iResolution.y;
	float background = smoothstep( -0.25, 0.25, p.x);
	float f = noise( 32.0*p );
	//float f = fbm( 4.0*p );
	// move the circle to the right
	p.x -= 0.75;
	// r = radius
	// distance from the center of the screen
	float r = sqrt(dot(p,p));
	float a = atan(p.y,p.x);
	
	vec3 col = vec3( f);

	//float ss = 0.5 + 0.5*sin(iGlobalTime);
	//float anim = 1.0 + 0.1*ss;
	float ss = 0.5 + 0.5*sin(2.0*iGlobalTime);
	float anim = 1.0 + 0.1*ss*clamp(1.0-r,0.0,1.0);
	r *= anim;
	if (r<0.8)
	{
		col = vec3(0.2,0.3,0.4);
		float f = fbm( 5.0*p );
		col = mix( col, vec3(0.2,0.5,0.4), f );

		f = 1.0 - smoothstep(0.2,0.5,r);
		col = mix(col, vec3(0.9,0.6,0.2),f);

		a += fbm(iRatio*p);

		f = smoothstep(0.3,1.0,fbm(vec2(6.0*r,20.0*a)));
		col = mix(col, vec3(1.0),f);

		f = smoothstep(0.4,0.9,fbm(vec2(10.0*r,15.0*a)));
		col *= 1.0-0.5*f;

		f = smoothstep(0.6,0.8,r);
		col *= 1.0-0.5*f;

		f = smoothstep(0.2,0.25,r);
		col *= f;

		f = 1.0 - smoothstep( 0.0,0.2, length(p-vec2(0.1,0.1)));
		col += vec3(f);

		f = smoothstep(0.75,0.8,r);
		col = mix(col, vec3(0.6),f);

	}

	gl_FragColor = vec4(col*background, 1.0);
}

