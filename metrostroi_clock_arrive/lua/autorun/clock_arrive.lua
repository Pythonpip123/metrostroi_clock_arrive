if CLIENT then
	local Station = CreateClientConVar("clock_arrive_st","0",false)
	local Path = CreateClientConVar("clock_arrive_path","0",false)
	local Line = CreateClientConVar("clock_arrive_line",1,false)
	local Line_R = CreateClientConVar("clock_arrive_line_r",128,false)
	local Line_G = CreateClientConVar("clock_arrive_line_g",128,false)
	local Line_B = CreateClientConVar("clock_arrive_line_b",128,false)
	local Next = CreateClientConVar("clock_arrive_dest","Не указано",false)
	local Dist = CreateClientConVar("clock_arrive_dist",1500,false)
else

	util.AddNetworkString("SpawnClockArrive")
	local function SpawnClockArrive(ply,vec,ang,station,path,dest,dist,line,color)
		local ex_vec
		local ex_ang
		if IsValid(ply) then
			local entlist = ents.FindInSphere(vec,10) or {}
			for k,v in pairs(entlist) do
				if v:GetClass() == "gmod_track_clock_arrive" then
					if IsValid(v) then
						ex_vec = v:GetPos()
						ex_ang = v:GetAngles()
						SafeRemoveEntity(v) 
					end
				end
			end
		end
		local ent = ents.Create("gmod_track_clock_arrive")
		ent:SetPos(ex_vec or vec)
		local angle = ex_ang or ang
		ent:SetAngles(angle)
		if IsValid(ply) and not ex_vec then ent:SetPos(ent:LocalToWorld(Vector(-5,0,-20))) end -- смещение только при спавне игроком
		ent:Spawn()
		if IsValid(ply) then
			undo.Create("clock_arrive_tool")
				undo.AddEntity(ent)
				undo.SetPlayer(ply)
			undo.Finish()
		end
		ent.Station = tonumber(station)
		ent.Path = tonumber(path)
		ent.Distance = tonumber(dist)
		ent:SetNW2Int("Station",station)
		ent:SetNW2Int("Path",path)
		ent:SetNW2String("Destination",dest)
		ent:SetNW2Int("Distance",dist)
		ent:SetNW2String("Line",line)
		ent:SetNW2String("LineColor",color)
	end
	
	net.Receive("SpawnClockArrive", function(len,ply)
		if not ply:IsAdmin() then return end
		local vec,ang,station,path,dest,dist,line,color = net.ReadVector(),net.ReadAngle(),net.ReadString(),net.ReadString(),net.ReadString(),net.ReadString(),net.ReadString(),net.ReadString()
		SpawnClockArrive(ply,vec,ang,station,path,dest,dist,line,color)
	end)
	
	local function FindPlatform(st,path)
		for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
			if not IsValid(v) then continue end
			if v.StationIndex == st and v.PlatformIndex == path then return v end
		end
	end
	
	concommand.Add("clocks_arrive_save", function(ply)
		if not IsValid(ply) or not ply:IsAdmin() then return end
		local fl = file.Read("clocks_arrive.txt")
		local Clocks = fl and util.JSONToTable(fl) or {}
		local cur_map = game.GetMap()
		Clocks[cur_map] = {}
		for _,ent in pairs(ents.FindByClass("gmod_track_clock_arrive")) do
			if IsValid(ent) then 
				table.insert(Clocks[cur_map],{
					Pos = ent:GetPos(),
					Angles = ent:GetAngles(),
					StationID = ent.Station,
					StationPath = ent.Path,
					Destination = ent:GetNW2String("Destination"),
					Distance = ent.Distance,
					Line = ent:GetNW2String("Line"),
					LineColor = ent:GetNW2String("LineColor")})
			end
		end
		file.Write("clocks_arrive.txt", util.TableToJSON(Clocks,true))
		print("Saved "..#Clocks[cur_map].." clocks arrive.")
		if IsValid(ply) then ply:ChatPrint("Saved "..#Clocks[cur_map].." clocks arrive.") end
	end)
	concommand.Add("clocks_arrive_load", function(ply)
		if IsValid(ply) and not ply:IsAdmin() then return end
		local fl = file.Read("clocks_arrive.txt")
		local Clocks = fl and util.JSONToTable(fl) or {}
		local cur_map = game.GetMap()
		Clocks = Clocks[cur_map]
		
		for k,v in pairs(ents.FindByClass("gmod_track_clock_arrive")) do
			SafeRemoveEntity(v)
		end
		if not Clocks or #Clocks < 1 then
			print("No clocks arrive for this map")
			if IsValid(ply) then ply:ChatPrint("No clocks arrive for this map.") end
			return
		else
			timer.Simple(1,function()    
				for _,clockdata in ipairs(Clocks) do
					SpawnClockArrive(nil,clockdata.Pos,clockdata.Angles,clockdata.StationID,clockdata.StationPath,clockdata.Destination,clockdata.Distance,clockdata.Line,clockdata.LineColor)
				end
				print("Loaded "..#Clocks.." clocks arrive.")
			end)
		end
		if IsValid(ply) then ply:ChatPrint("Loaded "..#Clocks.." clocks arrive.") end
	end)
	
	-- Временная команда 
	concommand.Add("clocks_arrive_fix", function(ply)
		if IsValid(ply) and not ply:IsAdmin() then return end
		local NewClocks = {}
		local fl = file.Read("clocks_arrive.txt")
		local Clocks = fl and util.JSONToTable(fl) or {}
		local cur_map = game.GetMap()
		NewClocks[cur_map] = {}

		if not Clocks[cur_map] or #Clocks[cur_map]  < 1 then
			print("No clocks to fix on this map")
			if IsValid(ply) then 
				ply:ChatPrint("No clocks to fix on this map")
			end
			return
		else
			for _,val in ipairs(Clocks[cur_map]) do
					table.insert(NewClocks[cur_map],{
						Pos = val[1],
						Angles = val[2],
						StationID = val[3],
						StationPath = val[4],
						Destination = val[5],
						Distance = 1500,
						Line = val[6],
						LineColor = val[7]})			
			end	
			table.Empty(Clocks[cur_map])
		end
		table.Merge(Clocks, NewClocks)
		file.Write("clocks_arrive.txt", util.TableToJSON(Clocks,true))
		print("Fixed "..#NewClocks[cur_map].." clocks arrive.")		
		if IsValid(ply) then ply:ChatPrint("Fixed "..#NewClocks[cur_map].." clocks arrive.") end
	end)
	timer.Create("ClocksArriveLoad",4,1,function() RunConsoleCommand("clocks_arrive_load") timer.Remove("ClocksArriveLoad") end)
end
