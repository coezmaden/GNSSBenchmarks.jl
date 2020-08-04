# StructArray of CuArrays
function gpu_gen_carrier_replica!(
    carrier_replica::StructArray{ComplexF32},
    carrier_frequency,
    sampling_frequency,
    start_phase,
    carrier_amplitude_power,
    start_sample,
    num_samples
)
    @. carrier_replica.re = 2pi * (1:num_samples) * carrier_frequency / sampling_frequency + start_phase
    @. carrier_replica.im = sin(carrier_replica.re)
    @. carrier_replica.re = cos(carrier_replica.re)
    return carrier_replica
end

# CuArray
function gpu_gen_carrier_replica!(
    carrier_replica::CuArray{ComplexF32},
    carrier_frequency,
    sampling_frequency,
    start_phase,
    carrier_amplitude_power,
    start_sample,
    num_samples
)
    @. carrier_replica = cis(2pi * (1:num_samples) * carrier_frequency / sampling_frequency + start_phase)
end

# Float32 implementation of the orig. CPU function
function gpu_gen_carrier_replica!(
    carrier_replica::Array{ComplexF32},
    carrier_frequency,
    sampling_frequency,
    start_phase,
    carrier_amplitude_power,
    start_sample,
    num_samples
)
    @. carrier_replica = cis(2pi * (1:num_samples) * carrier_frequency / sampling_frequency + start_phase)
    return carrier_replica
end