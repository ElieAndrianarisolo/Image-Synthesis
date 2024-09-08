const int Steps = 1000;
const float Epsilon = 0.1; // Marching epsilon
const float T=0.5;

const float rA=1.0; // Minimum ray marching distance from origin
const float rB=50.0; // Maximum


const float AMPLITUDE = 5.0;
const float FBASE = 0.06;
const float ATTENUATION = 0.4;
const int NOCTAVE = 8;

vec2 hash( vec2 p ) 
{
	p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(269.5,183.3)) );

	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p )
{
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;

	vec2 i = floor( p + (p.x+p.y)*K1 );
	
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = step(a.yx,a.xy);    
    vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;

    vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );

	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));

    return dot( n, vec3(70.0) );
}

float r_noise( vec2 p ){
    float res = 2.0 * (0.5-abs(0.5-noise(p)));
    return res;
}

float turbulence(in vec2 p, in float amplitude, in float fbase, in float attenuation, in int noctave)
{
    int i;
    float res = .0;
    float f = fbase;
    for (i=0;i<noctave;i++) {
        res = res+amplitude*r_noise(f*p);
        amplitude = amplitude*attenuation;
        f = f*2.;
    }
    return res;
}

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

float Terrain(vec3 p)
{
             
    float turb = turbulence(p.xz, AMPLITUDE,FBASE, ATTENUATION, NOCTAVE) - p.y;
    float res = max(0.0, turb) - p.y;
    return res;
}

// Potential field of the object
// p : point
float object(vec3 p)
{
   return Terrain(p);
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
vec3 background(vec3 rd, vec2 fragCoord, vec3 p)
{
    float turbRand = turbulence(p.xy, 200.0, 0.10, 0.7, 5); // Parametres pour les nuages
    float turbSun = turbulence(p.xy, 3.0, 0.10, 0.7, 5); // Parametre contour soleil
    vec2 uv = fragCoord/iResolution.xy; 
    vec3 col = 0.5 + 0.5*cos(iTime/3.0+uv.yxy+vec3(0.7,0,0));
    col.y = 0.3;
    col.z = 0.5;
    
    if(fragCoord.y >= iResolution.y - turbRand) // Nuages
    {
        col = 0.5 + 0.5*cos(iTime/3.0+uv.yxy+vec3(1.0,0.9,0.9));
    }
    
    vec2 centre = vec2(iResolution.x/1.555, iResolution.y/1.8);
    
    if(fragCoord.y >= iResolution.y/2.5 && fragCoord.y <= iResolution.y/1.5
        && fragCoord.x >= iResolution.x/1.75 && fragCoord.x <= iResolution.x/1.4 ) // Soleil
    {
        float distanceCentrePoint = distance(centre, fragCoord);
        if(distanceCentrePoint <= iResolution.y/10.0 + turbSun)
        {
           col = 0.5 + 0.5*cos(iTime/3.0+uv.yxy+vec3(1.0,0.99,0.22)); 
           
           if(col.x <= 0.1)
           {
               col.x = 0.1;
           }
           else if(col.x >= 0.9)
           {
               col.x = 0.9;
           }
           
           if(col.y <= 0.1)
           {
               col.y = 0.1;
           }
           else if(col.y >= 0.9)
           {
               col.y = 0.9;
           }
           
           if(col.z <= 0.1)
           {
               col.z = 0.1;
           }
           else if(col.z >= 0.22)
           {
               col.z = 0.22;
           }
           
           
        }
        
    }
    
    return col;
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
   
   float turb = turbulence(p.xz, 1.0, 0.06, 0.5, 8);
   float turbRand = turbulence(p.xz, 0.2, 0.25, 0.8, 8);
   float turbColor = turbulence(p.xz, 0.14, 0.17, 0.9, 10);
   float turbWater = turbulence(p.xz - vec2(iTime/3.0, cos(iTime/2.0)/7.0), 0.15, 0.25, 0.5, 4);
   
   vec3 color = vec3(0.2,0.1,0.0) + p.y/2.5 ;
   
   
   if(p.y <= 0.0 && p.y >= -0.1){  //Mer
       color= vec3(0.2,0.5,1.0) + turbWater;
   } else if(p.y >= 0.7 + turbRand){ // Neige
        color =  color + turbColor + turb;
   } else if(p.y <= 0.3 + turbRand/1.25){  // Herbe
       color= vec3(0.2,0.5,0.2) + turbColor;
   }
   
   
   vec3 c;
    
   c =  0.5*color+0.5*diff*lightColor;
   
   float fog = 0.7*float(s)/(float(Steps-1));
   c = (1.0-fog)*c+fog*vec3(1.0,1.0,1.0);
      
   return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   vec2 pixel = (gl_FragCoord.xy / iResolution.xy)*2.0-1.0;

   // compute ray origin and direction
   float asp = iResolution.x / iResolution.y;
   vec3 rd = vec3(asp*pixel.x, pixel.y-0.2, -4.0);
   vec3 ro = vec3(0.0, 2.0, 15.0);

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
   vec3 rgb = background(rd, fragCoord, pos);
   

   if (hit)
   {
      // Compute normal
      vec3 n = ObjectNormal(pos);

      // Shade object with light
      rgb = Shade(pos, n, s);
   }


   fragColor=vec4(rgb, 1.0);
}