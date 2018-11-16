// hexler https://vimeo.com/54385033

void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
 float specx = 1.0*texture2D( iChannel0, vec2(0.25,5.0/100.0) ).x;
  float specy = 1.0*texture2D( iChannel0, vec2(0.5,5.0/100.0) ).x;
  float specz = 1.0*texture2D( iChannel0, vec2(0.7,5.0/100.0) ).x;

  uv = 2.0 * (uv) - 1.0;
  float r = length(uv); float p = atan(uv.y/uv.x); uv = abs(uv);
  float col = 0.0;float amp = (specx+specy+specz)/3.0;
  uv.y += sin(uv.y*3.0*specx-iTime/5.0*specy+r*10.);
  uv.x += cos((iTime/5.0)+specx*30.0*uv.x);
  col += abs(1.0/uv.y/30.0) * (specx+specz)*15.0;
  col += abs(1.0/uv.x/60.0) * specx*8. ;
     
  gl_FragColor = vec4(vec3( col ),1.0);
}
