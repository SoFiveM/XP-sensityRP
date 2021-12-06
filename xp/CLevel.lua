local RockstarRanks = {
800, 2100, 3800, 6100, 9500, 12500, 16000, 19800, 24000, 28500, 33400, 38700, 44200, 50200, 56400, 63000, 69900, 77100, 84700, 92500,
100700, 109200, 118000, 127100, 136500, 146200, 156200, 166500, 177100, 188000, 199200, 210700, 222400, 234500, 246800, 259400, 272300,
285500, 299000, 312700, 326800, 341000, 355600, 370500, 385600, 401000, 416600, 432600, 448800, 465200, 482000, 499000, 516300, 533800,
551600, 569600, 588000, 606500, 625400, 644500, 663800, 683400, 703300, 723400, 743800, 764500, 785400, 806500, 827900, 849600, 871500,
893600, 916000, 938700, 961600, 984700, 1008100, 1031800, 1055700, 1079800, 1104200, 1128800, 1153700, 1178800, 1204200, 1229800, 1255600,
1281700, 1308100, 1334600, 1361400, 1388500, 1415800, 1443300, 1471100, 1499100, 1527300, 1555800, 1584350}

XNL_UseRedBarWhenLosingXP = true	
XNL_MaxPlayerLevel = 500 			
XNL_EnableZKeyForRankbar = true					 
                                
XNL_CurrentPlayerXP = 1

RegisterNetEvent('Edit:xp',function(xp)
    XNL_CurrentPlayerXP = tonumber(xp)
    CurLevel = XNL_GetLevelFromXP(XNL_CurrentPlayerXP)
    CreateRankBar(XNL_GetXPFloorForLevel(CurLevel), XNL_GetXPCeilingForLevel(CurLevel), XNL_CurrentPlayerXP, XNL_CurrentPlayerXP, CurLevel, false)
end)

Citizen.CreateThread(function()
    while true do
        if IsControlPressed(0,32) then
            TriggerServerCallback('GetXPState',function(level)
                XNL_CurrentPlayerXP = tonumber(level)
                CurLevel = XNL_GetLevelFromXP(XNL_CurrentPlayerXP)
                CreateRankBar(XNL_GetXPFloorForLevel(CurLevel), XNL_GetXPCeilingForLevel(CurLevel), XNL_CurrentPlayerXP, XNL_CurrentPlayerXP, CurLevel, false)
            end)
        else
            Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    if not XNL_EnableZKeyForRankbar then return end
    TriggerServerCallback('GetXPState',function(level)
        XNL_CurrentPlayerXP = tonumber(level)
    end)   
end)

exports('Exp_XNL_SetInitialXPLevels', function(EXCurrentXP, EXShowRankBar, EXShowRankBarAnimating)
    XNL_SetInitialXPLevels(EXCurrentXP, EXShowRankBar, EXShowRankBarAnimating)
end)

exports('Exp_XNL_AddPlayerXP', function(EXXPAmount)
    XNL_AddPlayerXP(EXXPAmount)
end)

exports('Exp_XNL_RemovePlayerXP', function(EXXPAmount)
    XNL_RemovePlayerXP(EXXPAmount)
end)

exports('Exp_XNL_GetCurrentPlayerXP', function()
    return tonumber(XNL_GetCurrentPlayerXP())
end)

exports('Exp_XNL_GetLevelFromXP', function(EXXPAmount)
    return XNL_GetLevelFromXP(EXXPAmount)
end)

exports('Exp_XNL_GetCurrentPlayerLevel', function()
    return tonumber(XNL_GetCurrentPlayerLevel())
end)

RegisterNetEvent("XNL_NET:XNL_SetInitialXPLevels")
AddEventHandler("XNL_NET:XNL_SetInitialXPLevels", function(NetCurrentXP, NetShowRankBar, NetShowRankBarAnimating)
    XNL_SetInitialXPLevels(NetCurrentXP, NetShowRankBar, NetShowRankBarAnimating)
end)

RegisterNetEvent("XNL_NET:AddPlayerXP")
AddEventHandler("XNL_NET:AddPlayerXP", function(NetXPAmmount)
    XNL_AddPlayerXP(NetXPAmmount)
    ShowNotificationAward("Information", "Vous avez reçu de l'EXP", NetXPAmmount, 'CHAR_MICHAEL', 1)
end)

ShowNotificationAward = function(titleStr, subtitle, xp, txn, colourEnum)
    local handle = RegisterPedheadshot(PlayerPedId())
    while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
        Citizen.Wait(0)
    end
    local txd = GetPedheadshotTxdString(handle)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(subtitle)
    AddTextEntry(titleStr, titleStr)
    EndTextCommandThefeedPostAward(txd, txd, xp, colourEnum, titleStr)
end

