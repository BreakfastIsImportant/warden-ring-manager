local mq = require('mq')
local ImGui = require('ImGui')
local mqRoot = mq.TLO
    and mq.TLO.MacroQuest
    and mq.TLO.MacroQuest.Path
    and mq.TLO.MacroQuest.Path()
if mqRoot and mqRoot ~= '' then
    local luaRoot = mqRoot..'\\lua\\'
    package.path = table.concat({
        luaRoot..'?.lua',
        luaRoot..'?\\init.lua',
        luaRoot..'pt-main\\?.lua',
        package.path,
    },';')
end
local PearlNetwork = require('pt-main.network')
local PearlUI = require('pt-main.ui')
local itemIcons = mq.FindTextureAnimation('A_DragItem')
local ITEM_ICON_OFFSET = 500

local Rings = {
    {id=151788, name='Rank 0', warden=0},
    {id=150915, name='Rank 1 PF 4', warden=1},
    {id=151725, name='Rank 1 PF 3', warden=1},
    {id=150916, name='Rank 2 PF', warden=2},
    {id=150940, name='Rank 2 Melee', warden=2},
    {id=151757, name='Rank 3 PF', warden=3},
    {id=151758, name='Rank 3 Melee', warden=3},
    {id=154798, name='Rank 4 PF', warden=4},
    {id=154797, name='Rank 4 Melee', warden=4},
}

local WardenLabels = {
    'None',
    'Warden I',
    'Warden II',
    'Warden III',
    'Warden IV',
}

local WardenBonus = {0, 0.4, 0.8, 1.2, 1.6}

local LevelMight = {
    [45]=1, [46]=1, [47]=1, [48]=1, [49]=1, [50]=1, [51]=1,
    [52]=2, [53]=2, [54]=3, [55]=4, [56]=5, [57]=6, [58]=7,
    [59]=8, [60]=10, [61]=13, [62]=16, [63]=20, [64]=30,
    [65]=40, [66]=60, [67]=80, [68]=100, [69]=120, [70]=140,
    [71]=150, [72]=150,
}

local DifficultyModes = {
    {name='Easy-', multiplier=2.5},
    {name='Easy', multiplier=2.0},
    {name='Easy+', multiplier=1.5},
    {name='Normal-', multiplier=1.2},
    {name='Normal', multiplier=1.0},
    {name='Normal+', multiplier=0.8},
    {name='Hard-', multiplier=0.6},
    {name='Hard', multiplier=0.5},
    {name='Hard+', multiplier=0.3},
}

local DifficultyLabels = {'Bronze', 'Silver', 'Gold', 'Platinum'}
local MoonPetLabels = {'None', 'I (+10)', 'II (+30)', 'III (+80)'}
local MoonPetBonus = {0, 10, 30, 80}

local InstanceCategories = {
    {
        name='Solo / Duo',
        tiers={
            {name='Tier 1 - Classic', tier=1, might=2, auto=true, content='GrimClaw (North Karana)|Allizewsaur (Ocean of Tears)|Icebane (Everfrost Peaks)'},
            {name='Tier 2 - Classic', tier=2, might=5, auto=true, content='Cazel (Oasis of Marr)|Phinigel Autropos (Kedge Keep)'},
            {name='Tier 3 - Kunark / Serpent Spine', tier=3, might=8, auto=true, content='Gorenaire (Deadlands)|Ixiblat Fer (Skyfire)|Mal / Plasa / Bigone (Gorukar Mesa)'},
            {name='Tier 4 - Velious', tier=4, might=10, auto=true, content='Narandi the Wretched (Great Divide)|Mistress Latazura (Siren\'s Grotto)'},
            {name='Tier 5 - Luclin', tier=5, might=15, auto=true, content='Doomshade (Umbral Plains)|Grieg Veneficius (Grieg\'s End)|Pathless Sentinel (The Grey)'},
            {name='Tier 6 - Dragons of Norrath', tier=6, might=20, auto=true, content='Grel Strongboom (Broodlands)|Tirranun (Tirranun\'s Delve)'},
            {name='Tier 7 - Planes of Power', tier=7, might=80, content='Bertoxxulous (Crypt of Decay)|Fabled Lady Vox|Beau\'Draa (Root of Ro)'},
            {name='Tier 8 - Dragons of Norrath', tier=8, might=120, content='Rikkukin (The Ascent)|Circle of Drakes (The Nest)|Matriarch Shyra (The Lodge)'},
            {name='Tier 9 - Omens of War', tier=9, might=160, content='Mastery of Versatility|Antraygus|Zhisza Shissars'},
            {name='Tier 10 - Classic Trio / Others', tier=10, might=200, content='Timeless Frenzied Ghoul|Axeweaver and Mundunugu|Ar\'yer the Warlord|Corruption of Ro'},
            {name='Tier 11 - Fabled / Others', tier=11, might=260, content='Fabled Terris Thule|Fabled Manaetic Behemoth|Timeless Cazel|Stitch|Dyn\'leth'},
            {name='Tier 12 - Veeshan\'s Peak Trio', tier=12, might=320, content='Veeshan\'s Peak 3.0 - Skyflap\'s quest'},
        },
    },
    {
        name='Group',
        tiers={
            {name='Tier 0 - Classic', tier=0, might=0, content='Broog Bloodbeard|Kly Overseer|Lord Elgnub & Tranixx Darpaw|Queen Ahex`Ka'},
            {name='Tier 1 - Classic', tier=1, might=6, auto=true, content='Lady Vox|Lord Nagafen|The Ghoul Lord'},
            {name='Tier 2 - Classic Planes', tier=2, might=30, auto=true, content='Cazic Thule (Plane of Fear)|Innoruuk (Plane of Hate)'},
            {name='Tier 3 - Classic / Kunark', tier=3, might=50, auto=true, content='Lady Vox\' Sister|Venril Sathir|Trakanon|Overking Bathezid'},
            {name='Tier 4 - Velious', tier=4, might=75, content='Velketor|King Tormax|The Final Arbiter|Zlandicar|Lord Yelinak|Vulak\'Aerr'},
            {name='Tier 5 - Kunark / Luclin', tier=5, might=100, raidMight=200, content='Korucust (Halls of Betrayals)|Inquisitor Seru|Emperor Ssraeshza|Aten Ha Ra (also Raid Tier 5)'},
            {name='Tier 6 - Dragons and Idols', tier=6, might=200, raidMight=320, content='The Avatar of War|Phara Dar (also Raid Tier 6)'},
            {name='Tier 7 - Fabled / Planes of Power', tier=7, might=500, auto='selected', content='Fabled Lord Nagafen|Fabled Venril Sathir|Quarm'},
            {name='Tier 8 - Gates of Discord / LDoN', tier=8, might=800, content='Primal Ukun Warhound|The Keeper of the Altar|Zun`Muram Tkarish Zyk|Tunat`Muram Cuu Vauax|Ancient Seer Venos'},
            {name='Tier 9 - Omens / Dragons / Others', tier=9, might=1100, content='Ancient Warlord Petrad|Summoran|Arch Magus Vangl|Vishimtar|Ar\'yer'},
            {name='Tier 10 - Fabled / Others', tier=10, might=1400, content='Nightrage Sanguinarch|Fabled Agnarr|Fabled Skal|Fabled Saryrn|Sullon Zek|Mayong\'s Confidents|Ayonae Ro'},
            {name='Tier 11 - Fabled / LDoN', tier=11, might=1700, content='Fabled Lord Mithaniel Marr|Fabled Solusek Ro|Fabled Rallos Zek|Chamber of Eternal Affliction|Sunken Labyrinth|Solteris'},
            {name='Tier 12 - Timeless / Fabled', tier=12, might=2000, raidMight=3500, content='Fabled Fennin Ro|Fabled Rydda`Dar|Geomancer Blackquill|Timeless Trakanon|Mayong Mistmore|Solusek Ro|Gorvash Bloodmarauder'},
            {name='Tier 13 - Might progression', tier=13, might=2300, raidMight=4200, content='Krag`Thul|Rallos Zek|Shade of Glenicae|Timeless Avatar of War|Skaramatra|Lavaforged Behemoth|Plaguelord Musca|Ebonthrax'},
            {name='Tier 14', tier=14, might=2600, raidMight=4800, content='Tier 14 progression targets (including 12- and 24-player raid suggestions)'},
            {name='Tier 15', tier=15, might=2900, content='Tier 15 progression targets'},
        },
    },
    {
        name='Raid',
        tiers={
            {name='Tier 5 Raid', tier=5, might=200, content='Aten Ha Ra (Vex Thal)'},
            {name='Tier 6 Raid', tier=6, might=320, content='Phara Dar (Veehan\'s Peak 2.0)'},
            {name='Tier 12 Raid', tier=12, might=3500, content='Fabled Plane of Fire - Fennin Ro|Fabled Temple of Marr - Rydda`Dar|Solteris|Toskirakk'},
            {name='Tier 13 Raid', tier=13, might=4200, content='Gorvash Bloodmarauder|Shadow of Zek (Toskirakk)'},
            {name='Tier 14 Raid', tier=14, might=4800, content='Raid Tier 14 progression targets'},
        },
    },
}

local ProgressNPCs = {
    solo={name='Lady Maria Luisa',categoryIndex=1},
    group={name='Sir Daniel',categoryIndex=2},
}

-- Names come from https://www.eqmight.com (Quests / Notable NPC pages).
local DefaultCurrencies = {
    {name='Token of Might',note='Instance rewards; spend with Walter'},
    {name='Token of Epic Might',note='10 Tokens of Might each (Walter); Epic 1.0 weapons from Cloe'},
    {name='Token of Legendary Might',note='6 Tokens of Epic Might each; gemstones from Cacuzza'},
    {name='Invaluable Coin',note='Hard/Hard- instance win; hand to Walter or Cloe',itemOnly=true},
}

local GuideSections = {
    {
        id='basics',
        label='How Might Works',
        lines={
            'Characters gain Might as they level; instance difficulty and final rewards depend on the party\'s Might.',
            'Get relevant AAs before leveling further to maximise Might.',
            'Suggested Might (or slightly below) gives Normal mode; Normal wins add a bonus chest with extra loot and Tokens of Might.',
            'Reclaim Tokens via Inventory > Alternate Currencies > Reclaim, then shop with Walter.',
            'Your first instance is offered by Marta in regular Permafrost (at least 1 Token of Might).',
        },
    },
    {
        id='path',
        label='Progression Path',
        lines={
            'Level 45: eligible for progression instances (leveling to 52 first may help, depending on class and gear).',
            'Tier 1: finish both solo instances OR both group instances to unlock Tier 2 and level 55. Completing both paths grants the AA reward twice.',
            'Level 66 (10 AA): beat the Ancient Statue of War in the instanced Plane of War on Normal or higher; loot the Ancient Battle Plans and hand them to Sir Daniel in Plane of Knowledge.',
            'Level 67 (20 AA): beat the Legend of the Spider Den on Normal- or higher; hand the Legendary Battle Plans to Sir Daniel.',
            'Ask Lady Maria Luisa (solo/duo) or Sir Daniel (group) for your current standing. Their spirits only spawn inside instances.',
            'Use the Checklist tab to mark each tier target and side flag as you finish it.',
        },
    },
    {
        id='npcs',
        label='Key NPCs',
        lines={
            'Sir Daniel / Lady Maria Luisa: progression status and level cap (Plane of Knowledge, Surefall Glades, Nexus, Temple of Marr).',
            'Walter: Tokens shop. 10 Tokens of Might buys a class buff artifact voucher (needs good faction: give him or Cloe an Invaluable Coin).',
            'Cloe: custom currency merchant; Epic 1.0 weapons for 2 Tokens of Epic Might (1 for Warrior, Ranger, Beastlord); Epic Gemstones for 3.',
            'Cacuzza: Legendary Gemstones for 5+ Tokens of Legendary Might.',
            'Pam: trades Tokens between your own characters (group of two, same zone, same IP).',
            'Pietri: exchanges your Ring of the Warden or Moon Pet Orb for any unlocked rank.',
            'Moonshine (L60), Lydia (L65), Korven (L68): buff items in the Nexus, unlocked by handing in more Invaluable Coins.',
        },
    },
    {
        id='currency',
        label='Currency Flow',
        lines={
            '1 Invaluable Coin: Walter sells 1 Token of Epic Might for 10 Tokens of Might.',
            '2 Invaluable Coins: Walter sells 1 Token of Legendary Might for 6 Tokens of Epic Might.',
            'More Invaluable Coins unlock further buff items from Moonshine, Lydia, and Korven.',
            'Epic 1.0 upgrade: 3 additional Tokens of Epic Might for the matching augmentation.',
        },
    },
    {
        id='rings',
        label='Warden & Moon Pets',
        lines={
            'Each completed Warden of Might stage unlocks a ring rank; every rank above 0 adds 40% Might.',
            'Warden I +40%, II +80%, III +120%, IV +160%.',
            'Moon Pet Orb ranks 1/2/3 need levels 60/65/68 (+10 / +30 / +80 Might).',
            'Use the Rings tab to swap rank and augments through Pietri.',
        },
    },
}

