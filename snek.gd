extends Node2D
var GameSize = Vector2i(40,20)
var PixelSize = 25
var snakeLength = 10
var snakeSegments = []
var snakePos : Vector2i
var foodPos : Vector2i =  Vector2i(7,7)
var moveDir : Vector2i = Vector2i.RIGHT
var lastMoveDir : Vector2i = Vector2i.RIGHT

var speedTimer = Timer.new()
var ScoreLabel = Label.new()
var score = 0
var HighScore = 0

# --- Scoring is: 1 point for every 10 segments after you move.
# --- food: 1xSegment Count

# --- If we're about to die, always give the player a little bit of time to respond to it, 
# --- before calling the game over
var AboutToDieCount : float = 0

func _init() -> void:
	snakePos = GameSize / 2
	add_child(speedTimer)
	add_child(ScoreLabel)
	ScoreLabel.position.x = 10
	ScoreLabel.position.y = 10
	ScoreLabel.modulate = Color.BLACK
	speedTimer.wait_time = 0.5
	speedTimer.autostart = true
	speedTimer.one_shot = false
	resetGame()

func resetGame():
	snakeSegments.clear()
	snakePos = GameSize / 2
	snakeLength = 10
	AboutToDieCount = 0
	
	if HighScore < score:
		HighScore = score
	score = 0
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

func _process(delta: float) -> void:
	ScoreLabel.text = "Score: " + str(score)
	if HighScore > 0:
		ScoreLabel.text += "\nHigh: " + str(HighScore)
	
	# --- Slightly weird looking yes, but seems to give the best feeling controls
	if moveDir.x == 0:
		if Input.is_action_just_pressed("LEFT"):
			moveDir = Vector2i.LEFT
		elif Input.is_action_just_pressed("RIGHT"):
			moveDir = Vector2i.RIGHT
	
	if moveDir.y == 0:
		if Input.is_action_just_pressed("UP"):
			moveDir = Vector2i.UP
		elif Input.is_action_just_pressed("DOWN"):
			moveDir = Vector2i.DOWN

func tick():
	#print("tick")
	var ShouldDie = false
	# --- We can't go directly backward
	var tempPos = moveDir + lastMoveDir
	var PrevSnakePos = snakePos
	
	if tempPos.x != 0 and tempPos.y != 0:
		snakePos += moveDir
		lastMoveDir = moveDir
	else:
		snakePos += lastMoveDir
	
	if snakePos.x >= GameSize.x:
		ShouldDie = true #snakePos.x = 0
	elif snakePos.x < 0:
		ShouldDie = true #snakePos.x = GameSize.x
	if snakePos.y >= GameSize.y:
		ShouldDie = true #snakePos.y = 0
	elif snakePos.y < 0:
		ShouldDie = true #snakePos.y = GameSize.y
	if snakePos in snakeSegments:
		ShouldDie = true #AboutToDieCount += 1
	
	if ShouldDie:
		AboutToDieCount += speedTimer.wait_time
	else:
		AboutToDieCount = 0
	
	if AboutToDieCount <= 0:
		snakeSegments.append(snakePos)
	elif AboutToDieCount > 0.25:
		resetGame()
	elif AboutToDieCount > 0:
		snakePos = PrevSnakePos
	
	# --- We've longer than we should be now, so remove last segment (front)
	if snakeSegments.size() > snakeLength:
		snakeSegments.pop_front()
	
	# --- Snake is on the fruit
	if snakePos == foodPos:
		score += (1 * snakeLength) * 10
		snakeLength += 1
		MakeNewFood()
	
	speedTimer.wait_time = 1.0 / snakeLength * 1.5
	if speedTimer.wait_time < 0.016: # --- Limit to 60fps
		speedTimer.wait_time = 0.016
	
	queue_redraw()

func _draw() -> void:
	for x in GameSize.x: 
		for y in GameSize.y:
			var PixelColor : Color = Color.GREEN
			var L : float = float(x+1) / float(GameSize.x)
			var U : float = float(y+1) / float(GameSize.y)
			PixelColor = PixelColor.blend(Color.GREEN_YELLOW * L)
			PixelColor = PixelColor.blend(Color.SEA_GREEN * U)
			draw_rect(Rect2i(x*PixelSize, y*PixelSize, PixelSize, PixelSize),PixelColor,true)
	
	draw_snake()
	draw_food()

func draw_snake():
	for segment in snakeSegments:
		var SnakeColor = Color.hex(0x00000099)
		draw_rect(Rect2i(segment.x*PixelSize, segment.y*PixelSize, PixelSize, PixelSize),SnakeColor,true)

func draw_food():
	draw_rect(Rect2i(foodPos.x*PixelSize, foodPos.y*PixelSize, PixelSize, PixelSize),Color.RED,true)

# --- Draw specific bitmap
func draw_bitmap():
	pass
