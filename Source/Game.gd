extends Node2D

@onready var LeftCircle = $AnimScreen/LeftCircle
@onready var RightCircle = $AnimScreen/RightCircle
@onready var LeftWanted = $AnimScreen/LeftCircle/WantedPoster
@onready var RightWanted = $AnimScreen/RightCircle/WantedPoster
@onready var LCPos = LeftCircle.position
@onready var RCPos = RightCircle.position
@onready var Middle = $AnimScreen/Middle
@onready var MPos = Middle.position

@onready var Heads = $Heads
@onready var HeadCopies = $HeadCopies
@onready var Grid = []
@onready var AllTypes = [["Left", "Right"], ["Up", "Down"], "BounceX", "BounceY", "DVD"]
@onready var ExtraTypes = [["Monochrome", "Redd", "Yellow", "Green"]]

@onready var PosterAtlus = [Vector2(2, 59), Vector2(263, 59), Vector2(2, 256), Vector2(263, 256)]

@onready var RNG = RandomNumberGenerator.new()
@onready var Char = 0
@onready var OldChar = 0
@onready var Round = 1

@onready var HeadSpeed = 50

@onready var MyTime = 10
@onready var TimeLabel = $Time
@onready var Counting = false
@onready var AddedTime = $AddedTime
@onready var MinusTime = $MinusTime

@onready var RegSize = HeadCopies.get_node("0/Sprite").texture.region.size
@onready var Bounds = []

@onready var RoundLabel = $Round

@onready var BlackBG = Color.html("#000000")
@onready var YellowBG = Color.html("#d0a600")
@onready var BG = $BG

@onready var MaxGrid = [1, 1]

@onready var GOd = false

@onready var GameOver = $GameOver
@onready var GOText1 = GameOver.get_node("Text1")
@onready var GOText2 = GameOver.get_node("Text2")
@onready var RetryBut = GameOver.get_node("RetryButton")
@onready var Retryable = false

@onready var BGM = $BGM


func _ready():
	RetryBut.connect("pressed", _retry)
	_bounds()
	GOText1.set_meta("OGSize", GOText1.size)
	GOText2.set_meta("OGSize", GOText2.size)
	var MyTimer = Timer.new()
	MyTimer.one_shot = false
	MyTimer.connect("timeout", _clock)
	add_child(MyTimer)
	MyTimer.start()
	_round()

func _bounds():
	var LeftB = 0 + (RegSize.x / 2)
	var RightB = get_viewport_rect().size.x - (RegSize.x / 2)
	var UpB = 0 + (RegSize.y / 2)
	var DownB = get_viewport_rect().size.y - (RegSize.y / 2)
	Bounds = [LeftB, RightB, UpB, DownB]

func _round():
	if Round == 15:
		AllTypes = AllTypes + ExtraTypes
		pass
	var BGTween = get_tree().create_tween()
	BGTween.tween_property(BG, "color", BlackBG, .1)
	for i in Heads.get_children():
		i.queue_free()
	RNG.randomize()
	while Char == OldChar:
		Char = RNG.randi_range(0, 3)
	OldChar = Char
	LeftWanted.texture.region.position = PosterAtlus[Char]
	await _intro_anim()
	_set_pieces(Round)
	Counting = true

func _end_round():
	_time_add()
	Counting = false
	var RemHead = _rem_head()
	for i in Heads.get_children():
		if !i.name == "RemHead":
			i.queue_free()
	AddedTime.position = RemHead.position + RemHead.get_node("Sprite").offset
	AddedTime.position -= Vector2(10, 20)
	AddedTime.visible = true
	var TimeTween = get_tree().create_tween()
	TimeTween.tween_property(AddedTime, "position:y", AddedTime.position.y - 15, 1)
	await get_tree().create_timer(1).timeout
	var BGTween = get_tree().create_tween()
	BGTween.tween_property(BG, "color", YellowBG, .1)
	await get_tree().create_timer(2).timeout
	AddedTime.visible = false
	Round += 1
	_round()

