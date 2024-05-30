mutable struct IpStateMultiThread{T}
    data::Vector{Dict{Tuple{Int64, Int64}, T}}
    fallback::T
    noOfElemmentsPerThread::Int64
end

function IpStateMultiThread(fallback::T, totalNoOfElements::Int64, noOfThreads = Threads.nthreads()) where T
    data = Vector{Dict{Tuple{Int64, Int64}, T}}(undef, noOfThreads)
    for i ∈ 1:noOfThreads
        data[i] = Dict{Tuple{Int64, Int64}, T}()
    end
    totalNoOfElementsPerThread = ceil(Int64, totalNoOfElements/noOfThreads)
    IpStateMultiThread{T}(data, fallback, totalNoOfElementsPerThread)
end

"""
This function creates a Dictionary of the fallback Type to store the state of the material.

    stateDict = createIpStateDictMultiThread(fallback, totalNoOfElements)
"""

function createIpStateDictMultiThread(fallback::T, totalNoOfElements::Int64) where T
    return IpStateMultiThread(fallback, totalNoOfElements)
end

"""
This function creates a Dictionary of the ipStateMultiThread.fallback Type to store the state of the material. 
It copies the fallback and the noOfElemmentsPerThread of the given ipStateOther 

    stateDict = createIpStateDictMultiThread(ipStateOther)
"""
function createIpStateDictMultiThread(ipStateOther::IpStateMultiThread)
    return createIpStateDictMultiThread(ipStateOther.fallback, ipStateOther.noOfElemmentsPerThread)
end

"""This function gets the state of the material, If they exist in the Dictionary 
for the given material/integration point in the given element,
if it exists in ipStateMultiThread.data Dictionary.
If they don't exist, it returns the fallback variable. 

    data = getState(ipState, elementNo, integrationPt)"""

function getIpState(ipState::IpStateMultiThread, elementNo::Int64= 1, integrationPt::Int64=1, threadNo::Int64=Threads.threadid())
    if (elementNo, integrationPt) ∈ keys(ipState.data[threadNo])
        return ipState.data[threadNo][elementNo, integrationPt]
    end
    return deepcopy(ipState.fallback)
end

"""This function gets the state of the material, If they exist in the Dictionary 
for the given material/integration point in the given element,
if it exists in ipState.data Dictionary.
If they don't exist, it returns the fallback variable. 

    getState!(data, ipState, elementNo, integrationPt)"""

function getIpState!(data::AbstractArray{T,N}, 
    ipState::IpStateMultiThread, elementNo::Int64= 1, integrationPt::Int64=1, threadNo::Int64=Threads.threadid()) where {T, N}
    if (elementNo, integrationPt) ∈ keys(ipState.data[threadNo])
        data .= ipState.data[threadNo][elementNo, integrationPt]
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

function updateIpStateDict!(data::T, ipState::IpStateMultiThread{T},
    elementNo::Int64= 1, integrationPt::Int64=1, threadNo::Int64=Threads.threadid()) where T
    if (elementNo, integrationPt) ∉ keys(ipState.data[threadNo])
        ipState.data[threadNo][elementNo, integrationPt] = deepcopy(data)
    else
        try
            ipState.data[threadNo][elementNo, integrationPt] .= data
        catch
            ipState.data[threadNo][elementNo, integrationPt] = data
        end

    end
    return nothing
end

#=function updateStateDict!(ipState::IpStateMultiThread{T}, ipStateBuffer::IpStateMultiThread{T}) where T
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
end=#


