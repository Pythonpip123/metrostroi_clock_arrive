TOOL.Category		= "Metro"
TOOL.Name			= "Clock Arrive Tool"
TOOL.Command		= nil
TOOL.ConfigName		= ""

if CLIENT then
    language.Add("Tool.clock_arrive_tool.name", "Clock Arrive Tool")
    language.Add("Tool.clock_arrive_tool.desc", "Adds arrival clocks")
    language.Add("Tool.clock_arrive_tool.0", "Primary: Spawn/update arrival clock. Secondary: Remove arrival clock. Reload: Copy clock settings.")
    language.Add("Undone_clock_arrive_tool", "Undone arrival clock")
end

function TOOL:LeftClick(trace)
	if SERVER then return end
	if self.LastUse and CurTime() - self.LastUse < 1 then return end
	self.LastUse = CurTime()
	local ply = self:GetOwner()
	if LocalPlayer() ~= ply then return false end
	if not ply:IsValid() or not ply:IsAdmin() then return false end
	if not trace then return false end
	if trace.Entity and trace.Entity:IsPlayer() then return false end

	local vec = trace.HitPos
	if not vec then return false end
	local ang = trace.HitNormal:Angle()
	ang:RotateAroundAxis(ang:Up(),-180)
	local station = GetConVar("clock_arrive_st"):GetString()
	local path = GetConVar("clock_arrive_path"):GetString()
	local dest = GetConVar("clock_arrive_dest"):GetString()
	local dist = GetConVar("clock_arrive_dist"):GetString()
	local line = GetConVar("clock_arrive_line"):GetString()
	local line_color = GetConVar("clock_arrive_line_r"):GetString()..","..GetConVar("clock_arrive_line_g"):GetString()..","..GetConVar("clock_arrive_line_b"):GetString()

	net.Start("SpawnClockArrive")
		net.WriteVector(vec)
		net.WriteAngle(ang)
		net.WriteString(station)
		net.WriteString(path)
		net.WriteString(dest)
		net.WriteString(dist)
		net.WriteString(line)
		net.WriteString(line_color)
	net.SendToServer()
	return true
end

function TOOL:RightClick(trace)
	if CLIENT then return end
	
    local ply = self:GetOwner()
    if not ply:IsValid() or not ply:IsAdmin() then return false end
    if not trace then return false end
    if trace.Entity and trace.Entity:IsPlayer() then return false end
	if not trace.HitPos then return false end
	local entlist = ents.FindInSphere(trace.HitPos,10) or {}
    for k,v in pairs(entlist) do
        if v:GetClass() == "gmod_track_clock_arrive" then
            if IsValid(v) then SafeRemoveEntity(v) end
        end
    end
    return true
end

function TOOL:Reload(trace)
    if SERVER then return end

	local ply = self:GetOwner()
	if LocalPlayer() ~= ply then return false end
	if not ply:IsValid() or not ply:IsAdmin() then return false end
	if not trace then return false end
	if trace.Entity and trace.Entity:IsPlayer() then return false end
	if not trace.HitPos then return false end
	local entlist = ents.FindInSphere(trace.HitPos,10) or {}
	for k,v in pairs(entlist) do
		if v:GetClass() == "gmod_track_clock_arrive" then
			if IsValid(v) then
				local station = tostring(v.Station)
				local path = tostring(v.Path)
				local dist = tostring(v.Distance)
				local dest = v.Dest				
				local line = v.Line
				local color = v.Color
				
				RunConsoleCommand("clock_arrive_st",station)
				RunConsoleCommand("clock_arrive_path",path)
				RunConsoleCommand("clock_arrive_dest",dest)
				RunConsoleCommand("clock_arrive_dist",dist)
				RunConsoleCommand("clock_arrive_line",line)
				RunConsoleCommand("clock_arrive_line_r",color.r)
				RunConsoleCommand("clock_arrive_line_g",color.g)
				RunConsoleCommand("clock_arrive_line_b",color.b)
			end
		end
	end
    return true
end
--language.GetPhrase("spawnmenu.content_tab")
function TOOL.BuildCPanel(panel)
	panel:AddControl("label",{ 
		text = language.GetPhrase("clockarrive.tool.label_main")
	})
	panel:AddControl("textbox",{ 
		Label = language.GetPhrase("clockarrive.tool.station_ID"), 
		Command = "clock_arrive_st"
	})
	
	panel:AddControl("textbox",{ 
		Label = language.GetPhrase("clockarrive.tool.station_path"), 
		Command = "clock_arrive_path"
	})
	panel:AddControl("textbox",{ 
		Label = language.GetPhrase("clockarrive.tool.destination"), 
		Command = "clock_arrive_dest"
	})
	panel:AddControl("textbox",{ 
		Label = language.GetPhrase("clockarrive.tool.distance"), 
		Command = "clock_arrive_dist"
	})
	panel:AddControl("slider",{
		Label = language.GetPhrase("clockarrive.tool.line_number"), 
		Command="clock_arrive_line",
		min=1,
		max=8
	})
	panel:AddControl("color",{
		Label = language.GetPhrase("clockarrive.tool.line_color"), 
		Red="clock_arrive_line_r",
		Green="clock_arrive_line_g",
		Blue="clock_arrive_line_b"
	})

	panel:AddControl("button",{ 
		Label = language.GetPhrase("clockarrive.tool.button_save"), 
		Command = "clocks_arrive_save"
	})
	panel:AddControl("button",{ 
		Label = language.GetPhrase("clockarrive.tool.button_load"), 
		Command = "clocks_arrive_load"
	})
	
	-- Временная кнопка 
	panel:AddControl("label",{ 
		text = language.GetPhrase("clockarrive.tool.label_fix"), 
	})
	panel:AddControl("button",{ 
		Label = language.GetPhrase("clockarrive.tool.button_fix"), 
		Command = "clocks_arrive_fix"
	})
end