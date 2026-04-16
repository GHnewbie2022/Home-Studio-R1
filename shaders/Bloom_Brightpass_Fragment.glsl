precision highp float;
precision highp int;
precision highp sampler2D;

// R2-UI Bloom pyramid Pass 1/N：brightpass + 2x downsample with 13-tap Karis average
// Reference: Jorge Jimenez, "Next Generation Post Processing in Call of Duty: Advanced Warfare" SIGGRAPH 2014
// Unreal 與 Blender Eevee 皆採用此演算法。
//
// 13 個 tap 分成 5 個重疊的 2x2 組（中心組 + 4 個外圈組），每組內用 Karis 加權平均
//   w_i = 1 / (1 + luma_i)
// 防止 path tracer 偶發的 firefly 像素把整塊 mip 染白。之後 downsample chain 再沿用
// 13-tap 結構但不再做 Karis（firefly 已在此處壓制）。

uniform sampler2D tPathTracedImageTexture;
uniform float uOneOverSampleCounter;

float karisWeight(vec3 c)
{
	float luma = dot(c, vec3(0.2126, 0.7152, 0.0722));
	return 1.0 / (1.0 + luma);
}

vec3 karisAvg4(vec3 a, vec3 b, vec3 c, vec3 d)
{
	float wa = karisWeight(a);
	float wb = karisWeight(b);
	float wc = karisWeight(c);
	float wd = karisWeight(d);
	return (a * wa + b * wb + c * wc + d * wd) / (wa + wb + wc + wd);
}

void main()
{
	vec2 srcSize = vec2(textureSize(tPathTracedImageTexture, 0));
	vec2 texel = 1.0 / srcSize;
	// destination 為 1/2 res，gl_FragCoord.xy 為 dest pixel 中心
	// 映射到 src UV：src_uv = gl_FragCoord.xy * 2 * texel
	vec2 uv = gl_FragCoord.xy * 2.0 * texel;

	// 13 taps 布局（在 src texel 單位下）：
	//   a b c     (-2, 2) ( 0, 2) ( 2, 2)
	//   d e f     (-2, 0) ( 0, 0) ( 2, 0)
	//   g h i     (-2,-2) ( 0,-2) ( 2,-2)
	//      j k         (-1, 1) ( 1, 1)
	//      l m         (-1,-1) ( 1,-1)
	vec3 a = texture(tPathTracedImageTexture, uv + vec2(-2.0,  2.0) * texel).rgb;
	vec3 b = texture(tPathTracedImageTexture, uv + vec2( 0.0,  2.0) * texel).rgb;
	vec3 c = texture(tPathTracedImageTexture, uv + vec2( 2.0,  2.0) * texel).rgb;
	vec3 d = texture(tPathTracedImageTexture, uv + vec2(-2.0,  0.0) * texel).rgb;
	vec3 e = texture(tPathTracedImageTexture, uv).rgb;
	vec3 f = texture(tPathTracedImageTexture, uv + vec2( 2.0,  0.0) * texel).rgb;
	vec3 g = texture(tPathTracedImageTexture, uv + vec2(-2.0, -2.0) * texel).rgb;
	vec3 h = texture(tPathTracedImageTexture, uv + vec2( 0.0, -2.0) * texel).rgb;
	vec3 i = texture(tPathTracedImageTexture, uv + vec2( 2.0, -2.0) * texel).rgb;
	vec3 j = texture(tPathTracedImageTexture, uv + vec2(-1.0,  1.0) * texel).rgb;
	vec3 k = texture(tPathTracedImageTexture, uv + vec2( 1.0,  1.0) * texel).rgb;
	vec3 l = texture(tPathTracedImageTexture, uv + vec2(-1.0, -1.0) * texel).rgb;
	vec3 m = texture(tPathTracedImageTexture, uv + vec2( 1.0, -1.0) * texel).rgb;

	// path tracer 累加但未除 sampleCounter，先 normalize 再算 luma weight
	float inv = uOneOverSampleCounter;
	a *= inv; b *= inv; c *= inv;
	d *= inv; e *= inv; f *= inv;
	g *= inv; h *= inv; i *= inv;
	j *= inv; k *= inv; l *= inv; m *= inv;

	// 5 組 Karis 平均，權重 center 0.5 + 4 個 corner 0.125
	vec3 center = karisAvg4(j, k, l, m);
	vec3 tl = karisAvg4(a, b, d, e);
	vec3 tr = karisAvg4(b, c, e, f);
	vec3 bl = karisAvg4(d, e, g, h);
	vec3 br = karisAvg4(e, f, h, i);

	vec3 hdr = center * 0.5 + (tl + tr + bl + br) * 0.125;

	// bright-pass：smoothstep(0.3, 1.0) 柔化閾值
	float lum = max(max(hdr.r, hdr.g), hdr.b);
	float w = smoothstep(0.3, 1.0, lum);

	pc_fragColor = vec4(hdr * w, 1.0);
}
