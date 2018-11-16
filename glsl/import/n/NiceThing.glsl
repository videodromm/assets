// https://www.shadertoy.com/view/4sSGzK

/*****************************************************/
/*  uncomment/comment below to customize shader      */
/*****************************************************/

//#define interactive
#define ver2
#define useao
#define clouds

/*****************************************************/

#define marchsteps 4
#define c1 0.1
#define c2 0.2
#define c3 0.3
#define numiter 2
float scale= -5.34642;
vec3 from;

/****************************************************/
#ifdef ver2
float DE1(vec3 pos) {
   	vec3 z=pos-from;
   	float r=dot(pos-from,pos-from)*pow(length(z),2.0);
   	return (1.0-smoothstep(0.0,0.01,r))*0.01;
}
#endif

float DE2(vec3 pos)  {
	vec4 p = vec4(pos,1.0);
	vec4 c=vec4(c1,c2,c3,0.5)-0.5; 

	for (int i=0 ;i<numiter ; i++) {
		p.xyz=clamp(p.xyz, -1.0, 1.0) * 2.0 - p.xyz;		
	   	float r2 = dot(p.xyz,p.xyz);
	   	if(r2<2.0) p*=(1.0/r2); else p*=0.5;				
    	p=p*scale+c;
   	}
   	return length(p.xyz)/p.w;
}

/****************************************************/
/****************************************************/
#ifdef clouds
float hash(float n) {
	return fract(sin(n)*43758.5453);
}

float noise( in vec3 x ) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
}

float DEclouds(vec3 p) {
	float d = -p.y -1.5;
	vec3 q = p - vec3(0.1, 0.1, 0.1)*iTime;
	float f;
	f = 0.5 * noise(q); q*=2.02;
	f += 0.25 * noise(q); q *= 2.03;
	f += 0.125 * noise(q); q *= 2.01;
	f += 0.0625 * noise(q);
	d += 3.0*f;
	d = clamp(d,0.0, 1.0);
	return d;
}
#endif
/****************************************************/
/****************************************************/

vec3 map(vec3 pos) {
#ifdef clouds
	float fog=DEclouds(pos);
#else
	float fog=0.0;
#endif
	
#ifdef ver2
	float d1=DE1(pos);   
   	float d2=DE2(pos);
	return vec3( max(d1,d2), 1.0, fog);
#else
 	float d1=DE2(pos);
	return vec3( d1, 1.0, fog);
#endif
}

/****************************************************/

vec3 tex3D( vec3 pos, vec3 nor, sampler2D s) {
	return texture2D( s, pos.yz).xyz*abs(nor.x)+
	       texture2D( s, pos.xz).xyz*abs(nor.y)+
	       texture2D( s, pos.xy).xyz*abs(nor.z);
}

#ifdef useao
float cao(vec3 pos, vec3 nor){
	float sca = 1.0;
	float totao = 0.0;
	for (int i=0; i<5; i++) {
        	float hr = 0.01 + 0.05*float(i);
        	vec3 aopos =  nor * hr + pos;
        	float dd = map(aopos).x;
        	totao += -(dd-hr)*sca;
        	sca *= 0.75;
    	}
    return clamp( totao, 0.0, 1.0 );
}
#endif

float csh(vec3 ro, vec3 rd, float t, float k ) {
    float res = 1.0;
    for( int i=0; i<10; i++ ) {
    	float h = map(ro + rd*t).x;
        res = min( res, k*h/t );
        t += h;
	}
    return clamp(res,0.0,1.0);
}

vec3 normal(vec3 p ) {
	vec3 e=vec3(0.01,-0.01,0.0);
	return normalize( vec3(	e.xyy*map(p+e.xyy).x +	e.yyx*map(p+e.yyx).x +	e.yxy*map(p+e.yxy).x +	e.xxx*map(p+e.xxx).x));
}


#ifdef interactive
void rot( inout vec3 p, vec3 r) {
	float sa=sin(r.y); float sb=sin(r.x); float sc=sin(r.z);
	float ca=cos(r.y); float cb=cos(r.x); float cc=cos(r.z);
	p*=mat3( cb*cc, cc*sa*sb-ca*sc, ca*cc*sb+sa*sc,	cb*sc, ca*cc+sa*sb*sc, -cc*sa+ca*sb*sc,	-sb, cb*sa, ca*cb );
}
#endif

