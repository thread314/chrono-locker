require 'openssl'

def bin_to_int(binary)
  hexkey = binary.unpack("H*").first
  return hexkey.to_i(16)
end

def int_to_bin(integer)
  binkey = integer.to_i.to_s(16)
  if binkey.length < 64
    (64-binkey.length).times do
      binkey = "0#{binkey}"
    end
  end
  return [binkey].pack("H*")
end

def iv_int_to_bin(integer)
  binkey = integer.to_i.to_s(16)
  if binkey.length < 32
    (32-binkey.length).times do
      binkey = "0#{binkey}"
    end
  end
  return [binkey].pack("H*")
end

10000.times do
  cipher = OpenSSL::Cipher::AES.new(256, :CBC)
  cipher.encrypt
  key = cipher.random_key
  iv = cipher.random_iv
  keyfile = File.new("tempfile", "w")
  keyfile.puts(bin_to_int(key))
  keyfile.puts(bin_to_int(iv))
  keyfile.close
  keyfileopened = File.readlines("tempfile")
  if int_to_bin(keyfileopened[0]) != key
    puts "there was an error"
  end
  if iv_int_to_bin(keyfileopened[1]) != iv
    puts "there was an error - iv"
  end
  File.delete("tempfile")
end




#10000.times do
#  $cipher = OpenSSL::Cipher::AES.new(256, :CBC)
#  $cipher.encrypt
#  key = $cipher.random_key
#  iv = $cipher.random_iv
#  tempfile = File.new("tempfile", "w")
#  encodedkey = Base64.encode64(key)
#  encodediv = Base64.encode64(iv)
#  tempfile.puts(encodedkey)
#  tempfile.puts(encodediv)
#  tempfile.close
#  openedfile = File.readlines("tempfile")
#  readencodedkey = openedfile[0]
#  unencodedkey = Base64.decode64(readencodedkey)
#  readencodediv = openedfile[1]
#  unencodediv = Base64.decode64(readencodediv)
#  if unencodedkey != key || unencodediv != iv 
#    puts "There was an error."
#  end
#end
