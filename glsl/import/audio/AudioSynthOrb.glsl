
// https://www.shadertoy.com/view/Mss3DS
// **************************************************************************
// DEFINITIONS
// **************************************************************************

#define PI 3.14159
#define TWO_PI 6.28318
#define ONE_OVER_PI 0.3183099
#define ONE_OVER_TWO_PI 0.159154
#define PI_OVER_TWO 1.570796
    
#define EPSILON 0.0001
#define BIG_FLOAT 1000000.0

// **************************************************************************
// OPTIMIZATION DEFS
// **************************************************************************

// Adjust number of polar march steps number based on performance of 
// graphics cards.

//#define NUM_POLAR_MARCH_STEPS 128
//#define NUM_POLAR_MARCH_STEPS 64
//#define NUM_POLAR_MARCH_STEPS 32
#define NUM_POLAR_MARCH_STEPS 8

// **************************************************************************
// GLOBALS
// **************************************************************************

// the beat ourpithyator is about 125 beats per minute, so we have all timing
// based events based on multiples of that beat rate.

// Music events of ourpithyator
#define OURPITHYATOR_START 6.
#define OURPITHYATOR_SOFTDROP 13.
#define OURPITHYATOR_TICKSTART 28.
#define OURPITHYATOR_FIRSTDROP 45.
#define OURPITHYATOR_SLIDINGSCALE 79.
#define OURPITHYATOR_INCEPTIONHONK 87.
#define OURPITHYATOR_FINALHONK 163.

// - - - - - - - - - - - - -
// Audio based signals
float g_beatRate = 125./60.;
float g_time = iGlobalTime;// iChannelTime[1];
float g_audioResponse = 1.;

// audio signals
float g_bassBeat = 0.;
float g_audioFreqs[4];

// - - - - - - - - - - - - -
// pool Surface properties

float g_poolSurfaceFacingKr = .3;
float g_poolSurfaceEdgeOnKr = 1.;
float g_poolSurfaceIOR = 1.33;

// - - - - - - - - - - - - -
// Orb properties

//   dimensions of the orb
float g_orbOuterRadius = 30.;
float g_orbCenterRadius = 12.;
vec3 g_orbPosition = vec3(0.);

//   surface projerteis of the orb
float g_orbSurfaceFacingKr = .1;
float g_orbSurfaceEdgeOnKr = 1.2;
float g_orbIOR = 1.33;

vec2 g_numOrbCells = vec2(12., 128.);
vec2 g_numOrbsChangeRate = vec2(g_beatRate * 0.05, g_beatRate * 0.0625);

//   properties of the "spark" lines
float g_sparkColorIntensity = 1.;
vec2 g_sparkRotationRate = vec2(.0, g_beatRate * .25);

float g_sparkWidth = 0.45;
float g_sparkColorMixLeadingLimit = 0.;
float g_sparkColorMixTrailingLimit = 0.;
float g_sparkColorMixInterval = 0.;

// - - - - - - - - - - - - -
// Camera properties
vec3 g_camOrigin = vec3(0., 0., -120.);
    
// point the camera is pointing at
vec3 g_camPointAt = vec3( 0.0, 0.0, 0.0 );
    
// frame of reference for camera's up position
// Put in a little "dutch angle" to make the image a bit more interesting
vec3 g_camUpDir = vec3( 0.025, 1.0, 0.0 );

float g_camYRotationRate = -0.0625 * g_beatRate;
float g_camXRotationRate = 0.125 * g_beatRate;

// **************************************************************************
// MATH UTILITIES
// **************************************************************************

// XXX: To get around a case where a number very close to zero can result in 
// erratic behavior with sign, we assume a positive sign when a value is 
// close to 0.
float zeroTolerantSign(float value)
{
    // DEBRANCHED
    // Equivalent to:
    // if (abs(value) > EPSILON) { 
    //    s = sign(value); 
    // }
    return mix(1., sign(value), step(EPSILON, abs(value)));
}

// convert a 3d point to two orb coordinates. First coordinate is latitudinal
// angle (angle from the plane going through x+z) Second coordinate is azimuth
// (rotation around the y axis)

// Range of outputs := ([PI/2, -PI/2], [-PI, PI])
vec2 cartesianToPolar( vec3 p ) 
{    
    return vec2(PI/2. - acos(p.y / length(p)), atan(p.z, p.x));
}

// Convert a polar coordinate (x is latitudinal angle, y is azimuthal angle)
// results in a 3-float vector with y being the up axis.

// Range of outputs := ([-1.,-1.,-1.] -> [1.,1.,1.])
vec3 polarToCartesian( vec2 angles )
{
    float cosLat = cos(angles.x);
    float sinLat = sin(angles.x);
    
    float cosAzimuth = cos(angles.y);
    float sinAzimuth = sin(angles.y);
    
    return vec3(cosAzimuth * cosLat,
                sinLat,
                sinAzimuth * cosLat);
}

// Rotate the input point around the y-axis by the angle (given in radians)
// Range of outputs := ([-1.,-1.,-1.] -> [1.,1.,1.])
vec3 rotateAroundYAxis( vec3 point, float angle )
{
    float cosangle = cos(angle);
    float sinangle = sin(angle);
    return vec3(point.x * cosangle  + point.z * sinangle,
                point.y,
                point.x * -sinangle + point.z * cosangle);
}

// Rotate the input point around the x-axis by the angle (given in radians)
// Range of outputs := ([-1.,-1.,-1.] -> [1.,1.,1.])
vec3 rotateAroundXAxis( vec3 point, float angle )
{
    float cosangle = cos(angle);
    float sinangle = sin(angle);
    return vec3(point.x,
                point.y * cosangle - point.z * sinangle,
                point.y * sinangle + point.z * cosangle);
}

// Returns the floor and ceiling of the given float
vec2 floorAndCeil( float x ) 
{
    return vec2(floor(x), ceil(x));
}

// Returns the floor and ceiling of each component in respective
// order (floor(p.x), ceil(p.x), floor(p.y), ceil(p.y)) 
vec4 floorAndCeil2( vec2 p ) 
{
    return vec4(floorAndCeil(p.x), 
                floorAndCeil(p.y));
}

// Returns 2 floats, the first is the rounded value of float.  The second
// is the direction in which the rounding took place.  So if rounding 
// occurred towards a larger number 1 is returned, otherwise -1 is returned. 
vec2 round( float x ) 
{
    return vec2(floor(x+0.5), sign(fract(x)-0.5));
}

// Returns 4 floats, 
// the first is the rounded value of p.x
// the second is the direction in which the rounding took place for p.x
// So if rounding occurred towards a greater number 1 is returned, 
// otherwise -1 is returned
// the third is the rounded value of p.y.  
// the fourth is the direction in which the rounding took place for p.y
vec4 round2( vec2 p ) 
{
    return vec4(round(p.x), round(p.y));
}

// Given the vec3 values, mix between them such that 
//  result=v1 at mod(x,4)=0,3
//  result=v2 at mod(x,4)=1
//  result=v3 at mod(x,4)=2

vec3 periodicmix(vec3 v1, 
                 vec3 v2, 
                 vec3 v3, 
                 float x)
{
    float modx = mod(x, 3.);
    return mix(v1, 
                mix(v2, 
                    mix(v3, 
                        v1,
                        clamp(modx - 2., 0., 1.)), 
                    clamp(modx - 1., 0., 1.)), 
                clamp(modx, 0., 1.));
}

// **************************************************************************
// SIGNAL FUNCTIONS
// **************************************************************************


