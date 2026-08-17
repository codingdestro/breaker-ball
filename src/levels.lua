local Levels = {}

-- Brick key: S=standard, T=tough, A=armored, E=explosive, M=moving, I=indestructible.
-- All level rows are 10 columns wide.

Levels.list = {
    {
        name = "WARM UP",
        ballSpeed = 320,
        bricks = {
            "SSSSSSSSSS",
            "SSSSSSSSSS",
            "SSSSSSSSSS",
            "SSSSSSSSSS",
        },
    },
    {
        name = "NEON ROWS",
        ballSpeed = 330,
        bricks = {
            "SSSSSSSSSS",
            "SSSSSSSSSS",
            "SSSSSSSSSS",
            "SSSSSSSSSS",
            "SSSSSSSSSS",
        },
    },
    {
        name = "TOUGH MOVERS",
        ballSpeed = 340,
        bricks = {
            "SSSSSSSSSS",
            "TTTTTTTTTT",
            "MMMMMMMMMM",
            "SSSSSSSSSS",
            "TTTTTTTTTT",
        },
    },
    {
        name = "SLIDE ZONE",
        ballSpeed = 350,
        bricks = {
            "SSSSSSSSSS",
            "MMMMMMMMMM",
            "TTTTTTTTTT",
            "MMMMMMMMMM",
            "SSSSSSSSSS",
        },
    },
    {
        name = "DETONATE",
        ballSpeed = 360,
        bricks = {
            "SSSSSSSSSS",
            "SSEESSEESS",
            "SSSSSSSSSS",
            "SEESSSEESS",
            "SSSSSSSSSS",
        },
    },
    {
        name = "ARMORED WALL",
        ballSpeed = 370,
        bricks = {
            "AAAAAAAAAA",
            "SSSSSSSSSS",
            "IISSSSSSII",
            "TTTTTTTTTT",
            "SSSSSSSSSS",
        },
    },
    {
        name = "FORTRESS",
        ballSpeed = 380,
        bricks = {
            "IIIIIIIIII",
            "AAAAAAAAAA",
            "SSSSSSSSSS",
            "TTTTTTTTTT",
            "IIIIIIIIII",
        },
    },
    {
        name = "TIGHT CORRIDOR",
        ballSpeed = 390,
        bricks = {
            "SSSSSSSSSS",
            "MMTTTTTTMM",
            "SSSSSSSSSS",
            "MMTTTTTTMM",
            "SSSSSSSSSS",
        },
    },
    {
        name = "THE MIX",
        ballSpeed = 400,
        bricks = {
            "SSTTSSTTSS",
            "MMAEESSEAM",
            "SSSSTTSSSS",
            "AAEESSSEEA",
            "SSSSTTSSSS",
            "MMSSTTSSMM",
        },
    },
    {
        name = "FINAL WAVE",
        ballSpeed = 420,
        bricks = {
            "IISSSSSSII",
            "AAAAAAAAAA",
            "MMSSEESSMM",
            "TTTTTTTTTT",
            "SSSSSSSSSS",
            "MMSSEESSMM",
            "IISSSSSSII",
        },
    },
}

return Levels
