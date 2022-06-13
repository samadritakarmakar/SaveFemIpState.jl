module SaveFemIpState

include("state.jl")
include("ipState.jl")

AbstractIpState = Union{Dict{Tuple{Int64, Int64}, IpStateSingle}, 
Dict{Tuple{Int64, Int64}, IpStateArray}, IpState}

export AbstractIpState, IpStateSingle, IpStateArray

export getIpState!, getIpState, createIpStateDict, updateIpStateDict!, updateIpStateDict4rmBuffer!, updateStateDict!

end # module
