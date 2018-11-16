// https://www.shadertoy.com/view/4slXWn

#define f(a,b)sin(50.3*length(gl_FragCoord.xy/iResolution.xy*4.-vec2(cos(a),sin(b))-3.))
void main(){float t=iTime;gl_FragColor=vec4(f(t,t)*f(1.4*t,.7*t));}