// Returns a noise wave within the range [-1, 1] for which
// each octave has a different scale on the phaseOffset.  The
// phaseOffset is usually a dimension of time.
vec3 phasedfractalwave(vec3 p, float phaseOffset)
{       

    // rotation matrix for noise octaves
    mat3 octaveMatrix = mat3( 0.00,  0.80,  0.60,
                              -0.80,  0.36, -0.48,
                              -0.60, -0.48,  0.64 );

    vec3 signal = .5 * sin(p + phaseOffset);
    p = octaveMatrix*p*1.32;    
    signal += .3 * sin(p + 2.2 * phaseOffset);
    p = octaveMatrix*p*1.83;
    signal += .2 * sin(p + 5.4 * phaseOffset);

    signal /= 1.0;
    return signal;
}

// Periodic saw tooth function that repeats with a period of 
// 4 and ranges from [-1, 1].  
// The function starts out at 0 for x=0,
//  raises to 1 for x=1,
//  drops to 0 for x=2,
//  continues to -1 for x=3,
//  and then rises back to 0 for x=4
// to complete the period

float sawtooth( float x )
{
    float xmod = mod(x+3.0, 4.);
    return abs(xmod-2.0) - 1.0;
}

vec3 xyz2rgb(vec3 xyz)
{               
    // Taken from XYZ to sRGB transformation:
    // reference: http://en.wikipedia.org/wiki/SRGB    
    mat3 xyz2rgbMat = mat3( 3.2404190, -1.5371500, -0.4985350,
                           -0.9692560,  1.8759920,  0.0415560,
                            0.0556480, -0.2040430,  1.0573110);
     
    vec3 color = xyz * xyz2rgbMat;

    // Get sRGB out of its gamma space
    color = pow(color, vec3(1./2.2));
    return clamp(color, vec3(0.), vec3(1.));
}

vec3 blackBodyColor(float T)
{
    
    float x = 0.;
    float y = 0.;

    // Cubic approximation of the Planckian Locus as a function of temperature
    // reference: http://en.wikipedia.org/wiki/Planckian_locus
    
    // The approximation puts the color in CIE xyY space (Y is luminance, x
    // and y are perseptively measured values that can be transformed into
    // sRGB)
    float T2 = T * T;
    float T3 = T2 * T;

    // DEBRANCHED
    // Equivalent to :
    // if (T < 4000.) {
    //     x = (-0.2661239e9/T3 - 0.2343580e6/T2 + 0.8776956e3/T + .179910);
    //     float x2 = x * x;
    //     float x3 = x2 * x;
    //     if (T < 2222.) {
    //         y = -1.1063814*x3 - 1.34811020*x2 + 2.18555832*x - 0.20219683;
    //     } else {
    //         y = -0.9549476*x3 - 1.37418593*x2 + 2.09137015*x - 0.16748867;
    //     }
    // } else if (4000. <= T) {
    //     x = (-3.0258469e9/T3 + 2.1070379e6/T2 + 0.2226347e3/T + .240390); 
    //     float x2 = x * x;
    //     float x3 = x2 * x;
    //     y = 3.0817580*x3 - 5.87338670*x2 + 3.75112997*x - 0.37001483;          
    // }

    float isTlt4000 = step(-4000., -T);
    float isTlt2222 = step(-2222., -T);

    float xlt4000 = (-0.2661239e9/T3 - 0.2343580e6/T2 + 0.8776956e3/T + .179910);
    float xlt4000_2 = xlt4000 * xlt4000;
    float xlt4000_3 = xlt4000_2 * xlt4000;
    float ylt2222 = -1.1063814*xlt4000_3 - 1.34811020*xlt4000_2 + 2.18555832*xlt4000 - 0.20219683;
    float ygt2222 = -0.9549476*xlt4000_3 - 1.37418593*xlt4000_2 + 2.09137015*xlt4000 - 0.16748867;

    float xgt4000 = (-3.0258469e9/T3 + 2.1070379e6/T2 + 0.2226347e3/T + .240390); 
    float xgt4000_2 = xgt4000 * xgt4000;
    float xgt4000_3 = xgt4000_2 * xgt4000; 
    float ygt4000 = 3.0817580*xgt4000_3 - 5.87338670*xgt4000_2 + 3.75112997*xgt4000 - 0.37001483;  
    
    x = mix(xgt4000, xlt4000, isTlt4000);
    y = mix(mix(ygt2222, ylt2222, isTlt2222), ygt4000, isTlt4000);

    // XXX: This smoothstep cheat from 1666 to 14000 is a cheat that looks
    // perceptively good.  What I should be doing is calculating the maximum
    // wavelength using Wien's displacement law and then finding the intensity
    // by plugging that wavelength into Planck's law:
    // http://en.wikipedia.org/wiki/Black-body_radiation
    
    // Translate from CIE xyY to CIE XYZ space which can then be transferred
    // to sRGB space.
    float Y = pow(smoothstep(1666., 14000., T), .25);  
    float X = (Y/y) * x;
    float Z = (Y/y) * ( 1. - x - y );

    return xyz2rgb(vec3(X, Y, Z));

}

// **************************************************************************
// INTERSECT UTILITIES
// **************************************************************************

// intersection for a sphere with a ray.
//
// If negateDiscriminant is set, this will act as if we're tracing a 
// "black hole" like effect where the hole size is the radius.
//
// Returns a vec3 where:
//  result.x = 1. or 0. to indicate if a hit took place
//  result.y = tmin
//  result.z = tmax

vec3 intersectSphere(vec3 rayOrigin,                 
                     vec3 rayDir, 
                     float radius,
                     vec3 sphereCenter,
                     float negateDiscriminant)
{

    // Calculate the ray origin in object space of the sphere
    vec3 ospaceRayOrigin = rayOrigin - sphereCenter;
    
    float a = dot(rayDir, rayDir);
    float b = 2.0*dot(ospaceRayOrigin, rayDir);
    float c = dot(ospaceRayOrigin, ospaceRayOrigin) - radius*radius;
    float discr = mix(1., -1., step(0.5, negateDiscriminant)) * (b*b - 4.0*a*c); // discriminant

    float tmin = 0.0;
    float tmax = 0.0;

    // DEBRANCH
    // Equivalent to:
    // if (discr > 0.) {
    //     ...
    // }

    float isdiscrgtZero = step(0., discr);

    // Real root of disc, so intersection
    float sdisc = sqrt(discr);
    tmin = (-b - sdisc)/(2.0 * a);
    tmax = (-b + sdisc)/(2.0 * a); 

    float hit = max(step(0., tmin), step(0., tmax));

    return mix(vec3(0.), vec3(hit, tmin, tmax), isdiscrgtZero);
}

// Reference: http://geomalgorithms.com/a05-_intersect-1.html. Does an
// intersection test against a plane that is assumed to be double sided and
// passes through the origin and has the specified normal.

// Returns a vec2 where:
//   result.x = 1. or 0. if there is a hit
//   result.y = t such that origin + t*dir = hit point
vec2 intersectDSPlane(vec3 origin,
                      vec3 dir,
                      vec3 planeNormal,
                      vec3 planeOffset)
{
    float dirDotN = dot(dir, planeNormal);
    // if the ray direction is parallel to the plane, let's just treat the 
    // ray as intersecting *really* far off, which will get culled as a
    // possible intersection.

    float denom = zeroTolerantSign(dirDotN) * max(abs(dirDotN), EPSILON);
    float t = min(BIG_FLOAT, -dot(planeNormal, (origin - planeOffset)) / denom);    
    return vec2(step(EPSILON, t), t);

}

// Reference: http://geomalgorithms.com/a05-_intersect-1.html Does an
// intersection test against a plane that is assumed to  be single sided and
// passes through a planeOffset and has the specified normal.

// References: 
// http://www.geometrictools.com/Documentation/IntersectionLineCone.pdf
// http://www.geometrictools.com/LibMathematics/Intersection/Intersection.html
//
// Does an intersection with an infinite cone centered at the origin and 
// oriented along the positive y-axis extending to infinite.  Returns the 
// minimum positive value of t if there is an intersection.  

