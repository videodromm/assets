// http://glsl.heroku.com/e#13593.0

// Source edited by David Hoskins - 2013.

// I took and completed this http://glsl.heroku.com/e#9743.20 - just for fun! 8|
// Locations in 3x7 font Letters_grid, inspired by http://www.claudiocc.com/the-1k-notebook-part-i/
// Had to edit it to remove line doubling.
// ABC  a:GIOMJL b:AMOIG c:IGMO d:COMGI e:OMGILJ f:CBN g:OMGIUS h:AMGIO i:EEHN j:GHTS k:AMIKO l:BN m:MGHNHIO n:MGIO
// DEF  o:GIOMG p:SGIOM q:UIGMO r:MGI s:IGJLOM Letters_t:BNO u:GMOI v:GJNLI w:GMNHNOI x:GOKMI y:GMOIUS z:GIMO
// GHI
// JKL 
// MNO
// PQR
// STU

#define STROKEWIDTH 0.05
#define PI 3.14159265359

#define A_ vec2(0.,0.)
#define B_ vec2(1.,0.)
#define C_ vec2(2.,0.)

#define D_ vec2(0.,1.)
#define E_ vec2(1.,1.)
#define F_ vec2(2.,1.)

#define G_ vec2(0.,2.)
#define H_ vec2(1.,2.)
#define I_ vec2(2.,2.)

#define J_ vec2(0.,3.)
#define K_ vec2(1.,3.)
#define L_ vec2(2.,3.)

#define M_ vec2(0.,4.)
#define N_ vec2(1.,4.)
#define O_ vec2(2.,4.)

#define P_ vec2(0.,5.)
#define Q_ vec2(1.,5.)
#define R_ vec2(1.,5.)

#define S_ vec2(0.,6.)
#define T_ vec2(1.,6.)
#define U_ vec2(2.0,6.)

#define A(p) Letters_t(G_,I_,p) + Letters_t(I_,O_,p) + Letters_t(O_,M_, p) + Letters_t(M_,J_,p) + Letters_t(J_,L_,p)
#define B(p) Letters_t(A_,M_,p) + Letters_t(M_,O_,p) + Letters_t(O_,I_, p) + Letters_t(I_,G_,p)
#define C(p) Letters_t(I_,G_,p) + Letters_t(G_,M_,p) + Letters_t(M_,O_,p) 
#define D(p) Letters_t(C_,O_,p) + Letters_t(O_,M_,p) + Letters_t(M_,G_,p) + Letters_t(G_,I_,p)
#define E(p) Letters_t(O_,M_,p) + Letters_t(M_,G_,p) + Letters_t(G_,I_,p) + Letters_t(I_,L_,p) + Letters_t(L_,J_,p)
#define F(p) Letters_t(C_,B_,p) + Letters_t(B_,N_,p) + Letters_t(G_,I_,p)
#define G(p) Letters_t(O_,M_,p) + Letters_t(M_,G_,p) + Letters_t(G_,I_,p) + Letters_t(I_,U_,p) + Letters_t(U_,S_,p)
#define H(p) Letters_t(A_,M_,p) + Letters_t(G_,I_,p) + Letters_t(I_,O_,p) 
#define I(p) Letters_t(E_,E_,p) + Letters_t(H_,N_,p) 
#define J(p) Letters_t(E_,E_,p) + Letters_t(H_,T_,p) + Letters_t(T_,S_,p)
#define K(p) Letters_t(A_,M_,p) + Letters_t(M_,I_,p) + Letters_t(K_,O_,p)
#define L(p) Letters_t(B_,N_,p)
#define M(p) Letters_t(M_,G_,p) + Letters_t(G_,I_,p) + Letters_t(H_,N_,p) + Letters_t(I_,O_,p)
#define N(p) Letters_t(M_,G_,p) + Letters_t(G_,I_,p) + Letters_t(I_,O_,p)
#define O(p) Letters_t(G_,I_,p) + Letters_t(I_,O_,p) + Letters_t(O_,M_, p) + Letters_t(M_,G_,p)
#define P(p) Letters_t(S_,G_,p) + Letters_t(G_,I_,p) + Letters_t(I_,O_,p) + Letters_t(O_,M_, p)
#define Q(p) Letters_t(U_,I_,p) + Letters_t(I_,G_,p) + Letters_t(G_,M_,p) + Letters_t(M_,O_, p)
#define R(p) Letters_t(M_,G_,p) + Letters_t(G_,I_,p)
#define S(p) Letters_t(I_,G_,p) + Letters_t(G_,J_,p) + Letters_t(J_,L_,p) + Letters_t(L_,O_,p) + Letters_t(O_,M_,p)
#define T(p) Letters_t(B_,N_,p) + Letters_t(N_,O_,p) + Letters_t(G_,I_,p)
#define U(p) Letters_t(G_,M_,p) + Letters_t(M_,O_,p) + Letters_t(O_,I_,p)
#define V(p) Letters_t(G_,J_,p) + Letters_t(J_,N_,p) + Letters_t(N_,L_,p) + Letters_t(L_,I_,p)
#define W(p) Letters_t(G_,M_,p) + Letters_t(M_,O_,p) + Letters_t(N_,H_,p) + Letters_t(O_,I_,p)
#define X(p) Letters_t(G_,O_,p) + Letters_t(I_,M_,p)
#define Y(p) Letters_t(G_,M_,p) + Letters_t(M_,O_,p) + Letters_t(I_,U_,p) + Letters_t(U_,S_,p)
#define Z(p) Letters_t(G_,I_,p) + Letters_t(I_,M_,p) + Letters_t(M_,O_,p)
#define STOP(p) Letters_t(N_,N_,p)
vec2 Letters_caret_origin = vec2(3.0, .7);
vec2 Letters_caret;

