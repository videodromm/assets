
// https://www.shadertoy.com/view/MdfSRj
const float CBGi_MAXD = 100.;
vec3 CBGeps = vec3(.02, 0., 0.);
int CBGistep = 0;

float CBGsmin( float a, float b ) {
	float k = 1.;
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float CBGsdSphere( vec3 p, float s ) {
  return length(p)-s;
}

float CBGsdGrid(vec3 p, vec3 q) {		
	float w = 0.1;	
  	return CBGsmin(
			CBGsmin(
				length(p.xy)-w,
				length(p.xz)-w
				),
			length(p.yz)-w
		);
}

vec2 CBGfield(in vec3 q) {		
	float grid = 5. + .1*length(q);
		
	float c = .2*cos(.05*q.y);
    float s = .2*sin(.05*q.z);
	mat2 m = mat2(c,-s,s,c);
    vec3 p = mix(vec3(m*q.xy,q.z), q, .4 + .23*sin(.11*iTime));
	vec3 w = .2*p;
	
	vec3 pp = 4.*vec3(sin(1.+.94*iTime), cos(1.12*iTime), 1.5+sin(2.+0.73*iTime)*cos(.81*iTime));
	float sp = CBGsdSphere(p + pp, 1.3);
	
	vec3 g = mod(p, grid) - .5*grid;	
	return vec2(CBGsmin(CBGsdGrid(g, q), sp), 0.);
}

vec3 CBGnormal(vec3 p) {
	return normalize(vec3(
		CBGfield(p+CBGeps.xyz).x - CBGfield(p-CBGeps.xyz).x,
		CBGfield(p+CBGeps.yxz).x - CBGfield(p-CBGeps.yzx).x,
		CBGfield(p+CBGeps.yzx).x - CBGfield(p-CBGeps.yzx).x
		));
}


vec4 CBGintersect(in vec3 ro, in vec3 rd) {	
    	float k = 0.;
    	vec2 r = vec2(0.1);
    	int j = 0;
    	for(int i=0; i<iSteps; i++ ) {
			if (CBGistep > iSteps) continue;
        	if(abs(r.x) < CBGeps.x || k>CBGi_MAXD) continue;        				
	    	r = CBGfield(ro+rd*k);
	    	k += r.x;
			j += 1;
			CBGistep += 1;
    	}

    	if(k>CBGi_MAXD) r.y=-1.0;
    	return vec4( k, j, r.yx );
}

vec3 CBGFresnelSchlick(vec3 SpecularColor,vec3 E,vec3 H) {
    return SpecularColor + (1.0 - SpecularColor) * pow(1.0 - clamp(dot(E, H), 0., 1.), 5.);
}


vec3 CBGshade(vec4 h, vec3 p, vec3 rd, vec3 n) {
	vec3 color = vec3(0.);
	if (h.z >= 0.) {	
		vec3 L = (-rd);
		float D = clamp(dot(L, n), 0., 1.);
		vec3 H = normalize(L - rd);
		vec3 R = reflect(rd, n);
			
		vec3 tex = texture2D(iChannel0, R.xy).xyz;
		vec3 dcolor = 0.1+0.3*tex;
		vec3 scolor = vec3(0.4, 0.3, 0.2 );
		
		// L = light
		// N = CBGnormal
		// R = reflected ray
		// V = viewer, -1* ray dir
		// H = halfway vector H = .5*(L + V)
		
		float spec = 64.;		
			
		color = dcolor*1.*(D + .01);
		color += CBGFresnelSchlick(scolor, L, H) * ((spec + 2.) / 8. ) * pow(clamp(dot(n, H), 0., 1.), spec) * D;		
		
		color *= smoothstep(0., 1., 6./h.x);	
	}		
	
	return color;
}

// Stolen somewhere
vec2 CBGHmdWarp(vec2 uv) {
	// screen space transform(Side by Side)
	uv = vec2((mod(uv.x,1.0)-0.5)*2.0+0.2*sign(uv.x), uv.y);

	// HMD Parameters
	vec2 ScaleIn = vec2(1.0);
	vec2 LensCenter = vec2(0.0,0.0);
	vec4 HmdWarpParam = vec4(1.0,0.22, 0.240, 0.00);
	vec2 Scale = vec2(1.1);

	// Distortion
	vec2 theta  = (uv - LensCenter) * ScaleIn; // Scales to [-1, 1]
	float  rSq    = theta.x * theta.x + theta.y * theta.y;
	vec2 rvector= theta * (HmdWarpParam.x + HmdWarpParam.y * rSq
			       + HmdWarpParam.z * rSq * rSq
			       + HmdWarpParam.w * rSq * rSq * rSq);
	return LensCenter + Scale * rvector;
}
/*
	vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
	vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
	uv.x *= float(iResolution.x )/ float(iResolution.y);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
*/
void main(void)
{
	vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;	
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
	//vec3 mouse = vec3(2.*iMouse.xy / iResolution.xy - 1., 0.);
	//mouse.y *= -1.;
	
	vec2 xy = CBGHmdWarp(2.*uv - 1.);
	
	vec3 ct = vec3(.5*cos(iTime), .5*sin(iTime), 0.);// + 5.*mouse;
	vec3 cp = vec3(0., 0., -13.);
	vec3 cd = normalize(ct-cp);		
	
	vec3 side = cross(vec3(0., 1., 0.), cd);
	vec3 up = cross(cd, side);
	vec3 rd = normalize(cd + 1.5*(xy.x*side + xy.y*up)); // FOV
	
    //-----------------------------------------------------	
	
	vec4 h = CBGintersect(cp, rd);			
	vec3 p = cp + h.x*rd;
	vec3 color = vec3(0.);	
	if (h.z >= 0.) {
		vec3 n = CBGnormal(p-rd*0.01);
		vec3 R = reflect(rd, n);
		color = CBGshade(h, p, rd, n);
	}	
	
	color = pow( clamp(color,0.0,1.0), vec3(0.45) );
	//color = pow( color, vec3(1.1)) * sqrt( 64.*uv.x*uv.y*(1.-uv.x)*(1.-uv.y) );
	gl_FragColor = vec4(color, 1.);
}
