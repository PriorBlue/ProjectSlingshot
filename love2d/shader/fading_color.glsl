extern float time = 0.0;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	vec4 glowInfo = Texel(texture, texture_coords);

	if(glowInfo.a != 0.0) {
		return vec4((sin(time * 0.5) + 1.0) * 0.4, (cos(time * 0.6) + 1.0) * 0.3, (sin(time * 0.7) + 1.0) * 0.4, 1.0);
	} else {
		return vec4(0);
	}
}