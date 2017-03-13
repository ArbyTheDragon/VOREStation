/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20

	mob_bump_flag = SIMPLE_ANIMAL
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL

	//Settings for played mobs
	var/show_stat_health = 1		// Does the percentage health show in the stat panel for the mob
	var/ai_inactive = 0 			// Set to 1 to turn off most AI actions

	//Mob icon settings
	var/icon_living = ""			// The iconstate if we're alive, required
	var/icon_dead = ""				// The iconstate if we're dead, required
	var/icon_gib = null				// The iconstate for being gibbed, optional
	var/icon_rest = null			// The iconstate for resting, optional

	//Mob talking settings
	universal_speak = 0				// Can all mobs in the entire universe understand this one?
	var/speak_chance = 0			// Probability that I talk (this is 'X in 200' chance since even 1/100 is pretty noisy)
	var/reacts = 0					// Reacts to some things being said
	var/list/speak = list()			// Things I might say if I talk
	var/list/emote_hear = list()	// Hearable emotes I might perform
	var/list/emote_see = list()		// Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	var/list/say_understood = list()// List of things to say when accepting an order
	var/list/say_cannot = list()	// List of things to say when they cannot comply
	var/list/reactions = list() 	// List of "string" = "reaction" and things they hear will be searched for string.

	//Mob movement settings
	var/wander = 1					// Does the mob wander around when idle?
	var/turns_per_move = 1			// How many life() cycles to wait between each move?
	var/stop_automated_movement = 0 // Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/stop_when_pulled = 1 		// When set to 1 this stops the animal from moving when someone is pulling it.
	var/obstacles = list()			// Things this mob refuses to move through
	var/speed = 0					// Higher speed is slower, negative speed is faster.
	var/obj/item/weapon/card/id/myid// An ID card if they have one to give them access to stuff.

	//Mob interaction
	var/response_help   = "tries to help"	// If clicked on help intent
	var/response_disarm = "tries to disarm" // If clicked on disarm intent
	var/response_harm   = "tries to hurt"	// If clicked on harm intent
	var/harm_intent_damage = 3		// How much an unarmed harm click does to this mob.
	var/meat_amount = 0				// How much meat to drop from this mob when butchered
	var/obj/meat_type				// The meat object to drop
	var/obj/list/loot_types			// The list of lootable objects to drop, with "/path = prob%" structure
	var/recruitable = 0				// Mob can be bossed around
	var/recruit_cmd_str = "Hey,"	// The thing you prefix commands with when bossing them around

	//Mob environment settings
	var/minbodytemp = 250			// Minimum "okay" temperature in kelvin
	var/maxbodytemp = 350			// Maximum of above
	var/heat_damage_per_tick = 3	// Amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2	// Same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	var/fire_alert = 0

	var/min_oxy = 5					// Oxygen in moles, minimum, 0 is 'no minimum
	var/max_oxy = 0					// Oxygen in moles, maximum, 0 is 'no maximum'
	var/min_tox = 0					// Phoron min
	var/max_tox = 1					// Phoron max
	var/min_co2 = 0					// CO2 min
	var/max_co2 = 5					// CO2 max
	var/min_n2 = 0					// N2 min
	var/max_n2 = 0					// N2 max
	var/unsuitable_atoms_damage = 2	// This damage is taken when atmos doesn't fit all the requirements above

	//Mob attack settings
	var/melee_damage_lower = 0		// Lower bound of randomized melee damage
	var/melee_damage_upper = 0		// Upper bound of randomized melee damage
	var/attacktext = "attacked"		// "You are [attacktext] by the mob!"
	var/attack_sound = null			// Sound to play when I attack
	var/friendly = "nuzzles"		// What mobs do to people when they aren't really hostile
	var/environment_smash = 0		// How much environment damage do I do when I hit stuff?

	//Hostility settings
	var/hostile = 0					// Do I even attack?
	var/attack_same = 0				// Do I attack members of my own faction?
	var/supernatural = 0			// If the mob is supernatural (used in null-rod stuff for banishing?)

	//Attack ranged settings
	var/ranged = 0					// Do I attack at range?
	var/shoot_range = 7				// How far away do I start shooting from?
	var/rapid = 0					// Three-round-burst fire mode
	var/projectiletype				// The projectiles I shoot
	var/projectilesound				// The sound I make when I do it
	var/casingtype					// What to make the hugely laggy casings pile out of

	//Attack movement settings
	var/move_to_delay = 4			// Delay for the automated movement (deciseconds)
	var/destroy_surroundings = 0	// Should I smash things to get to my target?
	var/break_stuff_probability = 0	// Chances of me breaking stuff (each life() tick) to get to my target

	//Damage resistances
	var/resistance = 0				// Damage reduction for all types
	var/list/resistances = list(
								HALLOSS = 0,
								BRUTE = 1,
								BURN = 1,
								TOX = 1,
								OXY = 0,
								CLONE = 0
								)

	//Counters and other non-user-settable variables
	var/stance = STANCE_IDLE		// Used to determine behavior
	var/turns_since_move = 0 		// A counter for how many life() cycles since move
	var/shuttletarget = null		// Shuttle's here, time to get to it
	var/enroute = 0					// If the shuttle is en-route
	var/purge = 0					// A counter used for null-rod stuff
	var/mob/living/target_mob		// Who I'm trying to attack
	var/mob/living/list/friends = list() // People who are immune to my wrath, for now
	var/turf/walk_list = list()		// List of turfs to walk through to get somewhere

