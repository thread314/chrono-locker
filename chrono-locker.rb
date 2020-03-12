require 'openssl'

$cipher = OpenSSL::Cipher::AES.new(256, :CBC)
$cipher.encrypt
$key = $cipher.random_key
iv = $cipher.random_iv
puts "Welcome to Chrono-Locker."
puts "Please enter the name of the file you would like to encrypt..."

def bin_to_int(binary)
  hexkey = binary.unpack("H*").first
  return hexkey.to_i(16)
end

def int_to_bin(integer)
  binkey = integer.to_s(16)
  if binkey.length < 64
    binkey = "0#{binkey}"
  end
  return [binkey].pack("H*")
end

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

def encryptfile
  encryptedfilename = "#{$filetoencrypt}.enc"
  output = File.new(encryptedfilename, "w")
  buf = ""
  File.open(output, "wb") do |outf|
    File.open($filetoencrypt, "rb") do |inf|
      while inf.read(4096, buf)
        outf << $cipher.update(buf)
      end
      outf << $cipher.final
    end
  end
  puts "File has been encrypted and saved as \"#{encryptedfilename}\""
end

encryptfile

def setdecodetime
  t1 = Time.now
end

#setdecodetime

#
#puts "**************"
#
#
#



#
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
