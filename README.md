These instructions are specific to OS X, because that is the only platform that allows you to run OS X *within*
VMWare. The bash shell is required, as is git and sed. I strongly suggest you install homebrew (<http://brew.sh>) which
gives access to an enormous number of tools.

The setup is as follows:

1. Install VMWare, Packer (<http://packer.io>) and Vagrant (<http://vagrantup.com>),
and the the Vagrant VMWare connector, which can be purchased from <http://vagrantup.com>.

2. Create a directory structure as follows (which can be rooted anywhere), populated with the the following files.
You don't need the files for those versions you aren't going to build, although note that there are dependencies i.e. 
on Windows you need PowerShell 2 installed in order to install .NET 4.5.2 in order to install PowerShell 3, in order
to complete the installation.

  You will need Apple Developer Connection and MSDN accounts to get all of these, unless your organisation has stashed them
somewhere

        <<ROOT>>
            OSX/
              InstallerApps/
                Install OS X El Capitan.app
                Install OS X Mavericks.app
                Install OS X Mountain Lion.app
                Install OS X Yosemite.app
              DMGs/
              Utilities/
                Command_Line_Tools_OS_X_10.10_for_Xcode_7.dmg
                Command_Line_Tools_OS_X_10.11_for_Xcode_7.dmg
                command_line_tools_for_osx_mountain_lion_april_2014.dmg
                commandlinetoolsosx10.9forxcode6.2.dmg
            Windows/
              ISOs/
                en_windows_10_enterprise_x64_dvd_6851151.iso
                en_windows_10_enterprise_x86_dvd_6851156.iso
                en_windows_7_professional_with_sp1_x64_dvd_u_676939.iso
                en_windows_7_professional_with_sp1_x86_dvd_u_677056.iso
                en_windows_8.1_with_update_x64_dvd_4065090.iso
                en_windows_8.1_with_update_x86_dvd_4065105.iso
                en_windows_8_x64_dvd_915440.iso
                en_windows_8_x86_dvd_915417.iso
                en_windows_server_2008_r2_with_sp1_x64_dvd_617601.iso
                en_windows_server_2008_with_sp2_x64_dvd_342336.iso
                en_windows_server_2008_with_sp2_x86_dvd_342333.iso
                en_windows_server_2012_r2_with_update_x64_dvd_6052708.iso
                en_windows_server_2012_x64_dvd_915478.iso
              Utilities/
                7z920.exe                               # 7Zip for Windows installer
                KB968930-win2008-x64.msu                # PowerShell 2.0 installer
                KB968930-win2008-x86.msu                # PowerShell 2.0 installer
                NDP452-KB2901907-x86-x64-AllOS-ENU.exe  # .NET 4.5.2 installer
                Windows6.0-KB2506146-x64.msu            # PowerShell 3.0 installer
                Windows6.0-KB2506146-x86.msu            # PowerShell 3.0 installer
                Windows6.1-KB2506143-x64.msu            # PowerShell 3.0 installer
                Windows6.1-KB2506143-x86.msu            # PowerShell 3.0 installer
                setupssh-6.7p1-2.exe                    # OpenSSH for Windows installer

3. Checkout the Packer scripts and machine configurations from this git repository

        cd <<ROOT>>/
        git clone https://github.com/AntonyBlakey/packer-platforms.git packer

4. Build the DMGs from the Installer Apps for OSX

        cd <<ROOT>>/packer/osx/app-to-dmg
        ./prepare_iso.sh ../../../OSX/InstallerApps/Install\ OS\ X\ Mountain\ Lion.app ../../../OSX/DMGs
        ./prepare_iso.sh ../../../OSX/InstallerApps/Install\ OS\ X\ Mavericks.app ../../../OSX/DMGs
        ./prepare_iso.sh ../../../OSX/InstallerApps/Install\ OS\ X\ Yosemite.app ../../../OSX/DMGs
        ./prepare_iso.sh ../../../OSX/InstallerApps/Install\ OS\ X\ El\ Capitan.app ../../../OSX/DMGs

5. Copy `<<ROOT>>/packer/template-packer-config.sed.sample` to `<<ROOT>>/packer-config.sed` and
edit it to specify your Windows activation keys, Windows and OSX timezone and locale.

6. Build whichever boxes you want, e.g.

        cd <<ROOT>>/packer
        ./build-osx.sh osx/osx10
        ./build-windows.sh windows/win10/enterprise/x86
        
  You can build them all at once using cli scripting, although it will take a while :) Note that you might
  see some errors during construction, but that is to be expected. On Windows in particular openssh doesn't like to
  start immediately, although it's fine on restart, and on non-server versions of Windows there are two server-only commands
  that fail. Also, if you haven't downloaded all the Windows utility files then you might see some failures, but that's
  because I upload everything to the box even if it's not required. Everything is deleted as part of the build, so don't
  be concerned about that. Finally, the process of deleting the contents of the temp directory on some versions of windows
  will give error diagnostic output - also not something to worry about.

7. Add the boxes to the Vagrant box store, e.g.

        cd <<ROOT>>/packer/output
        vagrant box add --name win10-enterprise-x86 win10-enterprise-x86.box
        
  This is easy to script if you've built a heap of them.

8. Create your VMs using Vagrant, as you normally would.
