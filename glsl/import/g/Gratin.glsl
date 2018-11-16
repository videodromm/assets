void main(void) {   
  vec2 c = gl_FragCoord.xy / iResolution.xy-vec2(0.5);

  const float eps = 0.1;
  const float r = 0.8;
  const float l = 0.5;
    float roundness = 0.6*mod(iTime,50.0)/8.0;

  vec3 color = iBackgroundColor;
  vec3 linecol = iColor;
  vec3 outbuff;

  float s = smoothstep(-0.1,0.1,sin(20.0*(c.x+c.y)))-0.5;
  color.xyz = clamp(color.xyz+color.xyz*s,vec3(0),vec3(1));


  float d   = pow(abs(c.x/l),roundness)+pow(abs(c.y/l),roundness)-r;
  float sdc = step(0.0,d);
  float sdl = smoothstep(eps-0.1,eps+0.1,abs(d));

  outbuff = mix(iBackgroundColor,vec3(0),sdc);
  gl_FragColor = vec4(mix(linecol,outbuff,sdl),1.0);
}
