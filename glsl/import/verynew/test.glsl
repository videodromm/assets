void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
vec2 uv = (fragCoord - .5*iResolution.xy) / iResolution.y;

	fragColor = vec4(1);
}
