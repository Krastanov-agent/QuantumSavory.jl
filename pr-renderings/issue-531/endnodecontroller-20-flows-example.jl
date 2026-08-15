using QuantumSavory
using QuantumSavory.ProtocolZoo
using ConcurrentSim
using Graphs
using CairoMakie

const FLOW_COUNT = 20
const HUB = 1

graph = SimpleGraph(FLOW_COUNT + 1)
for peer in 2:nv(graph)
    add_edge!(graph, HUB, peer)
end

registers = [Register(node == HUB ? FLOW_COUNT + 4 : 2) for node in vertices(graph)]
names = ["Hub"; ["Peer $(lpad(peer - 1, 2, '0'))" for peer in 2:nv(graph)]]
net = RegisterNet(
    graph,
    registers;
    classical_delay=1e-3,
    name="20-flow QTCP star",
    names,
)
sim = get_time_tracker(net)

controllers = Dict{Int,EndNodeController}()
for node in vertices(graph)
    controller = EndNodeController(net, node)
    controllers[node] = controller
    @process controller()
    @process NetworkNodeController(net, node)()
end
for edge in edges(graph)
    @process LinkController(net, edge.src, edge.dst)()
end

for (index, peer) in enumerate(2:nv(graph))
    put!(net[HUB], Flow(src=HUB, dst=peer, npairs=1, uuid=1000 + index))
end
run(sim, 1000.0)

controller = controllers[HUB]
@assert length(controller._log) == FLOW_COUNT
@assert all(stats.delivered == 1 for stats in values(controller._log))

CairoMakie.with_theme(size=(800, 2200)) do
    open("/tmp/qtcp-endnodecontroller-20-flows-image-png.png", "w") do io
        show(io, MIME"image/png"(), controller)
    end
end

body = repr(MIME"text/html"(), controller)
document = """
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <style>
    body { color: #24292f; font-family: sans-serif; margin: 2rem; }
    .quantumsavory_show { max-width: 1000px; }
    h1 { font-size: 1.5rem; margin-bottom: 0.25rem; }
    address { margin-bottom: 1.5rem; }
    .quantumsavory_protocol_flow { margin: 0.55rem 0; }
    .quantumsavory_protocol_local_node {
      background: #ddf4ff; border: 1px solid #54aeff; border-radius: 4px;
      padding: 0.2rem 0.4rem;
    }
    .quantumsavory_protocol_flow_arrow { margin: 0 0.5rem; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #d0d7de; padding: 0.5rem; text-align: right; }
    th:first-child { text-align: left; }
    thead { background: #f6f8fa; }
  </style>
</head>
<body>$(body)</body>
</html>
"""
write("/tmp/qtcp-endnodecontroller-20-flows-text-html.html", document)

latencies = [stats.latency_sum / stats.delivered for stats in values(controller._log)]
println("observed_flows=$(length(controller._log))")
println("delivered_pairs=$(sum(stats.delivered for stats in values(controller._log)))")
println("latency_range=$(extrema(latencies))")
