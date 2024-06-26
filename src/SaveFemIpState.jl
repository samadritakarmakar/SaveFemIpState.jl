module SaveFemIpState
include("state.jl")
include("ipState.jl")
include("ipStateMt.jl")


AbstractIpState = Union{Dict{Tuple{Int64, Int64}, IpStateSingle}, 
Dict{Tuple{Int64, Int64}, IpStateArray}, IpState}

#from state.jl
export AbstractIpState, IpStateSingle, IpStateArray
#from ipState.jl
export IpState
#from common
export getIpState!, getIpState, createIpStateDict, updateIpStateDict!, updateIpStateDict4rmBuffer!, updateStateDict!
#from ipStateMt
export IpStateMultiThread, createIpStateDictMultiThread, getSingleMergedDict
end # module
