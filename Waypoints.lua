local DM = select(2,...)

local Waypoints = {
    { x = 50.47, y = 31.54 },
    { x = 52.23, y = 28.04 },
    { x = 45.24, y = 16.04 },
    { x = 34.32, y = 19.63 },
    { x = 34.38, y = 21.27 },
    { x = 33.68, y = 25.38 },
    { x = 33.23, y = 28.09 },
    { x = 29.90, y = 24.90 },
    { x = 29.85, y = 20.45 },
    { x = 31.96, y = 45.29 },
    { x = 32.73, y = 47.63 },
    { x = 25.40, y = 51.07 },
    { x = 24.44, y = 59.96 },
    { x = 22.09, y = 64.06 },
    { x = 25.59, y = 65.89 },
    { x = 26.27, y = 65.09 },
    { x = 28.51, y = 63.74 },
    { x = 30.42, y = 62.67 },
    { x = 30.61, y = 60.50 },
    { x = 33.08, y = 60.13 },
    { x = 33.20, y = 62.83 },
    { x = 30.99, y = 66.37 },
    { x = 30.98, y = 67.52 },
    { x = 31.50, y = 69.26 },
    { x = 33.21, y = 72.04 },
    { x = 33.27, y = 67.78 },
    { x = 37.13, y = 64.08 },
    { x = 38.28, y = 60.70 },
    { x = 38.49, y = 54.93 },
    { x = 40.84, y = 49.75 },
    { x = 39.97, y = 45.00 },
    { x = 40.10, y = 43.40 },
    { x = 40.16, y = 38.41 },
    { x = 46.25, y = 44.58 },
    { x = 48.17, y = 46.40 },
    { x = 51.80, y = 49.34 },
    { x = 51.03, y = 50.80 },
    { x = 50.48, y = 50.65 },
    { x = 51.47, y = 51.16 },
    { x = 52.14, y = 51.21 },
    { x = 51.92, y = 70.81 },
    { x = 50.42, y = 72.22 },
    { x = 50.24, y = 73.67 },
    { x = 49.13, y = 75.91 },
    { x = 47.28, y = 76.69 },
    { x = 51.14, y = 79.79 },
    { x = 73.44, y = 73.61 },
    { x = 69.87, y = 58.13 },
    { x = 72.02, y = 43.88 },
    { x = 64.66, y = 30.27 },
}


function CS:Waypoints()
    local currentUIMapID = C_Map.GetBestMapForUnit("player")
    local mapInfo = C_Map.GetMapInfo(CS.Uldum)
    if TomTom then
        for _,v in next, Waypoints do
            TomTom:AddWaypoint(CS.Uldum, v.x/100, v.y/100, { title = "|cffFFDD00Mysterious Camel Figurine|r\n|cffEEE4AECamel Spotter|r", })
        end
        print("|cffEEE4AECamel Spotter:|r Waypoints added to "..mapInfo.name..".")
        if currentUIMapID == CS.Uldum then
            TomTom:SetClosestWaypoint()
        end
    else
        print("|cffEEE4AECamel Spotter:|r You need TomTom for this feature.")
    end
end
