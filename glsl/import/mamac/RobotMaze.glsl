// https://www.shadertoy.com/view/MtS3zc
//thx iq for distance functions: http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

struct camera {
    vec3 position;
    vec3 direction;
};

const vec3 worldUp = vec3(0.0,-1.0,0.0);
const float minStep = 0.1;
const float maxStep = 90.0;
const float delta = 0.01;
const float damping = 0.9;
const int numSteps = 99;

mat3 getViewMatrix (vec3 t, vec3 d, vec3 k)
{
	vec3 z = normalize(d);
    vec3 x = normalize(cross(d,k));
    vec3 y = normalize(cross(z,x));
    return mat3(x,y,z);
}

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

vec3 opRep( vec3 p, vec3 c )
{
    vec3 q = mod(p,c)-0.5*c;
    return q ;
}

float distf (vec3 pos)
{
    pos = opRep(pos, vec3(2.0));
    float boxes = sdBox(pos, vec3(0.5));
    
    boxes = min(boxes, sdBox(pos+vec3(0.75,0,0), vec3(0.25)));
    boxes = min(boxes, sdBox(pos+vec3(-0.75,0,0), vec3(0.25)));
    
    boxes = min(boxes, sdBox(pos+vec3(0,0.75,0), vec3(0.25)));
    boxes = min(boxes, sdBox(pos+vec3(0,-0.75,0), vec3(0.25)));
    
    boxes = min(boxes, sdBox(pos+vec3(0,0,0.75), vec3(0.25)));
    boxes = min(boxes, sdBox(pos+vec3(0,0,-0.75), vec3(0.25)));
    return boxes;
}

vec3 normal (vec3 p)
{
    vec2 dm = vec2(delta, 0.0);
	return normalize(vec3(
    	distf(p+dm.xyy) - distf(p-dm.xyy),
        distf(p+dm.yxy) - distf(p-dm.yxy),
        distf(p+dm.yyx) - distf(p-dm.yyx)
    ));
}

float castRay ( vec3 pos, vec3 dir, out vec3 norm)
{
    float dist = minStep;
    for(int step = 0; step < numSteps; step++)
    {
        norm = pos + dir*dist;
        float normL = distf(norm);
        if(normL > delta || dist > maxStep){
            dist += normL*damping;
        }
    }
    return dist;
}

vec4 render(in vec2 xy)
{
    
    camera myCam = camera( 
    	vec3(0,0,2.*iGlobalTime),
   		vec3(iMouse.x/iResolution.x*3.0-1.5,iMouse.y/iResolution.y*3.0-1.5,1.0)
	);
    
    mat3 viewMatrix = getViewMatrix(myCam.position, myCam.direction, worldUp);
	vec3 rayDir = viewMatrix * normalize(vec3(xy, 1.0));
    vec3 ro = vec3(0.0,0.0,0.0);
    float didHitTerrain = castRay(myCam.position, rayDir, ro);
    if(didHitTerrain < maxStep){
        vec4 colToRtn = vec4(vec3(0.5),1.0);
        vec3 nml = normal(ro);
        vec3 textureRGB = texture(iChannel0,cross(nml,myCam.direction).xz).xyz;
        colToRtn.xyz = textureRGB * 5./distance(myCam.position, ro); //* cross(nml,vec3(0,1,0.5));
        return colToRtn;
    }
    else{
    	return vec4(0);
    }
}

void main(void)
{
	vec2 uv = fragCoord.xy / iResolution.xx - 0.5;
    fragColor = render(uv);
}
