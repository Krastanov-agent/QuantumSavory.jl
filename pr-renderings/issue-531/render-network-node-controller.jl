using CairoMakie
using ConcurrentSim
using Graphs
using QuantumSavory
using QuantumSavory.ProtocolZoo
using ResumableFunctions

graph = path_graph(5)
net = RegisterNet(
    graph,
    [Register(12) for _ in vertices(graph)];
    classical_delay=1e-6,
    names=["Amherst", "Boston", "Cambridge", "Dover", "Essex"],
)
sim = get_time_tracker(net)

for node in (1, 2, 4, 5)
    @process EndNodeController(net, node)()
end

controllers = [NetworkNodeController(net, node) for node in vertices(graph)]
for controller in controllers
    @process controller()
end
for edge in edges(net)
    @process LinkController(net, edge.src, edge.dst)()
end

put!(net[1], Flow(src=1, dst=5, npairs=2, uuid=301))
put!(net[2], Flow(src=2, dst=4, npairs=2, uuid=302))
run(sim, 12.0)

controller = controllers[2]
@assert sort!(unique(event.flow_id for event in controller._log)) == [301, 302]
@assert all(
    iszero(statistic.backlog) for
    statistic in QuantumSavory.ProtocolZoo.QTCP._network_node_controller_statistics(controller)
)

open("network-node-controller.png", "w") do io
    show(io, MIME"image/png"(), controller)
end

println("Rendered 2 flows at simulation time $(ConcurrentSim.now(sim)).")
