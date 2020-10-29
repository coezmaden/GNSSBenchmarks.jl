module GNSSBenchmarks
    using
        CUDA,
        CSV,
        StructArrays,
        BenchmarkTools,
        LoopVectorization,
        Tracking,
        TrackingLoopFilters,
        GNSSSignals,
        DataFrames,
        PGFPlotsX,
        LinearAlgebra

    using Unitful: upreferred, Hz, dBHz, ms, kHz, MHz
    
    import
        LinearAlgebra.dot,
        Base.length,
        Tracking.TrackingState,
        Tracking.NumAnts,
        Tracking.MomentsCN0Estimator,
        Tracking.AbstractCN0Estimator,
        Tracking.AbstractCorrelator,
        Tracking.EarlyPromptLateCorrelator,
        Tracking.SecondaryCodeOrBitDetector,
        Tracking.GainControlledSignal,
        Tracking.found,
        Tracking.TrackingResults,
        Tracking.BitBuffer,
        Tracking.get_default_post_corr_filter,
        Tracking.get_num_samples_left_to_integrate,
        Tracking.get_num_samples,
        Tracking.get_num_ants,
        Tracking.get_current_carrier_frequency,
        Tracking.get_current_code_frequency,
        TrackingLoopFilters.AbstractLoopFilter,
        GNSSSignals.AbstractGNSSSystem

    export
        main,
        plotall,
        benchmark_downconvert,
        benchmark_carrier_replica,
        benchmark_code_replica,
        benchmark_correlate,
        benchmark_tracking_loop,
        plot_carrier_replica,
        gpu_correlate

    include("main.jl")
    include("plot.jl")
    include("gpu_downconvert.jl")
    include("gpu_carrier_replica.jl")
    include("gpu_code_replica.jl")
    include("gpu_correlate.jl")
    include("gpu_tracking_state.jl")
    include("gpu_tracking_results.jl")
    include("gpu_tracking_loop.jl")
    include("benchmark_carrier_replica.jl")
    include("benchmark_code_replica.jl")
    include("benchmark_downconvert.jl")
    include("benchmark_correlate.jl")
    include("benchmark_gpu_tracking_loop.jl")

    const MAX_NUM_SAMPLES = 50000
    const SAMPLES = StepRange(2500,2500,MAX_NUM_SAMPLES)
    const ANTENNA = [1, 4, 16]
end
