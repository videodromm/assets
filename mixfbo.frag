#version 150
// mixfbo.frag uniforms begin
uniform vec3        iResolution;          // viewport resolution (in pixels)
uniform sampler2D   iChannel0;        // input channel 0 
uniform sampler2D   iChannel1;        // input channel 1 
uniform vec4        iMouse;               // mouse pixel coords. xy: current (if MLB down), zw: click
uniform float       iTime;          // shader playback time (in seconds)
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
uniform int         iGlitch;              // 1 for glitch
uniform float       iChromatic;       // chromatic if > 0.
uniform float       iTrixels;             // trixels if > 0.
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
uniform float       iContour;         // contour size if > 0.01

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
      blend += texture(tex, uv1);         
        }
    }
    rtn = (blend / 9.0);
    return rtn;
}
// trixels end
float glitchHash(float x)
{
  return fract(sin(x * 11.1753) * 192652.37862);
}
float glitchNse(float x)
{
  float fl = floor(x);
  return mix(glitchHash(fl), glitchHash(fl + 1.0), smoothstep(0.0, 1.0, fract(x)));
}


vec3 greyScale( vec3 colored )
{
   return vec3( (colored.r+colored.g+colored.b)/3.0 );
}
// left main lines begin
vec3 shaderLeft(vec2 uv)
{
  vec4 left = texture(iChannel0, uv);
  // chromatic aberration
  if (iChromatic > 0.0) 
  {
    vec2 offset = vec2(iChromatic/50.,.0);
    left.r = texture(iChannel0, uv+offset.xy).r;
    left.g = texture(iChannel0, uv          ).g;
    left.b = texture(iChannel0, uv+offset.yx).b;
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
  vec4 right = texture(iChannel1, uv);
  // chromatic aberation
  if (iChromatic > 0.0) 
  {
    vec2 offset = vec2(iChromatic/50.,.0);
    right.r = texture(iChannel1, uv+offset.xy).r;
    right.g = texture(iChannel1, uv          ).g;
    right.b = texture(iChannel1, uv+offset.yx).b;
  }
  // Trixels
  if (iTrixels > 0.0) 
  {
        right = trixels( uv, iChannel1 );
  }
  return vec3( right.r, right.g, right.b );
}
// Blend functions begin
vec3 multiply( vec3 s, vec3 d )
{
   return s*d;
}
vec3 colorBurn( vec3 s, vec3 d )
{
   return 1.0 - (1.0 - d) / s;
}
vec3 linearBurn( vec3 s, vec3 d )
{
   return s + d - 1.0;
}
vec3 darkerColor( vec3 s, vec3 d )
{
   return (s.x + s.y + s.z < d.x + d.y + d.z) ? s : d;
}
vec3 lighten( vec3 s, vec3 d )
{
   return max(s,d);
}
vec3 darken( vec3 s, vec3 d )
{
   return min(s,d);
}
vec3 screen( vec3 s, vec3 d )
{
   return s + d - s * d;
}

vec3 colorDodge( vec3 s, vec3 d )
{
   return d / (1.0 - s);
}

vec3 linearDodge( vec3 s, vec3 d )
{
   return s + d;
}

vec3 lighterColor( vec3 s, vec3 d )
{
   return (s.x + s.y + s.z > d.x + d.y + d.z) ? s : d;
}

float overlay( float s, float d )
{
   return (d < 0.5) ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
}

vec3 overlay( vec3 s, vec3 d )
{
   vec3 c;
   c.x = overlay(s.x,d.x);
   c.y = overlay(s.y,d.y);
   c.z = overlay(s.z,d.z);
   return c;
}

float softLight( float s, float d )
{
   return (s < 0.5) ? d - (1.0 - 2.0 * s) * d * (1.0 - d) 
      : (d < 0.25) ? d + (2.0 * s - 1.0) * d * ((16.0 * d - 12.0) * d + 3.0) 
                : d + (2.0 * s - 1.0) * (sqrt(d) - d);
}

vec3 softLight( vec3 s, vec3 d )
{
   vec3 c;
   c.x = softLight(s.x,d.x);
   c.y = softLight(s.y,d.y);
   c.z = softLight(s.z,d.z);
   return c;
}

float hardLight( float s, float d )
{
   return (s < 0.5) ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
}

vec3 hardLight( vec3 s, vec3 d )
{
   vec3 c;
   c.x = hardLight(s.x,d.x);
   c.y = hardLight(s.y,d.y);
   c.z = hardLight(s.z,d.z);
   return c;
}

float vividLight( float s, float d )
{
   return (s < 0.5) ? 1.0 - (1.0 - d) / (2.0 * s) : d / (2.0 * (1.0 - s));
}

vec3 vividLight( vec3 s, vec3 d )
{
   vec3 c;
   c.x = vividLight(s.x,d.x);
   c.y = vividLight(s.y,d.y);
   c.z = vividLight(s.z,d.z);
   return c;
}

vec3 linearLight( vec3 s, vec3 d )
{
   return 2.0 * s + d - 1.0;
}

float pinLight( float s, float d )
{
   return (2.0 * s - 1.0 > d) ? 2.0 * s - 1.0 : (s < 0.5 * d) ? 2.0 * s : d;
}

vec3 pinLight( vec3 s, vec3 d )
{
   vec3 c;
   c.x = pinLight(s.x,d.x);
   c.y = pinLight(s.y,d.y);
   c.z = pinLight(s.z,d.z);
   return c;
}

vec3 hardMix( vec3 s, vec3 d )
{
   return floor(s + d);
}

vec3 difference( vec3 s, vec3 d )
{
   return abs(d - s);
}

vec3 exclusion( vec3 s, vec3 d )
{
   return s + d - 2.0 * s * d;
}

vec3 subtract( vec3 s, vec3 d )
{
   return s - d;
}

vec3 divide( vec3 s, vec3 d )
{
   return s / d;
}

// rgb<-->hsv functions by Sam Hocevar
// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 rgb2hsv(vec3 c)
{
   vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
   vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
   vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
   
   float d = q.x - min(q.w, q.y);
   float e = 1.0e-10;
   return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
   vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
   vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
   return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 hue( vec3 s, vec3 d )
{
   d = rgb2hsv(d);
   d.x = rgb2hsv(s).x;
   return hsv2rgb(d);
}

vec3 color( vec3 s, vec3 d )
{
   s = rgb2hsv(s);
   s.z = rgb2hsv(d).z;
   return hsv2rgb(s);
}

vec3 saturation( vec3 s, vec3 d )
{
   d = rgb2hsv(d);
   d.y = rgb2hsv(s).y;
   return hsv2rgb(d);
}

vec3 luminosity( vec3 s, vec3 d )
{
   float dLum = dot(d, vec3(0.3, 0.59, 0.11));
   float sLum = dot(s, vec3(0.3, 0.59, 0.11));
   float lum = sLum - dLum;
   vec3 c = d + lum;
   float minC = min(min(c.x, c.y), c.z);
   float maxC = max(max(c.x, c.y), c.z);
   if(minC < 0.0) return sLum + ((c - sLum) * sLum) / (sLum - minC);
   else if(maxC > 1.0) return sLum + ((c - sLum) * (1.0 - sLum)) / (maxC - sLum);
   else return c;
}
// Blend functions end

vec3 mainFunction( vec2 uv )
{
   vec3 c = vec3(0.0);
   switch ( iBlendmode )
   {
   case 0: 
      c = mix( shaderLeft(uv), shaderRight(uv), iCrossfade );
      break;
   case 1: 
      c = multiply( shaderLeft(uv), shaderRight(uv) );
      break;
   case 2: 
      c = colorBurn( shaderLeft(uv), shaderRight(uv) );
      break;
   case 3: 
      c = linearBurn( shaderLeft(uv), shaderRight(uv) );
      break;
   case 4: 
      c = darkerColor( shaderLeft(uv), shaderRight(uv) );
      break;
   case 5: 
      c = lighten( shaderLeft(uv), shaderRight(uv) );
      break;
   case 6: 
      c = screen( shaderLeft(uv), shaderRight(uv) );
      break;
   case 7: 
      c = colorDodge( shaderLeft(uv), shaderRight(uv) );
      break;
   case 8: 
      c = linearDodge( shaderLeft(uv), shaderRight(uv) );
      break;
   case 9: 
      c = lighterColor( shaderLeft(uv), shaderRight(uv) );
      break;
   case 10: 
      c = overlay( shaderLeft(uv), shaderRight(uv) );
      break;
   case 11: 
      c = softLight( shaderLeft(uv), shaderRight(uv) );
      break;
   case 12: 
      c = hardLight( shaderLeft(uv), shaderRight(uv) );
      break;
   case 13: 
      c = vividLight( shaderLeft(uv), shaderRight(uv) );
      break;
   case 14: 
      c = linearLight( shaderLeft(uv), shaderRight(uv) );
      break;
   case 15: 
      c = pinLight( shaderLeft(uv), shaderRight(uv) );
      break;
   case 16: 
      c = hardMix( shaderLeft(uv), shaderRight(uv) );
      break;
   case 17: 
      c = difference( shaderLeft(uv), shaderRight(uv) );
      break;
   case 18: 
      c = exclusion( shaderLeft(uv), shaderRight(uv) );
      break;
   case 19: 
      c = subtract( shaderLeft(uv), shaderRight(uv) );
      break;
   case 20: 
      c = divide( shaderLeft(uv), shaderRight(uv) );
      break;
   case 21: 
      c = hue( shaderLeft(uv), shaderRight(uv) );
      break;
   case 22: 
      c = color( shaderLeft(uv), shaderRight(uv) );
      break;
   case 23: 
      c = saturation( shaderLeft(uv), shaderRight(uv) );
      break;
   case 24: 
      c = luminosity( shaderLeft(uv), shaderRight(uv) );
      break;
   case 25: 
      c = darken( shaderLeft(uv), shaderRight(uv) );
      break;
   case 26: 
      c = shaderLeft(uv);
      break;
   default: // in any other case.
      c = shaderRight(uv);
      break;
   }
   return c;
}
float BadTVResoRand(in float a, in float b) { return fract((cos(dot(vec2(a,b) ,vec2(12.9898,78.233))) * 43758.5453)); }

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

 // slitscan
  if (iRatio < 1.0)
  {
    float x = gl_FragCoord.x;
    float y = gl_FragCoord.y;
    float x2 = x;   
    float y2 = y;
    if (iXorY)
    {
      float z1 = floor((x/iParam1) + 0.5);     //((x/20.0) + 0.5)
      x2 = x + (sin(z1 + (iTime * 2.0)) * iRatio * 20.0);
    }
    else
    {
      float z2 = floor((y/iParam2) + 0.5);     //((x/20.0) + 0.5)
      y2 = y + (sin(z2 + (iTime * 2.0)) * iRatio * 20.0);
    }

    vec2 uv2 = vec2(x2 / iResolution.x, y2/ iResolution.y);
    uv  = texture( iChannel1, uv2 ).rg;
  }
  // glitch
  if (iGlitch == 1) 
  {
    // glitch the point around
    float s = iTempoTime * iRatio * 20.0;
    float te = iTempoTime * 9.0 / 16.0;//0.25 + (iTempoTime + 0.25) / 2.0 * 128.0 / 60.0;
    vec2 shk = (vec2(glitchNse(s), glitchNse(s + 11.0)) * 2.0 - 1.0) * exp(-5.0 * fract(te * 4.0)) * 0.1;
    uv += shk;    
  }
  // pixelate
  if ( iPixelate < 1.0 )
  {
    vec2 divs = vec2(iResolution.x * iPixelate / iResolution.y*60.0, iPixelate*60.0);
    uv = floor(uv * divs)/ divs;
  }

   
  vec3 col;
   
  if ( iCrossfade > 0.99 )
  {
    col = shaderRight(uv-cZ);
  }
  else
  {
    if ( iCrossfade < 0.01 )
    {
      col = shaderLeft(uv-cZ);
    }
    else
    {
      col = mainFunction( uv-cZ );

    }
  }
  if (iToggle == 1) 
  {
    col.rgb = col.gbr;
  }
  col *= iExposure;
  if (iInvert == 1) col = 1.-col;
   // badtv
  if (iBadTv > 0.01)
  {
    float c = 1.;
    if (iXorY)
    {
      c += iBadTv * sin(iTime * 2. + uv.y * 100. * iParam1);
      c += iBadTv * sin(iTime * 1. + uv.y * 80.);
      c += iBadTv * sin(iTime * 5. + uv.y * 900. * iParam2);
      c += 1. * cos(iTime + uv.x);
    }
    else
    {
      c += iBadTv * sin(iTime * 2. + uv.x * 100. * iParam1);
      c += iBadTv * sin(iTime * 1. + uv.x * 80.);
      c += iBadTv * sin(iTime * 5. + uv.x * 900. * iParam2);
      c += 1. * cos(iTime + uv.y);
    } 
  
    //vignetting
    c *= sin(uv.x*3.15);
    c *= sin(uv.y*3.);
    c *= .9;
  
    uv += iTime;
  
    float r = BadTVResoRand(uv.x, uv.y);
    float g = BadTVResoRand(uv.x * 9., uv.y * 9.);
    float b = BadTVResoRand(uv.x * 3., uv.y * 3.);
  
    col.x *= r*c*.35;
    col.y *= b*c*.95;
    col.z *= g*c*.35;
  }

  // grey scale mode
  if (iGreyScale == 1)
  {
     col = greyScale( col );
  }
  col.r *= iRedMultiplier;
  col.g *= iGreenMultiplier;
  col.b *= iBlueMultiplier;
         
  // contour 
  if (iContour> 0.01) {
    if ( uv.y > 1.0 - iContour )
      col = iBackgroundColor;
    if ( uv.y < iContour )
      col = iBackgroundColor;
    if ( uv.x > 1.0 - iContour )
      col = iBackgroundColor;
    if ( uv.x < iContour )
      col = iBackgroundColor;  
  }
  oColor = iAlpha * vec4( col, 1.0 );
}
