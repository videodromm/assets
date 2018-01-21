// https://www.shadertoy.com/view/XtfGR7
// wavelet-ish visualizer 2

// Iain Melvin 2014

// gradient from: https://www.shadertoy.com/view/4dsSzr
vec3 heatmapGradient(float t) {
    return clamp((pow(t, 1.5) * 0.8 + 0.2) * vec3(smoothstep(0.0, 0.35, t) + t * 0.5, smoothstep(0.5, 1.0, t), max(1.0 - t * 1.7, t * 7.0 - 6.0)), 0.0, 1.0);
}

void main(void)
{
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  float px = 2.0*(uv.x-0.5);
  float py = 2.0*(uv.y-0.5);

  float dx = uv.x;
  float dy = uv.y;

  // alternative mappings
  dx = abs(uv.x-0.5)*3.0;
  //dx =1.0*atan(abs(py),px)/(3.14159*2.0);
  //dy =2.0*sqrt( px*px + py*py );
    
  const float pi2 = 3.14159*2.0;

  // my wavelet 
  //float width = 1.0-dy; 
  //float width = (1.0-sqrt(dy)); // focus a little more on higher frequencies
  float width = 1.0-(pow(dy,(1.0/4.0) )); // focus a lot more on higher frequencies
  const float nperiods = 4.0; //num full periods in wavelet
  const int numsteps = 100; // more than 100 crashes nvidia windows (would love to know why)
  const float stepsize = 1.0/float(numsteps);
  
  float accr = 0.0;

  // x is in 'wavelet packet space'
  for (float x=-1.0; x<1.0; x+=stepsize){
    
    // the wave in the wavelet 
    float yr = sin((dx+x*nperiods*pi2)); 
    
    // get a sample - center at uv.x, offset by width*x
    float si = dx + width*x;
      if (si>0.0 || si<1.0){
        
        // take sample and scale it to -1.0 -> +1.0
        float s = 2.0*( texture2D( iChannel0, vec2(si,0.75)).x - 0.5 + (12.5/256.0) ); 
            
        // multiply sample with the wave in the wavelet
        float sr=yr*s;
         
        // apply packet 'window'
        float w = 1.0-abs(x);
        sr*=w;

        // accumulate
        accr+=sr;
      }
  }

  float y=3.0*accr; //; //0.0*abs(accr)/accn;
 
  gl_FragColor = vec4( heatmapGradient(y),1.0);


 
}
