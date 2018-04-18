// https://www.shadertoy.com/view/XdsGWs
// #### realistic display of star in Hubble images ################
//                            Fabrice NEYRET 15 oct 2013
// toggles:
//    T:      tune (R)GB  vs   Planck spectrum(T)
//    SPACE:  tune 1GB  vs RG1

// see also https://www.shadertoy.com/view/Xty3zc

#define NB_STARS 200
#define PERS 1          // perspective

#define SCALE 40.
const float star_luminosity = 1e3;
vec3 star_color = vec3(1.,.3,.1)*star_luminosity;
#define PI 3.1415927
vec2 FragCoord, R;

//--- filter integration (l0..l1) on black body spectrum(T) ---------
float F(float x) 
{ return (6.+x*(6.+x*(3.+x)))*exp(-x); }
float IntPlanck(float T,float lambda1,float lambda0) 
{
	const float A=1.1, B=1./1.05;
	float C0 = 0.014387770, C=C0/(B*T);
	T = 1.; // normalised spectrum better for display :-)
	return 100.*A/B*pow(100.*T/C0,4.)*( F(C/lambda1) - F(C/lambda0) );
}

// --- Planck black body color I.spectrum(Temp) -----------------------
vec3 Planck(float T) {
	return vec3(
		IntPlanck(T,.7e-6,.55e-6),   // red filter
        IntPlanck(T,.55e-6,.49e-6),  // green filter
        IntPlanck(T,.49e-6,.4e-6)    // blue filter
		)*1e-14;
}

//--- draw one star:  (I.filter(color)).dirac * PSF ------------------ 
vec3 draw_star(vec2 pos, float I) {
	// star out of screen
    const float margin = .2;
	if (pos!=clamp(pos,vec2(-margin),R/R.y+margin)) return vec3(0.);
	
	pos -= FragCoord.xy/iResolution.y; 
	
// Airy spot = (2BesselJ(1,x)/x)^2 ~ cos^2(x-2Pi/4)/x^3 for x>>1
// pixels >> fringes -> smoothed Airy ~ 1/x^3
	float d = length(pos)*SCALE;
	
	vec3 col, spectrum = I*star_color;
#if 1
	col = spectrum/(d*d*d);
#else
	col = spectrum*(1.+.323*cos(d/4.+PI/2.))/(d*d*d);
#endif
	
// 2ndary mirror handles signature (assuming handles are long ellipses)
	d = length(pos*vec2(50.,.5))*SCALE;
	col += spectrum/(d*d*d);
	d = length(pos*vec2(.5,50.))*SCALE;
	col += spectrum/(d*d*d);

	return col;
}

// --- utility functions ----------------------------------
float rnd ( int n ) { return fract(sin(float(n)*543.21)*43758.5453);} 
float srnd( int n ) { return -1.+2.*fract(sin(float(n)*543.21)*43758.5453);} 

// --- main -----------------------------------------
void main(void) {
	vec3 col = vec3(0.0);
	FragCoord = fragCoord;
    R = iResolution.xy;
    float t = iGlobalTime;
	
	// --- camera
	vec3 cam = vec3(.3*sin(12.+t+.3*sin(2.2*t)),
					.3*sin(5.+.5*t-.2*cos(t)+sin(.31*t)),
					.3*sin(-2.+.6*t+.16*sin(.26*t))-3.);
	float a = .7*sin(.1*t+.02*sin(.33*t) );
	float c=cos(a),s=sin(a);
	mat2 m = mat2(c,-s, s,c), im=mat2(c,s, -s,c);
	//mat3 m = mat3(c,-s,0., s,c,0., 0.,0.,1.);
	
	// --- display stars 
	
		// background
		vec2 uv = im*(fragCoord.xy/iResolution.y)+cam.xy;

		// do stars
		for (int i=0; i<NB_STARS; i++) {
			// random position, intensity(=surf), temperature(->color)
			vec3 pos = vec3(3.*srnd(6*i), 3.*srnd(6*i+1), 2.*srnd(6*i+3));
			float I = .02*exp(-15.*rnd(6*i+4));
			star_color = Planck(40000.*exp(-3.*rnd(6*i+5)));

			// project to screen coords
			pos = pos-cam;
			pos.xy = m*pos.xy;
#if PERS // perspective
			pos.xy /= pos.z;
#endif
			if (pos.z>0.)
				col += draw_star(pos.xy+vec2(.8,.5),I/(pos.z*pos.z));
		}


	
	fragColor = vec4(col,1.0);
}
