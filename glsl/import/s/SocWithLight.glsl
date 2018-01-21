// https://www.shadertoy.com/view/4s23zW

// SoC with Light by eiffie (added a light to the Sphere of Confusion script)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define SocLightTime iGlobalTime*0.5
#define SocLightSize iResolution

float SocLightFocalDist=1.0,SocLightAperture=0.025,SocLightFudgeFactor=1.0,SocLightShadowCone=0.2;

bool SocLightbColoring=false;
vec3 SocLightmCol;
const int SocLightIters=3;

float SocLightScale=4.0*0.9000;
vec3 SocLightOffset=vec3(0.8700,0.6300+sin(SocLightTime*0.1)*0.1,0.3100)*2.0;//menger
//float SocLightScale=2.0;vec3 SocLightOffset=vec3(1.0,0.0,0.0);//sierpinski
float SocLightPsni=pow(SocLightScale,-float(SocLightIters));
float SocLightDE(in vec3 z){//menger sponge by menger
	float flr=z.y+SocLightScale*0.4;
	for (int n = 0; n < SocLightIters; n++) {
		z = abs(z);
		if (z.x<z.y)z.xy = z.yx;
		if (z.x<z.z)z.xz = z.zx;
		if (z.y<z.z)z.yz = z.zy;
		z = z*SocLightScale - SocLightOffset*(SocLightScale-1.0);
		if(z.z<-0.5*SocLightOffset.z*(SocLightScale-1.0))z.z+=SocLightOffset.z*(SocLightScale-1.0);
	}
	if(SocLightbColoring)SocLightmCol+=vec3(0.5)+sin(z)*((flr<0.1)?0.0:0.4);
	z=abs(z)-vec3(0.1,0.1,0.88)*SocLightScale;
	float d=min(flr,max(z.x,max(z.y,z.z))*SocLightPsni);
	return d;
}

float SocLightSegment(vec3 p, vec3 p0, vec3 p1, float r){vec3 v=p1-p0;v*=clamp(dot(p-p0,v)/dot(v,v),0.0,1.0);return distance(p-p0,v)-r;}//from iq

float SocLightPixelSize;
float SocLightCircleOfConfusion(float t){//calculates the radius of the circle of confusion at length t
	return max(abs(SocLightFocalDist-t)*SocLightAperture,SocLightPixelSize*(1.0+t));
}
mat3 SocLightLookAt(vec3 fw,vec3 up){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,normalize(up)));return mat3(rt,cross(rt,fw),fw);
}
float SocLightLinstep(float a, float b, float t){return clamp((t-a)/(b-a),0.,1.);}// i got this from knighty and/or darkbeam
float SocLightRand(vec2 co){// implementation found at: lumina.sourceforge.net/Tutorials/Noise.html
	return fract(sin(dot(co*0.123,vec2(12.9898,78.233))) * 43758.5453);
}
float SocLightFuzzyShadow(vec3 ro, vec3 rd, float lightDist, float coneGrad, float rCoC){
	float t=0.01,d=1.0,s=1.0;
	for(int i=0;i<iSteps;i++){
		if(t>lightDist)continue;
		float r=rCoC+t*coneGrad;//radius of cone
		d=SocLightDE(ro+rd*t)+r*0.66;
		s*=SocLightLinstep(-r,r,d);
		t+=abs(d)*(0.8+0.2*SocLightRand(gl_FragCoord.xy*vec2(i)));
	}
	return clamp(s,0.0,1.0);
}

void main() {
	SocLightPixelSize=1.0/SocLightSize.y;
	float tim=SocLightTime*0.5;
	vec3 ey=vec3(cos(tim),sin(tim*1.3)*0.35,sin(tim*0.87))*1.5;
	vec3 ro=mix(vec3(0.2,0.0,0.25),ey,length(ey));
	vec3 rd=SocLightLookAt(-ro,vec3(0.0,1.0,0.0))*normalize(vec3((2.0*gl_FragCoord.xy-SocLightSize.xy)/SocLightSize.y,2.0));
	vec3 lightPos=vec3(cos(tim),0.0,sin(tim*0.5))*2.0;
	vec3 lightColor=vec3(1.0,0.5,0.25)*2.0,lp=ro;
	vec4 col=vec4(0.0);//color accumulator
	float t=0.0;//distance traveled
	for(int i=1;i<20;i++){//march loop BL: 70 is too slow
		if(col.w>0.9 || t>7.0)continue;//bail if we hit a surface or go out of bounds
		float rCoC=SocLightCircleOfConfusion(t);//calc the radius of CoC
		float d=SocLightDE(ro)+0.5*rCoC;
		if(d<rCoC){//if we are inside add its contribution
			vec3 p=ro-rd*abs(d-rCoC);//back up to border of CoC
			SocLightmCol=vec3(0.0);//clear the color trap, collecting color samples with normal deltas
			SocLightbColoring=true;
			vec2 v=vec2(rCoC*0.5,0.0);//use normal deltas based on CoC radius
			vec3 N=normalize(vec3(-SocLightDE(p-v.xyy)+SocLightDE(p+v.xyy),-SocLightDE(p-v.yxy)+SocLightDE(p+v.yxy),-SocLightDE(p-v.yyx)+SocLightDE(p+v.yyx)));
			SocLightbColoring=false;
			if(N!=N)N=-rd;//if we failed to find any direction assume facing camera
			vec3 L=lightPos-p;//the direction to the light
			float lightDist=length(L);//how far is the light
			L/=lightDist;//normalize the direction
			float lightStrength=1.0/(1.0+lightDist*lightDist*0.1);//how much light is there?
			vec3 scol=SocLightmCol*0.1666*(0.2+0.4*(1.0+dot(N,L)))*lightStrength;
			scol+=0.25*pow(max(0.0,dot(reflect(rd,N),L)),32.0)*lightColor*lightStrength;
			scol*=SocLightFuzzyShadow(p,L,lightDist,SocLightShadowCone,rCoC);
			lightDist=SocLightSegment(lightPos,lp,ro,0.01);//for the bloom find the nearest distance between ray and lightPos
			col.rgb+=lightColor/(1.0+lightDist*lightDist*100.0)*(1.0-clamp(col.w,0.0,1.0));//add bloom (should use rCoC)
			lp=ro;//save this point for next SocLightSegment calc
			float alpha=SocLightFudgeFactor*(1.0-col.w)*SocLightLinstep(-rCoC,rCoC,-d);//calculate the mix like cloud density
			col+=vec4(scol*alpha,alpha);//blend in the new color
		}
		d=abs(SocLightFudgeFactor*d*(0.8+0.2*SocLightRand(gl_FragCoord.xy*vec2(i))));//add in noise to reduce banding and create fuzz
		ro+=d*rd;//march
		t+=d;
	}//mix in background color
	vec3 scol=vec3(0.4)+rd*0.1;
	float lightDist=SocLightSegment(lightPos,lp,ro+rd*7.0,0.01);//one last light bloom calc
	scol+=lightColor/(1.0+lightDist*lightDist*100.0);
	col.rgb+=scol*(1.0-clamp(col.w,0.0,1.0));

	gl_FragColor = vec4(clamp(col.rgb,0.0,1.0),1.0);
}
