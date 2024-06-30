shader_type canvas_item;

uniform vec3 color = vec3(0.86,0.88,0.82);

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if (COLOR.rgb == vec3(1.0,0.0,0.0)) {
		COLOR = vec4(color, 1.0);
	}
}
