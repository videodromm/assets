// https://www.shadertoy.com/view/Xs2GWz
float pix(vec2 p)
{
    p=abs(p);
    vec2 q;
    q.x=float(int(p.x+0.5));
    q.y=float(int(p.y+0.5));
    vec2 r=p-q;
    if(max(abs(r.x),abs(r.y))>0.45) return iColor.b;
	float v = sin(length(q)*0.5-iTime*5.0);//5.0);
	if(v>0.0) return iColor.r;
	else return iColor.g;
}

void main(void)
{
	float width = iZoom / min( iResolution.x, iResolution.y );
	vec2 control = mix( iResolution.xy * 0.5, iMouse.xy, 1.0 - step( iMouse.z, 0.0 ) );
	vec2 uv = ( gl_FragCoord.xy - control ) * width * iRatio;//25.0;
	
	gl_FragColor = vec4(pix(uv)*iColor.r,pix(uv)*iColor.g,pix(uv)*iColor.b,iAlpha);
}