require 'openssl'

def encrypt
  puts "Encrypting"
  cipher = OpenSSL::Cipher.new('aes-256-gcm')
  cipher.encrypt
  key = cipher.random_key
  puts key
  iv = cipher.random_iv
  puts iv
  cipher.auth_data= 'auth_data'
  output = File.new("a-encryptedfile.enc", "w")
  buf = ""
  File.open("output", "wb") do |outf|
    File.open("file", "rb") do |inf|
      while inf.read(4096, buf)
        outf << cipher.update(buf)
      end
      outf << cipher.final
    end
  end
  auth_tag = cipher.auth_tag
  puts auth_tag
  File.open("a-key", "w") {|f| f.write(key) }
  File.open("a-iv", "w") {|f| f.write(iv) }
  File.open("a-auth_tag", "w") {|f| f.write(auth_tag) }
end

def decrypt
  puts "Decrypting"
  key = File.read("a-key")
  puts key
  iv = File.read("a-iv")
  puts iv
  auth_tag = File.read("a-auth_tag")
  puts auth_tag
#  decryptcipher = OpenSSL::Cipher.new('aes-256-gcm')
#  decryptcipher.decrypt
#  decryptcipher.key = key
#  decryptcipher.iv = iv
#  decryptcipher.auth_tag = auth_tag
#  decryptcipher.auth_data = 'auth_data'
#  buf = ""
cipher = OpenSSL::Cipher.new('aes-256-gcm')
cipher.decrypt
cipher.key = key
cipher.iv = iv
cipher.auth_tag = auth_tag
cipher.auth_data = 'auth_data'
buf = ""

  File.open("a-decrypted", "wb") do |outf|
    File.open("a-encryptedfile.enc", "rb") do |inf|
      while inf.read(4096, buf)
        outf << cipher.update(buf)
      end
      outf << cipher.final
    end
  end


end

encrypt
decrypt
