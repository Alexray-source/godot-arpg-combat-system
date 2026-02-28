class_name MeleeAttack extends AttackComponent

@export var animation_library : String
@export var anim_player : AnimationPlayer
@export var hostile_mask : int = 1
@export var dmg : int = 10

var animation_chainer : AnimationChainer = AnimationChainer.new()
var melee_hitbox : MeleeHitbox = MeleeHitbox.new()

func _ready() -> void:
	melee_hitbox.scan_mask = hostile_mask
	melee_hitbox.atk_info = AtkInfo.new(dmg, AtkInfo.AtkType.MELEE, character)
	
	animation_chainer.anim_player = anim_player
	animation_chainer.attacks_library_name = animation_library
	animation_chainer.animation_finished.connect(on_animation_finish)
	animation_chainer.setup()

func on_animation_finish():
	atk_finished.emit()

func action() -> void:
	animation_chainer.resume_chain()

func attack() -> void:
	melee_hitbox.attack()
