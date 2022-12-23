function addYellowPageEntry(pCharacterId, pFirstName, pLastName, pNumber, pText)
    if not pText then return false, "You need to type something" end

    print(pCharacterId, pFirstName, pLastName, pNumber, pText)

    local query = "INSERT INTO _yellowpages(character_id, first_name, last_name, number, text) VALUES(?, ?, ?, ?, ?)"

    local insertedData = Await(SQL.execute(query, pCharacterId, pFirstName, pLastName, pNumber, pText))

    return true, true
end

function getYellowPageEntries()
    local pResult = Await(SQL.execute("SELECT * FROM _yellowpages"))

    return true, pResult
end
