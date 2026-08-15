# NetworkNodeController PR renderings

These files were generated from feature commit `97ff035c` for issue #531. The
fixture uses the existing five-node same-chain QTCP scenario with flows 301 and
302 and renders the controller on node 2 after 12 simulation-time units.

- `network-node-controller.png` is the `image/png` representation.
- `network-node-controller.html` is the `text/html` representation.
- `network-node-controller-html.png` is a browser rendering of that HTML.

## Twenty-flow follow-up

The `network-node-controller-20-flows*` files use a three-node chain with 20
one-pair flows from node 1 to node 3. They render the controller at node 1 after
30 simulation-time units. The PNG uses Makie's default theme with a larger
`(1000, 1600)` canvas so that all 20 table and legend rows fit.

`render-network-node-controller-20-flows.jl` is the script used to produce the
PNG and HTML source. The HTML screenshot was produced with headless Chromium.
