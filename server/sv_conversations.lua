function readPlayerconversations(pSource, pServerId, pPlayerId)
    local success, message
    if not success then
        return "Cannot read player conversations"
    end
end

function sendMessage(source_number, number_to, text_message)
    local targetSource = getSourceByPhoneNumber(tonumber(number_to))
    local query = [[INSERT INTO _phone_message (id, number_from, number_to, message) VALUES (?, ?, ?)]]
    local result = Await(SQL.execute(query, source_number, number_to, text_message))
    if (result.affectedRows >= 1) then
        if (targetSource ~= nil) then
            TriggerClientEvent("phone:sms:receive", targetSource, source_number, text_message)
        end
        return true
    else
        return false
    end

    return false
end

function getMessages(pSource, source_number, target_number)
    local user = exports["ucrp-base"]:getModule('Player'):GetUser(pSource);
    local character = user:getCurrentCharacter()
    local pCharacterId = character.id
    -- do gsub for numberTarget and remove ";"
    local numberSrc = tostring(source_number)
    local numberTarget = string.gsub(tostring(target_number), ";", "")
    local messages = {}
    
    print(("[2][Phone] Getting messages | Source Number: %s type: %s | Target Number: %s type: %s"):format(numberSrc, type(numberSrc), numberTarget, type(numberTarget)))
    -- we will fetch all the messages for the both numbers
    -- and then we will filter the messages that are not between the two numbers
    -- once we found the messages between the two numbers we will add them to a table
    local query = [[SELECT * FROM _phone_message WHERE (`number_from` = ? AND `number_to` = ?) OR (`number_from` = ? AND `number_to` = ?)]]
    local pResult = Await(SQL.execute(query, numberSrc, numberTarget, numberTarget, numberSrc))
    local dataStructure = {
        id,
        number_from,
        number_to,
        message,
        timestamp,
        displayName,
    }   
    
    if (#pResult == 0) then
        return false, "No messages found"
    end

    for k, v in pairs(pResult) do
        local contactNameQuery = [[SELECT `name` FROM _phone_contact WHERE `number` = ? AND `character_id` = ?]]
        local contactNameResult = Await(SQL.execute(contactNameQuery, numberTarget, pCharacterId))
        local contactName = (contactNameResult[1] ~= nil and contactNameResult[1].name or nil)
        local message = {
            id = v.id,
            number_from = v.number_from,
            number_to = v.number_to,
            message = v.message,
            timestamp = v.timestamp,
            displayName = contactName,
        }

        table.insert(messages, message)
    end
    
    return true, messages
end

function getConversations(source_number, cid)
    local query = [[
        SELECT * FROM _phone_message WHERE number_from = ? OR number_to = ?
    ]]
    local pResult = Await(SQL.execute(query, source_number, source_number))

    if (#pResult == 0) then
        print("[Phone] No conversations found")
        return false, "No conversations found"
    end

    local tempData = {}
    for _, row in pairs(pResult) do
        local id = row.id
        local number_from = row.number_from
        local number_to = row.number_to
        local message = row.message
        local timestamp = row.timestamp
        local conversation = {
            id = id,
            number_from = number_from,
            number_to = number_to,
            message = message,
            timestamp = timestamp,
            received = true
        }

        if (tonumber(number_from) == tonumber(source_number)) then
            conversation.received = false
        end
        Wait(100)
        table.insert(tempData, conversation)
    end

    -- in here we must get the contact name of that number we've received message from or we've sent message to, if its saved in our contacts
    for _, conversation in pairs(tempData) do
        local number_from = conversation.number_from
        local number_to = conversation.number_to
        local query = [[
            SELECT * FROM _phone_contact WHERE number = ? AND character_id = ?
        ]]

        local pResult = Await(SQL.execute(query, number_from, cid))
        if #pResult > 0 then
            conversation.displayName = pResult[1].name
        end

        local pResult = Await(SQL.execute(query, number_to, cid))
        if #pResult > 0 then
            conversation.displayName = pResult[1].name
        end
    end

    Wait(100)

    -- after all we must look for the latest message of conversations for each and add only that to our data
    local data = {}
    for _, conversation in pairs(tempData) do
        local id = conversation.id
        local number_from = conversation.number_from
        local number_to = conversation.number_to
        local message = conversation.message
        local timestamp = conversation.timestamp
        local displayName = conversation.displayName
        local received = conversation.received
        local found = false
        for _, dataConversation in pairs(data) do
            if (dataConversation.number_from == number_from and dataConversation.number_to == number_to) or
                (dataConversation.number_from == number_to and dataConversation.number_to == number_from) then
                found = true
                if (tonumber(timestamp) > tonumber(dataConversation.timestamp)) then
                    dataConversation.message = message
                    dataConversation.timestamp = timestamp
                    dataConversation.displayName = displayName
                    dataConversation.received = received
                end
            end
        end
        if not found then
            local conversation = {
                id = id,
                number_from = number_from,
                number_to = number_to,
                message = message,
                timestamp = timestamp,
                displayName = displayName,
                received = received
            }
            table.insert(data, conversation)
        end
    end

    Wait(100)
    return true, data
end