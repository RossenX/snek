extends Node2D
var GameSize = Vector2i(40,20)
var PixelSize = 25
var snakeLength = 3 # --- Snake's total length
var snakeSegments = []
var snakePos : Vector2i
var foodPos : Vector2i =  Vector2i(7,7)
var moveDir : Vector2i = Vector2i.RIGHT
var lastMoveDir : Vector2i = Vector2i.RIGHT
var speedTimer = Timer.new()

func _init() -> void:
	snakePos = GameSize / 2
	MakeNewFood()
	add_child(speedTimer)
	speedTimer.wait_time = 0.5
	speedTimer.autostart = true
	speedTimer.one_shot = false

func resetGame():
	snakeSegments.clear()
	snakePos = GameSize / 2
	snakeLength = 3
	MakeNewFood()

func MakeNewFood():
	foodPos = Vector2i(randi_range(1, GameSize.x - 1), randi_range(1, GameSize.y - 1))
	var FoodIsOverLapping = true
	while FoodIsOverLapping:
		foodPos = Vector2i(randi_range(1, GameSize.x - 1), randi_range(1, GameSize.y - 1))
		if foodPos in snakeSegments:
			FoodIsOverLapping = true
		else:
			FoodIsOverLapping = false

func _ready() -> void:
	get_window().size = GameSize * PixelSize
	speedTimer.timeout.connect(tick)

func tick():
	print("tick")
	# --- We can't go directly backward
	var tempPos = moveDir + lastMoveDir
	if tempPos.x != 0 and tempPos.y != 0:
		snakePos += moveDir
		lastMoveDir = moveDir
	else:
		snakePos += lastMoveDir
	
	if snakePos.x >= GameSize.x:
		snakePos.x = 0
	elif snakePos.x < 0:
		snakePos.x = GameSize.x
	
	if snakePos.y >= GameSize.y:
		snakePos.y = 0
	elif snakePos.y < 0:
		snakePos.y = GameSize.y
	if snakePos in snakeSegments:
		resetGame()
	snakeSegments.append(snakePos)
	# --- We've longer than we should be now, so remove last segment (front)
	if snakeSegments.size() > snakeLength:
		snakeSegments.pop_front()
	# --- Snake is on the fruit
	if snakePos == foodPos:
		snakeLength += 1
		MakeNewFood()
	speedTimer.wait_time = 1.0 / snakeLength
	queue_redraw()

func _draw() -> void:
	for x in GameSize.x: 
		for y in GameSize.y:
			var PixelColor : Color = Color.GRAY
			if Vector2i(x,y) in snakeSegments:
				PixelColor = Color.BLUE
			elif Vector2i(x,y) == foodPos:
				PixelColor = Color.RED
			draw_rect(Rect2i(x*PixelSize, y*PixelSize, PixelSize, PixelSize),PixelColor,true)
func _process(delta: float) -> void:
	var InputDir = Vector2(Input.get_axis("LEFT","RIGHT"),Input.get_axis("UP","DOWN"))
	# --- Just pressed take priority over just being held
	if InputDir != Vector2.ZERO && (InputDir.x == 0 || InputDir.y == 0):
		moveDir = InputDir
