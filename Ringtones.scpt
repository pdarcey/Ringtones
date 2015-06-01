(*
Select a group from Contacts (if no group, use all contacts). Use Nickname or Phonetic First/LastName, else First & Last name
Set default messages: ringtone & message e.g. "You've got a message from %NAME%"; "It's %NAME% calling"
Generate voice files: ringtone & message e.g. say -v Karen -o Aleem_message.aiff "You've got a message from Aleem"
Set base sounds: ringtone & message
Combine base sound with each voice file -> ringtone file (ringtone & message)
Add to iTunes
*)

property extension_list : {"m4r"} -- Used to filter files to show when selecting base ringtone/messages file

on run
	(*
	This is where we store the defaults used by the program
*)
	set defaultRingtoneMessage to "It's #NAME calling"
	set defaultiMessageMessage to "You've got a message from #NAME"
	set pathToTemp to POSIX path of (path to temporary items folder)
	set defaultFolder to pathToTemp -- alternative: "$HOME/Desktop/"
	set defaultScript to "say -v #VOICE -o " & defaultFolder & "#FILENAME.aiff \"#MESSAGE\""
	set defaultVoice to "Karen"
	(* Karen is the voice of Austrlian Siri; that's why I made it my default
	   Samantha is the voice of American Siri
	   The British male voice is Daniel
	   I don't know the other countries’ names.
	   All these voices can be downloaded from Apple. 
	   On your Mac, go to System Preferences -> Dicatation & Speech -> Text to Speech. In the System Voice dropdown,
	   select Customise, and you'll see all the voices available for download.
	*)
	set PathToRingtones to "/" & (do shell script "grep '>Music Folder<' \"$HOME/Music/iTunes/iTunes Music Library.xml\" | cut -d/ -f5- |   cut -d\\< -f1 | sed 's/%20/ /g'") & "Tones/" -- get iTunes Library folder	   
	set appPath to path to me
	tell application "Finder"
		set parentPath to (container of appPath) as alias
	end tell
	set defaultRingtoneFileName to "Base_Ringtone.m4r"
	set defaultMessageFileName to "Base_Message.m4r"
	
	set chosenLists to my getContactNames()
	set nameList to item 1 of chosenLists
	set phoneticList to item 2 of chosenLists
	set chosenBaseRingtone to my setBaseRingtone()
	set chosenBaseMessage to my setBaseMessageTone()
	set ringtoneMessage to my setDefaultRingtoneMessage(defaultRingtoneMessage)
	set iMessageMessage to my setDefaultiMessageMessage(defaultiMessageMessage)
	my generateVoiceFiles(nameList, phoneticList, ringtoneMessage, iMessageMessage, defaultFolder, defaultScript, defaultVoice, chosenBaseRingtone, chosenBaseMessage)
	my cleanup()
end run

(*
	This is where we store the defaults used by the program
*)
on setProgramDefaults()
	set defaultRingtoneMessage to "It's #NAME calling"
	set defaultiMessageMessage to "You've got a message from #NAME"
	set pathToTemp to POSIX path of (path to temporary items folder)
	set defaultFolder to pathToTemp -- alternative: "$HOME/Desktop/"
	set defaultScript to "say -v #VOICE -o " & defaultFolder & "#FILENAME.aiff \"#MESSAGE\""
	set defaultVoice to "Karen"
	(* Karen is the voice of Austrlian Siri; that's why I made it my default
	   Samantha is the voice of American Siri
	   The British male voice is Daniel
	   I don't know the other countries’ names.
	   All these voices can be downloaded from Apple. 
	   On your Mac, go to System Preferences -> Dicatation & Speech -> Text to Speech. In the System Voice dropdown,
	   select Customise, and you'll see all the voices available for download.
	*)
	set PathToRingtones to "/" & (do shell script "grep '>Music Folder<' \"$HOME/Music/iTunes/iTunes Music Library.xml\" | cut -d/ -f5- |   cut -d\\< -f1 | sed 's/%20/ /g'") & "Tones/" -- get iTunes Library folder	   
	set appPath to path to me
	tell application "Finder"
		set parentPath to (container of appPath) as alias
	end tell
	set defaultRingtoneFileName to "Base_Ringtone.m4r"
	set defaultMessageFileName to "Base_Message.m4r"
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
						if first name is not missing value then
							set firstName to first name
						end if
						if last name is not missing value then
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
	
	return {nameList, phoneticList}
