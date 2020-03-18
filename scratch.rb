require 'openssl'
require 'base64'






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
