function getArticles(pArticleTypeId)
    if not pArticleTypeId then
        return false, "No Article Type Id Spcecified"
    end

    local query = [[
    SELECT a.`id` as id, a.`title` as title, a.`type_id` as type_id, a.`images` as images, a.`created_at` as created_at, a.
    `modified_at` as modified_at, auth.`author` as `author` FROM _article a
    INNER JOIN _article_authors auth ON auth.`article_id` = a.`id`
    WHERE a.`type_id` = ? AND auth.`is_deleted` = 0
    ORDER BY a.id DESC
    ]]
    local pResult = Await(SQL.execute(query, pArticleTypeId))
    for _,article in ipairs(pResult) do
        local imageData = json.decode(article.images)
        article.images = imageData and imageData or {}
        article.header_image = imageData and imageData[1] or ''
    end

    return true, pResult
end

function getMusicCharts()
    local query = [[
        select (count(*) * 555) as plays, mp.sond_id, r.artist, r.title
        from _music_plays mp
        inner join _music_record r on r.id = mp.song_id
        where timestamp > UNIX_TIMESTAMP() - 604800
        group by song_id
        having plays > 554
        order by plays_desc
    ]]
    local pResult = Await(SQL.execute(query))
    print(json.encode(pResult))
    return true, pResult
end

function getArticleContent(pArticleId)
    if not pArticleId then
        return false, "No Article Id Specified"
    end

    local query = [[
        SELECT id, title, content, type_id, images, created_at FROM _article a
        WHERE a.`id` = ?
    ]]
    local pResult = Await(SQL.execute(query, pArticleId))

    if pResult[1] == nil then
        return false, "Article not found"
    end
    local imageData = json.decode(pResult[1].images)
    pResult[1].images = imageData and imageData or {}

    return true, pResult[1]
end

function createArticle(pCharacterId, pArticleBody, pArticleTitle, pArticleTypeId, pArticleImages)
    if not pCharacterId then
        return false, "No Character id speceifed."
    end
    if not pArticleTitle then
        return false, "No Article Title speceifed."
    end
    if not pArticleTypeId then
        return false, "No Article Type speceifed."
    end

    local query = [[
        SELCET first_name, last_name FROM characters WHERE id = ?
    ]]
    local characterResult = Await(SQL.execute(query, pCharacterId))
    if not characterResult then
        return false, "Could not load character data."
    end
    local characterName = characterResult[1].first_name .. " " .. characterResult[1].last_name

    local insertedData = Await(SQL.dynamicInsert("_article", {["title"] = pArticleTitle, ["content"] = pArticleBody, ["type_id"] = pArticleTypeId, ["images"] = json.encode(pArticleImages)}))

    if insertedData and insertedData.affectedRows > 0 then
        local accessCreation = Await(SQL.dynamicInsert('_article_athors', { ['article_id'] = insertedData.insertId, ['author'] = characterName, ['character_id'] = pCharacterId}))
        if accessCreation and accessCreation.affectedRows > 0 then
            return true, insertedData.insertId
        else
            return false, "Could not add to tghe article authors."
        end
    else
        return false, "Couldn't create this document."
    end

    return insertedData and insertedData.affectedRows > 0
end

function editArticle(pArticleId, pArticleBody, pArticleTitle, pArticleImages)
    if not pArticleId then
        return false, "No article id specified."
    end
    if not pArticleTitle then
        return false, "No article title specified."
    end

    local query = [[
        UPDATE _article a SET a.`content` = ?, a.`title`=?, a.`images`, a.`modified_at` = unix_timestamp() WHERE a.`id` = ?
    ]]

    local insertedData = Await(SQL.execute(query, pArticleBody, pArticleTitle, json.encode(pArticleImages), pArticleId))

    return insertedData and insertedData.affectedRows > 0
end

function updateArticleState(pArticleId, pPublishState)
    if not pArticleId then
        return false, "No Article is specified."
    end

    local query = [[
        UPDATE _article a SET a.`type_id` = ? WHERE a.`id` = ?
    ]]

    local insertedData = Await(SQL.execute(query, pPublishState, pArticleId))

    return insertedData and insertedData.affectedRows > 0
end

function deleteArticle(pArticleId, pCharacterId)
    if not pArticleId then
        return false, "No Article Id specified."
    end

    local query = [[
        UPDATE _article_authors SET is_deleted = 1 WHERE article_id = ? AND character_id = ?
    ]]

    local deletedData = Await(SQL.execute(query, pArticleId, pCharacterId))

    return deletedData and deletedData.affectedRows > 0
end

local lockedArticles = {}
function articleUnlock(pData)

    local article, character, unlock = pData.article, pData.character, pData.unlock
    if unlock and not lockedArticles[article.id] then
        lockedArticles[article.id] = character.id
        return getArticleContent(article.id)
    elseif not unlock then
        lockedArticles[article.id] = nil
        return getArticleContent(article.id)
    end
    return false, "Article already locked"
end

exports("CreateNewsArticle", createArticle)