end getContactNames

on setDefaultRingtoneMessage(defaultRingtoneMessage)
	display dialog "Enter your ringtone message:" default answer defaultRingtoneMessage
	
	return the text returned of the result
end setDefaultRingtoneMessage

on setDefaultiMessageMessage(defaultiMessageMessage)
	display dialog "Enter your iMessage message:" default answer defaultiMessageMessage
	
	return the text returned of the result
end setDefaultiMessageMessage

on generateVoiceFiles(nameList, phoneticList, defaultRingtoneMessage, defaultiMessageMessage, defaultFolder, defaultScript, defaultVoice, chosenBaseRingtone, chosenBaseMessage)
	repeat with i from 1 to the count of nameList
		-- Ringtone
		set thisMessage to defaultRingtoneMessage
		set thisMessage to replace_chars(thisMessage, "#NAME", item i of phoneticList)
		
		set theFileName to item i of nameList & "_ringtone"
		set theScript to defaultScript
		set theScript to replace_chars(theScript, "#VOICE", defaultVoice)
		set theScript to replace_chars(theScript, "#FILENAME", theFileName)
		set theScript to replace_chars(theScript, "#MESSAGE", thisMessage)
		
		do shell script theScript -- Generates the voice file
		set theVoiceFile to POSIX file (defaultFolder & theFileName & ".aiff") as alias
		combineBaseWithVoiceFiles(chosenBaseRingtone, theVoiceFile) -- Generates the ringtone
		
		-- Message
		set thisMessage to defaultiMessageMessage
		set thisMessage to replace_chars(thisMessage, "#NAME", item i of phoneticList)
		
		set theFileName to item i of nameList & "_message"
		set theScript to defaultScript
		set theScript to replace_chars(theScript, "#VOICE", defaultVoice)
		set theScript to replace_chars(theScript, "#FILENAME", theFileName)
		set theScript to replace_chars(theScript, "#MESSAGE", thisMessage)
		
		do shell script theScript -- Generates the voice file
		set theVoiceFile to POSIX file (defaultFolder & theFileName & ".aiff") as alias
		combineBaseWithVoiceFiles(chosenBaseMessage, theVoiceFile) -- Generates the ringtone
		
	end repeat
end generateVoiceFiles

on setBaseRingtone()
	try
		set chosenBaseRingtone to choose file with prompt "Choose an audio file to use as your base Ringtone:" of type extension_list without multiple selections allowed
	on error
		tell application "Finder"
			set chosenBaseRingtone to (file defaultRingtoneFileName of parentPath) as alias
		end tell
	end try
	
	return chosenBaseRingtone
end setBaseRingtone

on setBaseMessageTone()
	try
		set chosenBaseMessage to choose file with prompt "Choose an audio file to use as your base Message notification:" of type extension_list without multiple selections allowed
	on error
		tell application "Finder"
			set chosenBaseMessage to (file defaultMessageFileName of parentPath) as alias
		end tell
	end try
	
	return chosenBaseMessage
end setBaseMessageTone

on combineBaseWithVoiceFiles(baseFile, voiceFile)
	tell application "System Events" to set {baseFileName, baseFileExtension} to {name, name extension} of baseFile -- does this file use an extension in its name?
	if baseFileName ends with baseFileExtension then set baseFileName to (characters 1 thru -((length of baseFileExtension) + 2) of baseFileName) as string -- get rid of the extension so the name is pretty in iTunes
	tell application "QuickTime Player 7"
		stop documents -- stop playing any open documents; make sure QT can accurately identify our ringtone add-on
		set baseDocument to open baseFile -- open our ringtone add-on
		tell baseDocument -- our add-on ringtone sound
			rewind -- I really shouldn't need to do this, but it will hork the output once in a while without it
			select all -- if you don't want the whole sample, you'll need to create a custom file with just the bit you want
			copy -- get what we need
			select none -- so the file is reset properly for export and to prevent arbitrary system event overwrite
		end tell
		set voiceDocument to open voiceFile -- open the spoken name file we created
		set outputPath to POSIX path of voiceFile & ".m4r" -- this is the magic trick to turn regular AAC/MPEG4 into a ringtone
		tell voiceDocument -- our spoken name file
			select none -- avoids occasional unknown source error
			select at 0 to 1 -- before name insertion
			replace -- more reliable than paste
			select none -- so the file is reset properly for export and to prevent arbitrary system event overwrite
			rewind -- just in case we open it again; be kind, rewind
			my exportAAC(voiceDocument, outputPath) -- and here's where the magic happens
			close -- we're done here, move along
		end tell
	end tell
