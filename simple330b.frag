uniform float iGlobalTime;
uniform sampler2D iChannel0;

in vec2 vertTexCoord0;

out vec4 fragColor;

void main() {
  
  vec2 pos = 2 * (vertTexCoord0 - vec2(0.5));
float y = sin(pos.x + iGlobalTime * 3.1415 * 2.0);

  float color = max(0, (0.1 - (y - pos.y) * (y - pos.y)) * 10);
  	vec2 uv = vertTexCoord0;
	vec4 tex = texture(iChannel0, uv);

  fragColor = vec4(color, tex.g, color, 1);
}
