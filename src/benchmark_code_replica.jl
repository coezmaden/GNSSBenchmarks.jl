function benchmark_code_replica()
    results_min = DataFrame(
        Samples = SAMPLES, 
        CPU_time = zeros(Float64,length(SAMPLES)),
        GPU_time = zeros(Float64,length(SAMPLES))
    )
    results_med = DataFrame(
        Samples = SAMPLES, 
        CPU_time = zeros(Float64,length(SAMPLES)),
        GPU_time = zeros(Float64,length(SAMPLES))
    )
    results_mean = DataFrame(
        Samples = SAMPLES, 
        CPU_time = zeros(Float64,length(SAMPLES)),
        GPU_time = zeros(Float64,length(SAMPLES))
    )
    rowpos = Int32(1)
    for N in SAMPLES
        #init signals
        cpucode = zeros(Int16, N + 2)
        gpucode = CuArray{ComplexF32}(cpucode)
        code_frequency = 1023e3
        sampling_frequency = 2.5e6
        start_code_phase = 0.0
        start_sample = 1
        early_late_sample_shift = 1
        prn = 1

        gpsl1 = GNSSSignals.GPSL1()
        gpsl1cpu = GNSSSignals.GPSL1(gpsl1)

        println("Benchmarking code_replica on CPU: Array{ComplexF32} ", N, " samples...")
        result = @benchmark gpu_gen_code_replica!(
            $cpucode,
            $gpsl1cpu,
            $code_frequency,
            $sampling_frequency,
            $start_code_phase,
            $start_sample,
            $N,
            $early_late_sample_shift,
            $prn
        )
        println(result)
        results_min.CPU_time[rowpos] = minimum(result).time
        results_med.CPU_time[rowpos] = median(result).time
        results_mean.CPU_time[rowpos] = mean(result).time

        println("Benchmarking code_replica on GPU: CuArray{ComplexF32} ", N, " samples...")
        result = @benchmark CUDA.@sync gpu_gen_code_replica!(
            $gpucode,
            $gpsl1,
            $code_frequency,
            $sampling_frequency,
            $start_code_phase,
            $start_sample,
            $N,
            $early_late_sample_shift,
            $prn
        )
        println(result)
        results_min.GPU_time[rowpos] = minimum(result).time
        results_med.GPU_time[rowpos] = median(result).time
        results_mean.GPU_time[rowpos] = mean(result).time

        rowpos += 1
    end
    CSV.write("data/codeprelica_min.csv", results_min)
    CSV.write("data/codeprelica_med.csv", results_med)
    CSV.write("data/codeprelica_mean.csv", results_mean)
    CSV.write("data/codeprelicacpu_min.csv", results_min)
    CSV.write("data/codeprelicacpu_med.csv", results_med)
    CSV.write("data/codeprelicacpu_mean.csv", results_mean)
end