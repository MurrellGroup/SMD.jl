module SMD

    include("include_all.jl")

    export

    permutation_test

    # fxns to export

<<<<<<< HEAD:smdfuncs.jl
"""Mutation distance from one population to another"""
function smd_mf(distances_matrix::Array{Float64,2};
                freq1::Vector{Float64}=Float64[],
                freq2::Vector{Float64}=Float64[],
                unbounded_first::Bool=false,
                unbounded_second::Bool=false)
    if (size(distances_matrix)[1] != length(freq1))
        freq1 = ones(size(distances_matrix)[1])
    end
    if (size(distances_matrix)[2] != length(freq2))
        freq2 = ones(size(distances_matrix)[2])
    end

    # init solver
    m = Model(solver = ClpSolver(SolveType=5))

    # flow is a matrix with how much of each distr1 elem maps to how
    # much of each distr2 elem
    @variable(m, flow[1:length(freq1), 1:length(freq2)] >= 0 )

    # constraint: The occurrence of a element "i" in flow is equal to
    # its frequency (normalized)
    if !unbounded_first
        for i = 1:length(freq1)
            @constraint(m, sum(flow[i, :]) == freq1[i] / sum(freq1))
        end
    end

    # constraint: The occurence of a element "j" in flow is equal to
    # its frequency (normalized)
    if !unbounded_second
        for j = 1:length(freq2)
            @constraint(m, sum(flow[:, j]) == freq2[j] / sum(freq2))
        end
    end

    # minimize sum of distance flows
    @objective(m, Min, sum(flow .* distances_matrix))

    status = solve(m)
    return (getobjectivevalue(m), (getvalue(flow)))
end

function smd_sum(distances_matrix::Array{Float64,2};
                freq1::Vector{Float64}=Float64[],
                freq2::Vector{Float64}=Float64[])
	return smd_mf(distances_matrix, freq1, freq2, unbounded_first = true)[2] 
		+ smd_mf(distances_matrix, freq1, freq2, unbounded_second = true)[2]
end

function smd_distance_wrapper(distmat::Array{Float64,2}, inds1, inds2)
    return smd_mf(distmat[inds1, :][:, inds2])[1]
end

function fst_wrapper(distmat, inds1, inds2)
    l1 = length(inds1)
    l2 = length(inds2)
    
    within = (sum([distmat[x,y] for x in inds1, y in inds1])/(l1  - 1 ) + (sum([distmat[x,y] for x in inds2, y in inds2])/(l2 - 1)))/(l1 + l2) 
    between = mean([distmat[x,y] for x in inds1, y in inds2])
    return (between - within)/between
end

function permutation_test(distmat::Array{Float64,2}; l1 = nothing, l2 = nothing, tests=10000, dist_func = smd_distance_wrapper, randvariation=true)
    #Get the upper right quadrant of the huge matrix
    
    if l1 == nothing || l2 == nothing
        l1 = trunc(Int, (size(distmat)[1])/2)
        l2 = ceil(Int, (size(distmat)[1])/2)
    end
    
    group1_selects = 1:l1
    group2_selects = group1_selects + l2
    
    baseline = dist_func(distmat, group1_selects, group2_selects)
        
    array_of_distances = []
    #array_of_distances = zeros(Float64, tests)
    
    for i in 1:tests
        # permuted = shuffle(1:(l1:l2))
        # group1_selects = permuted[1:l1]
        # group2_selects = permuted[l1+1:end]
        group1_selects = shuffle(1:(l1+l2))[1:l1]
        group2_selects = [x for x in 1:(l1+l2) if !(x in group1_selects)]
            
        dist = dist_func(distmat, group1_selects, group2_selects)
        push!(array_of_distances, dist)
        #array_of_distances[i] = dist
    end
    
    if randvariation
        baseline += randn() * 0.00000001
        dist_func = [x + (randn() * 0.00000001) for x in array_of_distances]
    end
    return array_of_distances, baseline
    #return length(array_of_distances .> baseline) > 0 ? sum(array_of_distances .> baseline)/length(array_of_distances) : 1
end
=======
end  # module
>>>>>>> 8fc828a5d631a68f07df39348790bae8760c3250:smd.jl
