@tool
extends Node2D

@export var item_resource: Item: # 导出物品资源，可以在编辑器里指定这个地上掉的是什么
	set(value):
		item_resource = value
		_update_texture() # 在编辑器里修改资源时，自动刷新图标

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	_update_texture() # 游戏运行时初始化图标
	if not Engine.is_editor_hint(): # 不是在编辑器模式下，才连接信号（防止编辑器里误触）
		area_2d.body_entered.connect(_on_body_entered)

func _update_texture():
	if item_resource and sprite_2d: # 确保节点和资源都存在，防止报错
		sprite_2d.texture = item_resource.icon

func _on_body_entered(player: Node2D) -> void:
	if player is Player: # 只有玩家才能捡起物品
		GlobalPlayerManager.player_inventory.add_item(item_resource) # 添加到全局背包
		queue_free() # 销毁地图上的这个物体
