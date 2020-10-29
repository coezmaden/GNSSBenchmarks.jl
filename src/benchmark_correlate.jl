function benchmark_correlate()
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

            #init signals
            correlator = EarlyPromptLateCorrelator(0.0 + 0.0im, 0.0 + 0.0im, 0.0 + 0.0im)
            gpsl1 = GNSSSignals.GPSL1()
            early_late_sample_shift = 1
            gpucode = CuArray(GNSSSignals.get_code(
                gpsl1,
                (1 - early_late_sample_shift:N + early_late_sample_shift) * 1023e3 / 2.5e6,
                1
            ))
            cpucode = Array{ComplexF32}(gpucode)
            cpudwnsignal = Array{ComplexF32}(cpucode .+ zeros(N+2) .* im)
            scpudwnsignal = StructArray{ComplexF32}((real(cpudwnsignal),imag(cpudwnsignal)))
            gpudwnsignal = CuArray{ComplexF32}(cpudwnsignal)
            sgpudwnsignal = StructArray{ComplexF32}((real(gpudwnsignal),imag(gpudwnsignal)))

            # init signals as matrices
            if M > 1
                correlator = EarlyPromptLateCorrelator(NumAnts(M))
                cpudwnsignal = zeros(ComplexF32, N, M)
                gpudwnsignal = CUDA.zeros(ComplexF32, N, M)
                scpudwnsignal = StructArray{ComplexF32}(
                    (real(zeros(Float32,N,M)),
                    imag(zeros(Float32,N,M))))
                sgpudwnsignal = StructArray{ComplexF32}(
                    (real(CUDA.zeros(Float32,N,M)),
                    imag(CUDA.zeros(Float32,N,M))))
            end
            
            # do the benchmark
            println("Benchmarking correlate on CPU: StructArray{ComplexF32} ", N," samples, ", M, " antenna...")
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
            results_min[rowpos, columnpos] = minimum(result).time
            results_med[rowpos, columnpos] = median(result).time
            results_mean[rowpos, columnpos] = mean(result).time


            println("Benchmarking the correlator on GPU: CuArray{ComplexF32} ", N," samples, ", M, " antenna...")
            result = @benchmark CUDA.@sync gpu_correlate(
                $correlator,
                $gpudwnsignal,
                $gpucode,
                $early_late_sample_shift,
                1,
                $N,
                1.0,
                2,
                Val(7),
            )
            println(minimum(result).time)
            results_min[rowpos, columnpos+3] = minimum(result).time
            results_med[rowpos, columnpos+3] = median(result).time
            results_mean[rowpos, columnpos+3] = mean(result).time


            println("Benchmarking downconvert on GPU: StructArray{ComplexF32}(CuArray,CuArray) ", N, " samples, ", M, " antenna...")
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
            results_min[rowpos, columnpos+6] = minimum(result).time
            results_med[rowpos, columnpos+6] = median(result).time
            results_mean[rowpos, columnpos+6] = mean(result).time

        end
        rowpos += 1
    end
    CSV.write("data/correlate_min.csv", results_min)
    CSV.write("data/correlate_med.csv", results_med)
    CSV.write("data/correlate_mean.csv", results_mean)
end