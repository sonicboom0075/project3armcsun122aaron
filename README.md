LEFT BLACK BUTTON (AKA TOGGLELOCK):
1. Does a PIN exist?:
	Check memory location to see if a PIN is stored there
2. Is program in locked state or unlocked state?
	Check memory location to see if it's equal to 1 or 2. 1 = unlocked 2 = locked
3. Set to lock state
	Store 2 to memory location containing lock state.
4. Did user input a PIN before pushing Left black button?
	Check register to see if a PIN is stored there.
5. Check to see if PIN matches any of the saved PINs.
	if(currentPIN==savedPIN)
		return true
6. Set status to unlocked
	Store 1 to memory location containing lock state.
	
RIGHT BLACK BUTTON (AKA PROGRAMMING):
1. Set to Programming mode
	Listen for blue key presses
	Blue key presses get sent to memory location for PIN
2. Does PIN already exist?
	Check memory location to see if a PIN is stored there
3. Check to see if input PIN is valid
	if(currentPIN.length != 4)
		return "error"
4. Confirm the PIN
	if(currentPIN != savedPIN)
		return "error"
5. If PIN already exists: Before pushing right black button again, was there a PIN input?
	Check register to see if a PIN is stored there.
6. Was the PIN input again AND was it correct?
	if(currentPIN != savedPIN)
		return "error"
7. Delete PIN from memory
	Store 0 to memory location containing PIN.
