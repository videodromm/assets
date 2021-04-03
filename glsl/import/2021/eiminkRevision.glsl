// https://www.shadertoy.com/view/fsjGDD by eimink 

const int STEPS = 64;
const float E = 0.0001;
const float FAR = 40.0;
 
vec3 glow = vec3(0);
float fft1 = 0.;
float fftx = 0.;
 
void rot(inout vec2 p, float a) {
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}
 
float sphere (vec3 p, float s)
{
  return length(p)-s;
}
 
float box(vec3 p, vec3 r)
{
  vec3 d = abs(p) - r;
  return length(max(d,0.) + min(max(d.x, max(d.y,d.z)),0.0));
}

float tun2(vec3 p){
    vec3 pp = p;
    vec3 t = vec3(2.) - abs(vec3(length(pp.xz),length(p.xy),1.0));
    return max(t.x,t.y)+.1;
    return min(max(t.x,t.y),0.0);
}

float scene(vec3 p)
{
  vec3 pp = p;
  float m = fft1*5.;
  float ms = fft1*.1;
  for (int i = 0; i < 5; ++i)
  {
    pp = abs(pp) - vec3(1.,4.,5.);
    rot(pp.xy, iTime+fftx*.5);
    rot(pp.yz, iTime*0.1+fftx*.1);
  }
  float a = box(pp, vec3(1.,.4,4.));
  float b = sphere(pp, m);
  rot(pp.xz,iTime);
  float c = box(pp, vec3(6.,8.,12.));
  rot(p.xz,m);
  rot(p.xy,iTime+ms);
  float d = abs(box(p,vec3(3.+sin(m*4.),.5,.5)));
  float e = abs(box(p,vec3(1.5,.5,3.+cos(ms))));
  float f = abs(box(p,vec3(1.5,3.+sin(m)+tan(ms*2.),.5)));
  float h = min(tun2(pp),.7);
  float g = max(h,min(f,min(d,e)));
  glow += vec3(.8,.4,.2)*0.025/(0.09+abs(a));
  glow += vec3(.4,.8,.1)*0.01/(0.9+abs(c));
  glow += vec3(.1,.2,.8)*0.1/(0.01+abs(g+h));
  return max(g,min(c,min(a,b)));
}
 
vec3 march (vec3 ro, vec3 rd)
{
  vec3 p = ro;
  float t = E;
  vec3 col = vec3(0);
  for (int i = 0; i < STEPS; ++i) {
    float d = scene(p);
    t += d;
    if ( d < E || t > FAR) {
      break;
    }
    p += rd*d;
  }
  if (t < FAR)
  {
    col = normalize(p)*vec3(.2,.2,.6)*.9;
  }
  return col;
}

void main( void )
{
    vec2 uv = vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);
    vec2 q = -1.0+2.0*uv;
  q.x *= iResolution.x/iResolution.y;
 
  int tx = int(abs(uv.x*512.0));
  fft1 = texelFetch( iChannel0, ivec2(5,0), 0 ).x * 0.9; 
  fftx = texelFetch( iChannel0, ivec2(tx,0), 0 ).x* 300.0; 
 
  vec3 cp = vec3(0.,0.,10.);
  vec3 ct = vec3(0.,0.,0.);
   
  vec3 cf = normalize(ct-cp);
  vec3 cr = normalize(cross(vec3(0.,1.,0.),cf));
  vec3 cu = normalize(cross(cf,cr));
  vec3 rd = normalize(mat3(cr,cu,cf)*vec3(q,radians(60.0)));
  rot(cp.xy,iTime);
  vec3 c = march(cp,rd);
  c += glow;
     
  fragColor = vec4(c,1);

}