// This function works by taking in the latitudinal parameters from -PI/2 to
// PI/2 which correspond to the latitudinal of the x-z plane.  The reference
// provided assumes the angle of the cone is determined based on the cone angle
// from the y-axis.  So instead of using a cosine of the angle as described in
// the reference, we use a sine of the angle and also consider whether the
// angle is positive or negative to determine which side of the pooled cone
// we are selecting.
//
// If the angle of the z-x plane is near zero, this function just does a an
// intersection against the x-y plane to handle the full range of possible
// input.  This function clamps any angles between -PI/2 and PI/2.

// Returns a vec2 where:
//   result.x = 1. or 0. if there is a hit
//   result.y = t such that origin + t*dir = hit point

// Returns a vec2 where:
//   result.x = 1. or 0. if there is a hit
//   result.y = t such that origin + t*dir = hit point
vec2 intersectSimpleCone(vec3 origin,
                         vec3 dir,
                         float coneAngle)
{
    
    // for convenience, if coneAngle ~= 0., then intersect
    // with the x-z plane.      
    float axisDir = zeroTolerantSign(coneAngle);
    float clampedConeAngle = clamp(abs(coneAngle), 0., PI/2.);    
    
    float t = 0.;

    if (clampedConeAngle < EPSILON) {
        t = -origin.y / dir.y;
        return vec2(step(0., t), t);
    }
    
    // If coneAngle is 0, assume the cone is infinitely thin and no
    // intersection can take place
    if (clampedConeAngle < EPSILON) {
        return vec2(0.);
    }
    
    float sinAngleSqr = sin(clampedConeAngle);
    sinAngleSqr *= sinAngleSqr;

    // Quadric to solve in order to find values of t such that 
    // origin + direction * t intersects with the pooled cone.
    // 
    // c2 * t^2 + 2*c1*t + c0 = 0
    //
    // This is a little math trick to get rid of the constants in the 
    // classic equation t = ( -b +- sqrt(b^2 - 4ac) ) / 2a
    // by making b = 2*c1, you can see how this helps divide out the constants
    // t = ( -2 * c1 +- sqrt( 4 * c1^2 - 4 * c2c0) / 2 * c2
    // see how the constants drop out so that
    // t = ( -c1 +- sqrt( c1^2 - c2 * c0)) / c2

    // Lots of short cuts in reference intersection code due to the fact that
    // the cone is at the origin and oriented along positive y axis.
    // 
    // A := cone aligned axis = vec3(0., 1., 0.)
    // E := origin - coneOrigin = origin
    // AdD := dot(A, dir) = dir.y
    // AdE := dot(A, E) = origin.y
    // DdE := dot(dir, E) = dot(dir, origin)
    // EdE := dot(E, E) = dot(origin, origin)
    
    float DdO = dot(dir, origin);
    float OdO = dot(origin, origin);
    
    float c2 = dir.y * dir.y - sinAngleSqr;
    float c1 = dir.y * origin.y - sinAngleSqr * DdO;
    float c0 = origin.y * origin.y - sinAngleSqr * OdO;

    float discr = c1*c1 - c2*c0;
    float hit = 0.;

    // if c2 is near zero, then we know the line is tangent to the cone one one
    // side of the pool.  Need to check if the cone is tangent to the negative
    // side of the cone since that could still intersect with quadric in one
    // place.
    if (abs(c2) > EPSILON) {
    
        if (discr < 0.0) {
            
            return vec2(0.);
            
        } else {
    
            // Real root of disc, so intersection may have 2 solutions, fine the 
            // nearest one.
            float sdisc = sqrt(discr);
            float t0 = (-c1 - sdisc)/c2;
            float t1 = (-c1 + sdisc)/c2;
    
            // a simplification we can make since we know the cone is aligned
            // along the y-axis and therefore we only need to see how t affects
            // the y component.
            float intersectPt0y = origin.y + dir.y * t0;
            float intersectPt1y = origin.y + dir.y * t1;    
            
            // If the intersectPts y value is greater than 0. we know we've
            // intersected along the positive y-axis since the cone is aligned
            // along the y-axis
    
            // If the closest intersection point is also a valid intersection
            // have that be the winning value of t.
            
            if ((t0 >= 0.) &&
                (axisDir * intersectPt0y > 0.)) {
                t = t0;
                hit = 1.;
            }
            
            if ((t1 >= 0.) &&
                ((t1 < t0) || (hit < .5)) &&
                (axisDir * intersectPt1y > 0.)) {
                t = t1;     
                hit = 1.;
            }
    
        } 

    } else if (abs(c1) > EPSILON) {
        // This is the code to handle the case where there  is a ray that is on
        // the pooled cone and intersects at the very tip of the cone at the
        // origin.
        float t0 = -0.5 * c0 / c1;
        
        float intersectPty = origin.y + dir.y * t0;
        if (( t0 >= 0.) && (axisDir * intersectPty > 0.)) {
            t = t0;
            hit = 1.;
        }       
    }
    
    return vec2(hit, t);

}

// Returns the vector that is the shortest path from the bounded line segment
// u1->u2 to the line represented by the line passing through v1 and v2.  
//
// result.x is the distance of the shortest path between the line segment and
// the unbounded line
//
// result.y = is the value of t along the line segment of ba [0,1] that 
// represents the 3d point (p) of the shortest vector between the two line 
// segments that rests on the vector between u1 anb u2 such that 
//    p = u1 + (u2-u1) * t
//
// result.z = is the value of t along the line passing through v1 and v2 such
// that q represents the closest point on the line to the line segment u2<-u1:
//    q = v1 + (v2-v1) * t
// t is unbounded in this case but is parameterized such that t=0 at v1 and t=1
// at v2.

vec3 segmentToLineDistance( vec3 u1, 
                            vec3 u2, 
                            vec3 v1, 
                            vec3 v2 )
{
    vec3 u = u2 - u1;
    vec3 v = v2 - v1;
    vec3 w = u1 - v1;
    
    // For the maths:
    // http://geomalgorithms.com/a07-_distance.html#dist3D_Segment_to_Segment
    float a = dot(  u, u );
    float b = dot(  u, v ); 
    float c = dot(  v, v );   
    float d = dot(  u, w );
    float e = dot(  v, w ); 
    
    // just a way of calculating two equations with one operation.
    // th.x is the value of t along ba
    // th.y is the value of t along wv 

    // when a*c - b*b is near 0 (the lines are parallel), we will just assume
    // a close line is the distance between u1 and v1
    float denom = (a * c - b * b);

    // DEBRANCHED
    // Equivalent to:
    // vec2 th = (abs(denom) < EPSILON ? vec2(0.) : 
    //                                  vec2( b*e - c*d, a*e - b*d ) / denom);

    float clampedDenom = sign(denom) * max(EPSILON, abs(denom));
    vec2 th = mix( vec2( b*e - c*d, a*e - b*d ) / clampedDenom, 
                   vec2(0.),
                   step(abs(denom), EPSILON));

    // In the case where the line to line comparison has p be a point that lives
    // off of the bounded segment u2<-u1, just fine the closest path between u1
    // and u2 and pick the shortest

    float ifthxltZero = step(th.x, 0.);
    float ifthxgt1 = step(1., th.x);

    // DEBRANCHED
    // Equivalent to:
    // if (th.x < 0.) {
    //     th.x = 0.;
    //     th.y = dot(v, u1-v1) / c; // v . (u1<-v1) / v . v
    // } else if (th.x > 1.) {
    //     th.x = 1.;
    //     th.y = dot(v, u2-v1) / c; // v . (u2<-v1) / v . v
    // }
    
    th.x = clamp(th.x, 0., 1.);
    th.y = mix(th.y, dot(v, u1-v1) / c, ifthxltZero);
    th.y = mix(th.y, dot(v, u2-v1) / c, ifthxgt1);
    
    // p is the nearest clamped point on the line segment u1->u2
    vec3 p = u1     + u  * th.x;
    // q is the nearest unbounded point on the line segment v1->v2
    vec3 q = v1     + v  * th.y;
    
    return vec3(length(p-q), th.x, th.y);
}

