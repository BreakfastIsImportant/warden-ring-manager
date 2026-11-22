local mq = require('mq')
local ImGui = require('ImGui')
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

local function DrawRingUI()

    RefreshRing()

    local ring = GetEquippedRing()
    ImGui.TextColored(0.35,0.82,1,1,'WARDEN RING MANAGER')

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

local function DrawUI()

    State.open = ImGui.Begin('Warden Ring Manager',State.open)

    RefreshRing()

    DrawRingUI()
    ImGui.Separator()
    DrawMightUI()
    ImGui.Separator()
    DrawPartyMight()

    if not State.open then
        State.swapRequested = false
    end

    ImGui.End()
end

RefreshRing()
State.targetIndex = State.currentIndex
State.draftRingIndex = State.currentIndex
RefreshParty()
LoadLoadouts()
ScanAvailableAugs()
LoadDraftFromEquippedRing()

mq.imgui.init(
    'WardenRingManager',
    DrawUI
)

while State.open do
    mq.delay(100)

    if State.swapRequested then
        State.swapRequested = false
        Execute()
    end
end