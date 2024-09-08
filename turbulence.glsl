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

float turbulence(in vec2 p, in float amplitude, in float fbase, in float attenuation, in int noctave) {
    int i;
    float res = .0;
    float f = fbase;
    for (i=0;i<noctave;i++) {
        res = res+amplitude*noise(f*p);
        amplitude = amplitude*attenuation;
        f = f*2.;
    }
    return res;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   /* Code pour Noise :
   vec2 uv = fragCoord/iResolution.xy; 
   fragColor = vec4 (noise(4.0*uv), noise(4.0*uv), noise(4.0*uv), 1); 
   */
   
   /* Réponses aux questions :
   Q5) amplitude règle l’amplitude générale que l’on veut donner au signal, tandis qu’attenuation donne
       l’atténuation que l’on va avoir entre deux octaves différentes.
   Q6) fbase est la fréquence de base, toutes les autres fréquences ajoutées seront des multiples (puissances
       de 2) de cette fréquence de base. noctave donne le nombre d’octaves qui seront sommés. Plus on ajoute
       d’octaves plus il y aura de détails dans le fonction générée.
   Q7) attenuation doit être entre 0 (surface très lisse) et 1 (surface très rugueuse). La valeur standard est
       de 0.5. noctave ne doit pas être trop élevé sinon les performances vont être dégradées. Un bonne valeur
       est 8, mais on peut aller jusqu’à 10. Dans le cas d’une texture on peut s’arrêter quand la fréquence engendre
       des détails plus petits que la taille d’un pixel et ne sera pas visible.
   */
   
   /* Code pour Turbulence :
   vec2 uv = fragCoord/iResolution.xy; 
   fragColor = vec4 (turbulence(uv, 50.0, 20.0, 0.5, 8), turbulence(uv, 50.0, 20.0, 0.5, 8), turbulence(uv, 50.0, 20.0, 0.5, 8), 1); 
   */
   
}