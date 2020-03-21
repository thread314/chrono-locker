require 'openssl'

# encryption
cipher = OpenSSL::Cipher.new('aes-256-gcm')
cipher.encrypt
key = cipher.random_key
iv = cipher.random_iv
cipher.auth_data = ""
auth_tag = cipher.auth_tag 

output = File.new("output.enc", "w")
buf = ""
File.open("output.enc", "wb") do |outf|
  File.open("file", "rb") do |inf|
    while inf.read(4096, buf)
      outf << cipher.update(buf)
    end
    outf << cipher.final
  end
end

# decryption
cipher = OpenSSL::Cipher.new('aes-256-gcm')
cipher.decrypt
cipher.key = key
cipher.iv = iv 
cipher.auth_data = ""

buf = ""
File.open("file.dec", "wb") do |outf|
  File.open("output.enc", "rb") do |inf|
    while inf.read(4096, buf)
      outf << cipher.update(buf)
    end
    outf << cipher.final
  end
end
