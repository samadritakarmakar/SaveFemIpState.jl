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
This function creates a Dictionary of the fallback Type to store the state of the material.
This function is to be used for multithreaded applications.

    stateDict = createIpStateDict(fallback)
"""
function createIpStateDict(fallback::T, noOfElements::Int64, noOfIntPtsPerElement::Int64) where T
    data = Dict{Tuple{Int64, Int64}, T}()
    for elementNo ∈ 1:noOfElements
        for ipNo ∈ 1:noOfIntPtsPerElement
            data[elementNo, ipNo] = deepcopy(fallback)
        end
    end
    return IpState(data, fallback)
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

function getIpState(ipState::IpState, elementNo::Int64= 1, integrationPt::Int64=1)
    if (elementNo, integrationPt) ∈ keys(ipState.data)
        return ipState.data[elementNo, integrationPt]
    end
    return deepcopy(ipState.fallback)
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
        return data
    else
        data .= ipState.fallback
        return data
    end
    return nothing
end


"""
This function updates the ipState according to the passed data of
    an integration point number within the given element number.

    updateStateDict!(data, ipState, elementNo, integrationPt)
"""

function updateIpStateDict!(data::T, ipState::IpState{T},
    elementNo::Int64= 1, integrationPt::Int64=1) where T
    if (elementNo, integrationPt) ∉ keys(ipState.data)
        ipState.data[elementNo, integrationPt] = deepcopy(data)
    else
        try
            ipState.data[elementNo, integrationPt] .= data
        catch
            ipState.data[elementNo, integrationPt] = data
        end

    end
    return nothing
end

function updateStateDict!(ipState::IpState{T}, ipStateBuffer::IpState{T}) where T
    for i ∈ keys(ipStateBuffer.data)
        if i ∈ keys(ipState.data)
            try
                ipState.data[i] .=ipStateBuffer.data[i]
            catch
                ipState.data[i] = ipStateBuffer.data[i]
            end
            
        else
            ipState.data[i] = deepcopy(ipStateBuffer.data[i])
        end
    end
    try
        ipState.fallback .= ipStateBuffer.fallback
    catch
        ipState.fallback = deepcopy(ipStateBuffer.fallback)
    end
    return nothing
end

function updateIpStateDict4rmBuffer!(ipState::IpState{T}, ipStateBuffer::IpState{T}) where T
    updateStateDict!(ipState, ipStateBuffer)
end
