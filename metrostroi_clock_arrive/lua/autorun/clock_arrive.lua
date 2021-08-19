if CLIENT then
	local Station = CreateClientConVar("clock_arrive_st","0",false)
	local Path = CreateClientConVar("clock_arrive_path","0",false)
	local Line = CreateClientConVar("clock_arrive_line",1,false)
	local Line_R = CreateClientConVar("clock_arrive_line_r",128,false)
	local Line_G = CreateClientConVar("clock_arrive_line_g",128,false)
	local Line_B = CreateClientConVar("clock_arrive_line_b",128,false)
	local Next = CreateClientConVar("clock_arrive_dest","Не указано",false)
else
	--TrainsArrive = TrainsArrive or {}
	util.AddNetworkString("SpawnClockArrive")
	--util.AddNetworkString("ClockArriveTime") 		-- временно отключено, под вопросом
	local function SpawnClockArrive(ply,vec,ang,station,path,dest,line,color)
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
		ent:SetNW2Int("Station",station)
		ent:SetNW2Int("Path",path)
		ent:SetNW2String("Destination",dest)
		ent:SetNW2String("Line",line)
		ent:SetNW2String("LineColor",color)
	end
	
	net.Receive("SpawnClockArrive", function(len,ply)
		if not ply:IsAdmin() then return end
		local vec,ang,station,path,dest,line,color = net.ReadVector(),net.ReadAngle(),net.ReadString(),net.ReadString(),net.ReadString(),net.ReadString(),net.ReadString()
		SpawnClockArrive(ply,vec,ang,station,path,dest,line,color)
	end)
	
	local function FindPlatform(st,path)
		for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
			if not IsValid(v) then continue end
			if v.StationIndex == st and v.PlatformIndex == path then return v end
		end
	end

	--[[timer.Create("CAUpdateTrainsInfo",3,0,function()
		local TrainPositions = {}
		for train,tpos in pairs(Metrostroi.TrainPositions) do
			if not IsValid(train) then continue end
			if train.Base ~= "gmod_subway_base" and train:GetClass() ~= "gmod_subway_base" then continue end
			local p = train:ReadCell(49167)
			table.insert(TrainPositions,{path=p,pos=tpos[1]})
		end

		for k,v in pairs(ents.FindByClass("gmod_track_platform")) do
			local PlatformArrives = {}
			for k2,v2 in pairs(TrainPositions) do
				local path = v2.path
				if v.PlatformIndex == path then
					local train_pos = v2.pos
					local station_pos = Metrostroi.GetPositionOnTrack(v.PlatformEnd)
					if station_pos then
						station_pos = station_pos[1]
						local arr,dist = Metrostroi.GetTravelTime(train_pos.node1,station_pos.node1)
						if arr < 600 then
							table.insert(PlatformArrives,math.Round(arr))
						end
					end
				end
			end
			TrainsArrive[v] = {}
			TrainsArrive[v].station = v.StationIndex
			TrainsArrive[v].path = v.PlatformIndex
			TrainsArrive[v].arrives = PlatformArrives
		end
		for _,ent in pairs(ents.FindByClass("gmod_track_clock_arrive")) do
			if not IsValid(ent) or not ent.Station or not ent.Path then continue end
			local ArrTimes = {}
			
			for k,v in pairs(TrainsArrive) do
				if ent.Path == v.path and ent.Station == v.station then 
					ArrTimes = v.arrives
					if #ArrTimes < 1 then
						ent:SetNW2Int("ArrTime",-1)
						break
					else
						local min_arr
						for k,v in pairs(ArrTimes) do
							if not min_arr or (v < min_arr and v > 15) then min_arr = v end
						end
						--print(min_arr)
						ent:SetNW2Int("ArrTime",min_arr)
						break
					end
				end
			end
		end
	end) ]]
	
	concommand.Add("clocks_arrive_save", function(ply)
		if not IsValid(ply) or not ply:IsAdmin() then return end
		local fl = file.Read("clocks_arrive.txt")
		local Clocks = fl and util.JSONToTable(fl) or {}
		local cur_map = game.GetMap()
		Clocks[cur_map] = {}
		for _,ent in pairs(ents.FindByClass("gmod_track_clock_arrive")) do
			if IsValid(ent) then table.insert(Clocks[cur_map],1,{ent:GetPos(),ent:GetAngles(),ent.Station,ent.Path,ent:GetNW2String("Destination"),ent:GetNW2String("Line"),ent:GetNW2String("LineColor")}) end
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
				for _,val in ipairs(Clocks) do
					SpawnClockArrive(nil,val[1],val[2],val[3],val[4],val[5],val[6],val[7])
				end
				print("Loaded "..#Clocks.." clocks arrive.")
			end)
		end
		if IsValid(ply) then ply:ChatPrint("Loaded "..#Clocks.." clocks arrive.") end
	end)
	
	-- Временная команда
	concommand.Add("clocks_arrive_fix", function(ply)
		if not IsValid(ply) or not ply:IsAdmin() then return end
		local col = 0
		for _,ent in pairs(ents.FindByClass("gmod_track_clock_arrive")) do
			if not IsValid(ent) then continue end
			local ang = ent:GetAngles()
			ang:RotateAroundAxis(ang:Up(),-90)
			ent:SetAngles(ang)
			ent:SetPos(ent:LocalToWorld(Vector(3,0,0)))
			col = col + 1
		end
		if IsValid(ply) then ply:ChatPrint("Fixed "..col.." clocks arrive.") end
	end)
	timer.Create("ClocksArriveLoad",4,1,function() RunConsoleCommand("clocks_arrive_load") timer.Remove("ClocksArriveLoad") end)
end