// Returns the vector that is the shortest path from the 3D point to the line
// segment as well as the parameter t that represents the length along the line
// segment that p is closest to.

// Returned result is:

// result.xyz := vector of the path from p to q where q is defined as the point
// on the line segment that is closest to p.
// result.w   := the t parameter such that a + (b-a) * t = q 

vec4 segmentToPointDistance( vec3 a, 
                             vec3 b, 
                             vec3 p)
{
    
    vec3 ba = b - a;    
    float t = dot(ba, (p - a)) / max(EPSILON, dot(ba, ba));
    t = clamp(t, 0., 1.);
    vec4 result = vec4(ba * t + a - p, t);
    return result;
}

// Returns the vector that is the shortest path from the 3D point to the  line
// that passes through a and b as well as the parameter t that represents the
// length along the line that p is closest to.

// Returned result is:

// result.xyz := vector of the path from p to q where q is defined as the point
// on the line segment that is closest to p.
// result.w   := the t parameter such that a + (b-a) * t = q 

vec4 lineToPointDistance( vec3 a, 
                          vec3 b, 
                          vec3 p)
{
    
    vec3 ba = b - a;    
    float t = dot(ba, (p - a)) / dot(ba, ba);
    vec4 result = vec4(ba * t + a - p, t);
    return result;
}

// **************************************************************************
// SHADING UTILITIES
// **************************************************************************

// Approximating a dialectric fresnel effect by using the schlick approximation
// http://en.wikipedia.org/wiki/Schlick's_approximation. Returns a vec3 in case
// I want to approximate a different index of reflection for each channel to
// get a chromatic effect.
vec3 fresnel(vec3 I, vec3 N, float eta)
{
    // assume that the surrounding environment is air on both sides of the 
    // dialectric
    float ro = (1. - eta) / (1. + eta);
    ro *= ro;
    
    float fterm = pow(1. - dot(-I, N), 5.);  
    return vec3(ro + ( 1. - ro ) * fterm); 
}

// Classic formula for desaturating a color:
// http://www.gamedev.net/topic/373341-colormath-desaturation/
vec3 desat(vec3 color, float desatAmt)
{
    vec3 gray = vec3(dot(color, vec3(0.3, .59, .11)));
    return mix(color, gray, desatAmt);
}


// **************************************************************************
// AUDIO UTILITIES
// **************************************************************************

float getAudioScalar(float t)
{

    float audioScalar =  10. *  g_audioFreqs[0] * sin(-2.  * 
        (g_beatRate * g_time - PI_OVER_TWO * t));

    audioScalar +=       5. *  g_audioFreqs[1] * sin(-4.  * 
        (g_beatRate * g_time - PI_OVER_TWO * t));

    audioScalar +=       5. *  g_audioFreqs[2] * sin(-8.  * 
        (g_beatRate * g_time - PI_OVER_TWO * t));

    audioScalar +=       5. *  g_audioFreqs[3] * sin(-16. * 
        (g_beatRate * g_time - PI_OVER_TWO * t));

    return (audioScalar + 10.)/20.;
}

// **************************************************************************
// TRACE UTILITIES
// **************************************************************************

// This ray structure is used to march the scene and accumulate all final
// results.

struct SceneRayStruct {
    vec3 origin;        // origin of the ray - updates at refraction, 
                        // reflection boundaries
    vec3 dir;           // direction of the ray - updates at refraction, 
                        // reflection boundaries

    float marchDist;    // current march distance of the ray - updated during
                        // tracing
    float marchMaxDist; // max march distance of the ray - does not update

    vec4 color;         // accumulated color and opaqueness of the ray - updated
                        // during tracing

    vec4 debugColor;    // an alternative color that is updated during
                        // traversal if it has a non-zero opaqueness, then it
                        // will be returned to the frame buffer as the current
                        // frag color. Alpha is ignored when displaying to the 
                        // frag color.
};

// Function used to determine if we should discontinue marching down this 
// ray.  Returns true when the ray should be terminated.
bool shouldTerminateSceneRay(SceneRayStruct sceneRay)
{
    return ((sceneRay.marchDist >= sceneRay.marchMaxDist) || 
            (sceneRay.color.a > 0.95) ||
            (sceneRay.debugColor.a > 0.));
}

// This ray structure is used to march through a space that represents the
// interior of the orbs and is chopped up into cells whose boundaries are
// aligned with the azimuthal and latitudinal angles of the sphere.

// Looking at a cross section of the orb from the azimuthal direction (from
// top down). You can see how in this case of a sphere divided into 8
// subdomains, the cell coordinates wrap at the back of the sphere.

//
//        . * ' * .
//      *   8 | 1   *
//    *  \    |    /  *
//   /  7  \  |  /  2  \
//  *________\|/________*
//  *        /|\        *
//   \  6  /  |  \  3  /
//    *  /    |    \  *
//      *   5 | 4   *
//        ' * . * ' 
//
//        V Front V


// Looking at a cross section of the orb from the side split down the center.
// You can see in this example of the latitudinal cells having 4 subdomains
// (or cells), the latitudinal cells are divided by cones originating from the
// sphere center.

//
//        . * ' * .
//      * \   4   / *
//    *    \     /    *
//   /  3   \   /   3  \
//  *________\ /________*
//  *        / \        *
//   \  2   /   \   2  /
//    *    /     \    *
//      * /   1   \ *
//        ' * . * '
//
//        V Bottom V

struct OrbRayStruct {
    vec3 origin;                  // origin of the ray to march through the
                                  // orb space - does not update
    
    vec3 dir;                     // direction of the ray to march through the
                                  // orb space - does not update

    float marchDist;              // current march distance of the ray through
                                  // the sphere - updated during tracing

    float marchNextDist;          // represents the next extent of the current
                                  // cell so we can create a line segment on
                                  // the ray that represents the part of the
                                  // line that is clipped by the orb cell
                                  // boundaries.  We then use this line
                                  // segment to perform a distance test  of
                                  // the spark

    float marchMaxDist;           // max march distance of the ray - does not 
                                  // update represents the other side the sphere
 
    int azimuthalOrbCellMarchDir; // when marching through the orb cells, we
                                  // keep track of which way the ray is going
                                  // in the azimuthal direction, so we only
                                  // need to test against one side of the
                                  // orb cell - a plane that lies on the
                                  // y-axis and is rotated  based on the
                                  // current cell.  This avoids precision
                                  // issues calculated at beginning of
                                  // traversal and used through out the
                                  // iterations.

    vec2 orbCellCoords;     
                                  // Keep track of the current orb cell
                                  // we're in: x is the latitudinal cell number
                                  // y is the azimuthal cell number

    vec4 color;                   // accumulated color and opaqueness of the ray
                                  // marching the orbs.

    vec4 debugColor;              // an alternative color that is updated during
                                  // traversal if it has a non-zero opaqueness,
                                  // then it will be returned to the frame
                                  // buffer as the current frag color

};
    
// Function used to determine if we should discontinue marching down this 
// ray.  Returns true when the ray should be terminated.
bool shouldTerminateOrbRay(OrbRayStruct orbRay)
{
    return ((orbRay.marchDist >= orbRay.marchMaxDist) || 
            (orbRay.color.a > 0.95) ||
            (orbRay.debugColor.a > 0.));
}

