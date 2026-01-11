local meta = FindMetaTable('Player')
function meta:GetResists()
    local allresists = 0

    if self.IsBlock then
        allresists = allresists + 0.3
    end

    return allresists
end

function meta:GetBuffDmg()
    local allbuffs = 0

    return allbuffs
end