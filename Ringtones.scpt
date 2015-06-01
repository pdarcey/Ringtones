(*
Select a group from Contacts (if no group, use all contacts). Use Nickname or Phonetic First/LastName, else First & Last name
Set default messages: ringtone & message e.g. "You've got a message from %NAME%"; "It's %NAME% calling"
Generate voice files: ringtone & message e.g. say -v Karen -o Aleem_message.aiff "You've got a message from Aleem"
Set base sounds: ringtone & message
Combine base sound with each voice file -> ringtone file (ringtone & message)
Add to iTunes
*)

on run
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
						set theName to name
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
end setDefaultRingtoneMessage

on setDefaultiMessageMessage()
end setDefaultiMessageMessage

on generateVoiceFiles()
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
