struct gpuTrackingResults{
        TS <: Union{gpuTrackingState, sgpuTrackingState},
        C <: AbstractCorrelator
    }
    state::TS
    correlator::C
    got_correlator::Bool
    bit_buffer::BitBuffer
    cn0::typeof(1.0dBHz)
end

@inline get_state(results::gpuTrackingResults) = results.state

@inline get_carrier_doppler(results::gpuTrackingResults) = get_carrier_doppler(results.state)

@inline get_carrier_phase(results::gpuTrackingResults) = get_carrier_phase(results.state) * 2π

@inline get_code_doppler(results::gpuTrackingResults) = get_code_doppler(results.state)

@inline get_code_phase(results::gpuTrackingResults) = get_code_phase(results.state)

@inline get_correlator(results::gpuTrackingResults) = results.correlator

@inline get_early(results::gpuTrackingResults) = get_early(get_correlator(results))

@inline get_prompt(results::gpuTrackingResults) = get_prompt(get_correlator(results))

@inline get_late(results::gpuTrackingResults) = get_late(get_correlator(results))

@inline get_bits(results::gpuTrackingResults) = get_bits(results.bit_buffer)

@inline get_num_bits(results::gpuTrackingResults) = length(results.bit_buffer)

@inline get_cn0(results::gpuTrackingResults) = results.cn0

@inline get_secondary_code_or_bit_found(results::TrackingResults) =
    found(get_sc_bit_detector(results.state))