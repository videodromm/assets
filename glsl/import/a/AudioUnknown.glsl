void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
   uv = 2. * uv;
   uv = uv - 1.;
	float b = texture2D(iChannel0, vec2(0.1, 0.0)).x;
	b = b*b;
	float c = texture2D(iChannel0, vec2(0.2, 0.0)).x;
	c = c*c;
	float d = texture2D(iChannel0, vec2(0.3, 0.0)).x;
	d = d*d;
	float e = texture2D(iChannel0, vec2(0.05, 0.0)).x * 5.0;
	
	float a = length(vec2(.5,.5)-uv);
	float angle = atan(uv.y,uv.x)*(6.0+e);
	a = a*(cos(angle+b+c+d+iGlobalTime)*0.5+1.0);
		
	vec4 col = texture2D(iChannel0, vec2(a, 0.0));
	col.x += b;
	col.y += c;
	col.z += d;
  gl_FragColor = vec4(col.x, col.y, col.z,1.0);
}