/mob/living/simple_animal/New()
	..()
	verbs -= /mob/verb/observe

/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.screen = list()
		src.client.screen += src.client.void
		ai_inactive = 1
	..()

/mob/living/simple_animal/Logout()
	if(src && !src.client)
		spawn(15 SECONDS) //15 seconds to get back into the mob before it goes wild
			ai_inactive = initial(ai_inactive) //So if they never have an AI, they stay that way.
	..()

/mob/living/simple_animal/updatehealth()
	//Alive, becoming dead
	if((stat < DEAD) && (health <= 0))
		death()

	//Dead, becoming alive
	else if((stat >= DEAD) && (health > 0))
		dead_mob_list -= src
		living_mob_list += src
		stat = CONSCIOUS
		density = 1

	//Overhealth
	else if(health > maxHealth)
		health = maxHealth

/mob/living/simple_animal/update_icon()
	..()
	//Awake and normal
	if((stat == CONSCIOUS) && !resting)
		icon_state = icon_living

	//Resting or KO'd
	else if(((stat == UNCONSCIOUS) || resting) && icon_rest)
		icon_state = icon_rest

	//Dead
	else if(stat >= DEAD)
		icon_state = icon_dead

	//Backup
	else
		icon_state = initial(icon_state)

/mob/living/simple_animal/Life()
	..()

	//Health
	update_health()
	if(stat >= DEAD)
		return

	handle_stunned()
	handle_weakened()
	handle_paralysed()
	handle_supernatural()
	update_icon()

	//Movement
	if(!ai_inactive && !stop_automated_movement && wander && !anchored) //Allowed to move?
		if(isturf(src.loc) && !resting && !buckled && canmove) //Physically capable of moving?
			turns_since_move++ //Increment turns since move (turns are life() cycles)
			if(turns_since_move >= turns_per_move)
				if(!(stop_when_pulled && pulledby)) //Some animals don't move when pulled
					var/moving_to = 0 // otherwise it always picks 4, fuck if I know.   Did I mention fuck BYOND
					moving_to = pick(cardinal)
					dir = moving_to			//How about we turn them the direction they are moving, yay.
					Move(get_step(src,moving_to))
					turns_since_move = 0

	//Speaking
	if(!ai_inactive && speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				if((emote_hear && emote_hear.len) || (emote_see && emote_see.len))
					var/length = speak.len
					if(emote_hear && emote_hear.len)
						length += emote_hear.len
					if(emote_see && emote_see.len)
						length += emote_see.len
					var/randomValue = rand(1,length)
					if(randomValue <= speak.len)
						say(pick(speak))
					else
						randomValue -= speak.len
						if(emote_see && randomValue <= emote_see.len)
							visible_emote("[pick(emote_see)].")
						else
							audible_emote("[pick(emote_hear)].")
				else
					say(pick(speak))
			else
				if(!(emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					visible_emote("[pick(emote_see)].")
				if((emote_hear && emote_hear.len) && !(emote_see && emote_see.len))
					audible_emote("[pick(emote_hear)].")
				if((emote_hear && emote_hear.len) && (emote_see && emote_see.len))
					var/length = emote_hear.len + emote_see.len
					var/pick = rand(1,length)
					if(pick <= emote_see.len)
						visible_emote("[pick(emote_see)].")
					else
						audible_emote("[pick(emote_hear)].")


	//Atmos
	var/atmos_suitable = 1

	var/atom/A = src.loc

	if(istype(A,/turf))
		var/turf/T = A

		var/datum/gas_mixture/Environment = T.return_air()

		if(Environment)

			if( abs(Environment.temperature - bodytemperature) > 40 )
				bodytemperature += ((Environment.temperature - bodytemperature) / 5)

			if(min_oxy)
				if(Environment.gas["oxygen"] < min_oxy)
					atmos_suitable = 0
			if(max_oxy)
				if(Environment.gas["oxygen"] > max_oxy)
					atmos_suitable = 0
			if(min_tox)
				if(Environment.gas["phoron"] < min_tox)
					atmos_suitable = 0
			if(max_tox)
				if(Environment.gas["phoron"] > max_tox)
					atmos_suitable = 0
			if(min_n2)
				if(Environment.gas["nitrogen"] < min_n2)
					atmos_suitable = 0
			if(max_n2)
				if(Environment.gas["nitrogen"] > max_n2)
					atmos_suitable = 0
			if(min_co2)
				if(Environment.gas["carbon_dioxide"] < min_co2)
					atmos_suitable = 0
			if(max_co2)
				if(Environment.gas["carbon_dioxide"] > max_co2)
					atmos_suitable = 0

	//Atmos effect
	if(bodytemperature < minbodytemp)
		fire_alert = 2
		adjustBruteLoss(cold_damage_per_tick)
	else if(bodytemperature > maxbodytemp)
		fire_alert = 1
		adjustBruteLoss(heat_damage_per_tick)
	else
		fire_alert = 0

	if(!atmos_suitable)
		adjustBruteLoss(unsuitable_atoms_damage)

	//Hostility
	if(!stat && !ai_inactive && hostile)
		switch(stance)
			if(STANCE_IDLE)
				target_mob = FindTarget()

			if(STANCE_ATTACK)
				if(destroy_surroundings)
					DestroySurroundings()
				MoveToTarget()

			if(STANCE_ATTACKING)
				if(destroy_surroundings)
					DestroySurroundings()
				AttackTarget()

	return 1

/mob/living/simple_animal/proc/handle_supernatural()
	if(purge)
		purge -= 1

/mob/living/simple_animal/gib()
	..(icon_gib,1)

/mob/living/simple_animal/emote(var/act, var/type, var/desc)
	if(act)
		..(act, type, desc)

/mob/living/simple_animal/proc/visible_emote(var/act_desc)
	custom_emote(1, act_desc)

/mob/living/simple_animal/proc/audible_emote(var/act_desc)
	custom_emote(2, act_desc)

/mob/living/simple_animal/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return

	if(Proj.taser_effect)
		stun_effect_act(0, Proj.agony)

	if(Proj.nodamage)
		return

	adjustBruteLoss(Proj.damage)
	return 0

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M as mob)
	..()

	switch(M.a_intent)

		if(I_HELP)
			if (health > 0)
				M.visible_message("\blue [M] [response_help] \the [src]")

		if(I_DISARM)
			M.visible_message("\blue [M] [response_disarm] \the [src]")
			M.do_attack_animation(src)
			//TODO: Push the mob away or something

		if(I_GRAB)
			if (M == src)
				return
			if (!(status_flags & CANPUSH))
				return

			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)

			M.put_in_active_hand(G)

			G.synch()
			G.affecting = src
			LAssailant = M

			M.visible_message("\red [M] has grabbed [src] passively!")
			M.do_attack_animation(src)

		if(I_HURT)
			if(M.loc == src) //VOREStation Add (prevents attacking from inside mobs)
				return
			adjustBruteLoss(harm_intent_damage)
			M.visible_message("\red [M] [response_harm] \the [src]")
			M.do_attack_animation(src)

	return

/mob/living/simple_animal/attackby(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/stack/medical))
		if(stat != DEAD)
			var/obj/item/stack/medical/MED = O
			if(health < maxHealth)
				if(MED.amount >= 1)
					adjustBruteLoss(-MED.heal_brute)
					MED.amount -= 1
					if(MED.amount <= 0)
						qdel(MED)
					for(var/mob/M in viewers(src, null))
						if ((M.client && !( M.blinded )))
							M.show_message("<span class='notice'>[user] applies the [MED] on [src].</span>")
		else
			user << "<span class='notice'>\The [src] is dead, medical items won't bring \him back to life.</span>"
	if(meat_type && (stat == DEAD))	//if the animal has a meat, and if it is dead.
		if(istype(O, /obj/item/weapon/material/knife) || istype(O, /obj/item/weapon/material/knife/butch))
			harvest(user)
	else
		if(!O.force)
			visible_message("<span class='notice'>[user] gently taps [src] with \the [O].</span>")
		else
			O.attack(src, user, user.zone_sel.selecting)

