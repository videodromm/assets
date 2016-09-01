// https://www.shadertoy.com/view/Xtc3Wj

// gigatron France for Shadertoy 2016 !
// simple pattern and color bypass ;
void main(void)
{
	vec2 uv= gl_FragCoord.xy/iResolution.xy;    
    float a=0.4; // color bypass factor !
    // simple patern
	float scl  = mod((gl_FragCoord.y + gl_FragCoord.y) * 0.5, 2.0);
          scl *= mod((gl_FragCoord.x + gl_FragCoord.x) * 0.5, 2.0);
          scl *= mod((gl_FragCoord.x + gl_FragCoord.y) * 0.5, 2.0);
        
    
    vec3 tx=texture(iChannel0,uv).stp; // s'il te plait !
    
    if (tx.r>a*1.7 || tx.g>a*2. || tx.b>a*2.) { 
    	fragColor = scl * vec4(tx, 1.0);
    } else
    {
    	fragColor = scl * vec4(0);
    }
	
	
   // variant  
   // :fragColor = scl * vec4(tx.rgb/fract(uv.y), 1.0);
   
}
