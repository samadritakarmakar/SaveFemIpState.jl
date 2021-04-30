module SaveFemIpState

include("state.jl")

export AbstractIpState, IpStateSingle, IpStateArray

export getState!, createStateDict, updateStateDict!, updateIpStateDict!, updateIpStateDict4rmBuffer!

end # module
