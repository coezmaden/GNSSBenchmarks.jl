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
        result = 1000 * median(@benchmark gpu_downconvert!(
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
        result = 1000 * median(@benchmark CUDA.@sync gpu_downconvert!(
            $gpudwnsignal,
            $gpucarrier,
            $gpusignal,
            1,
            $N
        )).time
        println(result)
        results.GPU_median[counter] = result
        println("Benchmarking downconvert on GPU: StructArray{ComplexF32}(CuArray,CuArray) ", N, " samples...")
        result = 1000 * median(@benchmark CUDA.@sync gpu_downconvert!(
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