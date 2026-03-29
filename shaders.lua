local shaders = {}

shaders.whiteout = love.graphics.newShader([[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        return vec4(1, 1, 1, pixel.a);
    }
]])

shaders.light = love.graphics.newShader([[
    extern vec2 light_center;
    extern float light_radius;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        vec4 pixel = Texel(texture, texture_coords);
        float dist = length(screen_coords - light_center);

        if (dist < light_radius) {
            return vec4(0, 0, 0, 0);
        }

        return pixel * color;
    }
]])

return shaders
