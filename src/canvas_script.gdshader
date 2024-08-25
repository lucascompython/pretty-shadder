shader_type canvas_item;
uniform float color_speed;
uniform float brightness;
uniform float complexity;
uniform float periodicity;
uniform float fractal_force;
uniform float speed;
uniform float out_time = 0.0;
uniform vec3 a;
uniform vec3 b;
uniform vec3 c;
uniform vec3 d;

//https://iquilezles.org/articles/palettes/
vec3 palette(float t) { return a + b * cos(6.28318 * (c * t * d)); }

void fragment() {
  vec2 i_resolution = 1.0 / SCREEN_PIXEL_SIZE;
  vec2 uv = (FRAGCOORD.xy * 2.0 - i_resolution.xy) / i_resolution.y;
  vec2 uv0 = uv;
  vec3 finalColor = vec3(0.0);

  for (float i = 0.0; i < complexity; i++) {
    uv = (fract(uv * fractal_force) - 0.5);

    float dist = length(uv) * exp(-length(uv0));
    vec3 col = palette(length(uv0) + i * .4 + TIME * color_speed);

    float cur_speed = speed;
    if (cur_speed == 0.0) {
      cur_speed = 1.0;
    }

    dist = sin(dist * periodicity + (out_time * cur_speed)) / periodicity;
    dist = abs(dist);
    dist = pow(brightness / dist, 1.2);
    finalColor += col * dist;
  }

  COLOR = vec4(finalColor, 1.0);
}