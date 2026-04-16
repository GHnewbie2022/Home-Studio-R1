precision highp float;
precision highp int;
precision highp sampler2D;

// R2-UI Bloom pyramid：13-tap downsample（Jimenez / Unreal / Blender Eevee）
// 從 source mip 以 13-tap 5-group weighted average 降到 0.5x 解析度
// 不做 Karis average（firefly 已在 brightpass 處理），使用簡單加權：
//   center tap (e):                 0.125
//   inner 4 (j,k,l,m):              0.125 each (總 0.5)
//   outer edges (b,d,f,h):          0.0625 each (總 0.25)
//   outer corners (a,c,g,i):        0.03125 each (總 0.125)
// 權重總和 = 1.0

uniform sampler2D tBloomTexture;

void main()
{
	vec2 srcSize = vec2(textureSize(tBloomTexture, 0));
	vec2 texel = 1.0 / srcSize;
	// dest 為 src 的 1/2 res，gl_FragCoord.xy 為 dest 中心
	vec2 uv = gl_FragCoord.xy * 2.0 * texel;

	vec3 a = texture(tBloomTexture, uv + vec2(-2.0,  2.0) * texel).rgb;
	vec3 b = texture(tBloomTexture, uv + vec2( 0.0,  2.0) * texel).rgb;
	vec3 c = texture(tBloomTexture, uv + vec2( 2.0,  2.0) * texel).rgb;
	vec3 d = texture(tBloomTexture, uv + vec2(-2.0,  0.0) * texel).rgb;
	vec3 e = texture(tBloomTexture, uv).rgb;
	vec3 f = texture(tBloomTexture, uv + vec2( 2.0,  0.0) * texel).rgb;
	vec3 g = texture(tBloomTexture, uv + vec2(-2.0, -2.0) * texel).rgb;
	vec3 h = texture(tBloomTexture, uv + vec2( 0.0, -2.0) * texel).rgb;
	vec3 i = texture(tBloomTexture, uv + vec2( 2.0, -2.0) * texel).rgb;
	vec3 j = texture(tBloomTexture, uv + vec2(-1.0,  1.0) * texel).rgb;
	vec3 k = texture(tBloomTexture, uv + vec2( 1.0,  1.0) * texel).rgb;
	vec3 l = texture(tBloomTexture, uv + vec2(-1.0, -1.0) * texel).rgb;
	vec3 m = texture(tBloomTexture, uv + vec2( 1.0, -1.0) * texel).rgb;

	vec3 result = e * 0.125;
	result += (j + k + l + m) * 0.125;
	result += (b + d + f + h) * 0.0625;
	result += (a + c + g + i) * 0.03125;

	pc_fragColor = vec4(result, 1.0);
}
