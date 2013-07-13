PROJECTNAME = 'STBase64Encoding'.freeze

task :default => 'analyze'

desc "Clean #{PROJECTNAME}-iOS and -mac"
task :clean => [ 'ios', 'mac' ].map { |x| 'clean:' + x }

desc "Analyze #{PROJECTNAME}-iOS and -mac"
task :analyze => [ 'ios', 'mac' ].map { |x| 'analyze:' + x }

desc "Execute #{PROJECTNAME}Tests-iOS and -mac"
task :test => [ 'ios', 'mac' ].map { |x| 'test:' + x }

namespace :clean do
	desc "Clean #{PROJECTNAME}-iOS"
	task :ios do Ios.clean end

	desc "Clean #{PROJECTNAME}-mac"
	task :mac do Mac.clean end
end

namespace :analyze do
	desc "Analyze #{PROJECTNAME}-iOS"
	task :ios do Ios.analyze end

	desc "Analyze #{PROJECTNAME}-mac"
	task :mac do Mac.analyze end
end

namespace :test do
	desc "Execute #{PROJECTNAME}Tests-iOS"
	task :ios do Ios.test end

	desc "Execute #{PROJECTNAME}Tests-mac"
	task :mac do Mac.test end
end


class BuildPlatform
	@BUILDARGS = [].freeze

	def self.clean
		system('xctool', *(@BUILDARGS + [ 'clean' ]))
	end

	def self.analyze
		system('xctool', *(@BUILDARGS + [ 'analyze' ]))
	end

	def self.test
		buildargs = @BUILDARGS + [
			'-configuration', 'Coverage',
		]
		testargs = [
			#'parallelize',
		]
		system('xctool', *(buildargs + [ 'test', *testargs ]))
	end
end

class Ios < BuildPlatform
	@BUILDARGS = [
		'-project', "#{PROJECTNAME}.xcodeproj",
		'-scheme', "#{PROJECTNAME}-iOS",
		'-sdk', 'iphonesimulator6.0',
		'ONLY_ACTIVE_ARCH=NO',
	].freeze
end

class Mac < BuildPlatform
	@BUILDARGS = [
		'-project', "#{PROJECTNAME}.xcodeproj",
		'-scheme', "#{PROJECTNAME}-mac",
		'-sdk', 'macosx10.8',
	].freeze
end
