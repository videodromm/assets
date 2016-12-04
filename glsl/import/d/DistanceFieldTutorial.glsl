// https://www.shadertoy.com/view/XtXGzM
/*
 * # Raymarched distance-field renderer tutorial
 * # Part 1: Basic Distance Field & Raymarching
 *
 * ```
 * Author:  Sébastien Pierre   http://sebastienpierre.ca   @ssebastien
 * License: BSD License
 * ```
 *
 * This shader is meant to show how to implement a raymarching distance field
 * shader-based renderer. It is based on the work of Inigo Quilezles ("iq"), whose
 * amazing code can be see all around on Shadertoy.com.
 *
 * Before editing/reading this shader, you should learn about distance fields and
 * raymarching, in particular [DIST] and [RAY] mentioned below. This tutorial's code
 * is based on the [TRI] code by `iq`.
 *
 * References:
 *
 * - [DIST] http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
 * - [TRI]  https://www.shadertoy.com/view/4sXXRN
 * - [RAY]  http://www.iquilezles.org/www/material/nvscene2008/nvscene2008.htm

*/

/**
  * sdSphere is the distance field-based sphere equation as described
  * by iq in [DIST]
*/
float sdSphere( vec3 p, float s )
{
    // The sphere is positioned at the origin (0,0,0) and has a radius of `s`.
    // the distance between the point `p` and the envelope of the shpere is
    // then the distance between the point and the origin, minus the radius
    // of the sphere.
    return length(p)-s;
}

/**
  * The map function is where you can register the distance field functions
  * for all the "objects" in your scene. It is fairly simple to do union, interection
  * difference, and repeats, as explained in [DIST]
*/
float map( in vec3 p )
{
    // We have only one object in this scene, and it is a sphere of
    // radius 1.0
    return sdSphere(p, 1.0);    
}


/**
  * The `intersect` function is the main raymarching algorithm. It takes
  * the ray origin `ro` and the ray step (or delta) `rd`. `rd` will be
  * repeatedly added to `ro` until the `map` function (which determines
  * the distance between the given point and the union of all objects
  * in the scene) returns a value that is close to 0 (meaning the current
  * point is almost on the scene object's envelope.
  *
  * Note that if `rd` is not normalized, the steps will increase or
  * decrease as the intersection algorithm go.
*/
float intersect( in vec3 ro, in vec3 rd )
{
    // `maxd` is the maximum distance after which we'll stop the
    // raymarching. This means that if we haven't interesected
    // with anything after 10.0 world units of iteration, we'll stop.
    const float maxd = 10.0;
    
    // `h` is the temporary value that we'll use to store the
    // distance to objects in the scene. We could initialize it at any
    // value > 0.001 (the intersection threshold).
    float h          = 1.0;
    // `t` will hold the final result of the raymarching, returning
    // the distance marched on the ray before reaching an intersection.
    float t          = 0.0;
    
    // The number of iterations is limited to 50. I guess this should
    // be adjusted depending on the scene.
    for( int i=0; i<50; i++ )
    {
        // We break if h is below the threshold (ie, we've nearly
        // intersected a scene object), or that we've exceeded the
        // marching distance.
        if( h<0.001 || t>maxd ) break;
        // We get the distance between the current raymarched point 
        // and the union of all objects in the scene. The value returned
        // is the distance to the closest object in the scene.
        h = map( ro+rd*t );
        // We add that to the current walking distance. If at the next
        // iteration map returns a value close to 0, it means we'll have
        // intersected, otherwise we'll need to continue.
        t += h;
    }

    if( t>maxd ) t=-1.0;
    
    return t;
}


void main(void)
{
    // `q` is the normalized position of the current shaded pixel, meaning it
    // is between [0,0] and [1,1]
    vec2 q = gl_FragCoord.xy / iResolution.xy;
    
    
    // If you do `p=q`, you will see that the origin is to the bottom left 
    // of the screen. With this simple expression, we adjust the viewpoint
    // in the space and center the origin in the preview screen.
    //
    // vec2 p = q;              // [1] Origin is at the bottom-left of the screen
    // vec2 p = 2.0 * q;        // [2] We scale by 1/2 by multiplying q
    vec2 p = 2.0 * q - 1.0;     // [3] We scale by 1/2 and then center the origin on screen
    // vec2 p = -0.5 + q;       // [4] Alternatively, we can center without scaling
    
    // NOTE: I'm not very familiar with the shader API, but from the above we can deduce
    // that 1.0 means [1.0, 1.0] for a vect2, 2.0 means [2.0, 2.0], etc.
    
    // `iResolution.x/isResolution.y` is the aspect ratio, by default it is 512/288~=1.7777.
    // If you uncomment the following line the image will appear as squashed.
    p.x *= iResolution.x/iResolution.y;  
    
    // The `ro` value specifies the origin of the camera's center in the virtual space.
    // You can tweak the X and Y values to shift the origin, or the Z value to
    // adjust the distance to the sphere (here it is 2.0 to the sphere's center).
    vec3 ro = vec3(0.0, 0.0, 2.0 );
    
    // The `rd` value specifies the position of the current pixel (on the projection
    // plane in the 3D space The notation vec3(p,-1.0) is equivalent to vec3(p.x,p.y,-1.0) as
    // `p` is a vec2.
    // NOTE: I am not sure what `normalize` does
    vec3 rd = normalize( vec3(p,-1.0) );
    
    // The `col` vector holds the color that will be rendered on the screen, ie. the main
    // output of the shader. As the alpha channel will be set to 1.0, we only need the
    // three components RGB, hence the use of a vec3.
    vec3 col = vec3(0.0);

    // We call the `interect` function with `ro` as the ray origin and `rd` as the 
    // point from which the raymarching step/delta will be calculated. Interest is the
    // main raymatching function.
    float t = intersect(ro,rd);
    
    // If t > 0.0, it means the ray cast from `ro` through `rd` has intersected with
    // an object of the scene, in which case we'll assign a non-black color to the
    // pixel.
    if( t>0.0 )
    {
        // Here we do the simplest possible shading, which is based on the distance between
        // the ray and the sphere. if `t == 0`, it means the sphere's envelope is intersecting
        // with the current pixel, otherwise t will be the distance between the current pixel
        // and the sphere's envelope. 
        //
        // NOTE: I'm not sure exactly why we need to substract t from 2.0 and not 1.0. I would
        // assume that because the projection plane is at -1.0 (as set by `rd.z`) and that the
        // sphere is at the origin with a 1.0 radius that there t would be osciallating between
        // 0 (closest) and 1.0 (farthest). If you try changing rd to the following expression:
        //
        // vec3 rd = normalize( vec3(p,-2.0) );
        //
        // You will only make the sphere closer, but the values for `t` will remain the same
        // (the shading will remain). However, if you change the value of `ro` to the following:
        //
        // vec3 ro = vec3(0.0, 0.0, 2.5 );
        //
        // not only will the sphere shrink on the projection, but `t` will also increase. It is
        // not clear to me yet why that is.
        float d =  max(0.0, 2.0 - t);
        col = vec3(d);
    }
    // We assign the color we've just computed.
    gl_FragColor = vec4( col, 1.0 );
}

