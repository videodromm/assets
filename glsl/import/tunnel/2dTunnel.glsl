// functions begin
// https://www.shadertoy.com/view/4sX3RM
float TunnelRand(vec2 co){
    return 0.5+0.5*fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 Tunnel(vec2 uvTunnel)
{
	float j = sin(uvTunnel.y*1.0*3.14+uvTunnel.x*0.0+iTime*5.0);
	float i = sin(uvTunnel.x*10.0-uvTunnel.y*2.0*3.14+iTime*10.0);
	
	float p1 = clamp(i,0.0,0.2)*clamp(j,0.0,0.2);
	float n = -clamp(i,-0.2,0.0)-0.0*clamp(j,-0.2,0.0);
	
	return 5.0*(vec4(1.0,0.25,0.125,1.0)*n*TunnelRand(uvTunnel) + vec4(1.0,1.0,1.0,1.0)*p1);
	
}
// functions end
// https://www.shadertoy.com/view/4sX3RM
 void main(void)
{
	vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy;
   uv = -0.8 + iZoom * uv * 3.0 ;
	
	uv += vec2(sin(iTime*0.4), sin(-iTime*0.2));


	float r = sqrt(dot(uv,uv));
	float a = atan(uv.y*(0.3+0.2*cos(iTime*2.0+uv.y)),uv.x*(0.3+0.2*sin(iTime+uv.x)))+iTime;
	
   	vec2 uvTunnel;
    uvTunnel.x = iTime + 1.0/( r + .01);
    uvTunnel.y = 4.0*a/3.1416;

	gl_FragColor = Tunnel(uvTunnel)*r*r*r*r*2.0;
}
