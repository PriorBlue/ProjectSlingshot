extern Image glowImage;
extern float glowTime;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
	vec4 glowInfo = Texel(glowImage, texture_coords).rgba;

	if(glowInfo.a > 0) {
		if(glowInfo.r != glowInfo.g) {
			float glowStrength = mod(glowTime + glowInfo.b * 2.0, 2.0);

			if(glowStrength <= 1.0){
				glowInfo.b = glowStrength;
			}else{
				glowInfo.b = 2.0 - glowStrength;
			}

			return Texel(texture, texture_coords) * (glowInfo.b * (glowInfo.r - glowInfo.g) + glowInfo.g);
		}

		return vec4(Texel(texture, texture_coords).rgb * glowInfo.r, glowInfo.a);
	} else {
		return vec4(0);
	}
}