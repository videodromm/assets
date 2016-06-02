#version 150
// uniforms begin
uniform vec3        iResolution;          // viewport resolution (in pixels)
uniform float       iChannelTime[4];      // channel playback time (in seconds)
uniform vec3        iChannelResolution[4];  // channel resolution (in pixels)
uniform sampler2D   iChannel0;        // input channel 0 (TODO: support samplerCube)
uniform sampler2D   iChannel1;        // input channel 1 
uniform sampler2D   iAudio0;        // input channel 0 (audio)
uniform vec4        iMouse;               // mouse pixel coords. xy: current (if MLB down), zw: click
uniform float       iGlobalTime;          // shader playback time (in seconds)
uniform vec3        iBackgroundColor;     // background color
uniform vec3        iColor;               // color
uniform int         iSteps;               // steps for iterations
uniform int         iFade;                // 1 for fade out
uniform int         iToggle;              // 1 for toggle
uniform float       iRatio;
uniform vec2        iRenderXY;            // move x y 
uniform float       iZoom;                // zoom
uniform int         iBlendmode;           // blendmode for channels
uniform float   iRotationSpeed;       // Rotation Speed
uniform float       iCrossfade;           // CrossFade 2 shaders
uniform float       iPixelate;            // pixelate
uniform int         iGreyScale;           // 1 for grey scale mode
uniform float       iAlpha;               // alpha
uniform int         iLight;             // 1 for light
uniform int         iLightAuto;           // 1 for automatic light
uniform float       iExposure;            // exposure
uniform float       iDeltaTime;           // delta time between 2 tempo ticks
uniform int         iTransition;        // transition type
uniform float       iAnim;              // animation
uniform int         iRepeat;              // 1 for repetition
uniform int         iVignette;            // 1 for vignetting
uniform int         iInvert;              // 1 for color inversion
uniform int         iDebug;               // 1 to show debug
uniform int         iShowFps;             // 1 to show fps
uniform float       iFps;               // frames per second
uniform float       iTempoTime;
uniform vec4    iDate;          // (year, month, day, time in seconds)
uniform int         iGlitch;              // 1 for glitch
uniform float       iChromatic;       // chromatic if > 0.
uniform float       iTrixels;             // trixels if > 0.
uniform float       iGridSize;        // gridSize if > 0.
uniform bool        iFlipH;         // flip horizontally
uniform bool        iFlipV;         // flip vertically
uniform int         iBeat;          // measure from ableton
uniform float       iSeed;          // random 
uniform float       iRedMultiplier;     // red multiplier 
uniform float       iGreenMultiplier;   // green multiplier 
uniform float       iBlueMultiplier;    // blue multiplier 
uniform float       iParam1;        // slitscan (or other) Param1
uniform float       iParam2;        // slitscan (or other) Param2 
uniform bool        iXorY;          // slitscan (or other) effect on x or y
uniform float       iBadTv;         // badtv if > 0.01

const   float       PI = 3.14159265;
// uniforms end

vec4 trixels( vec2 inUV, sampler2D tex )
{
  // trixels https://www.shadertoy.com/view/4lj3Dm
  vec4 rtn;

    float height = iResolution.x/(1.01 - iTrixels)/90.0;
    float halfHeight = height*0.5;
    float halfBase = height/sqrt(3.0);
    float base = halfBase*2.0;

    float screenX = gl_FragCoord.x;
    float screenY = gl_FragCoord.y;    

    float upSlope = height/halfBase;
    float downSlope = -height/halfBase;

    float oddRow = mod(floor(screenY/height),2.0);
    screenX -= halfBase*oddRow;
    
    float oddCollumn = mod(floor(screenX/halfBase), 2.0);

    float localX = mod(screenX, halfBase);
    float localY = mod(screenY, height);

    if(oddCollumn == 0.0 )
    {
        if(localY >= localX*upSlope)
        {
            screenX -= halfBase;
        }
    }
    else
    {
        if(localY <= height+localX*downSlope)
        {
            screenX -= halfBase;
        }
    }
    
    float startX = floor(screenX/halfBase)*halfBase;
    float startY = floor(screenY/height)*height;
    vec4 blend = vec4(0.0,0.0,0.0,0.0);
    for(float x = 0.0; x < 3.0; x += 1.0)
    {
        for(float y = 0.0; y < 3.0; y += 1.0)
        {
            vec2 screenPos = vec2(startX+x*halfBase,startY+y*halfHeight);
            vec2 uv1 = screenPos / iResolution.xy;
      blend += texture2D(tex, uv1);         
        }
    }
    rtn = (blend / 9.0);
    return rtn;
}
// trixels end
vec3 greyScale( vec3 colored )
{
   return vec3( (colored.r+colored.g+colored.b)/3.0 );
}
// left main lines begin
vec3 shaderLeft(vec2 uv)
{
  vec4 left = texture2D(iChannel0, uv);
  // chromatic aberration
  if (iChromatic > 0.0) 
  {
    vec2 offset = vec2(iChromatic/50.,.0);
    left.r = texture2D(iChannel0, uv+offset.xy).r;
    left.g = texture2D(iChannel0, uv          ).g;
    left.b = texture2D(iChannel0, uv+offset.yx).b;
  }
  // Trixels
  if (iTrixels > 0.0) 
  {
        left = trixels( uv, iChannel0 );
  }
  return vec3( left.r, left.g, left.b );
}
// left main lines end

// right main lines begin
vec3 shaderRight(vec2 uv)
{
  vec4 right = texture2D(iChannel1, uv);
  // chromatic aberation
  if (iChromatic > 0.0) 
  {
    vec2 offset = vec2(iChromatic/50.,.0);
    right.r = texture2D(iChannel1, uv+offset.xy).r;
    right.g = texture2D(iChannel1, uv          ).g;
    right.b = texture2D(iChannel1, uv+offset.yx).b;
  }
  // Trixels
  if (iTrixels > 0.0) 
  {
        right = trixels( uv, iChannel1 );
  }
  return vec3( right.r, right.g, right.b );
}

out vec4 oColor;

void main( void )
{
  vec2 uv = gl_FragCoord.xy / iResolution.xy;
  // flip horizontally
  if (iFlipH)
  {
    uv.x = 1.0 - uv.x;
  }
  // flip vertically
  if (iFlipV)
  {
    uv.y = 1.0 - uv.y;
  }
  // zoom centered
  float xZ = (uv.x - 0.5)*iZoom*2.0;
  float yZ = (uv.y - 0.5)*iZoom*2.0;
  vec2 cZ = vec2(xZ, yZ);

  vec4 tex = texture(iChannel0, vec2(cZ.x-iChannelResolution[0].x,cZ.y-iChannelResolution[0].y));
  vec4 tex2 = texture(iChannel1, vec2(cZ.x-iChannelResolution[0].x,cZ.y-iChannelResolution[0].y));
   
  vec3 col;
   
      col = shaderLeft(uv-cZ);
  
  // grey scale mode
  if (iGreyScale == 1)
  {
     col = greyScale( col );
  }
  col.r *= iRedMultiplier;
  col.g *= iGreenMultiplier;
  col.b *= iBlueMultiplier;

  //oColor    = vec4(tex2.x,tex.x,tex2.y,1.0);
  oColor = iAlpha * vec4( col, 1.0 );
}
