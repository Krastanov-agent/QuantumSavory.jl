@testitem "Apply" begin
using Test
using QuantumSavory

function ensure_qcgate_sequence_binding!()
    qcext = Base.get_extension(QuantumSavory.QuantumSymbolics, :QuantumCliffordExt)
    qcext === nothing && return
    isdefined(qcext, :QCGateSequence) && return
    Core.eval(qcext, :(const QCGateSequence = $(QuantumSavory).QCGateSequence))
end

ensure_qcgate_sequence_binding!()

gate = tensor(X, Z)
@test express(gate, CliffordRepr(), UseAsOperation()) isa QuantumSavory.QCGateSequence

reg = Register([Qubit(), Qubit()], [CliffordRepr(), CliffordRepr()])
initialize!(reg[1], Z1)
initialize!(reg[2], X1)
apply!(reg[1:2], gate)

@test observable(reg[1], Z) ≈ -1
@test observable(reg[2], X) ≈ -1

end
