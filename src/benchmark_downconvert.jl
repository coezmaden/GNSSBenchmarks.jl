function benchmark_downconvert()
    results_min = DataFrame(
        Samples = SAMPLES, 
        sCPU_time_1ant = zeros(Float64,length(SAMPLES)),
        sCPU_time_4ant = zeros(Float64,length(SAMPLES)),
        sCPU_time_16ant = zeros(Float64,length(SAMPLES)),
        GPU_time_1ant = zeros(Float64,length(SAMPLES)),
        GPU_time_4ant = zeros(Float64,length(SAMPLES)),
        GPU_time_16ant = zeros(Float64,length(SAMPLES)),
        sGPU_time_1ant = zeros(Float64,length(SAMPLES)),
        sGPU_time_4ant = zeros(Float64,length(SAMPLES)),
        sGPU_time_16ant = zeros(Float64,length(SAMPLES)) 
    )
    results_med = DataFrame(
        Samples = SAMPLES, 
        sCPU_time_1ant = zeros(Float64,length(SAMPLES)),
        sCPU_time_4ant = zeros(Float64,length(SAMPLES)),
        sCPU_time_16ant = zeros(Float64,length(SAMPLES)),
        GPU_time_1ant = zeros(Float64,length(SAMPLES)),
        GPU_time_4ant = zeros(Float64,length(SAMPLES)),
        GPU_time_16ant = zeros(Float64,length(SAMPLES)),
        sGPU_time_1ant = zeros(Float64,length(SAMPLES)),
        sGPU_time_4ant = zeros(Float64,length(SAMPLES)),
        sGPU_time_16ant = zeros(Float64,length(SAMPLES)) 
    )
    results_mean = DataFrame(
        Samples = SAMPLES, 
        sCPU_time_1ant = zeros(Float64,length(SAMPLES)),
        sCPU_time_4ant = zeros(Float64,length(SAMPLES)),
        sCPU_time_16ant = zeros(Float64,length(SAMPLES)),
        GPU_time_1ant = zeros(Float64,length(SAMPLES)),
        GPU_time_4ant = zeros(Float64,length(SAMPLES)),
        GPU_time_16ant = zeros(Float64,length(SAMPLES)),
        sGPU_time_1ant = zeros(Float64,length(SAMPLES)),
        sGPU_time_4ant = zeros(Float64,length(SAMPLES)),
        sGPU_time_16ant = zeros(Float64,length(SAMPLES)) 
    )
    rowpos = Int32(1)
    for N in SAMPLES
        for M in ANTENNA
            # init csv column write position 
            M==1 ? columnpos=2 : M==4 ? columnpos=3 : M==16 ? columnpos=4 : throw("Error in antenna num")
            # init signals 
            phases = 2π * (1:N) * 1000 / 2.5e6
            cpusignal = Vector{ComplexF32}(cos.(phases) + 1im.*sin.(phases))
            cpucarrier = cpusignal
            gpusignal = CuVector{ComplexF32}(cos.(phases) + 1im.*sin.(phases))
            gpucarrier = gpusignal
            cpudwnsignal = zeros(ComplexF32, N)
            gpudwnsignal = CUDA.zeros(ComplexF32, N)

            # init signals in StructArrays
            scpusignal = StructArray{ComplexF32}(
                (real(cpusignal),
                imag(cpusignal)))
            scpucarrier = copy(scpusignal)
            sgpusignal = StructArray{ComplexF32}(
                (real(gpusignal),
                imag(gpusignal)))
            sgpucarrier = copy(sgpusignal)
            scpudwnsignal = StructArray{ComplexF32}(
                    (real(zeros(Float32, N)),imag(zeros(Float32, N)))
                    )
            sgpudwnsignal = StructArray{ComplexF32}(
                    (real(CUDA.zeros(Float32, N)), imag(CUDA.zeros(Float32, N))))

            # init signals as matrices
            if M > 1
                cpusignal = cpusignal .* ones(ComplexF32, N, M)
                gpusignal = gpusignal .* CUDA.ones(ComplexF32, N, M)
                cpudwnsignal = zeros(ComplexF32, N, M)
                gpudwnsignal = CUDA.zeros(ComplexF32, N, M)

                scpusignal = StructArray{ComplexF32}(
                    (real(cpusignal),
                    imag(cpusignal)))
                sgpusignal = StructArray{ComplexF32}(
                    (real(gpusignal),
                    imag(gpusignal)))
                scpudwnsignal = StructArray{ComplexF32}(
                    (real(zeros(Float32,N,M)),
                    imag(zeros(Float32,N,M))))
                sgpudwnsignal = StructArray{ComplexF32}(
                    (real(CUDA.zeros(Float32,N,M)),
                    imag(CUDA.zeros(Float32,N,M))))
            end

            # do the benchmark
            println("Benchmarking downconvert on CPU: StructArray{ComplexF32} ", N," samples, ", M, " antenna...")
            result = @benchmark cpu_downconvert!(
                $scpudwnsignal.re,
                $scpudwnsignal.im,
                $scpucarrier.re,
                $scpucarrier.im,
                $scpusignal.re,
                $scpusignal.im,
                1,
                $N
            )
            println(minimum(result).time)
            results_min[rowpos, columnpos] = minimum(result).time
            results_med[rowpos, columnpos] = median(result).time
            results_mean[rowpos, columnpos] = mean(result).time
            println("Benchmarking downconvert on GPU: CuArray{ComplexF32} ", N, " samples, ", M, " antenna...")
            result = @benchmark CUDA.@sync gpu_downconvert!(
                $gpudwnsignal,
                $gpucarrier,
                $gpusignal,
                1,
                $N
            )
            println(minimum(result).time)
            results_min[rowpos, columnpos+3] = minimum(result).time
            results_med[rowpos, columnpos+3] = median(result).time
            results_mean[rowpos, columnpos+3] = mean(result).time
            println("Benchmarking downconvert on GPU: StructArray{ComplexF32}(CuArray,CuArray) ", N, " samples, ", M, " antenna...")
            result = @benchmark CUDA.@sync gpu_downconvert!(
                $sgpudwnsignal.re,
                $sgpudwnsignal.im,
                $sgpucarrier.re,
                $sgpucarrier.im,
                $sgpusignal.re,
                $sgpusignal.im,
                1,
                $N
            )
            println(minimum(result).time)
            results_min[rowpos, columnpos+6] = minimum(result).time
            results_med[rowpos, columnpos+6] = median(result).time
            results_mean[rowpos, columnpos+6] = mean(result).time
        end
        rowpos += 1
    end
    CSV.write("data/downconvert_min.csv", results_min)
    CSV.write("data/downconvert_med.csv", results_med)
    CSV.write("data/downconvert_mean.csv", results_mean)
end