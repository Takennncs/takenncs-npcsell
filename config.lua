cfg = {}

cfg.selldrugs = {
    gold_ring = math.random(250, 350),
    gold_earring = math.random(300, 400),
    silver_ring = math.random(150, 250),
    silverearring = math.random(200, 300),
    silverchain = math.random(250, 350),
    diamond_ring = math.random(500, 700), 
    diamond_necklace = math.random(900, 1100),
    diamond_necklace_silver = math.random(750, 950),
    diamond_earring = math.random(450, 550)
}

cfg.selldistance = 3.5

cfg.locale = "en" -- kui tahad, siis pane en ja saad english language endale.....

Locales = {}

local function loadLocales()
    local files = {'et', 'en'}
    for _, file in ipairs(files) do
        local locale = LoadResourceFile(GetCurrentResourceName(), "locales/" .. file .. ".lua")
        if locale then
            local func, err = load(locale)
            if func then
                func() 
            else

            end
        else
        end
    end
end
loadLocales()