/mob/living/simple_animal/hit_with_weapon(obj/item/O, mob/living/user, var/effective_force, var/hit_zone)
	if (user.loc == src) //VOREStation Edit (prevents hitting animals from inside with weapons)
		return 1
	visible_message("<span class='danger'>\The [src] has been attacked with \the [O] by [user].</span>")

	if(O.force <= resistance)
		user << "<span class='danger'>This weapon is ineffective, it does no damage.</span>"
		return 2

	var/damage = O.force
	if (O.damtype == HALLOSS)
		damage = 0
	if(supernatural && istype(O,/obj/item/weapon/nullrod))
		damage *= 2
		purge = 3
	adjustBruteLoss(damage)

	return 0

/mob/living/simple_animal/movement_delay()
	var/tally = 0 //Incase I need to add stuff other than "speed" later

	tally = speed
	if(purge)//Purged creatures will move more slowly. The more time before their purge stops, the slower they'll move.
		if(tally <= 0)
			tally = 1
		tally *= purge

	return tally+config.animal_delay

/mob/living/simple_animal/Stat()
	..()

	if(statpanel("Status") && show_stat_health)
		stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/death(gibbed, deathmessage = "dies!")
	density = 0
	return ..(gibbed,deathmessage)

/mob/living/simple_animal/ex_act(severity)
	if(!blinded)
		flash_eyes()
	switch (severity)
		if (1.0)
			adjustBruteLoss(500)
			gib()
			return

		if (2.0)
			adjustBruteLoss(60)


		if(3.0)
			adjustBruteLoss(30)

