shader_type spatial;
render_mode unshaded, cull_front;

uniform float OutlineSize = 0.2;
uniform vec3 OutlineColor : source_color;

void vertex() {
	VERTEX += NORMAL * (OutlineSize * 0.1);
}

void fragment() {
	ALBEDO = OutlineColor;
}
