# MedusaInstaller
A Windows Installer for Medusa

### **Please note:**
By default, this installer provides the dependencies required to run Medusa.  
If you have Git or Python already installed on your system, and you would prefer to use those versions,  
you may deselect the dependencies you already have and provide a path to the already-installed versions.

Features
--------
Here are some of the features of MedusaInstaller:
- Downloads Medusa dependencies (Git, Python)
- Installs everything (Medusa and dependencies) in a self-contained directory
- Installs Medusa as a Windows service (handled by NSSM)
- Detects 32-bit and 64-bit architectures and installs appropriate dependencies
- Creates Start Menu shortcuts
- When uninstalling, asks user if they want to delete or keep their database and configuration
- Allows configuring the web UI port during install
- Allows configuring the branch during install

The install script is written using the excellent [Inno Setup](http://www.jrsoftware.org/isinfo.php) by Jordan Russell.

Download
--------
Head on over to the [releases](https://github.com/pymedusa/MedusaInstaller/releases) tab.

How It Works
------------
First, the installer will grab a 'seed' file, located [here](https://raw.githubusercontent.com/pymedusa/MedusaInstaller/master/seed.ini). This has a list of the dependencies, the URLs they can be downloaded from, their size, and an SHA1 hash. It also uses this file to make sure the user is running the latest version of the installer.

Once the user steps through the pages of the wizard, the installer downloads the dependency files and verifies the SHA1 hash. It then installs them into the directory chosen by the user. Once the dependencies are installed, it uses Git to clone the Medusa repository.
