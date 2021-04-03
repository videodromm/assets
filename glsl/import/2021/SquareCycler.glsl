// https://www.shadertoy.com/view/fs23Wh by Tater
#define rot(a) mat2( cos(a),-sin(a),sin(a),cos(a) )
#define pi 3.141592653
float smoothtrig(float b, float wv){
return sqrt((1.0+b*b)/(1.0+b*b*wv*wv))*wv;
}


float rects(vec2 uv, float t)
{
    uv*=rot(t);
    vec2 cent = vec2(sin(t*3.5)+1.5,cos(t*3.5)+1.5);
    vec2 d = abs(uv*cent);
    
    float o = step(max(d.x,d.y),0.3);
          o -= step(max(d.x,d.y),0.15);        
return o;
}
void main( void )
{
    float t = iTime;
    vec2 R = iResolution.xy;
    vec2 uv = (fragCoord.xy-.5*R.xy)/R.y;
    vec2 uv2 = uv;
    //uv = abs(uv);
    //uv*=length(uv)*3.0;
    float c = abs(10.0*sin(iTime)) +3.0;
    vec3 col= 0.5*vec3(30.,14.,256.)/256.*length(uv*0.6);

    for(int i = 0; i<int(c); i++){
        float fi  = float(i);
        uv2*=rot(-fi*-0.03);
        uv*=1.0+(fi/c)*0.1;
        col.r += (1.3/c)*rects(uv2,t+fi*0.1)*2.0;
        col.g += (1.3/c)*rects(uv2,t+fi*0.1);
        
      
    }
    fragColor = vec4(col,1.0);
}