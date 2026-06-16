shader_type canvas_item;

// Вхідні (оригінальні) кольори, які хочемо замінити
uniform vec3 from_color1 : source_color = vec3(0.125, 0.0,   0.698);
uniform vec3 from_color2 : source_color = vec3(0.225, 0.38, 0.984);

// Нові кольори
uniform vec3 to_color1   : source_color = vec3(0.698, 0.0, 0.125);
uniform vec3 to_color2   : source_color = vec3(0.984, 0.38, 0.225);

// Допустима відстань (чемність порівняння)
uniform float threshold  : hint_range(0.0, 0.5) = 0.05;

void fragment() {
    // Беремо колір з текстури
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Обчислюємо квадрат відстані до першого й другого "зразка"
    float d1 = dot(tex_color.rgb - from_color1, tex_color.rgb - from_color1);
    float d2 = dot(tex_color.rgb - from_color2, tex_color.rgb - from_color2);
    
    // Порівнюємо з квадратом threshold
    float t2 = threshold * threshold;
    if (d1 < t2) {
        // заміняємо перший колір
        tex_color.rgb = mix(tex_color.rgb, to_color1, 1.0);
    }
    else if (d2 < t2) {
        // заміняємо другий колір
        tex_color.rgb = mix(tex_color.rgb, to_color2, 1.0);
    }
    
    COLOR = tex_color;
}
