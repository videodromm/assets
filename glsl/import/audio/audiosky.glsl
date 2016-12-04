// https://www.shadertoy.com/view/Msf3DX
const float MAX_DIST = 10.0;

float lowFreq = 0.0;
float midFreq = 0.0;
float bassEnergy = 0.0;

float myShape( vec3 p )
{
  float pr = length(p);
  float r = 2.0;
  float lowdisp =  0.1*sin(p.y*80.0*lowFreq);
  float middisp =  0.1*cos(p.x*80.0*midFreq);
  float highdisp = 0.0;
  float disp = lowdisp + middisp + highdisp;
  return pr - r -5.0*lowFreq -disp;
}

float myFloor( vec3 p )
{
  float pd = p.y+2.0;
  return pd + bassEnergy*(sin(p.x*5.0)+sin(p.z*5.0));
}

float fdist( vec3 p )
{
  float dfloor = myFloor(p);
  float dmyshape = myShape(p);
  return min(dfloor, dmyshape);
}

vec3 fnorm( vec3 p )
{
  vec2 dd = vec2(0.0001,0.0);
  return normalize(vec3(
    fdist(p+dd.xyy) - fdist(p-dd.xyy),
    fdist(p+dd.yxy) - fdist(p-dd.yxy),
    fdist(p+dd.yyx) - fdist(p-dd.yyx)
    ));
}

vec4 skyColor( vec2 pos )
{
  float fftx = pos.x*0.2+0.5;
  fftx -= mod(fftx,0.02);
  float vol = texture2D(iChannel0, vec2(fftx,0.4)).x;
  //float line = 10.0*min(max(vol - pos.y, 0.0),1.0);
  float line = 5.0*min(max(vol - pos.y, 0.0),1.0);
  //vec3 c = vec3(line*0.5,line, lowFreq*10.0)*0.5;
  vec3 c = vec3(lowFreq*20.0,line, line*0.15)*0.5;
  return vec4(c,1.0);
}

void main()
{
  lowFreq = texture2D(iChannel0, vec2(0.1,0.4)).x/10.0;
  midFreq = texture2D(iChannel0, vec2(0.4,0.4)).x/10.0;
  bassEnergy = texture2D(iChannel0, vec2(0.1,0.0)).x/10.0;
  
  // Cast the ray into the scene
  vec2 pos = 2.0*gl_FragCoord.xy/iResolution.yy;
  pos += vec2(-2.4,-1.0);
  vec3 ro = vec3(0.0,0.0,-5.0);
  vec3 rd = normalize(vec3(pos.xy, -4.0)-ro);
  
  // Marching
  float d=0.0,fd;
  int steps = 0;
  for (int i=0;i<iSteps;i++) {
    fd = fdist( ro+d*rd );
    d += max(fd,0.01);
    if (fd<0.0) break;
	steps = i;
  }
  
  gl_FragColor = skyColor(pos);
   
}
