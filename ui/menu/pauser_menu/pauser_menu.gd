class_name PauserMenu
extends Control

@export_file("*.tscn") var main_scene_path: String

@onready var resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton


func _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed) # 连接信号
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	hide() # 游戏开始时隐藏暂停菜单

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"): # 监听ESC键
		toggle_pause()


func _on_resume_pressed() -> void:
	toggle_pause() # 继续游戏：只需再次调用切换函数即可

func _on_main_menu_pressed() -> void:
	# 返回主界面，先恢复游戏运行（否则切换场景后，新场景可能还是暂停的）
	get_tree().paused = false
	get_tree().change_scene_to_file(main_scene_path)

func _on_quit_pressed() -> void:
	get_tree().quit()

func toggle_pause() -> void: # 切换暂停状态的核心逻辑
	get_tree().paused = not get_tree().paused # 切换暂停状态
	if get_tree().paused: show() # 根据暂停状态，显示或隐藏菜单
	else: hide()
