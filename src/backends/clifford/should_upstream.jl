
struct QCGateSequence <: QuantumClifford.AbstractSymbolicOperator
    gates # TODO constructor that flattens nested QCGateSequence
end
function QuantumClifford.apply!(state::QuantumClifford.MixedDestabilizer, gseq::QCGateSequence, indices::AbstractVector{Int})
    for g in gseq.gates[end:-1:begin]
        apply_popindex!(state, g, indices)
    end
    state
end
QuantumClifford.apply!(state::QuantumClifford.MixedDestabilizer, indices::AbstractVector{Int}, gseq::QCGateSequence) =
    QuantumClifford.apply!(state, gseq, indices)
apply_popindex!(state, g::Type{<:QuantumClifford.AbstractSingleQubitOperator}, indices::AbstractVector{Int}) =
    QuantumClifford.apply!(state, g(pop!(indices)::Int))
apply_popindex!(state, g::Type{<:QuantumClifford.AbstractTwoQubitOperator}, indices::AbstractVector{Int}) =
    QuantumClifford.apply!(state, g(pop!(indices)::Int, pop!(indices)::Int))

projector(state::QuantumClifford.Stabilizer) = projector(StabilizerState(state)) # convert to a type that QuantumSymbolics can handle
