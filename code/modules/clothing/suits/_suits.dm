/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	block_priority = BLOCK_PRIORITY_WEAR_SUIT
	var/fire_resist = T0C+100
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0,ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0)
	drop_sound = 'sound/items/handling/cloth_drop.ogg'
	pickup_sound = 'sound/items/handling/cloth_pickup.ogg'
	slot_flags = ITEM_SLOT_OCLOTHING
	body_parts_covered = CHEST
	var/blood_overlay_type = "suit"
	var/togglename = null
	var/suittoggled = FALSE
	limb_integrity = 0 // disabled for most exo-suits
	mutantrace_variation = STYLE_DIGITIGRADE

/obj/item/clothing/suit/worn_overlays(isinhands = FALSE, icon_file, used_state, style_flags = NONE)
	. = ..()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damaged[blood_overlay_type]")
		if(blood_DNA)
			var/file2use = (style_flags & STYLE_ALL_TAURIC) ? 'modular_citadel/icons/mob/64x32_effects.dmi' : 'icons/effects/blood.dmi'
			. += mutable_appearance(file2use, "[blood_overlay_type]blood", color = blood_DNA_to_color(), blend_mode = blood_DNA_to_blend())
		var/mob/living/carbon/human/M = loc
		if(!ishuman(loc))
			return
		if(istype(M) || M.dna || M.dna.species || M.dna.species.can_wag_tail(M) || !isvox(M))
			if(M.dna.features["tail_primary"] && M.dna.features["tail_secondary"])
				var/tail_under_suit = tail_suit_worn_overlay || 'modular_bluemoon/SmiLeY/icons/mob/clothing/tails_digi.dmi'
				. += mutable_appearance(tail_under_suit, tail_state)
		var/obj/item/clothing/under/U = M.w_uniform
			//SANDSTORM EDIT
		if(ishuman(M) && M.w_uniform)
			if(istype(U) && length(U.attached_accessories))
				for(var/obj/item/clothing/accessory/attached in U.attached_accessories)
					if(attached.above_suit)
						. += U.accessory_overlays
			//SANDSTORM EDIT END

/obj/item/clothing/suit/update_clothes_damaged_state()
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_suit()
