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
        Tracking.get_early(correlator) + early,
        Tracking.get_prompt(correlator) + prompt,
        Tracking.get_late(correlator) + late 
    )
end

function correlate(
    correlator::EarlyPromptLateCorrelator,
    downconverted_signal::StructArray{Complex{Float32},2,NamedTuple{(:re, :im),Tuple{Array{Float32,2},Array{Float32,2}}},Int64},
    code,
    early_late_sample_shift,
    start_sample,
    num_samples_left,
    agc_attenuation,
    agc_bits,
    carrier_bits::Val{NC}
) where {N, NC}
    late = zero(MVector{N, Complex{Int32}})
    prompt = zero(MVector{N, Complex{Int32}})
    early = zero(MVector{N, Complex{Int32}})
    @inbounds for j = 1:length(late), i = start_sample:num_samples_left + start_sample - 1
        late[j] = late[j] + downconverted_signal[i,j] * code[i]
    end
    @inbounds for j = 1:length(late), i = start_sample:num_samples_left + start_sample - 1
        prompt[j] = prompt[j] + downconverted_signal[i,j] * code[i + early_late_sample_shift]
    end
    @inbounds for j = 1:length(late), i = start_sample:num_samples_left + start_sample - 1
        early[j] = early[j] + downconverted_signal[i,j] * code[i + 2 * early_late_sample_shift]
    end
    EarlyPromptLateCorrelator(
        get_early(correlator) + early .* agc_attenuation / 1 << (agc_bits + NC),
        get_prompt(correlator) + prompt .* agc_attenuation / 1 << (agc_bits + NC),
        get_late(correlator) + late .* agc_attenuation / 1 << (agc_bits + NC)
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
        Tracking.get_early(correlator) + early, 
        Tracking.get_prompt(correlator) + prompt,
        Tracking.get_late(correlator) + late
    )
end

# StructArray GPU
function gpu_correlate(
    correlator::EarlyPromptLateCorrelator,
    downconverted_signal_re::CuMatrix,
    downconverted_signal_im::CuMatrix,
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
    late = 
                (downconverted_signal_re[(start_sample:num_samples_left + start_sample - 1),1:end]
                + 1im*downconverted_signal_im[(start_sample:num_samples_left + start_sample - 1),1:end])'* 
                code[start_sample:num_samples_left + start_sample - 1]
    prompt= (downconverted_signal_re[(start_sample:num_samples_left + start_sample - 1),1:end]
                + 1im*downconverted_signal_im[(start_sample:num_samples_left + start_sample - 1),1:end])' *
                code[(start_sample:num_samples_left + start_sample - 1) .+ early_late_sample_shift]
    early = (downconverted_signal_re[(start_sample:num_samples_left + start_sample - 1),1:end]
            + downconverted_signal_im[(start_sample:num_samples_left + start_sample - 1),1:end])'*
            code[(start_sample:num_samples_left + start_sample - 1) .+ 2 * early_late_sample_shift]
    EarlyPromptLateCorrelator(
        Tracking.get_early(correlator) + early, 
        Tracking.get_prompt(correlator) + prompt,
        Tracking.get_late(correlator) + late
    )
end

# CuArray Ant=1
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
    @views late = downconverted_signal[start_sample:num_samples_left + start_sample - 1] ⋅ code[start_sample:num_samples_left + start_sample - 1]
    @views prompt = downconverted_signal[start_sample:num_samples_left + start_sample - 1] ⋅ code[early_late_sample_shift .+ (start_sample:num_samples_left + start_sample - 1)]
    @views early = downconverted_signal[start_sample:num_samples_left + start_sample - 1] ⋅ code[2*early_late_sample_shift .+ (start_sample:num_samples_left + start_sample - 1)]
    EarlyPromptLateCorrelator(
        Tracking.get_early(correlator) + early, 
        Tracking.get_prompt(correlator) + prompt,
        Tracking.get_late(correlator) + late
    )
end

# Mulit Antenne CuArray
function gpu_correlate(
    correlator::EarlyPromptLateCorrelator,
    downconverted_signal::CuArray{Complex{Float32},2},
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
    late = downconverted_signal[(start_sample:num_samples_left + start_sample - 1),1:end]' * code[start_sample:num_samples_left + start_sample - 1]
    prompt = downconverted_signal[(start_sample:num_samples_left + start_sample - 1),1:end]' * code[early_late_sample_shift .+ (start_sample:num_samples_left + start_sample - 1)]
    early = downconverted_signal[(start_sample:num_samples_left + start_sample - 1),1:end]' * code[2*early_late_sample_shift .+ (start_sample:num_samples_left + start_sample - 1)]
    EarlyPromptLateCorrelator(
        Tracking.get_early(correlator) + early, 
        Tracking.get_prompt(correlator) + prompt,
        Tracking.get_late(correlator) + late
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
