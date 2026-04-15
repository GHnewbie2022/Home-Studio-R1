precision highp float;
precision highp int;
precision highp sampler2D;

#include <pathtracing_uniforms_and_defines>

#define N_QUADS 1
#define N_BOXES 16

vec3 rayOrigin, rayDirection;
vec3 hitNormal, hitEmission, hitColor;
vec2 hitUV;
float hitObjectID;
int hitType = -100;

struct Quad { vec3 normal; vec3 v0; vec3 v1; vec3 v2; vec3 v3; vec3 emission; vec3 color; int type; };
struct Box { vec3 minCorner; vec3 maxCorner; vec3 emission; vec3 color; int type; };

Quad quads[N_QUADS];
Box boxes[N_BOXES];

#include <pathtracing_random_functions>

#include <pathtracing_quad_intersect>

#include <pathtracing_box_intersect>

#include <pathtracing_box_interior_intersect>

#include <pathtracing_sample_quad_light>


float SceneIntersect( )
{
	vec3 normal, n;
    float d;
	float t = INFINITY;
	int objectCount = 0;
	
	hitObjectID = -INFINITY;
	
	d = QuadIntersect( quads[0].v0, quads[0].v1, quads[0].v2, quads[0].v3, rayOrigin, rayDirection, FALSE );
	if (d < t)
	{
		t = d;
		hitNormal = quads[0].normal;
		hitEmission = quads[0].emission;
		hitColor = quads[0].color;
		hitType = quads[0].type;
		hitObjectID = float(objectCount);
	}
	objectCount++;
	
	int isRayExiting = FALSE;
	for (int i = 0; i < N_BOXES; i++) {
		d = BoxIntersect( boxes[i].minCorner, boxes[i].maxCorner, rayOrigin, rayDirection, n, isRayExiting );
		if (d < t && n != vec3(0,0,0))
		{
			t = d;
			hitNormal = n;
			hitEmission = boxes[i].emission;
			hitColor = boxes[i].color;
			hitType = boxes[i].type;
			hitObjectID = float(objectCount);
		}
		objectCount++;
	}

	return t;
}


vec3 CalculateRadiance( out vec3 objectNormal, out vec3 objectColor, out float objectID, out float pixelSharpness )
{
    Quad light = quads[0];

	vec3 accumCol = vec3(0);
    vec3 mask = vec3(1);
    vec3 n, nl, x;
	vec3 diffuseBounceMask = vec3(1);
	vec3 diffuseBounceRayOrigin = vec3(0);
	vec3 diffuseBounceRayDirection = vec3(0);
        
	float t = INFINITY;
	float weight, p;
	
	int diffuseCount = 0;
	int previousIntersecType = -100;
	hitType = -100;
	
	int bounceIsSpecular = TRUE;
	int sampleLight = FALSE;
	int willNeedDiffuseBounceRay = FALSE;


	for (int bounces = 0; bounces < 10; bounces++)
	{
		previousIntersecType = hitType;

		t = SceneIntersect();

		if (t == INFINITY)
		{
			if (bounces == 0 || (bounces == 1 && previousIntersecType == SPEC))
				pixelSharpness = 1.0;
			
			if (willNeedDiffuseBounceRay == TRUE)
			{
				mask = diffuseBounceMask;
				rayOrigin = diffuseBounceRayOrigin;
				rayDirection = diffuseBounceRayDirection;

				willNeedDiffuseBounceRay = FALSE;
				bounceIsSpecular = FALSE;
				sampleLight = FALSE;
				diffuseCount = 1;
				continue;
			}

			break;
		}
			

		n = normalize(hitNormal);
    nl = dot(n, rayDirection) < 0.0 ? n : -n;
		x = rayOrigin + rayDirection * t;

		if (bounces == 0)
		{
			objectID = hitObjectID;
		}

		if (diffuseCount == 0)
		{
			objectNormal += n;
			objectColor += hitColor;
		}
		
		
		if (hitType == LIGHT)
		{	
			if (diffuseCount == 0)
				pixelSharpness = 1.0;

			if (bounceIsSpecular == TRUE || sampleLight == TRUE)
				accumCol = mask * hitEmission;

			if (willNeedDiffuseBounceRay == TRUE)
			{
				mask = diffuseBounceMask;
				rayOrigin = diffuseBounceRayOrigin;
				rayDirection = diffuseBounceRayDirection;

				willNeedDiffuseBounceRay = FALSE;
				bounceIsSpecular = FALSE;
				sampleLight = FALSE;
				diffuseCount = 1;
				continue;
			}

			break;
		}
		
		if (sampleLight == TRUE) 
		{
			if (willNeedDiffuseBounceRay == TRUE)
			{
				mask = diffuseBounceMask;
				rayOrigin = diffuseBounceRayOrigin;
				rayDirection = diffuseBounceRayDirection;

				willNeedDiffuseBounceRay = FALSE;
				bounceIsSpecular = FALSE;
				sampleLight = FALSE;
				diffuseCount = 1;
				continue;
			}

			break;
		}
			

    if (hitType == DIFF) 
    {
			diffuseCount++;

			mask *= hitColor;

			bounceIsSpecular = FALSE;

			rayOrigin = x + nl * uEPS_intersect;

        if (diffuseCount == 1)
        {
				diffuseBounceMask = mask;
				diffuseBounceRayOrigin = rayOrigin;
				diffuseBounceRayDirection = randomCosWeightedDirectionInHemisphere(nl);
				willNeedDiffuseBounceRay = TRUE;
			}
			
			rayDirection = sampleQuadLight(x, nl, light, weight);
			mask *= weight * 1.5;
			sampleLight = TRUE;
			continue;
                        
    } 
	
    if (hitType == SPEC)  
	{
		mask *= hitColor;

		rayDirection = reflect(rayDirection, nl);
		rayOrigin = x + nl * uEPS_intersect;

		continue;
	}
		
	} 
	
	return max(vec3(0), accumCol);

}


