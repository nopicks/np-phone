function getContacts(pCharacterId)
    if not pCharacterId then return false, "Error while fetching data." end

    local query = [[
        SELECT * FROM `_phone_contact` a
        WHERE character_id = ?
    ]]

    local pResult = Await(SQL.execute(query, pCharacterId))

    return pResult ~= nil and true or false, pResult or {}
end

function addContact(pCharacterId, pName, pNumber)
    if not pName then return false, "You need to specify a name" end

    local query = "INSERT INTO _phone_contact(character_id, name, number) VALUES(?, ?, ?)"

    local insertedData = Await(SQL.execute(query, pCharacterId, pName, pNumber))

    return insertedData and insertedData.affectedRows > 0
end

function deleteContact(pSource, pContactId)
    local user = exports["np-base"]:getModule("Player"):GetUser(pSource)
    local character = user:getCurrentCharacter()

    local query = "DELETE FROM _phone_contact WHERE id = ? and character_id = ?"

    local pResult = Await(SQL.execute(query, pContactId, character.id))
    if pResult then
        return true
    end

    return false, "Couldn't remove person."
end