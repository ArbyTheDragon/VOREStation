/mob/living/simple_animal/hostile/large/deathclaw
	name = "deathclaw"
	desc = "Big! Big! The size of three men! Claws as long as my forearm! Ripped apart! Ripped apart!"
	icon = 'icons/mob/vore64x64.dmi'
	icon_dead = "deathclaw-dead"
	icon_living = "deathclaw"
	icon_state = "deathclaw"
	attacktext = "mauled"

	maxHealth = 200
	health = 200

	old_x = -16
	old_y = 0

	pixel_x = -16
	pixel_y = 0

/mob/living/simple_animal/hostile/large/deathclaw/vore
	vore_active = 1
	vore_capacity = 2
	vore_escape_chance = 5
	vore_max_size = RESIZE_HUGE
	vore_min_size = RESIZE_SMALL