void SetupScene(void)
{
	vec3 z = vec3(0);
	
	float MIN_X = -2.11;
	float MAX_X = 2.11;
	float MIN_Y = -0.20;
	float MAX_Y = 3.105;
	float MIN_Z = -2.074;
	float MAX_Z = 3.256;
	
	vec3 C_FLOOR = vec3(0.55, 0.47, 0.41);
	vec3 C_WALL = vec3(1.0, 0.984, 0.949);
	vec3 C_WALL_L = vec3(1.0, 0.984, 0.949);
	vec3 C_WALL_R = vec3(1.0, 0.984, 0.949);
	vec3 C_WALL_S = vec3(1.0, 0.984, 0.949);
	vec3 C_BEAM = vec3(1.0, 0.984, 0.949);
	
	vec3 L1 = vec3(1.0, 0.95, 0.8) * 8.0;

	quads[0] = Quad( vec3(0.0, -1.0, 0.0),
	                 vec3(-0.5, 2.90, -0.5),
	                 vec3(0.5, 2.90, -0.5),
	                 vec3(0.5, 2.90, 0.5),
	                 vec3(-0.5, 2.90, 0.5),
	                 L1, z, LIGHT);

	boxes[0] = Box( vec3(MIN_X, MIN_Y, MIN_Z), vec3(MAX_X, 0.0, MAX_Z), z, C_FLOOR, DIFF);
	boxes[1] = Box( vec3(MIN_X, 2.905, MIN_Z), vec3(MAX_X, MAX_Y, MAX_Z), z, C_WALL, DIFF);
	boxes[2] = Box( vec3(MIN_X, 0.0, MIN_Z), vec3(-1.52, 2.905, -1.874), z, C_WALL, DIFF);
	boxes[3] = Box( vec3(-0.73, 0.0, MIN_Z), vec3(MAX_X, 2.905, -1.874), z, C_WALL, DIFF);
	boxes[4] = Box( vec3(-1.52, 2.03, MIN_Z), vec3(-0.73, 2.905, -1.874), z, C_WALL, DIFF);
	boxes[5] = Box( vec3(1.91, 0.0, MIN_Z), vec3(MAX_X, 2.905, MAX_Z), z, C_WALL_R, DIFF);
	boxes[6] = Box( vec3(MIN_X, 0.0, 3.056), vec3(-1.75, 2.905, MAX_Z), z, C_WALL_S, DIFF);
	boxes[7] = Box( vec3(0.69, 0.0, 3.056), vec3(MAX_X, 2.905, MAX_Z), z, C_WALL_S, DIFF);
	boxes[8] = Box( vec3(-1.75, 0.0, 3.056), vec3(0.69, 1.04, MAX_Z), z, C_WALL_S, DIFF);
	boxes[9] = Box( vec3(MIN_X, 2.04, -1.874), vec3(-1.91, 2.905, -0.984), z, C_WALL_L, DIFF);
	boxes[10] = Box( vec3(MIN_X, 0.0, -1.874), vec3(-1.91, 0.09, -0.984), z, C_WALL_L, DIFF);
	boxes[11] = Box( vec3(MIN_X, 0.0, -0.984), vec3(-1.91, 2.905, MAX_Z), z, C_WALL_L, DIFF);
	boxes[12] = Box( vec3(-1.91, 2.525, MIN_Z), vec3(-1.75, 2.905, MAX_Z), z, C_BEAM, DIFF);
	boxes[13] = Box( vec3(1.85, 2.515, MIN_Z), vec3(MAX_X, 2.905, 2.49), z, C_BEAM, DIFF);
	boxes[14] = Box( vec3(-1.91, 0.0, 2.848), vec3(-1.75, 2.905, MAX_Z), z, C_BEAM, DIFF);
	boxes[15] = Box( vec3(1.78, 0.0, 2.49), vec3(MAX_X, 2.905, MAX_Z), z, C_BEAM, DIFF);
}


#include <pathtracing_main>