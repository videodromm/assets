// https://www.shadertoy.com/view/fsXSWN by Tater

float donut(vec3 p, vec2 t){ return length(vec2(length(p.xz)-t.x,p.y))-t.y;}
#define rot(a) mat2(cos(a),-sin(a),sin(a),cos(a))
#define MAX_DIST 250.0
#define STEP 64.0
float g1 = 0.;
vec2 Dist(vec3 p){
  vec2 a = vec2(donut(p,vec2(1,0.5)),2.0);
  vec2 b = vec2(length(p+vec3(0,1.0*3.0,0))-0.5,1.0);
  g1 += 0.01/(0.01+b.x*b.x);
  b = (b.x < a.x) ? b:a;
  return b;
}

vec2 Dist2(vec3 p){
  float t= mod(iTime,20.0);
 
  vec3 p2 = p;
  
  float modd = 42.0;
  vec3 id = floor((p2+modd*0.5)/modd);
  t+= id.x*2.0;
  t+= id.z*2.0;
  p2.yz*=rot(sin(t)*0.2);
  p2.y +=sin(id.x+t)*12.0;
  p2 = mod(p2+modd*0.5,modd)-modd*0.5;
  p2.xy*=rot(t*(mod(abs(id.x),3.0)-1.0));
  p2.zy*=rot(-t*0.5*(mod(abs(id.z),3.0)-1.0));
  for(int i = 0; i < 4; i++){
    p2 = abs(p2)-vec3(2,1,1);
    p2.xy *=rot(0.5);
  
    p2.zx *=rot(0.5);
  }
  
  return Dist(p2)*vec2(0.65,1.0);
}

void main(void)
{
vec2 uv = (gl_FragCoord.xy - .5*iResolution.xy) / iResolution.y;
 float t = mod(iTime,200.0);
  vec3 ro = vec3(t*3.0,0,-30);
  vec3 rd = normalize(vec3(uv,1.05));
  float dO = 0.0;
  float shad = 0.0;
  vec2 obj;
  for(float i = 0.0; i <STEP; i++){
    vec3 p = ro + rd*dO;
    obj = Dist2(p);
    dO += obj.x;
    if(obj.x <0.001|| dO>MAX_DIST){
      shad = i/STEP;
      break;
    }
  }
 
  vec3 col = vec3(0);
 
  if(obj.y == 1.0){
    shad= 1.0-shad;
    col = vec3(shad)*vec3(0.2,0.5,0.8);
  }
  if(obj.y == 2.0){
    shad= shad;
    col = vec3(shad)*vec3(0.8,0.2,0.9);
  }
  col += g1*vec3(0.2,0.5,0.8)*0.2;
  col = mix(col,vec3(0.235,0.075,0.369)*0.2,clamp(dO/MAX_DIST,0.0,1.0));
  gl_FragColor = vec4(min(col*1.6,1.0),1.0);

}
