/datum/antagonist/valentine
	name = "valentine"
	roundend_category = "valentines" //there's going to be a ton of them so put them in separate category
	show_in_antagpanel = FALSE
	var/datum/mind/date

/datum/antagonist/valentine/proc/forge_objectives()
	var/datum/objective/protect/protect_objective = new /datum/objective/protect
	protect_objective.owner = owner
	protect_objective.target = date
	if(!ishuman(date.current))
		protect_objective.human_check = FALSE
	protect_objective.explanation_text = "Protect [date.name], your date."
	objectives += protect_objective

/datum/antagonist/valentine/on_gain()
	forge_objectives()
	if(isliving(owner))
		var/mob/living/L = owner
		L.apply_status_effect(STATUS_EFFECT_INLOVE, date)
	. = ..()

/datum/antagonist/valentine/on_removal()
	. = ..()
	if(isliving(owner))
		var/mob/living/L = owner
		L.remove_status_effect(STATUS_EFFECT_INLOVE)


/datum/antagonist/valentine/greet()
	to_chat(owner, "<span class='warning'><B>You're on a date with [date.name]! Protect [date.ru_na()] at all costs. This takes priority over all other loyalties.</B></span>")

//Squashed up a bit
/datum/antagonist/valentine/roundend_report()
	var/objectives_complete = TRUE
	if(objectives.len)
		for(var/datum/objective/objective in objectives)
			if(objective.completable && !objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives_complete)
		return "<span class='greentext big'>[owner.name] protected [owner.ru_ego()] date</span>"
	else
		return "<span class='redtext big'>[owner.name] date failed!</span>"

//Just so it's distinct, basically.
/datum/antagonist/valentine/chem/greet()
	to_chat(owner, "<span class='warning'><B>You're in love with [date.name]! Protect [date.ru_na()] at all costs. This takes priority over all other loyalties.</B></span>")

/datum/antagonist/valentine/chem/roundend_report()
	var/objectives_complete = TRUE
	if(objectives.len)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives_complete)
		return "<span class='greentext big'>[owner.name] protected [owner.ru_ego()] love: [date.name]! <i>What a cutie!</i></span>"
	else
		return "<span class='redtext big'>[owner.name] date failed!</span>"
