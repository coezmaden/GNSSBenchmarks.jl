function benchmark_correlate()
    results_min = DataFrame(
        Samples = SAMPLES, 
        sCPU_time = zeros(Float64,length(SAMPLES)),
        GPU_time = zeros(Float64,length(SAMPLES)),
        sGPU_time = zeros(Float64,length(SAMPLES)),
    )
    results_med = DataFrame(
        Samples = SAMPLES, 
        sCPU_time = zeros(Float64,length(SAMPLES)),
        GPU_time = zeros(Float64,length(SAMPLES)),
        sGPU_time = zeros(Float64,length(SAMPLES)),
    )
    results_mean = DataFrame(
        Samples = SAMPLES, 
        sCPU_time = zeros(Float64,length(SAMPLES)),
        GPU_time = zeros(Float64,length(SAMPLES)),
        sGPU_time = zeros(Float64,length(SAMPLES)),
    )
    rowpos = Int32(1)
    for N in SAMPLES
        #init signals
        correlator = EarlyPromptLateCorrelator(0.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im)
        gpsl1 = GNSSSignals.GPSL1()
        early_late_sample_shift = 1
        gpucode = GNSSSignals.get_code(
            gpsl1,
            (1 - early_late_sample_shift:N + early_late_sample_shift) * 1023e3 / 2.5e6,
            1
        )
        cpucode = Array{ComplexF32}(gpucode)
        cpudwnsignal = Array{ComplexF32}(cpucode .+ zeros(N+2) .* im)
        scpudwnsignal = StructArray{ComplexF32}((real(cpudwnsignal),imag(cpudwnsignal)))
        gpudwnsignal = CuArray{ComplexF32}(cpudwnsignal)
        sgpudwnsignal = StructArray{ComplexF32}((real(gpudwnsignal),imag(gpudwnsignal)))
    
        println("Benchmarking the correlator on CPU: StructArray{ComplexF32}(Array, Array) ", N," samples...")
        result = @benchmark gpu_correlate(
            $correlator,
            $scpudwnsignal,
            $cpucode,
            $early_late_sample_shift,
            1,
            $N,
            1.0,
            2,
            Val(7)
        )
        println(minimum(result).time)
        results_min.sCPU_time[rowpos] = minimum(result).time
        results_med.sCPU_time[rowpos] = median(result).time
        results_mean.sCPU_time[rowpos] = mean(result).time


        println("Benchmarking the correlator on GPU: CuArray{ComplexF32} ", N, " samples...")
        # result = @benchmark CUDA.@sync gpu_correlate(
        #     $correlator,
        #     $gpudwnsignal,
        #     $gpucode,
        #     $early_late_sample_shift,
        #     1,
        #     $N,
        #     1.0,
        #     2,
        #     Val(7),
        # )
        # println(minimum(result).time)
        # results_min.GPU_time[rowpos] = minimum(result).time
        # results_med.GPU_time[rowpos] = median(result).time
        # results_mean.GPU_time[rowpos] = mean(result).time


        println("Benchmarking the correlator on GPU: StructArray{ComplexF32}(CuArray,CuArray) ", N, " samples...")
        result = @benchmark CUDA.@sync gpu_correlate(
            $correlator,
            $sgpudwnsignal,
            $gpucode,
            $early_late_sample_shift,
            1,
            $N,
            1.0,
            2,
            Val(7),
        )
        println(minimum(result).time)
        results_min.sGPU_time[rowpos] = minimum(result).time
        results_med.sGPU_time[rowpos] = median(result).time
        results_mean.sGPU_time[rowpos] = mean(result).time

        rowpos += 1
    end
    CSV.write("data/correlate_min.csv", results_min)
    CSV.write("data/correlate_med.csv", results_med)
    CSV.write("data/correlate_mean.csv", results_mean)
end