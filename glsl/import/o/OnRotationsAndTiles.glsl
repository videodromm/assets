// https://www.shadertoy.com/view/lsjGWG
/* The screen is divided into tiles.
   Each tile is divided into areas painted with different colors.
   Areas are determined by the polar angle inside the tile.
*/

#define ORATPI 3.14159265358979323846

// Choose a preset. (from 0 to 3, for now)
//int ORATPresetNo = 0;

// PARAMETERS
float ORATNumTile = 4.0; // number of tiles in vertical direction
float ORATMaxCol = 1.0;
float ORATMinCol = 0.25;
const float ORATNumFrames = 4.0; // number of frames to be used in motion blur
// change these at presets
float ORATNumDiv;
float ORATOverallSpeed;
bool ORATConstantSpeed; // if true rotates continuously w/o stopping
float ORATStopAngle; // if ORATConstantSpeed is false, stop every this angle

// hyberbolic tangent function
float ORATTanh(float x) {
	return (exp(x)-exp(-x))/(exp(x)+exp(-x));
}

// modulus function for integers
int ORATIMode(int n, int m) {
    return n-m*(n/m);
}

// returns the color of a division
float ORATColN(int n) {
    return ORATMinCol + float(n+1)*(ORATMaxCol-ORATMinCol)/float(ORATNumDiv);
}

// anti-alias(?) between divisions
float ORATColorVal(float angle) {
    float antiAlias = 0.03; // higher smoother 

    float divAngle = 2.0*ORATPI / ORATNumDiv; // angle per division
    int n = int(angle/divAngle); // the division number. 0 -> ORATNumDiv - 1
    //float smooth = smoothstep( float(n)*divAngle-antiAlias, float(n)*divAngle+antiAlias, angle-0.5*divAngle );
    //return ORATColN(n) + ( ORATColN(ORATIMode(n+1,int(ORATNumDiv)))-ORATColN(n))*smooth;
	return ORATColN(n);
}

void main(void)
{
    vec2 uv = 2.0 * (gl_FragCoord.xy/iResolution.xy- 0.5);
	vec2 mo = iMouse.xy / iResolution.y;
	
    float side = 1.0/ORATNumTile;
	
    vec2 pos = mod(uv, vec2(side)) - vec2(0.5*side); // generate tiles

	float i = floor(ORATNumTile*uv.x);
    float j = floor(ORATNumTile*uv.y);
	
    float im = i-2.*(i/2.);
    float jm = j-2.*(j/2.);
    float im2 = im*2.-1.; // for alternating directions 
    float jm2 = jm*2.-1.;
    float ijm = i+j-2.*((i+j)/2.);

    float angle = atan(pos.x, pos.y);
	float t = iTime;
	int ORATPresetNo = int(mod(iSteps,4.0));	
	// change the phase and speed of different tiles individually as function of their coordinates	
	if(ORATPresetNo==0) { // 
		angle += - i*ORATPI + j*ORATPI; // adjust phase as a function of tile coordinate
		ORATOverallSpeed = 1.64;
		t *= ORATOverallSpeed;
		ORATNumDiv = 4.0;
		ORATConstantSpeed = false;
		ORATStopAngle = ORATPI/4.0;		
	} else if(ORATPresetNo == 1) { // simplest
		angle += 0.0;
		ORATOverallSpeed = 2.0;
		t *= ORATOverallSpeed;
		ORATNumDiv = 2.0;
		ORATConstantSpeed = true;
		ORATStopAngle = ORATPI/4.0;
	} else if(ORATPresetNo == 2) { // 
		angle += mod(j,2.0)*ORATPI;
		ORATOverallSpeed = mod(i,2.0)*6.0-3.0; // adjust the rotation speed of an individual tile
		t *= ORATOverallSpeed;
		ORATNumDiv = 3.0;
		ORATConstantSpeed = false;
		ORATStopAngle = ORATPI/6.0;
	} else if(ORATPresetNo == 3) { // 
		angle += 0.0*ORATPI;
		ORATOverallSpeed = (i-3.5)*(j-1.5)*2.0;
		t *= ORATOverallSpeed;
		ORATNumDiv = 4.0;
		ORATConstantSpeed = false;
		ORATStopAngle = ORATPI/2.0;
	}	
	
	// motion blur
	float col = 0.0;
	float inNumFrames = 1.0/ORATNumFrames;
	for(float m=0.0; m<ORATNumFrames; m+=1.0) {
		float t1;
		if(ORATConstantSpeed) {
			t1 = t;
		} else {
			t1 = (floor(t + 0.02*m) + smoothstep(0.1, 0.9, fract(t + 0.02*m
)) )*ORATStopAngle;
		}
		float an = mod(angle + t1, 2.0*ORATPI);
		//col += inNumFrames*ORATColorVal( an ); // each frame has the same weight in motion blur
		col += ORATColorVal( an )*(m+1.0)/(ORATNumFrames*(ORATNumFrames+1.0)*0.5); // frames have different weights
	}
	
	// vignette
	//vec2 vig = (gl_FragCoord.xy - 0.5*iResolution.xy) / iResolution.y;
	//col *= smoothstep( 1.8, 0.5, length(vig) );
  gl_FragColor = vec4(vec3( col, col, col),1.0);
}
