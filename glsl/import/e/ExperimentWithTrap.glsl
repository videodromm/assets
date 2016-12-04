// https://www.shadertoy.com/view/Msj3WR
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//parameters

//const int iterations=150;
const float bailout=1e5;
//const float iExposure=.85;
//const float saturation=.6;
//const float zoom=0.5;
//------------------ ------------------------------------------
// complex number operations
vec2 cadd( vec2 a, float s ) { return vec2( a.x+s, a.y ); }
vec2 cmul( vec2 a, vec2 b )  { return vec2( a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x ); }
vec2 cdiv( vec2 a, vec2 b )  { float d = dot(b,b); return vec2( dot(a,b), a.y*b.x - a.x*b.y ) / d; }
vec2 cinv( vec2 z)  { float d = dot(z,z); return vec2( z.x, -z.y ) / d; }
vec2 csqr( vec2 a ) { return vec2(a.x*a.x-a.y*a.y, 2.0*a.x*a.y ); }
vec2 csqrt( vec2 z ) { float m = length(z); return sqrt( 0.5*vec2(m+z.x, m-z.x) ) * vec2( 1.0, sign(z.y) ); }
vec2 conj( vec2 z ) { return vec2(z.x,-z.y); }
vec2 cpow( vec2 z, float n ) { float r = length( z ); float a = atan( z.y, z.x ); return pow( r, n )*vec2( cos(a*n), sin(a*n) ); }
vec2 cexp( vec2 z) {  return exp( z.x )*vec2( cos(z.y), sin(z.y) ); }
vec2 clog( vec2 z) {  float d = dot(z,z);return vec2( 0.5*log(d), atan(z.y,z.x)); }
vec2 csin( vec2 z) { float r = exp(z.y); return 0.5*vec2((r+1.0/r)*sin(z.x),(r-1.0/r)*cos(z.x));}
vec2 ccos( vec2 z) { float r = exp(z.y); return 0.5*vec2((r+1.0/r)*cos(z.x),-(r-1.0/r)*sin(z.x));}
// determinant
float EWTdet(vec2 a, vec2 b) { return a.x*b.y-a.y*b.x;}
//------------------------------------------------------------

vec2 EWTz0;
vec2 EWTzn;

void main(void)
{
    vec2 p= (gl_FragCoord.xy)/ iResolution.xy - 0.5;
    p.x*=iResolution.x/iResolution.y;
    p/=iZoom*0.5;
	
    vec2 q = (iMouse.xy)/ iResolution.xy-(iMouse.xy==vec2(0.,0.)?0.:0.5);
    q.x*=iResolution.x/iResolution.y;
    q/=iZoom*0.5;


    float k = 0.0;
    float dz;
    EWTzn=normalize(p);			
    vec2 z=p;
    EWTz0=p;
    vec2 trap = vec2(bailout);

    for (int i=0; i<iSteps; i++) {
        
        vec2 prevz=z;
		//z=f(z);
        //formulas
       int b = int(iBlendmode);
       switch ( b )
       {
       case 0: 
          z=csqr(z) + EWTz0;//Mandelbrot
          break;
       case 1: 
          z=(csqr(z+EWTz0)- z+ EWTz0)*0.5  ;
          break;
       case 2: 
          z=cinv(z+EWTz0)+ z-EWTz0;//Infinity
          break;
       case 3: 
          z=(z+cinv(z)+ EWTz0+cinv(EWTz0))*-.5  ;
          break;
       case 4: 
          z=(csqr(z-EWTz0)+ z+EWTz0)  ;
          break;
       case 5: 
          z=cdiv( EWTz0-z ,csin(EWTz0+0.5*z));//Santa Claus
          break;
       case 6: 
          z=cdiv( EWTz0-z ,csin(EWTz0-2.1*z));
          break;
       case 7: 
          z=cmul((cpow(clog(EWTz0-(23.0)*z),-1.95)),( -z+EWTz0 ));//Strange attractor
          break;
       case 8: 
          z=csin(z)+ EWTz0  ;
          break;
       case 9: 
          z=cinv(csqr(z)-EWTz0)+ z+EWTz0  ;
          break;

       default: // in any other case.
          z=cinv(csqr(z)-EWTz0)+ z+EWTz0;
          break;
       }
       		
        trap = min(trap,vec2(
            abs(EWTdet(z-EWTz0,z-q)),
            dot(z-q,z-q)
        ));
				
		dz=length(z-prevz);
        if(dz==0.)break;
        if(dz<1.0)dz=1.0/dz;
        if(dz>bailout){
            k = bailout/dz;
            z=(k*prevz+(1.-k)*z);
            float k1 =sqrt(sqrt(k))/float(i+1);
            if(dot(z,z)>0.)EWTzn=k1*normalize(z)+(1.-k1)*EWTzn;
            break;
        }
				                          
        k = 1./float(i+1);
        if(dot(z,z)>0.)EWTzn=k*normalize(z)+(1.-k)*EWTzn;
        			
    }

    vec3 color=0.2+0.8*abs(vec3(EWTzn.x*EWTzn.x,EWTzn.x*EWTzn.x,EWTzn.y))+0.2*sin(vec3(-0.5,-0.2,0.8)+log(abs(trap.x*trap.y*trap.y)));
	trap =sqrt(trap);
	//color=0.6*vec3(0.5-0.5*abs(sin(EWTzn.y)),0.5-0.5*abs(sin(EWTzn.x)),abs(sin(EWTzn.x+EWTzn.y)))+0.4*sin(vec3(-0.5,-0.2,0.8)+2.3+log(abs(trap.x*trap.y*trap.y)));
	trap=1.-smoothstep(0.05,0.07,trap);
    //color =mix( color,vec3(0.,0.8,1.0),trap.x);
    color =mix( color,vec3(1.),trap.y);
    color =mix( color,vec3(1.),1.-step(0.04,length(p-q)));
    color =mix( color,vec3(0.),1.-step(0.02,length(p-q)));       

    color=mix(vec3(length(color)),color,.6)*iExposure;
    gl_FragColor = vec4(color,1.0);
}