# GPU CuArray Blueprint
function gpu_gen_code_replica!(
    code_replica::CuArray{ComplexF32},
    ::Type{S},
    code_frequency,
    sampling_frequency,
    start_code_phase::AbstractFloat,
    start_sample::Integer,
    num_samples::Integer,
    early_late_sample_shift,
    prn::Integer
) where S <: AbstractGNSSSystem
    code_replica = CuArray{ComplexF32}(
        get_code.(
            GPSL1,
            code_frequency .* (1:MAX_NUM_SAMPLES) ./ sampling_frequency .+ start_code_phase,
            prn
        )
    )
end

