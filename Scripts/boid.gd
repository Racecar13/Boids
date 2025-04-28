extends CharacterBody2D

@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	# Randomize color, position and rotation
	polygon_2d.color = Color(randf(), randf(), randf(), 1)
	position = Vector2(randf() * screen_size.x, randf() * screen_size.y)
	rotation = 2 * PI * randf()

func _physics_process(_delta: float) -> void:
	# Wrap
	position = position.posmodv(screen_size)
	
	# Parameters
	var count = 0
	var total_attract = Vector2.ZERO
	var total_align = Vector2.ZERO
	var total_avoid = Vector2.ZERO
	var noise = Vector2(randf() - 0.5, randf() - 0.5)
	area_2d.get_child(0).shape.radius = get_parent().neighbor_radius
	
	# Perform boid calculations
	for boid in area_2d.get_overlapping_bodies():
		var distance = position.distance_to(boid.position)
		if distance > 0:
			count += 1
			total_attract += boid.position
			total_align += boid.velocity.normalized() / distance
			if distance < get_parent().avoid_radius:
				total_avoid += (position - boid.position).normalized() / distance
	if count:
		total_attract = (total_attract / count - position).normalized() / get_parent().neighbor_radius
	
	# Move
	velocity += total_align * get_parent().align_strength + total_attract * get_parent().attract_strength + total_avoid * get_parent().avoid_strength + noise * get_parent().noise_strength
	if velocity.length() > get_parent().max_speed:
		velocity = velocity.normalized() * get_parent().max_speed
	move_and_slide()
	rotation = velocity.angle()
	polygon_2d.color = get_parent().color
