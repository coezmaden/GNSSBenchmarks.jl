function gpu_correlate(
    correlator::EarlyPromptLateCorrelator,
    downconverted_signal_re::Array,
    downconverted_signal_im::Array,
    code,
    early_late_sample_shift,
    start_sample,
    num_samples_left,
    agc_attenuation,
    agc_bits,
    carrier_bits::Val{NC}
) where NC
    late = zero(Complex{Int32})
    prompt = zero(Complex{Int32})
    early = zero(Complex{Int32})
    @inbounds for i = start_sample:num_samples_left + start_sample - 1
        late = late + (downconverted_signal_re[i] + 1im * downconverted_signal_im[i]) * code[i]
    end
    @inbounds for i = start_sample:num_samples_left + start_sample - 1
        prompt = prompt + (downconverted_signal_re[i] + 1im * downconverted_signal_im[i]) * code[i + early_late_sample_shift]
    end
    @inbounds for i = start_sample:num_samples_left + start_sample - 1
        early = early + (downconverted_signal_re[i] + 1im * downconverted_signal_im[i]) * code[i + 2 * early_late_sample_shift]
    end
    EarlyPromptLateCorrelator(
        get_early(correlator) + early,
        get_prompt(correlator) + prompt,
        get_late(correlator) + late 
    )

end

function gpu_correlate(
    correlator::EarlyPromptLateCorrelator,
    downconverted_signal_re::CuArray,
    downconverted_signal_im::CuArray,
    code,
    early_late_sample_shift,
    start_sample,
    num_samples_left,
    agc_attenuation,
    agc_bits,
    carrier_bits::Val{NC}
) where NC
    late = zero(ComplexF32)
    prompt = zero(ComplexF32)
    early = zero(ComplexF32)
    @views late = dot(
                (downconverted_signal_re[start_sample:num_samples_left + start_sample - 1]
                + 1im*downconverted_signal_im[start_sample:num_samples_left + start_sample - 1]), 
                code[start_sample:num_samples_left + start_sample - 1]) 
    @views prompt = dot(
                (downconverted_signal_re[start_sample:num_samples_left + start_sample - 1]
                + 1im*downconverted_signal_im[start_sample:num_samples_left + start_sample - 1]), 
                code[(start_sample:num_samples_left + start_sample - 1) .+ early_late_sample_shift])
    @views early = dot(
                (downconverted_signal_re[start_sample:num_samples_left + start_sample - 1]
                + 1im*downconverted_signal_im[start_sample:num_samples_left + start_sample - 1]),
                code[(start_sample:num_samples_left + start_sample - 1) .+ 2 * early_late_sample_shift])
    EarlyPromptLateCorrelator(
        get_early(correlator) + early, 
        get_prompt(correlator) + prompt,
        get_late(correlator) + late
    )
end

function gpu_correlate(
    correlator::EarlyPromptLateCorrelator,
    downconverted_signal::CuArray{ComplexF32},
    code,
    early_late_sample_shift,
    start_sample,
    num_samples_left,
    agc_attenuation,
    agc_bits,
    carrier_bits::Val{NC}
) where NC
    late = zero(ComplexF32)
    prompt = zero(ComplexF32)
    early = zero(ComplexF32)
    @views late = dot(
                downconverted_signal[start_sample:num_samples_left + start_sample - 1], 
                code[start_sample:num_samples_left + start_sample - 1]) 
    @views prompt = dot(
                downconverted_signal[start_sample:num_samples_left + start_sample - 1], 
                code[(start_sample:num_samples_left + start_sample - 1) .+ early_late_sample_shift])
    @views early = dot(
                downconverted_signal[start_sample:num_samples_left + start_sample - 1], 
                code[(start_sample:num_samples_left + start_sample - 1) .+ 2 * early_late_sample_shift])
    EarlyPromptLateCorrelator(
        get_early(correlator) + early, 
        get_prompt(correlator) + prompt,
        get_late(correlator) + late
    )
end

function gpu_correlate(
    correlator::EarlyPromptLateCorrelator,
    downconverted_signal::StructArray,
    code,
    early_late_sample_shift,
    start_sample,
    num_samples_left,
    agc_attenuation,
    agc_bits,
    carrier_bits::Val{NC}
) where NC
    gpu_correlate(
        correlator,
        downconverted_signal.re,
        downconverted_signal.im,
        code,
        early_late_sample_shift,
        start_sample,
        num_samples_left,
        agc_attenuation,
        agc_bits,
        carrier_bits
    )
end