func _set_pieces(Round):
	match Round:
		1:
			Grid = _make_grid([2, 2])
			_grid_place(Grid, [])
		2:
			Grid = _make_grid([4, 4])
			_grid_place(Grid, [])
		3:
			Grid = _make_grid([8, 8])
			_grid_place(Grid, [])
		4:
			_scatter(20, [])
		_:
			RNG.randomize()
			var Placement = RNG.randi_range(0, 1)
			RNG.randomize()
			var TypeNum = RNG.randi_range(0, 3)
			var MyTypes = [""]
			for i in range(TypeNum):
				var NewType = ""
				while NewType in MyTypes:
					RNG.randomize()
					NewType = AllTypes[RNG.randi_range(0, AllTypes.size() - 1)]
				MyTypes.append(NewType)
			for i in range(MyTypes.size()):
				if MyTypes[i] is Array:
					RNG.randomize()
					var SubType = MyTypes[i][RNG.randi_range(0, MyTypes[i].size() - 1)]
					MyTypes[i] = SubType
			#if Placement == 0:
				#Grid = _make_grid([5 + Round, 5 + Round])
				#_grid_place(Grid, MyTypes)
			#elif Placement == 1:
			_scatter(30 + (Round * 2) + int(get_viewport_rect().size.x / 10), MyTypes)
			

func _make_grid(Size):
	Grid = []
	#var XSize = int(Size.x / RegSize.x)
	#var YSize = int(Size.y / RegSize.y)
	var FullSize = Vector2(RegSize.x * Size[0], RegSize.y * Size[1])
	var Offset = Vector2((get_viewport_rect().size.x / 2) - (FullSize.x / 2), 
	(get_viewport_rect().size.y / 2) - (FullSize.y / 2))
	for x in range(Size[0]):
		for y in range(Size[1]):
			Grid.append(Vector2((((x + 1) * RegSize.x) - RegSize.x / 2) + Offset.x, 
			((y + 1) * RegSize.y) - (RegSize.y / 2) + Offset.y))
	return(Grid)

func _intro_anim():
	RightCircle.visible = true
	LeftCircle.visible = true
	LeftCircle.position = LCPos
	RightCircle.position = RCPos
	LeftWanted.position.x = 202
	RightWanted.position.x = -202
	LeftCircle.scale = Vector2(1, 1)
	RightCircle.scale = Vector2(1, 1)
	var LCTween = get_tree().create_tween()
	LCTween.tween_property(LeftCircle, "position", RCPos, 1)
	LCTween.tween_property(LeftCircle, "position", MPos, 1)
	var LWTween = get_tree().create_tween()
	LWTween.tween_property(LeftWanted, "position:x", -202, 1)
	LWTween.tween_property(LeftWanted, "position:x", 0, 1)
	var RCTween = get_tree().create_tween()
	RCTween.tween_property(RightCircle, "position", LCPos, 1)
	RCTween.tween_property(RightCircle, "position", MPos, 1)
	var RWTween = get_tree().create_tween()
	RWTween.tween_property(RightWanted, "position:x", 202, 1)
	RWTween.tween_property(RightWanted, "position:x", 0, 1)
	await RWTween.finished
	await get_tree().create_timer(1).timeout
	
	var LCTweenS = get_tree().create_tween()
	LCTweenS.tween_property(LeftCircle, "scale", Vector2(.01, .01), 1)
	var RCTweenS = get_tree().create_tween()
	RCTweenS.tween_property(RightCircle, "scale", Vector2(.01, .01), 1)
	await RCTweenS.finished
	RightCircle.visible = false
	LeftCircle.visible = false
	await get_tree().process_frame

func _grid_place(Grid, Types):
	var GridHeads = []
	for i in Grid:
		RNG.randomize()
		var RandChar = Char
		while RandChar == Char:
			RandChar = RNG.randi_range(0, 3)
		var NewHead = _spawn_head(RandChar, i, Types)
		RNG.randomize()
		GridHeads.append(NewHead)
	var TrueHead = RNG.randi_range(0, Grid.size() - 1)
	GridHeads[TrueHead].call_deferred("queue_free")
	var NewHead = _spawn_head(Char, Grid[TrueHead], Types)
	NewHead.name = "TrueHead"

