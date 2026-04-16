precision highp float;
precision highp int;
precision highp sampler2D;

// R2-UI Bloom pyramid：2x upsample + 9-tap tent filter（Jimenez / Unreal / Blender Eevee）
// radius 固定為 1 source texel：tap 間距恰好貼齊相鄰 texel，bilinear filter 無縫銜接，
// 避免 tap spacing 超出 texel 造成的離散斑點（馬賽克）。
// halo 廣度由金字塔層數決定，不靠拉大 tap 間距。
// material 設 AdditiveBlending，GPU 將此結果加到 dest mip 既有內容上。

uniform sampler2D tBloomTexture;

void main()
{
	vec2 srcSize = vec2(textureSize(tBloomTexture, 0));
	vec2 destSize = srcSize * 2.0;
	vec2 uv = gl_FragCoord.xy / destSize;

	// tap 間距 = 1 source texel，固定值
	vec2 o = 1.0 / srcSize;

	// 9-tap tent filter，權重 (1, 2, 1 | 2, 4, 2 | 1, 2, 1) / 16
	vec3 c = vec3(0.0);
	c += texture(tBloomTexture, uv + vec2(-o.x, -o.y)).rgb;
	c += texture(tBloomTexture, uv + vec2( 0.0, -o.y)).rgb * 2.0;
	c += texture(tBloomTexture, uv + vec2( o.x, -o.y)).rgb;
	c += texture(tBloomTexture, uv + vec2(-o.x, 0.0)).rgb * 2.0;
	c += texture(tBloomTexture, uv).rgb * 4.0;
	c += texture(tBloomTexture, uv + vec2( o.x, 0.0)).rgb * 2.0;
	c += texture(tBloomTexture, uv + vec2(-o.x, o.y)).rgb;
	c += texture(tBloomTexture, uv + vec2( 0.0, o.y)).rgb * 2.0;
	c += texture(tBloomTexture, uv + vec2( o.x, o.y)).rgb;

	c *= 1.0 / 16.0;

	pc_fragColor = vec4(c, 1.0);
}
