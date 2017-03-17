/mob/living/simple_animal/catgirl
	name = "catgirl"
	desc = "Her hobbies are catnaps, knocking things over, and headpats."
	icon = 'icons/mob/vore.dmi'
	icon_dead = "catgirl-dead"
	icon_living = "catgirl"
	icon_state = "catgirl"

	speed = 5

	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 10


	speak_chance = 2
	speak = list("Meow!","Esp!","Purr!","HSSSSS","Mew?","Nya~")
	speak_emote = list("purrs","meows")
	emote_hear = list("meows","mews")
	emote_see = list("shakes her head","shivers")
	attacktext = "swatted"

	var/random_skin = 1
	var/list/skins = list(
	"catgirlnude",
	"catgirlbikini",
	"catgirlrednude",
	"catgirlredbikini",
	"catgirlblacknude",
	"catgirlblackbikini",
	"catgirlbrownnude",
	"catgirlbrownbikini",
	"catgirlred",
	"catgirlblack",
	"catgirlbrown"
	)

/mob/living/simple_animal/catgirl/New()
	..()
	if(random_skin)
		icon_living = pick(skins)
		icon_dead = "[icon_living]-dead"
		update_icon()

/mob/living/simple_animal/catgirl/vore
	vore_active = 1
	vore_pounce_chance = 100
	vore_ignores_prefs = 0 // Catgirls just want to eat yoouuu
	vore_default_mode = DM_HOLD // Chance that catgirls just wanna bellycuddle yoouuuu!
	vore_digest_chance = 25 // But squirming might make them gurgle...

/mob/living/simple_animal/catgirl/vore/retaliate
	retaliate = 1
