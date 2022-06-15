shader_type canvas_item;

uniform vec4 color : hint_color;
uniform float multiplier : hint_range(-0.0, 1.0);
uniform float softness : hint_range(-0.0, 1.0);

void fragment()
{
	float value = distance(UV, vec2(0.5));
	COLOR = vec4(color.rgb, smoothstep(multiplier, softness, value));
}