// Function used for ray marching the interior of the orb.  The sceneRay is 
// also passed in since it may have some information we want to key off of.
//
// Returns the OrbRayStruct that was passed in with certain parameters
// updated.
OrbRayStruct rayMarchOrbInterior(in OrbRayStruct orbRay)
{    
    
    // Before marching into the orb coordinates, first determine if the orbRay
    // is casting in the direction of the sphere where the "angle" is increasing
    // along the azimuthal direction, in which case we assume we are marching
    // along the azimuthal cells in a positive direction.

    vec3 orbRayEnd = orbRay.origin + orbRay.dir * orbRay.marchMaxDist;
    vec4 ltpresult = lineToPointDistance(orbRay.origin, orbRayEnd, vec3(0.));
    vec3 ltp = ltpresult.xyz;
    vec3 rdircrossltp = normalize(cross(orbRay.dir, ltp));
        
    orbRay.azimuthalOrbCellMarchDir = (dot(rdircrossltp, 
                                      vec3(0., 1., 0.)) > 0.) ? 1 : -1;  


    // ------------------------------------------------------------
    // Convert the cartesian point to orb space within the range
    // Latitudinal    := [-PI/2, PI/2]
    // Azimuth        := [-PI, PI]
    vec2 orbRayOriginPt = cartesianToPolar(orbRay.origin);                
    
    //
    // convert orb coordinates into number of spark domains       
    // Latitudinal    := [-PI/2, PI/2]
    // Azimuth        := [-PI, PI]
    // LatdDomains    := [-numLatdDomains/2., numLatdDomains/2.] 
    // AzimuthDomains := [-numAzimDomains/2., numAzimDomains/2.]
    // In order to avoid confusion        

    orbRayOriginPt -= g_sparkRotationRate * g_time;
    orbRayOriginPt *= g_numOrbCells * vec2(1./PI, 1./TWO_PI);

    vec4 rOrbRayOriginPtResults = round2(orbRayOriginPt);
    vec2 cellCoords = vec2(rOrbRayOriginPtResults.xz);                        
    cellCoords -= vec2(.5,.5) * rOrbRayOriginPtResults.yw;

    orbRay.orbCellCoords = cellCoords;

    // ------------------------------------------------------------
    // March through the orb cells a fixed number of steps - can control
    // quality knob by adjusting
    
    // Define the 3 spark colors that we'll be mixing between:

    // XXX: the interpolation between colors is not correct (would be best to be 
    // in a perceptually linear space).  For next time...

    vec3 sparkci1 = vec3(1.1, 0.5, 0.5);
    vec3 sparkco1 = vec3(1.2, 1.2, 2.3);

    vec3 sparkci2 = vec3(0.5, 0.2, 0.6);
    vec3 sparkco2 = vec3(0.6, 0.8, 1.2);

    vec3 sparkci3 = vec3(1.2, 0.8, 1.4);
    vec3 sparkco3 = vec3(1.7, 1.3, 0.9);

    for ( int i = 0; i < NUM_POLAR_MARCH_STEPS; i++)
    {
        // If orbRay color has near opaque opacity, no need to continue marching
        if (shouldTerminateOrbRay(orbRay)) continue;
        
        vec3 marchPoint = orbRay.origin + orbRay.dir * orbRay.marchDist;
        
        // Convert the cartesian point to orb space within the range
        // Latitudinal    := [-PI/2, PI/2]
        // Azimuth        := [-PI, PI]
        vec2 orbMarchPt = cartesianToPolar(marchPoint);                
        
        // convert orb coordinates into number of cell domains       
        // From:
        // Latitudinal    := [-PI/2, PI/2]
        // Azimuth        := [-PI, PI]
        // To:
        // LatdDomains    := [-numLatdDomains/2., numLatdDomains/2.] 
        // AzimuthDomains := [-numAzimDomains/2., numAzimDomains/2.]

        orbMarchPt -= g_sparkRotationRate * g_time;
        orbMarchPt *= g_numOrbCells * vec2(ONE_OVER_PI, ONE_OVER_TWO_PI);

        vec2 orbSparkStart = orbRay.orbCellCoords;     
        
        // convert back into orb coordinate range 
        // Latitudinal      := [-PI/2, PI/2]
        // Azimuth        := [-PI, PI] 
        vec2 remapOrbSparkStart = orbSparkStart * vec2(PI, TWO_PI) / 
                                            g_numOrbCells;
                
        remapOrbSparkStart += g_sparkRotationRate * g_time;     
                
        // ------------------------------------------------------------------
        // Spark color contribution

        vec3 sparkDir = polarToCartesian(remapOrbSparkStart);
        vec3 sparkOrigin = g_orbCenterRadius * sparkDir;
        vec3 sparkEnd = g_orbOuterRadius * sparkDir;
                
        vec3 sparkResult = segmentToLineDistance(sparkOrigin,
                                                 sparkEnd,
                                                 orbRay.origin,
                                                 orbRayEnd);

        vec3 sparkColor = vec3(0.);
        float sparkOpacity = 0.;        

        float sparkSeed = (orbRay.orbCellCoords.x + g_numOrbCells.x *.5)/(g_numOrbCells.x);
        float sparkSeedMix = step(1. - mod(g_time, g_sparkColorMixInterval)/g_sparkColorMixInterval, 
                                            sparkSeed);

        float sparkColorMix = mix(g_sparkColorMixTrailingLimit,
                                  g_sparkColorMixLeadingLimit,
                                  sparkSeedMix);
        
        vec3 sparkColorInner = periodicmix(sparkci1, 
                                           sparkci2, 
                                           sparkci3, 
                                           sparkColorMix);

        vec3 sparkColorOuter = periodicmix(sparkco1, 
                                           sparkco2, 
                                           sparkco3, 
                                           sparkColorMix);

        float sparkGlowExtent = g_sparkWidth;

        float audioScale = 1. + 2. * getAudioScalar(sparkResult.y);
        audioScale = audioScale + .5 * g_bassBeat;
        sparkGlowExtent *= audioScale;

        float sparkAlphaExtent = 1.15 * sparkGlowExtent;
        float sparkAttenuate = abs(sparkResult.x);

        float sparkAmt = 1. * smoothstep(sparkAlphaExtent, 
                                         0., 
                                         sparkAttenuate);               
        
        // Multiply the spark color based on a black body curve.  The 
        // inputs to blackBodyColor is temperature in Kelvins.  The idea is
        // that the spark is "hotter" towards the center.
        
        sparkColor = blackBodyColor(2000. + 
                                    10000. * sparkResult.y * audioScale) * 
                      mix(sparkColorInner, 
                          sparkColorOuter, 
                          sparkResult.y);

        float sparkCorePresence = pow(smoothstep(sparkGlowExtent, 
                                           0., 
                                           sparkAttenuate),2.);

        sparkColor = (g_sparkColorIntensity * (1. - orbRay.color.a) * 
                      sparkColor * sparkCorePresence);

        sparkOpacity = ((1. - orbRay.color.a) * 
                        smoothstep(sparkAlphaExtent, 
                                   0., 
                                   sparkAttenuate));
        

        // ------------------------------------------------------------------
        // Compute the cell bound marching
        
        // Test the boundary walls of a polar cell represented by the floor or ceil
        // of the polarized march pt.  The boundary walls to test are determined
        // based on how we're marching through the orb cells.

        // Remember that x is the latitudinal angle so to find it's boundary, we
        // intersect with a cone.  y is the azimuth angle so we can more simply
        // intersect the plane that is perpendicular with the x-z plane and
        // rotated around the y-axis by the value of the angle.

        // Remember to remap the floors and ceils to   
        // Latitudinal      := [-PI/2, PI/2]
        // Azimuth          := [-PI, PI]
        vec4 orbCellBounds = floorAndCeil2(orbRay.orbCellCoords) *
            vec2(PI, TWO_PI).xxyy / g_numOrbCells.xxyy;
        
        orbCellBounds += g_sparkRotationRate.xxyy * g_time;
        
        float nextRelativeDist = orbRay.marchMaxDist - orbRay.marchDist;
        float t = BIG_FLOAT;        
        vec2 cellCoordIncr = vec2(0.);

        // Intersect with the planes passing through the origin and aligned
        // with the y-axis.  The plane is a rotation around the y-axis based
        // on the  azimuthal boundaries.  Remember we know which direction the
        // ray is traveling so we only need to test one side of the cell.        
        float orbNextCellAzimAngle = (orbRay.azimuthalOrbCellMarchDir < 0 ? 
                                        orbCellBounds.z : orbCellBounds.w);

        vec3 orbNextCellAzimBound = vec3(-sin(orbNextCellAzimAngle), 
                                          0., 
                                          cos(orbNextCellAzimAngle));

        vec2 intersectResult = intersectDSPlane(marchPoint, orbRay.dir, 
                                                orbNextCellAzimBound, vec3(0.) );

        // DEBRANCHED
        // Equivalent to:
        //
        // if ((intersectResult.x > 0.5) && (nextRelativeDist > intersectResult.y)) {
        //    nextRelativeDist = intersectResult.y;
        //    cellCoordIncr = vec2(0., orbRay.azimuthalOrbCellMarchDir);            
        // }

        float isAzimPlaneHit = intersectResult.x * step(intersectResult.y, nextRelativeDist);
        nextRelativeDist = mix(nextRelativeDist, intersectResult.y, isAzimPlaneHit);
        cellCoordIncr = mix(cellCoordIncr, vec2(0., orbRay.azimuthalOrbCellMarchDir), isAzimPlaneHit);
        
        // XXX Future work: It would be nice if we only test one side of the
        // cell wall in the latitudinal direction based on the direction of the
        // orb ray as it marches through the cells, like what I'm doing with the
        // azimuthal direction. But due to some shader issues and the extra
        // complexity this adds to the  code, this seems like a more stable
        // approach.  If we do go down this road, you could determine which
        // direction the ray is travelling but you'll need to test if that ray
        // crosses the "dividing plane" since the "negative" direction will
        // become the "positive" direction at  that point.  Perhaps this
        // indicates I need to rethink how the  orb cell coordinates are
        // defined.  I think solving this problem will get to the bottom of the
        // flickering that happens.

        // Test the top of the current orb cell
        intersectResult = intersectSimpleCone(marchPoint, orbRay.dir, orbCellBounds.x);

        // DEBRANCHED
        // Equivalent to:
        //
        // if ((intersectResult.x > 0.5) && (nextRelativeDist > intersectResult.y)) {
        //    nextRelativeDist = intersectResult.y;
        //    cellCoordIncr = vec2(-1., 0.);            
        // }
        
        float isTopConeHit = intersectResult.x * step(intersectResult.y, nextRelativeDist);
        nextRelativeDist = mix(nextRelativeDist, intersectResult.y, isTopConeHit);
        cellCoordIncr = mix(cellCoordIncr, vec2(-1, 0.), isTopConeHit);

        // Test the bottom of the current orb cell
        intersectResult = intersectSimpleCone(marchPoint, orbRay.dir, orbCellBounds.y);

        // DEBRANCHED
        // Equivalent to:
        //
        // if ((intersectResult.x > 0.5) && (nextRelativeDist > intersectResult.y)) {
        //    nextRelativeDist = intersectResult.y;
        //    cellCoordIncr = vec2(-1., 0.);            
        // }

        float isBottomConeHit = intersectResult.x * step(intersectResult.y, nextRelativeDist);
        nextRelativeDist = mix(nextRelativeDist, intersectResult.y, isBottomConeHit);
        cellCoordIncr = mix(cellCoordIncr, vec2(1, 0.), isBottomConeHit);
        
        // ------------------------------------------------------------------
        // Update orbRay for next march step

        // We now know what cell we're going to march into next
        // XXX: There is a fudge factor on the EPSILON here to get around some
        // precision issues we're seeing with intersecting the simple cones. 
        // This probably indicates there is something flawed in the cell logic
        // traversal.
        orbRay.marchNextDist = min(orbRay.marchMaxDist, orbRay.marchDist + nextRelativeDist + 35. * EPSILON);
        orbRay.orbCellCoords += cellCoordIncr;

        // Make sure that y wraps (the azimuthal dimension) when you've reached
        // the extent of the number of orb cells
        orbRay.orbCellCoords.y = mod(orbRay.orbCellCoords.y + g_numOrbCells.y/2., 
                                     g_numOrbCells.y) - g_numOrbCells.y/2.;
        
        orbRay.marchDist = orbRay.marchNextDist;        
        
        // ------------------------------------------------------------------
        // Shade the center of the orb interior itself (only if this cell's
        // march has intersected with that center interior).  Avoid an if 
        // statement here by having the signal that drives the presense of 
        // this color come on only when the ray is intersecting that orb
        // interior.

        vec3 orbCenterColor = sparkColorInner * blackBodyColor(14000.);
        vec3 marchExit = orbRay.origin + orbRay.dir * orbRay.marchNextDist;  

        vec4 segToPtResult = segmentToPointDistance(marchPoint,
                                                    marchExit,
                                                    vec3(0.));
        
        float distToCenter = length(segToPtResult.xyz);

        float centerOrbProximityMask = smoothstep(g_orbCenterRadius + 1., 
                                                  g_orbCenterRadius, 
                                                  distToCenter);

        float sparkOriginGlowMaxDist = mix(2.5, 0.5, 
                                           smoothstep(8., 
                                                      128., 
                                                      min(g_numOrbCells.x, 
                                                          g_numOrbCells.y)));
        
        float sparkOriginGlow = min(sparkOriginGlowMaxDist, abs(sparkOriginGlowMaxDist - 
                                      distance(segToPtResult.xyz, sparkOrigin)));
        
        sparkOriginGlow = pow(sparkOriginGlow, 3.);

        // Spark origin contribution
        sparkColor += .06 * centerOrbProximityMask * sparkOriginGlow * orbCenterColor;
        sparkOpacity += .06 * centerOrbProximityMask * sparkOriginGlow;
        
        float isMarchIntersectingCenterOrb = smoothstep(g_orbCenterRadius + .1, 
                                                        g_orbCenterRadius, distToCenter);

        float centerOrbGlow = .4 * g_sparkColorIntensity * max(0., 
                    1. - dot(-normalize(segToPtResult.xyz), orbRay.dir));

        centerOrbGlow = pow(centerOrbGlow, .6);

        // Center orb glow - independent of sparks
        sparkColor += max(0., (1. - sparkOpacity)) * orbCenterColor * centerOrbGlow * isMarchIntersectingCenterOrb;
                
        orbRay.color.rgb += (1. - orbRay.color.a) * sparkColor;
        orbRay.color.a += (1. - orbRay.color.a) * sparkOpacity;
                                
        // If we want to terminate march (because we intersected the center orb), 
        // then make sure to make the alpha for this orb ray 1. 
        orbRay.color.a += (1. - orbRay.color.a) * isMarchIntersectingCenterOrb;        

    }
    
    return orbRay;
}

