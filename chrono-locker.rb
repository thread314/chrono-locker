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

def openfile
  $singledecodeduration
  $cipher = OpenSSL::Cipher.new('aes-256-gcm')
  $cipher.encrypt
  $key = $cipher.random_key
  $iv = $cipher.random_iv
  $cipher.auth_data = 'auth_data'
  puts "Please enter the name of the file you would like to encrypt..."
  $filetoencrypt = "file"
  #$filetoencrypt = gets.chomp
  begin
    puts File.open($filetoencrypt, "r")
  rescue
    puts "Invalid filename"
    #openfile
  end
  #  $cipher = OpenSSL::Cipher::AES.new(256, :GCM)
  #  $cipher.encrypt
  #  $key = $cipher.random_key
  #  $iv = $cipher.random_iv
end

def keepkey 
  puts "Would you like to keep a copy of the key? (y/n)"
  keepkeyanswer = "y"
  #keepkeyanswer = gets.chomp
  if keepkeyanswer == "y" 
    keyfile = "#{$filetoencrypt}.key"
    keyfile = File.new("#{$filetoencrypt}.key", "w")
    keyfile.puts(bin_to_int($key))
    puts "this is the kept key #{bin_to_int($key)}"
    keyfile.puts(bin_to_int($iv))
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
  File.open("output", "wb") do |outf|
    File.open($filetoencrypt, "rb") do |inf|
      while inf.read(4096, buf)
        outf << $cipher.update(buf)
      end
      outf << $cipher.final
    end
  end
  $auth_tag = $cipher.auth_tag
  #buf = ""
  #File.open(output, "wb") do |outf|
  #  File.open($filetoencrypt, "rb") do |inf|
  #    while inf.read(4096, buf)
  #      outf << $cipher.update(buf)
  #    end
  #    outf << $cipher.final
  #  end
  #end
  puts "File has been encrypted and saved as \"#{encryptedfilename}\""
end

def measuredecodetime
  tempcipher = OpenSSL::Cipher.new('aes-256-gcm')
  tempcipher.decrypt
  tempcipher.key = tempcipher.random_key
  tempcipher.iv = $iv 
  tempcipher.padding = 0
  begin
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
  rescue
  $singledecodeduration = 1 #Time.now - t1 
  File.delete("test.dec")
  puts "It took #{$singledecodeduration} seconds to decode the file once."
  end
end

def createpartialkey
  puts "How long on average (in seconds) would you like it to take to remove the chrono-lock?"
  targetunlocktime = "100"
  #targetunlocktime = gets.chomp
  unlockfieldrange = ( 2 * ( targetunlocktime.to_f / $singledecodeduration ) ) .to_i
  searchstartpoint = rand(unlockfieldrange) + ( bin_to_int($key) - unlockfieldrange )
  searchendpoint = searchstartpoint + unlockfieldrange
  puts "this is searchstartpoint #{searchstartpoint}"
  puts "this is searchendpoint #{searchendpoint}"
  if bin_to_int($key) > searchstartpoint && bin_to_int($key) < searchendpoint
    puts "the key is in range"
    puts searchendpoint - searchstartpoint 
  else
    puts "THE KEY IS NOT IN RANGE!!!!!!!!!!!!!!!"
  end
  encryptedfilename = "#{$filetoencrypt}.keypart"
  output = File.new(encryptedfilename, "w")
  output.puts("#{searchstartpoint},#{searchendpoint}")
  output.puts(bin_to_int($iv))
  output.puts($auth_tag)
  output.close
end

def decrypt
  puts "Enter the name of the file to decrypt..."
  #filetodecrypt = gets.chomp
  filetodecrypt = "file.enc" 
  puts "Enter the name of the keyfile..."
  #keyfilename = gets.chomp
  keyfilename = "file.keypart"
  keyfile = File.readlines(keyfilename)

  #decrypt
  #cipher = OpenSSL::Cipher.new('aes-256-gcm')
  #cipher.decrypt
  cipher = OpenSSL::Cipher.new('aes-256-gcm')
  cipher.decrypt
  keyrange = 0
  if keyfile[0].include?(",")
    keyrange = keyfile[0].split(",")
    keyrange = (keyrange[0]..keyrange[1])
  else
    keyrange = (keyfile[0]..keyfile[0])
  end
  remainingattempts = keyrange.last.to_i - keyrange.first.to_i
  puts keyrange
  keyrange.each do |keyattempt|
    begin
      puts keyattempt.to_s.class
      puts keyattempt
      puts keyfile[1].class
      puts keyfile[1]

      cipher.key = int_to_bin(keyattempt.to_s)
      cipher.iv = iv_int_to_bin(keyfile[1])
      cipher.auth_tag = keyfile[2]
      cipher.auth_data = 'auth_data'
      buf = ""
      File.open("output", "wb") do |outf|
        File.open(filetodecrypt, "rb") do |inf|
          while inf.read(4096, buf)
            outf << cipher.update(buf)
          end
          outf << cipher.final
        end
      end
  #    cipher.key = int_to_bin(keyattempt.to_s)
  #    cipher.iv = iv_int_to_bin(keyfile[1])
  #    buf = ""
  #    File.open("output", "wb") do |outf|
  #      File.open(filetodecrypt, "rb") do |inf|
  #        while inf.read(4096, buf)
  #          outf << cipher.update(buf)
  #        end
  #        outf << cipher.final
  #      end
  #    end
      puts "decryption successful"
      break
    rescue => error
      puts error
      puts "Still working on it - #{remainingattempts} attempts remaining"
      remainingattempts -= 1
    end
  end
end

def selecttask
  puts "Welcome to Chrono-Locker."
  puts "Would you like to (e)ncrypt or (d)ecrypt a file today?"
  task = gets.chomp
  #task = "d"
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
