RPC.register("phone:getContacts", function(pSource, pCharacterId)
    return getContacts(pCharacterId)
end)

RPC.register("phone:addContact", function(pSource, pCharacterId, pName, pNumber)
    return addContact(pCharacterId, pName, pNumber)
end)

RPC.register("phone:deleteContact", function(pSource, pContactId)
    return deleteContact(pSource, pContactId)
end)

RPC.register("phone:sendMessage", function(pSource, pSourceNumber, pTargetNumber, pMessage)
    return sendMessage(pSourceNumber, pTargetNumber, pMessage)
end)

RPC.register("phone:getConversations", function(pSource, pSourceNumber)
    return getConversations(pSourceNumber)
end)

RPC.register("phone:getMessages", function(pSource, pSourceNumber, pTargetNumber)
    return getMessages(pSourceNumber, pTargetNumber)
end)

RPC.register("phone:checkCryptoAmount", function(pSource, pCryptoId, pAmount)
    local user = exports["np-base"]:getModule('Players'):GetUser(pSource)
    local character = user:getCurrentCharacter()
    local pCharacterId = character.id
    local success, message = getCrypto(pCharacterId)
    if not success then
        return false, message
    end

    local found = nil
    for _, v in pairs(message) do
        if v.id == pCryptoId then
            found = v
        end
    end
    if found == nil then
        return false, "Wallet not found"
    end
    if found.amount < pAmount then
        return false, "Not enough " .. found.name .. "! (" .. tostring(pAmount) .. ")"
    end
    return found, ''
end)

RPC.register("phone:getCrypto", function(pSource)
    local user = exports["np-base"]:getModule('Players'):GetUser(pSource)
    local character = user:getCurrentCharacter()
    local pCharacterId = character.id

    getCrypto(pCharacterId)
end)

RPC.register("phone:droppedDocumentDestroy", function(pSource, pDocumentId)
    droppedDocumentDestroy(pDocumentId)
end)

RPC.register("phone:getServerIdByPhoneNumber", function(pSource, pNumber)
    if (ActiveNumbers[pNumber]) then
        return true, ActiveNumbers[pNumber].data.source
    end
    return false, nil
end)

RPC.register("phone:addYellowPageEntry", function(pSource, pCharacterId, pFirstName, pLastName, pNumber, pText)
    return addYellowPageEntry(pCharacterId, pFirstName, pLastName, pNumber, pText)
end)

RPC.register("phone:getYellowPageEntries", function(pSource)
    return getYellowPageEntries()
end)

RPC.register("phone:addTwatterEntry", function(pSource, pCharacterId, first_name, last_name, text)
    return addTwatterEntry(pCharacterId, first_name, last_name, text)
end)

RPC.register("phone:getTwatterEntries", function(pSource)
    return getTwatterEntries()
end)

RPC.register("phone:getArticles", function(pSource, pArticleTypeId)
    return getArticles(pArticleTypeId)
end)

RPC.register("phone:getMusicCharts", function(pSource, pArticleTypeId)
    return getMusicCharts(pArticleTypeId)
end)

RPC.register("phone:getArticleContent", function(pSource, pArticleTypeId)
    return getArticleContent(pArticleTypeId)
end)

RPC.register("phone:createArticle", function(pSource, pCharacterId, pArticleBody, pArticleTitle, pArticleTypeId, pArticleImages)
    return createArticle(pCharacterId, pArticleTitle, pArticleTypeId, pArticleImages)
end)

RPC.register("phone:editArticle", function(pSource, pArticleId, pArticleBody, pArticleTitle, pArticleImages)
    return editArticle(pArticleId, pArticleBody, pArticleTitle, pArticleImages)
end)

RPC.register("phone:updateArticleState", function(pSource, pArticleId, pPublishState)
    return editArticle(pArticleId, pPublishState)
end)

RPC.register("phone:deleteArticle", function(pSource, pArticleId, pCharacterId)
    return deleteArticle(pArticleId, pCharacterId)
end)

RPC.register("phone:articleUnlock", function(pSource, pData)
    return articleUnlock(pData)
end)