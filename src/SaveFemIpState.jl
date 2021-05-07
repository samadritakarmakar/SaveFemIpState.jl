module SaveFemIpState

include("state.jl")

export AbstractIpState, IpStateSingle, IpStateArray

export getIpState!, createIpStateDict, updateIpStateDict!, updateIpStateDict4rmBuffer!, updateStateDict!

end # module
