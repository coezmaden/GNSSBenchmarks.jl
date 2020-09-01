function benchmark_carrier_replica()
    #init signals
    cpucarrier = Array(zeros(Complex{Float32}, MAX_NUM_SAMPLES))
    scpucarrier = StructArray{ComplexF32}((real(cpucarrier),imag(cpucarrier)))
    gpucarrier = CuArray{ComplexF32}(cpucarrier)
    sgpucarrier = StructArray{ComplexF32}((real(gpucarrier),imag(gpucarrier)))
    results = DataFrame(
        Samples = SAMPLES, 
        sCPU_median = zeros(Float32,length(SAMPLES)),
        GPU_median = zeros(Float32,length(SAMPLES)),
        sGPU_median = zeros(Float32,length(SAMPLES))
    )
    counter = Int32(1)
    for N in SAMPLES
        println("Benchmarking carrier_replica on CPU: Array{ComplexF32} ", N," samples...")
        result = 1000 * median(@benchmark gpu_gen_carrier_replica!(
            $cpucarrier[1:$N],
            1500,
            2.5e6,
            0,
            Val(7),
            1,
            $N
        )).time
        println(result)
        results.sCPU_median[counter] = result
        println("Benchmarking carrier_replica on GPU: CuArray{ComplexF32} ", N, " samples...")
        result = 1000 * median(@benchmark gpu_gen_carrier_replica!(
            $gpucarrier[1:$N],
            1500,
            2.5e6,
            0,
            Val(7),
            1,
            $N
        )).time
        println(result)
        results.GPU_median[counter] = result
        println("Benchmarking carrier_replica on GPU: StructArray{ComplexF32}(CuArray,CuArray) ", N, " samples...")
        result = 1000 * median(@benchmark gpu_gen_carrier_replica!(
            $sgpucarrier[1:$N],
            1500,
            2.5e6,
            0,
            Val(7),
            1,
            $N
        )).time
        println(result)
        results.sGPU_median[counter] = result
        counter += 1
    end
    CSV.write("data/carrier_replica.csv", results)
end