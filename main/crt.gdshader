shader_type canvas_item;

// 获取屏幕内容的纹理（Godot 4写法）
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// --- 可调参数 ---
// 屏幕弯曲程度 (0.0 为不弯曲)
uniform float curvature : hint_range(0.0, 10.0) = 2.0;
// 扫描线暗度
uniform float scanline_alpha : hint_range(0.0, 1.0) = 0.5;
// 扫描线数量
uniform float scanline_count : hint_range(0, 1200) = 180.0;
// 扫描线滚动速度 (实现"动起来"的关键)
uniform float speed : hint_range(-10.0, 10.0) = 1.0;
// 噪点强度
uniform float noise_amount : hint_range(0.0, 1.0) = 0.05;
// 色差 (RGB分离效果)
uniform float aberration : hint_range(0.0, 0.05) = 0.005;

// --- Roll (干扰条纹) 参数 ---
uniform bool roll_on = true;
// 干扰条滚动的速度
uniform float roll_speed : hint_range(-20.0, 20.0) = 8.0; 
// 干扰条的粗细/密度
uniform float roll_size : hint_range(0.0, 100.0) = 15.0; 
// 干扰条的变化率 (值越高条纹越不规则)
uniform float roll_variation : hint_range(0.1, 5.0) = 1.8; 
// 干扰条造成的画面扭曲强度
uniform float distort_intensity : hint_range(0.0, 0.2) = 0.05; 
// 干扰条本身的噪点可见度 (白色杂讯)
uniform float roll_noise_opacity : hint_range(0.0, 1.0) = 0.4;

// --- 新增：VHS 滤色 (Discolor) 参数 ---
uniform bool discolor = true; // 开关
// 饱和度 (0.0=黑白, 1.0=原色)。原Shader里的逻辑是反的，但我把它改成符合直觉的操作了。
uniform float saturation : hint_range(0.0, 1.0) = 0.5; 
// 对比度 (1.0=原图, 高于1.0增加对比度)
uniform float contrast : hint_range(0.0, 3.0) = 1.2;


// --- 辅助函数：随机数 ---
vec2 random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

// --- 辅助函数：Perlin 噪声 ---
float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, uv_fract);
    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) * 0.5 + 0.5;
}

// --- 屏幕弯曲函数 ---
vec2 curve(vec2 uv) {
	uv = (uv - 0.5) * 2.0;
	uv.x *= 1.0 + pow(abs(uv.y) / 5.0, curvature);
	uv.y *= 1.0 + pow(abs(uv.x) / 5.0, curvature);
	uv  = (uv / 2.0) + 0.5;
	return uv;
}

void fragment() {
	// 应用屏幕弯曲
	vec2 uv = curve(SCREEN_UV);
	
	// 边缘裁切（把弯曲后超出屏幕的部分变黑）
	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// 计算 Roll (干扰条纹) 的扭曲逻辑
		float roll_line = 0.0;
		vec2 roll_displacement = vec2(0.0);
		
		if (roll_on) {
			// 创建干扰线条区域
			roll_line = smoothstep(0.3, 0.9, sin(uv.y * roll_size - (TIME * roll_speed) ) );
			// 再次叠加一层不同频率的 sin，增加变化
			roll_line *= roll_line * smoothstep(0.3, 0.9, sin(uv.y * roll_size * roll_variation - (TIME * roll_speed * roll_variation) ) );
			
			// 计算扭曲向量 (只在水平方向位移)
			roll_displacement = vec2(( roll_line * distort_intensity * (1.-uv.x)), 0.0);
		}
		
		// 组合 UV 并采样
		// 基础 UV + Roll 带来的扭曲
		vec2 final_uv = uv + roll_displacement;
		
		// 应用静态色差 (Aberration)
		// R通道向右偏移，B通道向左偏移
		vec2 r_uv = final_uv + vec2(aberration, 0.0);
		vec2 g_uv = final_uv;
		vec2 b_uv = final_uv - vec2(aberration, 0.0);
		
		float r = texture(screen_texture, r_uv).r;
		float g = texture(screen_texture, g_uv).g;
		float b = texture(screen_texture, b_uv).b;
		
		vec3 color = vec3(r, g, b);

		// 叠加 Roll 的白色噪点带 (视觉层)
		if (roll_on && roll_noise_opacity > 0.0) {
			// 生成拉伸的噪声图案
			float noise_val = smoothstep(0.4, 0.5, noise(uv * vec2(2.0, 200.0) + vec2(10.0, TIME * 5.0)));
			
			// 将噪声限制在 roll_line (干扰条) 的范围内
			float line_noise = roll_line * noise_val * scanline_alpha * clamp(random(vec2(uv.y, TIME)).x + 0.8, 0.0, 1.0);
			
			// 混合到颜色中
			color = clamp(mix(color, color + line_noise, roll_noise_opacity), vec3(0.0), vec3(1.0));
		}

		// 扫描线效果 (Scanlines)
		// 使用 Sin 函数和 TIME (时间) 变量让它滚动
		float scanline = sin((uv.y * scanline_count * 3.14159) - (TIME * speed));
		// 将 scanline 范围从 [-1, 1] 映射到更温和的亮度范围
		scanline = (scanline + 1.0) / 2.0; 
		scanline = 1.0 + scanline * (scanline_alpha - 1.0); // 混合强度
		
		color *= scanline;
		
		// 噪点效果 (Static Noise)
		// 使用简单的随机数生成噪点，乘以 TIME 让它每帧都闪烁
		float noise = fract(sin(dot(uv * TIME, vec2(12.9898, 78.233))) * 43758.5453);
		color = mix(color, vec3(noise), noise_amount);
		
		// 晕影 (Vignette) - 让四个角变暗
		float vignette = uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y);
		vignette = pow(vignette * 15.0, 0.25); // 调整强度
		color *= vignette;
		
		// VHS 滤色 (Discolor) 处理
		if (discolor) {
			// A. 饱和度调整 (Saturation)
			// 计算灰度值 (这里使用简单平均法，还原原Shader的粗糙感)
			vec3 greyscale = vec3((color.r + color.g + color.b) / 3.0);
			// 在灰度和原色之间混合。saturation 为 0 是全灰，1 是原色。
			color = mix(greyscale, color, saturation);
			
			// B. 对比度调整 (Contrast)
			// 计算中点 (Gamma 2.2 近似值)
			float midpoint = pow(0.5, 2.2);
			// 以中点为中心扩展或压缩颜色值
			color = (color - vec3(midpoint)) * contrast + midpoint;
		}
		
		COLOR = vec4(color, 1.0);
	}
}