function gpu_track(
    signal,
    state::GNSSBenchmarks.gpuTrackingState{S, C, CALF, COLF, CN, DS},
    prn::Integer,
    sampling_frequency;
    post_corr_filter = get_default_post_corr_filter(GNSSBenchmarks.get_correlator(state)),
    intermediate_frequency = 0.0Hz,
    max_integration_time::typeof(1ms) = 1ms,
    min_integration_time::typeof(1.0ms) = 0.75ms,
    early_late_sample_shift = get_early_late_sample_shift(S,
        GNSSBenchmarks.get_correlator(state), sampling_frequency, 0.5),
    carrier_loop_filter_bandwidth = 18Hz,
    code_loop_filter_bandwidth = 1Hz,
    velocity_aiding = 0Hz,
    carrier_amplitude_power::Val{N} = Val(5)
) where {
S <: AbstractGNSSSystem,
C <: AbstractCorrelator,
CALF <: AbstractLoopFilter,
COLF <: AbstractLoopFilter,
CN <: AbstractCN0Estimator,
DS <: CuArray,
N
}
correlator = GNSSBenchmarks.get_correlator(state)
downconverted_signal = resize!(GNSSBenchmarks.get_downconverted_signal(state), size(signal, 1))
carrier_replica = resize!(GNSSBenchmarks.get_carrier(state), size(signal, 1))
code_replica = resize!(GNSSBenchmarks.get_code(state), size(signal, 1) + 2 * maximum(early_late_sample_shift))
init_carrier_doppler = GNSSBenchmarks.get_init_carrier_doppler(state)
init_code_doppler = GNSSBenchmarks.get_init_code_doppler(state)
carrier_doppler = GNSSBenchmarks.get_carrier_doppler(state)
code_doppler = GNSSBenchmarks.get_code_doppler(state)
carrier_phase = GNSSBenchmarks.get_carrier_phase(state)
code_phase = GNSSBenchmarks.get_code_phase(state)
sc_bit_detector = GNSSBenchmarks.get_sc_bit_detector(state)
carrier_loop_filter = GNSSBenchmarks.get_carrier_loop_filter(state)
code_loop_filter = GNSSBenchmarks.get_code_loop_filter(state)
prompt_accumulator = GNSSBenchmarks.get_prompt_accumulator(state)
integrated_samples = GNSSBenchmarks.get_integrated_samples(state)
cn0_estimator = GNSSBenchmarks.get_cn0_estimator(state)
signal_start_sample = 1
bit_buffer = Tracking.BitBuffer()
valid_correlator = zero(correlator)
got_correlator = false
while true
    num_samples_left_to_integrate = get_num_samples_left_to_integrate(
        S,
        max_integration_time,
        sampling_frequency,
        code_doppler,
        code_phase,
        found(sc_bit_detector)
    )
    signal_samples_left = get_num_samples(signal) - signal_start_sample + 1
    num_samples_left = min(num_samples_left_to_integrate, signal_samples_left)
    carrier_frequency = get_current_carrier_frequency(
        intermediate_frequency,
        carrier_doppler
    )
    code_frequency = get_current_code_frequency(S, code_doppler)
    code_replica = GNSSBenchmarks.gpu_gen_code_replica!(
        code_replica,
        Tracking.GPSL1,
        code_frequency,
        sampling_frequency,
        code_phase,
        signal_start_sample,
        num_samples_left,
        early_late_sample_shift,
        prn
    )
    carrier_replica = gpu_gen_carrier_replica!(
        carrier_replica,
        carrier_frequency,
        sampling_frequency,
        carrier_phase,
        carrier_amplitude_power,
        signal_start_sample,
        num_samples_left
    )
    downconverted_signal = gpu_downconvert!(
        downconverted_signal,
        signal,
        carrier_replica,
        signal_start_sample,
        num_samples_left
    )
    correlator = gpu_correlate(
        correlator,
        downconverted_signal,
        code_replica,
        early_late_sample_shift,
        signal_start_sample,
        num_samples_left,
        1,
        2,
        Val(7)
    )
    integrated_samples += num_samples_left
    carrier_phase = Tracking.update_carrier_phase(
        num_samples_left,
        carrier_frequency,
        sampling_frequency,
        carrier_phase,
        carrier_amplitude_power
    )
    prev_code_phase = code_phase
    code_phase = Tracking.update_code_phase(
        S,
        num_samples_left,
        code_frequency,
        sampling_frequency,
        code_phase,
        found(sc_bit_detector)
    )
    integration_time = integrated_samples / sampling_frequency
    if num_samples_left == num_samples_left_to_integrate &&
            integration_time >= min_integration_time
        got_correlator = true

        correlator = Tracking.normalize(correlator, integrated_samples)
        valid_correlator = correlator
        filtered_correlator = Tracking.filter(post_corr_filter, correlator)
        pll_discriminator = Tracking.pll_disc(S, filtered_correlator)
        dll_discriminator = Tracking.dll_disc(
            S,
            filtered_correlator,
            early_late_sample_shift,
            code_frequency / sampling_frequency
        )
        carrier_freq_update, carrier_loop_filter = filter_loop(
            carrier_loop_filter,
            pll_discriminator,
            integration_time,
            carrier_loop_filter_bandwidth
        )
        code_freq_update, code_loop_filter = filter_loop(
            code_loop_filter,
            dll_discriminator,
            integration_time,
            code_loop_filter_bandwidth
        )
        carrier_doppler, code_doppler = Tracking.aid_dopplers(
            S,
            init_carrier_doppler,
            init_code_doppler,
            carrier_freq_update,
            code_freq_update,
            velocity_aiding
        )
        cn0_estimator = Tracking.update(cn0_estimator, Tracking.get_prompt(filtered_correlator))
        bit_buffer, prompt_accumulator = Tracking.buffer(
            S,
            bit_buffer,
            prompt_accumulator,
            found(sc_bit_detector),
            prev_code_phase,
            code_phase,
            max_integration_time,
            Tracking.get_prompt(filtered_correlator)
        )
        sc_bit_detector = Tracking.find(S, sc_bit_detector, Tracking.get_prompt(filtered_correlator))
        correlator = zero(correlator)
        integrated_samples = 0
    end

    num_samples_left == signal_samples_left && break
    signal_start_sample += num_samples_left
end
next_state = gpuTrackingState{S, C, CALF, COLF, CN, DS}(
    init_carrier_doppler,
    init_code_doppler,
    carrier_doppler,
    code_doppler,
    carrier_phase,
    code_phase,
    correlator,
    carrier_loop_filter,
    code_loop_filter,
    sc_bit_detector,
    integrated_samples,
    prompt_accumulator,
    cn0_estimator,
    downconverted_signal,
    carrier_replica,
    code_replica
)
estimated_cn0 = Tracking.estimate_cn0(cn0_estimator, max_integration_time)
gpuTrackingResults(next_state, valid_correlator, got_correlator, bit_buffer, estimated_cn0)
end