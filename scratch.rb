require 'openssl'
require 'base64'

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

#convert to int, increment it, convert back to bin, convert to 64 convet back
10000.times do
  cipher = OpenSSL::Cipher.new('aes-256-gcm')
  cipher.encrypt
  key = cipher.random_key
  changed = bin_to_int(key)
  changed += 1
  changed = int_to_bin(changed)
  changed = Base64.encode64(changed)
  changed = Base64.decode64(changed)
end
