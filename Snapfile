# Uncomment the lines below you want to change by removing the # in the beginning

# A list of devices you want to take the screenshots from
devices([
	"iPhone 8 Plus",
	"iPhone 8",
	"iPhone X",
	"iPhone 11 Pro",
	"iPhone 11 Pro Max",
	"iPhone SE",
	"iPad Pro (9.7-inch)",
	"iPad Pro (12.9-inch)"
])

languages([
	"ru-RU",
#	"en-US",
#	"de-DE",
#	"it-IT",
#	["pt", "pt_BR"] # Portuguese with Brazilian locale
])

launch_arguments ["SKIP_ANIMATIONS"]
suppress_xcode_output true
stop_after_first_error true
output_simulator_logs true
headless false

# The name of the scheme which contains the UI Tests
 scheme "AlefSwiftLayout"

# Where should the resulting screenshots be stored?
output_directory "./screenshots"

#clear_previous_screenshots true # remove the '#' to clear all previously generated screenshots before creating new ones

# Choose which project/workspace to use
# project "./AlefSwift.xcodeproj"
workspace "./AlefSwift.xcworkspace"

reinstall_app true
erase_simulator true
number_of_retries 5

# Arguments to pass to the app on launch. See https://github.com/fastlane/fastlane/tree/master/snapshot#launch-arguments
# launch_arguments(["-favColor red"])

# For more information about all available options run
# fastlane snapshot --help
