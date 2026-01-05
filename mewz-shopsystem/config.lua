Config = {}

Config.Webhook = ''

Config.Shops = {
    {
        id = 'supermarket',
        name = '24/7 Supermarket',
        shopType = 'supermarket',
        blip = {
            id = 59,
            colour = 69,
            scale = 0.8
        },
        npc = {
            model = `mp_m_shopkeep_01`,
            offset = vector3(0.0, 0.0, 0.0)
        },
        locations = {
            { coords = vector4(24.3317, -1345.6394, 29.4970, 271.3670) },
            { coords = vector4(-3038.8960, 584.4456, 7.9089, 26.3252) },
            { coords = vector4(-3243.9612, 999.9838, 12.8307, 346.9553) },
            { coords = vector4(1728.6428, 6416.7993, 35.0372, 245.3431) },
            { coords = vector4(1697.2490, 4923.4893, 42.0636, 325.3263) },
            { coords = vector4(1959.2692, 3741.4429, 32.3437, 299.0128) },
            { coords = vector4(549.3137, 2669.7007, 42.1565, 98.2626) },
            { coords = vector4(2676.4548, 3280.1284, 55.2411, 330.9494) },
            { coords = vector4(2555.4680, 380.7740, 108.6229, 2.1230) },
            { coords = vector4(372.8015, 328.1590, 103.5663, 254.8313) },
        }
    },
    {
        id = 'digitaldan',
        name = 'DigitalDan',
        shopType = 'digitaldan',
        blip = {
            id = 521,
            colour = 3,
            scale = 0.8
        },
        npc = {
            model = `mp_m_shopkeep_01`,
            offset = vector3(0.0, 0.0, 0.0)
        },
        locations = {
            { coords = vector4(-657.5093, -854.7382, 24.5074, 350.8971) },
        }
    },
    {
        id = 'ammunition',
        name = 'Ammunition',
        shopType = 'ammunition',
        blip = {
            id = 110,
            colour = 1,
            scale = 0.8
        },
        npc = {
            model = `s_m_y_ammucity_01`,
            offset = vector3(0.0, 0.0, 0.0)
        },
        locations = {
            { coords = vector4(-662.2770, -933.5273, 21.8292, 180.8278), npcOffset = vector3(0.0, -0.5, 0.0) },
            { coords = vector4(842.5132, -1035.3441, 28.1948, 0.7280), npcOffset = vector3(0.0, 0.5, 0.0) },
            { coords = vector4(1692.3777, 3761.0286, 34.7053, 240.4255), npcOffset = vector3(-0.4, -0.4, 0.0) },
            { coords = vector4(-331.4605, 6085.0913, 31.4548, 228.9734), npcOffset = vector3(-0.4, -0.4, 0.0) },
            { coords = vector4(252.696, -50.004, 69.941, 70.0), npcOffset = vector3(-0.5, 0.0, 0.0) },
            { coords = vector4(-1119.0325, 2699.7839, 18.5541, 224.7574), npcOffset = vector3(0.0, 0.5, 0.0) },
            { coords = vector4(22.7112, -1105.4738, 29.7970, 159.0113), npcOffset = vector3(0.3, -0.3, 0.0) },
        }
    },
}

Config.Items = {
    ['supermarket'] = {
        ['MAD'] = {
            {
                id = 1,
                name = 'burger',
                label = 'Burger',
                item = 'burger',
                type = 'item',
                price = 30,
                description = 'Lækker burger med kød, salat og dressing.'
            },
        },
        ['DRIKKE'] = {
            {
                id = 2,
                name = 'water',
                label = 'Water',
                item = 'water',
                type = 'item',
                price = 15,
                description = 'Frisk vand.'
            },
        },
        ['ITEMS'] = {
            {
                id = 4,
                name = 'lockpick',
                label = 'Lockpick',
                item = 'lockpick',
                type = 'item',
                price = 500,
                description = 'Lockpick til at åbne døre.'
            },
            {
                id = 5,
                name = 'bucket',
                label = 'Bucket',
                item = 'bucket',
                type = 'item',
                price = 500,
                description = 'En spand.'
            },
            {
                id = 6,
                name = 'kanyle',
                label = 'Kanyle',
                item = 'kanyle',
                type = 'item',
                price = 500,
                description = 'En kanyle.'
            },
        }
    },
    ['digitaldan'] = {
        ['ELEKTRONIK'] = {
            {
                id = 10,
                name = 'radio',
                label = 'Radio',
                item = 'radio',
                type = 'item',
                price = 500,
                description = 'En radio til kommunikation.'
            },
            {
                id = 11,
                name = 'phone',
                label = 'Telefon',
                item = 'phone',
                type = 'item',
                price = 1000,
                description = 'En smartphone.'
            },
            {
                id = 12,
                name = 'camera',
                label = 'Kamera',
                item = 'camera',
                type = 'item',
                price = 1500,
                description = 'Et kamera til at tage billeder.'
            },
        }
    },
    ['ammunition'] = {
        ['HÅNDVÅBEN'] = {
            {
                id = 20,
                name = 'weapon_knife',
                label = 'Kniv',
                item = 'weapon_knife',
                type = 'weapon',
                price = 200,
                description = 'En skarp kniv.'
            },
            {
                id = 21,
                name = 'weapon_bat',
                label = 'Baseball Bat',
                item = 'weapon_bat',
                type = 'weapon',
                price = 150,
                description = 'Et baseball bat.'
            },
            {
                id = 22,
                name = 'weapon_knuckle',
                label = 'Knojern',
                item = 'weapon_knuckle',
                type = 'weapon',
                price = 300,
                description = 'Knojern til nærkamp.'
            },
            {
                id = 23,
                name = 'weapon_hammer',
                label = 'Hammer',
                item = 'weapon_hammer',
                type = 'weapon',
                price = 250,
                description = 'En hammer.'
            },
            {
                id = 24,
                name = 'weapon_crowbar',
                label = 'Brækjern',
                item = 'weapon_crowbar',
                type = 'weapon',
                price = 200,
                description = 'Et brækjern.'
            },
            {
                id = 25,
                name = 'weapon_golfclub',
                label = 'Golfkølle',
                item = 'weapon_golfclub',
                type = 'weapon',
                price = 300,
                description = 'En golfkølle.'
            },
            {
                id = 26,
                name = 'weapon_bottle',
                label = 'Flaskeskår',
                item = 'weapon_bottle',
                type = 'weapon',
                price = 100,
                description = 'Et flaskeskår.'
            },
            {
                id = 27,
                name = 'weapon_dagger',
                label = 'Dolk',
                item = 'weapon_dagger',
                type = 'weapon',
                price = 400,
                description = 'En skarp dolk.'
            },
            {
                id = 28,
                name = 'weapon_hatchet',
                label = 'Økse',
                item = 'weapon_hatchet',
                type = 'weapon',
                price = 350,
                description = 'En økse.'
            },
            {
                id = 29,
                name = 'weapon_switchblade',
                label = 'Foldekniv',
                item = 'weapon_switchblade',
                type = 'weapon',
                price = 250,
                description = 'En foldekniv.'
            },
        }
    },
}