func _scatter(Size, Types):
	for i in range(Size):
		RNG.randomize()
		var HeadPos = Vector2(RNG.randf_range(Bounds[0], Bounds[1]), RNG.randf_range(Bounds[2], Bounds[3]))
		RNG.randomize()
		var RandChar = Char
		while RandChar == Char:
			RandChar = RNG.randi_range(0, 3)
		var NewHead = _spawn_head(RandChar, Vector2(HeadPos), Types)
	RNG.randomize()
	var HeadPos = Vector2(RNG.randf_range(0, get_viewport_rect().size.x), RNG.randf_range(0, get_viewport_rect().size.y))
	var NewHead = _spawn_head(Char, HeadPos, Types)
	NewHead.name = "TrueHead"

func _spawn_head(Char, Pos, Types):
	var HSpeed = HeadSpeed + (Round * 2)
	HeadCopies.get_child(Char).duplicate()
	var NewHead = HeadCopies.get_child(Char).duplicate()
	NewHead.position = Pos
	Heads.add_child(NewHead)
	if !"Rem" in Types:
		for i in NewHead.get_node("Sprite").get_children():
			if i is Button:
				i.connect("pressed", _head_pressed.bind(NewHead))
	if "Left" in Types:
		NewHead.velocity = Vector2(-HeadSpeed, 0)
	elif "Right" in Types:
		NewHead.velocity = Vector2(HeadSpeed, 0)
	elif "Up" in Types:
		NewHead.velocity = Vector2(0, -HeadSpeed)
	elif "Down" in Types:
		NewHead.velocity = Vector2(0, HeadSpeed)
	
	NewHead.get_node("Sprite").texture = NewHead.get_node("Sprite").texture.duplicate()
	
	if "Redd" in Types:
		NewHead.get_node("Sprite").texture.region.position.y += 35
		print(NewHead.get_node("Sprite").texture.region.position.y)
	if "Green" in Types:
		NewHead.get_node("Sprite").texture.region.position.y += 35 * 2
		print(NewHead.get_node("Sprite").texture.region.position.y)
	if "Yellow" in Types:
		NewHead.get_node("Sprite").texture.region.position.y += 35 * 3
	if "Red" in Types:
		NewHead.get_node("Sprite").texture.region.position.x += 127
	
	if "DVD" in Types:
		RNG.randomize()
		var HeadDirection = [Vector2(HeadSpeed, HeadSpeed), Vector2(-HeadSpeed, HeadSpeed), Vector2(-HeadSpeed, -HeadSpeed), Vector2(HeadSpeed, -HeadSpeed)][RNG.randi_range(0, 3)]
		NewHead.velocity = HeadDirection
	
	NewHead.Types = Types
	RNG.randomize()
	NewHead.z_index = RNG.randi_range(5, 100)
	return NewHead

func _head_pressed(HeadPressed):
	if HeadPressed.name == "TrueHead":
		_end_round()
	else:
		HeadPressed.queue_free()
		MyTime -= 10
		var NewMinusTime = MinusTime.duplicate()
		add_child(NewMinusTime)
		NewMinusTime.visible = true
		NewMinusTime.position = HeadPressed.position
		NewMinusTime.position -= Vector2(10, 20)
		var TimeTween = get_tree().create_tween()
		TimeTween.tween_property(NewMinusTime, "position:y", NewMinusTime.position.y - 15, 1)
		await get_tree().create_timer(3).timeout
		NewMinusTime.queue_free()

func _clock():
	if Counting:
		MyTime -= 1

