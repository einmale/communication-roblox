local dataStoreService = game:GetService("DataStoreService")
local players = game:GetService("Players")

local banStore = dataStoreService:GetDataStore("Ban")

local radioModule = game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Radio")
local radio = require(radioModule)

local communicator = radio.new("localhost:3000", "bro")

function findPlayer(name)
    if not name then
        return nil
    end
    
    for i,v in ipairs(players:GetPlayers()) do
        if not (v.Name:lower() == name:lower()) then
            continue
        end
        return v
    end
    return nil
end

players.PlayerAdded:Connect(function(player)
    local success, get = pcall(banStore.GetAsync, banStore, player.UserId)
    if not success or not get then
        return
    end

    player:Kick(get)
end)

communicator:connect("command", function(author: string, label: string, text: string)
    -- 1 author 2 label 3 text
    if label == "message" then
        local hint = workspace:FindFirstChild("Hint") or Instance.new("Hint", workspace)
        hint.Text = text
    elseif label == "kill" then
        local packed = text:split(" ")

        local player = findPlayer(packed[1])
        if not player then
            return
        end

        local character = player.character
        if not character then
            return
        end

        character.Humanoid:TakeDamage(character.Humanoid.MaxHealth)
    elseif label == "kick" then
        local packed = text:split(" ")

        local player = findPlayer(packed[1])
        if not player then
            return
        end

        table.remove(packed, 1)

        player:Kick(table.concat(packed or {}, " "))
    elseif label == "ban" then
        local packed = text:split(" ")

        local player = findPlayer(packed[1])
        if not player then
            return
        end

        table.remove(packed, 1)

        local reason = table.concat(packed or {}, " ")
        
        local success, result = pcall(banStore.SetAsync, banStore, player.UserId, reason)
        if not success then
            return
        end

        player:Kick(reason)
    elseif label == "unban" then
        local packed = text:split(" ")

        local success, result = pcall(players.GetUserIdFromNameAsync, players, packed[1] or "")
        if not success then
            return
        end

        local success, result = pcall(banStore.RemoveAsync, banStore, result)
        if not success then
            return
        end
    end
end)