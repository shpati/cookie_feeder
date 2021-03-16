unit CF;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, ShellAPI, StdCtrls,
  Menus, inifiles, Math, Controls, Dialogs, Registry;

const WM_ICONTRAY = WM_USER + 1;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    PopupMenu1: TPopupMenu;
    N11: TMenuItem;
    N21: TMenuItem;
    OpenDialog1: TOpenDialog;
    Runonstartup1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure formhide(Sender: TObject);
    procedure TrayMessage(var Msg: TMessage); message WM_ICONTRAY;
    procedure initialsettings;
    procedure readsettings;
    function CountLinesInTextFile(const Filename: string): integer;
    function ReadLineInTextFile(const Filename: string; linenr: integer): string;
    procedure readcookie(Sender: TObject);
    procedure opendialog(Sender: TObject);
    procedure AboutClick(Sender: TObject);
    procedure ExitClick(Sender: TObject);
    procedure Runonstartup1Click(Sender: TObject);
    function CheckStartup: boolean;
    procedure hideit(Sender: TObject; var Action: TCloseAction);


  private
    TrayIconData: TNotifyIconData;
  end;

var
  Form1: TForm1;
  IniFile: TIniFile;
  fontsize, cookiesnr: integer;
  cookiefile, cookietext: string;

implementation

{$R *.dfm}

// Main procedure

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Top := Screen.WorkAreaHeight - Form1.Height - 10;
  Form1.Left := Screen.WorkAreaWidth - Form1.Width - 10;
  initialsettings;
  readsettings;
  readcookie(Form1);
  CheckStartup;
  TrayIconData.cbSize := SizeOf(TrayIconData);
  TrayIconData.Wnd := Handle;
  TrayIconData.uID := 0;
  TrayIconData.uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
  TrayIconData.uCallbackMessage := WM_ICONTRAY;
  TrayIconData.hIcon := Application.Icon.Handle;
  StrPCopy(TrayIconData.szTip, Application.Title);
  Shell_NotifyIcon(NIM_ADD, @TrayIconData);
  with OpenDialog1 do begin
    Options := Options + [ofPathMustExist, ofFileMustExist];
    InitialDir := ExtractFilePath(Application.ExeName);
    Filter := 'Text files (*.txt)|*.txt|All files (*.*)|*.*';
  end;
end;

// Hides the form.

procedure TForm1.formhide(Sender: TObject);
begin
  Form1.Hide;
end;

// Hides the form on Close instead of closing/unloading the form.

procedure TForm1.hideit(Sender: TObject; var Action: TCloseAction);
begin
  Action := caNone;
  Form1.Visible := false;
end;

// Tray commands. Left mouse button shows form, right mouse button shows menu.

procedure TForm1.TrayMessage(var Msg: TMessage);
var p: TPoint;
begin
  case Msg.lParam of
    WM_LBUTTONDOWN: begin
        Form1.Show;
        Application.Restore;
        readcookie(Form1);
      end;
    WM_RBUTTONDOWN: begin
        GetCursorPos(p);
        PopUpMenu1.Popup(p.x, p.y);
      end;
  end;
end;

// Creates initial .ini file if no file is found. Creates also intro cookie.

procedure TForm1.initialsettings;
var
  myFile: TextFile;
begin
  if not FileExists(ChangeFileExt(Application.ExeName, '.ini')) then
  begin
    if not FileExists('cookies.txt') then
    begin
      System.AssignFile(myFile, 'cookies.txt');
      ReWrite(myFile);
      WriteLn(myFile, 'This is an example cookie file with only this cookie. ' +
        'Each cookie entry is saved as a separate line in the file. The program' +
        ' will read a line at random every time it looks for a cookie. - Shpati');
      System.Closefile(myFile);
    end;
    System.AssignFile(myFile, ChangeFileExt(Application.ExeName, '.ini'));
    ReWrite(myFile);
    WriteLn(myFile, '[Settings]');
    WriteLn(myFile, 'cookiefile=', ExtractFileDir(Application.ExeName) +
      '\cookies.txt');
    WriteLn(myFile, 'fontsize=10');
    System.Closefile(myFile);
  end;
