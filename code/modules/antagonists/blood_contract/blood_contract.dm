
/datum/antagonist/blood_contract
	name = "Blood Contract Target"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	soft_antag = FALSE // BLUEMOON ADDITION

/datum/antagonist/blood_contract/on_gain()
	. = ..()
	give_objective()
	start_the_hunt()

/datum/antagonist/blood_contract/proc/give_objective()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive

/datum/antagonist/blood_contract/greet()
	. = ..()
	to_chat(owner, "<span class='userdanger'>You've been marked for death! Don't let the demons get you! KILL THEM ALL!</span>")

/datum/antagonist/blood_contract/proc/start_the_hunt()
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	H.add_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY)
	var/obj/effect/mine/pickup/bloodbath/B = new(H)
	INVOKE_ASYNC(B, /obj/effect/mine/pickup/bloodbath/.proc/mineEffect, H) //could use moving out from the mine

	for(var/mob/living/carbon/human/P in GLOB.player_list)
		if(P == H || HAS_TRAIT(P, TRAIT_NO_MIDROUND_ANTAG))
			continue
		to_chat(P, "<span class='userdanger'>You have an overwhelming desire to kill [H]. [H.ru_who(TRUE)] been marked red! Whoever [H.ru_who()] [H.p_were()], friend or foe, go kill [H.ru_na()]!</span>")
		P.put_in_hands(new /obj/item/kitchen/knife/butcher(P), TRUE)
