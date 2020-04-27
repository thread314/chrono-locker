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

def openfile
  #$filetoencrypt = 'file'
  $filetoencrypt = ""
  until File.file?($filetoencrypt)
    puts "Please enter the name of the file you would like to encrypt..."
    $filetoencrypt = gets.chomp
  end
end

def encryptfile
  cipher = OpenSSL::Cipher.new('aes-256-gcm')
  cipher.encrypt
  $key = cipher.random_key
  $iv = cipher.random_iv
  cipher.auth_data= 'auth_data'
  encryptedfilename = "#{$filetoencrypt}.enc"
  buf = ""
  File.open(encryptedfilename, "wb") do |outf|
    File.open($filetoencrypt, "rb") do |inf|
      while inf.read(4096, buf)
        outf << cipher.update(buf)
      end
      outf << cipher.final
    end
  end
  $auth_tag = cipher.auth_tag
  puts "File has been encrypted and saved as \"#{encryptedfilename}\""
end

def keepkey 
  puts "Would you like to keep a copy of the key? (y/n) (So you can bypass the chrono-lock, if needed)"
  #keepkeyanswer = "y"
  keepkeyanswer = gets.chomp
  if keepkeyanswer == "y" 
    keyfile = File.new("#{$filetoencrypt}.key", "w")
    keyfile.puts(bin_to_int($key))
    keyfile.puts(Base64.encode64($iv))
    keyfile.puts(Base64.encode64($auth_tag))
    keyfile.close
  keyfile.close
  elsif keepkeyanswer == "n"
    puts "WARNING: the decryption key will not be saved. The only way to decrypt the file will be to brute-force it."
  else
    puts "Invalid answer. Please try again."
    keepkey
  end
end

def measuredecodetime
  tempcipher = OpenSSL::Cipher.new('aes-256-gcm')
  tempcipher.decrypt
  tempcipher.iv = tempcipher.random_iv 
  decodetimes = []
  puts "Completing trial decryption to set benchmark for decode time..."
  10.times do
    begin
      tempcipher.key = tempcipher.random_key
      t1 = Time.now
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
      decodetimes.push(Time.now - t1)
      File.delete("test.dec")
    end
  end

  #array = [2,3,3,3,3]
  #$singledecodeduration = array.inject { |sum, element| sum + element}
  #puts $singledecodeduration

  $singledecodeduration = decodetimes.inject{ |sum, element| sum + element }.to_f / decodetimes.size
  puts decodetimes
  puts decodetimes.size
  puts "average"
  puts $singledecodeduration
end

def createpartialkey
  begin
    puts "How long on average (in seconds) would you like it to take to remove the chrono-lock?"
    Float targetunlocktime = gets.chomp
    #targetunlocktime = "1"
    unlockfieldrange = ( 2 * ( targetunlocktime.to_f / $singledecodeduration ) ) .to_i
    searchstartpoint = rand(unlockfieldrange) + ( bin_to_int($key) - unlockfieldrange )
    searchendpoint = searchstartpoint + unlockfieldrange
    encryptedfilename = "#{$filetoencrypt}.keypart"
    output = File.new(encryptedfilename, "w")
    output.puts("#{searchstartpoint},#{searchendpoint}")
    output.puts(Base64.encode64($iv))
    output.puts(Base64.encode64($auth_tag))
    output.close
    #fifthpercentile = 0.05 * unlockfieldrange * $singledecodeduration 
    #ninetyfifthpercentile = 0.95 * unlockfieldrange * $singledecodeduration 
    puts "The file has been encrypted. Using #{encryptedfilename} and this machine, it should take an average #{targetunlocktime} seconds to decrypt the file." 
    #puts "Note that there is *significant* variance in this estimate. In 5 percent of cases it will take less than #{fifthpercentile} seconds to decrypt. In another 5 percent of cases it will take longer than #{ninetyfifthpercentile} seconds to decrypt." 
    puts "Note that there will be *significant* variance in this estimate, which will be greatly impacted by computing resources and even luck. This tool is provided with no guarantees and no responsibility."
  rescue
    puts "Not a valid selection"
    retry
  end
end

def decrypt
  filetodecrypt = ""
  #filetodecrypt = "file.enc" 
  until File.file?(filetodecrypt)
    puts "Enter the name of the file to decrypt..."
    filetodecrypt = gets.chomp
  end
  keyfilename = ""
  #keyfilename = "file.keypart"
  until File.file?(keyfilename)
    puts "Enter the name of the keyfile..."
     keyfilename = gets.chomp
  end
  keyfile = File.readlines(keyfilename)
  decryptcipher = OpenSSL::Cipher.new('aes-256-gcm')
  decryptcipher.decrypt
  keyrange = 0
  if keyfile[0].include?(",")
    keyrange = keyfile[0].split(",")
    keyrange = (keyrange[0]..keyrange[1])
  else
    keyrange = (keyfile[0]..keyfile[0])
  end
  keysexplored = 0
  starttime = Time.now
  keyspace = keyrange.end.to_i - keyrange.begin.to_i
  percentcomplete = 0
  keyrange.each do |keyattempt|
    begin
      decryptcipher.key = int_to_bin(keyattempt.to_s)
      decryptcipher.iv = Base64.decode64(keyfile[1])
      decryptcipher.auth_tag = Base64.decode64(keyfile[2])
      decryptcipher.auth_data = 'auth_data'
      buf = ""
      File.open("file.decrypted", "wb") do |outf|
        File.open(filetodecrypt, "rb") do |inf|
          while inf.read(4096, buf)
            outf << decryptcipher.update(buf)
          end
          outf << decryptcipher.final
        end
      end
      puts "decryption successful"
      puts "It took #{Time.now - starttime} seconds to decrypt."
      #Saving decrypt time to file
      f = File.open('decrypttimes', 'a')
      f.write("#{(Time.now - starttime)} \t\t\t\t #{percentcomplete} \n")
      f.close
      #Finished saving decrypt time to file
      break
    rescue => error
      keysexplored += 1
      unless percentcomplete == ((keysexplored.to_f / keyspace.to_f) * 100).to_i
        puts "#{percentcomplete}% of the key space has been explored"
      end
      percentcomplete = ((keysexplored.to_f / keyspace.to_f) * 100).to_i
    end
  end
end

def selecttask
  puts "Welcome to Chrono-Locker."
  puts "Would you like to (e)ncrypt or (d)ecrypt a file today?"
  task = gets.chomp
  #task = "e"
  if task == "e"
    puts "You have chosen to encrypt a file."
    openfile
    encryptfile
    keepkey
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
