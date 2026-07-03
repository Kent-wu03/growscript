return {

    settings = {
        delay = 100,
        world = "TEST",
        useMag = true,
        ids = {1,2,3}
    },

    run = function(cfg)
        while cfg.running do
            Sleep(cfg.delay)
        end
    end

}