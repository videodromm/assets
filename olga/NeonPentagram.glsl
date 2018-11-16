// https://www.shadertoy.com/view/MlcXDB
#define PI 3.14159265359
#define TWO_PI 6.28318530718

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float polygon(vec2 st, int numVertices) {
  float a = atan(st.x, st.y) + PI;
  float r = TWO_PI / float(numVertices);

  return cos(floor(.5+a/r)*r-a)*length(st);;
}

void main() {

    vec2 st = (gl_FragCoord.xy / iResolution.xy) * 2. - 1.;
    st.x *= iResolution.x/iResolution.y;

    float d = polygon(st, 5);
    float f = mod(fract(d * 7.0) + iTime / 4.0, 1.0);
    d = smoothstep(0.0, f, d);

    vec3 c = hsv2rgb(vec3(mod(d + iTime / 8.0 + (1.0 - length(st) / 4.0), 1.0), 1.0, 0.9));
    c = mix(c, vec3(0, 0, 0), length(st) * 0.3);

    fragColor = vec4(c,1.0);
}