RegisterNetEvent("XNL_NET:RemovePlayerXP")
AddEventHandler("XNL_NET:RemovePlayerXP", function(NetXPAmmount)
    XNL_RemovePlayerXP(NetXPAmmount)
end)


function XNL_SetInitialXPLevels(CurrentXP, ShowRankBar, ShowRankBarAnimating)
    XNL_CurrentPlayerXP = CurrentXP
    
    if ShowRankBar then
        CurLevel = XNL_GetLevelFromXP(CurrentXP)
        AnimateFrom = CurrentXP
        if ShowRankBarAnimating then
            AnimateFrom = XNL_GetXPFloorForLevel(CurLevel)
        end
        CreateRankBar(XNL_GetXPFloorForLevel(CurLevel), XNL_GetXPCeilingForLevel(CurLevel), AnimateFrom, XNL_CurrentPlayerXP, CurLevel, false)
    end
end

function XNL_GetCurrentPlayerXP()
    return XNL_CurrentPlayerXP
end

function XNL_GetCurrentPlayerLevel()
    return XNL_GetLevelFromXP(XNL_CurrentPlayerXP)
end

function XNL_OnPlayerLevelUp()
end

function XNL_OnPlayerLevelsLost()
end

function XNL_AddPlayerXP(XPAmount)
    if not is_int(XPAmount) then
        return
    end

    if XPAmount < 0 then
        return
    end
    
    local CurrentLevel = XNL_GetLevelFromXP(XNL_CurrentPlayerXP)	
    local CurrentXPWithAddedXP = XNL_CurrentPlayerXP + XPAmount		
    local NewLevel =  XNL_GetLevelFromXP(CurrentXPWithAddedXP)		
    local LevelDifference = 0										
    
    if NewLevel > XNL_MaxPlayerLevel - 1 then
        NewLevel = XNL_MaxPlayerLevel -1
        CurrentXPWithAddedXP = XNL_GetXPCeilingForLevel(XNL_MaxPlayerLevel - 1)
    end
    
    if NewLevel > CurrentLevel then
        LevelDifference = NewLevel - CurrentLevel
    end
    
    if LevelDifference > 0 then
        StartAtLevel = CurrentLevel
        CreateRankBar(XNL_GetXPFloorForLevel(StartAtLevel), XNL_GetXPCeilingForLevel(StartAtLevel), XNL_CurrentPlayerXP, XNL_GetXPCeilingForLevel(StartAtLevel), StartAtLevel, false)
        
        for i = 1, LevelDifference ,1 
        do 
            StartAtLevel = StartAtLevel + 1
            
            if i == LevelDifference then
                CreateRankBar(XNL_GetXPFloorForLevel(StartAtLevel), XNL_GetXPCeilingForLevel(StartAtLevel), XNL_GetXPFloorForLevel(StartAtLevel), CurrentXPWithAddedXP, StartAtLevel, false)
            else
                CreateRankBar(XNL_GetXPFloorForLevel(StartAtLevel), XNL_GetXPCeilingForLevel(StartAtLevel), XNL_GetXPFloorForLevel(StartAtLevel), XNL_GetXPCeilingForLevel(StartAtLevel), StartAtLevel, false)
            end
        end
    else
        CreateRankBar(XNL_GetXPFloorForLevel(NewLevel), XNL_GetXPCeilingForLevel(NewLevel), XNL_CurrentPlayerXP, CurrentXPWithAddedXP, NewLevel, false)
    end
    
    XNL_CurrentPlayerXP = CurrentXPWithAddedXP

    if LevelDifference > 0 then
        XNL_OnPlayerLevelUp()
    end
end

