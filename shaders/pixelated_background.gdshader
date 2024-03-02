// imported from https://godotshaders.com/shader/pixelated-animated-water/
shader_type canvas_item;

uniform float transparency : hint_range(0, 1) = 1.0;

uniform vec4 color0 : source_color = vec4(0.01, 0.0, 1.0, 1.0);
uniform vec4 color1 : source_color = vec4(0.32, 0.2, 1.0, 1.0);
uniform vec4 color2 : source_color = vec4(0.34, 0.41, 1.0, 1.0);
uniform vec4 color3 : source_color = vec4(0.39, 0.52, 1.0, 1.0);

uniform vec2 Direction = vec2(1, 1);
uniform float Speed = 1.00;
uniform float RandomSeed = 1.00;

uniform float thresholds[3];

uniform int OCTAVE = 6;
uniform int pixel_size;
uniform float dithering = 2.5;

vec2 random(vec2 uv){
    uv = vec2( dot(vec3(uv, RandomSeed), vec3(127.1,311.7,149.2) ),
               dot(vec3(uv, RandomSeed), vec3(269.5,183.3,391.8) ) ).xy;
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}

float fbm(vec2 input){
	float value = 0.0;
	float scale = 0.2;

	input *= TIME/3000.0 + 1.0;

	for(int i = 0; i < OCTAVE; i++){
		value += noise(input)*scale;
		input *= dithering;
	}

	return clamp(value, 0.0, 1.0);
}

float get_pixelated_moving_colors(vec2 uv, vec2 direction, float speed) {
	speed = speed / 1000.0;
	direction*=-1.0;
	vec2 moving_uv = uv + (direction * TIME * speed) + vec2(0.5/float(pixel_size));
	vec2 pixel_uv = round((moving_uv) * float(pixel_size)) / float(pixel_size);
	float pixelated_color = fbm(pixel_uv);
	return pixelated_color;
}

vec4 smooth_extreme_colors(float color) {
	// Dark to light
	if (color<=thresholds[0]) {
        return color0;
    } else if (thresholds[0]<color && color<=thresholds[1]) {
        return color1;
    } else if (thresholds[1]<color && color<=thresholds[2]) {
        return color2;
    } else if (thresholds[2]<=color) {
        return color3;
	}
}

void fragment(){
	if (COLOR.a > 0.0001){
	float pixelated_color = get_pixelated_moving_colors(UV, Direction, Speed);
	vec4 smoothed_color = smooth_extreme_colors(pixelated_color);

	COLOR = smoothed_color * transparency;
	}
}