Config = {
    Gangs = {
  
        ["woo"] = {-- gang_name in MySQL->gangs table
        Markers = {
            Management = {
                Location = {x = -265.08, y = -962.95, z = 31.22},
                Color = {r = 255, g = 0, b = 0},
            },
            VehicleSpawn = {
                Location = {x = -3202.96, y = 834.78, z = 8.93},
                Color = {r = 255, g = 0, b = 0},
            },
            VehicleReturn = {
                Location = {x = -3214.92, y = 834.83, z = 8.93, h = 215.91},
                Color = {r = 255, g = 0, b = 0},
            },
        },
        Vehicles = {
            ["insurgent3"] = 0, -- Modelname = k, Price = v ( [k] = v )
            ["supervolito2"] = 0,
        },
    },
        ["otf"] = {-- gang_name in MySQL->gangs table
        Markers = {
            Management = {
                Location = {x = -265.08, y = -962.95, z = 31.22},
                Color = {r = 255, g = 0, b = 0},
            },
            VehicleSpawn = {
                Location = {x = -128.24, y = 1009.32, z = 234.73},
                Color = {r = 255, g = 0, b = 0},
            },
            VehicleReturn = {
                Location = {x = -125.36, y = 1001.43, z = 234.73, h = 196.72},
                Color = {r = 255, g = 0, b = 0},
            },
        },
        Vehicles = {
            ["insurgent3"] = 0, -- Modelname = k, Price = v ( [k] = v )
            ["supervolito2"] = 0,
        },
    },
        ["gd"] = {-- gang_name in MySQL->gangs table
            Markers = {
                Management = {
                    Location = {x = -265.08, y = -962.95, z = 31.22},
                    Color = {r = 255, g = 255, b = 0},
                },
                VehicleSpawn = {
                    Location = {x = 1398.44, y = 1114.84, z = 113.84},
                    Color = {r = 255, g = 255, b = 0},
                },
                VehicleReturn = {
                    Location = {x = 1407.05, y = 1119.66, z = 113.84, h = 87.32},
                    Color = {r = 255, g = 255, b = 0},
                },
            },
            Vehicles = {
                ["insurgent3"] = 0, -- Modelname = k, Price = v ( [k] = v )
                ["supervolito2"] = 0,
            },
        },
        
        Zones = {
            ["methfarm"] = {
                Location = {x = 126.135, y = -1278.583, z = 29.270},
                Blip = {id = 42, color = 1},
                Color = {r = 232, g = 232, b = 232},
                Label = "Meth Farm",
                Rewards = {
                    ["cash"] = 0,
                    ["dcash"] = 450000,
                    ["items"] = {
                        ["meth_pooch"] = 0,
                    }
                },
            },
            ["cokefarm"] = {
                Location = {x = 1383.31, y = -600.33, z = 73.34},
                Blip = {id = 42, color = 1},
                Color = {r = 232, g = 232, b = 232},
                Label = "Coke Farm",
                Rewards = {
                    ["cash"] = 0,
                    ["dcash"] = 450000,
                    ["items"] = {
                    ["coke_pooch"] = 0,
                    }
                },
            },
            ["codeinefarm"] = {
                Location = {x = 226.84, y = -171.43, z = 55.37},
                Blip = {id = 42, color = 1},
                Color = {r = 232, g = 232, b = 232},
                Label = "Codeine Farm",
                Rewards = {
                    ["cash"] = 0,
                    ["dcash"] = 450000,
                    ["items"] = {
                    ["codeine_pooch"] = 0,
                    }
                },
            },
            ["percfarm"] = {
                Location = {x = 239.85, y = 355.74, z = 104.60},
                Blip = {id = 42, color = 1},
                Color = {r = 232, g = 232, b = 232},
                Label = "Perc Farm",
                Rewards = {
                    ["cash"] = 0,
                    ["dcash"] = 450000,
                    ["items"] = {
                    ["perc_pooch"] = 0,
                    }
                },
            },
            ["heroinfarm"] = {
                Location = {x = 868.90, y = -915.15, z = 25.04},
                Blip = {id = 42, color = 1},
                Color = {r = 232, g = 232, b = 232},
                Label = "Heroin Farm",
                Rewards = {
                    ["cash"] = 0,
                    ["dcash"] = 450000,
                    ["items"] = {
                    ["heroin_pooch"] = 0,
                    }
                },
            },
            ["xanaxfarm"] = {
                Location = {x = -1374.84, y = -327.20, z = 38.43},
                Blip = {id = 42, color = 1},
                Color = {r = 232, g = 232, b = 232},
                Label = "Xanax Farm",
                Rewards = {
                    ["cash"] = 0,
                    ["dcash"] = 450000,
                    ["items"] = {
                    ["xanax_pooch"] = 0,
                    }
                },
            },
            ["weedfarm"] = {
                Location = {x = 99999999, y = 9999999, z = 8999999},
                Blip = {id = 42, color = 1},
                Color = {r = 232, g = 232, b = 232},
                Label = "Weed Field",
                Rewards = {
                    ["cash"] = 0,
                    ["dcash"] = 450000,
                    ["items"] = {
                    ["weed"] = 0,
                    }
                },
            },
            ["moneywash"] = {
                Location = {x = 900.39, y = -183.16, z = 72.87},
                Blip = {id = 42, color = 1},
                Color = {r = 232, g = 232, b = 232},
                Label = "Moneywash",
                Rewards = {
                    ["cash"] = 0,
                    ["dcash"] = 450000,
                    ["items"] = {
                        
                    }
                },
            },
        },
        AdministrativeGroups = {
            "admin",
            "superadmin",
        },
        CaptureTimer = 180, -- seconds 
        CaptureCooldown = 600, -- seconds
        WaitPeriod = 500,
        VehicleSpawnTimer = 0,
        ContestedColor = {r = 0, g = 0, b = 255},
    }
}