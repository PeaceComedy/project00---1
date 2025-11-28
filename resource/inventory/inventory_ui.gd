extends Control

@export var inventory_slot_scene: PackedScene

@onready var grid_container: GridContainer = $Window/MarginContainer/GridContainer

var is_open := false # 默认背包是关着的

func _ready() -> void:
	hide()# 初始化时隐藏背包
	is_open = false
	
	# 连接全局背包的信号，只要数据变了，就自动调用update_inventory_display
	GlobalPlayerManager.player_inventory.inventory_changed.connect(update_inventory_display)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		if is_open: close()
		else: open()

func open(): # 开背包
	show()
	is_open = true
	update_inventory_display() # 打开时刷新一次，确保数据最新

func close(): # 关背包
	hide()
	is_open = false

func update_inventory_display():
	for child in grid_container.get_children(): # 清除旧的格子，防止重复生成
		child.queue_free()
	
	for item in GlobalPlayerManager.player_inventory.items: # 遍历全局背包里的所有物品
		var slot = inventory_slot_scene.instantiate()
		grid_container.add_child(slot) # 添加到网格里
		slot.display_item(item) # 让格子显示这个物品的数据