func _time_up():
	var RemHead = _rem_head()
	for i in Heads.get_children():
		if !i.name == "RemHead":
			i.queue_free()
	Counting = false
	await get_tree().create_timer(1).timeout
	var BGTween = get_tree().create_tween()
	BGTween.tween_property(BG, "color", YellowBG, .1)
	await get_tree().create_timer(1).timeout
	Heads.get_node("RemHead")._game_over()
	var BGTween2 = get_tree().create_tween()
	BGTween2.tween_property(BG, "color", BlackBG, 1)
	await get_tree().create_timer(1).timeout
	#var BGMTween = get_tree().create_tween()
	#BGMTween.tween_property(BGM, "volume_db", -80, 3)
	GOText2.text = "You scored " + str(Round) + ", retry?"
	var GOTween = get_tree().create_tween()
	GOTween.tween_property(GameOver, "modulate:a", 1, 1)
	GameOver.z_index = 999
	await GOTween.finished
	Retryable = true

func _retry():
	if Retryable:
		get_tree().reload_current_scene()

func _time_add():
	var NewTime = MyTime + 5
	while MyTime < NewTime:
		MyTime += 1
		await get_tree().create_timer(.1).timeout

func _rem_head():
	var RemHead = _spawn_head(Char, Heads.get_node("TrueHead").position, ["Rem"])
	for i in RemHead.get_node("Sprite").get_children():
		i.queue_free()
	RemHead.name = "RemHead"
	RemHead.get_node("Sprite").offset = Heads.get_node("TrueHead/Sprite").offset
	return RemHead

func _go_size():
	GOText1.size.x = get_viewport_rect().size.x
	GOText1.size.y = GOText1.get_meta("OGSize").y * (GOText1.size.x / GOText1.get_meta("OGSize").x)
	GOText1.add_theme_font_size_override("font_size", 35 * (GOText1.size.x / GOText1.get_meta("OGSize").x))
	GOText2.size.x = get_viewport_rect().size.x
	GOText2.size.y = GOText2.get_meta("OGSize").y * (GOText2.size.x / GOText2.get_meta("OGSize").x)
	GOText2.add_theme_font_size_override("font_size", 19 * (GOText2.size.x / GOText2.get_meta("OGSize").x))
	RetryBut.scale = Vector2(GOText1.size.x / GOText1.get_meta("OGSize").x, GOText1.size.x / GOText1.get_meta("OGSize").x)
	var RetrySize = RetryBut.size * RetryBut.scale
	GOText2.position = Vector2(0, ((get_viewport_rect().size.y / 2) - (GOText2.size.y / 2)))
	GOText1.position = Vector2(0, ((get_viewport_rect().size.y / 2) - (GOText1.size.y / 2)) - GOText2.size.y)
	RetryBut.position = Vector2((get_viewport_rect().size.x / 2) - (RetrySize.x / 2), (get_viewport_rect().size.y / 2) - (RetrySize.y / 2) + GOText2.size.y)


func _process(delta):
	LeftWanted.scale = Vector2(1 / LeftCircle.scale.x, 1 / LeftCircle.scale.y)
	RightWanted.scale = Vector2(1 / RightCircle.scale.x, 1 / RightCircle.scale.y)
	TimeLabel.text = str(MyTime)
	RoundLabel.text = str(Round)
	BG.size = get_viewport_rect().size
	var SizeDif = Vector2(get_viewport_rect().size.x / LeftWanted.texture.region.size.x, get_viewport_rect().size.y / LeftWanted.texture.region.size.y)
	$AnimScreen.scale = SizeDif
	TimeLabel.position = Vector2(0, get_viewport_rect().size.y - TimeLabel.size.y)
	RoundLabel.position = Vector2(get_viewport_rect().size.x - RoundLabel.size.x, get_viewport_rect().size.y - RoundLabel.size.y)
	MaxGrid = [get_viewport_rect().size.x / RegSize.x, get_viewport_rect().size.y / RegSize.y]
	if MyTime <= 0 and !GOd:
		GOd = true
		_time_up()
	
	_go_size()
	
	if Input.is_action_just_pressed("Debug") and OS.is_debug_build():
		_head_pressed(Heads.get_node("TrueHead"))
