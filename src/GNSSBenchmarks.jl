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
        DataFrames

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
        Tracking.get_current_carrier_frequency,
        Tracking.get_current_code_frequency,
        TrackingLoopFilters.AbstractLoopFilter,
        GNSSSignals.AbstractGNSSSystem

    export
        main,
        benchmark_downconvert,
        benchmark_carrier_replica,
        benchmark_code_replica,
        benchmark_correlate,
        benchmark_tracking_loop

    include("main.jl")
    include("gpu_downconvert.jl")
    include("gpu_carrier_replica.jl")
    include("gpu_code_replica.jl")
    include("gpu_correlate.jl")
    include("gpu_tracking_state.jl")
    include("gpu_tracking_results.jl")
    include("gpu_tracking_loop.jl")
    
    
    const MAX_NUM_SAMPLES = 5000
    const SAMPLES = StepRange(2500,2500,MAX_NUM_SAMPLES)
end
