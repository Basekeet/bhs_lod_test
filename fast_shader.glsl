#define MAX_STEPS 100
#define MAX_DIST 1000.0
#define SURF_DIST 0.001
#define NUMBER_OF_SPHERES 36

float GetDist(vec3 p) {
    float planeDist = p.y + 2.0;
    float d = planeDist;
    
    for (int i = 0; i < NUMBER_OF_SPHERES; i++) {
        vec4 s = vec4(-5 + i % 5, -1 + i % 25 / 5, 10 + i / 25, 0.2);
        float sphereDist = length(p - s.xyz) - s.w;
         
        d = min(d, sphereDist);
    }
    return d;
}

float RayMarch(vec3 ro, vec3 rd) {
    float dO = 0.;
    for(int i = 0; i < MAX_STEPS; i++){
        vec3 p = ro + rd * dO;
        float dS = GetDist(p);
        dO += dS;
        if(dS < SURF_DIST || dO > MAX_DIST)
            break;
        
    }
    return dO;
}

vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(0.01, 0);
    
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx)
    );
    
    return normalize(n);
}

float GetLight(vec3 p) {
    vec3 lightPos = vec3(0, 5, 6);
    lightPos.xz += vec2(sin(iTime), cos(iTime));
    vec3 l = normalize(lightPos - p);
    vec3 n = GetNormal(p);


    float dif = clamp(dot(n, l), 0., 1.);
    float d = RayMarch(p + n * SURF_DIST, l);
    if(d<length(lightPos-p)) dif *= 0.1;
    return dif;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord-.5*iResolution.xy;
    uv /= iResolution.y;

    vec3 col = vec3(0);
    
    vec3 ro = vec3(0,1,0);
    
    vec3 rd = normalize(vec3(uv.x,uv.y,1));
    
    float d = RayMarch(ro, rd);
    vec3 p = ro + rd * d;
    
    float dif = GetLight(p);
    col = vec3(dif);
    fragColor = vec4(col,1.0);
}