/datum/gear/suit/lab_xyn_machine
	allowed_branches = CIVILIAN_BRANCHES

/datum/gear/gloves/duty/modified
	display_name = "modified gloves, duty"
	path = /obj/item/clothing/gloves/thick/duty/modified
	whitelisted = list(
		SPECIES_UNATHI
	)
	flags = GEAR_HAS_NO_CUSTOMIZATION

/datum/gear/suit/unathi/savage_hunter
	allowed_branches = CIVILIAN_BRANCHES

/datum/gear/head/skrell_helmet
	allowed_roles = ARMORED_ROLES

/datum/gear/uniform/harness
	allowed_branches = null

/datum/gear/shoes/clogs_toeless
	allowed_branches = CIVILIAN_BRANCHES

/datum/gear/shoes/flipflobsters_toeless
	allowed_branches = CIVILIAN_BRANCHES

// Patches
/datum/gear/accessory/cultex_patch
	display_name = "Cultural Exchange patch"
	path = /obj/item/clothing/accessory/solgov/cultex_patch
	description = "A shoulder patch representing the Expeditionary Corps."
	allowed_branches = list(/datum/mil_branch/expeditionary_corps)
	whitelisted = list(
		SPECIES_SKRELL,
		SPECIES_UNATHI,
		SPECIES_YEOSA,
		SPECIES_IPC
	)
	flags = GEAR_HAS_NO_CUSTOMIZATION
