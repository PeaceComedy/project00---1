extends Control

signal respawn_requested # 发送信号给 Main

@onready var respawn_button: Button = $CenterContainer/VBoxContainer/RespawnButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
	respawn_button.pressed.connect(_on_respawn_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_respawn_pressed() -> void:
	respawn_requested.emit() # 告诉Main我想重生

func _on_quit_pressed() -> void:
	get_tree().quit()
