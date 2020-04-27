# Chrono-Locker

Chrono-Locker is a simple utility that encrypts your files and then saves the decryption key in such a way that you can only recover the file after dedicating a certain amount of time and computing resources to the problem. 

This has the effect of 'locking' you out of the files, but only for a certain amount of time. 

This is an idea that has been explored [many times and in some detail](https://www.gwern.net/Self-decrypting-files), however despite my searching I was unable to find any actual functional implementation, so I put this together. 

This is a very simple app and is by no means the optimal implementation, but it is an implementation. 

### It works by:

* Encrypting the specified file. 
* The user specifies how long they would like the decryption to be delayed for. 
* Instead of saving just the decryption key, saving a range of values that contains the key at some random point. 
* When trying to decrypt the file, the utility brute-forces this range of values, until it finds the correct key and decrypts the file. 

### !!!WARNING!!!

* This utility comes with absolutely no guarantees or liability. When encrypting files there is a very real possibility that the data can be irretrievably lost. USE AT YOUR OWN RISK. 
* By nature of how the ap works, there will be *significant* variance in the real-world times it takes to decrypt a file. This is because key will be contained at some random point in the keyspace and the app is simply cycling through this keyspace. By chance the key could be very early or late in the keyspace, which will greatly effect the decryption time. 
* The decryption estimate is based on the machine that performs the encryption and the decryption time will scale with the amount of computational resources applied to it. In other words, if in attacker has a more powerful machine/access to multiple machines they could decrypt the file much quicker than you intended. Conversely if you are decrypting the file on a system less powerful than the machine that encrypted it, it could take a lot longer. 

### Installation

* Clone the repo (`git clone git@github.com:thread314/chrono-locker.git`)
* Install Ruby, if you don't have it already (`sudo apt install ruby`)
* Run the program (`ruby chrono-locker.rb`)
* Follow the prompts. 
