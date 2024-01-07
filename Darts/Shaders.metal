//
//  Shaders.metal
//  Darts
//
//  Created by Evan Rinehart on 1/3/24.
//

#include <metal_stdlib>
using namespace metal;

// Step 4: Creating a Vertex Shader

// GENERAL NOTES

// All vertex shaders must begin with the keyword vertex
// The function must return the final position of the vertex (at least)
// The shader name is the function name, basic_vertex in this case


// PARAMETER NOTES

// First parameter is a pointer to an array of packed_float3, which is the position vector
/* 
 use [[ ]] to declare attributes, which you can use to specify additional information such
 as resource locations, shader inputs and built-in variables. Here, you mark this parameter 
 with [[ buffer(0) ]] to indicate that the first buffer of data that you send to your vertex
 shader from your Metal code will populate this parameter.
 */
/*
 The vertex shader also takes a special parameter with the vertex_id attribute, which means
 that the Metal will fill it in with the index of this particular vertex inside the vertex array.
 */

/* This unused vertex shader takes a simple packed_float3 from swift buffer 0, and stores it in vertex_array */

vertex float4 basic_vertex(
                           const device packed_float3* vertex_array [[ buffer(0) ]],
                           unsigned int vid [[ vertex_id ]]
                           ) {
                               return float4(vertex_array[vid], 1.0);
                           }


// Step 5: Creating a Fragment Shader

// GENERAL NOTES

// All fragment shaders must begin with the keyword fragment
// The function must return the final color of the fragment (at least)
// The shader name is the function name, basic_fragment in this case

// half4 is more memory efficient than float4

/* This unused fragment shader simply returns 1.0 for all vertices */

fragment half4 basic_fragment() {
    return half4(1.0);
}

// ##############################################################################

// Declare this to match thew swift code definition of Vertex. You can use a bridging header to get around this.
struct Vertex {
    float3 position;
    float3 color;
};

struct VertexOut {
    float4 color;
    float4 pos [[position]];
};

/* 
 This vertex shader takes a buffer that contains Vertex objects
 The position is extracted and sent to the rasterizer becuase VertexOut says [[position]] comes from variable pos in the struct
 */
vertex VertexOut colored_vertex(const device Vertex *vertexArray [[buffer(0)]], unsigned int vid [[vertex_id]]) {
    Vertex in = vertexArray[vid];
    VertexOut out;

    out.color = float4(in.color,  1.0);
    out.pos = float4(in.position, 1.0);

    return out;
}

/*
 This fragment shader simply returns the interpolated color
 Interpolated comes from the rasterizer. Since we pass "out" to the rasterizer from the vertex shader,
 the result is passed to the fragment shader from special keyword [[stage_in]] (interpolated)
 */
fragment float4 colored_fragment(VertexOut interpolated [[stage_in]]) {
    return interpolated.color;
}
