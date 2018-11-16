// https://www.shadertoy.com/view/4ssSRM
const float PI = 3.14159265358979323846264;
const float lspPId2 = PI/2.0;

void main(void)
{
   vec2 uv = -1.0 + 2.0 * iZoom * gl_FragCoord.xy/iResolution.xy;
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
  uv.y *= iResolution.y/iResolution.x;
vec3 col = vec3( 0.0 );
  // controls arms for each channel (2 layers)
  vec3 n1_3 = vec3(-6.0,5.0,3.0);
  vec3 m1_3 = vec3(3.0,11.0,-12.0);

  // controls zoom effect for each layer
  vec3 n4_6 = 10.0*iTime*vec3(.1,.11,.111);
  vec3 m4_6 = 10.0*iTime*vec3(.2,.22,.222);

  // color width for each channel
  vec3 n7_9 = vec3(0.5);
  vec3 m7_9 = vec3(0.5);

  // color center for each channel
  vec3 n10_12 = vec3(0.5);
  vec3 m10_12 = vec3(0.5);

  // Layer mix
  float mixv = cos(iTime*.1)*0.5+0.5;

  float a = atan(uv.x, uv.y);
  float d = log(length(uv));
  // two layer version...
  col = mix(sin(d * n1_3 + vec3(a,-a-lspPId2,a+lspPId2) - n4_6) * n7_9 + n10_12, 
                          sin(d * m1_3 + vec3(a,-a-lspPId2,a+lspPId2) - m4_6)*sin(a*6.0) * m7_9 + m10_12, 
                          mixv);
  gl_FragColor = vec4(col,1.0);
}