function XNL_RemovePlayerXP(XPAmount)
    if not is_int(XPAmount) then
        print("=====================================================================================================")
        print("XNL WARNING: You have an error in one of your scripts calling the function 'XNL_RemovePlayerXP'")
        print("XNL WARNING: The script which is calling this function is not passing an integer!")
        print("=====================================================================================================")
        return
    end

    if XPAmount < 0 then
        print("=====================================================================================================")
        print("XNL WARNING: You have an error in one of your scripts calling the function 'XNL_RemovePlayerXP'")
        print("XNL WARNING: is trying to give 'negative' XP by passing a negative value, If you for example  ")
        print("XNL WARNING: want to remove 100XP just use: 'XNL_RemovePlayerXP(100)' to remove 100XP from the player")
        print("=====================================================================================================")
        return
    end

    local CurrentLevel = XNL_GetLevelFromXP(XNL_CurrentPlayerXP)	
    local CurrentXPWithRemovedXP = XNL_CurrentPlayerXP - XPAmount	
    local NewLevel =  XNL_GetLevelFromXP(CurrentXPWithRemovedXP)	
    local LevelDifference = 0										
    
    if NewLevel < 1 then
        NewLevel = 1
    end

    if CurrentXPWithRemovedXP < 0 then
        CurrentXPWithRemovedXP = 0
    end

    
    if NewLevel < CurrentLevel then
        LevelDifference = math.abs(NewLevel - CurrentLevel)
    end
    
    if LevelDifference > 0 then
        StartAtLevel = CurrentLevel
        CreateRankBar(XNL_GetXPFloorForLevel(StartAtLevel), XNL_GetXPCeilingForLevel(StartAtLevel), XNL_CurrentPlayerXP, XNL_GetXPFloorForLevel(StartAtLevel), StartAtLevel, true)
        
        for i = 1, LevelDifference ,1
        do 
            StartAtLevel = StartAtLevel - 1
            
            if i == LevelDifference then
                CreateRankBar(XNL_GetXPFloorForLevel(StartAtLevel), XNL_GetXPCeilingForLevel(StartAtLevel), XNL_GetXPCeilingForLevel(StartAtLevel), CurrentXPWithRemovedXP, StartAtLevel, true)
            else

                CreateRankBar(XNL_GetXPFloorForLevel(StartAtLevel), XNL_GetXPCeilingForLevel(StartAtLevel), XNL_GetXPCeilingForLevel(StartAtLevel), XNL_GetXPFloorForLevel(StartAtLevel), StartAtLevel, true)
            end
        end
    else
        CreateRankBar(XNL_GetXPFloorForLevel(NewLevel), XNL_GetXPCeilingForLevel(NewLevel), XNL_CurrentPlayerXP, CurrentXPWithRemovedXP , NewLevel, true)
    end
    
    XNL_CurrentPlayerXP = CurrentXPWithRemovedXP
    
    if LevelDifference > 0 then
        XNL_OnPlayerLevelsLost()
    end
end

function XNL_GetXPFloorForLevel(intLevelNr)
    if is_int(intLevelNr) then
        
        if intLevelNr > 7999 then
            intLevelNr = 7999
            print("=====================================================================================================")
            print("XNL WARNING: You have an error in one of your scripts which is trying to get the floor level XP for")
            print("XNL WARNING: an player level beyond level 7999, which is the game limit!")
            print("XNL WARNING: Script has prevented this and set the 'limit' to 7999!")
            print("=====================================================================================================")
        end
        
        if intLevelNr < 2 then
            return 0
        end
        
        if intLevelNr > 100 then
            BaseXP = RockstarRanks[99]	
            ExtraAddPerLevel = 50		
            MainAddPerLevel = 28550 	
            
            BaseLevel = intLevelNr - 100 
            CurXPNeeded = 0				 
            for i = 1, BaseLevel ,1 
            do 
                MainAddPerLevel = MainAddPerLevel + 50		
                CurXPNeeded = CurXPNeeded + MainAddPerLevel	
            end
            
            return BaseXP + CurXPNeeded	
        end

        return RockstarRanks[intLevelNr - 1]
    else
        print("=====================================================================================================")
        print("XNL WARNING: You have an error in one of your scripts calling the function 'XNL_GetXPFloorForLevel'")
        print("XNL WARNING: The script which is calling this function is not passing an integer!")
        print("=====================================================================================================")
        return 0
    end
end

function XNL_GetXPCeilingForLevel(intLevelNr)
    if is_int(intLevelNr) then
        
        if intLevelNr > 7999 then
            intLevelNr = 7999
            print("=====================================================================================================")
            print("XNL WARNING: You have an error in one of your scripts which is trying to get the ceiling level XP")
            print("XNL WARNING: for an player level beyond level 7999, which is the game limit!")
            print("XNL WARNING: Script has prevented this and set the 'limit' to 7999!")
            print("=====================================================================================================")
        end
        

        if intLevelNr < 1 then
            print("=====================================================================================================")
            print("XNL WARNING: You have an error in one of your scripts which is trying to get the ceiling level XP")
            print("XNL WARNING: for an player level BELLOW level 1, which is the game limit!")
            print("XNL WARNING: Script has prevented this and set the 'limit' back to 1!")
            print("=====================================================================================================")
            return 800	
        end
        
        if intLevelNr > 99 then
            BaseXP = RockstarRanks[99]
            ExtraAddPerLevel = 50		
            MainAddPerLevel = 28550 	
            BaseLevel = intLevelNr - 99
            CurXPNeeded = 0
            for i = 1, BaseLevel ,1 
            do 
                MainAddPerLevel = MainAddPerLevel + 50
                CurXPNeeded = CurXPNeeded + MainAddPerLevel
            end
            
            return BaseXP + CurXPNeeded
        end
        return RockstarRanks[intLevelNr]
    else
        print("=====================================================================================================")
        print("XNL WARNING: You have an error in one of your scripts calling the function 'XNL_GetXPCeilingForLevel'")
        print("XNL WARNING: The script which is calling this function is not passing an integer!")
        print("=====================================================================================================")
        return 0 
    end
