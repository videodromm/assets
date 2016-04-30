#version 150 core

// Shader Inputs
uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iGlobalTime;           // shader playback time (in seconds)
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if LMB down), zw: click
uniform vec4      iDate;                 // (year, month, day, time in seconds)
uniform sampler2D   iChannel0;              // input channel 0

out vec4 oColor;

void main(void)
{
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
   // vec4 left = texture2D(iChannel0, uv);
    
    //oColor = vec4( left.r, left.g, 0.5 + 0.5 * sin(iGlobalTime), 1.0 );
    oColor = vec4( 1.0, 0.5 * sin(iGlobalTime), 0.0, 1.0 );
}