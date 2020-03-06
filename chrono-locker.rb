require 'openssl'

cipher = OpenSSL::Cipher::AES.new(256, :CBC)
cipher.encrypt
$key = cipher.random_key
iv = cipher.random_iv
puts "Welcome to Chrono-Locker."
puts "Please enter the name of the file you would like to encrypt..."

def openfile
  $filetoencrypt = gets.chomp
  begin
    puts File.open($filetoencrypt, "r")
  rescue
    puts "Invalid filename"
    openfile
  end
end

openfile

puts $filetoencrypt

def keepkey 
  puts "Would you like to keep a copy of the key? (y/n)"
  keepkeyanswer = gets.chomp
  if keepkeyanswer == "y" 
    keyfile = "#{$filetoencrypt}.key"
    keyfile = File.new("#{$filetoencrypt}.key", "w")
    keyfile.write($key)
    keyfile.close
    puts "Saving decryption key as #{keyfile}"
  elsif keepkeyanswer == "n"
    puts "WARNING: the decryption key will not be saved. The only way to decrypt the file will be to brute-force it."
  else
    puts "Invalid answer. Please try again."
    keepkey
  end
end

keepkey


#
#encrypted = cipher.update(data) + cipher.final
#puts $key
#keyasinteger = $key.unpack('H*').first
#keyasinteger = $keyasinteger.to_i(16)
#
#puts "**************"
#
#decipherkey = keyasinteger 
#decipherkey = decipherkey.to_s(16)
#
#if decipherkey.length < 64
#   decipherkey = "0#{decipherkey}"
#end
#
#decipherkey = [decipherkey].pack('H*')
#puts decipherkey
#
#decipher = OpenSSL::Cipher::AES.new(256, :CBC)
#decipher.decrypt
#decipher.$key = decipherkey
#decipher.iv = iv
#
#plain = decipher.update(encrypted) + decipher.final
#
#puts data == plain #=> true
