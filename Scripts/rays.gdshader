shader_type canvas_item;

uniform vec4 ray_color : source_color = vec4(1.0, 0.0, 0.0, 0.5);
uniform float speed = 1.0;
uniform float ray_count = 12.0;

void fragment() {
	vec2 uv = UV - 0.5;
	float angle = atan(uv.y, uv.x);
	
	// Add rotation over time
	float time_angle = angle + TIME * speed;
	
	// Generate rays
	float ray = sin(time_angle * ray_count);
	
	// Make rays sharp
	ray = step(0.0, ray);
	
	// Circular fade out
	float dist = length(uv);
	float alpha = smoothstep(0.5, 0.0, dist); // Fade out towards edges
	
	COLOR = ray_color;
	COLOR.a = ray * alpha * ray_color.a;
}
