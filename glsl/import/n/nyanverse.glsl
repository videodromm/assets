
// https://www.shadertoy.com/view/ldf3Wf

#define USE_BRANCHLESS_DDA true

// give planet surface at radial angle
vec4 planetSample(ivec3 p)
{
	vec3 pp = vec3(p)/iResolution.xyx;
	float s = atan(pp.z,pp.x)/3.14159;
	float t = pp.y-0.5;
	return texture2D(iChannel0, vec2(s,t));
}


// return if a block exists at the position
bool notEmpty(ivec3 p)
{
	vec4 samp = planetSample(p);
	if (length(vec3(p))<20.0+10.0*length(samp.rgb*samp.a)) return true;
	
	return false;
}

// return location of first non-empty block
// marching accomplished with fb39ca4's non-branching dda: https://www.shadertoy.com/view/4dX3zl
ivec3 intersect(vec3 ro, vec3 rd, out bool success)
{
	success = false;
	ivec3 mapPos = ivec3(floor(ro + 0.));
	vec3 deltaDist = abs(vec3(length(rd)) / rd);
	ivec3 rayStep = ivec3(sign(rd));
	vec3 sideDist = (sign(rd) * (vec3(mapPos) - ro) + (sign(rd) * 0.5) + 0.5) * deltaDist; 
	
	bvec3 mask;
	for (int i = 0; i < 100; i++) {
		if (notEmpty(mapPos)) {success = true; continue;}
		
		if (USE_BRANCHLESS_DDA) {
			bvec3 b1 = lessThan(sideDist.xyz, sideDist.yzx);
			bvec3 b2 = lessThanEqual(sideDist.xyz, sideDist.zxy);
			mask.x = b1.x && b2.x;
			mask.y = b1.y && b2.y;
			mask.z = b1.z && b2.z;
	
			//All components of mask are false except for the corresponding largest component
			//of sideDist, which is the axis along which the ray should be incremented.			
			sideDist += vec3(mask) * deltaDist;
			mapPos += ivec3(mask) * rayStep;
			
		} else {
			if (sideDist.x < sideDist.y) {
				if (sideDist.x < sideDist.z) {
					sideDist.x += deltaDist.x;
					mapPos.x += rayStep.x;
					mask = bvec3(true, false, false);
				}
				else {
					sideDist.z += deltaDist.z;
					mapPos.z += rayStep.z;
					mask = bvec3(false, false, true);
				}
			}
			else {
				if (sideDist.y < sideDist.z) {
					sideDist.y += deltaDist.y;
					mapPos.y += rayStep.y;
					mask = bvec3(false, true, false);
				}
				else {
					sideDist.z += deltaDist.z;
					mapPos.z += rayStep.z;
					mask = bvec3(false, false, true);
				}
			}
		}
	}
	return mapPos;
}

vec3 sceneColor(ivec3 p) {
	return planetSample(p).rgb;
}

void cameraTransform( inout vec3 ro, inout vec3 rd )
{
	float c = cos(-iTime);
	float s = sin(-iTime);
    mat3 rot = mat3(
		  c,  0.0,   s,
		0.0,  1.0,  0.0,
		 -s,  0.0,   c
	);
	ro *= rot;
	rd *= rot;
}

void main(void)
{
	vec2 uv = (gl_FragCoord.xy-iResolution.xy/2.0) / iResolution.yy;
	uv.y = -uv.y;
	/*vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy; 
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;*/
	
	vec3 ro = vec3(0.0,0.0,-80.0);
	vec3 rd = normalize(vec3(uv,1.0));
	cameraTransform(ro,rd);
	ro += 40.0*rd; // cull area between camera and scene
	
	bool success;
	vec3 c;
	ivec3 p = intersect(ro,rd, success);
	if (success)
		c = sceneColor(p);
	else
		c = vec3(0.1);
	
	gl_FragColor = vec4(c,1.0);
}