local State = {
    open=true,
    currentIndex=1,
    targetIndex=1,
    status='Ready',
    savedAugs={},
    loadouts={},
    loadoutName='',
    selectedLoadout=0,
    draftRingIndex=1,
    draftSlots={},
    selectedAugSlot=1,
    availableAugs={},
    fitSelectedSlot=true,
    inventoryDirty=true,
    swapRequested=false,
    party={},
    instanceCategory=2,
    instanceTier=2,
    instanceTarget=1,
    progressDone={},
    progressFilter=1,
    sideFlags={},
    nextSideFlagID=1,
    newSideFlagName='',
    altCurrencies={},
    newAltCurrencyName='',
    currencyScanRequested=false,
    currencyReclaimRequested=false,
    progressStatus='Progress saves automatically.',
    progressReports={},
    progressPendingSave=false,
    progressPendingChanges=0,
    autoTrackProgressLogs=false,
    logTiers={},
    logMaxTier={},
    progressNav='overview',
    logChanges=0,
    logOffset=0,
    logCarry='',
    logLastPoll=0,
    logStatus='Log tracking is off.',
    allCharacters={},
    selectedProgressPage='basics',
    pearlTrackerReady=false,
    pearlTrackerError='',
}

local function LoadoutFilePath()
    local characterName = mq.TLO.Me.CleanName() or mq.TLO.Me.Name() or 'Character'
    local serverName = mq.TLO.EverQuest.Server() or 'Server'
    characterName = characterName:gsub('[^%w_-]','_')
    serverName = serverName:gsub('[^%w_-]','_')
    return string.format(
        '%s\\WardenRingLoadouts_%s_%s.txt',
        mq.configDir,
        serverName,
        characterName
    )
end

local function EncodeText(value)
    return (value:gsub('.',function(char)
        return string.format('%02X',string.byte(char))
    end))
end

local function DecodeText(value)
    return (value:gsub('(%x%x)',function(byte)
        return string.char(tonumber(byte,16))
    end))
end

local function ProgressFilePath()
    local characterName = mq.TLO.Me.CleanName() or mq.TLO.Me.Name() or 'Character'
    local serverName = mq.TLO.EverQuest.Server() or 'Server'
    characterName = characterName:gsub('[^%w_-]','_')
    serverName = serverName:gsub('[^%w_-]','_')
    return string.format(
        '%s\\WardenCompanionProgress_%s_%s.txt',
        mq.configDir,
        serverName,
        characterName
    )
end

local function ProgressKey(categoryIndex,tierIndex,targetIndex)
    return string.format('%d:%d:%d',categoryIndex,tierIndex,targetIndex)
end

local function CountTargets(instance)
    local count = 0
    for _ in string.gmatch(instance.content,'([^|]+)') do
        count = count + 1
    end
    return count
end

local function FindAltCurrency(name)
    local normalizedName = name:lower()
    for _,currency in ipairs(State.altCurrencies) do
        if currency.name:lower() == normalizedName then
            return currency
        end
    end
    return nil
end

local function LoadProgress()
    local file,openError = io.open(ProgressFilePath(),'r')

    if not file then
        if openError
        and not openError:find('No such file',1,true)
        and not openError:lower():find('cannot find the file',1,true)
        then
            State.progressStatus = 'Could not load saved progress: '..openError
        end
        return
    end

    for line in file:lines() do
        local categoryValue,tierValue,targetValue =
            line:match('^T|(%d+)|(%d+)|(%d+)$')
        if categoryValue and tierValue and targetValue then
            local categoryIndex = tonumber(categoryValue)
            local tierIndex = tonumber(tierValue)
            local targetIndex = tonumber(targetValue)
            local category = InstanceCategories[categoryIndex]
            local tier = category and category.tiers[tierIndex]

            if tier and targetIndex >= 1 and targetIndex <= CountTargets(tier) then
                State.progressDone[ProgressKey(
                    categoryIndex,
                    tierIndex,
                    targetIndex
                )] = true
            end
        else
            local flagIDValue,doneValue,nameHex =
                line:match('^S|(%d+)|([01])|([%x]+)$')

            if flagIDValue and #nameHex > 0 then
                local flagID = tonumber(flagIDValue)
                local name = DecodeText(nameHex)
                if flagID and name ~= '' then
                    table.insert(State.sideFlags,{
                        id=flagID,
                        name=name,
                        done=doneValue == '1',
                    })
                    State.nextSideFlagID = math.max(
                        State.nextSideFlagID,
                        flagID + 1
                    )
                end
            else
                local autoTrackValue = line:match('^L|([01])$')
                if autoTrackValue then
                    State.autoTrackProgressLogs = autoTrackValue == '1'
                else
                    local currencyHex = line:match('^C|([%x]+)$')
                    if currencyHex then
                        local currencyName = DecodeText(currencyHex)
                        if currencyName ~= '' and not FindAltCurrency(currencyName) then
                            table.insert(State.altCurrencies,{
                                name=currencyName,
                                custom=true,
                            })
                        end
                    end
                end
            end
        end
    end

    file:close()
end

local function SaveProgress()
    local file,openError = io.open(ProgressFilePath(),'w')
    if not file then
        return false,'Could not save progress: '..tostring(openError)
    end

    for categoryIndex,category in ipairs(InstanceCategories) do
        for tierIndex,tier in ipairs(category.tiers) do
            for targetIndex=1,CountTargets(tier) do
                if State.progressDone[ProgressKey(
                    categoryIndex,
                    tierIndex,
                    targetIndex
                )] then
                    local ok,writeError = file:write(string.format(
                        'T|%d|%d|%d\n',
                        categoryIndex,
                        tierIndex,
                        targetIndex
                    ))
                    if not ok then
                        file:close()
                        return false,'Could not write saved progress: '..tostring(writeError)
                    end
                end
            end
        end
    end

    for _,flag in ipairs(State.sideFlags) do
        local ok,writeError = file:write(string.format(
            'S|%d|%d|%s\n',
            flag.id,
            flag.done and 1 or 0,
            EncodeText(flag.name)
        ))
        if not ok then
            file:close()
            return false,'Could not write saved side flags: '..tostring(writeError)
        end
    end

    for _,currency in ipairs(State.altCurrencies) do
        if currency.custom then
            local ok,writeError = file:write('C|'..EncodeText(currency.name)..'\n')
            if not ok then
                file:close()
                return false,'Could not write saved currency list: '..tostring(writeError)
            end
        end
    end

    local autoTrackSaved,autoTrackError = file:write(
        'L|'..(State.autoTrackProgressLogs and '1' or '0')..'\n'
    )
    if not autoTrackSaved then
        file:close()
        return false,'Could not write auto-track setting: '..tostring(autoTrackError)
    end

    local closed,closeError = file:close()
    if not closed then
        return false,'Could not finish saving progress: '..tostring(closeError)
    end

    return true,'Progress saves automatically.'
end

local function LoadLoadouts()
    local file,openError = io.open(LoadoutFilePath(),'r')

    if not file then
        if openError
        and not openError:find('No such file',1,true)
        and not openError:lower():find('cannot find the file',1,true)
        then
            State.status = 'Could not load saved loadouts: '..openError
        end
        return
    end

    for line in file:lines() do
        local nameHex,ringIndex,slotValues =
            line:match('^([%x]*)|(%d+)|([%d,]*)$')

        if nameHex and #nameHex > 0 then
            local slots = {}
            local slotIndex = 0

            for itemID in (slotValues..','):gmatch('(%d*),') do
                slotIndex = slotIndex + 1
                if slotIndex <= 6 then
                    slots[slotIndex] = tonumber(itemID) or 0
                end
            end

            if tonumber(ringIndex) and Rings[tonumber(ringIndex)] then
                table.insert(State.loadouts,{
                    name=DecodeText(nameHex),
                    ringIndex=tonumber(ringIndex),
                    slots=slots,
                })
            end
        end
    end

    file:close()
end

local function SaveLoadouts()
    local file,openError = io.open(LoadoutFilePath(),'w')
    if not file then
        return false,'Could not save loadouts: '..tostring(openError)
    end

    for _,loadout in ipairs(State.loadouts) do
        local slots = {}
        for i=1,6 do
            slots[i] = tostring(tonumber(loadout.slots[i]) or 0)
        end

        local ok,writeError = file:write(string.format(
            '%s|%d|%s\n',
            EncodeText(loadout.name),
            loadout.ringIndex,
            table.concat(slots,',')
        ))

        if not ok then
            file:close()
            return false,'Could not write saved loadouts: '..tostring(writeError)
        end
    end

    local closed,closeError = file:close()
    if not closed then
        return false,'Could not finish saving loadouts: '..tostring(closeError)
    end

    return true
end

local function GetRingPosition(id)
    for i,v in ipairs(Rings) do
        if v.id == id then
            return i
        end
    end
    return nil
end

local function GetEquippedRing()

    local left = mq.TLO.Me.Inventory('leftfinger')

    if left() then
        local pos = GetRingPosition(left.ID())
        if pos then
            return left,pos,'leftfinger'
        end
    end

    local right = mq.TLO.Me.Inventory('rightfinger')

    if right() then
        local pos = GetRingPosition(right.ID())
        if pos then
            return right,pos,'rightfinger'
        end
    end

    return nil,nil,nil
end

local function RefreshRing()

    local ring,pos = GetEquippedRing()

    if not ring then
        return
    end

    State.currentIndex = pos
end

local function MightAtLevel(level)
    level = math.floor(tonumber(level) or 0)

    if level <= 44 then
        return 0
    end

    if level > 72 then
        return LevelMight[72]
    end

    return LevelMight[level] or 0
end

local function RefreshParty()

    local oldWardenRanks = {}
    local oldMembers = {}

    for _,member in ipairs(State.party) do
        if member.name then
            oldMembers[member.name] = member
        end

        if member.name and not member.isMe then
            oldWardenRanks[member.name] = member.warden or 0
        end
    end

    local party = {}
    local meName = mq.TLO.Me.Name()
    local meLevel = mq.TLO.Me.Level() or 0
    local meRing = GetEquippedRing()
    local meWarden = meRing and Rings[State.currentIndex].warden or 0
    local oldMe = oldMembers[meName]

    table.insert(party,{
        name=meName,
        level=meLevel,
        warden=meWarden,
        moonPet=oldMe and oldMe.moonPet or 0,
        isMe=true,
    })

    local function addMember(name,level)
        if not name or name == '' or name == meName or #party >= 24 then
            return
        end

        for _,existing in ipairs(party) do
            if existing.name == name then
                return
            end
        end

        table.insert(party,{
            name=name,
            level=tonumber(level) or 0,
            warden=oldWardenRanks[name] or 0,
            moonPet=oldMembers[name] and oldMembers[name].moonPet or 0,
            isMe=false,
        })
    end

    local raidMembers = mq.TLO.Raid.Members() or 0

    if raidMembers > 0 then
        for i=1,raidMembers do
            local member = mq.TLO.Raid.Member(i)

            if member() then
                addMember(member.Name(),member.Level())
            end
        end
    else
        local groupSize = mq.TLO.Me.GroupSize() or 0

        for i=1,groupSize-1 do
            local member = mq.TLO.Group.Member(i)

            if member() then
                addMember(member.Name(),member.Level())
            end
        end
    end

    while #party < 24 do
        local index = #party + 1
        local placeholderName = 'Character '..index
        local previous = oldMembers[placeholderName]

        table.insert(party,{
            name=placeholderName,
            level=previous and previous.level or 0,
            warden=previous and previous.warden or 0,
            moonPet=previous and previous.moonPet or 0,
            isMe=false,
        })
    end

    State.party = party
end

local function GetPartyMight(ringIndex)

    local total = 0

    for _,member in ipairs(State.party) do
        local level = member.isMe
            and (mq.TLO.Me.Level() or member.level)
            or member.level
        local baseMight = MightAtLevel(level)
        local wardenRank = member.isMe
            and Rings[ringIndex].warden
            or math.min(math.max(math.floor(member.warden or 0),0),4)
        local moonPetRank = math.min(math.max(math.floor(member.moonPet or 0),0),3)
        local moonPetMight = level > 0 and MoonPetBonus[moonPetRank + 1] or 0

        total = total
            + baseMight * (1 + WardenBonus[wardenRank + 1])
            + moonPetMight
    end

    return total
end

local function GetCharacterMight(ringIndex)
    local level = mq.TLO.Me.Level() or 0
    local baseMight = MightAtLevel(level)
    local moonPetRank = State.party[1]
        and math.min(math.max(math.floor(State.party[1].moonPet or 0),0),3)
        or 0
    local moonPetMight = level > 0 and MoonPetBonus[moonPetRank + 1] or 0

    return baseMight * (1 + WardenBonus[Rings[ringIndex].warden + 1])
        + moonPetMight
end

local function FormatMight(value)
    return string.format('%g',value)
end

local function GetRingIconID(ringIndex)
    local ring = Rings[ringIndex]

    if ring.icon then
        return ring.icon
    end

    local equippedRing = GetEquippedRing()
    if equippedRing and equippedRing.ID() == ring.id then
        return equippedRing.Icon()
    end

    local item = mq.TLO.FindItem(ring.id)
    if item() then
        return item.Icon()
    end

    return nil
end

