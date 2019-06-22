#include <.\idp\idp.iss>

#define MedusaInstallerVersion "v0.6"

#define AppId "{{991BED37-186A-5451-9E77-C3DCE91D56C7}"
#define AppName "Medusa"
#define AppPublisher "Medusa"
#define AppURL "https://github.com/pymedusa/Medusa"
#define AppServiceName AppName
#define AppServiceDescription "Automatic Video Library Manager for TV Shows"
#define ServiceStartIcon "{group}\Start " + AppName + " Service"
#define ServiceStopIcon "{group}\Stop " + AppName + " Service"
#define ServiceEditIcon "{group}\Edit " + AppName + " Service"

#define DefaultPort 8081

#define InstallerVersion 10006
#define InstallerSeedUrl "https://raw.githubusercontent.com/pymedusa/MedusaInstaller/master/seed.ini"
#define AppRepoUrl "https://github.com/pymedusa/Medusa.git"
#define AppSize 246784000

[Setup]
AppId={#AppId}
AppName={#AppName}
AppVerName={#AppName}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={sd}\{#AppName}
DefaultGroupName={#AppName}
AllowNoIcons=yes
DisableWelcomePage=no
DisableDirPage=no
DisableProgramGroupPage=no
ArchitecturesInstallIn64BitMode=x64
OutputBaseFilename={#AppName}Installer
SolidCompression=yes
UninstallDisplayIcon={app}\Installer\medusa.ico
UninstallFilesDir={app}\Installer
SetupIconFile=assets\medusa.ico
WizardImageFile=assets\Wizard.bmp
WizardSmallImageFile=assets\WizardSmall.bmp
WizardStyle=modern
WizardResizable=no

[Types]
Name: "full"; Description: "Full installation"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "application"; Description: {#AppName}; ExtraDiskSpaceRequired: {#AppSize}; Types: "full custom"; Flags: fixed
Name: "python"; Description: "Python"; ExtraDiskSpaceRequired: 36000000; Types: "full custom"
Name: "git"; Description: "Git"; ExtraDiskSpaceRequired: 55000000; Types: "full custom"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "utils\7za.exe"; Flags: dontcopy
Source: "assets\medusa.ico"; DestDir: "{app}\Installer"
Source: "assets\github.ico"; DestDir: "{app}\Installer"
Source: "utils\nssm32.exe"; DestDir: "{app}\Installer"; DestName: "nssm.exe"; Check: not Is64BitInstallMode
Source: "utils\nssm64.exe"; DestDir: "{app}\Installer"; DestName: "nssm.exe"; Check: Is64BitInstallMode

[Dirs]
Name: "{app}\Data"

[Icons]
;Desktop
Name: "{commondesktop}\{#AppName}"; Filename: "http://localhost:{code:GetWebPort}/"; IconFilename: "{app}\Installer\medusa.ico"; Tasks: desktopicon
;Start menu
Name: "{group}\{#AppName}"; Filename: "http://localhost:{code:GetWebPort}/"; IconFilename: "{app}\Installer\medusa.ico"
Name: "{group}\{#AppName} on GitHub"; Filename: "{#AppURL}"; IconFilename: "{app}\Installer\github.ico"; Flags: excludefromshowinnewinstall
Name: "{#ServiceStartIcon}"; Filename: "{app}\Installer\nssm.exe"; Parameters: "start ""{#AppServiceName}"""; Flags: excludefromshowinnewinstall
Name: "{#ServiceStopIcon}"; Filename: "{app}\Installer\nssm.exe"; Parameters: "stop ""{#AppServiceName}"""; Flags: excludefromshowinnewinstall
Name: "{#ServiceEditIcon}"; Filename: "{app}\Installer\nssm.exe"; Parameters: "edit ""{#AppServiceName}"""; AfterInstall: ModifyServiceLinks; Flags: excludefromshowinnewinstall

[Run]
;Medusa
Filename: "{code:GetGitExecutable}"; Parameters: "clone ""{param:LOCALREPO|{#AppRepoUrl}}"" ""{app}\{#AppName}"" --branch {code:GetBranch}"; StatusMsg: "Installing {#AppName}..."
;Service
Filename: "{app}\Installer\nssm.exe"; Parameters: "start ""{#AppServiceName}"""; Flags: runhidden; BeforeInstall: CreateService; StatusMsg: "Starting {#AppName} service..."
;Open
Filename: "http://localhost:{code:GetWebPort}/"; Flags: postinstall shellexec; Description: "Open {#AppName} in browser"

[UninstallRun]
;Service
Filename: "{app}\Installer\nssm.exe"; Parameters: "remove ""{#AppServiceName}"" confirm"; Flags: runhidden

[UninstallDelete]
Type: filesandordirs; Name: "{app}\Python"
Type: filesandordirs; Name: "{app}\Git"
Type: filesandordirs; Name: "{app}\Installer"
Type: filesandordirs; Name: "{app}\{#AppName}"
Type: dirifempty; Name: "{app}"

[Messages]
WelcomeLabel2=This will install [name/ver] on your computer.%n%nYou will need Internet connectivity in order to download the required packages.
SelectComponentsLabel2=Select the components you want to install; clear the components you do not want to install. Click Next when you are ready to continue. \
  %n%nPlease note: \
  %n  By default, this installer provides the dependencies required to run [name]. \
  %n  If you have Git or Python already installed on your system, and you would prefer to use those versions, \
  %n  you may deselect the dependencies you already have and provide a path to the already-installed versions.
AboutSetupNote=MedusaInstaller {#MedusaInstallerVersion}
BeveledLabel=MedusaInstaller {#MedusaInstallerVersion}

[INI]
Filename: "{app}\Data\config.ini"; Section: "General"; Key: "web_port"; String: "{code:GetWebPort}"; Flags: createkeyifdoesntexist

[Code]
type
  TDependency = record
    Name:     String;
    URL:      String;
    Filename: String;
    Size:     Integer;
    SHA1:     String;
    Version:  String;
  end;

  TBrowseOptions = record
    Caption: TNewStaticText;
    Path: TNewStaticText;
    Browse: TNewButton;
  end;

  TInstallOptions = record
    Page: TWizardPage;
    WebPort: TNewEdit;
    Branch: TNewCheckListBox;
    Python: TBrowseOptions;
    Git: TBrowseOptions;
  end;

  IShellLinkW = interface(IUnknown)
    '{000214F9-0000-0000-C000-000000000046}'
    procedure Dummy;
    procedure Dummy2;
    procedure Dummy3;
    function GetDescription(pszName: String; cchMaxName: Integer): HResult;
    function SetDescription(pszName: String): HResult;
    function GetWorkingDirectory(pszDir: String; cchMaxPath: Integer): HResult;
    function SetWorkingDirectory(pszDir: String): HResult;
    function GetArguments(pszArgs: String; cchMaxPath: Integer): HResult;
    function SetArguments(pszArgs: String): HResult;
    function GetHotkey(var pwHotkey: Word): HResult;
    function SetHotkey(wHotkey: Word): HResult;
    function GetShowCmd(out piShowCmd: Integer): HResult;
    function SetShowCmd(iShowCmd: Integer): HResult;
    function GetIconLocation(pszIconPath: String; cchIconPath: Integer;
      out piIcon: Integer): HResult;
    function SetIconLocation(pszIconPath: String; iIcon: Integer): HResult;
    function SetRelativePath(pszPathRel: String; dwReserved: DWORD): HResult;
    function Resolve(Wnd: HWND; fFlags: DWORD): HResult;
    function SetPath(pszFile: String): HResult;
  end;

  IPersist = interface(IUnknown)
    '{0000010C-0000-0000-C000-000000000046}'
    function GetClassID(var classID: TGUID): HResult;
  end;

  IPersistFile = interface(IPersist)
    '{0000010B-0000-0000-C000-000000000046}'
    function IsDirty: HResult;
    function Load(pszFileName: String; dwMode: Longint): HResult;
    function Save(pszFileName: String; fRemember: BOOL): HResult;
    function SaveCompleted(pszFileName: String): HResult;
    function GetCurFile(out pszFileName: String): HResult;
  end;

  IShellLinkDataList = interface(IUnknown)
    '{45E2B4AE-B1C3-11D0-B92F-00A0C90312E1}'
    procedure Dummy;
    procedure Dummy2;
    procedure Dummy3;
    function GetFlags(out dwFlags: DWORD): HResult;
    function SetFlags(dwFlags: DWORD): HResult;
  end;

const
  MinPort = 1;
  MaxPort = 65535;
  WM_CLOSE             = $0010;
  GENERIC_WRITE        = $40000000;
  GENERIC_READ         = $80000000;
  OPEN_EXISTING        = 3;
  INVALID_HANDLE_VALUE = $FFFFFFFF;
  SLDF_RUNAS_USER      = $00002000;
  CLSID_ShellLink = '{00021401-0000-0000-C000-000000000046}';

var
  // This lets AbortInstallation() terminate setup without prompting the user
  CancelWithoutPrompt: Boolean;
  ErrorMessage, LocalFilesDir: String;
  SeedDownloadPageId, DependencyDownloadPageId: Integer;
  PythonDep, GitDep: TDependency;
  InstallDepPage: TOutputProgressWizardPage;
  InstallOptions: TInstallOptions;
  // Uninstall variables
  UninstallRemoveData: Boolean;

// Import some Win32 functions
function CreateFile(
  lpFileName: String;
  dwDesiredAccess: LongWord;
  dwSharedMode: LongWord;
  lpSecurityAttributes: LongWord;
  dwCreationDisposition: LongWord;
  dwFlagsAndAttributes: LongWord;
  hTemplateFile: LongWord): LongWord;
external 'CreateFileW@kernel32.dll stdcall';

function CloseHandle(hObject: LongWord): Boolean;
external 'CloseHandle@kernel32.dll stdcall';

procedure AbortInstallation(ErrorMessage: String);
begin
  MsgBox(ErrorMessage + #13#10#13#10 'Setup will now terminate.', mbError, 0)
  CancelWithoutPrompt := True
  PostMessage(WizardForm.Handle, WM_CLOSE, 0, 0);
end;

procedure CheckInstallerVersion(SeedFile: String);
var
  InstallerVersion, CurrentVersion: Integer;
  DownloadUrl: String;
begin
  InstallerVersion := StrToInt(ExpandConstant('{#InstallerVersion}'))

  CurrentVersion := GetIniInt('Installer', 'Version', 0, 0, MaxInt, SeedFile)

  if CurrentVersion = 0 then begin
    AbortInstallation('Unable to parse configuration.')
  end;

  if CurrentVersion > InstallerVersion then begin
    DownloadUrl := GetIniString('Installer', 'DownloadUrl', ExpandConstant('{#AppURL}'), SeedFile)
    AbortInstallation(ExpandConstant('This is an old version of the {#AppName} installer. Please get the latest version at:') + #13#10#13#10 + DownloadUrl)
  end;
end;

function GetDependencyVersion(Dependency: TDependency): String;
var
  StartIndex: Integer;
begin
  Result := Dependency.Filename;
  // Handle Git dependency
  if Pos('git', Lowercase(Dependency.Name)) <> 0 then begin
    // --> MinGit-2.22.0-32-bit.zip
    // --> MinGit-2.22.0-64-bit.zip
    StartIndex := Pos('-', Result) + 1;
    Result := Copy(Result, StartIndex, Length(Result));
    // <-- 2.22.0-64-bit.zip
    StartIndex := Pos('-', Result);
    Delete(Result, StartIndex, Length(Result));
    // <-- 2.22.0
  // Handle Python dependency
  end else if Pos('python', Lowercase(Dependency.Name)) <> 0 then begin
    // --> pythonx86.3.7.3.nupkg
    // --> python.3.7.3.nupkg
    StartIndex := Pos('.', Result) + 1;
    Result := Copy(Result, StartIndex, Length(Result));
    // <-- 3.7.3.nupkg
    StartIndex := Pos('nupkg', Result) - 1;
    Delete(Result, StartIndex, Length(Result));
    // <-- 3.7.3
  end else begin
    Result := '';
  end;
end;

procedure UpdateComponentsPageDependencyVersions();
var
  Idx: Integer;
  Version: String;
begin
  for Idx := 0 to WizardForm.ComponentsList.Items.Count - 1 do
  begin
    Version := '';

    if Pos('python', Lowercase(WizardForm.ComponentsList.ItemCaption[Idx])) <> 0 then begin
      Version := ' (v' + PythonDep.Version + ')';
    end;

    if Pos('git', Lowercase(WizardForm.ComponentsList.ItemCaption[Idx])) <> 0 then begin
      Version := ' (v' + GitDep.Version + ')';
    end;

    WizardForm.ComponentsList.ItemCaption[Idx] := WizardForm.ComponentsList.ItemCaption[Idx] + Version;
  end;
end;

procedure ParseDependency(var Dependency: TDependency; Name, SeedFile: String);
var
  LocalFile: String;
  DownloadTarget: String;
begin
  Dependency.Name     := Name;
  Dependency.URL      := GetIniString(Name, 'url', '', SeedFile)
  Dependency.Filename := GetIniString(Name, 'filename', '', SeedFile)
  Dependency.Size     := GetIniInt(Name, 'size', 0, 0, MaxInt, SeedFile)
  Dependency.SHA1     := GetIniString(Name, 'sha1', '', SeedFile)
  Dependency.Version  := '';

  if (Dependency.URL = '') or (Dependency.Size = 0) or (Dependency.SHA1 = '') then begin
    AbortInstallation('Error parsing dependency information for ' + Name + '.')
  end;

  // If a filename was not supplied, use the last part of the URL as the filename
  if Dependency.Filename = '' then begin
    Dependency.Filename := Dependency.URL
    while Pos('/', Dependency.Filename) <> 0 do begin
      Delete(Dependency.Filename, 1, Pos('/', Dependency.Filename))
    end;
  end;

  if LocalFilesDir <> '' then begin
    LocalFile := LocalFilesDir + '\' + Dependency.Filename
  end;

  DownloadTarget := ExpandConstant('{tmp}\') + Dependency.Filename
  if (LocalFile <> '') and (FileExists(LocalFile)) then begin
    FileCopy(LocalFile, DownloadTarget, True)
  end else begin
    idpAddFileSize(Dependency.URL, DownloadTarget, Dependency.Size)
  end;

  Dependency.Version := GetDependencyVersion(Dependency);
end;

procedure ParseSeedFile();
var
  SeedFile: String;
  Arch: String;
  DownloadPage: TWizardPage;
begin
  SeedFile := ExpandConstant('{tmp}\installer.ini')

  // Make sure we're running the latest version of the installer
  CheckInstallerVersion(SeedFile)

  if Is64BitInstallMode then
    Arch := 'x64'
  else
    Arch := 'x86';

  ParseDependency(PythonDep,    'Python.'    + Arch, SeedFile)
  ParseDependency(GitDep,       'Git.'       + Arch, SeedFile)

  DependencyDownloadPageId := idpCreateDownloadForm(wpPreparing)
  DownloadPage := PageFromID(DependencyDownloadPageId)
  DownloadPage.Caption := 'Downloading Dependencies'
  DownloadPage.Description := ExpandConstant('Setup is downloading {#AppName} dependencies...')

  idpSetOption('DetailedMode', '1')
  idpSetOption('DetailsButton', '0')

  idpConnectControls()
end;

procedure InitializeSeedDownload();
var
  DownloadPage: TWizardPage;
  Seed: String;
  IsRemote: Boolean;
begin
  IsRemote := True

  Seed := ExpandConstant('{param:SEED}')
  if (Lowercase(Copy(Seed, 1, 7)) <> 'http://') and (Lowercase(Copy(Seed, 1, 8)) <> 'https://') then begin
    if Seed = '' then begin
      Seed := ExpandConstant('{#InstallerSeedUrl}')
    end else begin
      if FileExists(Seed) then begin
        IsRemote := False
      end else begin
        MsgBox('Invalid SEED specified: ' + Seed, mbError, 0)
        Seed := ExpandConstant('{#InstallerSeedUrl}')
      end;
    end;
  end;

  if not IsRemote then begin
    FileCopy(Seed, ExpandConstant('{tmp}\installer.ini'), False)
    ParseSeedFile()
    UpdateComponentsPageDependencyVersions()
  end else begin
    // Download the installer seed INI file
    // I'm adding a dummy size here otherwise the installer crashes (divide by 0)
    // when runnning in silent mode, a bug in IDP maybe?
    idpAddFileSize(Seed, ExpandConstant('{tmp}\installer.ini'), 1024)

    SeedDownloadPageId := idpCreateDownloadForm(wpWelcome)
    DownloadPage := PageFromID(SeedDownloadPageId)
    DownloadPage.Caption := 'Downloading Installer Configuration'
    DownloadPage.Description := 'Setup is downloading its configuration file...'

    idpConnectControls()
  end;
end;

function CheckFileInUse(Filename: String): Boolean;
var
  FileHandle: LongWord;
begin
  if not FileExists(Filename) then begin
    Result := False
    exit
  end;

  FileHandle := CreateFile(Filename, GENERIC_READ or GENERIC_WRITE, 0, 0, OPEN_EXISTING, 0, 0)
  if (FileHandle <> 0) and (FileHandle <> INVALID_HANDLE_VALUE) then begin
    CloseHandle(FileHandle)
    Result := False
  end else begin
    Result := True
  end;
end;

function GetPythonExecutable(Param: String): String;
begin
  if WizardIsComponentSelected('python') then begin
    Result := ExpandConstant('{app}\Python\python.exe')
  end else begin
    Result := InstallOptions.Python.Path.Caption
  end;
end;

function GetGitExecutable(Param: String): String;
begin
  if WizardIsComponentSelected('git') then begin
    Result := ExpandConstant('{app}\Git\cmd\git.exe')
  end else begin
    Result := InstallOptions.Git.Path.Caption
  end;
end;

function GetWebPort(Param: String): String;
begin
  Result := InstallOptions.WebPort.Text
end;

function GetBranch(Param: String): String;
var
  Idx: Integer;
begin
  for Idx := 0 to InstallOptions.Branch.Items.Count - 1 do
  begin
    if InstallOptions.Branch.Checked[Idx] then begin
      Result := InstallOptions.Branch.ItemCaption[Idx]
      break;
    end;
  end;
end;

function ConfigureCustomPython(Python: String): String;
var
  VirtualEnvPath: String;
  ResultCode: Integer;
begin
  VirtualEnvPath := ExpandConstant('{app}\Python')
  Result := VirtualEnvPath + '\Scripts\python.exe'

  Exec(Python, '-m venv "'+VirtualEnvPath+'"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
  if ResultCode = 0 then begin
    // Success using venv (Included in Python >= 3.3)
    exit;
  end;

  // Fall back to installing latest `virtualenv` using Pip and using that.
  // Some versions of Pip for Python 2.7 on Windows have an issue where having a progress bar can fail the install.
  Exec(Python, '-m pip install --progress-bar off --upgrade virtualenv', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
  if ResultCode = 0 then begin
    // Install/Upgrade successful
    Exec(Python, '-m virtualenv "'+VirtualEnvPath+'"', '', SW_SHOW, ewWaitUntilTerminated, ResultCode)
    if ResultCode = 0 then begin
      // Success using virtualenv (external package)
      exit;
    end;
  end;

  // Fall back to non-virtualenv (not recommended).
  Result := Python;
  MsgBox(
    'Failed to configure custom Python:' #13#10#13#10 'Unable to install/upgrade or configure virtualenv.' + \
    #13#10 'Falling back to using the custom Python executable as-is (not recommended).',
    mbError, MB_OK
  );
end;

procedure CreateService();
var
  PythonExecutable: String;
  GitPath: String;
  Nssm: String;
  ResultCode: Integer;
  OldProgressString: String;
  WindowsVersion: TWindowsVersion;
begin
  PythonExecutable := GetPythonExecutable('')
  GitPath := ExtractFileDir(GetGitExecutable(''))

  OldProgressString := WizardForm.StatusLabel.Caption;

  // Python was not selected, let's isolate this install using v(irtual)env
  if not WizardIsComponentSelected('python') then begin
    WizardForm.StatusLabel.Caption := ExpandConstant('Configuring custom Python...');
    // Returns the path to the new virtual env's Python executable.
    PythonExecutable := ConfigureCustomPython(PythonExecutable);
  end;

  Nssm := ExpandConstant('{app}\Installer\nssm.exe')
  GetWindowsVersionEx(WindowsVersion);

  WizardForm.StatusLabel.Caption := ExpandConstant('Installing {#AppName} service...')

  // Keep extra quotes; See "Quoting issues" on https://nssm.cc/usage
  Exec(Nssm, ExpandConstant('install "{#AppServiceName}" "'+PythonExecutable+'" """{app}\{#AppName}\start.py""" --nolaunch --datadir="""{app}\Data"""'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  Exec(Nssm, ExpandConstant('set "{#AppServiceName}" AppDirectory "{app}\Data"'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  Exec(Nssm, ExpandConstant('set "{#AppServiceName}" Description "{#AppServiceDescription}"'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  Exec(Nssm, ExpandConstant('set "{#AppServiceName}" AppStopMethodSkip 6'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  Exec(Nssm, ExpandConstant('set "{#AppServiceName}" AppStopMethodConsole 20000'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  Exec(Nssm, ExpandConstant('set "{#AppServiceName}" AppEnvironmentExtra "PATH='+GitPath+';%PATH%"'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)

  if WindowsVersion.NTPlatform and (WindowsVersion.Major = 10) and (WindowsVersion.Minor = 0) and (WindowsVersion.Build > 14393) then begin
    Exec(Nssm, ExpandConstant('set "{#AppServiceName}" AppNoConsole 1'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  end;

  WizardForm.StatusLabel.Caption := OldProgressString;
end;

procedure StopService();
var
  Nssm: String;
  ResultCode: Integer;
  Retries: Integer;
  OldProgressString: String;
begin
  Retries := 30

  OldProgressString := UninstallProgressForm.StatusLabel.Caption;
  UninstallProgressForm.StatusLabel.Caption := ExpandConstant('Stopping {#AppName} service...')

  Nssm := ExpandConstant('{app}\Installer\nssm.exe')
  Exec(Nssm, ExpandConstant('stop "{#AppServiceName}"'), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)

  while (Retries > 0) and (CheckFileInUse(Nssm)) do begin
    UninstallProgressForm.StatusLabel.Caption := ExpandConstant('Waiting for {#AppName} service to stop (') + IntToStr(Retries) + ')...'
    Sleep(1000)
    Retries := Retries - 1
  end;

  UninstallProgressForm.StatusLabel.Caption := OldProgressString;
end;

procedure CleanPython();
var
  PythonPath: String;
begin
  PythonPath := ExpandConstant('{app}\Python')
  DelTree(PythonPath + '\Tools',        True,  True, True)
end;

procedure InstallPython();
var
  ResultCode: Integer;
begin
  InstallDepPage.SetText('Installing Python...', '')
  Exec(ExpandConstant('{tmp}\7za.exe'), ExpandConstantEx('x "{tmp}\{filename}" -o"{app}" tools', 'filename', PythonDep.Filename), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  RenameFile(ExpandConstant('{app}\tools'), ExpandConstant('{app}\Python'))
  CleanPython()
  InstallDepPage.SetProgress(InstallDepPage.ProgressBar.Position+1, InstallDepPage.ProgressBar.Max)
end;

procedure InstallGit();
var
  ResultCode: Integer;
begin
  InstallDepPage.SetText('Installing Git...', '')
  Exec(ExpandConstant('{tmp}\7za.exe'), ExpandConstantEx('x "{tmp}\{filename}" -o"{app}\Git"', 'filename', GitDep.Filename), '', SW_HIDE, ewWaitUntilTerminated, ResultCode)
  InstallDepPage.SetProgress(InstallDepPage.ProgressBar.Position+1, InstallDepPage.ProgressBar.Max)
end;

function VerifyDependency(Dependency: TDependency): Boolean;
begin
  Result := True

  InstallDepPage.SetText('Verifying dependency files...', Dependency.Filename)
  if GetSHA1OfFile(ExpandConstant('{tmp}\') + Dependency.Filename) <> Dependency.SHA1 then begin
    MsgBox('SHA1 hash of ' + Dependency.Filename + ' does not match.', mbError, 0)
    Result := False
  end;
  InstallDepPage.SetProgress(InstallDepPage.ProgressBar.Position+1, InstallDepPage.ProgressBar.Max)
end;

function VerifyDependencies(): Boolean;
begin
  Result := True

  Result := Result and VerifyDependency(PythonDep)
  Result := Result and VerifyDependency(GitDep)
end;

procedure OnPythonBrowseClick(Sender: TObject);
var
  Filename: String;
  FilenameLength: Integer;
begin
  // Browse for a custom Python executable
  if GetOpenFilename('Path to Python executable:', Filename, '', 'Python executable (python.exe)|python.exe', 'python.exe') then begin
    FilenameLength := Length(Filename);
    if Copy(Filename, FilenameLength - Length('\python.exe') + 1, FilenameLength) = '\python.exe' then begin
      InstallOptions.Python.Path.Caption := Filename;
    end;
  end;
end;

procedure OnGitBrowseClick(Sender: TObject);
var
  Filename: String;
  FilenameLength: Integer;
begin
  // Browse for a custom Git executable
  if GetOpenFilename('Path to Git executable:', Filename, '', 'Git executable (git.exe)|git.exe', 'git.exe') then begin
    FilenameLength := Length(Filename);
    if Copy(Filename, FilenameLength - Length('\git.exe') + 1, FilenameLength) = '\git.exe' then begin
      InstallOptions.Git.Path.Caption := Filename;
    end;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  if ErrorMessage <> '' then begin
    Result := ErrorMessage
  end;
end;

procedure InstallDependencies();
var
  PythonSelected: Boolean;
  GitSelected: Boolean;
begin
  PythonSelected := WizardIsComponentSelected('python')
  GitSelected := WizardIsComponentSelected('git')

  if not (PythonSelected or GitSelected) then begin
    exit;
  end;

  try
    InstallDepPage.Show
    InstallDepPage.SetProgress(0, 6)
    if VerifyDependencies() then begin
      ExtractTemporaryFile('7za.exe')
      if PythonSelected then InstallPython();
      if GitSelected then InstallGit();
    end else begin
      ErrorMessage := 'There was an error installing the required dependencies.'
    end;
  finally
    InstallDepPage.Hide
  end;
end;

procedure InitializeWizard();
var
  WebPortCaption: TNewStaticText;
begin
  InitializeSeedDownload()

  idpInitMessages()

  InstallDepPage := CreateOutputProgressPage('Installing Dependencies', ExpandConstant('Setup is installing {#AppName} dependencies...'));

  // Custom Options Page
  InstallOptions.Page := CreateCustomPage(wpSelectProgramGroup, 'Additional Options', ExpandConstant('Additional {#AppName} configuration options'));

  WebPortCaption := TNewStaticText.Create(InstallOptions.Page);
  WebPortCaption.Anchors := [akLeft, akRight];
  WebPortCaption.Caption := ExpandConstant('{#AppName} Web Server Port:');
  WebPortCaption.AutoSize := True;
  WebPortCaption.Parent := InstallOptions.Page.Surface;

  InstallOptions.WebPort := TNewEdit.Create(InstallOptions.Page);
  InstallOptions.WebPort.Top := WebPortCaption.Top + WebPortCaption.Height + ScaleY(8);
  InstallOptions.WebPort.Text := ExpandConstant('{#DefaultPort}');
  InstallOptions.WebPort.Parent := InstallOptions.Page.Surface;
  InstallOptions.WebPort.Width := ScaleX(50);

  InstallOptions.Branch := TNewCheckListBox.Create(InstallOptions.Page);
  InstallOptions.Branch.Top := InstallOptions.WebPort.Top + InstallOptions.WebPort.Height;
  InstallOptions.Branch.Width := ScaleX(50);
  InstallOptions.Branch.Height := ScaleY(70);
  InstallOptions.Branch.Anchors := [akLeft, akRight];
  InstallOptions.Branch.BorderStyle := bsNone;
  InstallOptions.Branch.ParentColor := True;
  InstallOptions.Branch.MinItemHeight := WizardForm.TasksList.MinItemHeight;
  InstallOptions.Branch.ShowLines := False;
  InstallOptions.Branch.WantTabs := True;
  InstallOptions.Branch.Parent := InstallOptions.Page.Surface;
  InstallOptions.Branch.AddGroup('Branch:', '', 0, nil);
  InstallOptions.Branch.AddRadioButton('master', '(stable)', 0, True, True, nil);
  InstallOptions.Branch.AddRadioButton('develop', '(development)', 0, False, True, nil);

  InstallOptions.Python.Caption := TNewStaticText.Create(InstallOptions.Page);
  InstallOptions.Python.Caption.Anchors := [akLeft, akRight];
  InstallOptions.Python.Caption.Top := InstallOptions.Branch.Top + InstallOptions.Branch.Height + ScaleY(8);
  InstallOptions.Python.Caption.Caption := 'Path to Python executable:';
  InstallOptions.Python.Caption.AutoSize := True;
  InstallOptions.Python.Caption.Parent := InstallOptions.Page.Surface;
  InstallOptions.Python.Caption.Visible := False;

  InstallOptions.Python.Path := TNewStaticText.Create(InstallOptions.Page);
  InstallOptions.Python.Path.Anchors := [akLeft];
  InstallOptions.Python.Path.Top := InstallOptions.Python.Caption.Top;
  InstallOptions.Python.Path.Left := InstallOptions.Python.Caption.Left + InstallOptions.Python.Caption.Width + ScaleX(2);
  InstallOptions.Python.Path.AutoSize := True;
  InstallOptions.Python.Path.Parent := InstallOptions.Page.Surface;
  InstallOptions.Python.Path.Caption := '';
  InstallOptions.Python.Path.Visible := False;

  InstallOptions.Python.Browse := TNewButton.Create(InstallOptions.Page);
  InstallOptions.Python.Browse.Anchors := [akLeft];
  InstallOptions.Python.Browse.Top := InstallOptions.Python.Path.Top + InstallOptions.Python.Path.Height;
  InstallOptions.Python.Browse.Parent := InstallOptions.Page.Surface;
  InstallOptions.Python.Browse.Width := ScaleX(75);
  InstallOptions.Python.Browse.Height := ScaleY(23);
  InstallOptions.Python.Browse.Caption := 'Browse...';
  InstallOptions.Python.Browse.Visible := False;
  InstallOptions.Python.Browse.OnClick := @OnPythonBrowseClick;

  InstallOptions.Git.Caption := TNewStaticText.Create(InstallOptions.Page);
  InstallOptions.Git.Caption.Anchors := [akLeft, akRight];
  InstallOptions.Git.Caption.Top := InstallOptions.Python.Browse.Top + InstallOptions.Python.Browse.Height + ScaleY(8);
  InstallOptions.Git.Caption.Caption := 'Path to Git executable:';
  InstallOptions.Git.Caption.AutoSize := True;
  InstallOptions.Git.Caption.Parent := InstallOptions.Page.Surface;
  InstallOptions.Git.Caption.Visible := False;

  InstallOptions.Git.Path := TNewStaticText.Create(InstallOptions.Page);
  InstallOptions.Git.Path.Anchors := [akLeft];
  InstallOptions.Git.Path.Top := InstallOptions.Git.Caption.Top;
  InstallOptions.Git.Path.Left := InstallOptions.Git.Caption.Left + InstallOptions.Git.Caption.Width + ScaleX(2);
  InstallOptions.Git.Path.AutoSize := True;
  InstallOptions.Git.Path.Parent := InstallOptions.Page.Surface;
  InstallOptions.Git.Path.Caption := '';
  InstallOptions.Git.Path.Visible := False;

  InstallOptions.Git.Browse := TNewButton.Create(InstallOptions.Page);
  InstallOptions.Git.Browse.Anchors := [akLeft];
  InstallOptions.Git.Browse.Top := InstallOptions.Git.Path.Top + InstallOptions.Git.Path.Height;
  InstallOptions.Git.Browse.Parent := InstallOptions.Page.Surface;
  InstallOptions.Git.Browse.Width := ScaleX(75);
  InstallOptions.Git.Browse.Height := ScaleY(23);
  InstallOptions.Git.Browse.Caption := 'Browse...';
  InstallOptions.Git.Browse.Visible := False;
  InstallOptions.Git.Browse.OnClick := @OnGitBrowseClick;
end;

function ShellLinkRunAsAdmin(LinkFilename: String): Boolean;
var
  Obj: IUnknown;
  SL: IShellLinkW;
  PF: IPersistFile;
  DL: IShellLinkDataList;
  Flags: DWORD;
begin
  try
    Obj := CreateComObject(StringToGuid(CLSID_ShellLink));

    SL := IShellLinkW(Obj);
    PF := IPersistFile(Obj);

    // Load the ShellLink
    OleCheck(PF.Load(LinkFilename, 0));

    // Set the SLDF_RUNAS_USER flag
    DL := IShellLinkDataList(Obj);
    OleCheck(DL.GetFlags(Flags))
    OleCheck(DL.SetFlags(Flags or SLDF_RUNAS_USER))

    // Save the ShellLink
    OleCheck(PF.Save(LinkFilename, True));

    Result := True
  except
    Result := False
  end;
end;

procedure ModifyServiceLinks();
begin
  ShellLinkRunAsAdmin(ExpandConstant('{#ServiceStartIcon}.lnk'))
  ShellLinkRunAsAdmin(ExpandConstant('{#ServiceStopIcon}.lnk'))
  ShellLinkRunAsAdmin(ExpandConstant('{#ServiceEditIcon}.lnk'))
end;

function InitializeSetup(): Boolean;
begin
  CancelWithoutPrompt := False

  LocalFilesDir := ExpandConstant('{param:LOCALFILES}')
  if (LocalFilesDir <> '') and (not DirExists(LocalFilesDir)) then begin
    MsgBox('Invalid LOCALFILES specified: ' + LocalFilesDir, mbError, 0)
    LocalFilesDir := ''
  end;

  // Don't allow installations over top
  if RegKeyExists(HKEY_LOCAL_MACHINE, ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#AppId}_is1')) then begin
    MsgBox(ExpandConstant('{#AppName} is already installed. If you''re reinstalling or upgrading, please uninstall the current version first.'), mbError, 0)
    Result := False
  end else begin
    Result := True
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Port: Integer;
begin
  Result := True;

  if CurPageID = SeedDownloadPageId then begin
    ParseSeedFile()
    UpdateComponentsPageDependencyVersions()
  end else if CurPageId = wpSelectComponents then begin
    // Make options visible depending on component selection
    InstallOptions.Python.Caption.Visible := not WizardIsComponentSelected('python');
    InstallOptions.Python.Path.Visible := not WizardIsComponentSelected('python');
    InstallOptions.Python.Path.Caption := '';
    InstallOptions.Python.Browse.Visible := not WizardIsComponentSelected('python');

    InstallOptions.Git.Caption.Visible := not WizardIsComponentSelected('git');
    InstallOptions.Git.Path.Visible := not WizardIsComponentSelected('git');
    InstallOptions.Git.Path.Caption := '';
    InstallOptions.Git.Browse.Visible := not WizardIsComponentSelected('git');
  end else if CurPageId = InstallOptions.Page.ID then begin
    // Make sure valid port is specified
    Port := StrToIntDef(GetWebPort(''), 0)
    if (Port = 0) or (Port < MinPort) or (Port > MaxPort) then begin
      MsgBox(FmtMessage('Please specify a valid port between %1 and %2.', [IntToStr(MinPort), IntToStr(MaxPort)]), mbError, 0)
      Result := False;
      exit;
    end;

    // Make sure custom Python path is supplied
    if not WizardIsComponentSelected('python') then begin
      if InstallOptions.Python.Path.Caption = '' then begin
        MsgBox('Please specify the path to the Python executable.', mbError, 0)
        Result := False;
        exit;
      end;
    end;

    // Make sure custom Git path is supplied
    if not WizardIsComponentSelected('git') then begin
      if InstallOptions.Git.Path.Caption = '' then begin
        MsgBox('Please specify the path to the Git executable.', mbError, 0)
        Result := False;
        exit;
      end;
    end;
  end;
end;

function UninstallShouldRemoveData(): Boolean;
begin
  Result := MsgBox(ExpandConstant('Do you want to remove your {#AppName} database and configuration?' #13#10#13#10 'Select No if you plan on reinstalling {#AppName}.'), mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm := not CancelWithoutPrompt;
end;

procedure InitializeUninstallProgressForm();
begin
  UninstallRemoveData := UninstallShouldRemoveData()
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then begin
    // Stop service
    StopService()

    // Remove data if requested
    if UninstallRemoveData then begin
      DelTree(ExpandConstant('{app}\Data'), True, True, True)
    end;
  end;
end;

function Append(const Lines, S, NewLine: String): String;
begin
  Result := S;
  if Lines <> '' then begin
    if Result <> '' then
      Result := Result + NewLine + NewLine;
    Result := Result + Lines;
  end;
end;

procedure InjectDependencyVersions(var MemoComponentsInfo: String);
var
  SearchStr: String;
  Position: Integer;
begin
  if MemoComponentsInfo = '' then begin
    exit;
  end;

  // Inject dependency versions into MemoComponentsInfo
  if WizardIsComponentSelected('git') and (GitDep.Version <> '') then begin
    SearchStr := '   Git'
    Position := Pos(SearchStr, MemoComponentsInfo)
    if Position <> 0 then begin
      Insert(' (v' + GitDep.Version + ')', MemoComponentsInfo, Position + Length(SearchStr));
    end;
  end;

  if WizardIsComponentSelected('python') and (PythonDep.Version <> '') then begin
    SearchStr := '   Python'
    Position := Pos(SearchStr, MemoComponentsInfo)
    if Position <> 0 then begin
      Insert(' (v' + PythonDep.Version + ')', MemoComponentsInfo, Position + Length(SearchStr));
    end;
  end;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
  MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
var
  S: String;
begin
  S := '';

  S := Append(MemoDirInfo, S, NewLine);
  S := Append(MemoGroupInfo, S, NewLine);
  // S := Append(MemoTypeInfo, S, NewLine);

  InjectDependencyVersions(MemoComponentsInfo);

  S := Append(MemoComponentsInfo, S, NewLine);

  S := Append('Web server port:' + NewLine + Space + GetWebPort(''), S, NewLine);
  S := Append('Branch: ' + NewLine + Space + GetBranch(''), S, NewLine);

  S := Append(MemoTasksInfo, S, NewLine);

  Result := S;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then begin
    InstallDependencies()
  end;
end;
