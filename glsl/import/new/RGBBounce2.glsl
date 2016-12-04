// https://www.shadertoy.com/view/4lc3RH

const int NPOINTS = 7;
const float COLOUR_THRESHOLD = 0.2;

vec2 points[NPOINTS];
vec4 colours[NPOINTS];

void initColours() {
    //point 1 colour - red
    colours[0].x = 1.0;
    colours[0].y = 0.0;
    colours[0].z = 0.0;
    colours[0].w = 1.0;
    //point 2 colour - orange
    colours[1].x = 1.0;
    colours[1].y = 0.647;
    colours[1].z = 0.0;
    colours[1].w = 1.0;
    //point 3 colour - yellow
    colours[2].x = 1.0;
    colours[2].y = 1.0;
    colours[2].z = 0.0;
    colours[2].w = 1.0;
    //point 4 colour - green
    colours[3].x = 0.0;
    colours[3].y = 1.0;
    colours[3].z = 0.0;
    colours[3].w = 1.0;
    //point 5 colour - blue
    colours[4].x = 0.0;
    colours[4].y = 0.0;
    colours[4].z = 1.0;
    colours[4].w = 1.0;
    //point 3 colour - indigo
    colours[5].x = 0.22;
    colours[5].y = 0.39;
    colours[5].z = 0.76;
    colours[5].w = 1.0;
    //point 3 colour - violet
    colours[6].x = 0.4;
    colours[6].y = 0.2;
    colours[6].z = 0.6;
    colours[6].w = 1.0;
}

void initPoints() {
    
    for (int i = 0; i < NPOINTS; i++) {
        vec2 point = vec2(.456 * 3.0 * float(i), 0.) + iGlobalTime * vec2(1., .2 * float(i) + 0.1);
        point = abs(mod(point, 2.) -1.0);
        points[i].x = point.x;
        points[i].y = point.y;
    }
}

void main(void) {
    
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 ratio = vec2(iResolution.x/iResolution.y, 1.);
    vec4 colour = vec4(0.0);
    
    //colours
    initColours();
    
    // points
    initPoints();
    
    for (int i = 0; i < NPOINTS; i++) {
        
        float d = distance(uv, points[i]);  
        vec4 newColour = colours[i];
        
        if (newColour.x > COLOUR_THRESHOLD) {
            newColour = vec4(abs(1.0 - d * 3.0), 0.0, 0.0, 1.0);
        }
        if (newColour.y > COLOUR_THRESHOLD) {
            newColour = vec4(0.0, abs(1.0 - d * 3.0), 0.0, 1.0);
        }
        if (newColour.z > COLOUR_THRESHOLD) {
            newColour = vec4(0.0, 0.0, abs(1.0 - d * 3.0), 1.0);
        }
        
        if (!(newColour.x < COLOUR_THRESHOLD &&
            newColour.y < COLOUR_THRESHOLD &&
            newColour.z < COLOUR_THRESHOLD)) {
            
            //not black
            //colour += newColour;
            colour = mix(colour, newColour, .5);
        }
    }
    
    gl_FragColor = colour;    
}
