top = dummy_topology(4)

frame = Frame(top)

cell = UnitCell(10.)

frame.positions[1] = [2, 2, 4]
frame.positions[2] = [2, 2, 2]
frame.positions[3] = [1, 2, 3]
frame.positions[4] = [29, 22, 45]

#TODO: more tests here
