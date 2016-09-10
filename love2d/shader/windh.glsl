extern vec2 screenSize = vec2(800.0, 600.0);
extern float steps = 2.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	vec2 pSize = vec2(1.0 / screenSize.x, 1.0 / screenSize.y);
	vec4 col = Texel(texture, texture_coords);
	
	if(steps >= 1){
		int minStep = int(min(1, steps));
		int maxStep = int(max(1, steps));
		
		for(int i = minStep; i <= maxStep; i++) {
			col = col + Texel(texture, vec2(texture_coords.x, texture_coords.y + pSize.y * i));
		}
		col = col / (steps + 1.0);
	}

	return vec4(col.r, col.g, col.b, 1.0);
}