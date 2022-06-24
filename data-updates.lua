if battery_powered.is_k2 then
    -- K2 changes fuel-categories in this data stage, redo our changes so MultipleUnitTrainControl will see them
    require("code.data.vehicle-fuel")
end