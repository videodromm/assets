// https://www.shadertoy.com/view/WsGBRd
mat2 r(float a){
    float c=cos(a),s=sin(a);
    return mat2(c,s,-s,c);
}
vec3 p(float i)
{
    return .5+.5*cos(2.*3.1415*(1.*i+vec3(0.,.33,.67)));
}
void main(void)
{
    vec2 uv = (gl_FragCoord.xy -.5*iResolution.xy) / iResolution.y;
    uv*=1.;
    float bpm = sqrt(fract(-length(uv)+iTime*130./60.*.5));
    //uv+=vec2(cos(iTime),sin(iTime))*.1;
    uv*=r(iTime*.1)*+bpm;
    uv= abs(uv)-.1;
    float f = 1.01+(sin(iTime)*.02+0.02);//sin(iTime+texture1D(spectrum1,.1).r*100.)*2.+2.5;
        uv = vec2(uv.x/(1.-f),uv.y/(1.-f));
    uv = vec2( f*uv.x/ (uv.x*uv.x+uv.y*uv.y+1.),f*uv.y/ (uv.x*uv.x+uv.y*uv.y+1.));
uv+=vec2(cos(iTime),sin(iTime))*.1;
   uv*=r(iTime*.1);
    float d = max(abs(fract(uv.y*10.)-.5+.2)-.015,0.);
    d= smoothstep(0.25,0.19,d);
    float e = max(abs(fract(uv.x*10.)-.5+.2)-.015,0.);
    e=smoothstep(0.25,0.19,e);
    d=d+e;
    vec3 col = vec3(d);
    col = col*p(length(bpm));
    //col = texture2D(spectrum1,vec2(uv.x*.5+.75,0)).rrr*10.;
    gl_FragColor = vec4(col,1.0);
}
