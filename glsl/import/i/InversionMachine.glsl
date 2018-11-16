// https://www.shadertoy.com/view/4dsGD7

// The Inversion Machine by Kali
const float InversionMachineWidth=.22;
const float InversionMachineScale=4.;
const float InversionMachineDetail=.001;

vec3 InversionMachineLightdir=-vec3(.2,.5,1.);

mat2 InversionMachineRotation;

float InversionMachineRand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float InversionMachineDE(vec3 p) {
	float t=iTime;
	float dotp=dot(p,p);
	p.x+=sin(t*40.)*.007;
	p=p/dotp*InversionMachineScale;
	p=sin(p+vec3(sin(1.+t)*2.,-t,-t*2.));
	float d=length(p.yz)-InversionMachineWidth;
	d=min(d,length(p.xz)-InversionMachineWidth);
	d=min(d,length(p.xy)-InversionMachineWidth);
	d=min(d,length(p*p*p)-InversionMachineWidth*.3);
	return d*dotp/InversionMachineScale;
}

vec3 InversionMachineNormal(vec3 p) {
	vec3 e = vec3(0.0,InversionMachineDetail,0.0);
	
	return normalize(vec3(
			InversionMachineDE(p+e.yxx)-InversionMachineDE(p-e.yxx),
			InversionMachineDE(p+e.xyx)-InversionMachineDE(p-e.xyx),
			InversionMachineDE(p+e.xxy)-InversionMachineDE(p-e.xxy)
			)
		);	
}

float InversionMachineLight(in vec3 p, in vec3 dir) {
	vec3 ldir=normalize(InversionMachineLightdir);
	vec3 n=InversionMachineNormal(p);
	float sh=1.;
	float diff=max(0.,dot(ldir,-n))+.1*max(0.,dot(normalize(dir),-n));
	vec3 r = reflect(ldir,n);
	float spec=max(0.,dot(dir,-r))*sh;
	return diff+pow(spec,20.)*.7;	
		}

float InversionMachineRaymarch(in vec3 from, in vec3 dir) 
{
	vec2 uv = gl_FragCoord.xy / iResolution.xy*2.-1.;
	uv.y*=iResolution.y/iResolution.x;
	float st,d,col,totdist=st=0.;
	vec3 p;
	float ra=InversionMachineRand(uv.xy*iTime)-.5;
	float ras=max(0.,sign(-.5+InversionMachineRand(vec2(1.3456,.3573)*floor(30.+iTime*20.))));
	float rab=InversionMachineRand(vec2(1.2439,2.3453)*floor(10.+iTime*40.))*ras;
	float rac=InversionMachineRand(vec2(1.1347,1.0331)*floor(40.+iTime));
	float ral=InversionMachineRand(1.+floor(uv.yy*300.)*iTime)-.5;
	for (int i=0; i<60; i++) {
		p=from+totdist*dir;
		d=InversionMachineDE(p);
		if (d<InversionMachineDetail || totdist>3.) break;
		totdist+=d; 
		st+=max(0.,.04-d);
	}
	vec2 li=uv*InversionMachineRotation;
	float backg=.45*pow(1.5-min(1.,length(li+vec2(0.,-.6))),1.5);
	if (d<InversionMachineDetail) {
		col=InversionMachineLight(p-InversionMachineDetail*dir, dir); 
	} else { 
		col=backg;
	}
	col+=smoothstep(0.,1.,st)*.8*(.1+rab);
	col+=pow(max(0.,1.-length(p)),8.)*(.5+10.*rab);
	col+=pow(max(0.,1.-length(p)),30.)*50.;
	col = mix(col, backg, 1.0-exp(-.25*pow(totdist,3.)));
	if (rac>.7) col=col*.7+(.3+ra+ral*.5)*mod(uv.y+iTime*2.,.25);
	col = mix(col, .5+ra+ral*.5, max(0.,3.-iTime)/3.);
	return col+ra*.03+(ral*.1+ra*.1)*rab;
}
void main(void)
{
   vec2 uv = iZoom * gl_FragCoord.xy/iResolution.xy;
   uv.x -= iRenderXY.x;
   uv.y -= iRenderXY.y;
	float t=iTime*.2;
	//vec2 uv = gl_FragCoord.xy / iResolution.xy*2.-1.;
	//uv.y*=iResolution.y/iResolution.x;
	uv.x = uv.x *2.-1.;
	uv.y = uv.y *2.-1.;
	vec3 from=vec3(0.,0.1,-1.2);
	vec3 dir=normalize(vec3(uv,1.));
	InversionMachineRotation=mat2(cos(t),sin(t),-sin(t),cos(t));
	dir.xy=dir.xy*InversionMachineRotation;
	float col=InversionMachineRaymarch(from,dir); 
	col=pow(col,1.25);

 gl_FragColor = vec4(vec3( col ),1.0);
}
