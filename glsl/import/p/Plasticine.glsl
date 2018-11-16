// https://www.shadertoy.com/view/Md23DD

#define maxSteps 60.0
#define treshold 0.001
#define maxdist 20.0
#define pi acos(-1.)
#define oid1 1.0
#define oid2 2.0
#define shadowsteps 30.0
#define speed iTime*0.2332

vec2 rot(vec2 k, float t) {
	return vec2(cos(t)*k.x-sin(t)*k.y,sin(t)*k.x+cos(t)*k.y);
	}

float perlin(vec3 p) {
	vec3 i = floor(p);
	vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
	vec3 f = cos((p-i)*pi)*(-.5)+.5;
	a = mix(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
	a.xy = mix(a.xz, a.yw, f.y);
	return mix(a.x, a.y, f.z);
	}

vec3 texmap(vec3 p, vec3 n) {
	return n*perlin(p+atan(speed))*0.5;
}

vec2 map(vec3 p ) {
	float x=p.x+ cos(p.x+speed)*atan(p.z);
	float y=p.y+ cos(p.y+speed)*atan(p.x);
	float z= p.z*0.7;
	vec3 b= normalize( vec3(x,y,z) );	
	float d=(sin(p.x*40.0)*sin(p.y*40.0)*sin(p.z*40.0))*0.01;
	vec2 ret= vec2( length(p-b) - length( cos(perlin(p+speed)) ) -0.2 -d , oid1);
	return ret;
	}

vec3 cNor(vec3 p ) {
	vec3 e=vec3(0.001,0.0,0.0);
	return normalize(vec3( map(p+e.xyy).x - map(p-e.xyy).x, map(p+e.yxy).x - map(p-e.yxy).x, map(p+e.yyx).x - map(p-e.yyx).x ));
	}


float calcAO(vec3 pos, vec3 nor ){
	float totao = 0.0;
    float sca = 1.0;
    for( float aoi=0.0; aoi<5.0; aoi+=1.0 ) {
        float hr = 0.01 + 0.05*aoi;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        totao += -(dd-hr)*sca;
        sca *= 0.75;
    }
    return clamp( 1.0 - 4.0*totao, 0.0, 1.0 );
	}

float cShd(vec3 ro, vec3 rd, float k ) {
	float res = 1.0;
	for(float i=1.0; i<shadowsteps; i+=1.0){
		float f=shadowsteps/i;
        float h = map(ro + rd*f).x;
        if( h<0.001 ) { res=0.0; break; }
        res = min( res, k*h/f );
    }
    return res;
	}

void main(void)	{
	vec2 uv = iZoom * gl_FragCoord.xy / iResolution.xy; 
	uv.x -= iRenderXY.x;
	uv.y -= iRenderXY.y;
	//vec2 ps=(gl_FragCoord.xy/iResolution.xy);
	vec3 rd=normalize( vec3( (-1.0+2.0*uv)*vec2(1.0,1.0), 1.0));
	vec3 ro=vec3(0.0, 0.0, -3.0);
	vec3 lig=vec3(1.0,1.0,-1.0);

	vec4 m=iMouse*0.01;
	lig.xz=rot(lig.xz, m.x);
	lig.xy=rot(lig.xy, m.y);
	ro.xz=rot(ro.xz, m.x);
	ro.xy=rot(ro.xy, m.y);
	rd.xz=rot(rd.xz, m.x);
	rd.xy=rot(rd.xy, m.y);
	
	//march
	float f=0.0;
	vec2 t=vec2(treshold,f);
	for(float i=0.0; i<1.0; i+=1.0/maxSteps){
        t= map(ro + rd*t.x);
		f+=t.x;
		t.x=f;
		if( abs(t.x)<treshold || t.x>maxdist ) { t.y=0.0; break; }
		}
	//draw
	vec3 col = vec3(0.0);
	if (t.y>0.5) {
		
		lig=normalize(lig);
		vec3 pos = ro + rd*t.x;
		vec3 nor = cNor(pos);
		float ao = calcAO( pos, nor );
		
		float amb = clamp( 0.5+0.5*nor.y, 0.0, 1.0 );	
		float dif = clamp( dot( nor, lig ), 0.0, 1.0 );			
		float bac = clamp( dot( nor, vec3(-lig.x,lig.y,-lig.z)), 0.0, 1.0 );	

		float sh = cShd( pos, lig, 1.0 );	

		col = 0.20*amb*vec3(0.10,0.10,0.10)*ao;						
		col += 0.20*bac*vec3(0.15,0.15,0.15)*ao;					
		col += 1.90*dif*vec3(0.80,0.80,0.80);						

		float spe = sh*pow(clamp( dot( lig, reflect(rd,nor) ), 0.0, 1.0 ) ,16.0 );
		float rim = ao*pow(clamp( 1.0+dot(nor,rd),0.0,1.0), 2.0 );			

		vec3 oc;
		if (t.y == oid1) oc=texmap(pos, nor); 

		col =oc*col + vec3(1.0)*col*spe + 0.2*rim*(0.5+0.5*col);		
	} 
		

	gl_FragColor=vec4( col, 1.0);	
}