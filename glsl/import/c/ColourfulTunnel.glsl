// https://www.shadertoy.com/view/MdfSWf
float tau = atan(1.)*8.;

void main(void) {
    float time = iTime;
    vec2 p = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.5);
    p.x = p.x * 1.6;       
	p.x -= iRenderXY.x;
	p.y -= iRenderXY.y;
		vec4 col;
		float x,y;
		x = atan(p.x,p.y);
		y = 1./length(p.xy);
		col.x = sin(x*5. + sin(time)/3.) * sin(y*5. + time);
		col.y = sin(x*5. - time + sin(y+time*3.));
		col.z = -col.x + col.y * sin(y*4.+time);
		col = clamp(col,0.,1.);
		col.y = pow(col.y,.5);
		col.z = pow(col.z,.1);
		gl_FragColor = 1.-col*length(p.xy);
}


