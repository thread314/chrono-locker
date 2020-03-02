require 'openssl'
cipher = OpenSSL::Cipher.new('aes-256-cbc')
cipher.encrypt

cipher.key = "r"*32
cipher.iv = "0"*16

secret = "This is the secret, don't tell anyone!"

encrypted =  cipher.update(secret) + cipher.final


puts secret
puts encrypted

cipher.decrypt

