// https://www.shadertoy.com/view/ldKcRW

void main(void)
{
  	vec2 uv = fragCoord.xy / iResolution.y;
  
    float a = atan( uv.x, uv.y );
    float w = texture(iChannel0, vec2( abs(a)/6.28,1.0)).x;

    vec2 direction = uv - .5;
    uv *= length(direction)*w;
    
    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(iTime*uv.xyx+vec3(0,2,4));

    // Output to screen
    fragColor = vec4(col,1.0);
}
