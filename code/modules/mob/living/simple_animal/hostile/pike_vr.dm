/mob/living/simple_animal/hostile/carp/pike
	name = "space pike"
	desc = "A bigger, angrier cousin of the space carp."
	icon = 'icons/mob/spaceshark.dmi'
	icon_state = "shark"
	icon_living = "shark"
	icon_dead = "shark_dead"
	meat_amount = 10
	turns_per_move = 2
	move_to_delay = 2
	speed = 0
	mob_size = MOB_LARGE

	pixel_x = -16

	health = 150
	maxHealth = 150

	harm_intent_damage = 5
	melee_damage_lower = 20
	melee_damage_upper = 25

/mob/living/simple_animal/hostile/carp/pike/weak
	health = 75
	maxHealth = 75

/mob/living/simple_animal/hostile/carp/strong
	maxHealth = 50
	health = 50