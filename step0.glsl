/* Réponses aux questions :

Q1) La variable iResolution correspond à la taille de la fenêtre visualisée en pixel. C’est un vecteur de
    dimension deux. Cette taille change quand la fenêtre du navigateur est redimensionnée oou lorsqu’on met
    en plein écran la visualisation.
Q2) L’opérateur / fait une opération dite pointwise, c’est à dire qu’il prend en argument deux vecteurs de dimension deux et renvoie un autre vecteur de dimension 2, où chacune des composante est traitée séparément.
    Autrement dit c’est équivalent à écrire en plsu court le code suivant :
    vec2 uv;
    uv.x = fragCoord.x/iResolution.x;
    uv.y = fragCoord.y/iResolution.y;
Q3) C’est tout sauf facile! Le seul moyen de connaître la valeur d’une variable est de la visualiser par l’intermédiaire de fragColor. Vous avez à votre disposition trois composantes qui peuvent aider à visualiser
    différentes variables, mais il faudra être capable d’interprêter les couleurs qui sont affichées.
Q4) Chaque composante de couleur est entre 0 et 1, on le voit bien dans la formule qui définit col du fait que
    le cosinus est entre -1 et 1.
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec3 noir = vec3(0,0,0);
    vec3 blanc = vec3(1,1,1);
    
    if(int(fragCoord.x)%30 == 0)
    {
        fragColor = vec4(noir,1.0);
    }
    else
    {
        fragColor = vec4(blanc,1.0);
    }
    
}