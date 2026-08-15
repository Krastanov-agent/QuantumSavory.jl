using CairoMakie
using ConcurrentSim
using Graphs
using QuantumSavory
using QuantumSavory.ProtocolZoo
using ResumableFunctions

const FLOW_IDS = collect(1001:1020)

graph = path_graph(3)
net = RegisterNet(
    graph,
    [Register(32) for _ in vertices(graph)];
    classical_delay=1e-6,
    names=["Amherst", "Boston", "Cambridge"],
)
sim = get_time_tracker(net)

for node in (1, 3)
    @process EndNodeController(net, node)()
end

controllers = [NetworkNodeController(net, node) for node in vertices(graph)]
for controller in controllers
    @process controller()
end
for edge in edges(net)
    @process LinkController(net, edge.src, edge.dst)()
end

for flow_id in FLOW_IDS
    put!(net[1], Flow(src=1, dst=3, npairs=1, uuid=flow_id))
end
run(sim, 30.0)

controller = controllers[1]
observed_flows = sort!(unique(event.flow_id for event in controller._log))
processed = filter(event -> event.processed, controller._log)
@assert observed_flows == FLOW_IDS
@assert length(processed) == length(FLOW_IDS)
@assert all(iszero(statistic.backlog) for statistic in QuantumSavory.ProtocolZoo.QTCP._network_node_controller_statistics(controller))

open("network-node-controller-20-flows.png", "w") do io
    show(io, MIME"image/png"(), controller)
end

html = repr(MIME"text/html"(), controller)
open("network-node-controller-20-flows.html", "w") do io
    print(io, "<!doctype html><html><head><meta charset=\"utf-8\"><title>NetworkNodeController — 20 flows</title></head><body>")
    print(io, html)
    print(io, "</body></html>")
end

println("Rendered $(length(observed_flows)) flows and $(length(processed)) processed QDatagrams at simulation time $(ConcurrentSim.now(sim)).")
