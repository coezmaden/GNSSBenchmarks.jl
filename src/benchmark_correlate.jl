function benchmark_correlate()
    #init signals
    correlator = EarlyPromptLateCorrelator(0.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im)
    early_late_sample_shift = 1
    cpucode = GNSSSignals.get_code.(
            GPSL1,
            (1 - early_late_sample_shift:MAX_NUM_SAMPLES + early_late_sample_shift) * 1023e3 / 2.5e6,
            1
    )
    gpucode = CuArray{ComplexF32}(cpucode)
    cpudwnsignal = Array{ComplexF32}(cpucode[1:MAX_NUM_SAMPLES] + zeros(MAX_NUM_SAMPLES)*im)
    scpudwnsignal = StructArray{ComplexF32}((real(cpudwnsignal),imag(cpudwnsignal)))
    gpudwnsignal = CuArray{ComplexF32}(cpudwnsignal)
    sgpudwnsignal = StructArray{ComplexF32}((real(gpudwnsignal),imag(gpudwnsignal)))
    #init data frame
    results = DataFrame(
        Samples = SAMPLES, 
        sCPU_median = zeros(Float32,length(SAMPLES)),
        GPU_median = zeros(Float32,length(SAMPLES)),
        sGPU_median = zeros(Float32,length(SAMPLES))
    )
    counter = Int32(1)
    for N in SAMPLES
        println("Benchmarking the correlator on CPU: StructArray{ComplexF32}(Array, Array) ", N," samples...")
        result = 1000 * median(@benchmark gpu_correlate(
            $correlator,
            $scpudwnsignal[1:$N],
            $cpucode,
            $early_late_sample_shift,
            1,
            $N,
            1.0,
            2,
            Val(7),
        )).time
        println(result)
        results.sCPU_median[counter] = result
        println("Benchmarking the correlator on GPU: CuArray{ComplexF32} ", N, " samples...")
        result = 1000 * median(@benchmark CUDA.@sync gpu_correlate(
            $correlator,
            $gpudwnsignal[1:$N],
            $gpucode,
            $early_late_sample_shift,
            1,
            $N,
            1.0,
            2,
            Val(7),
        )).time
        println(result)
        results.GPU_median[counter] = result
        println("Benchmarking the correlator on GPU: StructArray{ComplexF32}(CuArray,CuArray) ", N, " samples...")
        result = 1000 * median(@benchmark CUDA.@sync gpu_correlate(
            $correlator,
            $sgpudwnsignal[1:$N],
            $gpucode,
            $early_late_sample_shift,
            1,
            $N,
            1.0,
            2,
            Val(7),
        )).time
        println(result)
        results.sGPU_median[counter] = result
        counter += 1
    end
    CSV.write("data/correlate.csv", results)
end