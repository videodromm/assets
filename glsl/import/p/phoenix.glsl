// https://www.shadertoy.com/view/4d2XR1
// original by nimitz https://www.shadertoy.com/view/lsSGzy#, slightly modified
 
	#define ray_brightness 10.
	#define gamma 5.
	#define ray_density 4.5
	#define curvature 15.
	#define red   4.
	#define green 1.0
	#define blue  .3 

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// !!!!!!!!!!!!! UNCOMMENT ONE OF THESE TO CHANGE EFFECTS !!!!!!!!!!!
// MODE IS THE PRIMARY MODE
#define MODE normalize
// #define MODE 

#define MODE3 *
// #define MODE3 +

#define MODE2 r +
// #define MODE2 

// #define DIRECTION +
#define DIRECTION -

#define SIZE 0.1

#define INVERT /
// #define INVERT *
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

float noise( in vec2 x )
{
	return texture2D(iChannel0, x*.01).x; // INCREASE MULTIPLIER TO INCREASE NOISE
}

// FLARING GENERATOR, A.K.A PURE AWESOME
mat2 m2 = mat2( 0.80,  0.60, -0.60,  0.80 );
float fbm( in vec2 p )
{	
	float z=2.;       // EDIT THIS TO MODIFY THE INTENSITY OF RAYS
	float rz = -0.05; // EDIT THIS TO MODIFY THE LENGTH OF RAYS
	p *= 0.25;        // EDIT THIS TO MODIFY THE FREQUENCY OF RAYS
	for (int i= 1; i < 6; i++)
	{
		rz+= abs((noise(p)-0.5)*2.)/z;
		z = z*2.;
		p = p*2.*m2;
	}
	return rz;
}

void main(void)
{
	float t = DIRECTION iTime*.33; 
	vec2 uv = gl_FragCoord.xy / iResolution.xy-0.5;
	uv.x *= iResolution.x/iResolution.y;
	uv*= curvature* SIZE;
	
	float r = sqrt(dot(uv,uv)); // DISTANCE FROM CENTER, A.K.A CIRCLE
	float x = dot(MODE(uv), vec2(.5,0.))+t;
	float y = dot(MODE(uv), vec2(.0,.5))+t;
 
    float val;
    val = fbm(vec2(MODE2 y * ray_density, MODE2 x MODE3 ray_density)); // GENERATES THE FLARING
	val = smoothstep(gamma*.02-.1,ray_brightness+(gamma*0.02-.1)+.001,val);
	val = sqrt(val); // WE DON'T REALLY NEED SQRT HERE, CHANGE TO 15. * val FOR PERFORMANCE
	
	vec3 col = val INVERT vec3(red,green,blue);
	col = 1.-col; // WE DO NOT NEED TO CLAMP THIS LIKE THE NIMITZ SHADER DOES!
    float rad= 30. * texture2D(iChannel1, vec2(0,0)).x; // MODIFY THIS TO CHANGE THE RADIUS OF THE SUNS CENTER
	col = mix(col,vec3(1.), rad - 266.667 * r); // REMOVE THIS TO SEE THE FLARING
	
	gl_FragColor = vec4(col,1.0);
}