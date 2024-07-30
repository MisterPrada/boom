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
uniform float u_ProgressImpulse;
uniform float u_Period;
uniform float u_CenterImpulse;
uniform float u_Sigma; // width of the impulse

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

    // World Position
    vec4 transformedModel = modelMatrix * vec4(transformed, 1.0);

    // *** Three.js Coords *** //
    vec3 finalPosition = transformed.xzy;
    finalPosition.z *= -1.0;
    vec3 _uv = vec3(uv1.x, uv2.y, uv1.y);
    // *** END Three.js Coords *** //

    vec3 direction = _uv.zyx;
    direction.y *= hashVec2(_uv.xy);

    float wave = max((140.0 - length(_uv.xz)) - 140.0 * (1.0 - u_Progress), 0.0 ) / 200.0;
    wave = sqrt(wave);

    float angle = 3.14 * length((110.0 - length(_uv.xz)) * 0.009) * wave;
    finalPosition = rotateVertex(vec4(finalPosition.xyz, 1.0), direction, angle).xyz;



    float dist = u_Progress * pow( 110.0 - length(_uv.xz), 1.2) ;
    float newY = u_Progress * dist + 2.0 * sin(u_Time + _uv.x) * u_Progress;

    //finalPosition.xz += transformedModel.xz * u_Progress;


    //finalPosition.xz += transformedModel.xz * (140.0 - length(_uv.xz)) * wave * 0.01;
    //finalPosition.xz += transformedModel.xz * wave;



    if( newY > 0.0 ) {
        finalPosition.y += newY * (wave * 0.4);

        float circle = length(transformedModel.xz) - 100.0 * u_Progress;
        //circle = abs(circle);
        //circle = smoothstep(0.0, 1.0, -circle);
        //finalPosition.xz += circle * length(_uv.xz) * u_Progress;
        //length((110.0 - length(_uv.xz)) * 0.009)
    }


//    // Impulse function
//    float T = u_Period;  // period
//    float t_0 = u_CenterImpulse;  // center of the impulse
//    float sigma = u_Sigma;  // width of the impulse
//
//    // Calculate the impulse
//    float t = u_ProgressImpulse * 10.0;
//
//    // Function Sin
//    float impulse = sin(2.0 * 3.14159265359 * t / T) * exp(-pow(t - t_0, 2.0) / (2.0 * sigma * sigma));
//
//    //finalPosition.y += impulse * sin(length(transformedModel.xz) * 0.1 - u_Time) * 2.0;


    // Вычисляем расстояние от центра
    float distance = length(transformedModel.xz);
    float waveSpeed = 2.0;
    float waveFrequency = 0.2;
    float waveAmplitude = 4.0;

    // Вычисляем фазовый сдвиг, чтобы волна распространялась наружу со временем
    float phaseShift = u_Progress * 140.0 - (distance / waveSpeed);

    // Вычисляем смещение по оси y с использованием синусоиды и фазового сдвига
    float offsetY = sin(phaseShift * waveFrequency) * waveAmplitude;

    // Применяем затухание к волне, чтобы она была только одной
    if (phaseShift < 0.0 || phaseShift > (2.0 * 3.14159 / waveFrequency)) {
        offsetY = 0.0;
    } else {
        float attenuation = smoothstep(0.0, 1.0, phaseShift * waveFrequency / 3.14159);
        offsetY *= attenuation;
    }

    finalPosition.y -= offsetY;


//    float circle = length(transformedModel.xz) - sin(u_Time) * 100.0;
//    circle = abs(circle);
//    circle = smoothstep(0.0, 1.0, circle);
//    finalPosition.y += circle * 3.0;


//    float circle = length(transformedModel.xz) - 50.0;
//    circle = abs(circle);
//    circle = smoothstep(0.0, 1.0, circle);
//    finalPosition.y -= circle * 7.0;





    // *** Three.js Coords comeback *** //
    transformed.xzy = finalPosition.xyz;
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
