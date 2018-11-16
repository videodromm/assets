// https://www.shadertoy.com/view/lsS3W1

float Manhatan(vec2 dir)
{
	return abs(dir.x)+abs(dir.y);
}

vec3 sampleVoronoi(vec2 uv, float size)
{	
	float nbPoints = size*size;
	float m = floor(uv.x*size);
	float n = floor(uv.y*size);			
	
	vec3 voronoiPoint = vec3(0.);;			
	float dist2Max = 3.;
	const float _2PI = 6.28318530718;
	
	for (int i=-1; i<2; i++)
	{ 
		for (int j=-1; j<2; j++)
		{
			vec2 coords = vec2(m+float(i),n+float(j));																
			float phase = _2PI*(size*coords.x+coords.y)/nbPoints;
			vec2 delta = 0.25*vec2(sin(iTime+phase), cos(iTime+phase));
			vec2 point = (coords +vec2(0.5) + delta)/size;
			vec2 dir = uv-point;
			float dist2 = Manhatan(dir);										
			float t = 0.5*(1.+sign(dist2Max-dist2));
			vec3 tmp = vec3(coords/size,dist2);
			dist2Max = mix(dist2Max,dist2,t);
			voronoiPoint = mix(voronoiPoint,tmp,t);				
		}
	}	
	return voronoiPoint;		
}

void main(void)
{	
	vec2 uv = gl_FragCoord.xy/iResolution.y;
	vec3 voronoi = sampleVoronoi(uv,float(iSteps));
	gl_FragColor = vec4(exp(-5.*voronoi.z)*texture2D(iChannel0, voronoi.xy).xyz,1.);
}