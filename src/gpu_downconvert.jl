# CuArray{ComplexF32}
function gpu_downconvert!(
    downconverted_signal::CuArray{ComplexF32},
    carrier::CuArray{ComplexF32},
    signal::CuArray{ComplexF32},
    start_sample::Integer,
    num_samples_left::Integer
)
    @. @views downconverted_signal[start_sample:num_samples_left + start_sample - 1] =
            signal[start_sample:num_samples_left + start_sample - 1] * 
            conj(carrier[start_sample:num_samples_left + start_sample - 1])
end

# CuArray{ComplexF32}
function gpu_downconvert!(
    downconverted_signal::CuArray{ComplexF32},
    carrier::CuArray{ComplexF32},
    signal::CuArray{ComplexF32},
    start_sample::Integer,
    num_samples_left::Integer
)
    @. @views downconverted_signal[start_sample:num_samples_left + start_sample - 1] =
            signal[start_sample:num_samples_left + start_sample - 1] * 
            conj(carrier[start_sample:num_samples_left + start_sample - 1])
end

# StructArray of CuArrays
function gpu_downconvert!(
    downconverted_signal_re::CuArray{Float32},
    downconverted_signal_im::CuArray{Float32},
    carrier_re::CuArray{Float32},
    carrier_im::CuArray{Float32},
    signal_re::CuArray{Float32},
    signal_im::CuArray{Float32},
    start_sample::Integer,
    num_samples_left::Integer
)
    @. @views downconverted_signal_re[start_sample:num_samples_left + start_sample - 1] = 
            signal_re[start_sample:num_samples_left + start_sample - 1] * 
            carrier_re[start_sample:num_samples_left + start_sample - 1] + 
            signal_im[start_sample:num_samples_left + start_sample - 1] * 
            carrier_im[start_sample:num_samples_left + start_sample - 1]
    @. @views downconverted_signal_im[start_sample:num_samples_left + start_sample - 1] = 
            signal_im[start_sample:num_samples_left + start_sample - 1] * 
            carrier_re[start_sample:num_samples_left + start_sample - 1] - 
            signal_re[start_sample:num_samples_left + start_sample - 1] * 
            carrier_im[start_sample:num_samples_left + start_sample - 1]
end

# Float32 implementation of the orig. CPU function
function gpu_downconvert!(
    downconverted_signal_re::Array{Float32},
    downconverted_signal_im::Array{Float32},
    carrier_re::Array{Float32},
    carrier_im::Array{Float32},
    signal_re::Array{Float32},
    signal_im::Array{Float32},
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

