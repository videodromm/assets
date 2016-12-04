// https://www.shadertoy.com/view/Xs2GRG

void main(void)
{
	vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
	vec3 b=vec3(0.);
	float a=iGlobalTime*.02;
	mat2 rot=mat2(sin(a),cos(a),-cos(a),sin(a));
	for (int r=1; r<iSteps; r++) {
		uv+=texture2D(iChannel0,uv*.5+float(r)*.132123465465).xy*.01;
		uv*=rot;
		b+=max(vec3(0.),.1-abs(texture2D(iChannel0,uv*float(r)*.004+iGlobalTime*.01).xyz-.6));
		b*=.9;
	}
	b-=texture2D(iChannel0,(uv+.5)*.75).xyz*.4;
	b*=1.-length(uv*uv)*.75;
	gl_FragColor = vec4(pow(b,vec3(2.))*20.,1.0);
}