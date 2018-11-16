// https://www.shadertoy.com/view/ldsSRS
const float PI = 3.14159265358979323846264;
void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy;
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
   vec2 coord = uv - vec2(.5,.5);
   coord.y *= iResolution.y / iResolution.x;
   float angle = atan(coord.y, coord.x);
   float dist = length(coord);
   
   float brightness = .25 + .25 * 
      sin(48.0*angle + dist*PI + sin(angle*1.0)*(dist + (.5+.5*sin(-PI/2.0+iTime*PI))*mod(iTime,2.0)) * 2.0 * PI);
   brightness += .25 + .25 * sin(pow(dist,.5) / .707 * PI * 32.0 - iTime * PI * .5);
   if (dist < .01) brightness *= (dist / .01);

   gl_FragColor = vec4(brightness, brightness, brightness,1.0);
}
