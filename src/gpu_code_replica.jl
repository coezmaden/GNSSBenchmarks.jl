# GPU CuArray Blueprint
function gen_code_replica!(
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
    code_replica = get_codes(code_replica, GPSL1)
end

