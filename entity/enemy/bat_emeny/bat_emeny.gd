extends CharacterBody2D

const CHASE_SPEED = 30
const FRICTION = 500

@export var min_hatred_range := 5 # 仇恨最小范围
@export var max_hatred_range := 150 # 仇恨最大范围
@export var stats: Stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var hurtbox: Hurtbox = $Hurtbox

func _ready() -> void:
	stats = stats.duplicate() # 复制一份stats以实例化
	hurtbox.hurt.connect(take_hit.call_deferred) # 受击框受伤信号连接，触发击退状态（在当前帧末尾）
	stats.no_health.connect(queue_free) # 没血时消失

func _physics_process(delta: float) -> void:
	var state = playback.get_current_node() # 状态，等同于获取动画树中当前状态
	match state: # 匹配执行不同的状态
		"IdleState": pass # 处在待机状态时
		"ChaseState": # 进入追逐状态时
			var player = get_player()
			if player is Player: # 如果找的到玩家
				# 计算一个指向玩家的速度向量，然后敌人以CHASE_SPEED的速度朝玩家移动
				velocity = global_position.direction_to(player.global_position) * CHASE_SPEED
				sprite_2d.scale.x = sign(velocity.x) # 返回与velocity.x相同的正负
			else: # 如果找不到玩家
				velocity = Vector2.ZERO
			move_and_slide()
		"HitState":
			# 让velocity以摩擦力的速度逐渐变小，最终变成0
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			move_and_slide()

func take_hit(other_hitbox: Hitbox) -> void: # 变为击退状态
		stats.health -= other_hitbox.damage # 击退时，受到指定伤害扣除血量
		# 击退速度=受击方向*hitbox的击退量
		velocity = other_hitbox.knockback_direction * other_hitbox.knockback_amount
		playback.start("HitState")
		print("change to the hitstate")

func get_player() -> Player: # 获取玩家，并返回Player对象获取其自动补全
	return get_tree().get_first_node_in_group("player") # 获取player分组中第一个节点的场景树

func is_player_in_range() -> bool: # 检查玩家是否是在仇恨范围内
	var result = false # 定义变量：默认结果为false
	
	var player := get_player()
	if player is Player: # 如果找得到玩家，定义其与玩家的距离为distance_to_player
		var distance_to_player = global_position.distance_to(player.global_position)
		# 如果distance_to_player在仇恨范围之间，返回true
		if distance_to_player < max_hatred_range and distance_to_player > min_hatred_range:
			result = true
	return result # 返回结果

func can_see_player()-> bool: # 能否看见玩家
	if not is_player_in_range(): return false # 如果不在范围内，返回false
	
	var player:= get_player()
	# 射线到目标的距离=玩家位置-自身位置
	ray_cast_2d.target_position = player.global_position - global_position
	# 视线内有玩家=视线没有阻挡，返回true
	var has_line_of_sight_to_player := not ray_cast_2d.is_colliding()
	return has_line_of_sight_to_player
