// https://www.shadertoy.com/view/ldX3zr

vec2 HRCenter = vec2(0.5,0.5);
float HRSpeed = 0.035;
float HRInvAr = iResolution.y / iResolution.x;

void main(void)
{
   vec2 uv = 2.0 * iZoom * (gl_FragCoord.xy/iResolution.xy- 0.25);
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
vec3 col = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0).xyz;
   
     vec3 texcol;
			
	float x = (HRCenter.x-uv.x);
	float y = (HRCenter.y-uv.y) *HRInvAr;
		
	//float r = -sqrt(x*x + y*y); //uncoment this line to symmetric ripples
	float r = -(x*x + y*y);
	float z = 1.0 + 0.5*sin((r+iGlobalTime*HRSpeed)/0.013);
	
	texcol.x = z;
	texcol.y = z;
	texcol.z = z;
	
 gl_FragColor = vec4(col*texcol,1.0);
}