/mob/living/simple_animal/adjustBruteLoss(damage)
	health = Clamp(health - damage, 0, maxHealth)

/mob/living/simple_animal/adjustFireLoss(damage)
	health = Clamp(health - damage, 0, maxHealth)

/mob/living/simple_animal/proc/SA_attackable(target_mob)
	if (isliving(target_mob))
		var/mob/living/L = target_mob
		if(!L.stat && L.health >= 0)
			return (0)
	if (istype(target_mob,/obj/mecha))
		var/obj/mecha/M = target_mob
		if (M.occupant)
			return (0)
	return 1

/mob/living/simple_animal/say(var/message)
	var/verb = "says"
	if(speak_emote.len)
		verb = pick(speak_emote)

	message = sanitize(message)

	..(message, null, verb)

/mob/living/simple_animal/get_speech_ending(verb, var/ending)
	return verb

/mob/living/simple_animal/put_in_hands(var/obj/item/W) // No hands.
	W.loc = get_turf(src)
	return 1

// Harvest an animal's delicious byproducts
/mob/living/simple_animal/proc/harvest(var/mob/user)
	var/actual_meat_amount = max(1,(meat_amount/2))
	if(meat_type && actual_meat_amount>0 && (stat == DEAD))
		for(var/i=0;i<actual_meat_amount;i++)
			var/obj/item/meat = new meat_type(get_turf(src))
			meat.name = "[src.name] [meat.name]"
		if(issmall(src))
			user.visible_message("<span class='danger'>[user] chops up \the [src]!</span>")
			new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
			qdel(src)
		else
			user.visible_message("<span class='danger'>[user] butchers \the [src] messily!</span>")
			gib()

/mob/living/simple_animal/handle_fire()
	return

/mob/living/simple_animal/update_fire()
	return
/mob/living/simple_animal/IgniteMob()
	return
/mob/living/simple_animal/ExtinguishMob()
	return

	//Hostile procs moved down
