// hexler https://vimeo.com/45629616

void main(void)
{
   vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
   float specx = 1.0*texture2D( iChannel0, vec2(0.25,5.0/100.0) ).x;
   float specy = 1.0*texture2D( iChannel0, vec2(0.5,5.0/100.0) ).x;
  vec2 p = vec2(sin(iTime) * 0.7, cos(iTime*0.7)) + vec2(specx,specy) * 0.1;
  float r = length(uv-p) * specy; 
  
  float phi = atan(uv.y-p.y,uv.x-p.x)+iTime*3.0*sin(iTime)*0.1; 
  float col = sin(100.0*r*specx+iTime)+cos(specx + phi + r * 10.5 + specy);
  
  gl_FragColor = vec4(vec3( col * specx,col,0.0 ),1.0);
}