end

function XNL_GetLevelFromXP(intXPAmount)
    if is_int(intXPAmount) then
        local SearchingFor = intXPAmount
        
        if SearchingFor < 0 then return 1 end				
        
        if SearchingFor < RockstarRanks[99] then			
            local CurLevelFound = -1
        
            local CurrentLevelScan = 0
            for k,v in pairs(RockstarRanks)do			
                CurrentLevelScan = CurrentLevelScan + 1	
                if SearchingFor < v then break end		
            end
            
            return CurrentLevelScan
        else
            BaseXP = RockstarRanks[99]
            ExtraAddPerLevel = 50		
            MainAddPerLevel = 28550 	

            
            CurXPNeeded = 0
            local CurLevelFound = -1
            for i = 1, XNL_MaxPlayerLevel - 99 ,1 			
            do 												
                MainAddPerLevel = MainAddPerLevel + 50
                CurXPNeeded = CurXPNeeded + MainAddPerLevel
                CurLevelFound = i
                if SearchingFor < (BaseXP + CurXPNeeded) then break end
            end
        
            return CurLevelFound + 99
        end
    else
        print("=====================================================================================================")
        print("XNL WARNING: You have an error in one of your scripts calling the function 'XNL_GetLevelFromXP'")
        print("XNL WARNING: The script which is calling this function is not passing an integer!")
        print("=====================================================================================================")
        return 1
    end
end


function CreateRankBar(XP_StartLimit_RankBar, XP_EndLimit_RankBar, playersPreviousXP, playersCurrentXP, CurrentPlayerLevel, TakingAwayXP)
    if not HasHudScaleformLoaded(19) then							
        RequestHudScaleform(19)										
        while not HasHudScaleformLoaded(19) do						
            Wait(1)													
        end
    end

    BeginScaleformMovieMethodHudComponent(19, "SET_COLOUR")
        PushScaleformMovieFunctionParameterInt(1) 
    EndScaleformMovieMethodReturn()
    BeginScaleformMovieMethodHudComponent(19, "SET_RANK_SCORES")		
        PushScaleformMovieFunctionParameterInt(XP_StartLimit_RankBar)	
        PushScaleformMovieFunctionParameterInt(XP_EndLimit_RankBar)		
        PushScaleformMovieFunctionParameterInt(playersPreviousXP)		
        PushScaleformMovieFunctionParameterInt(playersCurrentXP)		
        PushScaleformMovieFunctionParameterInt(CurrentPlayerLevel)		
        PushScaleformMovieFunctionParameterInt(100)						
    EndScaleformMovieMethodReturn()										
end

function is_int(n)
    if type(n) == "number" then
        if math.floor(n) == n then
            return true
        end
    end
    return false
end

local disabledSafeZonesKeys = {
    {group = 2, key = 37, message = '~r~Vous devez être Niveau 3 pour pouvoir sortir une arme.'},
    {group = 0, key = 24, message = '~r~Vous devez être Niveau 3 pour pouvoir faire ceci.'},
    {group = 0, key = 69, message = '~r~Vous devez être Niveau 3 pour pouvoir faire ceci.'},
    {group = 0, key = 92, message = '~r~Vous devez être Niveau 3 pour pouvoir faire ceci.'},
    {group = 0, key = 106, message = '~r~Vous devez être Niveau 3 pour pouvoir faire ceci.'},
    {group = 0, key = 168, message = '~r~Vous devez être Niveau 3 pour pouvoir faire ceci.'}
}

Citizen.CreateThread(function()
    local index = 1
    while (true) do
        Citizen.Wait(1.0)
        --[[if IsPedFalling(GetPlayerPed(-1)) then
            SetPlayerInvincible(PlayerId(),true)
            index = index +1
        else
            if index > 1 then
                SetPlayerInvincible(PlayerId(),false)
                index = 1
            end
        end--]]
        if XNL_CurrentPlayerXP <= 2100 then
            N_0x4757f00bc6323cfe(-1553120962, 0.0) 
            for i = 1, #disabledSafeZonesKeys, 1 do
                DisableControlAction(disabledSafeZonesKeys[i].group, disabledSafeZonesKeys[i].key, true)
            
                if IsDisabledControlJustPressed(disabledSafeZonesKeys[i].group, disabledSafeZonesKeys[i].key) then
                    SetCurrentPedWeapon(player,'WEAPON_UNARMED', true)
            
                    if disabledSafeZonesKeys[i].message then
                        ESX.ShowNotification(disabledSafeZonesKeys[i].message)
                    end
                end
            end
        end
    end
end)