SceneRayStruct traceHorizon(SceneRayStruct ray)
{

    // Simple infinite horizon lookup.
    vec3 hitPoint = ray.origin + 2000. * ray.dir;

    //vec3 horizonColor = vec3(0.1,0.5, 0.9);
    //vec3 skyColor = vec3(0.1, 0.1, 0.3);
    vec3 horizonColor = iBackgroundColor;
    vec3 skyColor = iColor;
    ray.color.rgb += (1. - ray.color.a) * mix(horizonColor, 
                                              skyColor, 
                                              smoothstep(0., 900., abs(hitPoint.y)));
    ray.color.a = 1.;

    return ray;
}


SceneRayStruct tracePoolSurface(SceneRayStruct ray)
{

    // pool plane direction and offset into the ground
    vec2 intersectResult = intersectDSPlane(ray.origin, ray.dir,
                                             vec3(0., 1., 0.),                                             
                                             vec3(0., -42, 0.)); 


    vec3 hitPoint = ray.origin + ray.dir * intersectResult.y;
    vec3 hitNormal = vec3(0., 1., 0.);

    // bump mapping
    float perturbStepOff = smoothstep(2000., 200., distance(g_camOrigin, hitPoint));
    vec3 perturb = perturbStepOff * phasedfractalwave(.0125 * hitPoint, .5 * g_time);
    perturb.y = 0.;
    hitNormal += .2 * perturb;
    hitNormal = normalize(hitNormal);
    
    vec3 reflectDir = reflect(ray.dir, hitNormal);

    // Trace the reflection of the orb in the plane.
    SceneRayStruct reflRay = SceneRayStruct(hitPoint, // origin
                                            reflectDir, // direction
                                            0., // current march depth
                                            BIG_FLOAT, // max march depth                                            
                                            vec4(0.), // color
                                            vec4(0.)); // debug color

    // If the orb was not scene in the pool plane, then continue the ray
    // into the horizon.
    reflRay = traceHorizon(reflRay);

    // Apply a fresnel effect as if the pool was made of water.  We are
    // cheating the fresnel effect a bit by specifying a facing kr and an
    // edge on kr.  More creative control.
    float reflectRatio = fresnel(ray.dir,
                               hitNormal, 
                               1. / g_poolSurfaceIOR).x;

    // The pool plane is fully opaque.
    ray.color.rgb += intersectResult.x * (1. - ray.color.a) * 
        mix(g_poolSurfaceFacingKr, g_poolSurfaceEdgeOnKr, reflectRatio) * 
        reflRay.color.rgb;

    ray.color.a = mix(ray.color.a, 1., intersectResult.x);

    return ray;
}

