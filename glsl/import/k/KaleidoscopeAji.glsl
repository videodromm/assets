// https://www.shadertoy.com/view/4sfGzs
vec2 kaleido(vec2 uv)
{
  float th = atan(uv.y, uv.x);
  float r = pow(length(uv), .9);
  float f = 3.14159 / 3.5;

  th = abs(mod(th + f/4.0, f) - f/2.0) / (1.0 + r);
  //th = sin(th * 6.283 / f);

  return vec2(cos(th), sin(th)) * r * .1;
}

vec2 transform(vec2 at)
{
  vec2 v;
  float th = .02 * iTime;
  v.x = at.x * cos(th) - at.y * sin(th) - .2 * sin(th);
  v.y = at.x * sin(th) + at.y * cos(th) + .2 * cos(th);
  return v;
}

vec4 scene(vec2 at)
{

  return texture2D(iChannel1, transform(at) * 2.0);
}

void main( void )
{
  vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
   //uv.x -= iRenderXY.x;
   //uv.y -= iRenderXY.y;
  uv.x = mix(-1.0, 1.0, uv.x);
  uv.y = mix(-1.0, 1.0, uv.y);
  uv.y *= iResolution.y / iResolution.x;
  gl_FragColor = scene(kaleido(uv));
}
