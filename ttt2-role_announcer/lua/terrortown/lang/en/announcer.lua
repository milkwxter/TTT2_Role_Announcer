local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[ANNOUNCER.name] = "Announcer"
L["info_popup_" .. ANNOUNCER.name] = [[You are the Announcer! As long as you live, all shop purchases will be public.]]
L["body_found_" .. ANNOUNCER.abbr] = "They were an Announcer."
L["search_role_" .. ANNOUNCER.abbr] = "This person was an Announcer!"
L["target_" .. ANNOUNCER.name] = "Announcer"
L["ttt2_desc_" .. ANNOUNCER.name] = [[The Announcer will reveal items purchased by players as long as they live.]]

-- CUSTOM ROLE LANGUAGE STRINGS
L["ttt2_announcer_reveal_purchase"] = "A player has purchased: {equipment}."
L["ttt2_announcer_reveal_purchase_team"] = "A {team} has purchased: {equipment}."
L["ttt2_announcer_reveal_purchase_desc"] = "This message was brought to you by your trusty Announcer!"

L["ttt2_label_announcer_show_purchaser_team"] = "Enable team identifier for purchase pop-up"
L["ttt2_label_announcer_purchase_time_on_screen"] = "Purchase pop-up duration in seconds"
L["ttt2_label_announcer_innocent_purchaser"] = "innocent"
L["ttt2_label_announcer_traitor_purchaser"] = "traitor"
L["ttt2_label_announcer_other_purchaser"] = "player"