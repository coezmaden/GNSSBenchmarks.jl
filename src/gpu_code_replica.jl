# GPU CuArray Blueprint
function gpu_gen_code_replica!(
    code_replica::CuArray{ComplexF32},
    system::AbstractGNSSSystem{T},
    code_frequency,
    sampling_frequency,
    start_code_phase::AbstractFloat,
    start_sample::Integer,
    num_samples::Integer,
    early_late_sample_shift,
    prn::Integer
) where T
    code_replica = GNSSSignals.get_code(
            system,
            code_frequency .* (start_sample:start_sample + num_samples + 2*early_late_sample_shift) ./ sampling_frequency .+ start_code_phase,
            prn
        )
end

# CPU Array Blueprint
function gpu_gen_code_replica!(
    code_replica::Array,
    system::AbstractGNSSSystem,
    code_frequency,
    sampling_frequency,
    start_code_phase::AbstractFloat,
    start_sample::Integer,
    num_samples::Integer,
    early_late_sample_shift,
    prn::Integer
)
    code_replica = GNSSSignals.get_code(
            system,
            code_frequency .* (start_sample:start_sample + num_samples + 2*early_late_sample_shift) ./ sampling_frequency .+ start_code_phase,
            prn
        )
end
