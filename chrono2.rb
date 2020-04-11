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
  if binkey.length < 12
    (12-binkey.length).times do
      binkey = "0#{binkey}"
    end
  end
  return [binkey].pack("H*")
end

def auth_tag_int_to_bin(integer)
  binkey = integer.to_i.to_s(16)
  if binkey.length < 16
    (16-binkey.length).times do
      binkey = "0#{binkey}"
    end
  end
  return [binkey].pack("H*")
end

def encrypt
  ciphera = OpenSSL::Cipher.new('aes-256-gcm')
  ciphera.encrypt
  key = ciphera.random_key
  iv = ciphera.random_iv
  ciphera.auth_data = 'auth_data'
  buf = ""
  File.open("gcm-encrypted", "wb") do |outf|
    File.open("gcmfile", "rb") do |inf|
      while inf.read(4096, buf)
        outf << ciphera.update(buf)
      end
      outf << ciphera.final
    end
  end
  auth_tag = ciphera.auth_tag
  key = bin_to_int(key)
  iv = bin_to_int(iv)
  auth_tag = bin_to_int(auth_tag)
  File.open("a-key", "w") {|f| f.write(key) }
  File.open("a-iv", "w") {|f| f.write(iv) }
  File.open("a-auth_tag", "w") {|f| f.write(auth_tag) }
end

def decrypt
  key = int_to_bin(File.read("a-key"))
  puts key
  iv = iv_int_to_bin(File.read("a-iv"))
  puts iv
  auth_tag = auth_tag_int_to_bin(File.read("a-auth_tag"))
  puts auth_tag
  cipherb = OpenSSL::Cipher.new('aes-256-gcm')
  cipherb.decrypt
  cipherb.key = key
  cipherb.iv = iv
  cipherb.auth_tag = auth_tag
  cipherb.auth_data = 'auth_data'
  buf = ""
  File.open("gcmfiledecrypted", "wb") do |outf|
    File.open("gcm-encrypted", "rb") do |inf|
      while inf.read(4096, buf)
        outf << cipherb.update(buf)
      end
      outf << cipherb.final
    end
  end
end

encrypt
decrypt