/mob/living/simple_animal/proc/FindTarget()

	var/atom/T = null
	stop_automated_movement = 0
	for(var/atom/A in ListTargets(10))

		if(A == src)
			continue

		var/atom/F = Found(A)
		if(F)
			T = F
			break

		if(isliving(A))
			var/mob/living/L = A
			if(L.faction == src.faction && !attack_same)
				continue
			else if(L in friends)
				continue
			else
				if(!L.stat)
					stance = STANCE_ATTACK
					T = L
					break

		else if(istype(A, /obj/mecha)) // Our line of sight stuff was already done in ListTargets().
			var/obj/mecha/M = A
			if(M.occupant && ((M.occupant.faction != src.faction) || attack_same))
				stance = STANCE_ATTACK
				T = M
				break
	return T


/mob/living/simple_animal/proc/Found(var/atom/A)
	return

//Move to a target (or near if we're ranged)
/mob/living/simple_animal/proc/MoveToTarget()
	stop_automated_movement = 1
	if(!target_mob || SA_attackable(target_mob))
		stance = STANCE_IDLE
		GiveUpMoving()
	if(target_mob in ListTargets(10))
		//Within pew-pew range
		if(ranged && (get_dist(src, target_mob) <= shoot_range))
			OpenFire(target_mob)

		//Within melee range
		else if(get_dist(src, target_mob) <= 1)
			stance = STANCE_ATTACKING

		//Wanna get closer
		else
			if(!walk_list.len)
				//GetPath failed for whatever reason, just smash into things towards them
				if(!GetPath(target_mob))
					walk_to(src, target_mob, 1, move_to_delay) //We try ye-olde fashioned way.

				//GetPath gave us a usable path, route along it
				else
					//How close do we want to get, anyway?
					var/get_to = ranged ? shoot_range-1 : 1 //The -1 just behaves better so if they step back they aren't instantly out of range
					while(get_dist(src, target_mob) > get_to)
						MoveOnce()
						sleep(move_to_delay)

walk_to(src, target_mob, 1, move_to_delay)

//A* now, try to a path to a target
/mob/living/simple_animal/proc/GetPath(var/atom/target)
	walk_list.Cut()
	walk_list = AStar(get_turf(loc), target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 250, id = myid, exclude = obstacles)

	return walk_list.len

//Take one step along a path
/mob/living/simple_animal/proc/MoveOnce()
	if(!walk_list.len)
		GiveUpMoving()

	Step_to(src, src.walk_list[1])
	walk_list -= src.walk_list[1]

//Giving up on moving
/mob/living/simple_animal/proc/GiveUpMoving()
	stop_automated_movement = 0
	walk_list.Cut()

//Return home, all-in-one proc (though does target scan and drop out if they see one)
/mob/living/simple_animal/proc/GoHome()
	stop_automated_movement = 0
	GetPath home
	MoveOnce home until home

//Get into attack mode on a target
/mob/living/simple_animal/proc/AttackTarget()
	stop_automated_movement = 1
	if(!target_mob || SA_attackable(target_mob))
		LoseTarget()
		return 0
	if(!(target_mob in ListTargets(10)))
		LostTarget()
		return 0
	if(get_dist(src, target_mob) <= 1)	//Attacking
		AttackingTarget()
		return 1

//Attack the target in melee
/mob/living/simple_animal/proc/AttackingTarget()
	if(!Adjacent(target_mob))
		return
	if(isliving(target_mob))
		var/mob/living/L = target_mob
		L.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext)
		return L
	if(istype(target_mob,/obj/mecha))
		var/obj/mecha/M = target_mob
		M.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext)
		return M

//We lost sight of the target
/mob/living/simple_animal/proc/LoseTarget()
	stance = STANCE_IDLE
	target_mob = null
	walk(src, 0)

//What to do when we lose the target
/mob/living/simple_animal/proc/LostTarget()
	stance = STANCE_IDLE
	walk(src, 0)

//Find me some targets
/mob/living/simple_animal/proc/ListTargets(var/dist = 7)
	var/list/L = hearers(src, dist)

	for (var/obj/mecha/M in mechas_list)
		if (M.z == src.z && get_dist(src, M) <= dist)
			L += M

	return L

