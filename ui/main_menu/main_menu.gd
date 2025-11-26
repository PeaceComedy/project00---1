extends Control

signal start_game # 定义信号：告诉外部（Main）点了start

@onready var start_button: Button = $VBoxContainer/STARTButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	get_tree().paused = false # 确保游戏开始时不暂停（防止从暂停菜单退回主界面后游戏卡死）
	start_button.pressed.connect(_on_start_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed() -> void:
	start_game.emit() # 发送信号！Main场景收到后会负责切换到 Level01

func _on_settings_button_pressed() -> void:
	print("打开设置面板")

func _on_quit_button_pressed() -> void:
	get_tree().quit() # 退出游戏
