#define MAX_STEPS 100
#define MAX_DIST 1000.0
#define SURF_DIST 0.001
#define NUMBER_OF_SPHERES 36

float GetDist(vec3 p) {
    float planeDist = p.y + 2.0;
    float d = planeDist;
    
    for (int i = 0; i < NUMBER_OF_SPHERES; i++) {
        vec4 s = vec4(-5 + i % 5, -1 + i % 25 / 5, 10 + i / 25, 0.2);
        vec3 nc = p;
        nc.x -= s.x;
        nc.y -= s.y;
        nc.z -= s.z;

        float sphereDist = length(nc) - s.w;
        if (d > sphereDist) {
            d = sphereDist;
        } 
    }

    return d;
}

float RayMarch(vec3 ro, vec3 rd) {
    float dO = 0.;
    for(int i = 0; i < MAX_STEPS; i++){
        vec3 p = rd * dO;
        p += ro;
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
    
    vec3 n1 = p;
    n1.x -= e.x;
    n1.y -= e.y;
    n1.z -= e.y;
    
    vec3 n2 = p;
    n2.x -= e.y;
    n2.y -= e.x;
    n2.z -= e.y;
    
    vec3 n3 = p;
    n3.x -= e.y;
    n3.y -= e.y;
    n3.z -= e.x;
    
    float d1 = GetDist(n1);
    float d2 = GetDist(n2);
    float d3 = GetDist(n3);
    
    vec3 n = vec3(d);
    n.x -= d1;
    n.y -= d2;
    n.z -= d3;
    
    float len = sqrt(n.x*n.x + n.y * n.y + n.z * n.z);
    n.x /= len;
    n.y /= len;
    n.z /= len;
    return n;
}

float GetLight(vec3 p) {
    vec3 lightPos = vec3(3, 5, 10);
    float v1 = sin(iTime);
    float v2 = cos(iTime);
    lightPos.x += v1;
    lightPos.z += v2;

    vec3 tmp = lightPos - p;
    float len = sqrt(tmp.x * tmp.x + tmp.y * tmp.y + tmp.z * tmp.z);
    tmp.x /= len;
    tmp.y /= len;
    tmp.z /= len;

    vec3 l = tmp;
    vec3 n = GetNormal(p);


    float dif = clamp(n.x * l.x + n.y * l.y + n.z * l.z, 0., 1.);
    float d = RayMarch(p + n * SURF_DIST, l);
    tmp = lightPos - p;
    
    float lightLen = sqrt(tmp.x * tmp.x + tmp.y * tmp.y + tmp.z * tmp.z);
    if(d<lightLen) dif *= 0.1;
    return dif;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy) / iResolution.y;

    vec3 col = vec3(0);
    
    vec3 ro = vec3(0,1,0);
    
    vec3 rd = normalize(vec3(uv.x,uv.y,1));
    
    float d = RayMarch(ro, rd);
    vec3 p = ro + rd * d;
    
    float dif = GetLight(p);
    col = vec3(dif);
    fragColor = vec4(col,1.0);
}