//The actual top-level ranged attack proc
/mob/living/simple_animal/proc/OpenFire(target_mob)
	var/target = target_mob
	visible_message("\red <b>[src]</b> fires at [target]!", 1)

	var/tturf = get_turf(target)
	if(rapid)
		spawn(1)
			Shoot(tturf, src.loc, src)
			if(casingtype)
				new casingtype(get_turf(src))
		spawn(4)
			Shoot(tturf, src.loc, src)
			if(casingtype)
				new casingtype(get_turf(src))
		spawn(6)
			Shoot(tturf, src.loc, src)
			if(casingtype)
				new casingtype(get_turf(src))
	else
		Shoot(tturf, src.loc, src)
		if(casingtype)
			new casingtype

	stance = STANCE_IDLE
	target_mob = null
	return

//Shoot a bullet at someone
/mob/living/simple_animal/proc/Shoot(var/target, var/start, var/user, var/bullet = 0)
	if(target == start)
		return

	var/obj/item/projectile/A = new projectiletype(user:loc)
	playsound(user, projectilesound, 100, 1)
	if(!A)	return

	if (!istype(target, /turf))
		qdel(A)
		return
	A.launch(target)
	return

//Break through windows/other things
/mob/living/simple_animal/proc/DestroySurroundings()
	if(prob(break_stuff_probability))
		for(var/dir in cardinal) // North, South, East, West
			for(var/obj/structure/window/obstacle in get_step(src, dir))
				if(obstacle.dir == reverse_dir[dir]) // So that windows get smashed in the right order
					obstacle.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext)
					return
			var/obj/structure/obstacle = locate(/obj/structure, get_step(src, dir))
			if(istype(obstacle, /obj/structure/window) || istype(obstacle, /obj/structure/closet) || istype(obstacle, /obj/structure/table) || istype(obstacle, /obj/structure/grille))
				obstacle.attack_generic(src,rand(melee_damage_lower,melee_damage_upper),attacktext)

//Check for shuttle bumrush
/mob/living/simple_animal/proc/check_horde()
	return 0
	if(emergency_shuttle.shuttle.location)
		if(!enroute && !target_mob)	//The shuttle docked, all monsters rush for the escape hallway
			if(!shuttletarget && escape_list.len) //Make sure we didn't already assign it a target, and that there are targets to pick
				shuttletarget = pick(escape_list) //Pick a shuttle target
			enroute = 1
			stop_automated_movement = 1
			spawn()
				if(!src.stat)
					horde()

		if(get_dist(src, shuttletarget) <= 2)		//The monster reached the escape hallway
			enroute = 0
			stop_automated_movement = 0

//Shuttle bumrush
/mob/living/simple_animal/proc/horde()
	var/turf/T = get_step_to(src, shuttletarget)
	for(var/atom/A in T)
		if(istype(A,/obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/D = A
			D.open(1)
		else if(istype(A,/obj/structure/simple_door))
			var/obj/structure/simple_door/D = A
			if(D.density)
				D.Open()
		else if(istype(A,/obj/structure/cult/pylon))
			A.attack_generic(src, rand(melee_damage_lower, melee_damage_upper))
		else if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille))
			A.attack_generic(src, rand(melee_damage_lower, melee_damage_upper))
	Move(T)
	FindTarget()
	if(!target_mob || enroute)
		spawn(10)
			if(!src.stat)
				horde()

//Touches a wire, etc
/mob/living/simple_animal/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/def_zone = null)
	shock_damage *= siemens_coeff
	if (shock_damage < 1)
		return 0

	adjustFireLoss(shock_damage)
	playsound(loc, "sparks", 50, 1, -1)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, loc)
	s.start()

//Shot with taser/stunvolver
/mob/living/simple_animal/stun_effect_act(var/stun_amount, var/agony_amount, var/def_zone, var/used_weapon=null)
	var/stunDam = 0
	var/agonyDam = 0

	if(stun_amount)
		stunDam += stun_amount * 0.5
		adjustFireLoss(stunDam)

	if(agony_amount)
		agonyDam += agony_amount * 0.5
		adjustFireLoss(agonyDam)

//Commands, reactions, etc
/mob/living/simple_animal/hear_say(var/message, var/verb = "says", var/datum/language/language = null, var/alt_name = "", var/italics = 0, var/mob/speaker = null, var/sound/speech_sound, var/sound_vol)
	return //Do interesting things TODO