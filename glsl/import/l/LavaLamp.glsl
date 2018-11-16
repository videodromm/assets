
// https://www.shadertoy.com/view/MdsGRH

float textureRND2D(vec2 uv)
{
	vec2 f = fract(uv);
	f = f*f*(3.0-2.0*f);
	uv = floor(uv);
	float v = uv.x+uv.y*1e3;
	vec4 r = vec4(v, v+1., v+1e3, v+1e3+1.);
	r = fract(1e5*sin(r*1e-3));
	//return mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);	
	return mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);	
}

void main( void )
{
	vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy; 
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;

	float c = step(textureRND2D(uv*5.+vec2(0.,-iTime)),uv.y*(iRatio/200.)+.1);
	// gl_FragColor = vec4(mix(vec3(1.2,.5,0.2)*uv.y, vec3(uv.y), c),1.0);
	vec3 back = vec3(iBackgroundColor.r,iBackgroundColor.g,iBackgroundColor.b);
	gl_FragColor = vec4(mix(vec3(iColor.r,iColor.g,iColor.b)*uv.y, 1.0-back*uv.y, c),1.0);
}