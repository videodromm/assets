
uniform float iGlobalTime;
uniform sampler2D iChannel0;

in vec2 vertTexCoord0;

out vec4 fragColor;

void main() {
  
  vec2 pos = 2 * (vertTexCoord0 - vec2(0.5));
	vec4 tex = texture(iChannel0, pos);

  fragColor = tex;
}