//-----------------------------------------------------------------------------------
float Letters_minimum_distance(vec2 v, vec2 w, vec2 p)
{	// Return minimum distance between line segment vw and point p
  float l2 = (v.x - w.x)*(v.x - w.x) + (v.y - w.y)*(v.y - w.y); //length_squared(v, w);  // i.e. |w-v|^2 -  avoid a sqrt
  if (l2 == 0.0) {
return distance(p, v);   // v == w case
}
// Consider the line extending the segment, parameterized as v + Letters_t (w - v).
  // We find projection of point p onto the line.  It falls where Letters_t = [(p-v) . (w-v)] / |w-v|^2
  float Letters_t = dot(p - v, w - v) / l2;
  if(Letters_t < 0.0) {
// Beyond the 'v' end of the segment
return distance(p, v);
} else if (Letters_t > 1.0) {
return distance(p, w);  // Beyond the 'w' end of the segment
}
  vec2 projection = v + Letters_t * (w - v);  // Projection falls on the segment
return distance(p, projection);
}

//-----------------------------------------------------------------------------------
float Letters_textColor(vec2 from, vec2 to, vec2 p)
{
p *= iRatio;
float inkNess = 0., nearLine, corner;
nearLine = Letters_minimum_distance(from,to,p); // basic distance from segment, thanks http://glsl.heroku.com/e#6140.0
inkNess += smoothstep(0., 1., 1.- 14.*(nearLine - STROKEWIDTH)); // ugly still
inkNess += smoothstep(0., 2.5, 1.- (nearLine  + 5. * STROKEWIDTH)); // glow
return inkNess;
}

//-----------------------------------------------------------------------------------
vec2 Letters_grid(vec2 letterspace) 
{
return ( vec2( (letterspace.x / 2.) * .65 , 1.0-((letterspace.y / 2.) * .95) ));
}

//-----------------------------------------------------------------------------------
float Letters_count = 0.0;
float Letters_t(vec2 from, vec2 to, vec2 p) 
{
Letters_count++;
if (Letters_count > iGlobalTime*20.0) return 0.0;
return Letters_textColor(Letters_grid(from), Letters_grid(to), p);
}

//-----------------------------------------------------------------------------------
vec2 r()
{
float font_spacing = .07;//05;

vec2 pos = gl_FragCoord.xy/iResolution.xy;
pos.y -= Letters_caret.y;
pos.x -= font_spacing*Letters_caret.x;
return pos;
}

//-----------------------------------------------------------------------------------
void Letters_add()
{
Letters_caret.x += 1.0;
}

//-----------------------------------------------------------------------------------
void Letters_space()
{
Letters_caret.x += 1.5;
}

//-----------------------------------------------------------------------------------
void Letters_newline()
{
Letters_caret.x = Letters_caret_origin.x;
Letters_caret.y -= .18;
}

//-----------------------------------------------------------------------------------
void main(void)
{
float d = 0.;
vec3 col = vec3(0.1, .07+0.07*(.5+sin(gl_FragCoord.y*3.14159*1.1+iGlobalTime*2.0)) + sin(gl_FragCoord.y*.01+iGlobalTime+2.5)*0.05, 0.1);
Letters_caret = Letters_caret_origin;

d += R(r()); Letters_add();  d += E(r()); Letters_add();  d += Y(r()); Letters_add(); d += M(r()); Letters_add(); d += E(r()); Letters_add(); d += N(r()); Letters_add(); d += T(r()); Letters_add(); d += A(r());
d = clamp(d* (.75+sin(gl_FragCoord.x*PI*.5-iGlobalTime*4.3)*.5), 0.0, 1.0);
      
    col += vec3(d*.5, d, d*.85);
vec2 xy = gl_FragCoord.xy / iResolution.xy;
col *= vec3(.4, .4, .3) + 0.5*pow(100.0*xy.x*xy.y*(1.0-xy.x)*(1.0-xy.y), .4 );
    gl_FragColor = vec4( col, 1.0 );
}
