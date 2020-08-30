function benchmark_tracking_loop()
    #init signals
    carrier_doppler = 0Hz
    start_code_phase = 0
    code_frequency = 1023kHz
    sampling_frequency = 2.5MHz
    prn = 1
    start_carrier_phase = 0
    cpustate = Tracking.TrackingState(GPSL1, carrier_doppler, start_code_phase)
    gpustate = GNSSBenchmarks.gpuTrackingState(GPSL1, carrier_doppler, start_code_phase)
    sgpustate = GNSSBenchmarks.sgpuTrackingState(GPSL1, carrier_doppler, start_code_phase)
    #init data frame
    results = DataFrame(
        Samples = SAMPLES, 
        sCPU_median = zeros(Float32,length(SAMPLES)),
        GPU_median = zeros(Float32,length(SAMPLES)),
        sGPU_median = zeros(Float32,length(SAMPLES))
    )
    counter = Int32(1)
    for N in SAMPLES
        cpusignal = cis.(
            2π .* carrier_doppler .* (1:N) ./ sampling_frequency .+ start_carrier_phase
        ) .*
        GNSSSignals.get_code.(
            GPSL1,
            code_frequency .* (1:N) ./ sampling_frequency .+ start_code_phase,
            prn
        )
        println("Benchmarking the tracking loop on CPU: StructArray{ComplexF32}(Array, Array) ", N," samples...")
        result = median(@benchmark Tracking.track(
            $cpusignal,
            $cpustate,
            $prn,
            $sampling_frequency,
        )).time
        println(result)
        results.sCPU_median[counter] = result
        println("Benchmarking the tracking loop on GPU: CuArray{ComplexF32} ", N, " samples...")
        result = median(@benchmark gpu_track(
            CuArray{ComplexF32}(cpusignal),
            $gpustate,
            $prn,
            $sampling_frequency,
        )).time
        println(result)
        results.GPU_median[counter] = result
        println("Benchmarking the tracking loop GPU: StructArray{ComplexF32}(CuArray,CuArray) ", N, " samples...")
        result = median(@benchmark Tracking.track(
            StructArray{ComplexF32}(
                (real(CuArray{ComplexF32}(cpusignal)),
                imag(CuArray{ComplexF32}(cpusignal)))),
            $sgpustate,
            $prn,
            $sampling_frequency,
        )).time
        println(result)
        results.sGPU_median[counter] = result
        counter += 1
    end
    CSV.write("data/tracking_loop.csv", results)
end

function benchmark_tracking_loop_feedback(
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
