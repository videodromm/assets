// http://glsl.heroku.com/e#14211.0
#define volsteps 10
#define iterations 6

#define sparsity 0.5  // .4 to .5 (sparse)
#define stepsize 0.4

#define frequencyVariation   1.1 // 0.5 to 2.0

#define brightness 0.038
#define distfading 0.300

//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
// 

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.8;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}


void main(void) {    
  
  vec2 uv = 2.0 * iZoom * gl_FragCoord.xy / iResolution.xy;
  uv.x *= float(iResolution.x )/ float(iResolution.y);
  uv.x -= iRenderXY.x;
  uv.y -= iRenderXY.y;

    vec2 zoom = vec2(5, 5);
    vec3 origin = vec3( cos(iTime * 0.1) + iTime * 0.05, sin(iTime * 0.05) + iTime * 0.05, 0 );
	
    vec3 dir = vec3( uv * zoom, 1.0 );

    float s = 0.1, fade = 0.02;
    gl_FragColor.rgb = vec3(0);//vec3(snoise(uv * 10.0 + origin.xy));
   
    for (int r = 0; r < volsteps; ++r) {
        vec3 p = origin + dir * s;
        p = abs(vec3(frequencyVariation) - mod(p, vec3(frequencyVariation * 2.0)));
		    
        float prevlen = 0.0, a = 0.0;
        for (int i = 0; i < iterations; ++i) {
            p = abs(p);
            p = p * (1.0 / dot(p, p)) - sparsity; // the magic formula            
            float len = length(p);
            a += abs(len - prevlen); // absolute sum of average change
            prevlen = len;
        }
        
        a *= a * a; // add contrast
        
        // coloring based on distance        
        gl_FragColor.rgb += (vec3(s, s*s, s*s*s) * a * brightness + 1.0) * fade;
        fade *= distfading; // distance fading
        s += stepsize;
    }
    
    gl_FragColor.rgb = min(gl_FragColor.rgb, vec3(1.2));

    // Detect and suppress flickering single pixels (ignoring the huge gradients that we encounter inside bright areas)
    //float intensity = min(gl_FragColor.r + gl_FragColor.g + gl_FragColor.b, 0.7);

    // Motion blur; increases temporal coherence of undersampled flickering stars
    // and provides temporal filtering under true motion.  
    //vec3 oldValue = texelFetch(oldImage, ivec2(gl_FragCoord.xy), 0).rgb;
    //gl_FragColor.rgb = mix(oldValue - vec3(0.004), gl_FragColor.rgb, 0.5);
    gl_FragColor.a = 1.0;
}


