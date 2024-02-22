extends Node

@export var snake_scene : PackedScene
var cell_size : int = 50

var screen_width : int = 20
var screen_height : int = 20
var score : int = 5

var berry_pos : Vector2
var regen_berry : bool = true

var old_data : Array
var snake_data : Array
var snake : Array

var start_pos = Vector2(9, 9)
var up = Vector2(0, -1)
var down = Vector2(0, 1)
var left = Vector2(-1, 0)
var right = Vector2(1, 0)
var move_direction : Vector2 = right
var can_move : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	can_move = true
	generate_snake()
	move_berry()
	$Timer.start()

func generate_snake():
	old_data.clear()
	snake_data.clear()
	snake.clear()
	
	for i in range(3):
		add_segment(start_pos + Vector2(0, i))

func add_segment(pos):
	snake_data.append(pos)
	var SnakeSegment = snake_scene.instantiate()
	SnakeSegment.position = (pos * cell_size) + Vector2(0, cell_size)
	add_child(SnakeSegment)
	snake.append(SnakeSegment)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_snake()
	
func move_snake():
	if can_move:
		if Input.is_action_just_pressed("move_down") and move_direction != up:
			move_direction = down
			can_move = false
		if Input.is_action_just_pressed("move_up") and move_direction != down:
			move_direction = up
			can_move = false
		if Input.is_action_just_pressed("move_left") and move_direction != right:
			move_direction = left
			can_move = false
		if Input.is_action_just_pressed("move_right") and move_direction != left:
			move_direction = right
			can_move = false

func _on_timer_timeout():
	can_move = true
	old_data = [] + snake_data
	snake_data[0] += move_direction
	for i in range(len(snake_data)):
		if i > 0:
			snake_data[i] = old_data[i - 1]
		snake[i].position = (snake_data[i] * cell_size) + Vector2(0, cell_size)
	check_out_of_bounds()
	check_self_eaten()
	check_berry_eaten()
	
func check_out_of_bounds():
	if snake_data[0].x < 0 or snake_data[0].x > screen_width - 1 or snake_data[0].y < 0 or snake_data[0].y > screen_height - 1:
		end_game()
		
func check_self_eaten():
	for i in range(len(snake_data)):
		if i == 0:
			continue
		if snake_data[0] == snake_data[i]:
			end_game()
			
func check_berry_eaten():
	if berry_pos == snake_data[0]:
		score += 1
		add_segment(old_data[-1])
		move_berry()

func move_berry():
	while regen_berry:
		regen_berry = false
		berry_pos = Vector2(randi_range(0, screen_width - 1), randi_range(0, screen_height - 1))
		for i in snake_data:
			if berry_pos == i:
				regen_berry = true
	$Berry.position = (berry_pos * cell_size) + Vector2(0, cell_size)
	regen_berry = true

func end_game():
	$GameOver.visible = true
	$GameOver.text = "Game over, Score: " + str(score)
	$Timer.stop()
