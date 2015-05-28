
facts("Frame type") do
    frame = Frame(3)
    @fact size(frame) => 3

    frame = Frame()
    @fact size(frame) => 0

    set_frame_size!(frame, 10)
    @fact size(frame) => 10

    set_frame_size!(frame, 20, velocities=true)
    @fact size(frame) => 20
    @fact size(frame.velocities) => (3,20)
end
