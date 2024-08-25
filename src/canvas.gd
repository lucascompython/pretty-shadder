extends ColorRect

@onready var label := $"../Label"

enum Settings {COMPLEXITY, PERIODICITY, FRACTAL_FORCE, COLOR_SPECTRUM, COLOR_SPEED, BRIGHTNESS, SPEED}
enum Spectrum {EMBER, RAINBOW, BMO, GBO, YMC, RANDOM, PURPLE}

var shader: ShaderMaterial = material

var active_setting := 0
var active_spectrum := 0

var color_speed := 0.1
var brightness := 0.01
var complexity := 3.0
var periodicity := 8.0
var fractal_force := 1.5
var speed := 1.0
var elapsed := 0.0

# http://dev.thi.ng/gradients/
var color_presets := {
	Spectrum.EMBER: [Vector3(0.914, 0.832, 0.920), Vector3(0.701, 0.468, 0.573), Vector3(0.534, 1.034, 1.222), Vector3(5.992, 2.194, 1.858)],
	Spectrum.RAINBOW: [Vector3(0.500, 0.500, 0.500), Vector3(0.500, 0.500, 0.500), Vector3(1.000, 1.000, 1.000), Vector3(0.000, 0.333, 0.667)],
	Spectrum.PURPLE: [Vector3(0.216, 0.153, 0.895), Vector3(0.695, 0.621, 0.554), Vector3(0.814, 1.381, 1.127), Vector3(3.871, 0.115, 0.124)],
	Spectrum.BMO: [Vector3(0.938, 0.328, 0.718), Vector3(0.659, 0.438, 0.328), Vector3(0.388, 0.388, 0.296), Vector3(2.538, 2.478, 0.168)],
	Spectrum.GBO: [Vector3(0.892, 0.725, 0.000), Vector3(0.878, 0.278, 0.725), Vector3(0.332, 0.518, 0.545), Vector3(2.440, 5.043, 0.732)],
	Spectrum.YMC: [Vector3(1.000, 0.500, 0.500), Vector3(0.500, 0.500, 0.500), Vector3(0.750, 1.000, 0.667), Vector3(0.800, 1.000, 0.333)],
}

var a: Vector3 = color_presets[Spectrum.PURPLE][0]
var b: Vector3 = color_presets[Spectrum.PURPLE][1]
var c: Vector3 = color_presets[Spectrum.PURPLE][2]
var d: Vector3 = color_presets[Spectrum.PURPLE][3]


func _ready() -> void:
	active_setting = Settings.COMPLEXITY
	update_text(Settings.keys()[active_setting])
	update_shader()

func update_shader() -> void:
	shader.set_shader_parameter("color_speed", color_speed)
	shader.set_shader_parameter("brightness", brightness)
	shader.set_shader_parameter("complexity", complexity)
	shader.set_shader_parameter("periodicity", periodicity)
	shader.set_shader_parameter("fractal_force", fractal_force)
	shader.set_shader_parameter("speed", speed)
	shader.set_shader_parameter("a", a)
	shader.set_shader_parameter("b", b)
	shader.set_shader_parameter("c", c)
	shader.set_shader_parameter("d", d)
	
func set_color_spectrum(color_preset: int) -> void:
	update_text(Spectrum.keys()[color_preset])

	if color_preset == Spectrum.RANDOM:
		a = Vector3(randf_range(-PI, + PI), randf_range(-PI, + PI), randf_range(-PI, + PI))
		b = Vector3(randf_range(-PI, + PI), randf_range(-PI, + PI), randf_range(-PI, + PI))
		c = Vector3(randf_range(-PI, + PI), randf_range(-PI, + PI), randf_range(-PI, + PI))
		d = Vector3(randf_range(-PI, + PI), randf_range(-PI, + PI), randf_range(-PI, + PI))
	else:
		a = color_presets[color_preset][0]
		b = color_presets[color_preset][1]
		c = color_presets[color_preset][2]
		d = color_presets[color_preset][3]

func increase_setting() -> void:
	var max_value := false

	match active_setting:
		Settings.COLOR_SPEED:
			if color_speed < 1:
				color_speed += 0.1
			else:
				max_value = true
		Settings.COMPLEXITY:
			if complexity < 10:
				complexity += 1
			else:
				max_value = true
		Settings.BRIGHTNESS:
			if brightness < 0.08:
				brightness += 0.005
			else:
				max_value = true
		Settings.PERIODICITY:
			if periodicity < 50.0:
				periodicity += 1.0
			else:
				max_value = true
		Settings.FRACTAL_FORCE:
			if fractal_force < 2.0:
				fractal_force += 0.1
			else:
				max_value = true
		Settings.SPEED:
			if speed < 20.0:
				speed += 1.0
			else:
				max_value = true
		Settings.COLOR_SPECTRUM:
			active_spectrum += 1
			active_spectrum = active_spectrum % Spectrum.size()
			set_color_spectrum(active_spectrum)
			update_shader()
			return

	update_shader()
	if max_value:
		update_text("Max Reached")
	else:
		update_text(str(Settings.keys()[active_setting], " increased"))
	
	
func decrease_setting() -> void:
	var min_value := false

	match active_setting:
		Settings.COLOR_SPEED:
			if color_speed > 0:
				color_speed -= 0.1
			else:
				min_value = true
		Settings.COMPLEXITY:
			if complexity > 1:
				complexity -= 1
			else:
				min_value = true
		Settings.BRIGHTNESS:
			if brightness > 1:
				brightness -= 0.005
			else:
				min_value = true
		Settings.PERIODICITY:
			if periodicity > 0.0:
				periodicity -= 1.0
			else:
				min_value = true
		Settings.FRACTAL_FORCE:
			if fractal_force > 0.0:
				fractal_force -= 0.1
			else:
				min_value = true
		Settings.SPEED:
			if speed > 0.0:
				speed -= 1.0
			else:
				min_value = true
		Settings.COLOR_SPECTRUM:
			active_spectrum -= 1
			active_spectrum = (active_spectrum + Spectrum.size()) % Spectrum.size()
			set_color_spectrum(active_spectrum)
			update_shader()
			return

	update_shader()
	if min_value:
		update_text("Min Reached")
	else:
		update_text(str(Settings.keys()[active_setting], " decreased"))

func next_setting() -> void:
	active_setting += 1
	active_setting = active_setting % Settings.size()
	update_text(Settings.keys()[active_setting])

func previous_setting() -> void:
	active_setting = (active_setting - 1 + Settings.size())
	active_setting = active_setting % Settings.size()
	update_text(Settings.keys()[active_setting])


func update_text(text: String) -> void:
	label.text = text


const threshold := 100

func _input(event: InputEvent) -> void:

	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.relative.x > threshold:
			next_setting()
		elif drag.relative.x < -threshold:
			previous_setting()
		elif drag.relative.y > threshold:
			decrease_setting()
		elif drag.relative.y < -threshold:
			increase_setting()
		return
		
	if Input.is_action_just_pressed("ui_up"):
		increase_setting()
	elif Input.is_action_just_pressed("ui_down"):
		decrease_setting()
	elif Input.is_action_just_pressed("ui_left"):
		previous_setting()
	elif Input.is_action_just_pressed("ui_right"):
		next_setting()
	
func _process(delta: float) -> void:
	if speed != 0.0:
		shader.set_shader_parameter("out_time", (Time.get_ticks_msec() / 1000.0) - elapsed)
	else:
		elapsed += delta
