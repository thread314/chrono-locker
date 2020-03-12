require 'openssl'

$cipher = OpenSSL::Cipher::AES.new(256, :CBC)
$cipher.encrypt
$key = $cipher.random_key
iv = $cipher.random_iv

def bin_to_int(binary)
  hexkey = binary.unpack("H*").first
  intkey = hexkey.to_i(16)
end

def int_to_bin(integer)
  [integer].pack("H*")
end

puts tempkey = $cipher.random_key
puts tempkey = bin_to_int(tempkey)
puts tempkey = int_to_bin(tempkey)


#1.times do
#  tempkey = $cipher.random_key
#  puts "original key -          #{tempkey}"
#  puts tempkey.class
#
#  converted  = bin_to_int(tempkey)
#  puts "key converted to int -  #{converted}"
#  puts converted.class
#  
#  reconverted  = int_to_bin(converted)
#  puts "converted back to bin - #{reconverted}"
#  puts reconverted.class
#
#end



## decryption
#cipher = OpenSSL::Cipher.new('aes-256-cbc')
#cipher.decrypt
#cipher.key = key
#cipher.iv = iv # key and iv are the ones from above
#
#buf = ""
#File.open("file.dec", "wb") do |outf|
#  File.open("output.enc", "rb") do |inf|
#    while inf.read(4096, buf)
#      outf << cipher.update(buf)
#    end
#    outf << cipher.final
#  end
#end
