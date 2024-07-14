#define PHONG

varying vec3 vViewPosition;

#include <common>
#include <batching_pars_vertex>
#include <uv_pars_vertex>
#include <displacementmap_pars_vertex>
#include <envmap_pars_vertex>
#include <color_pars_vertex>
#include <fog_pars_vertex>
#include <normal_pars_vertex>
#include <morphtarget_pars_vertex>
#include <skinning_pars_vertex>
#include <shadowmap_pars_vertex>
#include <logdepthbuf_pars_vertex>
#include <clipping_planes_pars_vertex>

// ** custom ** //

attribute vec2 uv1;
attribute vec2 uv2;

uniform float u_Time;
uniform float u_Progress;
//uniform float u_FlowFieldFrequency;
//uniform float u_FlowFieldStrength;
//uniform float u_TimeScale;
//
//#include ../Includes/simplexNoise3d.glsl
//#include ../Includes/simplexNoise4d.glsl
//
//vec3 waves( vec3 position, float time )
//{
//    return vec3(
//        simplexNoise4d(vec4(position.xyz * u_FlowFieldFrequency + 0.0, time)),
//        simplexNoise4d(vec4(position.xyz * u_FlowFieldFrequency + 1.0, time)),
//        simplexNoise4d(vec4(position.xyz * u_FlowFieldFrequency + 2.0, time))
//    );
//}

mat4 rotationMatrix(vec3 axis, float angle) {
    float cosAngle = cos(angle);
    float sinAngle = sin(angle);
    float oneMinusCos = 1.0 - cosAngle;

    axis = normalize(axis);

    return mat4(
        cosAngle + axis.x * axis.x * oneMinusCos,
        axis.x * axis.y * oneMinusCos - axis.z * sinAngle,
        axis.x * axis.z * oneMinusCos + axis.y * sinAngle,
        0.0,

        axis.y * axis.x * oneMinusCos + axis.z * sinAngle,
        cosAngle + axis.y * axis.y * oneMinusCos,
        axis.y * axis.z * oneMinusCos - axis.x * sinAngle,
        0.0,

        axis.z * axis.x * oneMinusCos - axis.y * sinAngle,
        axis.z * axis.y * oneMinusCos + axis.x * sinAngle,
        cosAngle + axis.z * axis.z * oneMinusCos,
        0.0,

        0.0, 0.0, 0.0, 1.0
    );
}

vec4 rotateVertex(vec4 vertex, vec3 direction, float angle) {
    mat4 rotMatrix = rotationMatrix(direction, angle);
    return rotMatrix * vertex;
}

float hashVec2(vec2 p)
{
    p = 50.0 * fract(p * 0.3183099 + vec2(0.71, 0.113));
    return -1.0 + 2.0 * fract( p.x * p.y * (p.x + p.y) );
}


void main() {

    #include <uv_vertex>
    #include <color_vertex>
    #include <morphcolor_vertex>
    #include <batching_vertex>

    #include <beginnormal_vertex>

//    float time = u_Time * u_TimeScale;
//
//    vec3 biTangent = cross(normal, tangent.xyz);
//    float shift = 0.1;
//
//    vec3 positionA = position + tangent.xyz * shift;
//    vec3 positionB = position + biTangent * shift;
//
//    positionA = positionA + waves(positionA, time) * u_FlowFieldStrength;
//    positionB = positionB + waves(positionB, time) * u_FlowFieldStrength;
//    vec3 pos = position + waves(position, time) * u_FlowFieldStrength;
//
//    // Compute normal
//    vec3 toA = normalize(positionA - pos);
//    vec3 toB = normalize(positionB - pos);
//    objectNormal = cross(toA, toB);
//
//    objectTangent = toA;

    #include <morphinstance_vertex>
    #include <morphnormal_vertex>
    #include <skinbase_vertex>
    #include <skinnormal_vertex>
    #include <defaultnormal_vertex>
    #include <normal_vertex>

    #include <begin_vertex>


    // *** Three.js Coords *** //
    vec3 finalPosion = transformed.xzy;
    finalPosion.z *= -1.0;
    vec3 _uv = vec3(uv1.y, uv2.y, uv1.x);
    // *** END Three.js Coords *** //

    vec3 direction = _uv;
    direction.y *= hashVec2(_uv.xy);

    float angle = 3.14 * length((110.0 - length(_uv.xz)) * 0.009) * u_Progress;
    finalPosion = rotateVertex(vec4(finalPosion.xyz, 1.0), direction, angle).xyz;


    //float dist = u_Progress * (110.0 - length(_uv.xz)) * (distance(_uv.xz, finalPosion.xz) * 0.01 + 1.3);
    float dist = u_Progress * pow( 110.0 - length(_uv.xz), 1.2) ;
    float newY = u_Progress * dist + 2.0 * sin(u_Time + _uv.x) * u_Progress;

    //finalPosion.xz += _uv.xz * u_Progress;

    if( newY > 0.0 ) {
        finalPosion.y += newY;
    }

    vec4 transformedModel = modelMatrix * vec4(transformed, 1.0);

    finalPosion.y += sin(length(transformedModel.xz) * 0.1 - u_Time) * 2.0;


    // *** Three.js Coords comeback *** //
    transformed.xzy = finalPosion.xyz;
    transformed.y *= -1.0;
    // *** END Three.js Coords comeback *** //


    #include <morphtarget_vertex>
    #include <skinning_vertex>
    #include <displacementmap_vertex>

    #include <project_vertex>
    #include <logdepthbuf_vertex>
    #include <clipping_planes_vertex>

    vViewPosition = - mvPosition.xyz;

    #include <worldpos_vertex>
    #include <envmap_vertex>
    #include <shadowmap_vertex>
    #include <fog_vertex>

}
