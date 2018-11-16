// https://www.shadertoy.com/view/4d2cRd
//Created by pthextract in 2017-Mar-15

// from: http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
// just a bit compacted
#define it float(x)/float(mod(iTime,15.)+1.)*pi

float sdCap( vec3 p, vec3 a, vec3 b)
{
    return length((p-=a)-(b-=a)*clamp(dot(p,b)/dot(b,b), 0.0, 1.0 ));
}

void main( void )
{
    float pi=acos(-1.)*2.;
    vec2 ir=iResolution.xy;
	vec2 uv = gl_FragCoord.xy/iResolution.x /ir -.5;
    uv/=0.01;uv.x/=ir.y/ir.x;
  
    vec3 l[99];
    int steps=16;//iFrame/10;
    float mini=1.;
    for (int x=0;x<steps;)
    {
    l[x]=vec3(-66.*sin(iDate.w+it),-44.*cos(iDate.w+it),1.);
    l[++x]=vec3(66.*sin(iDate.w+it),44.*cos(iDate.w+it),1.);
    mini=(min(mini,.8*sdCap(vec3(uv,1),l[--x],l[++x])));
 	
    }
    
    gl_FragColor=1.-vec4(pow(mini,0.5),pow(mini,0.1),pow(mini,1.5),1.);
    //o.g+=clamp( (1.-length(vec3(i/33.,1)-vec3(0,0,.2))-.1)*1.9,.0,.9);//df sphere
}
