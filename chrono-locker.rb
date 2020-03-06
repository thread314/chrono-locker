require 'openssl'
data = "Very, very confidential data"

cipher = OpenSSL::Cipher::AES.new(256, :CBC)
cipher.encrypt
key = cipher.random_key
iv = cipher.random_iv

encrypted = cipher.update(data) + cipher.final
puts key
keyasinteger = key.unpack('H*').first
keyasinteger = keyasinteger.to_i(16)

puts "**************"

decipherkey = keyasinteger 
decipherkey = decipherkey.to_s(16)

if decipherkey.length < 64
   decipherkey = "0#{decipherkey}"
end

decipherkey = [decipherkey].pack('H*')
puts decipherkey

decipher = OpenSSL::Cipher::AES.new(256, :CBC)
decipher.decrypt
decipher.key = decipherkey
decipher.iv = iv

plain = decipher.update(encrypted) + decipher.final

puts data == plain #=> true