end combineBaseWithVoiceFiles

on exportAAC(voiceDocument, outputPath)
	tell application "QuickTime Player"
		try
			tell voiceDocument
				my setHigh()
				-- export to SayNamePath as MPEG4 using settings file [path to settings file goes here] with replacing
				export with «class repl» given «class expd»:outputPath, «class expk»:«constant expkmpg4», «class exps»:«constant expsexpr» -- if you manually set QT to export at a desired setting, you can then use this line for the same settings; higher settings are nice when you want to use a quality music file as Ringtone Add-on	
				
			end tell
		on error errCODE
			my doError(errCODE)
			return
		end try
	end tell
end exportAAC

on replace_chars(this_text, search_string, replacement_string)
	set AppleScript's text item delimiters to the search_string
	set the item_list to every text item of this_text
	set AppleScript's text item delimiters to the replacement_string
	set this_text to the item_list as string
	set AppleScript's text item delimiters to ""
	return this_text
end replace_chars

on cleanup()
	-- To Do
end cleanup

on doError(errCODE)
	tell current application
		display dialog errCODE & return & return & ¬
			"You really shouldn't be getting an error here, but I threw this in just in case you've got bizarre permissions set on your shared library or something." & return & return & "It's also possible that you have tried to import/export a file that QuickTime light cannot handle." buttons {"OK"} with icon 2 default button 1
		display dialog "Canceling Entire Operation to this point." with icon 0 buttons {"OK"} default button 1
	end tell
	return
end doError

