require 'rubygems'
require 'plist'
require 'securerandom'
 
# Plist format:
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
#   <key>IDECodeSnippetCompletionPrefix</key>
#   <string>deg2rad</string>
#   <key>IDECodeSnippetCompletionScopes</key>
#   <array>
#     <string>TopLevel</string>
#   </array>
#   <key>IDECodeSnippetContents</key>
#   <string>#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)</string>
#   <key>IDECodeSnippetIdentifier</key>
#   <string>AC8BA180-1DC2-4982-B393-AF2F54151A2F</string>
#   <key>IDECodeSnippetLanguage</key>
#   <string>Xcode.SourceCodeLanguage.Objective-C</string>
#   <key>IDECodeSnippetTitle</key>
#   <string>Degrees to Radians Macro</string>
#   <key>IDECodeSnippetUserSnippet</key>
#   <true/>
#   <key>IDECodeSnippetVersion</key>
#   <integer>2</integer>
# </dict>
#
 
# Expected format of code file
# // #pragma Mark
# // Dividers and labels to organize your code into sections
# // 
# // Platform: All
# // Language: Objective-C
# // Completion Scopes: Top Level, Class Implementation, Class Interface Methods
 
# #pragma mark - <#Section#>
 
 
def exit_with_error(err)
  puts err
  exit(1)
end
 
def default_prefix(filename)
  File.basename(filename).split(".")[0]
end
 
def completion_scopes(code)
  scopes = code.scan(/\/\/\s+Completion Scopes?: (.+)$/).flatten.last.split(",")
  scopes = scopes.map do |scope|
    scope = scope.gsub(/\s+/, "")
    case scope.downcase
    when "functionormethod" then "CodeBlock"
    when "preprocessordirective" then "Preprocessor"
    else scope
    end
  end
  scopes
end
 
def title(code)
  code.split("\n").first.gsub(/\/\/ /, "")
end
 
def strip_comments(code)
  code.split("\n").select {|line| !line.start_with?("//")}.join("\n")
end
 
def code_snippet_version
  2
end
 
def source_code_language
  "Xcode.SourceCodeLanguage.Objective-C"
end
 
def user_snippet?
  true
end
 
def code_snippet_identifier
  SecureRandom.uuid.upcase
end
 
def platform_family(code)
  platform = code.scan(/\/\/ Platform: (.+)$/).flatten.last.downcase
  case platform
  when "all" then nil
  when "ios" then "iphoneos"
  when "osx" then "macosx"
  when "os x" then "macosx"
  else nil
  end
end
 
filename = ARGV.first rescue nil
exit_with_error "You must specify a filename" if filename.nil?
exit_with_error "The file #{filename} does not exist." unless File.exists?(filename)
 
puts "Converting #{filename}..."
code_contents = File.read(filename)
puts code_contents
puts
 
completion_prefix = default_prefix(filename)
 
puts "Using completion prefix: #{completion_prefix}"
 
snippet = {
  "IDECodeSnippetCompletionPrefix" => completion_prefix,
  "IDECodeSnippetCompletionScopes" => completion_scopes(code_contents),
  "IDECodeSnippetContents" => strip_comments(code_contents),
  "IDECodeSnippetTitle" => title(code_contents),
  "IDECodeSnippetIdentifier" => code_snippet_identifier,
  "IDECodeSnippetUserSnippet" => user_snippet?,
  "IDECodeSnippetVersion" => code_snippet_version,
  "IDECodeSnippetLanguage" => source_code_language
}
 
platform = platform_family(code_contents)
snippet.merge!("IDECodeSnippetPlatformFamily" => platform) if platform
 
plist_filename = "#{completion_prefix}.codesnippet"
 
File.open(plist_filename, "w") do |f|
  f << snippet.to_plist
end
 
puts
puts "#{plist_filename} was created."