void interact( inout vec3 ro, inout vec3 rd, inout vec3 lig) {
#ifdef interactive
	vec2 mp=iMouse.xy/iResolution.xy;
	rot(ro,vec3(mp.x,mp.y,0.0));
	rot(lig,vec3(mp.x,mp.y,0.0));
#else	
	ro.z=ro.z+cos(iTime*0.155)*0.47;
	ro.x=ro.x+cos(iTime*0.215)*0.74;
	ro.y=ro.y+cos(iTime*0.110)*0.92;
	lig.z=lig.z+cos(iTime*0.155)*0.47;
	lig.x=lig.x+cos(iTime*0.215)*0.74;
	lig.y=lig.y+cos(iTime*0.110)*0.92;	
#endif
}

void main( void ) {	
    vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;	
	vec3 ta = vec3(0.0, 0.0, 0.0);
	vec3 ro =vec3(0.0, 0.0, -0.01);
	vec3 lig=normalize(vec3(0.0, 3.0, 1.0));
	
	interact(ro, ta, lig);	

	vec3 cf = normalize( ta - ro );
    vec3 cr = normalize( cross(cf,vec3(0.0,1.0,0.0) ) );
    vec3 cu = normalize( cross(cr,cf));
	vec3 rd = normalize( p.x*cr + p.y*cu + 2.5*cf );	
	
	from=ro;	
	scale+= sin(iTime*0.2)*0.5-0.1;	
	
	//march
#ifdef clouds
	vec4 fog = vec4(0,0,0,0);
#endif
	vec3 r=vec3(0.0);
	float f=0.0;
	for(int i=0; i<marchsteps; i++) {
		r=map(ro+rd*f);
		if( r.x<0.0 ) break;
#ifdef clouds
	if (fog.w < 0.99 || r.z>0.0) {
		float dif = clamp((r.z - map((ro+rd*f)+0.3*lig).z)/0.6, 0.0, 1.0);
		vec3 lin = vec3(1.0)*1.35 + 0.45*vec3(0.7)*dif;
		vec4 tfog = vec4(r.z);
			 tfog.xyz= mix(1.15*vec3(1.0), vec3(0.7), r.z) * lin;
		tfog.w *= 0.35;
		tfog.xyz *= tfog.w;
		fog = fog + tfog*(1.0 - fog.w);		
	}		
#endif		
		f+=r.x;
	}
	r.x=f;
	if( r.x>30.0 ) r.y=0.0;

#ifdef clouds
	fog.xyz /= (0.001 + fog.w);
	fog=clamp(fog, 0.0, 1.0);
#endif	
	
	//process	
	vec3 col=vec3(1.0);
	if (r.y>0.5) {
		//obj
		vec3 ww=ro+rd*r.x;
		vec3 nor=normal(ww);
		
						
		vec3 rgb=tex3D(ww,nor,iChannel0);

//		vec3 rgb=vec3(1.0, 0.8, 0.7);

		
		float amb =0.2*ww.y;
		float dif =0.7*clamp(dot(lig, nor), 0.0,1.0);
		float bac =0.4*clamp(dot(nor,-lig), 0.0,1.0);
//	float rim =0.3*pow(1.+dot(nor,rd), 5.0);
//	float spe =0.5*pow(clamp( dot( lig, reflect(rd,nor) ), 0.0, 1.0 ) ,32.0 );
#ifdef useao
		float ao=cao(ww, nor);
#endif
		float sh=csh(ww, lig, 0.01, 1.0);
				//amb+dif+bac-ao+sh
#ifdef useao
	     col  = (amb+dif+bac-ao+sh)*vec3(1.);
#else		
	     col  = (amb+dif+bac+sh)*vec3(1.);
#endif		
		 col *= rgb;
//		 col += (rim+spe)*vec3(1.);
		
	}	
#ifdef clouds
	col = mix(col, fog.xyz, r.z*0.8);
#endif	

	
	//post 
	col*=exp(0.09*r.x);
	col*=0.8;

	gl_FragColor=vec4( col, 1.0);
}


