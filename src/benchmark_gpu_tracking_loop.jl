function benchmark_gpu_tracking_loop(
    signal::Union{CuArray, StructArray},
    state::Union{gpuTrackingState, sgpuTrackingState},
    prn::Integer,
    sampling_frequency::typeof(1.0Hz)
)   
    counter = 1
    results = gpu_track(signal, state, prn, sampling_frequency)
    while counter < 9999
        # tracking loop that feeds the state back
        results = gpu_track(signal, get_state(results), prn, sampling_frequency)
        counter += 1
    end
end
