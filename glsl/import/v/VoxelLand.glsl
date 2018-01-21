//https://www.shadertoy.com/view/XtlGRr
#ifdef GL_ES
precision highp float;
#endif

// Parameters
#define CAMERA_FOCAL_LENGTH   1.5
#define REFLECT_COUNT       1
#define REFLECT_INDEX     0.2
#define VOXEL_STEP_INCIDENT   100
#define VOXEL_STEP_REFLECTED  20
#define SHADERTOY

// Constants
#define M_PI  3.1415926535897932384626433832795
#define DELTA 0.01

// PRNG
// From https://www.shadertoy.com/view/4djSRW
float rand (in vec2 seed) {
  seed = fract (seed * vec2 (5.3983, 5.4427));
  seed += dot (seed.yx, seed.xy + vec2 (21.5351, 14.3137));
  return fract (seed.x * seed.y * 95.4337);
}

// HSV to RGB
vec3 rgb (in vec3 hsv) {
  hsv.yz = clamp (hsv.yz, 0.0, 1.0);
  return hsv.z * (1.0 + hsv.y * clamp (abs (fract (hsv.xxx + vec3 (0.0, 2.0 / 3.0, 1.0 / 3.0)) * 6.0 - 3.0) - 2.0, -1.0, 0.0));
}

// Main function
void main () {

  // Define the ray corresponding to this fragment
  vec3 ray = normalize (vec3 ((2.0 * gl_FragCoord.xy - iResolution.xy) / iResolution.y, CAMERA_FOCAL_LENGTH));

  // Get the music info
  #ifdef SHADERTOY
  float soundBass = texture2D (iChannel0, vec2 (0.0)).x;
  float soundTreble = texture2D (iChannel0, vec2 (0.9, 0.0)).x;
  #else
  float soundBass = 0.6 + 0.4 * cos (iGlobalTime * 0.2);
  float soundTreble = 0.5 + 0.5 * cos (iGlobalTime * 1.2);
  #endif

  // Set the camera
  vec3 origin = vec3 (0.0, 10.0 - 8.0 * cos (iGlobalTime * 0.3), iGlobalTime * 10.0);
  float cameraAngle = iGlobalTime * 0.1;
  #ifdef SHADERTOY
  cameraAngle += 2.0 * M_PI * iMouse.x / iResolution.x;
  #endif
  vec3 cameraForward = vec3 (cos (cameraAngle), cos (iGlobalTime * 0.3) - 1.5, sin (cameraAngle));
  vec3 cameraUp = vec3 (0.2 * cos (iGlobalTime * 0.7), 1.0, 0.0);
  mat3 cameraRotation;
  cameraRotation [2] = normalize (cameraForward);
  cameraRotation [0] = normalize (cross (cameraUp, cameraForward));
  cameraRotation [1] = cross (cameraRotation [2], cameraRotation [0]);
  ray = cameraRotation * ray;

  // Handle reflections
  vec3 colorMixed = vec3 (0.0);
  float absorb = 1.0;
  int voxelStepStop = VOXEL_STEP_INCIDENT;
  for (int reflectNumber = 0; reflectNumber <= REFLECT_COUNT; ++reflectNumber) {

    // Voxel
    vec2 voxelSign = sign (ray.xz);
    vec2 voxelIncrement = voxelSign / ray.xz;
    float voxelTimeCurrent = 0.0;
    vec2 voxelTimeNext = (0.5 + voxelSign * (0.5 - fract (origin.xz + 0.5))) * voxelIncrement;
    vec2 voxelPosition = floor (origin.xz + 0.5);
    float voxelHeight = 0.0;
    bool voxelDone = false;
    vec3 voxelNormal = vec3 (0.0);
    for (int voxelStep = 1; voxelStep <= VOXEL_STEP_INCIDENT; ++voxelStep) {

      // Compute the height of this column
      voxelHeight = 3.0 * rand (voxelPosition);
      voxelHeight *= abs (sin (soundBass * M_PI * 0.5 + voxelPosition.x) * sin (soundTreble * M_PI * 0.5 + voxelPosition.y));
      voxelHeight *= mod (voxelPosition.x * voxelPosition.y, 3.0);

      // Check whether we hit the side of the column
      if (voxelDone = voxelHeight > origin.y + voxelTimeCurrent * ray.y) {
        break;
      }

      // Check whether we hit the top of the column
      float timeNext = min (voxelTimeNext.x, voxelTimeNext.y);
      float timeIntersect = (voxelHeight - origin.y) / ray.y;
      if (voxelDone = timeIntersect > voxelTimeCurrent && timeIntersect < timeNext) {
        voxelTimeCurrent = timeIntersect;
        voxelNormal = vec3 (0.0, 1.0, 0.0);
        break;
      }

      // Next voxel...
      #if REFLECT_COUNT > 0
      if (voxelStep >= voxelStepStop) {
        break;
      }
      #endif
      voxelTimeCurrent = timeNext;
      voxelNormal.xz = step (voxelTimeNext.xy, voxelTimeNext.yx);
      voxelTimeNext += voxelNormal.xz * voxelIncrement;
      voxelPosition += voxelNormal.xz * voxelSign;
    }
    if (!voxelDone) {
      break;
    }
    origin += voxelTimeCurrent * ray;

    // Compute the local color
    vec3 mapping = origin;
    mapping.y -= voxelHeight + 0.5;
    mapping *= 1.0 - voxelNormal;
    mapping += 0.5;
    float id = rand (voxelPosition);
    vec3 color = rgb (vec3 (id + (iGlobalTime + floor (mapping.y)) * 0.05, 1.0, 1.0));
    color += 0.5 * cos (id * vec3 (1.0, 2.0, 3.0));
    color *= smoothstep (0.9 - 0.6 * cos (soundBass * M_PI), 0.1, length (fract (mapping) - 0.5));
    color *= 0.5 + 1.5 * smoothstep (0.85, 0.95, cos (id * iGlobalTime * 5.0));
    color *= 0.5 + 0.5 * cos (id * iGlobalTime + M_PI * soundTreble);

    // Mix the colors
    #if REFLECT_COUNT == 0
    colorMixed = color;
    #else
    colorMixed += color * absorb;
    absorb *= REFLECT_INDEX;

    // Reflection
    ray = reflect (ray, voxelNormal);
    origin += ray * DELTA;
    voxelStepStop = VOXEL_STEP_REFLECTED;
    #endif
  }

  // Set the fragment color
  gl_FragColor = vec4 (colorMixed, 1.0);
}