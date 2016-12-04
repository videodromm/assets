// https://www.shadertoy.com/view/lt33zl
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}



void main(void) {   
 
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 uv2 = (uv-vec2(0.5)+vec2(0.,0.002*sin(15.*uv.x+iGlobalTime*8.34)))*1.01+vec2(0.5);
    vec3 col  = texture2D(iChannel0, uv2).xyz;

    if(iGlobalTime<0.2)
    {
        if (abs(uv.y-0.5)<0.01){col.b=1.;}
    }
    else
    {
        vec3 def = texture2D(iChannel1, uv*1.+2.3*vec2(cos(iGlobalTime*1.2+uv.x),sin(iGlobalTime*1.2))).xyz;
        def-=vec3(0.5);
        def*=30./ iResolution.x;


        vec3 colA = texture2D(iChannel0, uv+def.xy).xyz;
        vec3 colB = texture2D(iChannel0, uv+def.yz).xyz;
        
        if (col.b<0.8)
        {
            if (colA.b>0.6 && colB.b<0.3)
            {
                vec3 colD=palette(iGlobalTime*0.2,vec3(0.5),vec3(0.5),vec3(1.0),vec3(0.,0.33,0.66));
                col=vec3(colD.x,colD.y,1.);
            }
        }
       
    }    
     
    float aa=1.-pow(uv.y-0.5,2.);
    col*=aa;

    gl_FragColor = vec4(col.xyz,1.0);
}