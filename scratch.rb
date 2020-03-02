require 'openssl'
data = "Very, very confidential data"

cipher = OpenSSL::Cipher::AES.new(256, :CBC)
cipher.encrypt
key = cipher.random_key
iv = cipher.random_iv

readable = key
puts readable
puts readable.class
readable = key.unpack('c*')
puts readable
readable = readable.to_i(16)
puts readable
puts readable.class
