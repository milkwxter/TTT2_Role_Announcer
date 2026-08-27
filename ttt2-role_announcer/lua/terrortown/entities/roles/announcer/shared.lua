if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_announcer.vmt")
	
	-- bum ass net messages
	util.AddNetworkString("TTT2_Announcer_EPOP")
end

CreateConVar("ttt2_announcer_show_purchaser_team", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "Should the purchase announcement include the team of the player who bought the equipment?", 0, 1)
CreateConVar("ttt2_announcer_purchase_time_on_screen", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY}, "How long should the purchase notification stay on screen in seconds?", 1, 10)

function ROLE:PreInitialize()
	self.color = Color(75, 104, 169, 255)

	self.abbr = "announcer"
	self.score.killsMultiplier = 8
	self.score.teamKillsMultiplier = -8
	self.score.bodyFoundMuliplier = 3
	self.unknownTeam = true

	self.defaultTeam = TEAM_INNOCENT
	self.defaultEquipment = SPECIAL_EQUIPMENT

	self.isPublicRole = true
	self.isPolicingRole = true

	self.conVarData = {
		pct = 0.13,
		maximum = 1,
		minPlayers = 6,
		minKarma = 600,
		credits = 2,
		creditsAwardDeadEnable = 1,
		creditsAwardKillEnable = 0,
		togglable = true,
		random = 25,
		shopFallback = SHOP_FALLBACK_DETECTIVE
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_DETECTIVE)
end

if SERVER then
	-- give loadout on respawn and rolechange
	function ROLE:GiveRoleLoadout(ply, isRoleChange)
		ply:GiveEquipmentItem("item_ttt_armor")
	end

	-- remove loadout on death and rolechange
	function ROLE:RemoveRoleLoadout(ply, isRoleChange)
		ply:RemoveEquipmentItem("item_ttt_armor")
	end

	-- announcer logic
	hook.Add("TTT2OrderedEquipment", "TTT2_AnnouncerSomeonePurchased", function(ply, equipmentName, isItem, credits, ignoreCost)
		-- dont run if role is disabled
		print("checking if role is enabled")
		PrintTable(roles.GetAvailableTeams())
		if ttt_announcer_enabled == 0 then return end
		
		-- try to find the first living announcer
		print("checking if a player has role")
		local livingAnnouncer = nil
		for _, v in pairs(roles.GetTeamMembers(TEAM_INNOCENT)) do
			if v:IsValid() and v:Alive() and v:GetSubRole() == ROLE_ANNOUNCER then
				livingAnnouncer = v
				break
			end
		end
		
		-- no announcer left alive then return early
		if livingAnnouncer == nil then return end
		print("player has role")
		
		-- try to get actual equipment
		print("checking for equipment")
		print(equipmentName)
		local ent = weapons.Get(equipmentName) or items.Get(equipmentName)
		if ent == nil then return end
		print("equipment found")
		
		-- make the announcement
		local purchaseDisplayTime = GetConVar("ttt2_announcer_purchase_time_on_screen"):GetInt()
		local textString
		local purchaserRoleLabel
		if GetConVar("ttt2_announcer_show_purchaser_team"):GetBool() then
			local plyTeam = ply:GetRealTeam()
			purchaserRoleLabel = "ttt2_label_announcer_other_purchaser"
			if plyTeam == TEAM_INNOCENT then
				purchaserRoleLabel = "ttt2_label_announcer_innocent_purchaser"
			elseif plyTeam == TEAM_TRAITOR then
				purchaserRoleLabel = "ttt2_label_announcer_traitor_purchaser"
			end
			
			textString = "ttt2_announcer_reveal_purchase_team"
		else
			textString = "ttt2_announcer_reveal_purchase"
		end
		
		net.Start("TTT2_Announcer_EPOP")
			net.WriteString(textString)
			net.WriteString((GetConVar("ttt2_announcer_show_purchaser_team"):GetBool() and purchaserRoleLabel) or "")
			net.WriteString(equipmentName)
			net.WriteColor(ANNOUNCER.color, false)
			net.WriteUInt(purchaseDisplayTime, 4)
		net.Broadcast()
	end)
end

-- bum ass epop
if CLIENT then
	net.Receive("TTT2_Announcer_EPOP", function(len, ply)
		local title = net.ReadString()
		local teamName = net.ReadString()
		teamName = LANG.TryTranslation(teamName)
		local equipment = net.ReadString()
		local color = net.ReadColor(false)
		local displayTime = net.ReadUInt(4)
		
		local storedEnt = weapons.GetStored(equipment) or items.Get(equipment)
		local equipmentName = (storedEnt and (storedEnt.PrintName or (storedEnt.EquipMenuData and storedEnt.EquipMenuData.name))) or equipment
		equipmentName = LANG.TryTranslation(equipmentName)
		
		local textString = LANG.GetParamTranslation(title, {team = teamName, equipment = equipmentName})
		
		-- local iconMat = Material("vgui/ttt/dynamic/roles/icon_announcer")
		
		EPOP:AddMessage({text = textString, color = color}, "ttt2_announcer_reveal_purchase_desc", displayTime, nil, true)
	end)
	
	function ROLE:AddToSettingsMenu(parent)
		local form = vgui.CreateTTT2Form(parent, "header_roles_additional")

		form:MakeCheckBox({
			serverConvar = "ttt2_announcer_show_purchaser_team",
			label = "ttt2_label_announcer_show_purchaser_team",
			min = 0,
			max = 1,
			decimal = 0,
		})

		form:MakeSlider({
			serverConvar = "ttt2_announcer_purchase_time_on_screen",
			label = "ttt2_label_announcer_purchase_time_on_screen",
			min = 0,
			max = 10,
			decimal = 0,
		})
	end
end
