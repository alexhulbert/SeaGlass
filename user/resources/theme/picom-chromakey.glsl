#version 430
// Original shader by ikz87

// Apply opacity changes to pixels similar to one color
int color_rgb[] = {{ {background.rgb} }}; // Color to replace, in rgb format 
float similarity = 0.1; // How many similar colors should be affected.
                        // A value of 0 means only pixels containing 
                        // the exact color set in color_rgb will match.
                        // A value of 1 means that, for example, a pixel
                        // with 0 green would even be able to match with 
                        // a color_rgb set to have 255 green and vice versa.

float amount = 1.4; // How much similar colors should be changed. 
                 // I'd advice to keep this value around 1
float target_opacity = 0.83;
// Change any of the above values to get the result you want


// Set values to a 0 - 1 range
vec3 chroma = vec3(color_rgb[0]/255.0, color_rgb[1]/255.0, color_rgb[2]/255.0);

in vec2 texcoord;             // texture coordinate of the fragment

uniform sampler2D tex;        // texture of the window

// Default window post-processing:
// 1) invert color
// 2) opacity / transparency
// 3) max-brightness clamping
// 4) rounded corners
vec4 default_post_processing(vec4 c);

// Returns a transparent color
vec4 transparent() {{
    return vec4(chroma[0], chroma[1], chroma[2], target_opacity);
}}

vec4 window_shader() {{
    vec4 c = texelFetch(tex, ivec2(texcoord), 0);
    c = default_post_processing(c);

    // Match the pixel
    if (c.x >=chroma.x - similarity && c.x <=chroma.x + similarity &&
        c.y >=chroma.y - similarity && c.y <=chroma.y + similarity &&
        c.z >=chroma.z - similarity && c.z <=chroma.z + similarity &&
        c.w >= 0.99)
    {{
        if (similarity == 0)
        {{
            // Ig similarity is 0, trun pixel completely transparent
            c = transparent();
        }}
        else
        {{
            // Calculate error between matched pixel and color_rgb values
            vec3 error = vec3(abs(chroma.x - c.x), abs(chroma.y - c.y), abs(chroma.z - c.z));
            float avg_error = (error.x + error.y + error.z) / 3;
            if (avg_error == 0)
            {{
                // If average error is 0, turn pixel completely transparent
                c = transparent();
            }}
            else
            {{
                // Magic
                c.w = target_opacity + (1.0 - target_opacity)*avg_error*amount/similarity;

            }}
        }}
    }}

    return (c);
}}


