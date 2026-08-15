# NetworkNodeController PR renderings

These files were generated from feature commit `b9ae8e79` for issue #531. The
fixture uses the existing five-node same-chain QTCP scenario with flows 301 and
302 and renders the controller on node 2 after 12 simulation-time units.

- `network-node-controller.png` is the `image/png` representation.
- `network-node-controller.html` is the `text/html` representation.
- `network-node-controller-html.png` is a browser rendering of that HTML.
- `render-network-node-controller.jl` reproduces the PNG.

## Twenty-flow follow-up

The `network-node-controller-20-flows*` files use a three-node chain with 20
one-pair flows from node 1 to node 3. They render the controller at node 1 after
30 simulation-time units. The generic `show` method allocates three plot rows,
giving the default `(600, 1400)` logical canvas without a theme override.

`render-network-node-controller-20-flows.jl` is the script used to produce the
PNG and HTML source. The HTML screenshot was produced with headless Chromium.
