function benchmark_code_replica()
    #init signals
    cpucode = zeros(Int16, MAX_NUM_SAMPLES + 2)
    gpucode = CuArray{ComplexF32}(cpucode)
    code_frequency = 1023e3
    sampling_frequency = 2.5e6
    start_code_phase = 0.0
    start_sample = 1
    early_late_sample_shift = 1
    prn = 1
    #init data frame
    results = DataFrame(
        Samples = SAMPLES, 
        CPU_median = zeros(Float32,length(SAMPLES)),
        GPU_median = zeros(Float32,length(SAMPLES))
    )
    counter = Int32(1)
    for N in SAMPLES
        println("Benchmarking code_replica on CPU: Array{ComplexF32} ", N, " samples...")
        result = 1000 * median(@benchmark Tracking.gen_code_replica!(
            $cpucode[1:$N],
            $GPSL1,
            $code_frequency,
            $sampling_frequency,
            $start_code_phase,
            $start_sample,
            $N,
            $early_late_sample_shift,
            $prn
        )).time
        println(result)
        results.CPU_median[counter] = result
        println("Benchmarking code_replica on GPU: CuArray{ComplexF32} ", N, " samples...")
        result = 1000 * median(@benchmark CUDA.@sync gpu_gen_code_replica!(
            $gpucode[1:$N],
            $GPSL1,
            $code_frequency,
            $sampling_frequency,
            $start_code_phase,
            $start_sample,
            $N,
            $early_late_sample_shift,
            $prn
        )).time
        println(result)
        results.GPU_median[counter] = result
        counter += 1
    end
    CSV.write("data/code_replica.csv", results)
end