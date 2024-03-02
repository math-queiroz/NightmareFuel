shader_type canvas_item;

uniform vec3 Color1 : source_color;
uniform vec3 Color2 : source_color;
uniform vec3 Color3 : source_color;
uniform vec3 Color4 : source_color;
uniform vec4 Weights;

uniform float RimHeight = 0.1;
uniform float RimBightness = 0.25;

uniform float Percentage = 0.0;

varying float y_rotation;

void vertex() {
	y_rotation = atan(MODEL_MATRIX[0][1], MODEL_MATRIX[0][0]);
}

void fragment() {
	float rotated_y = cos(-y_rotation) * (UV.y - 0.5) - sin(-y_rotation) * (UV.x - 0.5) + 0.5;
	vec3 Color = (Color1*Weights.x + Color2*Weights.y + Color3*Weights.z + Color4*Weights.w) / (Weights.x+Weights.y+Weights.z+Weights.w);
	COLOR.a -= step(rotated_y, 1.207 - Percentage * 1.207);
	COLOR.rgb = Color.rgb;
}
