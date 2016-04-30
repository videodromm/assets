// https://www.shadertoy.com/view/4lSGDK
// simple sphere cheat map.
// modified. playing around.
// dean alex

float PI = 3.14159265358979586;

float focal = 0.5;
float aspect = iResolution.x / iResolution.y;
//float heartRadius = pow(0.7 + sin( iGlobalTime * 6.0) * 0.05, 10.0);
float heartRadius = 0.7 + sin( iGlobalTime * 6.0) * 0.05;
float heartX = 0.5 * aspect;
float heartY = 0.4;

vec2 warp( float x, float y, float radius ){
    
    // width of radius at y
    float rad_w = sqrt( radius*radius - y*y );
    float warp_x = x / rad_w;
    
    // height of radius at x
    float rad_h = sqrt( radius*radius - x*x );
    float warp_y = y / rad_h;
    
    //
    warp_x = warp_x + (cos( x * PI ));
    warp_y = warp_y + (cos( y * PI ));
    
    return vec2( warp_x, warp_y );
}

void main( void )
{  
    //----- pixel coords -----
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    float s = uv.s * aspect;
    float t = 1.0 - uv.t;
      
    //----- get heart shape -----
    float dx = (s - heartX) / heartRadius;
    float dy = (t - heartY) / heartRadius;
    
    float theta = atan( dy, dx ) + PI / 2.0;
    theta = abs( PI - abs( theta - PI));
    float thetamf = theta / PI;
    
    float outlineRadius0 = 0.4;
    float outlineRadius1 = 0.7;
    
    float outline = sin( theta * 1.1) * (1.0 - thetamf * thetamf) * outlineRadius0 * heartRadius + outlineRadius1 * heartRadius * thetamf * thetamf;
    
    float dis = sqrt( dx*dx + dy*dy );
    float dismf = dis / outline;
    
    if( dismf > 1.0 ){
        return;
    }

    gl_FragColor = vec4( 1.0, 0.0, 0.2, 1.0 );
}