SceneRayStruct traceOrbWarp(SceneRayStruct ray)
{

    // --------------------------------------------------------------------
    // Intersect the warp around the orb

    vec3 intersectResult = intersectSphere(ray.origin, ray.dir,
                                            g_orbOuterRadius,
                                            g_orbPosition, 1.);

    if (intersectResult.x > .5) {       
        // Apply the warp to the ray and let it continue tracing.
        vec3 hitPoint = ray.origin + intersectResult.y * ray.dir;

        vec3 ohitPoint = hitPoint - g_orbPosition;
        vec3 hitNormal = normalize(ohitPoint);
        vec3 reflectDir = normalize(reflect(ray.dir, hitNormal));   

        ray.origin = hitPoint;
        ray.dir    = reflectDir;
    }
        
    return ray;
}


SceneRayStruct traceOrb(SceneRayStruct ray)
{

    // --------------------------------------------------------------------
    // Intersect Orb test    

    vec3 intersectResult = intersectSphere(ray.origin, ray.dir,
                                            g_orbOuterRadius,
                                            g_orbPosition, 0.);

                                      
    if (intersectResult.x > 0.5) {
        ray.marchDist += intersectResult.y;

        vec3 hitPoint = ray.origin + intersectResult.y * ray.dir;

        // Translate the hit point into object space of the sphere, we march
        // the interior assuming the sphere is at the origin.
        vec3 ohitPoint = hitPoint - g_orbPosition;
        
        vec3 hitNormal = normalize(ohitPoint);
        
        // --------------------------------------------------------------------
        // Environment map reflection on orb surface

        vec3 reflectDir = normalize(reflect(ray.dir, hitNormal));   

        SceneRayStruct reflRay = SceneRayStruct(hitPoint, // origin
                                                reflectDir, // direction
                                                0., // current march depth
                                                BIG_FLOAT, // max march depth
                                                vec4(0.), // color
                                                vec4(0.)); // debug color

        reflRay = tracePoolSurface(reflRay);
        reflRay = traceHorizon(reflRay);

        vec3 reflColor = reflRay.color.rgb * reflRay.color.a;
        // Add the environment look up (heavily desaturated), to make the 
        // rim more interesting on the orb.
        // BL ERROR reflColor += .8 * desat(textureCube(iChannel0, reflectDir).rgb, .6);        
		float reflectRatio = fresnel(ray.dir, 
                                     hitNormal, 
                                     1. / g_orbIOR).x;
         ray.color.rgb += (mix(g_orbSurfaceFacingKr, g_orbSurfaceEdgeOnKr, reflectRatio) * 
                          reflColor);
        ray.color.a += (1. - ray.color.a) * reflectRatio;

        // --------------------------------------------------------------------
        // Calculate the interior distance to march
         
        vec3 refractDir = normalize(refract(ray.dir, hitNormal, 1. / g_orbIOR));    
            
        // Consider the interior sphere when ray marching?
        vec3 innerIntersectResult = intersectSphere(ohitPoint, refractDir, 
                                                    g_orbCenterRadius,
                                                    vec3(0.), 0.);
         float interiorSphereHitDist = mix(BIG_FLOAT, innerIntersectResult.y, innerIntersectResult.x);

        // --------------------------------------------------------------------
        // Orb Interior Shading     

        float rayExtent = min(interiorSphereHitDist, intersectResult.z - intersectResult.y);
        
        OrbRayStruct orbRay = OrbRayStruct(ohitPoint, // origin
                                           refractDir, // dir
                                           0., // ray parameterized start
                                           0., // the next ray march step
                                           rayExtent, // ray parameterized end
                                           0, //  azimuthalOrbCellMarchDir
                                           vec2(0.), // orbCellCoords
                                           vec4(0.), // color
                                           vec4(0.));  // debugColor 

       	orbRay = rayMarchOrbInterior(orbRay); 

        // --------------------------------------------------------------------
        // Transfer the orb ray march results to the scene ray trace IF we actually
        // intersected with the orb at all. 

        ray.color.rgb += (1. - ray.color.a) * orbRay.color.rgb;
        ray.color.a += (1. - ray.color.a) * orbRay.color.a;

        ray.debugColor += orbRay.debugColor;

        // Update the ray to be refracted out the back and reset the march
        // distance.
        ray.origin = ray.origin + refractDir * rayExtent;
        vec3 exitNormal = normalize(-ray.origin);

        ray.dir = refract(refractDir, exitNormal, 1. / g_orbIOR);
        ray.marchDist = 0.;
        ray.marchMaxDist = BIG_FLOAT;

        reflectRatio = fresnel(refractDir, 
                               -exitNormal, 
                               1. / g_orbIOR).x;

        ray.color.a += (1. - ray.color.a) * 
            mix(g_orbSurfaceEdgeOnKr, g_orbSurfaceFacingKr, (1. - reflectRatio));
  
    }
        
    return ray;
}

SceneRayStruct traceScene(SceneRayStruct ray)
{

    // Perform the tracing of the scene, first by finding any orb to
    // trace, then if the ray still has "transparency" worth 
    // tracing, continue to trace the pool plane and then the horizon.
    // The order of tracing calls is important since recursion 
    // isn't possible.   
    
    ray = traceOrb(ray);
    
    ray = traceOrbWarp(ray);

    ray = tracePoolSurface(ray);
        
    ray = traceHorizon(ray);

    return ray;
}

