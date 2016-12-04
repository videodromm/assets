// https://www.shadertoy.com/view/4dBGDy

vec3 GreenDiscsCam_origin;
mat3 GreenDiscsCam_rotation;
vec2 GreenDiscsFragCoord;
float GreenDiscsTime=0.0;

vec3 GreenDiscsRotateX(float a, vec3 v)
{
	return vec3(v.x, cos(a) * v.y + sin(a) * v.z, cos(a) * v.z - sin(a) * v.y);
}

vec3 GreenDiscsRotateY(float a, vec3 v)
{
	return vec3(cos(a) * v.x + sin(a) * v.z, v.y, cos(a) * v.z - sin(a) * v.x);
}

vec3 GreenDiscsRound(vec3 x)
{
	return floor(x + vec3(0.5));
}

float GreenDiscsOrbIntensity(vec3 p)
{
	if(length(p) < 4.0)
		return 1.0;
	
	return smoothstep(0.25, 1.0, cos(p.x * 10.0) * sin(p.y * 5.0) * cos(p.z * 7.0)) * 0.2 *
				step(length(p), 17.0);
}

vec3 GreenDiscsProject(vec3 p)
{
	// transpose the rotation matrix. unfortunately tranpose() is not available.
	mat3 cam_rotation_t = mat3(vec3(GreenDiscsCam_rotation[0].x, GreenDiscsCam_rotation[1].x, GreenDiscsCam_rotation[2].x),
							   vec3(GreenDiscsCam_rotation[0].y, GreenDiscsCam_rotation[1].y, GreenDiscsCam_rotation[2].y),
							   vec3(GreenDiscsCam_rotation[0].z, GreenDiscsCam_rotation[1].z, GreenDiscsCam_rotation[2].z));
	
	// transform into viewspace
	p = cam_rotation_t * (p - GreenDiscsCam_origin);
	
	// GreenDiscsProject
	return vec3(p.xy / p.z, p.z);
}

float GreenDiscsOrb(float rad, vec3 coord)
{
	return 1.0 - smoothstep(0.5, 0.55, distance(coord.xy, GreenDiscsFragCoord) / rad);
}

float GreenDiscsOrbShadow(float rad, vec3 coord)
{
	return 1.0 - smoothstep(0.4, 1.1, distance(coord.xy, GreenDiscsFragCoord) / rad) *
		mix(1.0,0.99,GreenDiscsOrb(rad,coord));
}

vec3 GreenDiscsTraverseUniformGrid(vec3 ro, vec3 rd)
{
	vec3 increment = vec3(1.0) / rd;
	vec3 intersection = ((floor(ro) + GreenDiscsRound(rd * 0.5 + vec3(0.5))) - ro) * increment;

	increment = abs(increment);
	ro += rd * 1e-3;
	
	vec4 accum = vec4(0.0,0.0,0.0,1.0);
	
	// traverse the uniform grid
	for(int i = 0; i < iSteps; i += 1)
	{
		vec3 rp = floor(ro + rd * min(intersection.x, min(intersection.y, intersection.z)));
		
		float orb_intensity = GreenDiscsOrbIntensity(rp);

		if(orb_intensity > 1e-3)
		{
			// get the screenspace position of the cell's centerpoint										   
			vec3 coord = GreenDiscsProject(rp + vec3(0.5));
			
			if(coord.z > 1.0)
			{
				// calculate the initial radius
				float rad = 0.55 / coord.z;// * (1.0 - smoothstep(0.0, 50.0, length(rp)));
				
				// adjust the radius
				rad *= 1.0 + 0.5 * sin(rp.x + GreenDiscsTime * 1.0) * cos(rp.y + GreenDiscsTime * 2.0) * cos(rp.z);
				
				float dist = distance(rp + vec3(0.5), ro);
				
				float c = smoothstep(1.0, 2.5, dist);
				float a = GreenDiscsOrb(rad, coord) * c;
				float b = GreenDiscsOrbShadow(rad, coord) * c;
				
				accum.rgb += accum.a * a * 1.5 *
					mix(vec3(1.0), vec3(0.4, 1.0, 0.5) * 0.5, 0.5 + 0.5 * cos(rp.x)) * exp(-dist * dist * 0.008);

				accum.a *= 1.0 - b;
			}
		}
		
		// step to the next ray-cell intersection
		intersection += increment * step(intersection.xyz, intersection.yxy) *
									step(intersection.xyz, intersection.zzx);
	}
	
	// background colour
	accum.rgb += accum.a * vec3(0.02);

	return accum.rgb;
}
void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;

	GreenDiscsFragCoord = uv * 2.0 - vec2(1.0);
	GreenDiscsFragCoord.x *= iResolution.x / iResolution.y;

	// defined the GreenDiscsTime interval for this frame
	float time0=iGlobalTime,time1=time0+0.04;
	
	float jitter=texture2D(iChannel0,uv*iResolution.xy/256.0).r;
	
	gl_FragColor.rgb = vec3(0.0);
		
	for(int n=0;n<4;n+=1)
	{
		GreenDiscsTime=mix(time0,time1,(float(n)+jitter)/4.0)*0.7;
		
		GreenDiscsCam_origin = GreenDiscsRotateX(GreenDiscsTime * 0.3,
							 GreenDiscsRotateY(GreenDiscsTime * 0.5, vec3(0.0, 0.0, -10.0)));
		
		// calculate the rotation matrix
		vec3 cam_w = normalize(vec3(cos(GreenDiscsTime) * 10.0, 0.0, 0.0) - GreenDiscsCam_origin);
		vec3 cam_u = normalize(cross(cam_w, vec3(0.0, 1.0, 0.0)));
		vec3 cam_v = normalize(cross(cam_u, cam_w));
		
		GreenDiscsCam_rotation = mat3(cam_u, cam_v, cam_w);
		
		vec3 ro = GreenDiscsCam_origin,rd = GreenDiscsCam_rotation * vec3(GreenDiscsFragCoord, 1.0);
	
		// render the particles
		gl_FragColor.rgb += GreenDiscsTraverseUniformGrid(ro, rd);
	}
	
	// good old vignet
	gl_FragColor.rgb *= 0.5 + 0.5*pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), 0.1 );

	gl_FragColor.rgb = sqrt(gl_FragColor.rgb / 4.0 * 0.8);
	//return gl_FragColor.rgb;
 //gl_FragColor = vec4(c,1.0);
}
