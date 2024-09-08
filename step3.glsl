/* Réponses aux questions :

Q8) Dans la version initiale du ray-marching, on avance d’un pas fixe Epsilon à chaque itération. Ce pas est
    aussi la précision avec laquelle on obtiendra la position de l’intersection avec l’objet. Plus Epsilon est
    petit, plus la précision est bonne mais plus les performances sont mauvaises. D’autre part, pour ne pas
    faire trop chuter les performances, il y a un autre paramètre qui permet de donner le maximum d’itération
    possible en chaque pixel, c’est la constante Steps. Quand on a diminué Epsilon, ce nombre de pas a été
    atteint avant de toucher l’objet, qui a donc disparu. Quand on change la ligne pour adapter le pas en fonction
    de la valeur de la fonction implicite, on augmente le saut fait à chaque itération, donc les performances
    sont meilleures. Elles ne peuvent pas être moins bonnes car on prend le maximum de Epsilon et d’une
    autre valeur.
    
Q9) Cette constante représente la borne de Lipschitz de la fonction implicite, c’est-à-dire la norme maximum
    du gradient de la fonction. Lorsque la valeur de la fonction est v, alors on sait qu’en parcourant une distance de −v/ρ, on atteindra
    pas la valeur nulle de la fonction. Ici v est négatif, d’où le signe moins devant la formule. Si vous changez la
    fonction implicite visualisée, vous pouvez être amené à modifier cette valeur, par exemple dans le cas d’un
    terrain qui aurait une pente très elevée, votre fonction pourrait avoir une borne de Lipschitz plus grande que
    2.

*/

const int Steps = 1000;
const float Epsilon = 0.5; // Marching epsilon
const float T=0.5;

const float rA=1.0; // Minimum ray marching distance from origin
const float rB=50.0; // Maximum

// Transforms
vec3 rotateY(vec3 p, float a)
{
   vec3 tmp = p;
   p.x = tmp.x*cos(a) + tmp.z*sin(a);
   p.z = -tmp.x*sin(a) + tmp.z*cos(a);
   return p;
}

// Smooth falloff function
// r : small radius
// R : Large radius
float falloff( float r, float R )
{
   float x = clamp(r/R,0.0,1.0);
   float y = (1.0-x*x);
   return y*y*y;
}

// Primitive functions

// Point skeleton
// p : point
// c : center of skeleton
// e : energy associated to skeleton
// R : large radius
float point(vec3 p, vec3 c, float e,float R)
{
   return e*falloff(length(p-c),R);
}


// Blending
// a : field function of left sub-tree
// b : field function of right sub-tree
float Blend(float a,float b)
{
   return a+b;
}

// Potential field of the object
// p : point
float object(vec3 p)
{
   float v = Blend(point(p,vec3( -2.5, 0.0,0.0),1.0,4.5),
                   point(p,vec3( 2.5, 0.0,0.0),1.0,4.5));

   return v-T;
}

// Calculate object normal
// p : point
vec3 ObjectNormal(in vec3 p )
{
   float eps = 0.0001;
   vec3 n;
   float v = object(p);
   n.x = object( vec3(p.x+eps, p.y, p.z) ) - v;
   n.y = object( vec3(p.x, p.y+eps, p.z) ) - v;
   n.z = object( vec3(p.x, p.y, p.z+eps) ) - v;
   return normalize(n);
}

// Trace ray using ray marching
// o : ray origin
// u : ray direction
// h : hit
// s : Number of steps
float Trace(vec3 o, vec3 u, out bool h,out int s)
{
   h = false;

   // Don't start at the origin
   // instead move a little bit forward
   float t=rA;

   for(int i=0; i<Steps; i++)
   {
      s=i;
      vec3 p = o+t*u;
      float v = object(p);
      // Hit object (1) 
      if (v > 0.0)
      {
         s=i;
         h = true;
         break;
      }
      // Move along ray
      t += max(Epsilon,-v/2.0);

      // Escape marched far away
      if (t>rB)
      {
         break;
      }
   }
   return t;
}

// Background color
vec3 background(vec3 rd)
{
   return mix(vec3(0.8, 0.8, 0.9), vec3(0.6, 0.9, 1.0), rd.y*1.0+0.25);
}

// Shading and lighting
// p : point,
// n : normal at point
vec3 Shade(vec3 p, vec3 n, int s)
{
   // point light
   const vec3 lightPos = vec3(5.0, 5.0, 5.0);
   const vec3 lightColor = vec3(1.0, 1.0, 1.0);

   vec3 l = normalize(lightPos - p);

   // Not even Phong shading, use weighted cosine instead for smooth transitions
   float diff = 0.5*(1.0+dot(n, l));

   vec3 c =  0.5*vec3(0.5,0.5,0.5)+0.5*diff*lightColor;
   float fog = 0.7*float(s)/(float(Steps-1));
   c = (1.0-fog)*c+fog*vec3(1.0,1.0,1.0);
   return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   vec2 pixel = (gl_FragCoord.xy / iResolution.xy)*2.0-1.0;

   // compute ray origin and direction
   float asp = iResolution.x / iResolution.y;
   vec3 rd = vec3(asp*pixel.x, pixel.y, -4.0);
   vec3 ro = vec3(0.0, 0.0, 15.0);

   vec2 mouse = iMouse.xy / iResolution.xy;
   float a=-mouse.x;//iTime*0.25;
   rd.z = rd.z+2.0*mouse.y;
   rd = normalize(rd);
   ro = rotateY(ro, a);
   rd = rotateY(rd, a);

   // Trace ray
   bool hit;

   // Number of steps
   int s;

   float t = Trace(ro, rd, hit,s);
   vec3 pos=ro+t*rd;
   // Shade background
   vec3 rgb = background(rd);

   if (hit)
   {
      // Compute normal
      vec3 n = ObjectNormal(pos);

      // Shade object with light
      rgb = Shade(pos, n, s);
   }

   fragColor=vec4(rgb, 1.0);
}