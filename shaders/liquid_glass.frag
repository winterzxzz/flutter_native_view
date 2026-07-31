#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

// Lens geometry (logical pixels).
uniform vec2 uPaintOffset;   // top-left of the lens rect in canvas coords
uniform vec2 uSize;          // lens size
uniform float uRadius;       // corner radius

// Backdrop sampling.
uniform vec2 uBgSize;        // captured image size in PHYSICAL pixels
uniform vec2 uLensOffset;    // lens top-left relative to the captured view (logical)
uniform float uDpr;          // device pixel ratio (logical -> physical)

// Look.
uniform float uRefraction;   // edge bend strength (logical px)
uniform float uChroma;       // chromatic aberration (logical px)
uniform vec4 uTint;          // straight-alpha tint; a = tint amount
uniform float uHighlight;    // rim specular intensity 0..1
uniform float uPress;        // 0..1 press progress (intensifies the bend)

uniform sampler2D uBg;

out vec4 fragColor;

// Signed distance to a rounded rectangle centered at the origin.
float sdRoundRect(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

vec4 sampleBg(vec2 logicalPos) {
  // logical -> physical -> normalized UV, clamped to avoid sampling outside
  // the captured view (which would read undefined/black pixels).
  vec2 uv = clamp((logicalPos * uDpr) / uBgSize, vec2(0.0), vec2(1.0));
  return texture(uBg, uv);
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 local = fragCoord - uPaintOffset;   // 0..uSize inside the lens
  vec2 halfSize = uSize * 0.5;
  vec2 p = local - halfSize;
  float r = min(uRadius, min(halfSize.x, halfSize.y));

  float d = sdRoundRect(p, halfSize, r);

  // Surface normal from the SDF gradient (points outward from the edge).
  const float e = 1.0;
  vec2 n = vec2(
    sdRoundRect(p + vec2(e, 0.0), halfSize, r) - sdRoundRect(p - vec2(e, 0.0), halfSize, r),
    sdRoundRect(p + vec2(0.0, e), halfSize, r) - sdRoundRect(p - vec2(0.0, e), halfSize, r)
  );
  n = length(n) > 0.0 ? normalize(n) : vec2(0.0);

  // 0 in the flat center, ramping to 1 at the curved edge band.
  float band = min(halfSize.x, halfSize.y);
  float edge = smoothstep(-band, 0.0, d);
  edge = edge * edge;                       // bias bending toward the rim
  float bend = uRefraction * (1.0 + uPress * 1.5) * edge;

  // Position in the captured view that this pixel refracts to.
  vec2 base = uLensOffset + local + n * bend;

  // Chromatic aberration: split the channels along the normal.
  float ca = uChroma * edge;
  vec3 col;
  col.r = sampleBg(base + n * ca).r;
  col.g = sampleBg(base).g;
  col.b = sampleBg(base - n * ca).b;

  // Glass tint.
  col = mix(col, uTint.rgb, uTint.a);

  // Specular rim near the outer edge.
  float rim = smoothstep(0.7, 1.0, edge) * uHighlight;
  col += rim;

  // Antialiased shape mask.
  float aa = 1.0 - smoothstep(-1.0, 0.5, d);
  fragColor = vec4(col, 1.0) * aa;
}
