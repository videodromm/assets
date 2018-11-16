// https://www.shadertoy.com/view/Mdl3zj
void main( void ) {

     vec2 position = (gl_FragCoord.xy/iResolution.xy);

     float cX = position.x - 0.5;
     float cY = position.y - 0.5;

     float newX = log(sqrt(cX*cX + cY*cY));
     float newY = atan(cX, cY);
     
     float color = 0.0;
     color += cos( newX * cos(iTime / 15.0 ) * 80.0 ) + cos( newX * cos(iTime / 15.0 ) * 10.0 );
     color += cos( newY * cos(iTime / 10.0 ) * 40.0 ) + cos( newY * sin(iTime / 25.0 ) * 40.0 );
     color += cos( newX * cos(iTime / 5.0 ) * 10.0 ) + cos( newY * sin(iTime / 35.0 ) * 80.0 );
     color *= cos(iTime / 10.0 ) * 0.5;

     gl_FragColor = vec4( vec3( color, color * 0.5, sin( color + iTime / 3.0 ) * 0.75 ), 1.0 );

}