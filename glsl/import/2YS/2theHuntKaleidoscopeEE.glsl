// https://www.shadertoy.com/view/XtSGzz

void main( void )
{
    vec2  u = iZoom * gl_FragCoord.xy / iResolution.xy , p = -1. + 2. * u;
  float t = iTime, 
          a = atan(p.y, p.x) , 
          r = length(p) , 
          c = .7 * cos(t + 7. * a);
  gl_FragColor = vec4(
        texture2D(
            iChannel2, 
            vec2(7. * a / 3.14, -t + sin(7. * r + t) + c) * .5)) * (.5 + .5 * (sin(t + 7. * r) + c));

}
