# GPU CuArray
function gpu_gen_carrier_replica!(
    carrier_replica::CuArray{ComplexF32},
    carrier_frequency,
    sampling_frequency,
    start_phase,
    carrier_amplitude_power,
    start_sample,
    num_samples
)
    @. @views carrier_replica[start_sample:num_samples] = cis(2pi * (1:num_samples) * carrier_frequency / sampling_frequency + start_phase)
end

# GPU StructArray of CuArrays
function gpu_gen_carrier_replica!(
    carrier_replica::StructOfCuVectors,
    carrier_frequency,
    sampling_frequency,
    start_phase,
    carrier_amplitude_power,
    start_sample,
    num_samples
)where{
    StructOfCuVectors <: StructArray{Complex{Float32},1,NamedTuple{(:re, :im),Tuple{CuArray{Float32,1},CuArray{Float32,1}}},Int64}
}
    @. carrier_replica.re = 2pi * (1:num_samples) * carrier_frequency / sampling_frequency + start_phase
    @. carrier_replica.im = sin(carrier_replica.re)
    @. carrier_replica.re = cos(carrier_replica.re)
    return carrier_replica
end

# CPU StructArray 
function cpu_gen_carrier_replica!(
    carrier_replica::StructOfVectors,
    carrier_frequency,
    sampling_frequency,
    start_phase,
    carrier_amplitude_power,
    start_sample,
    num_samples
) where {
    StructOfVectors <: StructArray{Complex{Float32},1,NamedTuple{(:re, :im),Tuple{Array{Float32,1},Array{Float32,1}}},Int64}
}
    @. carrier_replica.re = 2pi * (1:num_samples) * carrier_frequency / sampling_frequency + start_phase
    @avx unroll = 6 for i = start_sample:num_samples + start_sample - 1
        carrier_replica.im[i] = sin(carrier_replica.re[i])
        carrier_replica.re[i] = cos(carrier_replica.re[i])
    end
    return carrier_replica
end