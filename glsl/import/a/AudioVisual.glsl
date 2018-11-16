// https://www.shadertoy.com/view/MsBSzw
void main(void)
{
    vec2 p = (gl_FragCoord.xy-.5*iResolution.xy)/min(iResolution.x,iResolution.y);			
    vec3 c = vec3(0.0);
	vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
	uv.x *= float(iResolution.x )/ float(iResolution.y);
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;    
	float wave = texture2D( iChannel0, vec2(uv.x,0.75) ).x;

    for(int i = 1; i<20; i++)
    {
        float time = 2.*3.14*float(i)/20.* (iTime*.9);
        float x = sin(time)*1.8*smoothstep( 0.0, 0.15, abs(wave - uv.y));
        float y = sin(.5*time) *smoothstep( 0.0, 0.15, abs(wave - uv.y));
        y*=.5;
        vec2 o = .4*vec2(x*cos(iTime*.5),y*sin(iTime*.3));
        float red = fract(time);
        float green = 1.-red;
        c+=0.016/(length(p-o))*vec3(red,green,sin(iTime));
    }
    gl_FragColor = vec4(c,1.0);
}
//2014 - Passion
//References  - https://www.shadertoy.com/view/Xds3Rr
//            - tokyodemofest.jp/2014/7lines/index.html
