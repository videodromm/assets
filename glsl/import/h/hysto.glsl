// 


// https://www.shadertoy.com/view/4ssGzH

float FloorVal = 30.0;

float FloorMe(in float val)
{
	return floor(val*FloorVal)/FloorVal;
}

vec3 GetNearest(vec2 RayDir, vec2 uv)
{
	vec2 Decal = RayDir / iResolution.xy * 3.0;
	vec2 StartUV = uv;
	vec3 Final = vec3(0.0);
	float IsCol = 0.0;
	for(float i=0.0; i<80.0; ++i)
	{
		float Val = texture2D(iChannel0, vec2(FloorMe(StartUV.x), 0.0)).r;
		float Col = Val > StartUV.y ? 1.0 : 0.0;
		Final = mix(vec3(StartUV.x, Val, i/30.0), Final, IsCol);
		IsCol = max(Col, IsCol);
		StartUV += Decal;
	}
	return Final;
}

void main(void)
{
	
	vec3 Decal;
	Decal.x = texture2D(iChannel0, vec2(0.3, 0.0)).x * 5.0 - iTime * 0.6;
	Decal.y = texture2D(iChannel0, vec2(0.5, 0.0)).x * 5.0 - iTime * 0.4;
	Decal.z = texture2D(iChannel0, vec2(0.7, 0.0)).x * 5.0 - iTime * 0.3;
	
	float BaseX = 0.0;
	float BaseY = -0.05;
	vec2 uv = gl_FragCoord.xy / iResolution.xy;
		
	float DirDecal = texture2D(iChannel0, vec2(0.7, 0.5)).x * 1.0;
	vec2 Dir = normalize(uv-vec2(sin(iTime / 2.0)+ 0.5 + DirDecal,1.2));
	
	//vec2 Prev = GetNearest(vec2(-1.0, -0.7), uv - 1.0/iResolution.x);
	vec3 Cur = GetNearest(Dir, uv);
	vec3 Next = GetNearest(Dir, uv - vec2(2.0/iResolution.x, 0.0));
	
	
	float Lum = 1.2-abs(Cur.x-Next.x) * 100.0;	
	float Lum2 = Cur.z * 10.0 + 1.0-(Cur.y-uv.y-0.2) * 4.0;
	vec3 select = abs(fract(FloorMe(Cur.x)*vec3(3.0,4.0,1.0) + Decal)-0.5)*2.0;
	
	vec3 colour = select*Lum2*(1.0-Cur.z);
	
	float LumCol = 1.0-dot(max(colour,vec3(0.0)),vec3(0.333));
	
	float Stars = texture2D(iChannel0, vec2(abs(fract(uv.y + Decal.x))*0.5+0.5, 0.1)).x;
	float Stars2 = texture2D(iChannel0, vec2(abs(fract(uv.x - Decal.y))*0.5+0.5, 0.0)).x;
	
	vec3 StarsColor = mix(vec3(1.0, 0.6, 0.0), vec3(0.2, 0.2, 1.0), Stars);
	vec3 StarsColor2 = max(vec3(0.0), mix(StarsColor, StarsColor.yzx, Stars2)*vec3(2.0)-vec3(0.5));
	gl_FragColor = vec4(max(colour, vec3(-0.2))+StarsColor2*LumCol, 1.0);
}