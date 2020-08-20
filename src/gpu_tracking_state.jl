struct sgpuTrackingState{
        S <: AbstractGNSSSystem,
        C <: AbstractCorrelator,
        CALF <: AbstractLoopFilter,
        COLF <: AbstractLoopFilter,
        CN <: AbstractCN0Estimator,
        DS <: StructArray,
    }
    init_carrier_doppler::typeof(1.0Hz)
    init_code_doppler::typeof(1.0Hz)
    carrier_doppler::typeof(1.0Hz)
    code_doppler::typeof(1.0Hz)
    carrier_phase::Float64
    code_phase::Float64
    correlator::C
    carrier_loop_filter::CALF
    code_loop_filter::COLF
    sc_bit_detector::SecondaryCodeOrBitDetector
    integrated_samples::Int
    prompt_accumulator::ComplexF64
    cn0_estimator::CN
    downconverted_signal::DS
    carrier::StructArray{Complex{Float32},1,NamedTuple{(:re, :im),Tuple{CuArray{Float32,1},CuArray{Float32,1}}},Int64}
    code::CuArray{ComplexF32}
end

function sgpuTrackingState(
    ::Type{S},
    carrier_doppler,
    code_phase;
    code_doppler = carrier_doppler * get_code_center_frequency_ratio(S),
    carrier_phase = 0.0,
    carrier_loop_filter::CALF = ThirdOrderBilinearLF(),
    code_loop_filter::COLF = SecondOrderBilinearLF(),
    sc_bit_detector = SecondaryCodeOrBitDetector(),
    num_ants = NumAnts(1),
    correlator::C = EarlyPromptLateCorrelator(num_ants),
    integrated_samples = 0,
    prompt_accumulator = zero(ComplexF64),
    cn0_estimator::CN = MomentsCN0Estimator(20)
) where {
    S <: AbstractGNSSSystem,
    C <: AbstractCorrelator,
    CALF <: AbstractLoopFilter,
    COLF <: AbstractLoopFilter,
    CN <: AbstractCN0Estimator
}
    if found(sc_bit_detector)
        code_phase = mod(code_phase, get_code_length(S) *
            get_secondary_code_length(S))
    else
        code_phase = mod(code_phase, get_code_length(S))
    end
    downconverted_signal = sgpu_init_downconverted_signal(num_ants)
    carrier = StructArray{ComplexF32}((real(CuArray{Float32}(undef,0)),imag(CuArray{Float32}(undef,0))))
    code = CuArray{ComplexF32}(undef, 0)

    sgpuTrackingState{S, C, CALF, COLF, CN, typeof(downconverted_signal)}(
        carrier_doppler,
        code_doppler,
        carrier_doppler,
        code_doppler,
        carrier_phase / 2π,
        code_phase,
        correlator,
        carrier_loop_filter,
        code_loop_filter,
        sc_bit_detector,
        integrated_samples,
        prompt_accumulator,
        cn0_estimator,
        downconverted_signal,
        carrier,
        code
    )
end

struct gpuTrackingState{
    S <: AbstractGNSSSystem,
    C <: AbstractCorrelator,
    CALF <: AbstractLoopFilter,
    COLF <: AbstractLoopFilter,
    CN <: AbstractCN0Estimator,
    DS <: CuArray
}
init_carrier_doppler::typeof(1.0Hz)
init_code_doppler::typeof(1.0Hz)
carrier_doppler::typeof(1.0Hz)
code_doppler::typeof(1.0Hz)
carrier_phase::Float64
code_phase::Float64
correlator::C
carrier_loop_filter::CALF
code_loop_filter::COLF
sc_bit_detector::SecondaryCodeOrBitDetector
integrated_samples::Int
prompt_accumulator::ComplexF64
cn0_estimator::CN
downconverted_signal::DS
carrier::CuArray{ComplexF32}
code::CuArray{ComplexF32}
end

