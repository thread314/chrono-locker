require 'openssl'

$cipher = OpenSSL::Cipher::AES.new(256, :CBC)
$cipher.encrypt
$key = $cipher.random_key
iv = $cipher.random_iv

def bin_to_int(binary)
  hexkey = binary.unpack("H*").first
  return intkey = hexkey.to_i(16)
end

def int_to_bin(integer)
  binkey = integer.to_s(16)
  if binkey.length < 64
    binkey = "0#{binkey}"
  end
  return [binkey].pack("H*")
end

1000.times do
  tempkey = $cipher.random_key
  inttempkey = bin_to_int(tempkey)
  bintempkey = int_to_bin(inttempkey)
  if tempkey != bintempkey
    puts "failure"
  end
end


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
