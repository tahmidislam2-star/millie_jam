shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.5) = 1.5;
uniform vec2 center = vec2(0.5, 0.5);
uniform vec4 wipe_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec2 uv = UV;
	float aspect = 1.7777;
	vec2 diff = uv - center;
	diff.x *= aspect;
	float dist = length(diff);

	float edge_softness = 0.02;
	float alpha = smoothstep(radius - edge_softness, radius, dist);
	COLOR = vec4(wipe_color.rgb, alpha);
}