(*
Select a group from Contacts (if no group, use all contacts). Use Nickname or Phonetic First/LastName, else First & Last name
Set default messages: ringtone & message e.g. "You've got a message from %NAME%"; "It's %NAME% calling"
Generate voice files: ringtone & message e.g. say -v Karen -o Aleem_message.aiff "You've got a message from Aleem"
Set base sounds: ringtone & message
Combine base sound with each voice file -> ringtone file (ringtone & message)
Add to iTunes
*)

on run
	setProgramDefaults
	getContactNames
	setDefaultRingtoneMessage
	setDefaultiMessageMessage
	generateVoiceFiles
	setBaseRingtone
	setBaseMessageTone
	combineBaseRingtoneWithRingtoneVoiceFiles
	combineBaseMessageToneWithMessageVoiceFiles
	addToiTunes
end run

(*
	This is where we store the defaults used by the program
*)
on setProgramDefaults()
	set defaultRingtoneMessage to "It's #NAME calling"
	set defaultiMessageMessage to "You've got a message from #NAME"
	set defaultFolder to "$HOME/Desktop/"
	set defaultScript to "say -v #VOICE -o " & defaultFolder & "#FILENAME.aiff \"#MESSAGE\""
	set defaultVoice to "Karen"
end setProgramDefaults

(*
	Get contact names from Contacts.
	Asks the user to select one or more groups, then creates two lists:
	1. a list of names; this will be used to create easily-understandable file names for our output
	2. a list of phonetic names; this will be used to generate our ringtones. It generates them in this order:
			* If there is an entry in Phonetic First Name, it will use that
			* Otherwise, if it is a company, it will use the Company Name
			* Otherwise, if there is a nickname, it will use that
			* Otherwise, it will use the full name of the person
*)
on getContactNames()
	tell application "Contacts"
		set everyGroup to name of every group
		set theGroupName to (choose from list everyGroup with title "Groups" with prompt "Choose group(s) to create ringtones for" with multiple selections allowed)
		set nameList to {}
		set phoneticList to {}
		repeat with i from 1 to the count of theGroupName
			set theGroup to group (item i of theGroupName)
			set thePeople to every person of theGroup
			repeat with j from 1 to the count of thePeople
				set thePerson to item j of thePeople
				tell thePerson
					if company then
						set theName to organization
						if theName is missing value then
							set theName to name
						end if
						set sayName to theName
						if phonetic first name of thePerson is not missing value then
							set sayName to "Your " & phonetic first name
						end if
					else
						set firstName to ""
						set lastName to ""
						if first name is not misssing value then
							set firstName to first name
						end if
						if last name is not misssing value then
							set lastName to last name
						end if
						set theName to first name & last name
						set sayName to name
						if nickname is not missing value then
							set sayName to nickname
						end if
						if phonetic first name of thePerson is not missing value then
							set sayName to phonetic first name
						end if
					end if
					set end of nameList to theName
					set end of phoneticList to sayName
				end tell
			end repeat
		end repeat
		get nameList
		get phoneticList
	end tell
end getContactNames

on setDefaultRingtoneMessage()
	display dialog "Enter your ringtone message:" default answer defaultRingtoneMessage
	set ringtoneMessage to the text returned of the result
end setDefaultRingtoneMessage

on setDefaultiMessageMessage()
	display dialog "Enter your iMessage message:" default answer defaultiMessageMessage
	set iMessageMessage to the text returned of the result
end setDefaultiMessageMessage

on generateVoiceFiles()
	repeat with i from 1 to the count of nameList
		-- Ringtone
		set thisMessage to defaultRingtoneMessage
		set thisMessage to replace_chars(thisMessage, "#NAME", item i of phoneticList)
	
		set theScript to defaultScript
		set theScript to replace_chars(theScript, "#VOICE", defaultVoice)
		set theScript to replace_chars(theScript, "#FILENAME", item i of nameList & "_ringtone")
		set theScript to replace_chars(theScript, "#MESSAGE", thisMessage)
	
		do shell script theScript
	
		-- Message
		set thisMessage to defaultiMessageMessage
		set thisMessage to replace_chars(thisMessage, "#NAME", item i of phoneticList)
	
		set theScript to defaultScript
		set theScript to replace_chars(theScript, "#VOICE", defaultVoice)
		set theScript to replace_chars(theScript, "#FILENAME", item i of nameList & "_message")
		set theScript to replace_chars(theScript, "#MESSAGE", thisMessage)
	
		do shell script theScript
	end repeat
end generateVoiceFiles

on setBaseRingtone()
end setBaseRingtone

on setBaseMessageTone()
end setBaseMessageTone

on combineBaseRingtoneWithRingtoneVoiceFiles()
end combineBaseRingtoneWithRingtoneVoiceFiles

on combineBaseMessageToneWithMessageVoiceFiles()
end combineBaseMessageToneWithMessageVoiceFiles

on addToiTunes()
end addToiTunes

on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars
