require 'openssl'
require 'base64'

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
  keyin64 = Base64.encode64(key)
  ivin64 = Base64.encode64(iv)
  auth_tagin64 = Base64.encode64(auth_tag)
  File.open("a-key", "w") {|f| f.write(keyin64) }
  File.open("a-iv", "w") {|f| f.write(ivin64) }
  File.open("a-auth_tag", "w") {|f| f.write(auth_tagin64) }
end

def decrypt
  key = Base64.decode64(File.read("a-key"))
  iv = Base64.decode64(File.read("a-iv"))
  auth_tag = Base64.decode64(File.read("a-auth_tag"))
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

10000.times do
  encrypt 
  decrypt 
end

#100.times do
#  cipher = OpenSSL::Cipher.new('aes-256-gcm')
#  cipher.encrypt
#  cipher.random_key
#  original = cipher.random_iv
#  cipher.auth_data = 'auth_data'
#  buf = ""
#  File.open("gcm-encrypted", "wb") do |outf|
#    File.open("gcmfile", "rb") do |inf|
#      while inf.read(4096, buf)
#        outf << cipher.update(buf)
#      end
#      outf << cipher.final
#    end
#  end
#  changed = Base64.encode64(original)
#  File.open("foo", "w") {|f| f.write(changed) }
#  readfromfile = File.read("foo")
#  changed = Base64.decode64(readfromfile)
#  if original != changed
#    puts "There was a problem"
#  end
#end
