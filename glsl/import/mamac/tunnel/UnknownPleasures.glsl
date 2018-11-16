// https://www.shadertoy.com/view/4sVyWR
#define LINEWIDTH 0.38
#define H 35.

#define WAVEHEIGHT 6.6
#define WIDTH 0.6

float random (in float x) {
    return fract(sin(x)*
        43758.5453123);
}


float noise (in float x) {
    float i = floor(x);
    float f = fract(x);

    float a = random(i);
    float b = random(i + 1.);

    float u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u);
}

#define OCTAVES 3
float fbm (in float x) {
    float value = 0.0;
    float amplitude = .5;
    float frequency = 0.;
    
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(x);
        x *= 2.;
        amplitude *= .7;
    }
    return value;
}

void main(void)
{
  	
    vec2 st = (2.*fragCoord.xy - iResolution.xy) / iResolution.y;
    
    st.y *= 45.;
    
    
    float val = 0.;
    if(abs(st.x) < WIDTH){
        float env = pow(cos(st.x/WIDTH*3.14159/2.),4.9);
        float i = floor(st.y);
        for (float n = max(-H,i-6.); n <= min(H, i); n++) {
            float f = st.y - n;
            float y = f - 0.5;
            y -= WAVEHEIGHT 
                * pow(fbm(st.x*10.504 +n*432.1 + 0.5*iTime), 3.)
                * env
                + (fbm(st.x*25.+n*1292.21)-0.32)*2. * 0.15;
            float grid = abs(y);
                val += (1.-smoothstep(0., 0.5,grid));
            	//val = grid;
            if(y < 0.)
                break;
        }
    }
    //val *= step(-WIDTH+0.01,st.x) - step(WIDTH-0.01,st.x);

        

    

    fragColor = vec4(val);
}
