// https://www.shadertoy.com/view/ldB3D1 
// BPM.frag 
// iRatio = BPM
void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy - 0.5;
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
	vec3 col = vec3(0.0);
	float h = fract( 0.25 + 0.5*iChannelTime[0]*iRatio/60.0 );
	float f = 1.0-smoothstep( 0.0, 1.0, h );
	f *= smoothstep( 4.5, 4.51, iChannelTime[0] );
	float r = length(uv-0.0) + 0.2*cos(25.0*h)*exp(-4.0*h);
	f = pow(f,0.5)*(1.0-smoothstep( 0.5, 0.55, r) );
	float rn = r/0.55;
	col = mix( col, vec3(0.4+1.5*rn,0.1+rn*rn,0.50)*rn, f );
	col = mix( col, vec3(1.0), smoothstep(  0.0,  3.0, iChannelTime[0] )*exp( -1.00*max(0.0,iChannelTime[0]- 2.5)) );
	col = mix( col, vec3(1.0), smoothstep( 16.0, 18.0, iChannelTime[0] )*exp( -0.75*max(0.0,iChannelTime[0]-19.0)) );
  gl_FragColor = vec4(col,1.0);
}