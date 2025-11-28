extends CharacterBody2D
class_name Player

const ROLL_SPEED = 125.0
const ROLL_STAMINA_COST = 25.0 # 翻滚消耗耐力值

@export var stats: PlayerStats
var input_vector := Vector2.ZERO # 输入向量，默认给到(0,0)
var last_input_vector = Vector2.DOWN # 记录最后输入的向量，确保不会原地翻滚

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var blink_animation_player: AnimationPlayer = $BlinkAnimationPlayer


func _ready() -> void:
	GlobalPlayerManager.player = self # 主动注册：告诉Manager我来了
	hurtbox.hurt.connect(take_hit.call_deferred) # 受击框受伤状态连接，触发击退状态（在当前帧末尾）
	stats.no_health.connect(die) # 没血时死亡
	stats.stamina = stats.max_stamina # 游戏开始时把耐力回满

func _physics_process(delta: float) -> void:
	stats.process_stamina_regen(delta) # 每帧调用stats里的恢复函数
	
	var state = playback.get_current_node() # 定义变量：状态，等同于获取动画树中当前状态
	match state: # 匹配执行不同的状态
		"MoveState": move_state(delta) # 移动状态时，调用移动状态函数
		"AttackState": pass # 攻击状态时
		"RollState": roll_state(delta) # 翻滚状态时

func _exit_tree(): # 场景切换或玩家死亡销毁时，清理引用，防止悬空指针
	if GlobalPlayerManager.player == self:
		GlobalPlayerManager.player = null


func die() -> void: # 死亡
	hide() # 隐藏玩家
	remove_from_group("player") # 移出组，确保敌人不会在玩家死后抽风
	process_mode = Node.PROCESS_MODE_DISABLED # 节点处理属性变为禁用，确保摄像机定在死亡位置
	GlobalPlayerManager.player_died.emit() # # 通知全局管理器玩家死了

func revive() -> void:
	stats.health = stats.max_health # 恢复满血
	process_mode = Node.PROCESS_MODE_INHERIT # 恢复处理（允许移动和输入）
	show() # 重新显示并加回分组,让敌人能再次看见
	if not is_in_group("player"):
		add_to_group("player")

func take_hit(other_hitbox: Hitbox) -> void: # 变为击退状态
	stats.health -= other_hitbox.damage # 击退时，受到指定伤害扣除血量
	blink_animation_player.play("Blink") # 播放闪烁动画，同时有无敌帧
	
	
func move_state(delta: float) -> void: # 移动状态，并接受与物理过程相同的delta变量
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down") 
	
	if input_vector != Vector2.ZERO: # 如果输入向量不为(0,0)，调用更新混合位置
		var direction_vector := Vector2.ZERO
		last_input_vector = input_vector # 更新当前最后输入向量的值，获得准确翻滚方向
		update_blend_position(direction_vector)
		hitbox.knockback_direction = input_vector.normalized() # 获取当前应该的击退方向
	
	if Input.is_action_just_pressed("attack"): # 如果按下攻击键，移动状态切换为攻击状态
		playback.travel("AttackState")
	
	if Input.is_action_just_pressed("roll"): # 如果按下翻滚键，移动状态切换为翻滚状态
		if stats.stamina >= ROLL_STAMINA_COST: # 检查耐力
			stats.stamina -= ROLL_STAMINA_COST # 扣除耐力
			playback.travel("RollState") # 执行翻滚
	
	velocity = input_vector * stats.move_speed # 实际移动速度=输入向量*移动速度
	move_and_slide()

func roll_state(delta: float) -> void: # 翻滚状态，并接受与物理过程相同的delta变量
	# 实际翻滚速度=输入向量*翻滚速度，归一化处理保证保持为1，手柄输入数值可能1>x>0之间
	velocity = last_input_vector.normalized() * ROLL_SPEED
	move_and_slide()
	
	
func update_blend_position(directon_vector: Vector2) -> void: # 更新混合位置，处理状态机更新各状态的动画
	animation_tree.set("parameters/StateMachine/MoveState/RunState/blend_position", input_vector)
	animation_tree.set("parameters/StateMachine/MoveState/StandState/blend_position", input_vector)
	animation_tree.set("parameters/StateMachine/AttackState/blend_position", input_vector)
	animation_tree.set("parameters/StateMachine/RollState/blend_position", input_vector)
