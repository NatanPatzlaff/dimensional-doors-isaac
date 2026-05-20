return {
    {
        TYPE = RoomType.ROOM_DEFAULT,
        VARIANT = 0,
        SUBTYPE = 0,
        NAME = "Land of Ooo - Start",
        DIFFICULTY = 1,
        WEIGHT = 1,
        WIDTH = 13,
        HEIGHT = 7,
        SHAPE = RoomShape.ROOMSHAPE_1x1,
        DOORS = {}, -- Vamos deixar o jogo gerenciar portas caso haja mais salas depois
        SPAWN_ENTS = {
            -- Exemplo: spawn de um pickup no centro
            -- {TYPE = 5, VARIANT = 10, SUBTYPE = 0, X = 6, Y = 3} 
        },
        SPAWN_GRIDS = {
            -- {TYPE = 1000, VARIANT = 0, X = 6, Y = 3} -- Exemplo de grid
        }
    }
}