local function DrawRingIcon(ringIndex,size)
    local iconID = GetRingIconID(ringIndex)

    if iconID and iconID > 0 then
        itemIcons:SetTextureCell(iconID - ITEM_ICON_OFFSET)
        ImGui.DrawTextureAnimation(itemIcons,size,size)
        return true
    end

    return false
end

local function NavigateToPietri()

    local pietri = mq.TLO.Spawn('npc Pietri')

    if not pietri() then
        return false,'Pietri not found in this zone'
    end

    local pietriID = pietri.ID()

    if pietri.Distance3D() > 15 then
        if not mq.TLO.Plugin('MQ2Nav').IsLoaded() then
            return false,'MQ2Nav is not loaded'
        end

        State.status = 'Navigating to Pietri'
        mq.cmdf('/target id %d',pietriID)
        mq.delay(200)
        mq.cmdf('/nav id %d dist=12',pietriID)

        local start = mq.gettime()

        while pietri()
        and pietri.Distance3D() > 12
        and mq.gettime()-start < 30000
        do
            mq.delay(200)
        end

        mq.cmd('/nav stop')
        mq.delay(250)

        if not pietri() or pietri.Distance3D() > 15 then
            return false,'Could not reach Pietri'
        end
    end

    mq.cmdf('/target id %d',pietriID)
    mq.delay(100)

    if mq.TLO.Target.ID() ~= pietriID then
        return false,'Could not target Pietri'
    end

    return true
end

local function AcceptConfirmationIfOpen(timeoutMs)
    local confirmation =
        mq.TLO.Window('ConfirmationDialogBox')

    if not confirmation.Open() then
        return true
    end

    mq.cmd('/notify ConfirmationDialogBox Yes_Button leftmouseup')

    local start = mq.gettime()

    while confirmation.Open() do
        if mq.gettime()-start > timeoutMs then
            return false
        end

        mq.delay(25)
    end

    return true
end

local function AutoInventoryUntilClear(timeoutMs)

    local start = mq.gettime()

    while (mq.TLO.Cursor.ID() or 0) > 0 do
        if mq.gettime()-start > timeoutMs then
            return false
        end

        mq.cmd('/autoinventory')
        mq.delay(25)
    end

    return true
end

local function RemoveAugs()

    local ring = GetEquippedRing()

    if not ring then
        return false
    end

    local ringName = ring.Name()

    for i=1,6 do

        local aug = ring.AugSlot(i)
        local augItem = aug.Item

        if aug()
        and not aug.Empty()
        and augItem()
        then

            local augName = augItem.Name()

            mq.cmdf(
                '/removeaug "%s" "%s"',
                augName,
                ringName
            )

            local start = mq.gettime()

            while aug() and not aug.Empty() do
                if mq.gettime()-start > 5000 then
                    return false
                end

                if not AcceptConfirmationIfOpen(1000) then
                    return false
                end

                mq.delay(50)
            end

            mq.cmd('/autoinventory')
            if not AutoInventoryUntilClear(3000) then
                return false
            end

        end
    end

    return true
end

local function FindItemInPackByID(itemID)

    for i=1,mq.TLO.Me.NumBagSlots() do

        local pack = mq.TLO.Me.Inventory('pack'..i)

        if pack() and pack.ID() then
            if pack.ID() == itemID then
                return true,i,0
            end

            local containerSize = pack.Container()

            if containerSize then
                for j=1,containerSize do
                    local item = pack.Item(j)

                    if item() and item.ID() == itemID then
                        return true,i,j
                    end
                end
            end
        end
    end

    return false,-1,-1
end

local function DecodeAugTypes(rawValue)
    local numeric = tonumber(rawValue) or 0
    local types = {}

    if numeric <= 0 then
        return types
    end

    if numeric <= 64 then
        types[1] = numeric
        return types
    end

    local typeID = 1
    numeric = math.floor(numeric)
    while numeric > 0 and typeID <= 64 do
        local bit = numeric % 2
        if bit == 1 then
            table.insert(types,typeID)
        end
        numeric = (numeric - bit) / 2
        typeID = typeID + 1
    end

    return types
end

local function AugTypesMatch(candidateTypes,slotType)
    for _,typeID in ipairs(candidateTypes or {}) do
        if typeID == tonumber(slotType) then
            return true
        end
    end
    return false
end

local function GetRingItem(ringIndex)
    local equipped = GetEquippedRing()
    if equipped and equipped.ID() == Rings[ringIndex].id then
        return equipped
    end

    local item = mq.TLO.FindItem(Rings[ringIndex].id)
    if item() then
        return item
    end

    return nil
end

local function GetRingSlotInfo(ringIndex)
    local ring = GetRingItem(ringIndex)
    local slots = {}

    for index=1,6 do
        local slot = ring and ring.AugSlot(index) or nil
        local item = slot and slot.Item or nil
        slots[index] = {
            index=index,
            type=slot and (slot.Type() or 0) or 0,
            visible=slot and slot.Visible() or false,
            itemID=item and item() and item.ID() or 0,
            itemName=item and item() and item.Name() or '',
        }
    end

    return ring,slots
end

local function ScanAvailableAugs()
    local itemsByID = {}

    local function addAug(item,source)
        if not item or not item() or not item.ID() then
            return
        end

        local itemID = item.ID()
        local augTypes = DecodeAugTypes(item.AugType() or 0)
        if #augTypes == 0 then
            return
        end

        local candidate = itemsByID[itemID]
        if not candidate then
            candidate = {
                id=itemID,
                count=1,
                name=item.Name() or ('Aug '..itemID),
                icon=item.Icon() or 0,
                augTypes=augTypes,
                item=item,
                source=source,
                ac=item.AC() or 0,
                hp=item.HP() or 0,
                mana=item.Mana() or 0,
                endur=item.Endurance() or 0,
                str=item.STR() or 0,
                sta=item.STA() or 0,
                agi=item.AGI() or 0,
                dex=item.DEX() or 0,
                wis=item.WIS() or 0,
                int=item.INT() or 0,
                cha=item.CHA() or 0,
                heroicStr=item.HeroicSTR() or 0,
                heroicSta=item.HeroicSTA() or 0,
                heroicAgi=item.HeroicAGI() or 0,
                heroicDex=item.HeroicDEX() or 0,
                heroicWis=item.HeroicWIS() or 0,
                heroicInt=item.HeroicINT() or 0,
                heroicCha=item.HeroicCHA() or 0,
            }
            itemsByID[itemID] = candidate
        else
            candidate.count = candidate.count + 1
            if source == 'Bags' then
                candidate.item = item
                candidate.source = source
            end
        end
    end

    for bagIndex=1,mq.TLO.Me.NumBagSlots() do
        local bag = mq.TLO.Me.Inventory('pack'..bagIndex)
        if bag() then
            addAug(bag,'Bags')

            for slotIndex=1,(bag.Container() or 0) do
                addAug(bag.Item(slotIndex),'Bags')
            end
        end
    end

    local equippedRing = GetEquippedRing()
    if equippedRing then
        for index=1,6 do
            local slot = equippedRing.AugSlot(index)
            local augItem = slot.Item
            if slot() and not slot.Empty() and augItem() then
                addAug(augItem,'Equipped ring')
            end
        end
    end

    State.availableAugs = {}
    for _,candidate in pairs(itemsByID) do
        table.insert(State.availableAugs,candidate)
    end
    table.sort(State.availableAugs,function(a,b)
        return a.name:lower() < b.name:lower()
    end)

    State.inventoryDirty = false
    return #State.availableAugs
end

local function FindAvailableAug(itemID)
    for _,candidate in ipairs(State.availableAugs) do
        if candidate.id == itemID then
            return candidate
        end
    end
    return nil
end

local function HandInOnce(expectedIndex,nextIndex)

    local ring,currentIndex,slot = GetEquippedRing()

    if not ring or currentIndex ~= expectedIndex then
        return false
    end

    local nextRingID = Rings[nextIndex].id
    local currentRingID = Rings[expectedIndex].id

    if (mq.TLO.Cursor.ID() or 0) > 0 then
        return false
    end

    mq.cmdf('/ctrl /itemnotify %s leftmouseup', slot)

    local start = mq.gettime()

    while (mq.TLO.Cursor.ID() or 0) == 0 do
        if mq.gettime()-start > 5000 then
            return false
        end
        mq.delay(10)
    end

    if mq.TLO.Cursor.ID() ~= currentRingID then
        mq.cmd('/autoinventory')
        return false
    end

    mq.cmd('/click left target')

    start = mq.gettime()

    while (mq.TLO.Cursor.ID() or 0) > 0 do
        if mq.gettime()-start > 10000 then
            AutoInventoryUntilClear(3000)
            return false
        end
        mq.delay(10)
    end

    mq.cmd('/notify GiveWnd GVW_Give_Button leftmouseup')

    start = mq.gettime()

    while (mq.TLO.Cursor.ID() or 0) == 0 do
        if mq.gettime()-start > 5000 then
            return false
        end
        mq.delay(10)
    end

    if mq.TLO.Cursor.ID() ~= nextRingID then
        AutoInventoryUntilClear(3000)
        return false
    end

    if not AutoInventoryUntilClear(10000) then
        return false
    end

    local equippedRing,equippedIndex = GetEquippedRing()

    if equippedRing
    and equippedRing.ID() == nextRingID
    and equippedIndex == nextIndex
    then
        return true
    end

    start = mq.gettime()

    local found,packID,slotID =
        FindItemInPackByID(nextRingID)

    while not found do
        if mq.gettime()-start > 10000 then
            return false
        end

        mq.delay(50)
        found,packID,slotID =
            FindItemInPackByID(nextRingID)
    end

    if slotID > 0 then
        mq.cmdf(
            '/itemnotify in pack%d %d leftmouseup',
            packID,
            slotID
        )
    else
        mq.cmdf(
            '/itemnotify pack%d leftmouseup',
            packID
        )
    end

    start = mq.gettime()

    while not mq.TLO.Cursor() do
        if mq.gettime()-start > 5000 then
            return false
        end
        mq.delay(10)
    end

    if mq.TLO.Cursor.ID() ~= nextRingID then
        AutoInventoryUntilClear(3000)
        return false
    end

    mq.cmdf('/itemnotify %s leftmouseup', slot)

    start = mq.gettime()

    while (mq.TLO.Cursor.ID() or 0) > 0 do
        if mq.gettime()-start > 5000 then
            AutoInventoryUntilClear(3000)
            return false
        end
        mq.delay(10)
    end

    mq.delay(100)

    equippedRing,equippedIndex = GetEquippedRing()

    return equippedRing ~= nil
        and equippedRing.ID() == nextRingID
        and equippedIndex == nextIndex
end

