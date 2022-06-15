mutable struct IpState{T}
    data::Dict{Tuple{Int64, Int64}, T}
    fallback::T
end

function IpState(fallback::T) where T
    IpState{T}(Dict{Tuple{Int64, Int64}, T}(), fallback)
end

"""
This function creates a Dictionary of the fallback Type to store the state of the material.

    stateDict = createIpStateDict(fallback)
"""

function createIpStateDict(fallback::T) where T
    return IpState(fallback)
end

"""
This function creates a Dictionary of the ipState.fallback Type to store the state of the material. 
It copies the fallback of the given ipStateOther

    stateDict = createIpStateDict(ipStateOther)
"""
function createIpStateDict(ipStateOther::IpState)
    return createIpStateDict(ipStateOther.fallback)
end

"""This function gets the state of the material, If they exist in the Dictionary 
for the given material/integration point in the given element,
if it exists in ipState.data Dictionary.
If they don't exist, it returns the fallback variable. 

    data = getState(ipState, elementNo, integrationPt)"""

function getIpState(ipState::IpState, elementNo::Int64= 1, integrationPt::Int64=1) where {T}
    if (elementNo, integrationPt) ∈ keys(ipState.data)
        return ipState.data[elementNo, integrationPt]
    end
    return ipState.fallback
end

"""This function gets the state of the material, If they exist in the Dictionary 
for the given material/integration point in the given element,
if it exists in ipState.data Dictionary.
If they don't exist, it returns the fallback variable. 

    getState!(data, ipState, elementNo, integrationPt)"""

function getIpState!(data::AbstractArray{T,N}, 
    ipState::IpState, elementNo::Int64= 1, integrationPt::Int64=1) where {T, N}
    if (elementNo, integrationPt) ∈ keys(ipState.data)
        data .= ipState.data[elementNo, integrationPt]
    end
    data .= ipState.fallback
    return nothing
end

"""
This function updates the ipState according to the passed data of
    an integration point number within the given element number.

    updateStateDict!(data, ipState, elementNo, integrationPt)
"""

function updateIpStateDict!(data::T, ipState::IpState{T},
    elementNo::Int64= 1, integrationPt::Int64=1) where T
    ipState.data[elementNo, integrationPt] = data
    return nothing
end

function updateStateDict!(ipState::IpState{T}, ipStateBuffer::IpState{T}) where T
    merge!(ipState.data, ipStateBuffer.data)
    ipState.fallback = deepcopy(ipStateBuffer.fallback)
    return nothing
end

function updateIpStateDict4rmBuffer!(ipState::IpState{T}, ipStateBuffer::IpState{T}) where T
    updateStateDict!(ipState, ipStateBuffer)
end
