Config = {}

Config.Identifier = 'license' -- 'steam', 'license', 'discord'...

Config.Framework = 'custom'   -- 'esx', 'qb', 'custom'

Config.Notification = 'ox'    -- 'esx', 'qb', 'ox, 'custom'

Config.Zones = {
    Debug = false,
    Booths = {
        { coords = vec3(-523.35, -176.3, 38.0),  distance = 1 },
        { coords = vec3(-522.01, -178.86, 38.0), distance = 1 },
        { coords = vec3(-530.9, -180.53, 38.0),  distance = 1 },
        { coords = vec3(-529.42, -182.97, 38.0), distance = 1 },
    },
    ControlPanels = {
        { coords = vec3(-522.15, -187.5, 38.4), distance = 2 }
    }
}
