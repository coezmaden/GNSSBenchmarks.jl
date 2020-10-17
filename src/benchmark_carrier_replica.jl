function benchmark_carrier_replica()
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
        # init signals
        cpucarrier = zeros(Complex{Float32}, N)
        gpucarrier = CuArray{ComplexF32}(cpucarrier)

        # init signals in StructArrays
        scpucarrier = StructArray{ComplexF32}(
            (real(cpucarrier),imag(cpucarrier))
        )
        sgpucarrier = StructArray{ComplexF32}(
            (real(gpucarrier),imag(gpucarrier))
        )

        # do the benchmark
        println("Benchmarking carrier_replica on CPU: StructArray{ComplexF32} ", N," samples...")
        result = @benchmark cpu_gen_carrier_replica!(
            $scpucarrier,
            1500,
            2.5e6,
            0,
            Val(7),
            1,
            $N
        )
        println(minimum(result).time)
        results_min.sCPU_time[rowpos] = minimum(result).time
        results_med.sCPU_time[rowpos] = median(result).time
        results_mean.sCPU_time[rowpos] = mean(result).time
        println("Benchmarking carrier_replica on GPU: CuArray{ComplexF32} ", N, " samples...")
        result = @benchmark CUDA.@sync gpu_gen_carrier_replica!(
            $gpucarrier,
            1500,
            2.5e6,
            0,
            Val(7),
            1,
            $N
        )
        println(minimum(result).time)
        results_min.GPU_time[rowpos] = minimum(result).time
        results_med.GPU_time[rowpos] = median(result).time
        results_mean.GPU_time[rowpos] = mean(result).time
        println("Benchmarking carrier_replica on GPU: StructArray{ComplexF32}(CuArray,CuArray) ", N, " samples...")
        result = @benchmark CUDA.@sync gpu_gen_carrier_replica!(
            $sgpucarrier,
            1500,
            2.5e6,
            0,
            Val(7),
            1,
            $N
        )
        println(minimum(result).time)
        results_min.sGPU_time[rowpos] = minimum(result).time
        results_med.sGPU_time[rowpos] = median(result).time
        results_mean.sGPU_time[rowpos] = mean(result).time
        rowpos += 1
    end
    CSV.write("data/carrierreplica_min.csv", results_min)
    CSV.write("data/carrierreplica_med.csv", results_med)
    CSV.write("data/carrierreplica_mean.csv", results_mean)
end