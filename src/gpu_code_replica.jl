# GPU CuArray Blueprint
function gpu_gen_code_replica!(
    code_replica::CuArray{ComplexF32},
    system::AbstractGNSSSystem,
    code_frequency,
    sampling_frequency,
    start_code_phase::AbstractFloat,
    start_sample::Integer,
    num_samples::Integer,
    early_late_sample_shift,
    prn::Integer
)
    # code_replica] = GNSSSignals.get_code(
    #         system,
    #         code_frequency .* (start_sample:start_sample + num_samples + 2*early_late_sample_shift) ./ sampling_frequency .+ start_code_phase,
    #         prn
    #     )
    idxs = start_sample:start_sample - 1 + num_samples + 2*early_late_sample_shift
    phases = code_frequency .* (0:num_samples - 1 + 2 * early_late_sample_shift) ./ sampling_frequency .+ start_code_phase
    code_length = get_code_length(system) * get_secondary_code_length(system)
    @inbounds @views code_replica[idxs] .= system.codes[2 .+ mod.(floor.(Int, phases), code_length), prn]
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
    # code_replica = GNSSSignals.get_code(
    #         system,
    #         code_frequency .* (start_sample:start_sample + num_samples + 2*early_late_sample_shift) ./ sampling_frequency .+ start_code_phase,
    #         prn
    #     )
    idxs = start_sample:start_sample - 1 + num_samples + 2*early_late_sample_shift
    phases = code_frequency .* (0:num_samples - 1 + 2 * early_late_sample_shift) ./ sampling_frequency .+ start_code_phase
    code_length = get_code_length(system) * get_secondary_code_length(system)
    @inbounds @views code_replica[idxs] .= system.codes[2 .+ mod.(floor.(Int, phases), code_length), prn]
end
