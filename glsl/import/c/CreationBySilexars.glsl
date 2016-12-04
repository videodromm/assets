// https://www.shadertoy.com/view/XtBGDD

// From https://www.shadertoy.com/view/XsXXDn

#define t iGlobalTime
#define r iResolution.xy
#define m iMouse.xy

#define PI 3.14159265359

/**
 * Interpolate (cos) between 'min' and 'max' with a defined 'period'
 */
float stepper(float time, float period, float min, float max)
{
    return cos(mod(time, period) / period * 2. * PI) * (max - min) / 2. + (max + min) / 2.;
}
void main(void)
{
    /* position */
    vec2 p = gl_FragCoord.xy/r;
        
    // follow mouse
    if (m.x == .0 && m.y == .0)
    {
        p.x-= 0.5;
        p.y-= 0.5;
    }
    else
    {
        p.x-= m.x/r.x;
        p.y-= m.y/r.y;
    }

    p.x*= r.x/r.y;

    float l = length(p);
    
    
    /* cycling values */
    // color shift
    float dz = stepper(t, 10.9, -.1, .1);
    // size
    float ds = stepper(t, 15.4, -2., 2.);
    // pattern
    float dp = stepper(t, 20.6, 5., 10.);
    // intensity
    float di = stepper(t, 8.2, .008, .06);
    // direction
    float dd = stepper(t, 12.1, -.2, .2);
    // attenuation
    float dl = stepper(t, 19.3, l, 1./l);
    
    /* original values */
    //dz = .07;
    //ds = 1.;
    //dp = 9.;
    //di = .01;
    dd = 2.; // glitches, why ?
    //dl = 1./l;
    
    
    /* compute colors */
    vec3 c;
    float z = t;
    
    for (int i=0; i<3; i++)
    {
        z+= dz;
        float a = (sin(z)+ds) * abs(sin(l*dp - z*dd));
        vec2 uv = gl_FragCoord.xy/r + p / l * a;
        c[i] = di / length(abs(mod(uv, 1.) - .5));
    }
    
    gl_FragColor = vec4(c*dl, t);
}
