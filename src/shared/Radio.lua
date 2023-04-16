local httpService = game:GetService("HttpService")

local radio = {}
local methods = {}

function methods:connect(path: string, callback: (...any) -> ())
    assert(type(path) == "string", "String type only.")
    assert(type(callback) == "function", "Function type only.")
    assert(not self.connections[path], "Already.")

    local connection = coroutine.create(function()
        local info = self.requestInfo
        info.Url..=path.."?password="..self.password

        while task.wait(5) do
            local success, result = pcall(httpService.RequestAsync, httpService, info)
            if not success then
				-- print(result)
                continue
			end
			
            if not result.Success then
                -- print(result.StatusMessage)
                continue
            end

            local success, decode = pcall(httpService.JSONDecode, httpService, result.Body)
			if not success or not decode[1] then
				-- print(decode)
                continue
            end

            callback(unpack(decode))
        end
    end)

    self.connections[path] = connection

    coroutine.resume(connection)
end

function methods:send()
    --TODO
end

function radio.new(url: string, password: string)
    local meta = setmetatable({}, {__index = methods})

    meta.url = url
    meta.password = password
    meta.connections = {}
    meta.requestInfo = {
        Url = ("http://%s/"):format(url),
        Method = "GET",
        Headers = {},
    }

    return meta
end

return radio