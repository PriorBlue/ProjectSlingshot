extern vec2 screenSize = vec2(800.0, 600.0);
extern float steps = 2.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	vec2 pSize = vec2(1.0 / screenSize.x, 1.0 / screenSize.y);
	vec4 col = Texel(texture, texture_coords);
	
	if(steps >= 1){
		int minStep = int(min(1, steps));
		int maxStep = int(max(1, steps));
		
		int cnt = 1;
		float multi = 1;
		
		for(int i = minStep; i <= maxStep; i++) {
			cnt = cnt + 1;
			col = col + Texel(texture, vec2(texture_coords.x + pSize.x * i, texture_coords.y)) * (1.0 / cnt);
			multi = multi + (1.0 / cnt);
		}
		col = col / multi;
	}

	return vec4(col.r, col.g, col.b, 1.0);
}