# CuArray{ComplexF32}
function gpu_downconvert!(
    downconverted_signal::CuVector{ComplexF32},
    carrier::CuVector{ComplexF32},
    signal::CuVector{ComplexF32},
    start_sample::Integer,
    num_samples_left::Integer
)   
    @. @views downconverted_signal[start_sample:num_samples_left + start_sample - 1] =
            signal[start_sample:num_samples_left + start_sample - 1] * 
            conj(carrier[start_sample:num_samples_left + start_sample - 1])
end

# CuArray{ComplexF32} Matrix
function gpu_downconvert!(
    downconverted_signal::CuMatrix{ComplexF32},
    carrier::CuVector{ComplexF32},
    signal::CuMatrix{ComplexF32},
    start_sample::Integer,
    num_samples_left::Integer
)
    @. downconverted_signal = signal * conj(carrier)
end

# StructArray{CuArray} Vector
function gpu_downconvert!(
    downconverted_signal_re::CuVector{Float32},
    downconverted_signal_im::CuVector{Float32},
    carrier_re::CuVector{Float32},
    carrier_im::CuVector{Float32},
    signal_re::CuVector{Float32},
    signal_im::CuVector{Float32},
    start_sample::Integer,
    num_samples_left::Integer
    )
    @. downconverted_signal_re = signal_re * carrier_re + signal_im * carrier_im
    @. downconverted_signal_im = signal_im * carrier_re - signal_re * carrier_im
end

# StructArray{CuArray} Matrix
function gpu_downconvert!(
    downconverted_signal_re::CuMatrix{Float32},
    downconverted_signal_im::CuMatrix{Float32},
    carrier_re::CuVector{Float32},
    carrier_im::CuVector{Float32},
    signal_re::CuMatrix{Float32},
    signal_im::CuMatrix{Float32},
    start_sample::Integer,
    num_samples_left::Integer
    )
    @. downconverted_signal_re = signal_re * carrier_re + signal_im * carrier_im
    @. downconverted_signal_im = signal_im * carrier_re - signal_re * carrier_im
end

# Float32 implementation of the orig. CPU function
function cpu_downconvert!(
    downconverted_signal_re::Vector{Float32},
    downconverted_signal_im::Vector{Float32},
    carrier_re::Vector{Float32},
    carrier_im::Vector{Float32},
    signal_re::Vector{Float32},
    signal_im::Vector{Float32},
    start_sample::Integer,
    num_samples_left::Integer
)
    @avx unroll = 3 for i = start_sample:num_samples_left + start_sample - 1
        downconverted_signal_re[i] = signal_re[i] * carrier_re[i] +
            signal_im[i] * carrier_im[i]
        downconverted_signal_im[i] = signal_im[i] * carrier_re[i] -
            signal_re[i] * carrier_im[i]
    end
end

# Float32 implementation of the orig. CPU function for matrices
function cpu_downconvert!(
    downconverted_signal_re::Matrix{Float32},
    downconverted_signal_im::Matrix{Float32},
    carrier_re::Vector{Float32},
    carrier_im::Vector{Float32},
    signal_re::Matrix{Float32},
    signal_im::Matrix{Float32},
    start_sample::Integer,
    num_samples_left::Integer
)
    @avx unroll = 3 for i = start_sample:num_samples_left + start_sample - 1, j = 1:size(signal_re, 2)
        # Calculate signal * carrier'
        downconverted_signal_re[i, j] = signal_re[i, j] * carrier_re[i] +
            signal_im[i, j] * carrier_im[i]
        downconverted_signal_im[i, j] = signal_im[i, j] * carrier_re[i] -
            signal_re[i, j] * carrier_im[i]
    end
end