local function HandinsNeeded(current,target)

    if current == target then
        return 0
    end

    if target > current then
        return target-current
    end

    return (#Rings-current)+target
end

local function RingHasAug(ring,itemID)

    for i=1,6 do
        local aug = ring.AugSlot(i)
        local augItem = aug.Item

        if aug()
        and not aug.Empty()
        and augItem()
        and augItem.ID() == itemID
        then
            return true,i
        end
    end

    return false,nil
end

local function InstallSelectedAugs()

    local ring = GetEquippedRing()

    if not ring then
        return false,'No Warden ring equipped'
    end

    local ringID = ring.ID()

    for _,aug in ipairs(State.savedAugs) do
        local found,packID,slotID = FindItemInPackByID(aug.id)

        if not found then
            return false,'Selected aug missing from bags: '..aug.name
        end

        if slotID > 0 then
            mq.cmdf(
                '/itemnotify in pack%d %d leftmouseup',
                packID,
                slotID
            )
        else
            mq.cmdf(
                '/itemnotify pack%d leftmouseup',
                packID
            )
        end

        local start = mq.gettime()
        while (mq.TLO.Cursor.ID() or 0) ~= aug.id do
            if mq.gettime()-start > 3000 then
                return false,'Could not pick up aug: '..aug.name
            end
            mq.delay(25)
        end

        mq.cmdf('/insertaug %d',ringID)

        start = mq.gettime()
        local installed,actualSlot = false,nil
        while mq.gettime()-start < 5000 do
            if not AcceptConfirmationIfOpen(1000) then
                return false,'Confirmation did not close for aug: '..aug.name
            end

            local equippedRing = GetEquippedRing()
            if equippedRing and equippedRing.ID() == ringID then
                installed,actualSlot = RingHasAug(equippedRing,aug.id)
                if installed then
                    break
                end
            end

            mq.delay(25)
        end

        if not installed then
            return false,'Aug was not installed: '..aug.name
        end

        if actualSlot ~= aug.slot then
            return false,string.format(
                '%s went into slot %d, not selected slot %d; stopped',
                aug.name,
                actualSlot + 1,
                aug.slot
            )
        end
    end

    mq.cmd('/autoinventory')

    if not AutoInventoryUntilClear(3000) then
        return false,'Item remains on cursor after aug installation'
    end

    return true
end

local function Execute()

    RefreshRing()

    local ring = GetEquippedRing()

    if not ring then
        State.status = 'No Warden ring equipped'
        return
    end

    if (mq.TLO.Cursor.ID() or 0) > 0 then
        State.status = 'Clear the cursor before swapping'
        return
    end

    local handinCount = HandinsNeeded(State.currentIndex,State.targetIndex)
    if handinCount == 0 then
        local expectedAugs = {}
        for _,aug in ipairs(State.savedAugs) do
            expectedAugs[aug.slot] = aug.id
        end

        local matches = true
        for slotIndex=1,6 do
            local slot = ring.AugSlot(slotIndex)
            local augItem = slot.Item
            local actualID = slot() and not slot.Empty() and augItem()
                and augItem.ID() or 0
            if actualID ~= (expectedAugs[slotIndex] or 0) then
                matches = false
                break
            end
        end

        if matches then
            State.status = 'Ring already matches this loadout'
            return
        end
    end

    if handinCount > 0 then
        local reachedPietri,navigationError = NavigateToPietri()

        if not reachedPietri then
            State.status = navigationError
            return
        end
    end

    State.inventoryDirty = true
    State.status = 'Removing augs'
    if not RemoveAugs() then
        State.status = 'Failed to remove all augs; hand-in cancelled'
        return
    end

    State.status =
        string.format(
            'Handing in %d times',
            handinCount
        )

    for i=1,handinCount do

        local nextIndex = State.currentIndex % #Rings + 1
        State.status = string.format(
            'Handing in %d of %d (%s)',
            i,
            handinCount,
            Rings[nextIndex].name
        )

        local success = HandInOnce(State.currentIndex,nextIndex)

        if not success then
            State.status='Hand-in failed; stopped before next step'
            return
        end

        State.currentIndex = nextIndex
    end

    State.status='Installing augs'

    local installed,installError = InstallSelectedAugs()

    if not installed then
        State.status = installError
        return
    end

    State.status='Complete'

end

local function DrawCombo(label,current,choices,id)

    local preview = choices[current] or choices[1] or ''

    if ImGui.BeginCombo(label,preview) then
        for i,choice in ipairs(choices) do
            if ImGui.Selectable(
                choice..'##'..id..i,
                i == current
            ) then
                current = i
            end
        end

        ImGui.EndCombo()
    end

    return current
end

local function GetInstanceTargets(instance)
    local targets = {}

    for target in string.gmatch(instance.content,'([^|]+)') do
        target = target:gsub('^%s+',''):gsub('%s+$','')
        table.insert(targets,target)
    end

    return targets
end

local function LoadDraft(loadoutIndex)
    local loadout = State.loadouts[loadoutIndex]
    if not loadout then
        State.selectedLoadout = 0
        State.loadoutName = ''
        State.draftRingIndex = State.targetIndex
        State.draftSlots = {}
        return
    end

    State.selectedLoadout = loadoutIndex
    State.loadoutName = loadout.name
    State.draftRingIndex = loadout.ringIndex
    State.targetIndex = loadout.ringIndex
    State.inventoryDirty = true
    State.draftSlots = {}
    for i=1,6 do
        State.draftSlots[i] = tonumber(loadout.slots[i]) or 0
    end
end

local function LoadDraftFromEquippedRing()
    local ring = GetEquippedRing()
    State.draftRingIndex = ring and State.currentIndex or State.targetIndex
    State.targetIndex = State.draftRingIndex
    State.draftSlots = {}

    if ring then
        for index=1,6 do
            local slot = ring.AugSlot(index)
            local augItem = slot.Item
            if slot() and not slot.Empty() and augItem() then
                State.draftSlots[index] = augItem.ID()
            end
        end
    end
end

local function SaveDraftAsLoadout()
    local name = (State.loadoutName or ''):gsub('^%s+',''):gsub('%s+$','')
    if name == '' then
        return false,'Enter a name for this loadout'
    end

    local ring,slots = GetRingSlotInfo(State.draftRingIndex)
    if not ring then
        return false,'The selected ring must be in your inventory or equipped to inspect its aug slots'
    end

    local savedSlots = {}
    local selectedCounts = {}
    for i=1,6 do
        local itemID = tonumber(State.draftSlots[i]) or 0
        savedSlots[i] = itemID
        if itemID > 0 then
            local candidate = FindAvailableAug(itemID)
            if not candidate then
                return false,'Refresh inventory; a selected augment is no longer available'
            end
            selectedCounts[itemID] = (selectedCounts[itemID] or 0) + 1
            if selectedCounts[itemID] > candidate.count then
                return false,'Not enough copies of '..candidate.name..' are available'
            end

            if slots[i].type <= 0 or not AugTypesMatch(candidate.augTypes,slots[i].type) then
                return false,string.format('%s does not fit aug slot %d',candidate.name,i)
            end

            for earlier=1,i-1 do
                if (savedSlots[earlier] or 0) == 0
                and AugTypesMatch(candidate.augTypes,slots[earlier].type)
                then
                    return false,string.format(
                        '%s could be inserted into empty slot %d instead; fill that slot first',
                        candidate.name,
                        earlier
                    )
                end
            end
        end
    end

    local foundIndex
    for i,loadout in ipairs(State.loadouts) do
        if loadout.name:lower() == name:lower() then
            foundIndex = i
            break
        end
    end

    local loadout = {
        name=name,
        ringIndex=State.draftRingIndex,
        slots=savedSlots,
    }

    if foundIndex then
        State.loadouts[foundIndex] = loadout
    else
        table.insert(State.loadouts,loadout)
        foundIndex = #State.loadouts
    end

    local saved,saveError = SaveLoadouts()
    if not saved then
        return false,saveError
    end

    LoadDraft(foundIndex)
    return true,'Saved loadout: '..name
end

local function RemoveSelectedLoadout()
    if not State.loadouts[State.selectedLoadout] then
        return false,'Select a saved loadout to delete'
    end

    table.remove(State.loadouts,State.selectedLoadout)
    local saved,saveError = SaveLoadouts()
    if not saved then
        return false,saveError
    end

    LoadDraft(0)
    State.inventoryDirty = true
    return true,'Loadout deleted'
end

local function PrepareSelectedAugs()
    local _,slots = GetRingSlotInfo(State.draftRingIndex)
    local selected = {}
    local selectedCounts = {}

    for slotIndex=1,6 do
        local itemID = tonumber(State.draftSlots[slotIndex]) or 0
        if itemID > 0 then
            local candidate = FindAvailableAug(itemID)
            if not candidate then
                return false,'Selected augment is not available; refresh inventory'
            end
            selectedCounts[itemID] = (selectedCounts[itemID] or 0) + 1
            if selectedCounts[itemID] > candidate.count then
                return false,'Not enough copies of '..candidate.name..' are available'
            end
            if not AugTypesMatch(candidate.augTypes,slots[slotIndex].type) then
                return false,string.format('%s does not fit aug slot %d',candidate.name,slotIndex)
            end

            for earlier=1,slotIndex-1 do
                if (tonumber(State.draftSlots[earlier]) or 0) == 0
                and AugTypesMatch(candidate.augTypes,slots[earlier].type)
                then
                    return false,string.format(
                        '%s could be inserted into empty slot %d instead; fill that slot first',
                        candidate.name,
                        earlier
                    )
                end
            end

            table.insert(selected,{
                id=itemID,
                name=candidate.name,
                slot=slotIndex,
            })
        end
    end

    State.savedAugs = selected
    State.targetIndex = State.draftRingIndex
    return true
end

local function GetCandidateStats(candidate)
    local values = {}
    if candidate.ac ~= 0 then table.insert(values,'AC '..candidate.ac) end
    if candidate.hp ~= 0 then table.insert(values,'HP '..candidate.hp) end
    if candidate.mana ~= 0 then table.insert(values,'Mana '..candidate.mana) end
    if candidate.endur ~= 0 then table.insert(values,'End '..candidate.endur) end
    return #values > 0 and table.concat(values,'  ') or 'No AC / HP / Mana / Endurance'
end

local function GetCandidateTooltip(candidate)
    local values = {GetCandidateStats(candidate)}
    for _,stat in ipairs({
        {'STR',candidate.str},
        {'STA',candidate.sta},
        {'AGI',candidate.agi},
        {'DEX',candidate.dex},
        {'WIS',candidate.wis},
        {'INT',candidate.int},
        {'CHA',candidate.cha},
        {'HSTR',candidate.heroicStr},
        {'HSTA',candidate.heroicSta},
        {'HAGI',candidate.heroicAgi},
        {'HDEX',candidate.heroicDex},
        {'HWIS',candidate.heroicWis},
        {'HINT',candidate.heroicInt},
        {'HCHA',candidate.heroicCha},
    }) do
        if stat[2] ~= 0 then
            table.insert(values,stat[1]..' '..stat[2])
        end
    end
    return table.concat(values,'  ')
end

local function DrawAugCandidate(candidate,categoryType)
    ImGui.PushID(string.format('aug_%d_%d',candidate.id,categoryType))

    if candidate.icon and candidate.icon > 0 then
        itemIcons:SetTextureCell(candidate.icon - ITEM_ICON_OFFSET)
        ImGui.DrawTextureAnimation(itemIcons,20,20)
        ImGui.SameLine()
    end

    local selected = State.draftSlots[State.selectedAugSlot] == candidate.id
    if ImGui.Selectable(
        candidate.name..'##candidate',
        selected,
        ImGuiSelectableFlags.SpanAvailWidth
    ) then
        local _,slots = GetRingSlotInfo(State.draftRingIndex)
        local slotType = slots[State.selectedAugSlot].type
        if AugTypesMatch(candidate.augTypes,slotType) then
            State.draftSlots[State.selectedAugSlot] = candidate.id
        else
            State.status = candidate.name..' does not fit this slot'
        end
    end

    if ImGui.IsItemHovered() then
        ImGui.SetTooltip(
            '%s\n%s\n%s',
            candidate.name,
            GetCandidateTooltip(candidate),
            candidate.source
        )
    end

    if ImGui.IsItemClicked(ImGuiMouseButton.Right) and candidate.item.ItemLink then
        local link = candidate.item.ItemLink('CLICKABLE')()
        if link and link ~= '' then
            mq.cmdf('/executelink %s',link)
        end
    end

    ImGui.SameLine()
    ImGui.TextDisabled(GetCandidateStats(candidate))
    ImGui.PopID()
end

local function DrawLoadoutEditor()
    if State.inventoryDirty then
        ScanAvailableAugs()
    end

    local loadoutNames = {'New loadout'}
    for _,loadout in ipairs(State.loadouts) do
        table.insert(loadoutNames,loadout.name)
    end

    local selectedOption = State.selectedLoadout + 1
    local newSelectedOption = DrawCombo(
        'Saved loadout',
        selectedOption,
        loadoutNames,
        'loadout'
    )
    if newSelectedOption ~= selectedOption then
        LoadDraft(newSelectedOption - 1)
    end

    local targetRing,slotInfo = GetRingSlotInfo(State.draftRingIndex)
    if not targetRing then
        ImGui.TextColored(1,0.65,0.3,1,'Have this ring in inventory or equipped to configure its aug slots.')
    end

    if ImGui.BeginTable(
        '##ring_aug_slots',
        3,
        ImGuiTableFlags.Borders + ImGuiTableFlags.RowBg,
        0,
        156
    ) then
        ImGui.TableSetupColumn('Slot',ImGuiTableColumnFlags.WidthFixed,100)
        ImGui.TableSetupColumn('Augment',ImGuiTableColumnFlags.WidthStretch)
        ImGui.TableSetupColumn('Action',ImGuiTableColumnFlags.WidthFixed,55)
        ImGui.TableHeadersRow()

        for i=1,6 do
            local slot = slotInfo[i]
            ImGui.TableNextRow()

            ImGui.TableSetColumnIndex(0)
            local isActive = State.selectedAugSlot == i
            if ImGui.Selectable(
                string.format('Slot %d##select_aug_slot_%d',i,i),
                isActive,
                ImGuiSelectableFlags.SpanAvailWidth
            ) then
                State.selectedAugSlot = i
            end
            ImGui.TextDisabled(slot.type > 0 and ('Type '..slot.type) or 'Unavailable')

            ImGui.TableSetColumnIndex(1)
            local itemID = tonumber(State.draftSlots[i]) or 0
            local candidate = itemID > 0 and FindAvailableAug(itemID) or nil
            if candidate then
                if candidate.icon and candidate.icon > 0 then
                    itemIcons:SetTextureCell(candidate.icon - ITEM_ICON_OFFSET)
                    ImGui.DrawTextureAnimation(itemIcons,18,18)
                    ImGui.SameLine()
                end
                ImGui.Text(candidate.name)
                ImGui.SameLine()
                ImGui.TextDisabled(GetCandidateStats(candidate))
            else
                ImGui.TextDisabled('Empty')
            end

            ImGui.TableSetColumnIndex(2)
            if itemID > 0 and ImGui.SmallButton('Clear##slot_'..i) then
                State.draftSlots[i] = 0
            end
        end

        ImGui.EndTable()
    end

    local _,slots = GetRingSlotInfo(State.draftRingIndex)
    local activeSlot = slots[State.selectedAugSlot]
    ImGui.Text(string.format(
        'Choose an augment for slot %d (type %s)',
        State.selectedAugSlot,
        activeSlot.type > 0 and tostring(activeSlot.type) or 'unavailable'
    ))

    State.fitSelectedSlot = ImGui.Checkbox(
        'Show only augs that fit selected slot',
        State.fitSelectedSlot
    )
    ImGui.SameLine()
    if ImGui.Button('Refresh inventory##augs') then
        ScanAvailableAugs()
    end

    local byType = {}
    for _,candidate in ipairs(State.availableAugs) do
        for _,typeID in ipairs(candidate.augTypes) do
            if not State.fitSelectedSlot or AugTypesMatch(candidate.augTypes,activeSlot.type) then
                byType[typeID] = byType[typeID] or {}
                table.insert(byType[typeID],candidate)
            end
        end
    end

    local sortedTypes = {}
    for typeID in pairs(byType) do
        table.insert(sortedTypes,typeID)
    end
    table.sort(sortedTypes)

    if #sortedTypes == 0 then
        ImGui.TextDisabled(State.fitSelectedSlot
            and 'No matching augs found in bags or the equipped ring.'
            or 'No augs found in bags or the equipped ring.')
    else
        for _,typeID in ipairs(sortedTypes) do
            local candidates = byType[typeID]
            if ImGui.CollapsingHeader(string.format(
                'Aug type %d (%d)##aug_type_%d',
                typeID,
                #candidates,
                typeID
            )) then
                for _,candidate in ipairs(candidates) do
                    DrawAugCandidate(candidate,typeID)
                end
            end
        end
    end

    State.loadoutName = ImGui.InputText(
        'Loadout name',
        State.loadoutName or '',
        64
    )

    if ImGui.Button('Save loadout') then
        local saved,message = SaveDraftAsLoadout()
        State.status = message
    end

    if State.selectedLoadout > 0 then
        ImGui.SameLine()
        if ImGui.SmallButton('Delete loadout') then
            local deleted,message = RemoveSelectedLoadout()
            State.status = message
        end
    end
end

local function DrawPartyMight()

    if ImGui.Button('Refresh Party') then
        RefreshParty()
    end

    ImGui.SameLine()
    ImGui.TextDisabled('Up to 24 characters; edit other members below.')

    if ImGui.BeginTable(
        '##might_party',
        4,
        ImGuiTableFlags.Borders
            + ImGuiTableFlags.RowBg
            + ImGuiTableFlags.ScrollY,
        0,
        190
    ) then
        ImGui.TableSetupColumn('Party member',ImGuiTableColumnFlags.WidthStretch)
        ImGui.TableSetupColumn('Level',ImGuiTableColumnFlags.WidthFixed,80)
        ImGui.TableSetupColumn('Warden',ImGuiTableColumnFlags.WidthFixed,120)
        ImGui.TableSetupColumn('Moon Pets',ImGuiTableColumnFlags.WidthFixed,120)
        ImGui.TableHeadersRow()

        for i,member in ipairs(State.party) do
            ImGui.TableNextRow()

            ImGui.TableSetColumnIndex(0)
            ImGui.Text(member.name)

            ImGui.TableSetColumnIndex(1)
            if member.isMe then
                member.level = mq.TLO.Me.Level() or member.level
                ImGui.Text(tostring(member.level))
            else
                member.level = ImGui.InputInt(
                    '##might_level_'..i,
                    member.level,
                    1,
                    1
                )
                member.level = math.min(math.max(member.level or 0,0),72)
            end

            ImGui.TableSetColumnIndex(2)
            if member.isMe then
                ImGui.Text(WardenLabels[Rings[State.currentIndex].warden + 1])
            else
                member.warden = DrawCombo(
                    '##might_warden_'..i,
                    (member.warden or 0) + 1,
                    WardenLabels,
                    'warden'
                ) - 1
            end

            ImGui.TableSetColumnIndex(3)
            member.moonPet = DrawCombo(
                '##might_moonpet_'..i,
                (member.moonPet or 0) + 1,
                MoonPetLabels,
                'moonpet'
            ) - 1
        end

        ImGui.EndTable()
    end
end

local function DrawDifficultyEstimate(instance,currentMight,projectedMight)

    if instance.auto == true then
        ImGui.Text('Automatic difficulty - estimated thresholds:')
    elseif instance.auto == 'selected' then
        ImGui.Text('Selected instances use automatic difficulty - estimated thresholds:')
    end

    if instance.auto then
        for _,mode in ipairs(DifficultyModes) do
            local required = math.floor(instance.might * mode.multiplier + 0.5)
            local currentReady = currentMight >= required
            local projectedReady = projectedMight >= required
            local status = string.format(
                '%s  |  Might %s  |  Current %s  |  Selected ring %s',
                mode.name,
                FormatMight(required),
                currentReady and 'meets' or 'below',
                projectedReady and 'meets' or 'below'
            )
            local color = projectedReady and 0.45 or 0.72
            ImGui.TextColored(color,projectedReady and 0.95 or 0.72,0.55,1,status)
        end

        ImGui.TextDisabled('Workbook multiplier estimates only; automatic modes are determined by the instance, not selected.')
    else
        ImGui.Text('Available modes: '..table.concat(DifficultyLabels,', '))
        ImGui.TextDisabled('These are player-selected for this tier; exact Might thresholds are not modeled.')
    end
end

local function DrawMightUI()

    local categoryNames = {}
    for i,category in ipairs(InstanceCategories) do
        categoryNames[i] = category.name
    end

    local previousCategory = State.instanceCategory
    State.instanceCategory = DrawCombo(
        'Instance type',
        State.instanceCategory,
        categoryNames,
        'category'
    )

    if State.instanceCategory ~= previousCategory then
        State.instanceTier = 1
        State.instanceTarget = 1
    end

    local category = InstanceCategories[State.instanceCategory]
    local tierNames = {}
    for i,instance in ipairs(category.tiers) do
        tierNames[i] = instance.name
    end

    State.instanceTier = math.min(State.instanceTier,#tierNames)
    local previousTier = State.instanceTier
    State.instanceTier = DrawCombo(
        'Dungeon / tier',
        State.instanceTier,
        tierNames,
        'tier'
    )

    if State.instanceTier ~= previousTier then
        State.instanceTarget = 1
    end

    local instance = category.tiers[State.instanceTier]
    local targets = GetInstanceTargets(instance)
    State.instanceTarget = math.min(State.instanceTarget,#targets)
    State.instanceTarget = DrawCombo(
        'Dungeon / target',
        State.instanceTarget,
        targets,
        'target'
    )
    local currentMight = GetPartyMight(State.currentIndex)
    local projectedMight = GetPartyMight(State.targetIndex)
    local currentCharacterMight = GetCharacterMight(State.currentIndex)
    local projectedCharacterMight = GetCharacterMight(State.targetIndex)
    local requirement = instance.might or 0
    local progress = requirement > 0
        and math.min(projectedMight / requirement,1)
        or 1

    ImGui.Separator()
    ImGui.TextColored(0.35,0.82,1,1,'MIGHT ESTIMATE')
    ImGui.Text(string.format(
        'Your Might: %s    With selected ring: %s',
        FormatMight(currentCharacterMight),
        FormatMight(projectedCharacterMight)
    ))
    ImGui.Text(string.format(
        'Party Might: %s    With selected ring: %s',
        FormatMight(currentMight),
        FormatMight(projectedMight)
    ))

    if requirement > 0 then
        ImGui.ProgressBar(
            progress,
            -1,
            0,
            string.format(
                '%s / %s suggested Might',
                FormatMight(projectedMight),
                FormatMight(requirement)
            )
        )
        ImGui.Text('Suggested Might: '..FormatMight(requirement))
    else
        ImGui.Text('Suggested Might: not specified')
    end

    if instance.raidMight then
        ImGui.Text('Suggested raid Might: '..FormatMight(instance.raidMight))
    end
    ImGui.TextWrapped('Selected target: '..(targets[State.instanceTarget] or 'Not listed'))

    ImGui.Separator()
    DrawDifficultyEstimate(instance,currentMight,projectedMight)

    ImGui.Separator()
    ImGui.TextDisabled('Estimate sources: eqmight.com/progression and the supplied Might workbook.')
    ImGui.TextDisabled('Assumptions: ring Rank 1-4 grants Warden I-IV; party-composition reductions are excluded.')
end

local function SaveProgressChanges()
    local saved,message = SaveProgress()
    State.progressStatus = message
    if saved then
        State.progressPendingSave = false
        State.progressPendingChanges = 0
    end
    return saved
end

local function GetProgressDisposition(text)
    local lowerText = text:lower()
    local incompleteMarkers = {
        '[ ]',
        'not completed',
        'not complete',
        'incomplete',
        'not done',
        'not cleared',
        'not defeated',
        'not killed',
        'in progress',
        'remaining',
        'still need',
        'not yet',
    }

    for _,marker in ipairs(incompleteMarkers) do
        if lowerText:find(marker,1,true) then
            return false
        end
    end

    if lowerText:find('[x]',1,true) then
        return true
    end

    for _,marker in ipairs({'completed','complete','done','cleared','defeated','killed'}) do
        if lowerText:find('%f[%a]'..marker..'%f[%A]') then
            return true
        end
    end

    return nil
end

local function ProgressTargetMatches(line,target)
    local lowerLine = line:lower()
    local lowerTarget = target:lower()
    if lowerLine:find(lowerTarget,1,true) then
        return true
    end

    local targetWithoutQualifier = target:match('^(.-)%s*%(')
    return targetWithoutQualifier ~= nil
        and lowerLine:find(targetWithoutQualifier:lower(),1,true) ~= nil
end

local function HandleProgressReport(source,line)
    local sourceInfo = ProgressNPCs[source]
    if not sourceInfo or type(line) ~= 'string' then
        return
    end

    local lowerLine = line:lower()
    if not lowerLine:find(sourceInfo.name:lower(),1,true)
    or (not lowerLine:find(' says',1,true)
        and not lowerLine:find(' tells you',1,true))
    then
        return
    end

    table.insert(State.progressReports,{
        source=sourceInfo.name,
        text=line,
    })
    if #State.progressReports > 100 then
        table.remove(State.progressReports,1)
    end

    local disposition = GetProgressDisposition(line)
    local matchedItems = {}
    local category = InstanceCategories[sourceInfo.categoryIndex]

    for tierIndex,tier in ipairs(category.tiers) do
        for targetIndex,target in ipairs(GetInstanceTargets(tier)) do
            if ProgressTargetMatches(line,target) then
                table.insert(matchedItems,{
                    key=ProgressKey(
                        sourceInfo.categoryIndex,
                        tierIndex,
                        targetIndex
                    ),
                })
            end
        end
    end

    for _,flag in ipairs(State.sideFlags) do
        if ProgressTargetMatches(line,flag.name) then
            table.insert(matchedItems,{flag=flag})
        end
    end

    local matchedTargets = #matchedItems
    local matchedStatuses = 0
    local changes = 0
    if matchedTargets == 1 and disposition ~= nil then
        matchedStatuses = 1
        local item = matchedItems[1]
        if item.key then
            local wasDone = State.progressDone[item.key] == true
            if wasDone ~= disposition then
                State.progressDone[item.key] = disposition and true or nil
                changes = changes + 1
            end
        elseif item.flag.done ~= disposition then
            item.flag.done = disposition
            changes = changes + 1
        end
    end

    if changes > 0 then
        State.progressPendingSave = true
        State.progressPendingChanges = State.progressPendingChanges + changes
        State.progressStatus = string.format(
            'Progress update from %s will be saved shortly.',
            sourceInfo.name
        )
    elseif matchedTargets > 1 and disposition ~= nil then
        State.progressStatus = string.format(
            'Captured %s dialogue, but its status applies to multiple tracked items; review it manually.',
            sourceInfo.name
        )
    elseif matchedStatuses > 0 then
        State.progressStatus = string.format(
            '%s confirmed %d progress item(s); no changes were needed.',
            sourceInfo.name,
            matchedStatuses
        )
    elseif matchedTargets > 0 then
        State.progressStatus = string.format(
            'Found %d tracked item(s) in %s dialogue, but no explicit completion status.',
            matchedTargets,
            sourceInfo.name
        )
    else
        State.progressStatus = string.format(
            'Captured %s dialogue; no tracked names were recognized.',
            sourceInfo.name
        )
    end
end

local function NormalizeProgressName(value)
    local normalized = (value or ''):lower():gsub('%b()',' ')
    normalized = normalized:gsub('[%p]',' ')
    normalized = normalized:gsub('%s+',' ')
    return normalized:gsub('^%s+',''):gsub('%s+$','')
end

local function TrackKilledTarget(mobName)
    local normalizedMob = NormalizeProgressName(mobName)
    if normalizedMob == '' then
        return 0
    end

    local changes = 0
    for categoryIndex=1,2 do
        local category = InstanceCategories[categoryIndex]
        for tierIndex,tier in ipairs(category.tiers) do
            for targetIndex,target in ipairs(GetInstanceTargets(tier)) do
                local targetName = target:match('^(.-)%s*%(') or target
                if NormalizeProgressName(targetName) == normalizedMob then
                    local key = ProgressKey(
                        categoryIndex,
                        tierIndex,
                        targetIndex
                    )
                    if not State.progressDone[key] then
                        State.progressDone[key] = true
                        changes = changes + 1
                    end
                end
            end
        end
    end

    for _,flag in ipairs(State.sideFlags) do
        local flagTarget = flag.name
            :gsub('^[Kk][Ii][Ll][Ll]%s+','')
            :gsub('^[Dd][Ee][Ff][Ee][Aa][Tt]%s+','')
        if not flag.done
        and NormalizeProgressName(flagTarget) == normalizedMob
        then
            flag.done = true
            changes = changes + 1
        end
    end

    return changes
end

local function EscapePattern(text)
    return (text:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]','%%%0'))
end

local function GetLogCharacterName()
    return mq.TLO.Me.CleanName() or mq.TLO.Me.Name() or ''
end

local function GetEQLogPath()
    local root = mq.TLO.EverQuest.Path() or ''
    if root == '' then
        return nil
    end
    root = root:gsub('[\\/]+$','')
    local server = mq.TLO.EverQuest.Server() or ''
    return string.format(
        '%s\\Logs\\eqlog_%s_%s.txt',
        root,
        GetLogCharacterName(),
        server
    )
end

local function ProcessProgressLogLine(line,name)
    local mob = line:match('%] '..name..' has defeated (.-) for the first time%.')
        or line:match('%] (.-) %(%a+%) was defeated by '..name..'%.')
    if mob then
        return TrackKilledTarget(mob),nil
    end

    local tier = line:match('%] '..name..' has completed (.-) progression!')
    if tier then
        State.logTiers[tier] = true
        local tierNumber = tonumber(tier:match('%(Tier (%d+)%)'))
        if tierNumber then
            -- Announcements only say "Solo" for the solo/duo path.
            local path = tier:find('Solo',1,true) and 1 or 2
            State.logMaxTier[path] = math.max(State.logMaxTier[path] or 0,tierNumber)
        end
    end
    return 0,tier
end

-- Finishing a tier implies every lower tier on that path is finished.
local function ApplyTierCompletion()
    local changes = 0
    for categoryIndex=1,2 do
        local maxTier = State.logMaxTier[categoryIndex]
        if maxTier then
            for tierIndex,tier in ipairs(InstanceCategories[categoryIndex].tiers) do
                if tier.tier <= maxTier then
                    for targetIndex=1,CountTargets(tier) do
                        local key = ProgressKey(categoryIndex,tierIndex,targetIndex)
                        if not State.progressDone[key] then
                            State.progressDone[key] = true
                            changes = changes + 1
                        end
                    end
                end
            end
        end
    end
    return changes
end

local function ResetProgressLog()
    if State.logFile then
        State.logFile:close()
    end
    State.logFile = nil
    State.logOffset = 0
    State.logCarry = ''
    State.logImporting = false
    State.logLastPoll = 0
    State.logPath = nil
end

local function StartProgressLog()
    ResetProgressLog()
    State.logTiers = {}
    State.logMaxTier = {}
    State.logChanges = 0
    local path = GetEQLogPath()
    if not path then
        State.logStatus = 'Could not determine the EverQuest folder.'
        return
    end
    local file = io.open(path,'rb')
    if not file then
        State.logStatus = 'No log file found at '..path..' (is /log on?).'
        return
    end
    State.logPath = path
    State.logFile = file
    State.logImporting = true
    State.logStatus = 'Importing log history...'
end

-- Reads a bounded amount per call so the main loop never stalls.
local function PumpProgressLog()
    local file = State.logFile
    if not file then
        return
    end

    local name = EscapePattern(GetLogCharacterName())
    local changes = 0
    local chunks = 0
    while chunks < 4 do
        file:seek('set',State.logOffset)
        local data = file:read(1048576)
        if not data or #data == 0 then
            break
        end
        State.logOffset = State.logOffset + #data
        data = State.logCarry..data
        local lastNewline = data:match('^.*()\n')
        if lastNewline then
            State.logCarry = data:sub(lastNewline + 1)
            data = data:sub(1,lastNewline)
            for line in data:gmatch('[^\n]+') do
                if line:find('first time',1,true)
                    or line:find('progression!',1,true)
                    or line:find('was defeated by',1,true)
                then
                    local ok,added = pcall(ProcessProgressLogLine,line,name)
                    if ok and added then
                        changes = changes + added
                    end
                end
            end
        else
            State.logCarry = data
        end
        chunks = chunks + 1
    end

    if chunks < 4 and State.logImporting then
        State.logImporting = false
        State.logStatus = 'Log history imported; watching for new announcements.'
    end

    changes = changes + ApplyTierCompletion()
    if changes > 0 then
        State.logChanges = State.logChanges + changes
        State.progressPendingSave = true
        State.progressPendingChanges = State.progressPendingChanges + changes
    end
end

local function CountLogTiers()
    local count = 0
    for _ in pairs(State.logTiers) do
        count = count + 1
    end
    return count
end

-- Reads every saved character's progress file so one screen shows them all.
local function ScanAllCharacterProgress()
    local rows = {}
    local ok,lfs = pcall(require,'lfs')
    if not ok then
        return rows
    end
    local total = 0
    for categoryIndex=1,2 do
        for _,tier in ipairs(InstanceCategories[categoryIndex].tiers) do
            total = total + CountTargets(tier)
        end
    end
    for entry in lfs.dir(mq.configDir) do
        local server,character = entry:match('^WardenCompanionProgress_(.-)_([^_]+)%.txt$')
        if server then
            local file = io.open(mq.configDir..'\\'..entry,'r')
            if file then
                local done = 0
                for line in file:lines() do
                    if line:match('^T|%d+|%d+|%d+$') then
                        done = done + 1
                    end
                end
                file:close()
                table.insert(rows,{
                    server=server,
                    character=character,
                    done=done,
                    total=total,
                })
            end
        end
    end
    table.sort(rows,function(a,b) return a.character:lower() < b.character:lower() end)
    return rows
end

local function TierStats(categoryIndex,tierIndex)
    local tier = InstanceCategories[categoryIndex].tiers[tierIndex]
    local total = CountTargets(tier)
    local done = 0
    for targetIndex=1,total do
        if State.progressDone[ProgressKey(categoryIndex,tierIndex,targetIndex)] then
            done = done + 1
        end
    end
    return done,total
end

local function CategoryStats(categoryIndex)
    local done,total = 0,0
    for tierIndex=1,#InstanceCategories[categoryIndex].tiers do
        local tierDone,tierTotal = TierStats(categoryIndex,tierIndex)
        done = done + tierDone
        total = total + tierTotal
    end
    return done,total
end

local function OverallStats()
    local done,total = 0,0
    for categoryIndex=1,2 do
        local categoryDone,categoryTotal = CategoryStats(categoryIndex)
        done = done + categoryDone
        total = total + categoryTotal
    end
    return done,total
end

local function FirstUnfinishedTier(categoryIndex)
    for tierIndex,tier in ipairs(InstanceCategories[categoryIndex].tiers) do
        local done,total = TierStats(categoryIndex,tierIndex)
        if tier.might > 0 and done < total then
            return tierIndex,tier
        end
    end
    return nil
end

local ProgressColors = {
    gold={0.92,0.70,0.25,1},
    green={0.45,0.85,0.45,1},
    grey={0.60,0.60,0.62,1},
    cyan={0.55,0.85,1,1},
    ember={1,0.55,0.15,1},
}

local function DrawHeading(text)
    ImGui.TextColored(ProgressColors.gold[1],ProgressColors.gold[2],ProgressColors.gold[3],1,text)
    ImGui.Separator()
end

local function SetTierDone(categoryIndex,tierIndex,done)
    local tier = InstanceCategories[categoryIndex].tiers[tierIndex]
    for targetIndex=1,CountTargets(tier) do
        State.progressDone[ProgressKey(categoryIndex,tierIndex,targetIndex)] = done and true or nil
    end
    SaveProgressChanges()
end

local function DrawTierDetail(categoryIndex,tierIndex)
    local category = InstanceCategories[categoryIndex]
    local tier = category.tiers[tierIndex]
    local targets = GetInstanceTargets(tier)
    local done,total = TierStats(categoryIndex,tierIndex)

    DrawHeading(string.format('%s - %s',category.name,tier.name))
    ImGui.Text(string.format('Might reward: %d',tier.might))
    if tier.raidMight then
        ImGui.SameLine()
        ImGui.TextDisabled(string.format('(raid: %d)',tier.raidMight))
    end
    local difficulty = tier.auto == true and 'Auto-scaling difficulty'
        or tier.auto == 'selected' and 'Selectable difficulty'
        or 'Fixed difficulty'
    ImGui.TextDisabled(difficulty)
    ImGui.TextColored(ProgressColors.gold[1],ProgressColors.gold[2],ProgressColors.gold[3],1,
        string.format('Progress: %d/%d targets complete',done,total))
    ImGui.ProgressBar(total > 0 and done / total or 0,-1,0,string.format('%d%%',total > 0 and math.floor(done * 100 / total) or 0))
    if ImGui.SmallButton('Mark all done##tier_all') then
        SetTierDone(categoryIndex,tierIndex,true)
    end
    ImGui.SameLine()
    if ImGui.SmallButton('Clear##tier_clear') then
        SetTierDone(categoryIndex,tierIndex,false)
    end

    ImGui.Spacing()
    DrawHeading('Targets')
    for targetIndex,target in ipairs(targets) do
        local key = ProgressKey(categoryIndex,tierIndex,targetIndex)
        local isDone = State.progressDone[key] == true
        local updated,changed = ImGui.Checkbox(
            string.format('%s##t_%d_%d_%d',target,categoryIndex,tierIndex,targetIndex),
            isDone
        )
        if changed then
            State.progressDone[key] = updated and true or nil
            SaveProgressChanges()
        end
    end
end

local function DrawSideFlagsUI()
    DrawHeading('Side Flags')
    ImGui.TextDisabled('Track keys, flags and goals that are not part of the tier checklist.')
    local completedFlags = 0
    for _,flag in ipairs(State.sideFlags) do
        if flag.done then
            completedFlags = completedFlags + 1
        end
    end
    ImGui.Text(string.format('Side flags complete: %d / %d',completedFlags,#State.sideFlags))
    ImGui.ProgressBar(#State.sideFlags > 0 and completedFlags / #State.sideFlags or 0,-1,0,
        string.format('%d / %d',completedFlags,#State.sideFlags))

    local submitted
    State.newSideFlagName,submitted = ImGui.InputText(
        '##new_side_flag',
        State.newSideFlagName,
        80,
        ImGuiInputTextFlags.EnterReturnsTrue
    )
    ImGui.SameLine()
    if ImGui.Button('Add side flag') or submitted then
        local name = (State.newSideFlagName or ''):gsub('^%s+',''):gsub('%s+$','')
        local duplicate = false
        for _,flag in ipairs(State.sideFlags) do
            if flag.name:lower() == name:lower() then
                duplicate = true
            end
        end
        if name == '' then
            State.progressStatus = 'Enter a name for the side flag.'
        elseif duplicate then
            State.progressStatus = 'That side flag is already tracked.'
        else
            table.insert(State.sideFlags,{id=State.nextSideFlagID,name=name,done=false})
            State.nextSideFlagID = State.nextSideFlagID + 1
            State.newSideFlagName = ''
            SaveProgressChanges()
        end
    end

    ImGui.Spacing()
    if #State.sideFlags == 0 then
        ImGui.TextDisabled('No side flags yet. Type a name above and press Enter.')
    end
    for index=#State.sideFlags,1,-1 do
        local flag = State.sideFlags[index]
        ImGui.PushID('side_flag_'..flag.id)
        local updated,changed = ImGui.Checkbox(flag.name,flag.done)
        if changed then
            flag.done = updated
            SaveProgressChanges()
        end
        ImGui.SameLine()
        if ImGui.SmallButton('Remove') then
            table.remove(State.sideFlags,index)
            SaveProgressChanges()
        end
        ImGui.PopID()
    end
end

local function DrawOverviewUI()
    DrawHeading('Progress Overview')
    for categoryIndex=1,2 do
        local category = InstanceCategories[categoryIndex]
        local done,total = CategoryStats(categoryIndex)
        ImGui.Text(string.format('%s: %d / %d targets',category.name,done,total))
        ImGui.ProgressBar(total > 0 and done / total or 0,-1,0,
            string.format('%d%%',total > 0 and math.floor(done * 100 / total) or 0))
        local maxTier = State.logMaxTier[categoryIndex]
        if maxTier then
            ImGui.TextDisabled(string.format('Highest tier announced in your log: Tier %d',maxTier))
        end
    end

    ImGui.Spacing()
    DrawHeading('Next Steps')
    for categoryIndex=1,2 do
        local tierIndex,tier = FirstUnfinishedTier(categoryIndex)
        if tierIndex then
            ImGui.TextColored(ProgressColors.ember[1],ProgressColors.ember[2],ProgressColors.ember[3],1,
                string.format('%s: %s',InstanceCategories[categoryIndex].name,tier.name))
            local targets = GetInstanceTargets(tier)
            for targetIndex,target in ipairs(targets) do
                if not State.progressDone[ProgressKey(categoryIndex,tierIndex,targetIndex)] then
                    ImGui.BulletText(target)
                end
            end
            if ImGui.SmallButton(string.format('Open tier##next_%d',categoryIndex)) then
                State.progressNav = string.format('t:%d:%d',categoryIndex,tierIndex)
            end
        else
            ImGui.TextColored(ProgressColors.green[1],ProgressColors.green[2],ProgressColors.green[3],1,
                InstanceCategories[categoryIndex].name..': everything complete!')
        end
    end

    if State.autoTrackProgressLogs and CountLogTiers() > 0 then
        ImGui.Spacing()
        DrawHeading('Tier Completions Found In Log')
        local names = {}
        for tierName in pairs(State.logTiers) do
            table.insert(names,tierName)
        end
        table.sort(names)
        for _,tierName in ipairs(names) do
            ImGui.BulletText(tierName)
        end
    end
end

local function DrawAllCharactersUI()
    DrawHeading('All Characters')
    if ImGui.Button('Refresh##all_chars') or not State.allCharactersScanned then
        State.allCharactersScanned = true
        local ok,rows = pcall(ScanAllCharacterProgress)
        State.allCharacters = ok and rows or {}
    end
    ImGui.SameLine()
    ImGui.TextDisabled('Every character that has run the Grimoire on this PC.')
    for _,row in ipairs(State.allCharacters) do
        ImGui.Text(string.format('%s (%s)',row.character,row.server))
        ImGui.ProgressBar(row.total > 0 and row.done / row.total or 0,-1,0,
            string.format('%d / %d',row.done,row.total))
    end
end

local function DrawProgressNavUI()
    local function NavItem(label,key)
        if ImGui.Selectable(label..'##nav_'..key,State.progressNav == key) then
            State.progressNav = key
        end
    end

    NavItem('Overview','overview')
    for categoryIndex=1,2 do
        local category = InstanceCategories[categoryIndex]
        local done,total = CategoryStats(categoryIndex)
        ImGui.Spacing()
        ImGui.TextDisabled(string.format('-- %s (%d/%d) --',category.name:upper(),done,total))
        for tierIndex,tier in ipairs(category.tiers) do
            local tierDone,tierTotal = TierStats(categoryIndex,tierIndex)
            local complete = tierDone == tierTotal
            if complete then
                ImGui.PushStyleColor(ImGuiCol.Text,0.45,0.85,0.45,1)
            end
            NavItem(
                string.format('%s %s (%d/%d)',complete and '[x]' or '[ ]',tier.name,tierDone,tierTotal),
                string.format('t:%d:%d',categoryIndex,tierIndex)
            )
            if complete then
                ImGui.PopStyleColor()
            end
        end
    end
    ImGui.Spacing()
    ImGui.TextDisabled('-- TOOLS --')
    NavItem('Side Flags','flags')
    NavItem('All Characters','chars')
    ImGui.Spacing()
    ImGui.TextDisabled('-- GUIDE --')
    for _,section in ipairs(GuideSections) do
        NavItem(section.label,'g:'..section.id)
    end
end

local function SetProgressLogTracking(enabled)
    State.autoTrackProgressLogs = enabled
    if enabled then
        StartProgressLog()
    else
        ResetProgressLog()
        State.logStatus = 'Log tracking is off.'
    end

    if SaveProgressChanges() then
        State.progressStatus = enabled
            and 'Log tracking enabled.'
            or 'Log tracking disabled; manual checklist remains available.'
    end
end

local function DrawGuideSection(sectionID)
    for _,section in ipairs(GuideSections) do
        if section.id == sectionID then
            DrawHeading(section.label)
            for _,line in ipairs(section.lines) do
                ImGui.Bullet()
                ImGui.TextWrapped(line)
            end
        end
    end
    ImGui.Spacing()
    ImGui.TextDisabled('Source: https://www.eqmight.com')
end

local function DrawProgressionUI()
    local done,total = OverallStats()
    local fraction = total > 0 and done / total or 0
    ImGui.TextColored(ProgressColors.gold[1],ProgressColors.gold[2],ProgressColors.gold[3],1,
        string.format('Progress: %d/%d targets complete (%d%%)',done,total,math.floor(fraction * 100)))
    ImGui.ProgressBar(fraction,-1,0,string.format('%d%% overall completion',math.floor(fraction * 100)))

    local autoTrack,autoTrackChanged = ImGui.Checkbox(
        'Auto-track from EverQuest logs (/log on)##progress_auto',
        State.autoTrackProgressLogs
    )
    if autoTrackChanged then
        SetProgressLogTracking(autoTrack)
    end
    ImGui.SameLine()
    ImGui.TextDisabled(State.logStatus)
    ImGui.Separator()

    ImGui.BeginChild('##prog_nav',250,0,true)
    DrawProgressNavUI()
    ImGui.EndChild()

    ImGui.SameLine()
    ImGui.BeginChild('##prog_detail',0,0,true)
    local nav = State.progressNav or 'overview'
    local categoryIndex,tierIndex = nav:match('^t:(%d+):(%d+)$')
    if categoryIndex then
        local category = InstanceCategories[tonumber(categoryIndex)]
        if category and category.tiers[tonumber(tierIndex)] then
            DrawTierDetail(tonumber(categoryIndex),tonumber(tierIndex))
        else
            DrawOverviewUI()
        end
    elseif nav == 'flags' then
        DrawSideFlagsUI()
    elseif nav == 'chars' then
        DrawAllCharactersUI()
    elseif nav:sub(1,2) == 'g:' then
        DrawGuideSection(nav:sub(3))
    else
        DrawOverviewUI()
    end
    ImGui.Spacing()
    ImGui.TextDisabled(State.progressStatus)
    ImGui.EndChild()
end

local function WaitForCondition(condition,timeoutMs)
    local elapsed = 0
    while elapsed < timeoutMs do
        if condition() then return true end
        mq.delay(100)
        elapsed = elapsed + 100
    end
    return false
end

-- Opens the inventory's Alt Currency page (controls from autoclaim.lua), runs fn, then restores the window.
local function WithCurrencyPage(showAllCurrencies,fn)
    local inventory = mq.TLO.Window('InventoryWindow')
    local wasOpen = inventory() and inventory.Open()
    if not wasOpen then
        inventory.DoOpen()
        if not WaitForCondition(function() return inventory() and inventory.Open() end,5000) then
            return false,'Could not open the inventory window.'
        end
    end

    local tabBox = inventory.Child('IW_Subwindows')
    local function tabName()
        return tabBox.CurrentTab and tabBox.CurrentTab.Name and tabBox.CurrentTab.Name() or ''
    end
    local found = false
    local originalTab = tabBox.CurrentTabIndex and tonumber(tabBox.CurrentTabIndex()) or nil
    for i=1,tonumber(tabBox.TabCount() or 0) do
        tabBox.SetCurrentTab(i)
        mq.delay(250)
        if tabName() == 'IW_AltCurrPage' then
            found = true
            break
        end
    end

    local result
    if found then
        local showAll = inventory.Child('IW_AltCurr_DisplayMissingButton')
        local toggled = false
        if showAllCurrencies and showAll() and not showAll.Checked() then
            showAll.LeftMouseUp()
            toggled = true
            mq.delay(300)
        end

        local ok,value = pcall(fn,inventory,tabName)
        result = ok and value or nil

        if toggled and showAll.Checked() then
            showAll.LeftMouseUp()
            mq.delay(100)
        end
    end

    if originalTab and originalTab > 0 then
        tabBox.SetCurrentTab(originalTab)
    end
    if not wasOpen then
        inventory.DoClose()
    end

    if not found then
        return false,'Could not find the Alt Currency page.'
    end
    return true,result
end

local function ReclaimCurrencies()
    local ok,result = WithCurrencyPage(false,function(inventory,tabName)
        local list = inventory.Child('IW_AltCurr_PointList')
        local button = inventory.Child('IW_AltCurr_ReclaimButton')
        if not list() or not button() then return 0 end

        local reclaimed = 0
        for row=1,tonumber(list.Items() or 0) or 0 do
            if not inventory.Open() or tabName() ~= 'IW_AltCurrPage' then break end
            list.Select(row)
            mq.delay(100,function() return list.SelectedIndex() == row end)
            button.LeftMouseUp()
            reclaimed = reclaimed + 1
            mq.delay(50)
        end
        return reclaimed
    end)

    State.progressStatus = ok
        and string.format('Reclaimed %d currency entries.',tonumber(result) or 0)
        or result
end

-- Reads currency names from the Alt Currency page.
local function ScanCurrencies()
    local ok,names = WithCurrencyPage(true,function(inventory)
        local list = inventory.Child('IW_AltCurr_PointList')
        local found = {}
        for row=1,tonumber(list.Items() or 0) or 0 do
            for column=1,3 do
                local text = list.List(row,column)()
                if text and text ~= '' and not tonumber((text:gsub(',',''))) then
                    found[#found + 1] = text
                    break
                end
            end
        end
        return found
    end)

    if not ok then
        State.progressStatus = names
        return
    end
    if type(names) ~= 'table' or #names == 0 then
        State.progressStatus = 'Currency list was empty; nothing changed.'
        return
    end

    State.altCurrencies = {}
    for _,name in ipairs(names) do
        if not FindAltCurrency(name) then
            table.insert(State.altCurrencies,{name=name,custom=true})
        end
    end
    SaveProgressChanges()
    State.progressStatus = string.format('Found %d currencies from your inventory.',#State.altCurrencies)
end

local function GetCurrencyBalance(currency)
    local balance
    if not currency.itemOnly then
        local ok,value = pcall(function()
            return mq.TLO.Me.AltCurrency(currency.name)()
        end)
        balance = ok and tonumber(value) or nil
    end
    local okBags,inBags = pcall(function()
        return mq.TLO.FindItemCount('='..currency.name)()
    end)
    return balance,okBags and tonumber(inBags) or 0
end

local function DrawAltCurrencyUI()
    ImGui.TextColored(0.92,0.70,0.25,1,'ALTERNATE CURRENCY')
    ImGui.TextDisabled('Balances are read live by name. Unreclaimed tokens in your bags are counted separately.')
    if ImGui.Button('Scan currencies from inventory') then
        State.currencyScanRequested = true
        State.progressStatus = 'Scanning currencies...'
    end
    ImGui.SameLine()
    ImGui.TextDisabled('Opens your inventory briefly and lists every server currency.')
    if ImGui.Button('Reclaim all tokens') then
        State.currencyReclaimRequested = true
        State.progressStatus = 'Reclaiming currencies...'
    end
    ImGui.SameLine()
    ImGui.TextDisabled('Same as Inventory > Alternate Currencies > Reclaim for every entry.')

    if ImGui.BeginTable(
        '##alt_currency_balances',
        4,
        ImGuiTableFlags.Borders + ImGuiTableFlags.RowBg,
        0,
        260
    ) then
        ImGui.TableSetupColumn('Currency',ImGuiTableColumnFlags.WidthStretch)
        ImGui.TableSetupColumn('Balance',ImGuiTableColumnFlags.WidthFixed,90)
        ImGui.TableSetupColumn('In bags',ImGuiTableColumnFlags.WidthFixed,90)
        ImGui.TableSetupColumn('',ImGuiTableColumnFlags.WidthFixed,70)
        ImGui.TableHeadersRow()

        for index,currency in ipairs(State.altCurrencies) do
            ImGui.TableNextRow()
            ImGui.TableSetColumnIndex(0)
            ImGui.Text(currency.name)
            if currency.note and ImGui.IsItemHovered() then
                ImGui.SetTooltip(currency.note)
            end

            local balance,inBags = GetCurrencyBalance(currency)
            ImGui.TableSetColumnIndex(1)
            if currency.itemOnly then
                ImGui.TextDisabled('item')
            elseif balance == nil then
                ImGui.TextDisabled('n/a')
            else
                ImGui.Text(tostring(balance))
            end

            ImGui.TableSetColumnIndex(2)
            ImGui.Text(tostring(inBags))

            ImGui.TableSetColumnIndex(3)
            if currency.custom and ImGui.SmallButton('Remove##currency_'..index) then
                table.remove(State.altCurrencies,index)
                SaveProgressChanges()
                break
            end
        end

        ImGui.EndTable()
    end
    ImGui.TextDisabled('Hover a currency for how it is used. "n/a" means the name was not recognised; check the exact in-game spelling.')

    State.newAltCurrencyName = ImGui.InputText(
        'Track currency',
        State.newAltCurrencyName,
        64
    )
    ImGui.SameLine()
    if ImGui.Button('Add currency') then
        local name = (State.newAltCurrencyName or ''):gsub('^%s+',''):gsub('%s+$','')
        if name == '' then
            State.progressStatus = 'Enter a currency name to track.'
        elseif FindAltCurrency(name) then
            State.progressStatus = 'That currency is already tracked.'
        else
            table.insert(State.altCurrencies,{name=name,custom=true})
            State.newAltCurrencyName = ''
            SaveProgressChanges()
        end
    end

    ImGui.TextDisabled(State.progressStatus)
end

-- Highest-requirement mode the party's Might still meets (the easiest expected result).
local function ExpectedMode(suggestedMight,might)
    local best
    for _,mode in ipairs(DifficultyModes) do
        if might >= math.floor(suggestedMight * mode.multiplier + 0.5) then
            if not best or mode.multiplier > best.multiplier then
                best = mode
            end
        end
    end
    return best
end

local function DrawNextUp(categoryIndex,might)
    local category = InstanceCategories[categoryIndex]
    for tierIndex,tier in ipairs(category.tiers) do
        local targets = GetInstanceTargets(tier)
        local remaining = {}
        for targetIndex,target in ipairs(targets) do
            if not State.progressDone[ProgressKey(categoryIndex,tierIndex,targetIndex)] then
                remaining[#remaining + 1] = target
            end
        end

        if #remaining > 0 then
            ImGui.TextColored(0.92,0.70,0.25,1,category.name..': '..tier.name)
            ImGui.Text(string.format('%d of %d targets left. Suggested Might %s.',#remaining,#targets,FormatMight(tier.might or 0)))
            local mode = ExpectedMode(tier.might or 0,might)
            if mode then
                ImGui.TextColored(0.55,0.85,0.45,1,'Your Might ('..FormatMight(might)..') should clear '..mode.name..' or better.')
            else
                ImGui.TextColored(1,0.55,0.35,1,'Your Might ('..FormatMight(might)..') is below the lowest mode. Level, AAs, or a ring rank first.')
            end
            ImGui.TextWrapped('Up next: '..table.concat(remaining,', '))
            ImGui.Spacing()
            return
        end
    end
    ImGui.TextColored(0.55,0.85,0.45,1,category.name..': every target is checked off.')
    ImGui.Spacing()
end

local function DrawTodayUI()
    local level = mq.TLO.Me.Level() or 0
    local solo = GetCharacterMight(State.currentIndex)
    local party = #State.party > 1 and GetPartyMight(State.currentIndex) or solo
    local ring = Rings[State.currentIndex]

    ImGui.TextColored(0.92,0.70,0.25,1,'TODAY')
    ImGui.Text(string.format(
        '%s, level %d. Ring: %s. Personal Might %s%s.',
        mq.TLO.Me.CleanName() or 'You',
        level,
        ring and ring.name or 'none',
        FormatMight(solo),
        #State.party > 1 and (', group Might '..FormatMight(party)) or ''
    ))
    ImGui.Separator()

    ImGui.TextColored(0.92,0.70,0.25,1,'NEXT PROGRESSION TARGETS')
    DrawNextUp(1,#State.party > 2 and solo or party)
    DrawNextUp(2,party)
    ImGui.TextDisabled('Check targets off on the Progression tab. Estimates come from the Might calculator and are planning aids.')
    ImGui.Separator()

    ImGui.TextColored(0.92,0.70,0.25,1,'TOKENS AND SHOPPING')
    local might,epic,legendary = 0,0,0
    for _,pair in ipairs({
        {'Token of Might',1},{'Token of Epic Might',2},{'Token of Legendary Might',3},
    }) do
        local balance,inBags = GetCurrencyBalance({name=pair[1]})
        local total = (balance or 0) + inBags
        if pair[2] == 1 then might = total elseif pair[2] == 2 then epic = total else legendary = total end
        ImGui.Text(string.format('%s: %d%s',pair[1],balance or 0,inBags > 0 and (' (+'..inBags..' unreclaimed)') or ''))
    end
    ImGui.TextDisabled(string.format(
        'Walter: %d Epic from your Might tokens (10 each, needs 1 Invaluable Coin), %d Legendary from your Epic tokens (6 each, needs 2).',
        math.floor(might / 10),
        math.floor(epic / 6)
    ))
    ImGui.TextDisabled(string.format('Cloe: %d Epic 1.0 weapon(s) at 2 Epic tokens each. Legendary tokens held: %d.',math.floor(epic / 2),legendary))
    if ImGui.Button('Reclaim all tokens##today') then
        State.currencyReclaimRequested = true
        State.progressStatus = 'Reclaiming currencies...'
    end
    ImGui.SameLine()
    ImGui.TextDisabled(State.progressStatus)
end

local function DrawRingUI()

    RefreshRing()

    local ring = GetEquippedRing()
    ImGui.TextColored(0.35,0.82,1,1,'WARDEN RING SWAPPER')

    if ring then
        local current = Rings[State.currentIndex]
        DrawRingIcon(State.currentIndex,32)
        ImGui.SameLine()
        ImGui.Text('Equipped: '..current.name)
        ImGui.ProgressBar(
            current.warden / 4,
            -1,
            0,
            string.format('Rank %d / 4',current.warden)
        )
    else
        ImGui.TextColored(1,0.55,0.35,1,'No Warden ring equipped')
    end

    local ringNames = {}
    for i,availableRing in ipairs(Rings) do
        ringNames[i] = availableRing.name
    end
    local previousTarget = State.draftRingIndex
    State.draftRingIndex = DrawCombo(
        'Target ring',
        State.draftRingIndex,
        ringNames,
        'ring'
    )
    State.targetIndex = State.draftRingIndex
    if State.draftRingIndex ~= previousTarget then
        State.selectedLoadout = 0
        State.loadoutName = ''
        State.draftSlots = {}
        State.inventoryDirty = true
    end

    if DrawRingIcon(State.targetIndex,24) then
        ImGui.SameLine()
        ImGui.Text(string.format(
            '%s - %s',
            Rings[State.targetIndex].name,
            WardenLabels[Rings[State.targetIndex].warden + 1]
        ))
    end
    ImGui.Separator()

    DrawLoadoutEditor()

    ImGui.Separator()

    if ImGui.Button('Swap Ring') then
        local prepared,prepareError = PrepareSelectedAugs()
        if prepared then
            State.swapRequested = true
            State.status = 'Swap queued'
        else
            State.status = prepareError
        end
    end

    ImGui.SameLine()
    ImGui.Text(State.status)
end

local GrimoireColors = {
    {'WindowBg',0.13,0.08,0.05,0.98},
    {'ChildBg',0.18,0.12,0.07,0.95},
    {'PopupBg',0.15,0.10,0.06,0.98},
    {'Border',0.55,0.40,0.18,0.90},
    {'Text',0.93,0.85,0.66,1},
    {'TextDisabled',0.60,0.52,0.38,1},
    {'FrameBg',0.24,0.16,0.09,1},
    {'FrameBgHovered',0.34,0.23,0.12,1},
    {'FrameBgActive',0.42,0.28,0.14,1},
    {'TitleBg',0.22,0.10,0.07,1},
    {'TitleBgActive',0.36,0.12,0.08,1},
    {'Button',0.40,0.16,0.10,1},
    {'ButtonHovered',0.55,0.22,0.12,1},
    {'ButtonActive',0.68,0.28,0.14,1},
    {'Header',0.32,0.18,0.09,1},
    {'HeaderHovered',0.48,0.28,0.12,1},
    {'HeaderActive',0.58,0.34,0.14,1},
    {'Tab',0.26,0.14,0.08,1},
    {'TabHovered',0.55,0.30,0.12,1},
    {'TabActive',0.42,0.20,0.10,1},
    {'TabSelected',0.42,0.20,0.10,1},
    {'CheckMark',0.92,0.70,0.25,1},
    {'PlotHistogram',0.62,0.18,0.12,1},
    {'Separator',0.55,0.40,0.18,0.70},
    {'ScrollbarBg',0.12,0.07,0.04,1},
    {'ScrollbarGrab',0.45,0.30,0.14,1},
    {'TableHeaderBg',0.30,0.16,0.09,1},
    {'TableRowBgAlt',0.20,0.13,0.07,0.60},
}

local function PushGrimoireTheme()
    local pushed = 0
    for _,entry in ipairs(GrimoireColors) do
        local colorID = ImGuiCol and ImGuiCol[entry[1]]
        if colorID then
            ImGui.PushStyleColor(colorID,entry[2],entry[3],entry[4],entry[5])
            pushed = pushed + 1
        end
    end
    return pushed
end

local GRIMOIRE_WIDTH = 1100
local GRIMOIRE_HEIGHT = 780
local GRIMOIRE_ASPECT = GRIMOIRE_WIDTH / GRIMOIRE_HEIGHT

local function ConstrainGrimoireSize(_,currentSize,desiredSize)
    local widthChange = math.abs(desiredSize.x - currentSize.x) / GRIMOIRE_WIDTH
    local heightChange = math.abs(desiredSize.y - currentSize.y) / GRIMOIRE_HEIGHT
    local width = heightChange > widthChange
        and desiredSize.y * GRIMOIRE_ASPECT
        or desiredSize.x
    width = math.max(width,220)
    return ImVec2(width,width / GRIMOIRE_ASPECT)
end

local function DrawUI()
    ImGui.SetNextWindowSize(GRIMOIRE_WIDTH,GRIMOIRE_HEIGHT,ImGuiCond.FirstUseEver)
    ImGui.SetNextWindowSizeConstraints(
        ImVec2(220,156),
        ImVec2(1000000,1000000),
        ConstrainGrimoireSize
    )
    local pushedColors = PushGrimoireTheme()
    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding,6)
    ImGui.PushStyleVar(ImGuiStyleVar.FrameRounding,4)
    ImGui.PushStyleVar(ImGuiStyleVar.ChildRounding,4)
    ImGui.PushStyleVar(ImGuiStyleVar.WindowBorderSize,2)
    ImGui.PushStyleVar(ImGuiStyleVar.ItemSpacing,10,8)
    local draw = false
    State.open,draw = ImGui.Begin('EQMight Grimoire',State.open)

    if draw then
        RefreshRing()
        ImGui.TextColored(0.92,0.70,0.25,1,'~ EQMIGHT GRIMOIRE ~')
        ImGui.SameLine()
        ImGui.TextDisabled('Progression, Might, Rings, Currency, Pearls')
        ImGui.Separator()

        if ImGui.BeginTabBar('##companion_tabs') then
            if ImGui.BeginTabItem('Today') then
                DrawTodayUI()
                ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem('Progression') then
                DrawProgressionUI()
                ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem('Might & Dungeons') then
                DrawMightUI()
                ImGui.Separator()
                DrawPartyMight()
                ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem('Rings') then
                DrawRingUI()
                ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem('Currency') then
                DrawAltCurrencyUI()
                ImGui.EndTabItem()
            end

            if ImGui.BeginTabItem('Pearls') then
                if State.pearlTrackerReady then
                    local pearlOK,pearlError = pcall(PearlUI.renderEmbedded)
                    if not pearlOK then
                        ImGui.TextColored(1,0.35,0.35,1,'Pearl Tracker render error:')
                        ImGui.TextWrapped(tostring(pearlError))
                    end
                else
                    ImGui.TextColored(1,0.65,0.35,1,'Pearl Tracker is unavailable.')
                    ImGui.TextWrapped(State.pearlTrackerError)
                end
                ImGui.EndTabItem()
            end

            ImGui.EndTabBar()
        end
    end

    if not State.open then
        State.swapRequested = false
    end

    ImGui.End()
    ImGui.PopStyleVar(5)
    if pushedColors > 0 then
        ImGui.PopStyleColor(pushedColors)
    end
end

for _,currency in ipairs(DefaultCurrencies) do
    table.insert(State.altCurrencies,{
        name=currency.name,
        note=currency.note,
        itemOnly=currency.itemOnly,
        custom=false,
    })
end
RefreshRing()
State.targetIndex = State.currentIndex
State.draftRingIndex = State.currentIndex
RefreshParty()
LoadLoadouts()
LoadProgress()
ScanAvailableAugs()
LoadDraftFromEquippedRing()
if State.autoTrackProgressLogs then
    StartProgressLog()
end
local pearlInitOK,pearlReady = pcall(PearlNetwork.init)
if pearlInitOK and pearlReady then
    local pearlDataOK,pearlError = pcall(function()
        PearlNetwork.broadcastMyData()
        PearlNetwork.requestAllData()
    end)
    State.pearlTrackerReady = pearlDataOK
    State.pearlTrackerError = pearlDataOK
        and ''
        or tostring(pearlError)
else
    State.pearlTrackerError = pearlInitOK
        and 'Could not register the Pearl Tracker actor mailbox.'
        or tostring(pearlReady)
end
mq.imgui.init(
    'EQMightGrimoire',
    DrawUI
)

while State.open do
    mq.delay(100)
    if State.autoTrackProgressLogs and State.logFile then
        local now = os.time()
        if State.logImporting or now - State.logLastPoll >= 2 then
            State.logLastPoll = now
            local ok,pumpError = pcall(PumpProgressLog)
            if not ok then
                State.logStatus = 'Log read failed: '..tostring(pumpError)
                ResetProgressLog()
            end
        end
    end
    if State.pearlTrackerReady then
        mq.doevents()
    end

    if State.progressPendingSave then
        local syncedCount = State.progressPendingChanges
        if SaveProgressChanges() then
            State.progressStatus = string.format(
                'Saved %d automatic progress update(s).',
                syncedCount
            )
        else
            State.progressPendingSave = false
            State.progressPendingChanges = 0
        end
    end

    if State.currencyScanRequested then
        State.currencyScanRequested = false
        local ok,scanError = pcall(ScanCurrencies)
        if not ok then
            State.progressStatus = 'Currency scan failed: '..tostring(scanError)
        end
    end

    if State.currencyReclaimRequested then
        State.currencyReclaimRequested = false
        local ok,reclaimError = pcall(ReclaimCurrencies)
        if not ok then
            State.progressStatus = 'Reclaim failed: '..tostring(reclaimError)
        end
    end

    if State.swapRequested then
        State.swapRequested = false
        Execute()
    end
end

mq.unevent('warden_companion_solo_progress')
mq.unevent('warden_companion_group_progress')
mq.unevent('project_might_progress_kill')