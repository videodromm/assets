// https://www.shadertoy.com/view/4ls3RH
// returns the mouse coords in ([0-1], [0-1]), or (.5, .5) if the mouse is uninitialized
vec2 mouse() 
{
    return all(greaterThan(iMouse.xy, vec2(0,0))) ? (iMouse.xy / iResolution.x) : vec2(.5, .5);
}

// Hashes a vec2 and return a random point
vec2 hash(vec2 p)
{
    vec2 q = vec2( dot(p,vec2(127.1,311.7)), 
				   dot(p,vec2(269.5,183.3)) );
	return fract(sin(q)*43758.5453);
}

// Position of the feature point (ie: random point) in the grid cell.
// g is the coord of the lower left corner of the grid cell
vec2 feature_pos(vec2 g)
{
    return g + hash(g);
}

// Calculates the norm of v using the mouse.y value to introduce some variation.
// Note that if mouse.y = 1.0, we get the manhattan distance, and with 
// mouse.y = 2.0, we have the Euclidean norm.
// As mouse.y grows larger, the formula tends to max(abs(v.x), abs(v.y))
float norm(vec2 v)
{
    float n = mouse().y * 10.0;
    return pow(pow(abs(v.x), n) + pow(abs(v.y), n), 1.0 / n);
}

float voronoi(vec2 uv, float cell_count)
{
    vec2 p = uv * cell_count;
    vec2 g = floor(p);
   
    float dist = 2.0; // technically, sqrt(2.0) would be enough
    for (float i = -1.0; i <= 1.0; i++) {
        for (float j = -1.0; j <= 1.0; j++) {
    		vec2 feature = feature_pos(g + vec2(i,j));
    		float d = norm(feature - p);
            dist = min(dist, d);
        }
    }
	return dist;
}

void main(void)
{    
    float m = mouse().x * 20.0; 
	vec2 uv = gl_FragCoord.xy / iResolution.xx;
    float v1 = voronoi(uv, 10.0);
    float v2 = voronoi(uv+vec2(v1,v1), m);

    
	gl_FragColor = vec4(v1, 0, v2, 1.0);
}