end;

// Reads settings from .ini file.

procedure TForm1.readsettings;
begin
  iniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
  cookiefile := iniFile.ReadString('Settings', 'cookiefile', cookiefile);
  Memo1.font.Size := iniFile.ReadInteger('Settings', 'fontsize', fontsize);
end;

// Counts the lines i.e. cookies inside the cookie file.

function TForm1.CountLinesInTextFile(const Filename: string): integer;
var
  ThisFile: TextFile;
begin
  Result := 0;
  if not FileExists(Filename) then Exit;
  AssignFile(ThisFile, Filename);
  Reset(ThisFile);
  while not Eof(ThisFile) do
  begin
    ReadLn(ThisFile);
    Inc(Result);
  end;
  CloseFile(ThisFile);
end;

// Reads the text from a given line inside the cookie file.

function TForm1.ReadLineInTextFile(const Filename: string; linenr: integer): string;
var
  ThisFile: TextFile;
  i: integer;
  cookie: string;
begin
  i := 0;
  Result := '';
  if not FileExists(Filename) then Exit;
  AssignFile(ThisFile, Filename);
  Reset(ThisFile);
  while not Eof(ThisFile) do
  begin
    ReadLn(ThisFile, cookie);
    Inc(i);
    if i = linenr then
    begin
      Result := cookie;
      exit;
    end;
  end;
  CloseFile(ThisFile);
end;

// Read a random cookie. Random seed is taken from current time in seconds.

procedure TForm1.readcookie(Sender: TObject);
var
  str: string;
begin
  str := '';
  RandSeed := trunc(Time * 24 * 60 * 60);
  Randomize;
  cookiesnr := (CountLinesInTextFile(cookiefile));
  while (str = '') or (str = sLineBreak) do
    str := ReadLineInTextFile(cookiefile, randomrange(1, cookiesnr + 1));
  if utf8toansi(str) <> '' then
    Memo1.text := utf8toansi(str)
  else
    Memo1.text := str;
end;

// Open dialog for selecting cookie file.

procedure TForm1.opendialog(Sender: TObject);
begin
  if OpenDialog1.Execute then begin
    begin
      iniFile := TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini'));
      cookiefile := OpenDialog1.FileName;
      iniFile.WriteString('Settings', 'cookiefile', cookiefile);
      readcookie(Form1);
    end;
  end;
end;

// Popup 'Run on Startup' menu item OnClick

procedure TForm1.Runonstartup1Click(Sender: TObject);
begin
  if CheckStartup = false then
    TRegIniFile.Create('').WriteString('Software\Microsoft\Windows\' +
    'CurrentVersion\Run', 'Cookie_Feeder', Application.ExeName)
  else
    TRegIniFile.Create('').DeleteKey('Software\Microsoft\Windows\' +
    'CurrentVersion\Run', 'Cookie_Feeder');
  checkstartup;
end;

function TForm1.CheckStartup: boolean;
begin
  if TRegIniFile.Create('').ReadString('Software\Microsoft\Windows\' +
  'CurrentVersion\Run', 'Cookie_Feeder', '') = '' then
    Runonstartup1.checked := false
  else
    Runonstartup1.checked := true;
  Result := Runonstartup1.checked;
end;

// Popup 'About' menu item OnClick

procedure TForm1.AboutClick(Sender: TObject);
begin
  Form1.Show;
  Memo1.Text := 'Cookie Feeder 2.0 - MIT License' + sLineBreak +
    'Copyright © MMXXI, Shpati Koleka.';
end;

// Popup 'Exit' menu item OnClick

procedure TForm1.ExitClick(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
  Application.terminate;
end;

end.

