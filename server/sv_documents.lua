function getDocumentTypes()
    local query = [[
        SELECT `id`, `name`, `editable`, `shareable`, `require_signature` as can_sign, `max_signature` as max_signatures FROM _document_type
    ]]
    local pResult = Await(SQL.execute(query))

    return true, pResult
end

function getDocuments(pCharacterId, pDocumentTypeId)
    if not pCharacterId then return false, "No Character Id specified." end
    if not pDocumentTypeId then return false, "No Document Type Id specified" end

    local query = [[
        SELECT d.`id`, d.`editable`, `title`, t.`name` as 'type', type_id, a.`can_sign`, a.`signed` FROM _document d
        INNER JOIN _document_type t on t.id = d.type_id
        INNER JOIN _document_access a ON a.`document_id` = d.`id` AND a.`character_id` = ?
        WHERE d.type = ? AND a.is_deleted = 0
    ]]
    local pResult = Await(SQL.execute(query, pCharacterId, pDocumentTypeId))

    return true, pResult
end

function getDocumentContent(pDocumentId)
    if not pDocumentId then return false, "No document Id specified." end

    local query = [[
        SELECT id, title, content, type_id, editable FROM _document d
        WHERE d.`id` = ?
    ]]
    local pResult = Await(SQL.execute(query, pDocumentId))

    return true, pResult
end

function signDocument(pDocumentId, pCharacterId)
    local query = [[
        UPDATE _document_access SET signed = unix_timestamp() WHERE document_id = ? AND character_id = ?
    ]]

    local pResult = Await(SQL.execute(query, pDocumentId, pCharacterId))
    local success = pResult and pResult.affectedRows > 0
    return success, success and "done" or "Could not sign document"
end

function shareDocumentPermanent(pData)
    local insertedData = Await(SQL.dynamicInsert('_document_access', {
        ['document_id'] = pData.document.id,
        ['character_id'] = Pdata.sharee_id,
    }))
    return true, "done"
end

function shareDocumentLocal(pTriggerSource, pId, pTypeId)
    local coords = GetEntityCoords(GetPlayerPed(pTriggerSource))
    if not coords then return false end
    exports["np-sync"]:TriggerAreaEvent("np-phone:showDocumentLocal", coords, 5.0, pTriggerSource, pId, pTypeId)
    return true
end

exports("CreateDocument", createDocument)