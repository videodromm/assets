uniform float iGlobalTime;
uniform sampler2D iChannel0;

in vec2 vertTexCoord0;

out vec4 fragColor;

void main() {
  	vec2 uv = vertTexCoord0;
	vec4 tex = texture(iChannel0, uv);
	 
	fragColor = vec4(tex.r, 0.3, tex.b, 1.0) ;
}
