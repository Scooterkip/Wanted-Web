extends CharacterBody2D

@onready var Sprite = $Sprite
@onready var RegSize = Sprite.texture.region.size

@onready var Types = []
@onready var Started = false
@onready var Buttons = Sprite.get_children()
@onready var Bounds = []

@onready var RNG = RandomNumberGenerator.new()

func _bounds():
	var LeftB = 0 + (RegSize.x / 2)
	var RightB = get_viewport_rect().size.x - (RegSize.x / 2)
	var UpB = 0 + (RegSize.y / 2)
	var DownB = get_viewport_rect().size.y - (RegSize.y / 2)
	Bounds = [LeftB, RightB, UpB, DownB]

func _bounce(Dir):
	var BounceTween = get_tree().create_tween()
	if Dir == "X":
		BounceTween.tween_property(get_node("Sprite"), "offset:x", -20, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		BounceTween.tween_property(get_node("Sprite"), "offset:x", 20, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	if Dir == "Y":
		BounceTween.tween_property(get_node("Sprite"), "offset:y", -20, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		BounceTween.tween_property(get_node("Sprite"), "offset:y", 20, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	BounceTween.tween_callback(_bounced.bind(Dir))

func _bounced(Dir):
	_bounce(Dir)

func _game_over():
	var GOTween = get_tree().create_tween()
	var TempNum = 0
	while TempNum < 5:
		GOTween.tween_property(self, "position:x", position.x - 1, .1)
		GOTween.tween_property(self, "position:x", position.x + 1, .1)
		TempNum += 1
	GOTween.tween_property(self, "position:y", get_viewport_rect().size.y + RegSize.y, .5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN_OUT)

func _process(delta):
	if "Left" in Types:
		move_and_slide()
		if global_position.x < (0 - (RegSize.x)):
			global_position.x = get_viewport_rect().size.x + RegSize.x
	elif "Right" in Types:
		move_and_slide()
		if global_position.x > (get_viewport_rect().size.x + (RegSize.x)):
			global_position.x = -RegSize.x
	if "Up" in Types:
		move_and_slide()
		if global_position.y < (0 - (RegSize.y)):
			global_position.y = get_viewport_rect().size.y + RegSize.y
	elif "Down" in Types:
		move_and_slide()
		if global_position.y > (get_viewport_rect().size.y + (RegSize.y)):
			global_position.y = -RegSize.y
	if "DVD" in Types:
		if Bounds.size() > 0:
			move_and_slide()
			if global_position.x < Bounds[0] or global_position.x > Bounds[1]:
				velocity.x = -velocity.x
			if global_position.y < Bounds[2] or global_position.y > Bounds[3]:
				velocity.y = -velocity.y
	if "GameOver" in Types:
		velocity = Vector2(0, 200)
		move_and_slide()
	
	if Started == false:
		Started = true
		if "BounceX" in Types:
			_bounce("X")
		if "BounceY" in Types:
			_bounce("Y")
		
		if "DVD" in Types:
			_bounds()
		
		if get_node("Sprite").get_children().size() > 0:
			for i in Buttons:
				i.set_meta("init_pos", i.position)
		
	if get_node("Sprite").get_children().size() > 0:
		for i in Buttons:
			i.position = Sprite.offset - i.get_meta("init_pos")
