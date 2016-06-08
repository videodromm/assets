#ifdef GL_ES
precision highp float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec3 spectrum;
varying vec2 v_texcoord;

void main(void) 
{
    vec2 uv = -1. + 2. * v_texcoord;
    uv.x += spectrum.y * 4.4 * tan(time + uv.y );
    float col = abs(sin(time + uv.x * 20.0));
    gl_FragColor = vec4(col,0,col,1.0);
}

