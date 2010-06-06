# To test out the pure Java main program on .NET, execute:
#
#   rake ikvm
#
# Just print dots:
#
#   [mono] pkg/gherkin.exe features
#
# Pretty print all to STDOUT:
#
#   [mono] pkg/gherkin.exe features pretty
#
# To test out the pure C# main program on .NET, execute:
#
#   rake ikvm (you need this to generate all the .dll files needed for the next step)
#
# Then build ikvm/Gherkin.sln. Then:
#
#   [mono] mono ikvm/Gherkin/bin/Debug/Gherkin.exe features/steps_parser.feature
#
namespace :ikvm do
  desc 'Make a .NET .exe'
  task :exe => 'lib/gherkin_native.jar' do
    mkdir_p 'release' unless File.directory?('release')
    sh("mono /usr/local/ikvm/bin/ikvmc.exe -target:exe lib/gherkin_native.jar -out:release/gherkin-#{GHERKIN_VERSION}.exe")
  end

  desc 'Make a .NET .dll'
  task :dll => 'lib/gherkin_native.jar' do
    mkdir_p 'release' unless File.directory?('release')
    sh("mono /usr/local/ikvm/bin/ikvmc.exe -target:library lib/gherkin_native.jar -out:release/gherkin-#{GHERKIN_VERSION}.dll")
    cp "release/gherkin-#{GHERKIN_VERSION}.dll", 'lib/gherkin_native.dll'
  end

  desc 'Copy the IKVM .dll files over to the pkg dir'
  task :copy_ikvm_dlls do
    Dir['/usr/local/ikvm/bin/{IKVM.OpenJDK.Core,IKVM.OpenJDK.Text,IKVM.OpenJDK.Security,IKVM.Runtime}.dll'].each do |dll|
      cp dll, 'release'
      cp dll, 'lib'
    end
  end
end

task :ikvm => ['ikvm:copy_ikvm_dlls', 'ikvm:exe', 'ikvm:dll'] do
  sh "mono release/gherkin-#{GHERKIN_VERSION}.exe features"
end

