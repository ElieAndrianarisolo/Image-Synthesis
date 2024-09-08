void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec3 noir = vec3(0,0,0);
    vec3 blanc = vec3(1,1,1);
    vec2 centre = iResolution.xy/2.0;
    int distanceCentrePoint = int(distance(centre, fragCoord));
    int ecart = 30;
    
    if(distanceCentrePoint%ecart == 0)
    {
        fragColor = vec4(noir,1.0);
    }
    else
    {
        fragColor = vec4(blanc,1.0);
    }
    
}