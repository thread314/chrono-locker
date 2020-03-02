require 'openssl'
data = "Very, very confidential data"

cipher = OpenSSL::Cipher::AES.new(256, :CBC)
cipher.encrypt
key = cipher.random_key
iv = cipher.random_iv

encrypted = cipher.update(data) + cipher.final
readable = key
puts readable
readable = key.unpack('H*').first
puts readable
readable = readable.to_i(16)
puts readable
puts readable.class

puts "**************"

decipherkey = readable 
puts decipherkey
decipherkey = [decipherkey.to_s(16)]
puts decipherkey
decipherkey = decipherkey.pack('H*')
puts decipherkey

decipher = OpenSSL::Cipher::AES.new(256, :CBC)
decipher.decrypt
decipher.key = decipherkey
decipher.iv = iv

plain = decipher.update(encrypted) + decipher.final

puts data == plain #=> true