void main(void)
{
    // --------------------------------------------------------------------
    // Place for animating global state

    float numOrbCellsXChangeTime = max(0., g_time - OURPITHYATOR_START);
    g_numOrbCells.x = 8. + 4. * (5. * (sawtooth( g_numOrbsChangeRate.x * 
                                                 numOrbCellsXChangeTime + 1.)) +
                                    5.);
    float numOrbCellsYChangeTime = max(0., g_time - OURPITHYATOR_FIRSTDROP);
    g_numOrbCells.y = 8. + 8. * pow(2., floor(3. * sawtooth( g_numOrbsChangeRate.y * 
                                                        numOrbCellsYChangeTime + 4.) + 
                                        3.));
    // Would be nice if I could find a way to ramp off of the beat better, but that
    // would require some history knowledge.
    g_bassBeat = smoothstep(0.91, 1.03, texture2D( iChannel0, vec2( 0.01, 0.1 ) ).r);
    
    // Round off the pop by raising the beat to a tweaked power
    g_bassBeat = pow(g_bassBeat, 0.5) * g_audioResponse;
    
    g_audioFreqs[0] = pow(texture2D( iChannel0, vec2(0.2, 0.05)).r, 0.5) * g_audioResponse;
    g_audioFreqs[1] = pow(texture2D( iChannel0, vec2(0.4, 0.05)).r, 0.5) * g_audioResponse;
    g_audioFreqs[2] = pow(texture2D( iChannel0, vec2(0.6, 0.05)).r, 0.5) * g_audioResponse;
    g_audioFreqs[3] = pow(texture2D( iChannel0, vec2(0.8, 0.05)).r, 0.5) * g_audioResponse;
    
    g_orbOuterRadius = 40. * mix(1., 1.05, g_bassBeat); 
    g_orbCenterRadius = 5. * mix(1., .98, g_bassBeat); 
    g_sparkColorIntensity = mix(1., 1.4, g_bassBeat);
    
    float colorChangeRate = 1.;
    // offset spark color mix by 2 seconds to hit the first electronic flange
    // event.
    float sparkColorMixModTime = mod(g_time + 2., colorChangeRate * 52. / g_beatRate);

    // The following bit of logic is used to have the sparks transition from one
    // color to the next in a vegas like strobe.  The idea is that the  first
    // set of sparks transition using the leading limit and then the  sparks
    // catch up to the trailing limit.  The sweep through the orb spark cells is
    // carefully timed to these transitions and the spark color mix interval.
    g_sparkColorMixInterval = colorChangeRate * 4. / g_beatRate;

    g_sparkColorMixLeadingLimit = smoothstep(colorChangeRate * 16. / g_beatRate ,  
                                         colorChangeRate * 17. / g_beatRate, 
                                         sparkColorMixModTime) +
                              smoothstep(colorChangeRate * 32. / g_beatRate ,  
                                         colorChangeRate * 33. / g_beatRate, 
                                         sparkColorMixModTime) +
                              smoothstep(colorChangeRate * 48. / g_beatRate ,  
                                         colorChangeRate * 49. / g_beatRate, 
                                         sparkColorMixModTime);
 
    g_sparkColorMixTrailingLimit = smoothstep(colorChangeRate * 19. / g_beatRate ,  
                                         colorChangeRate * 20. / g_beatRate, 
                                         sparkColorMixModTime) +
                              smoothstep(colorChangeRate * 35. / g_beatRate ,  
                                         colorChangeRate * 36. / g_beatRate, 
                                         sparkColorMixModTime) +
                              smoothstep(colorChangeRate * 51. / g_beatRate ,  
                                         colorChangeRate * 52. / g_beatRate, 
                                         sparkColorMixModTime);
    g_orbPosition = g_camPointAt;
    g_orbPosition += vec3(20. * cos(.4 * g_time), 
                         20. * (.5 * sin(.5 * g_time) + .5), 
                         -20. * sin(.4 * g_time) + 0.);
    

    // Shake the camera's focus object a bit with the bass beat - imagine the
    // beat shaking the camera holder.  So we precalculate the camera dimensions
    // here pre-shake and then once again when we determine the final values
    
    // calculate the rayDirection that represents mapping the image plane
    // towards the scene
    vec3 cameraZDir = normalize( g_camPointAt - g_camOrigin );
    vec3 cameraXDir = normalize( cross(cameraZDir, g_camUpDir) );
    vec3 cameraYDir = cross(cameraXDir, cameraZDir);
    g_camPointAt += 0.2 * cameraYDir * sin(16. * g_beatRate * g_time) * g_bassBeat;
 
    // --------------------------------------------------------------------
    
    // Shift p so it's in the range -1 to 1 in the x-axis and 1./aspectRatio
    // to 1./aspectRatio in the y-axis (a reminder aspectRatio := width /
    // height of screen)
    
    // I could simplify this to:
    // vec2 p = gl_FragCoord.xy / iResolution.xx; <- but that's a bit obtuse
    // to read.

    vec2 p = gl_FragCoord.xy / iResolution.xy;      
    float aspectRatio = iResolution.x / iResolution.y;
    p = 2.0 * p - 1.0;
    p.y *= 1./aspectRatio;
    
    // Do the same to the click position
    vec2 click = iMouse.xy / iResolution.xy;    
    click = 2.0 * click - 1.0;
    click.y *= 1./aspectRatio;
    
    // camera movement  
    float xrot = 1. * PI_OVER_TWO * (.25 * sin(g_camXRotationRate * g_time + 
                                         TWO_PI * click.y + PI_OVER_TWO) + .1);
    g_camOrigin = rotateAroundXAxis( g_camOrigin, xrot);
    g_camOrigin = rotateAroundYAxis( g_camOrigin, 
                            g_camYRotationRate * g_time - PI * click.x);
    
    // re-calculate the rayDirection that represents mapping the  image plane
    // towards the scene - post beat.
    cameraZDir = normalize( g_camPointAt - g_camOrigin );
    cameraXDir = normalize( cross(cameraZDir, g_camUpDir) );
    cameraYDir = normalize( cross(cameraXDir, cameraZDir) );
    
     // cheap way to provide a focal length by adjusting.  Make the constant in
    // front of cameraZDir (camFocalLengthScalar) bigger to tighten focus,
    // smaller to  widen focus.

    vec2 uv = p*0.5+0.5;
    float vignet = 0.2 + 0.8 * pow(10.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y),0.3);
    float camFocalLengthScalar = vignet;
    vec3 camRayDir = normalize( p.x*cameraXDir + p.y*cameraYDir + 
                                camFocalLengthScalar * cameraZDir );    
    // Construct scene ray shooting from the camera
    SceneRayStruct ray = SceneRayStruct(g_camOrigin, // origin
                                        camRayDir, // direction
                                        0., // current march depth
                                        BIG_FLOAT, // max march depth
                                        vec4(0.), // color
                                        vec4(0.)); // debug color
    // Perform the trace on the scene.  The ray will have the final
    // color in ray.color.
    ray = traceScene(ray);

    vec4 tracedColor = ray.color;

    // multiply the alpha onto the color.  If you want info on why I do this,
    // consult the source paper:
    // http://graphics.pixar.com/library/Compositing/paper.pdf
    tracedColor.rgb *= min(1., tracedColor.a);

    // --------------------------------------------------------------------
    // color-grading - simple color adjustment curve
    tracedColor.rgb = pow(tracedColor.rgb, vec3(1.4));
    
    // vigneting
    tracedColor *= vignet;
    
    gl_FragColor = tracedColor;
    
    // Debug color's alpha is not multiplied during final output.  If it is 
    // non-zero, then the debugcolor is respected fully 
    gl_FragColor.rgb = mix(gl_FragColor.rgb, ray.debugColor.rgb, 
                           step(EPSILON, ray.debugColor.a));

  
}
