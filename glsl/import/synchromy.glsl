// https://www.shadertoy.com/view/MdlXRX
vec3 c1 = vec3(0.8, 0.2, 0.2);
vec3 c2 = vec3(0.45, 0.6, 1.0);

vec3 stripe(float p, float width, vec3 color1, vec3 color2) {
	float pmod = mod(p, width / 2.0);
	float w4 = width / 4.0;
	float f = abs(pmod-w4)/w4;
	float f1 = pow(f, 6.0);
	float f2 = pow(1.0 - f, 6.0);
	vec3 m1 = mix(color1, color2, f1);
	vec3 m2 = mix(color2, color1, f2);
	return pmod > w4 ? m1 : m2;
}

void main(void) {
	float v1 = texture2D(iChannel0, vec2(0.1,0.1)).x;
	float v2 = texture2D(iChannel0, vec2(0.5,0.1)).x;
	float v3 = texture2D(iChannel0, vec2(0.3, 0.3)).x;
	
	vec2 center = vec2(0.0);
	vec3 color = vec3(0.0);
	float t = iGlobalTime;
	float zoom = v2 * 0.5 + 0.9;
	float width1 = 0.18;
	float width2 = width1 / 2.0;
	float width3 = width1 * 4.0;
	//vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
	vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
	uv.x *= float(iResolution.x )/ float(iResolution.y);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;	
	uv.x = abs(uv.x);
	uv.x += 0.35 * width1 * v1;

	// glitch the point around
	float glitch = sin(18.245*iGlobalTime)*cos(11.323*iGlobalTime)*sin(4.313*iGlobalTime);
	glitch *= glitch;
	uv.x += sin(uv.y*19.1)*glitch*.01;
	uv.x += sin(uv.y*459.1)*glitch*glitch*.02;


	
	float d = length(uv - center) + 0.5;
	
	d = smoothstep(d + v1, d - v1, v1);
	uv.x *= d*d;	
	
	vec2 r1 = mod(uv, width1);
	vec2 r2 = mod(uv, width2);
	vec2 r3 = mod(uv, width3);
	
	color += stripe(vec2(r1-(width1/2.0)).x, width1, c1, c2);
	color += stripe(vec2(r2-(width2/2.0)).y + sin(t * v3 * 0.05), width2, c2, c1) * v3 * 0.1;
	color += stripe(vec2(r3-(width3/2.0)).y + sin(t * v3 * 0.5), width3, c2, c1) * v3 * 0.1;
	
	color *= (1.0 - smoothstep(0.1, 3.5, length(uv)));
	
	gl_FragColor = vec4(color, 1.0);
}
