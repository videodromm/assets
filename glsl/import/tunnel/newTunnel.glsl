// https://www.shadertoy.com/view/ls2XDw

mat3 worldRotation() {
	float xang = iGlobalTime * 0.5;
    float yang = iGlobalTime * 0.0;
    float zang = iGlobalTime * 0.5;
    
	mat3 zrot = mat3(
    	cos(zang), -sin(zang), 0.0,
        sin(zang), cos(zang), 0.0,
        0.0, 0.0, 1.0);
    
    mat3 yrot = mat3(
        cos(yang), 0.0, -sin(yang),
        0.0, 1.0, 0.0,
        sin(yang), 0.0, cos(yang));

    mat3 xrot = mat3(
        1.0, 0.0, 0.0,
        0.0, cos(xang), -sin(xang),
        0.0, sin(xang), cos(xang));
    
    return zrot * yrot * xrot;
}

vec3 viewToWorld(vec3 pos) {
	vec3 world = worldRotation() * pos;
    world.z += iGlobalTime * 10.0;
    return world;
}

vec3 worldToView(vec3 pos) {
	vec3 view = pos;
    view.z -= iGlobalTime * 10.0;
	return view * worldRotation();
}

vec2 dist(vec3 pos) {
	pos = viewToWorld(pos);
    
    float len = length(pos.xy);
    float tun = len - 6.0;
    
    float theta = atan(pos.y, pos.x) * 20.0;
    float phi =  (pos.z + theta) * 0.5;
    
    float disp = sin(phi) * sin(pos.z);
    
    float damp = pow(1.0 / (1.0 + abs(pos.z) * 0.1), 1.0);

    tun += disp * (1.0 - damp);
    
    return vec2(tun,disp);
}

vec2 trace(vec3 ray) {
    float t = 0.0;
    vec2 disp;
    for(int i = 0; i < 16; ++i){
        disp = dist(ray * t);
        t += abs(disp.x) * 0.5;
    }
    return vec2(t, disp.y);
}

vec3 normal(vec2 coord) {
	vec3 ray = vec3(coord.xy, 1.0);
    float delta = 1.0 / iResolution.x;
    
    vec3 rhl = normalize(ray + vec3(-delta, 0.0, 0.0));
    vec3 hl = rhl * trace(rhl).x;
    
    vec3 rhr = normalize(ray + vec3(delta, 0.0, 0.0));
    vec3 hr = rhr * trace(rhr).x;
    
    vec3 rvl = normalize(ray + vec3(0.0, -delta, 0.0));
    vec3 vl = rvl * trace(rvl).x;
    
    vec3 rvr = normalize(ray + vec3(0.0, delta, 0.0));
    vec3 vr = rvr * trace(rvr).x;
    
    return normalize(cross(hr-hl, vr-vl));
}
void main() {

	vec2 coord = (gl_FragCoord.xy + 0.5) / iResolution.xy * 2.0 - 1.0;
    coord.y *= iResolution.y / iResolution.x;
    vec3 eye = normalize(vec3(coord.xy, 1.0));

    vec2 alpha = trace(eye);
    vec3 norm = normal(coord);
    
    vec3 view = eye * alpha.x;
    vec3 world = viewToWorld(view);
    
    vec3 lighting = vec3(0.1,0.1,0.1);
    vec3 glow = vec3(0.0,0.0,0.0);
    
    for (int i=-1; i<2; ++i) {
        float lang = world.z * 0.5 + iGlobalTime * 3.0;
        vec3 lpos = vec3(cos(lang)*sin(lang*2.0), sin(lang), 0.0) * 3.0;
        float lightz = (floor(world.z/50.0)+float(i))* 50.0;
        vec3 light = vec3(lpos.x, lpos.y, lightz);
        vec3 surfaceToLight = light - world;
        float lightDist = dot(surfaceToLight, surfaceToLight);
        surfaceToLight = normalize(surfaceToLight);
        float shine = 1.0 / (1.0 + lightDist * 0.01);
        vec3 ref = surfaceToLight - 2.0 * norm * dot(surfaceToLight, norm);

		vec3 lcol = vec3(cos(world.z+iGlobalTime), sin(world.z), cos(world.z)) * 0.5 + 0.5;
        
        float spec = pow(0.3 + max(dot(eye, -ref),0.0), 8.0);
        vec3 diff = vec3(sin(world.x), cos(world.x), sin(world.x)) * 0.5 + 0.5;
        diff *= alpha.y * 0.5 + 0.5;    
        
        lighting += (diff + spec) * lcol * shine;
        
        vec3 viewLight = worldToView(light);
        if (viewLight.z > 0.0) {
            viewLight /= viewLight.z;
            vec2 orbdiff = coord - viewLight.xy;
        	float dist = dot(orbdiff, orbdiff);
        	float orb = 1.0 / (1.0 + dist * 100.0);
            orb = pow(0.1 + orb, 4.0);
        	glow += orb * lcol;
        }
    }
    
    float fog = 1.0 / (1.0 + alpha.x * 0.1);
   
    vec3 col = clamp(lighting * fog + glow, 0.0, 1.0);
    
	fragColor = vec4(col, 1.0);
}


