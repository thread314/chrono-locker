require 'openssl'
data = "Very, very confidential data"

cipher = OpenSSL::Cipher::AES.new(256, :CBC)
cipher.encrypt
key = cipher.random_key
iv = cipher.random_iv

encrypted = cipher.update(data) + cipher.final
puts key
puts key.class
readable = key.unpack('H*')
puts readable
puts key.unpack('H*').first
puts key.unpack('H*').first.to_i(16)
readable = key.unpack('H*').first.to_i(16) + 1
puts "**************"
decipherkey = [readable.to_s(16)].pack('H*')

decipher = OpenSSL::Cipher::AES.new(256, :CBC)
decipher.decrypt
decipher.key = decipherkey
decipher.iv = iv

plain = decipher.update(encrypted) + decipher.final

puts data == plain #=> true
