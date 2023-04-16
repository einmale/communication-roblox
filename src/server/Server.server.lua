local radioModule = game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Radio")
local radio = require(radioModule)

local communicator = radio.new("localhost:3000", "bro")

communicator:connect("command", function(author, label, ...)
    print(author)
    print(label)
    print(...)
end)