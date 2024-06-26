/datum/keybinding/admin
	category = KEYBIND_CATEGORY_ADMIN

/datum/keybinding/admin/can_use(client/user)
	return !!user.holder

/datum/keybinding/admin/admin_say
	name = "admin_say"
	full_name = "Admin Say"
	description = "Talk with other admins."
	hotkey_keys = list("None")

/datum/keybinding/admin/admin_say/down(client/user)
	user.get_admin_say()
	return TRUE

/datum/keybinding/admin/moderator_say
	name = "moderator_say"
	full_name = "Moderator Say"
	description = "Talk with other moderators."
	hotkey_keys = list("F5")

/datum/keybinding/admin/moderator_say/down(client/user)
	user.get_mod_say()
	return TRUE

/datum/keybinding/admin/admin_ghost
	name = "admin_ghost"
	full_name = "Aghost"
	description = "Go ghost"
	hotkey_keys = list("None")

/datum/keybinding/admin/admin_ghost/down(client/user)
	user.admin_ghost()
	return TRUE

/datum/keybinding/admin/list_players
	name = "list_players"
	full_name = "Player panel"
	description = "Opens up the list players panel"
	hotkey_keys = list("F6")

/datum/keybinding/admin/list_players/down(client/user)
	user.holder.player_panel()
	return TRUE

/datum/keybinding/admin/admin_pm
	name = "admin_pm"
	full_name = "Admin PM"
	description = "Sends Admin PM message"
	hotkey_keys = list("F7")

/datum/keybinding/admin/admin_pm/down(client/user)
	user.cmd_admin_pm_panel()
	return TRUE

/datum/keybinding/admin/invisimin
	name = "invisimin"
	full_name = "Admin Invisibility"
	description = "Toggles ghost-like invisibility (Don't abuse this)"
	hotkey_keys = list("F8")

/datum/keybinding/admin/invisimin/down(client/user)
	user.invisimin()
	return TRUE

/datum/keybinding/admin/dead_say
	name = "dead_say"
	full_name = "Dead Say"
	description = "Allows you to send a message to dead chat"
	hotkey_keys = list("F10")

/datum/keybinding/admin/dead_say/down(client/user)
	user.get_dead_say()
	return TRUE

/datum/keybinding/admin/deadmin
	name = "deadmin"
	full_name = "De-Admin"
	description = "Shed your admin powers"
	hotkey_keys = list("None")

/datum/keybinding/admin/deadmin/down(client/user)
	user.deadmin_self()
	return TRUE

/datum/keybinding/admin/readmin
	name = "readmin"
	full_name = "Re-Admin"
	description = "Regain your admin powers"
	hotkey_keys = list("None")

/datum/keybinding/admin/readmin/down(client/user)
	user.readmin_self()
	return TRUE

/client/proc/get_admin_say()
	var/msg = input(src, null, "asay \"text\"") as text|null
	cmd_admin_say(msg)

/client/proc/get_mod_say()
	var/msg = input(src, null, "msay \"text\"") as text|null
	cmd_mod_say(msg)

/client/proc/get_dead_say()
	var/msg = input(src, null, "dsay \"text\"") as text
	dsay(msg)
