require 'openssl'
require 'base64'

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
  $singledecodeduration
  $cipher = OpenSSL::Cipher::AES.new(256, :CBC)
  $cipher.encrypt
  $key = $cipher.random_key
  $iv = $cipher.random_iv
  puts "Please enter the name of the file you would like to encrypt..."
  $filetoencrypt = "file-large" #gets.chomp
  begin
    puts File.open($filetoencrypt, "r")
  rescue
    puts "Invalid filename"
    openfile
  end
end

def keepkey 
  puts "Would you like to keep a copy of the key? (y/n)"
  keepkeyanswer = "y" #gets.chomp
  if keepkeyanswer == "y" 
    keyfile = "#{$filetoencrypt}.key"
    keyfile = File.new("#{$filetoencrypt}.key", "w")
    keyfile.write($key)
    keyfile.write($iv)
    keyfile.close
    puts "Saving decryption key as #{keyfile}"
  elsif keepkeyanswer == "n"
    puts "WARNING: the decryption key will not be saved. The only way to decrypt the file will be to brute-force it."
  else
    puts "Invalid answer. Please try again."
    keepkey
  end
end

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

def measuredecodetime
  $key = $cipher.random_key
  tempcipher = OpenSSL::Cipher.new('aes-256-cbc')
  tempcipher.decrypt
  tempcipher.key = tempcipher.random_key
  tempcipher.iv = $iv 
  tempcipher.padding = 0
  t1 = Time.now
  puts "Completing trial decryption to set benchmark for decode time..."
  buf = ""
  File.open("test.dec", "wb") do |outf|
    File.open("#{$filetoencrypt}.enc", "rb") do |inf|
      while inf.read(4096, buf)
        outf << tempcipher.update(buf)
      end
      outf << tempcipher.final
    end
  end
  $singledecodeduration = Time.now - t1 
  File.delete("test.dec")
  puts "It took #{$singledecodeduration} seconds to decode the file once."
end

def createpartialkey
  #puts "How long on average (in seconds) would you like it to take to remove the chrono-lock?"
  targetunlocktime = 20 #gets.chomp
  unlockfieldrange = ( 2 * ( targetunlocktime.to_f / $singledecodeduration ) ) .to_i
  searchstartpoint = rand(unlockfieldrange) + ( bin_to_int($key) - unlockfieldrange )
  searchendpoint = searchstartpoint + unlockfieldrange
  encryptedfilename = "#{$filetoencrypt}.keypart"
  output = File.new(encryptedfilename, "w")
  output.puts("#{searchstartpoint},#{searchendpoint}")
  output.puts($iv)
  output.close
end

def decrypt
  puts "Enter the name of the file to decrypt..."
  filetodecrypt = "file-large.enc"  #gets.chomp
  puts "Enter the name of the keyfile..."
  keyfile = "file-large.key"   #gets.chomp
  cipher = OpenSSL::Cipher.new('aes-256-cbc')
  cipher.decrypt
  cipher.key = key
  cipher.iv = iv # key and iv are the ones from above
  buf = ""
  File.open("output", "wb") do |outf|
    File.open(filetodecrypt, "rb") do |inf|
      while inf.read(4096, buf)
        outf << cipher.update(buf)
      end
      outf << cipher.final
    end
  end
end

def selecttask
  puts "Welcome to Chrono-Locker."
  puts "Would you like to encrypt (e) or decrypt (d) a file today?"
  task = gets.chomp
  if task == "e"
    puts "You have chosen to encrypt a file."
    openfile
    keepkey
    encryptfile
    measuredecodetime
    createpartialkey
  elsif task == "d"
    puts "You have chosen to decrypt a file."
    decrypt
  else
    puts "Invalid selection, please try again."
    selecttask
  end
end

selecttask
