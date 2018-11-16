// https://www.shadertoy.com/view/MdsXDl
const float PI = 3.14159265358979323846264;
vec2 q;

float circle(float rad, float size){

    return (1.0-smoothstep(rad+size,rad+size+0.01, length(q))) * smoothstep(rad, rad + 0.01, length(q)) ; 

}

void main(void)
{
    
    vec2 p = gl_FragCoord.xy / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;
    p.x -= 0.39;

    float fft  = texture2D( iChannel0, vec2(0.02,0.0) ).x; 
    float fft2  = texture2D( iChannel0, vec2(0.9,0.0) ).x; 
    
    float fff = (fft-0.4)*1.6;
    float fff2 = (fft2)*2.6;
    
    float tim = iTime;
    
    q = p - vec2(0.5, 0.5);
    
    vec3 col = vec3(0.14, 0.14, 0.14); // gray

    
    vec3 col2 = vec3( 0.96, 0.47, 0.43); // salmon
    vec3 col3 = vec3( 0.42, 0.18, 0.10); // brown
    vec3 col4 = vec3( 0.20, 0.13, 0.15); // Purple
    vec3 col5 = vec3( 0.87, 0.50, 0.18); // orange
    vec3 col6 = vec3( 0.63, 0.67, 1.0); // blue
    
    col *= step(0.31+(fft*0.45)-0.3, length(q));
          
    col2 *= circle(0.2,0.06 + pow(0.01, (fft*0.9)-0.2));    
    
    float angle = atan( q.y, q.x ) + PI;
    float mod = sqrt(q.y*q.y+q.x*q.x);
    
    float angle2 = angle + (sin(tim*2.0)*3.0)+fff  ;

    vec2 qr;
    qr.y = sin(angle2)*mod;
    qr.x = cos(angle2)*mod;
            
    float t = (atan( qr.y, qr.x ) + PI) / (2.0 * PI);
    
    col2 *= 1.0- smoothstep(0.12+fff, 0.125+fff, t);
    col2 *= smoothstep(0.0, 0.005, t);

    col += col2;

    float colm = fff*0.3;
    
    col3 += vec3( fff2*colm, fff2*colm, fff2*colm); 
    col3 *= circle(0.145+fff2*0.01, 0.03);  
    col += col3;

    
    angle2 = angle + (sin(tim*1.0)*6.0)+fff  ;

    qr.y = sin(angle2)*mod;
    qr.x = cos(angle2)*mod;
            
    t = (atan( qr.y, qr.x ) + PI) / (2.0 * PI);

    col4 *= 2.5*fff2;
    col4 *= circle(0.03, 0.08); 
    col4 *= 1.0-smoothstep(0.2+fff2*0.8, 0.205+fff2*0.8, t);    
    col4 *= smoothstep(0.0, 0.005, t);
    col += col4;

    col5 *= 1.0 - smoothstep(0.01+fff*0.04, 0.018+fff*0.04, length(q)); 
    col += col5;
    
    gl_FragColor = vec4(col, 1.0);  
}