on setHigh()
	-- write to file [filepath & preset192kbps] routine here
	set preset192kbps to "
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<array>
	<dict>
		<key>converter</key>
		<string>SampleRateConverter</string>
		<key>name</key>
		<string>Sample Rate Converter</string>
		<key>parameters</key>
		<array>
			<dict>
				<key>available values</key>
				<array>
					<string>Faster</string>
					<string>Fast</string>
					<string>Normal</string>
					<string>Better</string>
					<string>Best</string>
				</array>
				<key>current value</key>
				<integer>3</integer>
				<key>hint</key>
				<integer>0</integer>
				<key>key</key>
				<string>Quality</string>
				<key>name</key>
				<string>Quality</string>
				<key>summary</key>
				<string>Quality setting for the sample rate converter.</string>
				<key>value type</key>
				<integer>22</integer>
			</dict>
			<dict>
				<key>available values</key>
				<array>
					<string>Pre</string>
					<string>Normal</string>
					<string>None</string>
				</array>
				<key>current value</key>
				<integer>1</integer>
				<key>hint</key>
				<integer>2</integer>
				<key>key</key>
				<string>Priming Method</string>
				<key>name</key>
				<string>Priming Method</string>
				<key>summary</key>
				<string>Priming method for the sample rate converter.</string>
				<key>value type</key>
				<integer>22</integer>
			</dict>
		</array>
		<key>version</key>
		<integer>0</integer>
	</dict>
	<dict>
		<key>converter</key>
		<string>CodecConverter</string>
		<key>name</key>
		<string>MPEG 4 AAC LC Encoder</string>
		<key>parameters</key>
		<array>
			<dict>
				<key>ExplicitValue</key>
				<integer>6619138</integer>
				<key>available values</key>
				<array>
					<string>Mono</string>
					<string>Stereo</string>
					<string>Quadraphonic</string>
					<string>AAC 4.0</string>
					<string>AAC 5.0</string>
					<string>AAC 5.1</string>
					<string>AAC 6.0</string>
					<string>AAC 6.1</string>
					<string>AAC 7.0</string>
					<string>AAC 7.1</string>
					<string>Octagonal</string>
				</array>
				<key>current value</key>
				<integer>1</integer>
				<key>hint</key>
				<integer>5</integer>
				<key>key</key>
				<string>Channel Configuration</string>
				<key>limited values</key>
				<array>
					<string>Stereo</string>
				</array>
				<key>name</key>
				<string>Channel Configuration</string>
				<key>summary</key>
				<string>The channel layout of the AAC produced by the encoder</string>
				<key>value type</key>
				<integer>22</integer>
			</dict>
			<dict>
				<key>ExplicitValue</key>
				<real>44100</real>
				<key>available values</key>
				<array>
					<string>Recommended</string>
					<string>8.000</string>
					<string>11.025</string>
					<string>12.000</string>
					<string>16.000</string>
					<string>22.050</string>
					<string>24.000</string>
					<string>32.000</string>
					<string>44.100</string>
					<string>48.000</string>
				</array>
				<key>current value</key>
				<integer>8</integer>
				<key>hint</key>
				<integer>6</integer>
				<key>key</key>
				<string>Sample Rate</string>
				<key>limited values</key>
				<array>
					<string>Recommended</string>
					<string>32.000</string>
					<string>44.100</string>
					<string>48.000</string>
				</array>
				<key>name</key>
				<string>Sample Rate</string>
				<key>summary</key>
				<string>The sample rate of the AAC produced by the encoder</string>
				<key>unit</key>
				<string>kHz</string>
				<key>value type</key>
				<integer>22</integer>
			</dict>
			<dict>
				<key>ExplicitValue</key>
				<integer>1</integer>
				<key>available values</key>
				<array>
					<string>Average Bit Rate</string>
					<string>Variable Bit Rate</string>
					<string>Variable Bit Rate Constrained</string>
					<string>Constant Bit Rate</string>
				</array>
				<key>current value</key>
				<integer>0</integer>
				<key>hint</key>
				<integer>5</integer>
				<key>key</key>
				<string>Target Format</string>
				<key>limited values</key>
				<array>
					<string>Average Bit Rate</string>
					<string>Variable Bit Rate</string>
					<string>Variable Bit Rate Constrained</string>
					<string>Constant Bit Rate</string>
				</array>
				<key>name</key>
				<string>Encoding Strategy</string>
				<key>summary</key>
				<string>The encoding strategy used for the bit allocation</string>
				<key>value type</key>
				<integer>22</integer>
			</dict>
			<dict>
				<key>BitRateOffset</key>
				<integer>2</integer>
				<key>ExplicitValue</key>
				<integer>192000</integer>
				<key>available values</key>
				<array>
					<string>Recommended</string>
					<string>16</string>
					<string>20</string>
					<string>24</string>
					<string>28</string>
					<string>32</string>
					<string>40</string>
					<string>48</string>
					<string>56</string>
					<string>64</string>
					<string>72</string>
					<string>80</string>
					<string>96</string>
					<string>112</string>
					<string>128</string>
					<string>144</string>
					<string>160</string>
					<string>192</string>
					<string>224</string>
					<string>256</string>
					<string>288</string>
					<string>320</string>
				</array>
				<key>current value</key>
				<integer>17</integer>
				<key>hint</key>
				<integer>4</integer>
				<key>key</key>
				<string>Bit Rate</string>
				<key>limited values</key>
				<array>
					<string>Recommended</string>
					<string>64</string>
					<string>72</string>
					<string>80</string>
					<string>96</string>
					<string>112</string>
					<string>128</string>
					<string>144</string>
					<string>160</string>
					<string>192</string>
					<string>224</string>
					<string>256</string>
					<string>288</string>
					<string>320</string>
				</array>
				<key>name</key>
				<string>Target Bit Rate</string>
				<key>summary</key>
				<string>Encoding with a long-term average bit rate</string>
				<key>unit</key>
				<string>kbps</string>
				<key>value type</key>
				<integer>22</integer>
			</dict>
			<dict>
				<key>ExplicitValue</key>
				<integer>96</integer>
				<key>available values</key>
				<array>
					<string>Good</string>
					<string>Better</string>
					<string>Best</string>
				</array>
				<key>current value</key>
				<integer>2</integer>
				<key>hint</key>
				<integer>1</integer>
				<key>key</key>
				<string>Quality</string>
				<key>name</key>
				<string>Quality</string>
				<key>summary</key>
				<string>The quality of the encoded AAC bitstream</string>
				<key>value type</key>
				<integer>22</integer>
			</dict>
		</array>
		<key>version</key>
		<integer>1</integer>
	</dict>
</array>
</plist>
"
end setHigh
