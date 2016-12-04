// hexler https://vimeo.com/45629616
#define specx iFreq0/100.0
#define specy iFreq1/100.0
#define specz iFreq2/100.0

void main(void)
{
   vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
  //vec2 uv = (gl_FragCoord.xy / iResolution.xy) ;
  vec2 p = vec2(sin(iGlobalTime) * 0.7, cos(iGlobalTime*0.7)) + vec2(specx,specy) * 0.1;
  float r = length(uv-p) * specy; 
  
  float phi = atan(uv.y-p.y,uv.x-p.x)+iGlobalTime*3.0*sin(iGlobalTime)*0.1; 
  float col = sin(100.0*r*specx+iGlobalTime)+cos(specx + phi + r * 10.5 + specy);
  
  gl_FragColor = vec4(vec3( col * specx,col,0.0 ),1.0);
}
