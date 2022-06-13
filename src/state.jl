abstract type AbstractIpState end

"""This structure saves the state of the material."""
struct IpStateSingle{T<:Real} <:AbstractIpState
    data::T
end

"""This structure saves the state of the material."""
struct IpStateArray{T<:Real, N} <:AbstractIpState
    data::AbstractArray{T, N}
end

struct IpState{T} <:AbstractIpState
    data::T
end

"""
This function has to be implemented by the user for different types that they wish to implement.
This function gets the state of the material, If they exist in the Dictionary 
for the given material/integration point in the given element,
it updates the data with the available data in stateDict.
If they don't exist, it just fills the state varibles with zeros.

    data = getState!(data, stateDict, elementNo, integrationPt)
"""
function getIpState!(data::T, stateDict::Dict{Tuple{Int64, Int64}, IpStateSingle},
    elementNo::Int64= 1, integrationPt::Int64=1) where {T <:Real}

    if (elementNo, integrationPt) ∈ keys(stateDict)
        data = stateDict[elementNo, integrationPt].data
    return data
    end
    zero = zeros(typeof(data), 1)
    data = zero[1]
    return data
end

function getIpState!(data::AbstractArray{T,N}, stateDict::Dict{Tuple{Int64, Int64}, IpStateArray},
    elementNo::Int64= 1, integrationPt::Int64=1) where {T <:Real, N}

    if (elementNo, integrationPt) ∈ keys(stateDict)
        data .= stateDict[elementNo, integrationPt].data
    return data
    end
    zero = zeros(T, 1)
    fill!(data, zero[1])
    return data
end

"""This function gets the state of the material, If they exist in the Dictionary 
for the given material/integration point in the given element,
it updates the data with the available data in stateDict.
If they don't exist, it returns the fallback variable. 
The fallback data is mandatory for this reason.

    data = getState(stateDict, fallback, elementNo, integrationPt)"""

function getIpState(stateDict::Dict{Tuple{Int64, Int64}, T}, fallback::T, 
    elementNo::Int64= 1, integrationPt::Int64=1) where {T}

    if (elementNo, integrationPt) ∈ keys(stateDict)
        return stateDict[elementNo, integrationPt]
    end
    return fallback
end

"""
This function updates the StateDict according to the passed data a specific element number and
an integration point within the given element.

    updateStateDict!(data, stateDict, elementNo, integrationPt)
"""
function updateIpStateDict!(data::T1, stateDict::Dict{Tuple{Int64, Int64}, T2},
    elementNo::Int64= 1, integrationPt::Int64=1) where {T1, T2}
    stateDict[elementNo, integrationPt] = T2(data)
    return nothing
end

function updateIpStateDict!(data::T1, stateDict::Dict{Tuple{Int64, Int64}, T1},
    elementNo::Int64= 1, integrationPt::Int64=1) where T1
    stateDict[elementNo, integrationPt] = data
    return nothing
end

"""
This function creates a Dictionary of a give Type to store the state of the material.

    stateDict = createIpStateDict(type)
"""

function createIpStateDict(T::Type)
    return Dict{Tuple{Int64, Int64}, T}()
end

function updateStateDict!(stateDict::Dict{Tuple{Int64, Int64}, T},
    stateDictBuffer::Dict{Tuple{Int64, Int64}, T}) where T
    merge!(stateDict, stateDictBuffer)
end

function updateIpStateDict4rmBuffer!(stateDict::Dict{Tuple{Int64, Int64}, T},
    stateDictBuffer::Dict{Tuple{Int64, Int64}, T}) where T
    updateStateDict!(stateDict, stateDictBuffer)
end