function gpuTrackingState(
    ::Type{S},
    carrier_doppler,
    code_phase;
    code_doppler = carrier_doppler * get_code_center_frequency_ratio(S),
    carrier_phase = 0.0,
    carrier_loop_filter::CALF = ThirdOrderBilinearLF(),
    code_loop_filter::COLF = SecondOrderBilinearLF(),
    sc_bit_detector = SecondaryCodeOrBitDetector(),
    num_ants = NumAnts(1),
    correlator::C = EarlyPromptLateCorrelator(num_ants),
    integrated_samples = 0,
    prompt_accumulator = zero(ComplexF64),
    cn0_estimator::CN = MomentsCN0Estimator(20)
) where {
    S <: AbstractGNSSSystem,
    C <: AbstractCorrelator,
    CALF <: AbstractLoopFilter,
    COLF <: AbstractLoopFilter,
    CN <: AbstractCN0Estimator
}
    if found(sc_bit_detector)
        code_phase = mod(code_phase, get_code_length(S) *
            get_secondary_code_length(S))
    else
        code_phase = mod(code_phase, get_code_length(S))
    end
    downconverted_signal = gpu_init_downconverted_signal(num_ants)
    carrier = CuArray{ComplexF32}(undef, 0)
    code = CuArray{ComplexF32}(undef, 0)

    gpuTrackingState{S, C, CALF, COLF, CN, typeof(downconverted_signal)}(
        carrier_doppler,
        code_doppler,
        carrier_doppler,
        code_doppler,
        carrier_phase / 2π,
        code_phase,
        correlator,
        carrier_loop_filter,
        code_loop_filter,
        sc_bit_detector,
        integrated_samples,
        prompt_accumulator,
        cn0_estimator,
        downconverted_signal,
        carrier,
        code
    )
end

function sgpu_init_downconverted_signal(num_ants::NumAnts{1})
    StructArray{ComplexF32}(undef, 0)
end

function sgpu_init_downconverted_signal(num_ants::NumAnts{N}) where N
    StructArray{ComplexF32}(undef, 0, N)
end

function gpu_init_downconverted_signal(num_ants::NumAnts{1})
    CuArray{ComplexF32}(undef, 0)
end

function gpu_init_downconverted_signal(num_ants::NumAnts{N}) where N
    CuArray{ComplexF32}(undef, 0, N)
end


@inline get_code_phase(state::gpuTrackingState) = state.code_phase
@inline get_carrier_phase(state::gpuTrackingState) = state.carrier_phase
@inline get_init_code_doppler(state::gpuTrackingState) = state.init_code_doppler
@inline get_init_carrier_doppler(state::gpuTrackingState) = state.init_carrier_doppler
@inline get_code_doppler(state::gpuTrackingState) = state.code_doppler
@inline get_carrier_doppler(state::gpuTrackingState) = state.carrier_doppler
@inline get_correlator(state::gpuTrackingState) = state.correlator
@inline get_sc_bit_detector(state::gpuTrackingState) = state.sc_bit_detector
@inline get_carrier_loop_filter(state::gpuTrackingState) = state.carrier_loop_filter
@inline get_code_loop_filter(state::gpuTrackingState) = state.code_loop_filter
@inline get_prompt_accumulator(state::gpuTrackingState) = state.prompt_accumulator
@inline get_integrated_samples(state::gpuTrackingState) = state.integrated_samples
@inline get_cn0_estimator(state::gpuTrackingState) = state.cn0_estimator
@inline get_downconverted_signal(state::gpuTrackingState) = state.downconverted_signal
@inline get_carrier(state::gpuTrackingState) = state.carrier
@inline get_code(state::gpuTrackingState) = state.code

@inline get_code_phase(state::sgpuTrackingState) = state.code_phase
@inline get_carrier_phase(state::sgpuTrackingState) = state.carrier_phase
@inline get_init_code_doppler(state::sgpuTrackingState) = state.init_code_doppler
@inline get_init_carrier_doppler(state::sgpuTrackingState) = state.init_carrier_doppler
@inline get_code_doppler(state::sgpuTrackingState) = state.code_doppler
@inline get_carrier_doppler(state::sgpuTrackingState) = state.carrier_doppler
@inline get_correlator(state::sgpuTrackingState) = state.correlator
@inline get_sc_bit_detector(state::sgpuTrackingState) = state.sc_bit_detector
@inline get_carrier_loop_filter(state::sgpuTrackingState) = state.carrier_loop_filter
@inline get_code_loop_filter(state::sgpuTrackingState) = state.code_loop_filter
@inline get_prompt_accumulator(state::sgpuTrackingState) = state.prompt_accumulator
@inline get_integrated_samples(state::sgpuTrackingState) = state.integrated_samples
@inline get_cn0_estimator(state::sgpuTrackingState) = state.cn0_estimator
@inline get_downconverted_signal(state::sgpuTrackingState) = state.downconverted_signal
@inline get_carrier(state::sgpuTrackingState) = state.carrier
@inline get_code(state::sgpuTrackingState) = state.code