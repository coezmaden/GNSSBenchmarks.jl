function benchmark_downconvert()
    #init signals
    phases = 2π * (1:MAX_NUM_SAMPLES) * 1000 / 2.5e6
    cpusignal = Array{ComplexF32}(cos.(phases) + 1im.*sin.(phases))
    scpusignal = StructArray{ComplexF32}((real(cpusignal),imag(cpusignal)))
    scpucarrier = copy(scpusignal)
    scpudwnsignal = StructArray{ComplexF32}(undef, length(cpusignal))
    gpusignal = CuArray{ComplexF32}(cpusignal)
    gpucarrier = copy(gpusignal)
    gpudwnsignal = CuArray{ComplexF32}(undef, length(cpusignal))
    sgpusignal = StructArray{ComplexF32}((real(gpusignal),imag(gpusignal)))
    sgpucarrier = copy(sgpusignal)
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
        println("Benchmarking downconvert on CPU: StructArray{ComplexF32} ", N," samples...")
        result = median(@benchmark gpu_downconvert!(
            $scpudwnsignal.re,
            $scpudwnsignal.im,
            $scpucarrier.re,
            $scpucarrier.im,
            $scpusignal.re,
            $scpusignal.im,
            1,
            $N
        )).time
        println(result)
        results.sCPU_median[counter] = result
        println("Benchmarking downconvert on GPU: CuArray{ComplexF32} ", N, " samples...")
        result = median(@benchmark CUDA.@sync gpu_downconvert!(
            $gpudwnsignal,
            $gpucarrier,
            $gpusignal,
            1,
            $N
        )).time
        println(result)
        results.GPU_median[counter] = result
        println("Benchmarking downconvert on GPU: StructArray{ComplexF32}(CuArray,CuArray) ", N, " samples...")
        result = median(@benchmark CUDA.@sync gpu_downconvert!(
            $sgpudwnsignal.re,
            $sgpudwnsignal.im,
            $sgpucarrier.re,
            $sgpucarrier.im,
            $sgpusignal.re,
            $sgpusignal.im,
            1,
            $N
        )).time
        println(result)
        results.sGPU_median[counter] = result
        counter += 1
    end
    CSV.write("data/downconvert.csv", results)
end

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
        result = median(@benchmark gpu_gen_carrier_replica!(
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
        result = median(@benchmark gpu_gen_carrier_replica!(
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
        result = median(@benchmark gpu_gen_carrier_replica!(
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

function benchmark_code_replica()
    println("Not implemented yet")
end

function benchmark_correlate()
    #init signals
    correlator = EarlyPromptLateCorrelator(0.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im)
    early_late_sample_shift = 1
    cpucode = get_code.(
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
        result = median(@benchmark gpu_correlate(
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
        result = median(@benchmark CUDA.@sync gpu_correlate(
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
        result = median(@benchmark CUDA.@sync gpu_correlate(
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

function main()
    println("Executing all benchmarks")
    benchmark_downconvert();
    benchmark_carrier_replica();
    benchmark_code_replica();
    benchmark_correlate();
end
