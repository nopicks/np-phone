function addTwatterEntry(pCharacterId, first_name, last_name, pText)
    if not pText then return false, "You need to type something" end
    local data = {character = {cid = pCharacterId, first_name = first_name, last_name = last_name}, timestamp = os.time(os.date("!*t")), text = pText}

    local query = "INSERT INTO _twats(character_id, first_name, last_name, text) VALUES(?, ?, ?, ?)"

    local insertedData = Await(SQL.execute(query, pCharacterId, first_name, last_name, json.encode(pText)))

    TriggerClientEvent("phone:twatter:receive", -1, data)

    return true, true
end

function getTwatterEntries()
    local pResult = Await(SQL.execute("SELECT * FROM _twats"))

    return true, pResult
end